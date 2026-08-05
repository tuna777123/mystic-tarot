import 'dart:io';

import 'src/kotlin_plugin_audit.dart';

Future<void> main(List<String> arguments) async {
  try {
    final options = _Options.parse(arguments);
    final buildLog = await options.logFile.readAsString();
    final result = auditLegacyKotlinPlugins(
      buildLog: buildLog,
      allowedBlockers: options.allowedBlockers,
    );
    final report = result.formatReport();
    await options.reportFile.parent.create(recursive: true);
    await options.reportFile.writeAsString(report);
    stdout.write(report);
  } on KotlinPluginAuditFailure catch (error) {
    stderr.writeln(
      'Built-in Kotlin compatibility audit failed: ${error.message}',
    );
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('Built-in Kotlin compatibility audit could not run: $error');
    exitCode = 1;
  }
}

class _Options {
  const _Options({
    required this.logFile,
    required this.reportFile,
    required this.allowedBlockers,
  });

  final File logFile;
  final File reportFile;
  final Set<String> allowedBlockers;

  static _Options parse(List<String> arguments) {
    String? value(String name) {
      final index = arguments.indexOf(name);
      if (index == -1) return null;
      if (index + 1 >= arguments.length) {
        throw KotlinPluginAuditFailure('$name requires a value.');
      }
      return arguments[index + 1];
    }

    final logPath = value('--log');
    if (logPath == null) {
      throw const KotlinPluginAuditFailure(
        'Usage: dart run tool/verify_kotlin_plugin_warnings.dart '
        '--log <android-build.log> [--allow plugin_a,plugin_b] '
        '[--report <report.md>]',
      );
    }

    final allowed = (value('--allow') ?? '')
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();

    return _Options(
      logFile: File(logPath),
      reportFile: File(value('--report') ?? '$logPath.kotlin-audit.md'),
      allowedBlockers: allowed,
    );
  }
}
