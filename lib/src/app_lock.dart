import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

typedef AppLockKeyDeriver = Future<SecretKey> Function(
  String pin,
  List<int> salt,
);

abstract interface class AppLockStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureAppLockStore implements AppLockStore {
  const SecureAppLockStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class AppLockTemporarilyUnavailable implements Exception {
  const AppLockTemporarilyUnavailable(this.remaining);

  final Duration remaining;
}

class AppLockState {
  const AppLockState({
    required this.enabled,
    required this.biometricsEnabled,
    required this.failedAttempts,
    required this.lockedUntil,
    required this.promptDismissed,
  });

  final bool enabled;
  final bool biometricsEnabled;
  final int failedAttempts;
  final DateTime? lockedUntil;
  final bool promptDismissed;

  Duration remainingLockout(DateTime now) {
    final until = lockedUntil;
    if (until == null || !until.isAfter(now)) return Duration.zero;
    return until.difference(now);
  }
}

class AppLockService {
  AppLockService({
    AppLockStore? store,
    AppLockKeyDeriver? keyDeriver,
  })  : _store = store ?? const SecureAppLockStore(),
        _keyDeriver = keyDeriver ?? _deriveProductionKey;

  static const pinLength = 6;
  static const _enabledKey = 'mystic.app-lock.enabled.v1';
  static const _biometricsKey = 'mystic.app-lock.biometrics.v1';
  static const _saltKey = 'mystic.app-lock.pin-salt.v1';
  static const _verifierKey = 'mystic.app-lock.pin-verifier.v1';
  static const _failedAttemptsKey = 'mystic.app-lock.failed-attempts.v1';
  static const _lockedUntilKey = 'mystic.app-lock.locked-until.v1';
  static const _promptDismissedKey = 'mystic.app-lock.prompt-dismissed.v1';
  static const _verifierText = 'mystic-app-lock-verifier-v1';
  static const _aadText = 'MYSTIC-TAROT-APP-LOCK-V1';
  static const _saltLength = 16;

  static final _cipher = AesGcm.with256bits();
  static final _kdf = Argon2id(
    memory: 19 * 1024,
    parallelism: 1,
    iterations: 2,
    hashLength: 32,
  );

  final AppLockStore _store;
  final AppLockKeyDeriver _keyDeriver;

  Future<AppLockState> loadState() async {
    final enabled = await _store.read(_enabledKey) == '1';
    final biometrics = await _store.read(_biometricsKey) == '1';
    final failedAttempts =
        int.tryParse(await _store.read(_failedAttemptsKey) ?? '') ?? 0;
    final lockedUntilMillis =
        int.tryParse(await _store.read(_lockedUntilKey) ?? '');
    final promptDismissed =
        await _store.read(_promptDismissedKey) == '1';
    return AppLockState(
      enabled: enabled,
      biometricsEnabled: enabled && biometrics,
      failedAttempts: failedAttempts,
      lockedUntil: lockedUntilMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              lockedUntilMillis,
              isUtc: true,
            ),
      promptDismissed: promptDismissed,
    );
  }

  Future<void> enableWithPin(String pin) async {
    _validatePin(pin);
    final salt = SecretKeyData.random(length: _saltLength).bytes;
    final key = await _deriveKey(pin, salt);
    try {
      final box = await _cipher.encrypt(
        utf8.encode(_verifierText),
        secretKey: key,
        aad: utf8.encode(_aadText),
      );
      await _store.write(_saltKey, base64UrlEncode(salt));
      await _store.write(
        _verifierKey,
        base64UrlEncode(box.concatenation()),
      );
      await _store.write(_enabledKey, '1');
      await _store.write(_failedAttemptsKey, '0');
      await _store.delete(_lockedUntilKey);
      await _store.write(_promptDismissedKey, '1');
    } finally {
      key.destroy();
    }
  }

