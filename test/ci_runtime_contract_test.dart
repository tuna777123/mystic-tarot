import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release workflows use current Node 24 compatible actions', () {
    final flutterCi = File(
      '.github/workflows/flutter-ci.yml',
    ).readAsStringSync();
    final iosCi = File('.github/workflows/ios-ci.yml').readAsStringSync();
    final pages = File('.github/workflows/pages.yml').readAsStringSync();
    final storeRelease = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    expect(flutterCi, contains('actions/checkout@v6'));
    expect(flutterCi, contains('actions/setup-java@v5'));
    expect(flutterCi, contains('actions/upload-artifact@v7'));
    expect(iosCi, contains('actions/checkout@v6'));
    expect(pages, contains('actions/checkout@v6'));
    expect(storeRelease, contains('actions/checkout@v6'));
    expect(storeRelease, contains('actions/setup-java@v5'));
    expect(storeRelease, contains('actions/upload-artifact@v7'));

    for (final workflow in <String>[flutterCi, iosCi, pages, storeRelease]) {
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

  test('legacy jni dependency override stays removed', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, isNot(contains('dependency_overrides:')));
    expect(pubspec, isNot(contains('jni: 1.0.0')));
  });
}
