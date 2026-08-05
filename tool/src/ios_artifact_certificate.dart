import 'dart:io';

typedef IosCertificateCommandRunner = Future<ProcessResult> Function(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
});

Future<String> verifyIosArtifactSigningCertificate({
  required File ipaFile,
  required String expectedFingerprint,
  IosCertificateCommandRunner commandRunner = _runProcess,
}) async {
  if (!ipaFile.existsSync() || ipaFile.lengthSync() == 0) {
    throw FormatException('Signed iOS artifact is missing: ${ipaFile.path}');
  }

  final expected = _normalizeFingerprint(expectedFingerprint);
  final temporaryDirectory = Directory.systemTemp.createTempSync(
    'mystic-ios-signing-cert-',
  );

  try {
    await _runChecked(
      commandRunner,
      'unzip',
      ['-q', ipaFile.path, '-d', temporaryDirectory.path],
    );

    final payloadDirectory = Directory(
      '${temporaryDirectory.path}${Platform.pathSeparator}Payload',
    );
    if (!payloadDirectory.existsSync()) {
      throw const FormatException('Signed IPA has no Payload directory.');
    }

    final appBundles = payloadDirectory
        .listSync(followLinks: false)
        .whereType<Directory>()
        .where((entry) => entry.path.endsWith('.app'))
        .toList(growable: false);
    if (appBundles.length != 1) {
      throw FormatException(
        'Signed IPA must contain exactly one top-level app bundle; '
        'found ${appBundles.length}.',
      );
    }

    await _runChecked(
      commandRunner,
      'codesign',
      ['--display', '--extract-certificates', appBundles.single.path],
      workingDirectory: temporaryDirectory.path,
    );

    final leafCertificate = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}codesign0',
    );
    if (!leafCertificate.existsSync() || leafCertificate.lengthSync() == 0) {
      throw const FormatException(
        'codesign did not extract the final app leaf certificate.',
      );
    }

    final digestResult = await _runChecked(
      commandRunner,
      'shasum',
      ['-a', '256', leafCertificate.path],
    );
    final actual = _parseSha256Output(digestResult.stdout as String);
    if (actual != expected) {
      throw const FormatException(
        'Final iOS app signing certificate does not match the reviewed '
        'distribution certificate fingerprint.',
      );
    }
    return actual;
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
  );
}

Future<ProcessResult> _runChecked(
  IosCertificateCommandRunner commandRunner,
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
    throw FormatException(
      '$executable failed while verifying the signed iOS artifact'
      '${error.isEmpty ? '.' : ': $error'}',
    );
  }
  return result;
}

String _parseSha256Output(String output) {
  final parts = output.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) {
    throw const FormatException(
      'Could not read the final iOS certificate SHA-256 fingerprint.',
    );
  }
  return _normalizeFingerprint(parts.first);
}

String _normalizeFingerprint(String value) {
  final normalized = value.replaceAll(RegExp(r'[:\s]'), '').toUpperCase();
  if (!RegExp(r'^[0-9A-F]{64}$').hasMatch(normalized)) {
    throw const FormatException(
      'iOS certificate SHA-256 fingerprint must contain exactly 64 '
      'hexadecimal characters.',
    );
  }
  return normalized;
}
