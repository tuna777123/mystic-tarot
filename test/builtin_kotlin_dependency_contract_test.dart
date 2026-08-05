import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  test('share_plus stays on the Built-in Kotlin compatible line', () {
    expect(pubspec, contains('share_plus: ^13.3.0'));
  });

  test('legacy jni override does not return', () {
    expect(pubspec, isNot(contains('dependency_overrides:')));
    expect(pubspec, isNot(contains('jni: 1.0.0')));
  });
}
