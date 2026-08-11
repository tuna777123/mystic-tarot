import 'dart:convert';
import 'dart:io';

import 'store_release_contract.dart';

class MobileAdsSdkEvidence {
  const MobileAdsSdkEvidence({
    required this.platform,
    required this.flutterPluginVersion,
    required this.mobileAdsSdkVersion,
    required this.umpSdkVersion,
    required this.source,
  });

  final String platform;
  final String flutterPluginVersion;
  final String mobileAdsSdkVersion;
  final String umpSdkVersion;
  final String source;

  Map<String, Object> toJson() => <String, Object>{
    'platform': platform,
    'flutterPluginVersion': flutterPluginVersion,
    'mobileAdsSdkVersion': mobileAdsSdkVersion,
    'umpSdkVersion': umpSdkVersion,
    'source': source,
  };
}

String googleMobileAdsPluginVersionFromLockfile(String source) {
  final match = RegExp(
    r'^  google_mobile_ads:\n(?:    .*\n)*?    version: "([^"]+)"$',
    multiLine: true,
  ).firstMatch(source);
  if (match == null) {
    throw const FormatException(
      'pubspec.lock does not contain a resolved google_mobile_ads version.',
    );
  }
  return match.group(1)!;
}

MobileAdsSdkEvidence parseAndroidMobileAdsSdkEvidence({
  required String pubspecLock,
  required String dependencyReport,
  String source = 'Gradle releaseRuntimeClasspath',
}) {
  return MobileAdsSdkEvidence(
    platform: StoreReleasePlatform.android.name,
    flutterPluginVersion: googleMobileAdsPluginVersionFromLockfile(pubspecLock),
    mobileAdsSdkVersion: _resolvedGradleModuleVersion(
      dependencyReport,
      'com.google.android.gms:play-services-ads',
    ),
    umpSdkVersion: _resolvedGradleModuleVersion(
      dependencyReport,
      'com.google.android.ump:user-messaging-platform',
    ),
    source: source,
  );
}

MobileAdsSdkEvidence parseIosMobileAdsSdkEvidence({
  required String pubspecLock,
  required String packageResolved,
  String source = 'SwiftPM Package.resolved',
}) {
  final decoded = jsonDecode(packageResolved);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('SwiftPM Package.resolved must be a JSON map.');
  }

  final pinsValue =
      decoded['pins'] ??
      (decoded['object'] is Map<String, dynamic>
          ? (decoded['object'] as Map<String, dynamic>)['pins']
          : null);
  if (pinsValue is! List) {
    throw const FormatException('SwiftPM Package.resolved has no pins list.');
  }

  String? mobileAdsVersion;
  String? umpVersion;
  for (final pinValue in pinsValue) {
    if (pinValue is! Map) continue;
    final pin = Map<String, dynamic>.from(pinValue);
    final identity = '${pin['identity'] ?? pin['package'] ?? ''}'.toLowerCase();
    final location = '${pin['location'] ?? pin['repositoryURL'] ?? ''}'
        .toLowerCase();
    final stateValue = pin['state'];
    if (stateValue is! Map) continue;
    final state = Map<String, dynamic>.from(stateValue);
    final version = '${state['version'] ?? ''}'.trim();
    if (version.isEmpty) continue;

    if (_matchesSwiftPackage(
      identity,
      location,
      'swift-package-manager-google-mobile-ads',
    )) {
      mobileAdsVersion = version;
    }
    if (_matchesSwiftPackage(
      identity,
      location,
      'swift-package-manager-google-user-messaging-platform',
    )) {
      umpVersion = version;
    }
  }

  if (mobileAdsVersion == null) {
    throw const FormatException(
      'SwiftPM Package.resolved does not contain Google Mobile Ads.',
    );
  }
  if (umpVersion == null) {
    throw const FormatException(
      'SwiftPM Package.resolved does not contain Google User Messaging Platform.',
    );
  }

  return MobileAdsSdkEvidence(
    platform: StoreReleasePlatform.ios.name,
    flutterPluginVersion: googleMobileAdsPluginVersionFromLockfile(pubspecLock),
    mobileAdsSdkVersion: mobileAdsVersion,
    umpSdkVersion: umpVersion,
    source: source,
  );
}

