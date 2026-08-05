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

  test('blocks sensitive permissions while allowing core app access', () {
    final forbidden = findForbiddenPermissions(<String>{
      'android.permission.INTERNET',
      'android.permission.POST_NOTIFICATIONS',
      'android.permission.ACCESS_FINE_LOCATION',
      'com.google.android.gms.permission.AD_ID',
    });

    expect(forbidden, <String>{
      'android.permission.ACCESS_FINE_LOCATION',
      'com.google.android.gms.permission.AD_ID',
    });
  });

  test('detects packaged advertising and analytics class descriptors', () {
    final cleanBytes = Uint8List.fromList(
      ascii.encode(
        'Lcom/revenuecat/purchases/Purchases;Lcom/tunabozcali/mystictarot/App;',
      ),
    );
    final trackedBytes = Uint8List.fromList(
      ascii.encode(
        'Lcom/tunabozcali/mystictarot/App;Lcom/appsflyer/AppsFlyerLib;',
      ),
    );

    expect(findForbiddenDexMarkers(cleanBytes), isEmpty);
    expect(findForbiddenDexMarkers(trackedBytes), {'Lcom/appsflyer/'});
  });

  test('accepts a clean strict jarsigner result', () {
    expect(
      () => validateStrictJarsignerResult(exitCode: 0, output: 'jar verified.'),
      returnsNormally,
    );
  });

  test('accepts only the self-signed upload-certificate warning', () {
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

  test('rejects expired or disabled self-signed certificates', () {
    expect(
      () => validateStrictJarsignerResult(
        exitCode: 4,
        output: '''
jar verified, with signer errors.
This jar contains entries whose signer certificate is self-signed and has expired.
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

  test('formats release size in binary megabytes', () {
    expect(formatByteCount(61 * 1024 * 1024), '61.00 MiB');
  });
}
