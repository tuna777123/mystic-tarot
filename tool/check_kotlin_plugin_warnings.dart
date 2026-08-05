import 'dart:io';

import 'src/kotlin_plugin_warning.dart';

void main(List<String> arguments) {
  try {
    final options = _Options.parse(arguments);
    final source = options.logFile.readAsStringSync();
    final snapshot = KotlinPluginWarningSnapshot.parse(source);
    final unexpected = snapshot.unexpectedPlugins(options.allowedPlugins);

    if (unexpected.isNotEmpty) {
      final names = unexpected.toList()..sort();
      stderr.writeln(
        'Unexpected plugins still apply the Kotlin Gradle Plugin: '
        '${names.join(', ')}',
      );
      exitCode = 1;
      return;
    }

    if (snapshot.plugins.isEmpty) {
      stdout.writeln('Built-in Kotlin check passed: no legacy KGP warnings.');
      return;
    }

    final names = snapshot.plugins.toList()..sort();
    stdout.writeln(
      'Built-in Kotlin check passed with temporary upstream allowlist: '
      '${names.join(', ')}',
    );
  } on FileSystemException catch (error) {
    stderr.writeln('Could not read the Android build log: $error');
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln(
      'Could not parse the Android Kotlin warning: ${error.message}',
    );
    exitCode = 1;
  } on ArgumentError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

class _Options {
  const _Options({required this.logFile, required this.allowedPlugins});

  final File logFile;
  final Set<String> allowedPlugins;

  static _Options parse(List<String> arguments) {
    String? logPath;
    final allowedPlugins = <String>{};

    for (var index = 0; index < arguments.length; index++) {
      final argument = arguments[index];
      if (argument != '--log' && argument != '--allow') {
        throw ArgumentError(
          'Unknown argument $argument. Usage: '
          'dart run tool/check_kotlin_plugin_warnings.dart '
          '--log <build.log> [--allow <plugin>]...',
        );
      }
      if (index + 1 >= arguments.length) {
        throw ArgumentError('$argument requires a value.');
      }
      final value = arguments[++index].trim();
      if (value.isEmpty) {
        throw ArgumentError('$argument requires a non-empty value.');
      }
      if (argument == '--log') {
        if (logPath != null) {
          throw ArgumentError('--log may only be supplied once.');
        }
        logPath = value;
      } else {
        allowedPlugins.add(value);
      }
    }

    if (logPath == null) {
      throw ArgumentError('--log is required.');
    }

    return _Options(
      logFile: File(logPath),
      allowedPlugins: Set<String>.unmodifiable(allowedPlugins),
    );
  }
}
