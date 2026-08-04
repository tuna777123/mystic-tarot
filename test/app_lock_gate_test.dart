import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_lock.dart';
import 'package:mystic_tarot/src/app_lock_gate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offers setup and unlocks the child after creating a PIN',
      (tester) async {
    final service = testAppLockService(MemoryAppLockStore());

    await tester.pumpWidget(
      AppLockGate(
        service: service,
        authenticator: const FakeAuthenticator(available: false),
        promptDelay: Duration.zero,
        child: const MaterialApp(home: Scaffold(body: Text('PRIVATE APP'))),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Protect your private journal'), findsOneWidget);
    await tester.tap(find.text('Enable lock'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), '246810');
    await tester.enterText(fields.at(1), '246810');
    await tester.tap(find.text('Protect journal'));
    await _pumpUntilFound(tester, find.text('PRIVATE APP'));

    expect(find.text('PRIVATE APP'), findsOneWidget);
    expect((await service.loadState()).enabled, isTrue);
  });

  testWidgets('enabled lock hides the app until the correct PIN is entered',
      (tester) async {
    final service = testAppLockService(MemoryAppLockStore());
    await service.enableWithPin('135790');

    await tester.pumpWidget(
      AppLockGate(
        service: service,
        authenticator: const FakeAuthenticator(available: false),
        child: const MaterialApp(home: Scaffold(body: Text('PRIVATE APP'))),
      ),
    );
    await _pumpUntilFound(tester, find.text('Private journal locked'));

    expect(find.text('PRIVATE APP'), findsNothing);
    await tester.enterText(find.byType(TextField), '000000');
    await tester.tap(find.text('Unlock'));
    await _pumpUntilFound(tester, find.text('Incorrect PIN.'));
    expect(find.text('PRIVATE APP'), findsNothing);

    await tester.enterText(find.byType(TextField), '135790');
    await tester.tap(find.text('Unlock'));
    await _pumpUntilFound(tester, find.text('PRIVATE APP'));
    expect(find.text('PRIVATE APP'), findsOneWidget);
  });

  testWidgets('successful biometrics unlocks without exposing the PIN',
      (tester) async {
    final service = testAppLockService(MemoryAppLockStore());
    await service.enableWithPin('112233');
    await service.setBiometricsEnabled(true);

    await tester.pumpWidget(
      AppLockGate(
        service: service,
        authenticator: const FakeAuthenticator(
          available: true,
          authenticated: true,
        ),
        child: const MaterialApp(home: Scaffold(body: Text('PRIVATE APP'))),
      ),
    );
    await _pumpUntilFound(tester, find.text('PRIVATE APP'));

    expect(find.text('PRIVATE APP'), findsOneWidget);
    expect((await service.loadState()).failedAttempts, 0);
  });
}

AppLockService testAppLockService(MemoryAppLockStore store) => AppLockService(
      store: store,
      keyDeriver: fastKeyDeriver,
    );

Future<SecretKey> fastKeyDeriver(String pin, List<int> salt) async {
  final pinBytes = pin.codeUnits;
  return SecretKeyData(List<int>.generate(
    32,
    (index) =>
        (pinBytes[index % pinBytes.length] + salt[index % salt.length] + index) &
        0xff,
  ));
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder,
) async {
  for (var attempt = 0; attempt < 80 && finder.evaluate().isEmpty; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets);
}

class MemoryAppLockStore implements AppLockStore {
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

class FakeAuthenticator implements AppLockAuthenticator {
  const FakeAuthenticator({
    required this.available,
    this.authenticated = false,
  });

  final bool available;
  final bool authenticated;

  @override
  Future<bool> authenticate(String reason) async => authenticated;

  @override
  Future<bool> isAvailable() async => available;
}
