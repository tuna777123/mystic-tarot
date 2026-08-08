import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/store_release_contract.dart';

void main() {
  test('accepts production-shaped AdMob IDs', () {
    expect(
      validateAdMobAppId(
        'ca-app-pub-1234567890123456~1234567890',
        label: 'Android AdMob application ID',
      ),
      isEmpty,
    );
    expect(
      validateAdMobAdUnitId(
        'ca-app-pub-1234567890123456/1234567890',
        label: 'Android interstitial ad unit ID',
      ),
      isEmpty,
    );
  });

  test('rejects Google demo and malformed AdMob IDs for production', () {
    expect(
      validateAdMobAppId(
        'ca-app-pub-3940256099942544~3347511713',
        label: 'Android AdMob application ID',
      ),
      isNotEmpty,
    );
    expect(
      validateAdMobAdUnitId(
        'ca-app-pub-3940256099942544/1033173712',
        label: 'Android interstitial ad unit ID',
      ),
      isNotEmpty,
    );
    expect(
      validateAdMobAdUnitId(
        'not-an-ad-unit',
        label: 'Android interstitial ad unit ID',
      ),
      isNotEmpty,
    );
  });

  test('finds only missing protected environment values', () {
    final missing = missingEnvironmentValues(
      const {'ONE': 'present', 'TWO': '  '},
      const ['ONE', 'TWO', 'THREE'],
    );
    expect(missing, ['TWO', 'THREE']);
  });

  test('requires AdMob and certificate values for both store platforms', () {
    expect(
      StoreReleaseContract.androidRequiredEnvironment,
      containsAll(<String>[
        'ADMOB_ANDROID_APP_ID',
        'ADMOB_ANDROID_APP_OPEN_ID',
        'ADMOB_ANDROID_INTERSTITIAL_ID',
        'ANDROID_UPLOAD_CERT_SHA256',
      ]),
    );
    expect(
      StoreReleaseContract.iosRequiredEnvironment,
      containsAll(<String>[
        'ADMOB_IOS_APP_ID',
        'ADMOB_IOS_APP_OPEN_ID',
        'ADMOB_IOS_INTERSTITIAL_ID',
        'IOS_DISTRIBUTION_CERT_SHA256',
      ]),
    );
    expect(StoreReleaseContract.monetizationModel, 'advertising-only');
  });

  test('validates base64 file secrets without exposing them', () {
    final encoded = base64Encode(const [1, 2, 3, 4]);
    expect(validateBase64Secret(encoded, label: 'certificate'), isEmpty);
    expect(
      validateBase64Secret('not-base64%', label: 'certificate'),
      isNotEmpty,
    );
  });

  test('normalizes Play Console style SHA-256 fingerprints', () {
    const compact =
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    final colonSeparated = RegExp(
      '.{2}',
    ).allMatches(compact).map((match) => match.group(0)).join(':');

    expect(normalizeSha256Fingerprint(colonSeparated), compact.toUpperCase());
    expect(
      validateSha256Fingerprint(colonSeparated, label: 'upload certificate'),
      isEmpty,
    );
  });

  test('rejects malformed or truncated certificate fingerprints', () {
    expect(
      validateSha256Fingerprint('ABC123', label: 'certificate'),
      isNotEmpty,
    );
    final nonHexFingerprint = '${List.filled(63, 'A').join()}Z';
    expect(
      validateSha256Fingerprint(nonHexFingerprint, label: 'certificate'),
      isNotEmpty,
    );
  });

  test('requires permanent store identity', () {
    expect(
      validateReleaseIdentity(
        bundleIdentifier: StoreReleaseContract.bundleIdentifier,
      ),
      isEmpty,
    );
    expect(
      validateReleaseIdentity(bundleIdentifier: 'com.example.other'),
      hasLength(1),
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
    expect(() => readPubspecVersion('version: 1.8.0\n'), throwsFormatException);
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
    expect(() => parseStoreReleasePlatform('web'), throwsFormatException);
  });
}
