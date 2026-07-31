import 'dart:convert';
import 'dart:io';

import 'src/store_release_contract.dart';

void main(List<String> arguments) {
  try {
    final values = _parseArguments(arguments);
    final platform = parseStoreReleasePlatform(_required(values, 'platform'));
    final artifact = File(_required(values, 'artifact'));
    final checksum = _required(values, 'sha256').toLowerCase();
    final output = File(_required(values, 'output'));
    final channel = _required(values, 'channel');

    if (!artifact.existsSync()) {
      throw FormatException('Release artifact does not exist: ${artifact.path}');
    }
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(checksum)) {
      throw const FormatException('Artifact SHA-256 must be 64 hex characters.');
    }

    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      throw const FormatException('pubspec.yaml was not found.');
    }
    final version = readPubspecVersion(pubspec.readAsStringSync());
    final manifest = <String, Object?>{
      'schemaVersion': 1,
      'app': StoreReleaseContract.appName,
      'version': version,
      'platform': platform.name,
      'channel': channel,
      'bundleIdentifier': StoreReleaseContract.bundleIdentifier,
      'entitlementId': StoreReleaseContract.entitlementId,
      'products': const [
        StoreReleaseContract.monthlyProductId,
        StoreReleaseContract.yearlyProductId,
      ],
      'artifact': artifact.uri.pathSegments.last,
      'artifactBytes': artifact.lengthSync(),
      'artifactSha256': checksum,
      'signed': true,
      'gitSha': Platform.environment['GITHUB_SHA'],
      'sourceRef': Platform.environment['GITHUB_REF_NAME'],
      'builtAtUtc': DateTime.now().toUtc().toIso8601String(),
    };

    output.parent.createSync(recursive: true);
    output.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(manifest),
    );
    stdout.writeln(
      'Release manifest written for '
      '${releaseArtifactName(platform: platform, version: version, channel: channel)}.',
    );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(
      'Usage: dart run tool/write_release_manifest.dart '
      '--platform=android|ios --artifact=<path> --sha256=<digest> '
      '--channel=<name> --output=<path>',
    );
    exitCode = 64;
  }
}

Map<String, String> _parseArguments(List<String> arguments) {
  final values = <String, String>{};
  for (final argument in arguments) {
    if (!argument.startsWith('--') || !argument.contains('=')) continue;
    final separator = argument.indexOf('=');
    values[argument.substring(2, separator)] = argument.substring(separator + 1);
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
