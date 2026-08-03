import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class JournalTransferProtectionRequired implements Exception {
  const JournalTransferProtectionRequired();
}

class JournalTransferUnlockFailed implements Exception {
  const JournalTransferUnlockFailed();
}

class JournalTransferProtection {
  const JournalTransferProtection._();

  static const marker = 'MYSTIC-TAROT-JOURNAL-V2';
  static const schemaVersion = 2;
  static const minimumPassphraseLength = 8;
  static const saltLength = 16;
  static const memoryBlocks = 19 * 1024;
  static const iterations = 2;
  static const parallelism = 1;

  static final _cipher = AesGcm.with256bits();
  static final _kdf = Argon2id(
    memory: memoryBlocks,
    parallelism: parallelism,
    iterations: iterations,
    hashLength: 32,
  );

  static bool isProtectedCode(String value) =>
      value.trimLeft().startsWith(marker);

  static Future<String> protect({
    required String clearText,
    required String passphrase,
  }) async {
    _validatePassphrase(passphrase);
    final salt = SecretKeyData.random(length: saltLength).bytes;
    final secretKey = await _kdf.deriveKeyFromPassword(
      password: passphrase,
      nonce: salt,
    );
    try {
      final secretBox = await _cipher.encrypt(
        utf8.encode(clearText),
        secretKey: secretKey,
        aad: utf8.encode(marker),
      );
      final envelope = jsonEncode(<String, Object>{
        'schemaVersion': schemaVersion,
        'kind': 'protected-private-journal-transfer',
        'kdf': 'argon2id',
        'memory': memoryBlocks,
        'iterations': iterations,
        'parallelism': parallelism,
        'salt': base64UrlEncode(salt),
        'box': base64UrlEncode(secretBox.concatenation()),
      });
      return '$marker\n${base64UrlEncode(utf8.encode(envelope))}';
    } finally {
      secretKey.destroy();
    }
  }

  static Future<String> unlock({
    required String protectedCode,
    required String passphrase,
  }) async {
    if (passphrase.isEmpty) throw const JournalTransferProtectionRequired();
    try {
      final parts = protectedCode.trim().split(RegExp(r'\s+'));
      if (parts.length < 2 || parts.first != marker) {
        throw const FormatException('Not a protected Mystic transfer code.');
      }
      final envelopeBytes = base64Url.decode(
        base64Url.normalize(parts.skip(1).join()),
      );
      final envelope = jsonDecode(utf8.decode(envelopeBytes));
      if (envelope is! Map<String, dynamic> ||
          envelope['schemaVersion'] != schemaVersion ||
          envelope['kind'] != 'protected-private-journal-transfer' ||
          envelope['kdf'] != 'argon2id' ||
          envelope['memory'] != memoryBlocks ||
          envelope['iterations'] != iterations ||
          envelope['parallelism'] != parallelism ||
          envelope['salt'] is! String ||
          envelope['box'] is! String) {
        throw const FormatException('Unsupported protected transfer envelope.');
      }
      final salt = base64Url.decode(
        base64Url.normalize(envelope['salt'] as String),
      );
      if (salt.length != saltLength) {
        throw const FormatException('Invalid protected transfer salt.');
      }
      final secretKey = await _kdf.deriveKeyFromPassword(
        password: passphrase,
        nonce: salt,
      );
      try {
        final boxBytes = base64Url.decode(
          base64Url.normalize(envelope['box'] as String),
        );
        final secretBox = SecretBox.fromConcatenation(
          boxBytes,
          nonceLength: _cipher.nonceLength,
          macLength: _cipher.macAlgorithm.macLength,
        );
        final clearBytes = await _cipher.decrypt(
          secretBox,
          secretKey: secretKey,
          aad: utf8.encode(marker),
        );
        return utf8.decode(clearBytes);
      } finally {
        secretKey.destroy();
      }
    } on JournalTransferProtectionRequired {
      rethrow;
    } catch (_) {
      throw const JournalTransferUnlockFailed();
    }
  }

  static void _validatePassphrase(String passphrase) {
    if (passphrase.length < minimumPassphraseLength) {
      throw ArgumentError.value(
        passphrase.length,
        'passphrase',
        'Passphrase must contain at least $minimumPassphraseLength characters.',
      );
    }
  }
}
