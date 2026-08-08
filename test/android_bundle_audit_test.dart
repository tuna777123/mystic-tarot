import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/android_bundle_audit.dart';

void main() {
  test('parses release identity and manifest permissions', () {
    final manifest = ManifestSnapshot.parse('''
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.tunabozcali.mystictarot"
    android:versionCode="30"
    android:versionName="1.22.1">
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission-sdk-23 android:name="android.permission.USE_BIOMETRIC" />
</manifest>
''');

    expect(manifest.packageName, 'com.tunabozcali.mystictarot');
    expect(manifest.versionName, '1.22.1');
    expect(manifest.versionCode, 30);
    expect(manifest.permissions, <String>{
      'android.permission.INTERNET',
      'android.permission.USE_BIOMETRIC',
    });
  });

  test('reads strict Flutter version identity', () {
    final version = PubspecVersion.parse('''
name: mystic_tarot
version: 1.22.1+30
''');

    expect(version.name, '1.22.1');
    expect(version.code, 30);
  });

  test('extracts all native ABI directories from bundle entries', () {
    final abis = parseAndroidAbis(<String>[
      'base/lib/arm64-v8a/libapp.so',
      'base/lib/armeabi-v7a/libapp.so',
      'base/lib/x86_64/libapp.so',
      'base/dex/classes.dex',
    ]);

    expect(abis, requiredAndroidAbis);
  });

  test(
    'allows reviewed advertising identifiers but blocks sensitive access',
    () {
      final permissions = <String>{
        'android.permission.INTERNET',
        'android.permission.POST_NOTIFICATIONS',
        'android.permission.ACCESS_FINE_LOCATION',
        'com.google.android.gms.permission.AD_ID',
        'android.permission.ACCESS_ADSERVICES_AD_ID',
      };

      expect(findForbiddenPermissions(permissions), <String>{
        'android.permission.ACCESS_FINE_LOCATION',
      });
      expect(findReviewedAdvertisingPermissions(permissions), <String>{
        'com.google.android.gms.permission.AD_ID',
        'android.permission.ACCESS_ADSERVICES_AD_ID',
      });
    },
  );

  test('allows Google Mobile Ads while blocking unknown attribution SDKs', () {
    final reviewedBytes = Uint8List.fromList(
      ascii.encode(
        'Lcom/google/android/gms/ads/AdView;Lcom/google/android/ump/ConsentInformation;',
      ),
    );
    final trackedBytes = Uint8List.fromList(
      ascii.encode(
        'Lcom/tunabozcali/mystictarot/App;Lcom/appsflyer/AppsFlyerLib;',
      ),
    );

    expect(findForbiddenDexMarkers(reviewedBytes), isEmpty);
    expect(findForbiddenDexMarkers(trackedBytes), {'Lcom/appsflyer/'});
  });

  test('accepts a clean strict jarsigner result', () {
    expect(
      () => validateStrictJarsignerResult(exitCode: 0, output: 'jar verified.'),
      returnsNormally,
    );
  });

  test('accepts the reviewed self-signed trust warning', () {
    expect(
      () => validateStrictJarsignerResult(
        exitCode: 4,
        output: '''
jar verified, with signer errors.
This jar contains entries whose signer certificate is self-signed.
''',
      ),
      returnsNormally,
    );
  });

  test('accepts the equivalent invalid-chain trust warning', () {
    expect(
      () => validateStrictJarsignerResult(
        exitCode: 4,
        output: '''
jar verified, with signer errors.
This jar contains entries whose certificate chain is invalid. Reason: PKIX path building failed: unable to find valid certification path to requested target.
''',
      ),
      returnsNormally,
    );
  });

  test(
    'resource names containing disabled do not mimic algorithm failures',
    () {
      expect(
        () => validateStrictJarsignerResult(
          exitCode: 4,
          output: '''
jar verified, with signer errors.
This jar contains entries whose certificate chain is invalid.
This jar contains entries whose signer certificate is self-signed.
- Entry base/res/drawable/abc_list_selector_disabled_holo_light.png is signed.
''',
        ),
        returnsNormally,
      );
    },
  );

  test('rejects unsigned entries even when another signature is valid', () {
    expect(
      () => validateStrictJarsignerResult(
        exitCode: 20,
        output: '''
jar verified, with signer errors.
This jar contains entries whose signer certificate is self-signed.
This jar contains unsigned entries which have not been integrity-checked.
''',
      ),
      throwsA(isA<AuditFailure>()),
    );
  });

  test('rejects expired or disabled trust-chain certificates', () {
    expect(
      () => validateStrictJarsignerResult(
        exitCode: 4,
        output: '''
jar verified, with signer errors.
This jar contains entries whose certificate chain is invalid and has expired.
''',
      ),
      throwsA(isA<AuditFailure>()),
    );
    expect(
      () => validateStrictJarsignerResult(
        exitCode: 4,
        output: '''
jar verified, with signer errors.
This jar contains entries whose signer certificate is self-signed.
An algorithm used is considered a security risk and is disabled.
''',
      ),
      throwsA(isA<AuditFailure>()),
    );
  });

  test('rejects an unclassified strict code-four failure', () {
    expect(
      () => validateStrictJarsignerResult(
        exitCode: 4,
        output: 'jar verified, with signer errors.',
      ),
      throwsA(isA<AuditFailure>()),
    );
  });

  test('formats release size in binary megabytes', () {
    expect(formatByteCount(61 * 1024 * 1024), '61.00 MiB');
  });
}
