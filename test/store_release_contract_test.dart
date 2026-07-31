import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/store_release_contract.dart';

void main() {
  group('RevenueCat public SDK key validation', () {
    test('accepts platform-specific public application keys', () {
      expect(
        validateRevenueCatPublicKey(
          'goog_1234567890abcdef',
          platform: StoreReleasePlatform.android,
        ),
        isEmpty,
      );
      expect(
        validateRevenueCatPublicKey(
          'appl_1234567890abcdef',
          platform: StoreReleasePlatform.ios,
        ),
        isEmpty,
      );
    });

    test('rejects secret-looking and cross-platform keys', () {
      expect(
        validateRevenueCatPublicKey(
          'sk_1234567890abcdef',
          platform: StoreReleasePlatform.android,
        ),
        isNotEmpty,
      );
      expect(
        validateRevenueCatPublicKey(
          'appl_1234567890abcdef',
          platform: StoreReleasePlatform.android,
        ),
        isNotEmpty,
      );
    });

    test('rejects whitespace and unexpectedly short values', () {
      expect(
        validateRevenueCatPublicKey(
          'goog_ short',
          platform: StoreReleasePlatform.android,
        ),
        hasLength(2),
      );
    });
  });

  test('finds only missing protected environment values', () {
    final missing = missingEnvironmentValues(
      const {'ONE': 'present', 'TWO': '  '},
      const ['ONE', 'TWO', 'THREE'],
    );
    expect(missing, ['TWO', 'THREE']);
  });

  test('validates base64 file secrets without exposing them', () {
    final encoded = base64Encode(const [1, 2, 3, 4]);
    expect(
      validateBase64Secret(encoded, label: 'certificate'),
      isEmpty,
    );
    expect(
      validateBase64Secret('not-base64%', label: 'certificate'),
      isNotEmpty,
    );
  });

  test('requires permanent store identity and entitlement', () {
    expect(
      validateReleaseIdentity(
        bundleIdentifier: StoreReleaseContract.bundleIdentifier,
        entitlementId: StoreReleaseContract.entitlementId,
      ),
      isEmpty,
    );
    expect(
      validateReleaseIdentity(
        bundleIdentifier: 'com.example.other',
        entitlementId: 'premium',
      ),
      hasLength(2),
    );
  });

  test('validates Apple Team ID format', () {
    expect(validateTeamIdentifier('A1B2C3D4E5'), isEmpty);
    expect(validateTeamIdentifier('short'), isNotEmpty);
    expect(validateTeamIdentifier('a1b2c3d4e5'), isNotEmpty);
  });

  test('reads strict pubspec build versions', () {
    expect(
      readPubspecVersion('name: mystic_tarot\nversion: 1.8.0+11\n'),
      '1.8.0+11',
    );
    expect(
      () => readPubspecVersion('version: 1.8.0\n'),
      throwsFormatException,
    );
  });

  test('creates stable release artifact names', () {
    expect(
      releaseArtifactName(
        platform: StoreReleasePlatform.android,
        version: '1.8.0+11',
        channel: 'Closed Testing',
      ),
      'mystic-tarot-1.8.0-build11-android-closed-testing',
    );
  });

  test('rejects unsupported platform values', () {
    expect(
      () => parseStoreReleasePlatform('web'),
      throwsFormatException,
    );
  });
}
