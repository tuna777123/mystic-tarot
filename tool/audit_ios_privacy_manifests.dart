import 'dart:convert';
import 'dart:io';

import 'src/ios_privacy_manifest_audit.dart';

Future<void> main(List<String> arguments) async {
  try {
    final values = _parseArguments(arguments);
    final appPath = values['app']?.trim() ?? '';
    final ipaPath = values['ipa']?.trim() ?? '';
    final outputPath = _required(values, 'output');

    if ((appPath.isEmpty && ipaPath.isEmpty) ||
        (appPath.isNotEmpty && ipaPath.isNotEmpty)) {
      throw const FormatException(
        'Provide exactly one of --app=<Runner.app> or --ipa=<file.ipa>.',
      );
    }

    final result = appPath.isNotEmpty
        ? await verifyIosAppPrivacyManifests(appBundle: Directory(appPath))
        : await verifyIosArtifactPrivacyManifests(ipaFile: File(ipaPath));

    final output = File(outputPath);
    output.parent.createSync(recursive: true);
    output.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(result.toJson()),
    );

    stdout.writeln('Verified ${result.manifestCount} iOS privacy manifest(s).');
    for (final path in result.manifestPaths) {
      stdout.writeln('- $path');
    }
  } on FormatException catch (error) {
    _fail(error.message);
  } on IosPrivacyManifestAuditFailure catch (error) {
    _fail(error.message);
  }
}

Map<String, String> _parseArguments(List<String> arguments) {
  final values = <String, String>{};
  for (final argument in arguments) {
    if (!argument.startsWith('--') || !argument.contains('=')) continue;
    final separator = argument.indexOf('=');
    values[argument.substring(2, separator)] = argument.substring(
      separator + 1,
    );
  }
  return values;
}

String _required(Map<String, String> values, String name) {
  final value = values[name]?.trim();
  if (value == null || value.isEmpty) {
    throw FormatException('The --$name argument is required.');
  }
  return value;
}

void _fail(String message) {
  stderr.writeln(message);
  stderr.writeln(
    'Usage: dart run tool/audit_ios_privacy_manifests.dart '
    '--app=<Runner.app>|--ipa=<file.ipa> --output=<path>',
  );
  exitCode = 1;
}
