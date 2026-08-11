import 'dart:io';

import 'src/mobile_ads_sdk_evidence.dart';
import 'src/store_release_contract.dart';

Future<void> main(List<String> arguments) async {
  try {
    final values = _parseArguments(arguments);
    final platform = parseStoreReleasePlatform(_required(values, 'platform'));
    final output = _required(values, 'output');
    final evidence = await collectMobileAdsSdkEvidence(
      platform: platform,
      androidReportPath: values['android-report'],
    );
    writeMobileAdsSdkEvidence(evidence, output);
    stdout.writeln(
      'Recorded ${platform.name} Mobile Ads SDK evidence: '
      'google_mobile_ads ${evidence.flutterPluginVersion}, '
      'native ads ${evidence.mobileAdsSdkVersion}, '
      'UMP ${evidence.umpSdkVersion}.',
    );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(
      'Usage: dart run tool/collect_mobile_ads_sdk_evidence.dart '
      '--platform=android|ios --output=<path> '
      '[--android-report=<path>]',
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
