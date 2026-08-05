import 'dart:io';

import 'src/kotlin_plugin_warnings.dart';

Future<void> main(List<String> arguments) async {
  try {
    final options = _Options.parse(arguments);
    final buildLog = await options.logFile.readAsString();
    final observed = parseLegacyKgpPlugins(buildLog);
    final delta = compareLegacyKgpPlugins(observed);
    if (!delta.isValid) {
      final problems = <String>[];
      if (delta.missing.isNotEmpty) {
        problems.add(
          'expected but not observed: ${_sorted(delta.missing).join(', ')}',
        );
      }
      if (delta.unexpected.isNotEmpty) {
        problems.add(
          'unexpected legacy plugins: '
          '${_sorted(delta.unexpected).join(', ')}',
        );
      }
      throw KotlinPluginWarningFailure(problems.join('; '));
    }

    final report = buildKotlinCompatibilityReport(observed);
    await options.reportFile.parent.create(recursive: true);
    await options.reportFile.writeAsString(report);
    stdout.write(report);
  } on KotlinPluginWarningFailure catch (error) {
    stderr.writeln('Built-in Kotlin audit failed: ${error.message}');
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('Built-in Kotlin audit could not read its input: $error');
    exitCode = 1;
  }
}

List<String> _sorted(Iterable<String> values) {
  return values.toList()..sort();
}

class _Options {
  const _Options({required this.logFile, required this.reportFile});

  final File logFile;
  final File reportFile;

  static _Options parse(List<String> arguments) {
    String? value(String name) {
      final index = arguments.indexOf(name);
      if (index == -1) {
        return null;
      }
      if (index + 1 >= arguments.length) {
        throw KotlinPluginWarningFailure('$name requires a value.');
      }
      return arguments[index + 1];
    }

    final logPath = value('--log');
    if (logPath == null) {
      throw const KotlinPluginWarningFailure(
        'Usage: dart run tool/verify_kotlin_plugin_warnings.dart '
        '--log <android-build.log> [--report <audit.md>]',
      );
    }

    return _Options(
      logFile: File(logPath),
      reportFile: File(
        value('--report') ?? '$logPath.built-in-kotlin-audit.md',
      ),
    );
  }
}