  Future<bool> verifyPin(
    String pin, {
    DateTime? now,
  }) async {
    _validatePin(pin);
    final currentTime = (now ?? DateTime.now()).toUtc();
    final state = await loadState();
    final remaining = state.remainingLockout(currentTime);
    if (remaining > Duration.zero) {
      throw AppLockTemporarilyUnavailable(remaining);
    }
    if (!state.enabled) return true;

    try {
      final saltText = await _store.read(_saltKey);
      final verifierText = await _store.read(_verifierKey);
      if (saltText == null || verifierText == null) {
        await _registerFailure(state.failedAttempts, currentTime);
        return false;
      }
      final salt = base64Url.decode(base64Url.normalize(saltText));
      if (salt.length != _saltLength) {
        await _registerFailure(state.failedAttempts, currentTime);
        return false;
      }
      final key = await _deriveKey(pin, salt);
      try {
        final bytes = base64Url.decode(base64Url.normalize(verifierText));
        final box = SecretBox.fromConcatenation(
          bytes,
          nonceLength: _cipher.nonceLength,
          macLength: _cipher.macAlgorithm.macLength,
        );
        final clear = await _cipher.decrypt(
          box,
          secretKey: key,
          aad: utf8.encode(_aadText),
        );
        final valid = utf8.decode(clear) == _verifierText;
        if (!valid) {
          await _registerFailure(state.failedAttempts, currentTime);
          return false;
        }
        await _resetFailures();
        return true;
      } finally {
        key.destroy();
      }
    } catch (error) {
      if (error is AppLockTemporarilyUnavailable) rethrow;
      await _registerFailure(state.failedAttempts, currentTime);
      return false;
    }
  }

  Future<void> markTrustedUnlock() => _resetFailures();

  Future<void> setBiometricsEnabled(bool enabled) async {
    final state = await loadState();
    if (!state.enabled && enabled) {
      throw StateError('App lock must be enabled before biometrics.');
    }
    await _store.write(_biometricsKey, enabled ? '1' : '0');
  }

  Future<void> dismissPrompt() => _store.write(_promptDismissedKey, '1');

  Future<void> disable() async {
    for (final key in _lockKeys) {
      await _store.delete(key);
    }
    await _store.write(_promptDismissedKey, '1');
  }

  static Future<SecretKey> _deriveProductionKey(
    String pin,
    List<int> salt,
  ) =>
      _kdf.deriveKeyFromPassword(password: pin, nonce: salt);

  Future<SecretKey> _deriveKey(String pin, List<int> salt) =>
      _keyDeriver(pin, salt);

  Future<void> _resetFailures() async {
    await _store.write(_failedAttemptsKey, '0');
    await _store.delete(_lockedUntilKey);
  }

  Future<void> _registerFailure(int previousAttempts, DateTime now) async {
    final attempts = previousAttempts + 1;
    await _store.write(_failedAttemptsKey, attempts.toString());
    final delay = switch (attempts) {
      >= 15 => const Duration(minutes: 30),
      >= 10 => const Duration(minutes: 5),
      >= 5 => const Duration(seconds: 30),
      _ => Duration.zero,
    };
    if (delay > Duration.zero) {
      await _store.write(
        _lockedUntilKey,
        now.add(delay).millisecondsSinceEpoch.toString(),
      );
    }
  }

  void _validatePin(String pin) {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw ArgumentError.value(
        pin,
        'pin',
        'PIN must contain exactly $pinLength digits.',
      );
    }
  }

  static const _lockKeys = <String>[
    _enabledKey,
    _biometricsKey,
    _saltKey,
    _verifierKey,
    _failedAttemptsKey,
    _lockedUntilKey,
  ];
}

abstract interface class AppLockAuthenticator {
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

class DeviceAppLockAuthenticator implements AppLockAuthenticator {
  DeviceAppLockAuthenticator({LocalAuthentication? authentication})
      : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      final supported = await _authentication.isDeviceSupported();
      if (!supported) return false;
      final available = await _authentication.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    if (kIsWeb) return false;
    try {
      return await _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
