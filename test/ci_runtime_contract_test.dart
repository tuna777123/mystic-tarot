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

  test('Android release enforces a narrow legacy Kotlin warning budget', () {
    final flutterCi = File(
      '.github/workflows/flutter-ci.yml',
    ).readAsStringSync();

    expect(flutterCi, contains('flutter-appbundle.log'));
    expect(
      flutterCi,
      contains('dart run tool/check_kotlin_plugin_warnings.dart'),
    );
    expect(flutterCi, contains('--allow flutter_timezone'));
    expect(flutterCi, contains('--allow purchases_flutter'));
    expect(flutterCi, isNot(contains('--allow share_plus')));

    final warningCheck = flutterCi.indexOf(
      'dart run tool/check_kotlin_plugin_warnings.dart',
    );
    final bundleAudit = flutterCi.indexOf('Install pinned bundletool');
    expect(warningCheck, greaterThan(-1));
    expect(bundleAudit, greaterThan(warningCheck));
  });
}
