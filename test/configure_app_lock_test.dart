import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/configure_app_lock.dart' as configurator;

void main() {
  test('Android manifest and activity configuration is idempotent', () {
    final root = Directory.systemTemp.createTempSync('mystic-app-lock-android-');
    addTearDown(() => root.deleteSync(recursive: true));
    final manifest = File('${root.path}/AndroidManifest.xml')
      ..writeAsStringSync('''<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:label="mystic_tarot">
    </application>
</manifest>
''');
    final activity = File('${root.path}/MainActivity.kt')
      ..writeAsStringSync('''package com.tunabozcali.mystictarot

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
''');

    configurator.configureAndroidManifest(manifest);
    configurator.configureAndroidManifest(manifest);
    configurator.configureAndroidActivity(activity);
    configurator.configureAndroidActivity(activity);

    final manifestText = manifest.readAsStringSync();
    expect(
      'android.permission.USE_BIOMETRIC'.allMatches(manifestText).length,
      1,
    );
    expect(
      'android.permission.USE_FINGERPRINT'.allMatches(manifestText).length,
      1,
    );
    expect(manifestText, contains('android:allowBackup="false"'));
    expect(
      activity.readAsStringSync(),
      contains('class MainActivity : FlutterFragmentActivity()'),
    );
  });

  test('iOS Face ID, Keychain, and project configuration is idempotent', () {
    final root = Directory.systemTemp.createTempSync('mystic-app-lock-ios-');
    addTearDown(() => root.deleteSync(recursive: true));
    final info = File('${root.path}/Info.plist')
      ..writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
</dict>
</plist>
''');
    final entitlements = File('${root.path}/Runner/Runner.entitlements');
    final project = File('${root.path}/project.pbxproj')
      ..writeAsStringSync('''buildSettings = {
    PRODUCT_BUNDLE_IDENTIFIER = com.tunabozcali.mystictarot;
};
''');

    configurator.configureIosInfoPlist(info);
    configurator.configureIosInfoPlist(info);
    configurator.configureIosEntitlements(entitlements);
    configurator.configureIosEntitlements(entitlements);
    configurator.configureIosProject(project);
    configurator.configureIosProject(project);

    expect(
      'NSFaceIDUsageDescription'.allMatches(info.readAsStringSync()).length,
      1,
    );
    expect(
      entitlements.readAsStringSync(),
      contains('keychain-access-groups'),
    );
    expect(
      'CODE_SIGN_ENTITLEMENTS'.allMatches(project.readAsStringSync()).length,
      1,
    );
  });
}
