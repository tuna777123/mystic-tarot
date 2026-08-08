import 'dart:io';

import 'configure_app_lock.dart' as app_lock_config;
import 'configure_ritual_notifications.dart' as ritual_config;
import 'materialize_ad_only_ui.dart' as ad_only_ui;

const permanentIdentifier = 'com.tunabozcali.mystictarot';
const androidAdMobTestAppId = 'ca-app-pub-3940256099942544~3347511713';
const iosAdMobTestAppId = 'ca-app-pub-3940256099942544~1458002511';

const generatedIdentifiers = <String>[
  'com.tunabozcali.mystic_tarot',
  'com.tunabozcali.mysticTarot',
  'com.example.mystic_tarot',
];

void main() {
  ad_only_ui.materializeAdOnlyUi();

  final roots = <Directory>[
    Directory('android'),
    Directory('ios'),
  ].where((directory) => directory.existsSync());

  var changedFiles = 0;
  for (final root in roots) {
    for (final entity in root.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !_isTextBuildFile(entity.path)) continue;
      final original = entity.readAsStringSync();
      var updated = original;
      for (final generated in generatedIdentifiers) {
        updated = updated.replaceAll(generated, permanentIdentifier);
      }
      if (updated != original) {
        entity.writeAsStringSync(updated);
        changedFiles += 1;
      }
    }
  }

  final errors = <String>[];
  final androidBuild = File('android/app/build.gradle.kts');
  if (androidBuild.existsSync()) {
    final source = androidBuild.readAsStringSync();
    if (!source.contains('namespace = "$permanentIdentifier"')) {
      errors.add('Android namespace was not set to $permanentIdentifier.');
    }
    if (!source.contains('applicationId = "$permanentIdentifier"')) {
      errors.add('Android applicationId was not set to $permanentIdentifier.');
    }
  }

  final iosProject = File('ios/Runner.xcodeproj/project.pbxproj');
  if (iosProject.existsSync() &&
      !iosProject.readAsStringSync().contains(
        'PRODUCT_BUNDLE_IDENTIFIER = $permanentIdentifier;',
      )) {
    errors.add('iOS bundle identifier was not set to $permanentIdentifier.');
  }

  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
    return;
  }

  final hasAndroid = Directory('android').existsSync();
  final hasIos = Directory('ios').existsSync();
  if (hasAndroid) {
    ritual_config.configureRitualNotifications();
    _configureAndroidAdMob(
      _adMobAppId('ADMOB_ANDROID_APP_ID', androidAdMobTestAppId),
    );
  }
  if (hasIos) {
    _configureIosAdMob(_adMobAppId('ADMOB_IOS_APP_ID', iosAdMobTestAppId));
  }
  if (hasAndroid || hasIos) {
    app_lock_config.configureAppLock(
      requireAndroid: hasAndroid,
      requireIos: hasIos,
    );
  }
  if (exitCode != 0) return;

  stdout.writeln(
    'Permanent store identifiers and AdMob app IDs verified; '
    '$changedFiles file(s) updated.',
  );
}

String _adMobAppId(String environmentName, String fallback) {
  final value = Platform.environment[environmentName]?.trim();
  if (value == null || value.isEmpty) return fallback;
  if (!RegExp(r'^ca-app-pub-\d{16}~\d{10}$').hasMatch(value)) {
    stderr.writeln('$environmentName is not a valid AdMob application ID.');
    exitCode = 1;
    return fallback;
  }
  return value;
}

void _configureAndroidAdMob(String appId) {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (!manifest.existsSync()) {
    stderr.writeln('AndroidManifest.xml is missing.');
    exitCode = 1;
    return;
  }
  final original = manifest.readAsStringSync();
  final pattern = RegExp(
    r'<meta-data\s+android:name="com\.google\.android\.gms\.ads\.APPLICATION_ID"\s+android:value="[^"]+"\s*/>',
    multiLine: true,
  );
  final metadata = '''<meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="$appId" />''';
  final updated = pattern.hasMatch(original)
      ? original.replaceFirst(pattern, metadata)
      : original.replaceFirst(
          '</application>',
          '        $metadata\n    </application>',
        );
  manifest.writeAsStringSync(updated);
  if (!updated.contains('android:value="$appId"')) {
    stderr.writeln('Android AdMob application ID was not configured.');
    exitCode = 1;
  }
}

void _configureIosAdMob(String appId) {
  final plist = File('ios/Runner/Info.plist');
  if (!plist.existsSync()) {
    stderr.writeln('iOS Info.plist is missing.');
    exitCode = 1;
    return;
  }
  final original = plist.readAsStringSync();
  final pattern = RegExp(
    r'<key>GADApplicationIdentifier</key>\s*<string>[^<]+</string>',
    multiLine: true,
  );
  final entry = '''<key>GADApplicationIdentifier</key>
	<string>$appId</string>''';
  final updated = pattern.hasMatch(original)
      ? original.replaceFirst(pattern, entry)
      : original.replaceFirst('</dict>', '\t$entry\n</dict>');
  plist.writeAsStringSync(updated);
  if (!updated.contains('<string>$appId</string>')) {
    stderr.writeln('iOS AdMob application ID was not configured.');
    exitCode = 1;
  }
}

bool _isTextBuildFile(String path) {
  return path.endsWith('.kt') ||
      path.endsWith('.kts') ||
      path.endsWith('project.pbxproj');
}
