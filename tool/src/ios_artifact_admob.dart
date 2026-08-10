import 'dart:convert';
import 'dart:io';

import 'ios_admob_plist_audit.dart';

typedef IosAdMobArtifactCommandRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

Future<IosAdMobPlistAuditResult> verifyIosArtifactAdMobConfiguration({
  required File ipaFile,
  required String expectedAppId,
  IosAdMobArtifactCommandRunner commandRunner = _runProcess,
}) async {
  if (!ipaFile.existsSync() || ipaFile.lengthSync() == 0) {
    throw IosAdMobPlistAuditFailure(
      'Signed iOS artifact is missing: ${ipaFile.path}',
    );
  }

  final temporaryDirectory = Directory.systemTemp.createTempSync(
    'mystic-ios-admob-audit-',
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
      throw const IosAdMobPlistAuditFailure(
        'Signed IPA has no Payload directory.',
      );
    }
    final appBundles = payloadDirectory
        .listSync(followLinks: false)
        .whereType<Directory>()
        .where((entry) => entry.path.endsWith('.app'))
        .toList(growable: false);
    if (appBundles.length != 1) {
      throw IosAdMobPlistAuditFailure(
        'Signed IPA must contain exactly one top-level app bundle; '
        'found ${appBundles.length}.',
      );
    }

    final plist = File(
      '${appBundles.single.path}${Platform.pathSeparator}Info.plist',
    );
    if (!plist.existsSync() || plist.lengthSync() == 0) {
      throw const IosAdMobPlistAuditFailure(
        'Exported iOS app has no readable Info.plist.',
      );
    }
    final decoded = await _runChecked(commandRunner, 'plutil', [
      '-convert',
      'xml1',
      '-o',
      '-',
      plist.path,
    ]);
    return auditIosAdMobPlistXml(
      decoded.stdout as String,
      expectedAppId: expectedAppId,
    );
  } finally {
    if (temporaryDirectory.existsSync()) {
      temporaryDirectory.deleteSync(recursive: true);
    }
  }
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
  IosAdMobArtifactCommandRunner commandRunner,
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
    throw IosAdMobPlistAuditFailure(
      '$executable failed while verifying the exported iOS AdMob plist'
      '${error.isEmpty ? '.' : ': $error'}',
    );
  }
  return result;
}
