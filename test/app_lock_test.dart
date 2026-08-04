import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_lock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('enables and verifies a PIN without storing the raw PIN', () async {
    final store = MemoryAppLockStore();
    final service = AppLockService(store: store);

    await service.enableWithPin('246810');

    final state = await service.loadState();
    expect(state.enabled, isTrue);
    expect(await service.verifyPin('246810'), isTrue);
    expect(store.values.values, isNot(contains('246810')));
    expect(store.values.toString(), isNot(contains('246810')));
  });

  test('wrong PIN is rejected and persistent delay begins at attempt five',
      () async {
    final store = MemoryAppLockStore();
    final service = AppLockService(store: store);
    final now = DateTime.utc(2026, 8, 4, 12);

    await service.enableWithPin('135790');
    store.values['mystic.app-lock.failed-attempts.v1'] = '4';

    expect(await service.verifyPin('000000', now: now), isFalse);
    final state = await service.loadState();
    expect(state.failedAttempts, 5);
    expect(state.remainingLockout(now), const Duration(seconds: 30));

    expect(
      () => service.verifyPin(
        '135790',
        now: now.add(const Duration(seconds: 1)),
      ),
      throwsA(isA<AppLockTemporarilyUnavailable>()),
    );
    expect(
      await service.verifyPin(
        '135790',
        now: now.add(const Duration(seconds: 31)),
      ),
      isTrue,
    );
    expect((await service.loadState()).failedAttempts, 0);
  });

  test('biometrics require an enabled PIN lock', () async {
    final service = AppLockService(store: MemoryAppLockStore());

    expect(
      () => service.setBiometricsEnabled(true),
      throwsA(isA<StateError>()),
    );

    await service.enableWithPin('112233');
    await service.setBiometricsEnabled(true);
    expect((await service.loadState()).biometricsEnabled, isTrue);

    await service.setBiometricsEnabled(false);
    expect((await service.loadState()).biometricsEnabled, isFalse);
  });

  test('trusted unlock clears failed attempts and disable removes lock data',
      () async {
    final store = MemoryAppLockStore();
    final service = AppLockService(store: store);

    await service.enableWithPin('445566');
    store.values['mystic.app-lock.failed-attempts.v1'] = '9';
    store.values['mystic.app-lock.locked-until.v1'] =
        DateTime.utc(2026, 8, 4, 13).millisecondsSinceEpoch.toString();

    await service.markTrustedUnlock();
    expect((await service.loadState()).failedAttempts, 0);

    await service.disable();
    final state = await service.loadState();
    expect(state.enabled, isFalse);
    expect(state.biometricsEnabled, isFalse);
    expect(state.promptDismissed, isTrue);
    expect(
      store.values.keys.where((key) => key.contains('pin-verifier')),
      isEmpty,
    );
  });

  test('PIN must contain exactly six digits', () async {
    final service = AppLockService(store: MemoryAppLockStore());

    expect(
      () => service.enableWithPin('12345'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => service.enableWithPin('12345x'),
      throwsA(isA<ArgumentError>()),
    );
  });
}

class MemoryAppLockStore implements AppLockStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}
