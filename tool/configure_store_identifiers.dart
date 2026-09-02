import 'dart:io';

import 'configure_app_lock.dart' as app_lock_config;
import 'configure_ritual_notifications.dart' as ritual_config;
import 'materialize_ad_only_ui.dart' as ad_only_ui;
import 'materialize_home_focus.dart' as home_focus;
import 'materialize_optional_name_onboarding.dart' as optional_name_onboarding;

const permanentIdentifier = 'com.tunabozcali.mystictarot';
const androidAdMobTestAppId = 'ca-app-pub-3940256099942544~3347511713';
const iosAdMobTestAppId = 'ca-app-pub-3940256099942544~1458002511';

/// Reviewed against Google's official iOS AdMob quick-start snippet on
/// 2026-07-22. Keep this list synchronized with the dated release contract
/// before producing a new store candidate.
const iosSkAdNetworkSourceReviewedOn = '2026-07-22';
const iosSkAdNetworkIdentifiers = <String>[
  'cstr6suwn9.skadnetwork',
  '4fzdc2evr5.skadnetwork',
  '2fnua5tdw4.skadnetwork',
  'ydx93a7ass.skadnetwork',
  'p78axxw29g.skadnetwork',
  'v72qych5uu.skadnetwork',
  'ludvb6z3bs.skadnetwork',
  'cp8zw746q7.skadnetwork',
  '3sh42y64q3.skadnetwork',
  'c6k4g5qg8m.skadnetwork',
  's39g8k73mm.skadnetwork',
  'wg4vff78zm.skadnetwork',
  '3qy4746246.skadnetwork',
  'f38h382jlk.skadnetwork',
  'hs6bdukanm.skadnetwork',
  'mlmmfzh3r3.skadnetwork',
  'v4nxqhlyqp.skadnetwork',
  'wzmmz9fp6w.skadnetwork',
  'su67r6k2v3.skadnetwork',
  'yclnxrl5pm.skadnetwork',
  't38b2kh725.skadnetwork',
  '7ug5zh24hu.skadnetwork',
  'gta9lk7p23.skadnetwork',
  'vutu7akeur.skadnetwork',
  'y5ghdn5j9k.skadnetwork',
  'v9wttpbfk9.skadnetwork',
  'n38lu8286q.skadnetwork',
  '47vhws6wlr.skadnetwork',
  'kbd757ywx3.skadnetwork',
  '9t245vhmpl.skadnetwork',
  'a2p9lx4jpn.skadnetwork',
  '22mmun2rn5.skadnetwork',
  '44jx6755aq.skadnetwork',
  'k674qkevps.skadnetwork',
  '4468km3ulz.skadnetwork',
  '2u9pt9hc89.skadnetwork',
  '8s468mfl3y.skadnetwork',
  'klf5c3l5u5.skadnetwork',
  'ppxm28t8ap.skadnetwork',
  'kbmxgpxpgc.skadnetwork',
  'uw77j35x4d.skadnetwork',
  '578prtvx9j.skadnetwork',
  '4dzt52r2t5.skadnetwork',
  'tl55sbb4fm.skadnetwork',
  'c3frkrj4fj.skadnetwork',
  'e5fvkxwrpn.skadnetwork',
  '8c4e2ghe7u.skadnetwork',
  '3rd42ekr43.skadnetwork',
  '97r2b46745.skadnetwork',
  '3qcr597p9d.skadnetwork',
];

const generatedIdentifiers = <String>[
  'com.tunabozcali.mystic_tarot',
  'com.tunabozcali.mysticTarot',
  'com.example.mystic_tarot',
];

void main() {
  ad_only_ui.materializeAdOnlyUi();
  optional_name_onboarding.materializeOptionalNameOnboarding();
  home_focus.materializeHomeFocus();

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

String materializeIosAdMobPlist(String original, String appId) {
  final appIdPattern = RegExp(
    r'<key>GADApplicationIdentifier</key>\s*<string>[^<]+</string>',
    multiLine: true,
  );
  final appIdEntry = '''<key>GADApplicationIdentifier</key>
\t<string>$appId</string>''';
  var updated = appIdPattern.hasMatch(original)
      ? original.replaceFirst(appIdPattern, appIdEntry)
      : _insertBeforeRootDictionaryClose(original, appIdEntry);

  final skAdNetworkPattern = RegExp(
    r'<key>SKAdNetworkItems</key>\s*<array>.*?</array>',
    multiLine: true,
    dotAll: true,
  );
  final skAdNetworkEntry = _iosSkAdNetworkPlistEntry();
  updated = skAdNetworkPattern.hasMatch(updated)
      ? updated.replaceFirst(skAdNetworkPattern, skAdNetworkEntry)
      : _insertBeforeRootDictionaryClose(updated, skAdNetworkEntry);
  return updated;
}

void _configureIosAdMob(String appId) {
  final plist = File('ios/Runner/Info.plist');
  if (!plist.existsSync()) {
    stderr.writeln('iOS Info.plist is missing.');
    exitCode = 1;
    return;
  }
  final original = plist.readAsStringSync();
  late final String updated;
  try {
    updated = materializeIosAdMobPlist(original, appId);
  } on StateError catch (error) {
    stderr.writeln('iOS AdMob configuration failed: $error');
    exitCode = 1;
    return;
  }
  plist.writeAsStringSync(updated);

  if (!updated.contains('<string>$appId</string>')) {
    stderr.writeln('iOS AdMob application ID was not configured.');
    exitCode = 1;
  }
  final invalidSkAdNetworkIds = <String>[
    for (final identifier in iosSkAdNetworkIdentifiers)
      if (RegExp(RegExp.escape(identifier)).allMatches(updated).length != 1)
        identifier,
  ];
  if (invalidSkAdNetworkIds.isNotEmpty) {
    stderr.writeln(
      'iOS SKAdNetwork materialization is incomplete or duplicated: '
      '${invalidSkAdNetworkIds.join(', ')}',
    );
    exitCode = 1;
  }
}

String _iosSkAdNetworkPlistEntry() {
  final items = iosSkAdNetworkIdentifiers
      .map(
        (identifier) =>
            '''\t\t<dict>
\t\t\t<key>SKAdNetworkIdentifier</key>
\t\t\t<string>$identifier</string>
\t\t</dict>''',
      )
      .join('\n');
  return '''<key>SKAdNetworkItems</key>
\t<array>
$items
\t</array>''';
}

String _insertBeforeRootDictionaryClose(String source, String entry) {
  final insertionPoint = source.lastIndexOf('</dict>');
  if (insertionPoint < 0) {
    throw StateError('Info.plist has no root dictionary closing tag.');
  }
  return source.replaceRange(insertionPoint, insertionPoint, '\t$entry\n');
}

bool _isTextBuildFile(String path) {
  return path.endsWith('.kt') ||
      path.endsWith('.kts') ||
      path.endsWith('project.pbxproj');
}