Future<MobileAdsSdkEvidence> collectMobileAdsSdkEvidence({
  required StoreReleasePlatform platform,
  String pubspecLockPath = 'pubspec.lock',
  String androidDirectory = 'android',
  String iosDirectory = 'ios',
  String iosBuildDirectory = 'build/ios',
  String? androidReportPath,
}) async {
  final lockfile = File(pubspecLockPath);
  if (!lockfile.existsSync()) {
    throw FormatException('Missing Flutter lockfile: $pubspecLockPath');
  }
  final pubspecLock = lockfile.readAsStringSync();

  if (platform == StoreReleasePlatform.android) {
    final gradleDirectory = Directory(androidDirectory);
    if (!gradleDirectory.existsSync()) {
      throw FormatException('Missing Android project: $androidDirectory');
    }
    final gradleExecutable = Platform.isWindows ? 'gradlew.bat' : './gradlew';
    final result = await Process.run(gradleExecutable, const <String>[
      ':app:dependencies',
      '--configuration',
      'releaseRuntimeClasspath',
      '--console=plain',
    ], workingDirectory: gradleDirectory.path);
    final report = '${result.stdout}\n${result.stderr}';
    if (result.exitCode != 0) {
      throw FormatException(
        'Unable to resolve Android releaseRuntimeClasspath '
        '(exit ${result.exitCode}).',
      );
    }
    if (androidReportPath != null) {
      final reportFile = File(androidReportPath);
      reportFile.parent.createSync(recursive: true);
      reportFile.writeAsStringSync(report);
    }
    return parseAndroidMobileAdsSdkEvidence(
      pubspecLock: pubspecLock,
      dependencyReport: report,
    );
  }

  final candidates = <File>[];
  for (final rootPath in <String>[iosDirectory, iosBuildDirectory]) {
    final root = Directory(rootPath);
    if (!root.existsSync()) continue;
    for (final entity in root.listSync(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('Package.resolved')) {
        candidates.add(entity);
      }
    }
  }
  if (candidates.isEmpty) {
    throw const FormatException(
      'No SwiftPM Package.resolved file was found after the iOS build.',
    );
  }

  final parsed = <MobileAdsSdkEvidence>[];
  final failures = <String>[];
  for (final candidate in candidates) {
    try {
      parsed.add(
        parseIosMobileAdsSdkEvidence(
          pubspecLock: pubspecLock,
          packageResolved: candidate.readAsStringSync(),
          source: candidate.path,
        ),
      );
    } on FormatException catch (error) {
      failures.add('${candidate.path}: ${error.message}');
    }
  }
  if (parsed.isEmpty) {
    throw FormatException(
      'No SwiftPM resolution contained both Mobile Ads and UMP. '
      '${failures.join(' | ')}',
    );
  }

  final versions = parsed
      .map(
        (evidence) =>
            '${evidence.mobileAdsSdkVersion}/${evidence.umpSdkVersion}',
      )
      .toSet();
  if (versions.length != 1) {
    throw FormatException(
      'Conflicting SwiftPM Mobile Ads/UMP resolutions were found: '
      '${versions.join(', ')}.',
    );
  }
  return parsed.first;
}

void writeMobileAdsSdkEvidence(
  MobileAdsSdkEvidence evidence,
  String outputPath,
) {
  final output = File(outputPath);
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(
    const JsonEncoder.withIndent(
      '  ',
    ).convert(<String, Object>{'schemaVersion': 1, ...evidence.toJson()}),
  );
}

String _resolvedGradleModuleVersion(String report, String module) {
  final expression = RegExp(
    '${RegExp.escape(module)}:([0-9A-Za-z.+_-]+)'
    r'(?:\s+->\s+([0-9A-Za-z.+_-]+))?',
  );
  final versions = <String>{};
  for (final match in expression.allMatches(report)) {
    versions.add(match.group(2) ?? match.group(1)!);
  }
  if (versions.isEmpty) {
    throw FormatException(
      'Gradle releaseRuntimeClasspath does not contain $module.',
    );
  }
  if (versions.length != 1) {
    throw FormatException(
      'Gradle resolved multiple versions for $module: ${versions.join(', ')}.',
    );
  }
  return versions.single;
}

bool _matchesSwiftPackage(
  String identity,
  String location,
  String packageName,
) {
  return identity == packageName ||
      location.endsWith('/$packageName') ||
      location.endsWith('/$packageName.git');
}
