import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.20 private app lock release contract stays complete', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();
    final lock = File('lib/src/app_lock.dart').readAsStringSync();
    final gate = File('lib/src/app_lock_gate.dart').readAsStringSync();
    final configurator = File('tool/configure_app_lock.dart').readAsStringSync();
    final ci = File('.github/workflows/flutter-ci.yml').readAsStringSync();
    final qa =
        File('.github/workflows/release-candidate.yml').readAsStringSync();
    final notes = File('RELEASE_NOTES_1.20.md').readAsStringSync();

    expect(pubspec, contains('version: 1.20.0+26'));
    expect(pubspec, contains('flutter_secure_storage: ^10.3.1'));
    expect(pubspec, contains('local_auth: ^3.0.2'));
    expect(main, contains("import 'src/app_lock_gate.dart';"));
    expect(main, contains('AppLockGate(child: MysticApp())'));
    expect(lock, contains('Argon2id('));
    expect(lock, contains('AesGcm.with256bits()'));
    expect(lock, contains("RegExp(r'^\\d{6}\$')"));
    expect(lock, contains('AppLockTemporarilyUnavailable'));
    expect(lock, contains('const Duration(minutes: 30)'));
    expect(lock, contains('FlutterSecureStorage'));
    expect(lock, contains('LocalAuthentication'));
    expect(gate, contains('backgroundGrace = const Duration(seconds: 5)'));
    expect(gate, contains('There is no cloud reset or hidden recovery key.'));
    expect(gate, isNot(contains('MysticLanguage')));
    expect(configurator, contains('android.permission.USE_BIOMETRIC'));
    expect(configurator, contains('FlutterFragmentActivity'));
    expect(configurator, contains('android:allowBackup="false"'));
    expect(configurator, contains('NSFaceIDUsageDescription'));
    expect(configurator, contains('keychain-access-groups'));
    expect(ci, contains('dart run tool/configure_app_lock.dart'));
    expect(qa, contains('dart run tool/configure_app_lock.dart'));
    expect(notes, startsWith('# Mystic Tarot 1.20.0'));
    expect(notes, contains('raw PIN is never stored'));
    expect(notes, contains('no cloud reset'));
    expect(lock, isNot(contains('package:http')));
    expect(lock, isNot(contains('shared_preferences')));
    expect(File('.github/workflows/v120-integrate.yml').existsSync(), isFalse);
    expect(File('tool/v120_integrate.py').existsSync(), isFalse);
  });
}
