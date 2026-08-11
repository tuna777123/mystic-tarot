import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/store_release_contract.dart';

void main() {
  test('production store workflow secret refs match release contract exactly', () {
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    final referencedSecrets = RegExp(
      r'secrets\.([A-Z0-9_]+)',
    )
        .allMatches(workflow)
        .map((match) => match.group(1)!)
        .toSet();

    final requiredSecrets = <String>{
      ...StoreReleaseContract.androidRequiredEnvironment,
      ...StoreReleaseContract.iosRequiredEnvironment,
    };

    expect(
      referencedSecrets,
      requiredSecrets,
      reason:
          'Production workflow secret references must stay exactly aligned '
          'with StoreReleaseContract required environment values.',
    );
  });

  test('signed store jobs remain behind the protected production environment', () {
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    expect(
      RegExp(r'^\s*environment:\s*production-stores\s*$', multiLine: true)
          .allMatches(workflow)
          .length,
      2,
      reason:
          'Exactly the Android and iOS signed release jobs must use the '
          'production-stores environment.',
    );
  });

  test('production workflow keeps fail-closed preflight and locked dependencies', () {
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();

    expect(
      workflow,
      contains('dart run tool/store_release_preflight.dart --platform=android'),
    );
    expect(
      workflow,
      contains('dart run tool/store_release_preflight.dart --platform=ios'),
    );
    expect(
      RegExp(r'run:\s*flutter pub get --enforce-lockfile')
          .allMatches(workflow)
          .length,
      3,
      reason:
          'Source validation plus Android and iOS release jobs must all use '
          'the committed Flutter lockfile.',
    );
    expect(
      RegExp(r'--dart-define=MYSTIC_USE_TEST_ADS=false')
          .allMatches(workflow)
          .length,
      2,
      reason:
          'Both signed native release builds must explicitly disable test ads.',
    );
  });
}
