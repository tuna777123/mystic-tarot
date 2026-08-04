import 'dart:io';

const _faceIdDescription =
    'Use Face ID to unlock your private Mystic Tarot journal.';
const _entitlementsPath = 'Runner/Runner.entitlements';

void main() {
  final errors = <String>[];

  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (!manifest.existsSync()) {
    errors.add('Missing generated Android manifest.');
  } else {
    configureAndroidManifest(manifest);
  }

  final activity = findAndroidMainActivity(Directory('android/app/src/main'));
  if (activity == null) {
    errors.add('Missing generated Android MainActivity.kt.');
  } else {
    configureAndroidActivity(activity);
  }

  final infoPlist = File('ios/Runner/Info.plist');
  if (!infoPlist.existsSync()) {
    errors.add('Missing generated iOS Info.plist.');
  } else {
    configureIosInfoPlist(infoPlist);
  }

  final entitlements = File('ios/Runner/Runner.entitlements');
  configureIosEntitlements(entitlements);

  final iosProject = File('ios/Runner.xcodeproj/project.pbxproj');
  if (!iosProject.existsSync()) {
    errors.add('Missing generated iOS project file.');
  } else {
    configureIosProject(iosProject);
  }

  if (manifest.existsSync()) {
    final source = manifest.readAsStringSync();
    for (final required in const [
      'android.permission.USE_BIOMETRIC',
      'android.permission.USE_FINGERPRINT',
      'android:allowBackup="false"',
    ]) {
      if (!source.contains(required)) {
        errors.add('Android app-lock manifest entry missing: $required');
      }
    }
  }
  if (activity != null) {
    final source = activity.readAsStringSync();
    if (!source.contains('FlutterFragmentActivity')) {
      errors.add('Android MainActivity does not use FlutterFragmentActivity.');
    }
  }
  if (infoPlist.existsSync()) {
    final source = infoPlist.readAsStringSync();
    if (!source.contains('NSFaceIDUsageDescription') ||
        !source.contains(_faceIdDescription)) {
      errors.add('iOS Face ID usage description was not configured.');
    }
  }
  if (!entitlements.existsSync() ||
      !entitlements.readAsStringSync().contains('keychain-access-groups')) {
    errors.add('iOS Keychain entitlement was not configured.');
  }
  if (iosProject.existsSync() &&
      !iosProject.readAsStringSync().contains(
            'CODE_SIGN_ENTITLEMENTS = $_entitlementsPath;',
          )) {
    errors.add('iOS project does not reference the app-lock entitlements.');
  }

  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('Private app-lock platform support configured and verified.');
}

File? findAndroidMainActivity(Directory root) {
  if (!root.existsSync()) return null;
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('MainActivity.kt')) {
      return entity;
    }
  }
  return null;
}

void configureAndroidManifest(File file) {
  var source = file.readAsStringSync();
  const manifestStart =
      '<manifest xmlns:android="http://schemas.android.com/apk/res/android">';
  if (!source.contains('android.permission.USE_BIOMETRIC')) {
    source = source.replaceFirst(
      manifestStart,
      '$manifestStart\n'
          '    <uses-permission android:name="android.permission.USE_BIOMETRIC" />',
    );
  }
  if (!source.contains('android.permission.USE_FINGERPRINT')) {
    source = source.replaceFirst(
      manifestStart,
      '$manifestStart\n'
          '    <uses-permission android:name="android.permission.USE_FINGERPRINT" />',
    );
  }
  if (source.contains('<application') &&
      !source.contains('android:allowBackup=')) {
    source = source.replaceFirst(
      '<application',
      '<application\n        android:allowBackup="false"',
    );
  } else {
    source = source.replaceAll(
      RegExp(r'android:allowBackup="[^"]*"'),
      'android:allowBackup="false"',
    );
  }
  file.writeAsStringSync(source);
}

void configureAndroidActivity(File file) {
  var source = file.readAsStringSync();
  source = source.replaceAll(
    'import io.flutter.embedding.android.FlutterActivity',
    'import io.flutter.embedding.android.FlutterFragmentActivity',
  );
  source = source.replaceAll(
    'class MainActivity : FlutterActivity()',
    'class MainActivity : FlutterFragmentActivity()',
  );
  if (!source.contains('FlutterFragmentActivity')) {
    throw StateError('Generated MainActivity.kt has an unsupported shape.');
  }
  file.writeAsStringSync(source);
}

void configureIosInfoPlist(File file) {
  var source = file.readAsStringSync();
  if (!source.contains('NSFaceIDUsageDescription')) {
    const end = '</dict>';
    if (!source.contains(end)) {
      throw StateError('Generated iOS Info.plist has no dict end tag.');
    }
    source = source.replaceFirst(
      end,
      '\t<key>NSFaceIDUsageDescription</key>\n'
          '\t<string>$_faceIdDescription</string>\n'
          '$end',
    );
  }
  file.writeAsStringSync(source);
}

void configureIosEntitlements(File file) {
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>keychain-access-groups</key>
	<array>
		<string>\$(AppIdentifierPrefix)\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	</array>
</dict>
</plist>
''');
}

void configureIosProject(File file) {
  var source = file.readAsStringSync();
  if (!source.contains('CODE_SIGN_ENTITLEMENTS = $_entitlementsPath;')) {
    final productPattern = RegExp(
      r'(?m)^(\s*)PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);',
    );
    if (!productPattern.hasMatch(source)) {
      throw StateError('Generated iOS project has no bundle identifier setting.');
    }
    source = source.replaceAllMapped(productPattern, (match) {
      final indent = match.group(1)!;
      final productLine = match.group(0)!;
      return '$indentCODE_SIGN_ENTITLEMENTS = $_entitlementsPath;\n$productLine';
    });
  }
  file.writeAsStringSync(source);
}
