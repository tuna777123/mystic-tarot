import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_lock.dart';
import 'package:mystic_tarot/src/app_lock_gate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('private lock follows the language selected inside the app',
      (tester) async {
    final service = _testService(_MemoryAppLockStore());
    await service.enableWithPin('135790');

    await tester.pumpWidget(
      AppLockGate(
        service: service,
        authenticator: const _FakeAuthenticator(),
        languageCodeLoader: () async => 'tr',
        child: const MaterialApp(home: Scaffold(body: Text('PRIVATE APP'))),
      ),
    );
    await _pumpUntilFound(tester, find.text('Özel günlük kilitli'));

    expect(find.text('Private journal locked'), findsNothing);
    expect(find.text('Özel günlük kilitli'), findsOneWidget);
  });

  testWidgets('resume after the grace period relocks in the latest app language',
      (tester) async {
    final service = _testService(_MemoryAppLockStore());
    await service.enableWithPin('246810');
    var languageCode = 'en';

    await tester.pumpWidget(
      AppLockGate(
        service: service,
        authenticator: const _FakeAuthenticator(),
        languageCodeLoader: () async => languageCode,
        backgroundGrace: Duration.zero,
        child: const MaterialApp(home: Scaffold(body: Text('PRIVATE APP'))),
      ),
    );
    await _pumpUntilFound(tester, find.text('Private journal locked'));

    await tester.enterText(find.byType(TextField), '246810');
    await tester.tap(find.text('Unlock'));
    await _pumpUntilFound(tester, find.text('PRIVATE APP'));

    languageCode = 'tr';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _pumpUntilFound(tester, find.text('Özel günlük kilitli'));

    expect(find.text('PRIVATE APP'), findsNothing);
    expect(find.text('Özel günlük kilitli'), findsOneWidget);
  });

  testWidgets('a brief background transition stays unlocked inside grace',
      (tester) async {
    final service = _testService(_MemoryAppLockStore());
    await service.enableWithPin('112233');

    await tester.pumpWidget(
      AppLockGate(
        service: service,
        authenticator: const _FakeAuthenticator(),
        languageCodeLoader: () async => 'en',
        backgroundGrace: const Duration(minutes: 1),
        child: const MaterialApp(home: Scaffold(body: Text('PRIVATE APP'))),
      ),
    );
    await _pumpUntilFound(tester, find.text('Private journal locked'));

    await tester.enterText(find.byType(TextField), '112233');
    await tester.tap(find.text('Unlock'));
    await _pumpUntilFound(tester, find.text('PRIVATE APP'));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(milliseconds: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('PRIVATE APP'), findsOneWidget);
    expect(find.text('Private journal locked'), findsNothing);
  });
}

AppLockService _testService(_MemoryAppLockStore store) => AppLockService(
      store: store,
      keyDeriver: _fastKeyDeriver,
    );

Future<SecretKey> _fastKeyDeriver(String pin, List<int> salt) async {
  final pinBytes = pin.codeUnits;
  return SecretKeyData(List<int>.generate(
    32,
    (index) =>
        (pinBytes[index % pinBytes.length] + salt[index % salt.length] + index) &
        0xff,
  ));
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 100 && finder.evaluate().isEmpty; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsOneWidget);
}

class _MemoryAppLockStore implements AppLockStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

class _FakeAuthenticator implements AppLockAuthenticator {
  const _FakeAuthenticator();

  @override
  Future<bool> authenticate(String reason) async => false;

  @override
  Future<bool> isAvailable() async => false;
}
