import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release workflows use current Node 24 compatible actions', () {
    final flutterCi = File(
      '.github/workflows/flutter-ci.yml',
    ).readAsStringSync();
    final iosCi = File('.github/workflows/ios-ci.yml').readAsStringSync();
    final pages = File('.github/workflows/pages.yml').readAsStringSync();

    expect(flutterCi, contains('actions/checkout@v6'));
    expect(flutterCi, contains('actions/setup-java@v5'));
    expect(flutterCi, contains('actions/upload-artifact@v7'));
    expect(iosCi, contains('actions/checkout@v6'));
    expect(pages, contains('actions/checkout@v6'));

    for (final workflow in <String>[flutterCi, iosCi, pages]) {
      expect(workflow, isNot(contains('actions/checkout@v4')));
      expect(workflow, isNot(contains('actions/setup-java@v4')));
      expect(workflow, isNot(contains('actions/upload-artifact@v4')));
    }
  });

  test('web releases bundle the Cupertino icon asset package', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('cupertino_icons: ^1.0.9'));
    expect(pubspec, contains('uses-material-design: true'));
  });

  test('sharing uses a built-in Kotlin compatible plugin release', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('share_plus: ^13.3.0'));
    expect(pubspec, isNot(contains('share_plus: ^12.')));
  });

  test('Android releases enforce the partial Built-in Kotlin migration', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final workflow = File(
      '.github/workflows/flutter-ci.yml',
    ).readAsStringSync();
    final policy = File(
      'tool/src/kotlin_plugin_warnings.dart',
    ).readAsStringSync();

    expect(pubspec, contains('share_plus: ^13.3.0'));
    expect(workflow, contains('build/reports/android-release.log'));
    expect(workflow, contains('verify_kotlin_plugin_warnings.dart'));
    expect(workflow, contains('mystic-tarot-built-in-kotlin-audit'));
    expect(policy, contains("'flutter_timezone'"));
    expect(policy, contains("'purchases_flutter'"));
    expect(policy, isNot(contains("'share_plus',")));

    final buildIndex = workflow.indexOf('Build Android release bundle');
    final kotlinAuditIndex = workflow.indexOf(
      'Audit Built-in Kotlin compatibility',
    );
    final uploadIndex = workflow.indexOf('Upload Android bundle');
    expect(buildIndex, greaterThanOrEqualTo(0));
    expect(kotlinAuditIndex, greaterThan(buildIndex));
    expect(uploadIndex, greaterThan(kotlinAuditIndex));
  });
}
