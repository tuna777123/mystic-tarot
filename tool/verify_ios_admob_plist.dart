import 'dart:convert';
import 'dart:io';

import 'src/ios_admob_plist_audit.dart';

Future<void> main(List<String> arguments) async {
  try {
    final options = _Options.parse(arguments);
    if (!options.plist.existsSync()) {
      throw IosAdMobPlistAuditFailure(
        'Exported iOS Info.plist does not exist: ${options.plist.path}',
      );
    }

    final plutilResult = await Process.run(
      'plutil',
      ['-convert', 'xml1', '-o', '-', options.plist.path],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (plutilResult.exitCode != 0) {
      throw IosAdMobPlistAuditFailure(
        'plutil could not decode exported iOS Info.plist: '
        '${(plutilResult.stderr as String).trim()}',
      );
    }

    final result = auditIosAdMobPlistXml(
      plutilResult.stdout as String,
      expectedAppId: options.appId,
    );
    stdout.writeln(
      'Exported iOS AdMob plist audit PASS: production app ID matched; '
      '${result.skAdNetworkCount} reviewed SKAdNetwork IDs matched.',
    );
  } on IosAdMobPlistAuditFailure catch (error) {
    stderr.writeln('Exported iOS AdMob plist audit failed: ${error.message}');
    exitCode = 1;
  }
}

class _Options {
  const _Options({required this.plist, required this.appId});

  final File plist;
  final String appId;

  static _Options parse(List<String> arguments) {
    String? value(String name) {
      final index = arguments.indexOf(name);
      if (index == -1) return null;
      if (index + 1 >= arguments.length) {
        throw IosAdMobPlistAuditFailure('$name requires a value.');
      }
      return arguments[index + 1];
    }

    final plistPath = value('--plist');
    final appId = value('--app-id')?.trim();
    if (plistPath == null || appId == null || appId.isEmpty) {
      throw const IosAdMobPlistAuditFailure(
        'Usage: dart run tool/verify_ios_admob_plist.dart '
        '--plist <Info.plist> --app-id <production AdMob app ID>',
      );
    }
    if (!RegExp(r'^ca-app-pub-\d{16}~\d{10}$').hasMatch(appId)) {
      throw const IosAdMobPlistAuditFailure(
        '--app-id must be a valid AdMob application ID.',
      );
    }
    return _Options(plist: File(plistPath), appId: appId);
  }
}
