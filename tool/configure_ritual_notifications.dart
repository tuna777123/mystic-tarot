import 'dart:io';

const _desugaringDependency =
    'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")';

void main() {
  final gradle = File('android/app/build.gradle.kts');
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  final errors = <String>[];

  if (!gradle.existsSync()) {
    errors.add('Missing generated Android Gradle file.');
  } else {
    _configureGradle(gradle);
  }
  if (!manifest.existsSync()) {
    errors.add('Missing generated Android manifest.');
  } else {
    _configureManifest(manifest);
  }

  if (gradle.existsSync()) {
    final source = gradle.readAsStringSync();
    if (!source.contains('isCoreLibraryDesugaringEnabled = true')) {
      errors.add('Core library desugaring was not enabled.');
    }
    if (!source.contains(_desugaringDependency)) {
      errors.add('Desugaring dependency was not added.');
    }
  }
  if (manifest.existsSync()) {
    final source = manifest.readAsStringSync();
    for (final required in const [
      'android.permission.RECEIVE_BOOT_COMPLETED',
      'ScheduledNotificationReceiver',
      'ScheduledNotificationBootReceiver',
    ]) {
      if (!source.contains(required)) {
        errors.add('Android notification manifest entry missing: $required');
      }
    }
  }

  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('Daily ritual notification shell configured and verified.');
}

void _configureGradle(File file) {
  var source = file.readAsStringSync();
  if (!source.contains('isCoreLibraryDesugaringEnabled = true')) {
    const marker = 'compileOptions {';
    if (!source.contains(marker)) {
      throw StateError('Generated Android Gradle file has no compileOptions block.');
    }
    source = source.replaceFirst(
      marker,
      '$marker\n        isCoreLibraryDesugaringEnabled = true',
    );
  }
  if (!source.contains(_desugaringDependency)) {
    if (source.contains('\ndependencies {')) {
      source = source.replaceFirst(
        '\ndependencies {',
        '\ndependencies {\n    $_desugaringDependency',
      );
    } else {
      source = '$source\n\ndependencies {\n    $_desugaringDependency\n}\n';
    }
  }
  file.writeAsStringSync(source);
}

void _configureManifest(File file) {
  var source = file.readAsStringSync();
  if (!source.contains('android.permission.RECEIVE_BOOT_COMPLETED')) {
    source = source.replaceFirst(
      '<manifest xmlns:android="http://schemas.android.com/apk/res/android">',
      '<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n'
          '    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />',
    );
  }
  if (!source.contains('ScheduledNotificationReceiver')) {
    const applicationEnd = '    </application>';
    const receivers = '''
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
''';
    if (!source.contains(applicationEnd)) {
      throw StateError('Generated Android manifest has no application end tag.');
    }
    source = source.replaceFirst(applicationEnd, '$receivers$applicationEnd');
  }
  file.writeAsStringSync(source);
}
