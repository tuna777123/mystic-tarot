import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('share_plus stays on a Built-in Kotlin compatible release', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('share_plus: ^13.3.0'));
    expect(pubspec, isNot(contains('share_plus: ^12.')));
  });

  test('Android release logs enforce the reviewed KGP blocker allowlist', () {
    final workflow = File(
      '.github/workflows/flutter-ci.yml',
    ).readAsStringSync();

    expect(workflow, contains('android-build.log'));
    expect(workflow, contains('verify_kotlin_plugin_warnings.dart'));
    expect(workflow, contains('--allow flutter_timezone,purchases_flutter'));
    expect(
      workflow,
      isNot(contains('--allow flutter_timezone,purchases_flutter,share_plus')),
    );
    expect(workflow, contains('kotlin-plugin-audit.md'));
  });

  test('Kotlin compatibility policy remains in the release tree', () {
    expect(File('tool/verify_kotlin_plugin_warnings.dart').existsSync(), isTrue);
    expect(File('tool/src/kotlin_plugin_audit.dart').existsSync(), isTrue);
  });
}
