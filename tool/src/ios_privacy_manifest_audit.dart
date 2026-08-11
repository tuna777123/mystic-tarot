import 'dart:convert';
import 'dart:io';

class IosPrivacyManifestAuditFailure implements Exception {
  const IosPrivacyManifestAuditFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class IosPrivacyManifestAuditResult {
  const IosPrivacyManifestAuditResult({required this.manifestPaths});

  final List<String> manifestPaths;

  int get manifestCount => manifestPaths.length;

  Map<String, Object> toJson() => <String, Object>{
    'schemaVersion': 1,
    'privacyManifestCount': manifestCount,
    'privacyManifestPaths': manifestPaths,
  };
}

typedef IosPrivacyManifestCommandRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

Future<IosPrivacyManifestAuditResult> verifyIosAppPrivacyManifests({
  required Directory appBundle,
  IosPrivacyManifestCommandRunner commandRunner = _runProcess,
}) async {
  if (!appBundle.existsSync()) {
    throw IosPrivacyManifestAuditFailure(
      'iOS application bundle is missing: ${appBundle.path}',
    );
  }

  final manifests = appBundle
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('PrivacyInfo.xcprivacy'))
      .toList(growable: false)
    ..sort((left, right) => left.path.compareTo(right.path));

  if (manifests.isEmpty) {
    throw const IosPrivacyManifestAuditFailure(
      'Built iOS application contains no PrivacyInfo.xcprivacy manifests.',
    );
  }

  final relativePaths = <String>[];
  for (final manifest in manifests) {
    if (manifest.lengthSync() == 0) {
      throw IosPrivacyManifestAuditFailure(
        'Privacy manifest is empty: ${manifest.path}',
      );
    }
    await _runChecked(commandRunner, 'plutil', ['-lint', manifest.path]);
    relativePaths.add(_relativePath(appBundle, manifest));
  }

  return IosPrivacyManifestAuditResult(
    manifestPaths: List<String>.unmodifiable(relativePaths),
  );
}

Future<IosPrivacyManifestAuditResult> verifyIosArtifactPrivacyManifests({
  required File ipaFile,
  IosPrivacyManifestCommandRunner commandRunner = _runProcess,
}) async {
  if (!ipaFile.existsSync() || ipaFile.lengthSync() == 0) {
    throw IosPrivacyManifestAuditFailure(
      'Signed iOS artifact is missing: ${ipaFile.path}',
    );
  }

  final temporaryDirectory = Directory.systemTemp.createTempSync(
    'mystic-ios-privacy-manifest-audit-',
  );
  try {
    await _runChecked(commandRunner, 'unzip', [
      '-q',
      ipaFile.path,
      '-d',
      temporaryDirectory.path,
    ]);

    final payloadDirectory = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}Payload',
    );
    if (!payloadDirectory.existsSync()) {
      throw const IosPrivacyManifestAuditFailure(
        'Signed IPA has no Payload directory.',
      );
    }

    final appBundles = payloadDirectory
        .listSync(followLinks: false)
        .whereType<Directory>()
        .where((entry) => entry.path.endsWith('.app'))
        .toList(growable: false);
    if (appBundles.length != 1) {
      throw IosPrivacyManifestAuditFailure(
        'Signed IPA must contain exactly one top-level app bundle; '
        'found ${appBundles.length}.',
      );
    }

    return verifyIosAppPrivacyManifests(
      appBundle: appBundles.single,
      commandRunner: commandRunner,
    );
  } finally {
    if (temporaryDirectory.existsSync()) {
      temporaryDirectory.deleteSync(recursive: true);
    }
  }
}

String _relativePath(Directory appBundle, File manifest) {
  final prefix = '${appBundle.path}${Platform.pathSeparator}';
  if (!manifest.path.startsWith(prefix)) {
    throw IosPrivacyManifestAuditFailure(
      'Privacy manifest is outside the application bundle: ${manifest.path}',
    );
  }
  return manifest.path
      .substring(prefix.length)
      .replaceAll(Platform.pathSeparator, '/');
}

Future<ProcessResult> _runProcess(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) {
  return Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
}

Future<ProcessResult> _runChecked(
  IosPrivacyManifestCommandRunner commandRunner,
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final result = await commandRunner(
    executable,
    arguments,
    workingDirectory: workingDirectory,
  );
  if (result.exitCode != 0) {
    final error = result.stderr.toString().trim();
    throw IosPrivacyManifestAuditFailure(
      '$executable failed while verifying iOS privacy manifests'
      '${error.isEmpty ? '.' : ': $error'}',
    );
  }
  return result;
}
