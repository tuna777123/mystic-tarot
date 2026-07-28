import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef MysticErrorReporter = FutureOr<void> Function(
  Object error,
  StackTrace stackTrace, {
  required bool fatal,
  String? context,
});

/// Centralized error boundary for production diagnostics.
///
/// A remote crash provider can be connected later by passing [reporter]
/// without changing the rest of the application.
class MysticAppObservability {
  MysticAppObservability._();

  static MysticErrorReporter _reporter = _debugReporter;

  static void configure({MysticErrorReporter? reporter}) {
    _reporter = reporter ?? _debugReporter;

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(
        report(
          details.exception,
          details.stack ?? StackTrace.current,
          fatal: false,
          context: details.context?.toDescription(),
        ),
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      unawaited(report(error, stackTrace, fatal: true));
      return true;
    };
  }

  static Future<void> run(FutureOr<void> Function() body) async {
    await runZonedGuarded<Future<void>>(
      () async => body(),
      (error, stackTrace) => unawaited(
        report(error, stackTrace, fatal: true, context: 'root_zone'),
      ),
    );
  }

  static Future<void> report(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
    String? context,
  }) async {
    try {
      await _reporter(
        error,
        stackTrace,
        fatal: fatal,
        context: context,
      );
    } catch (reportingError, reportingStackTrace) {
      if (kDebugMode) {
        debugPrint('Mystic error reporter failed: $reportingError');
        debugPrintStack(stackTrace: reportingStackTrace);
      }
    }
  }

  static void _debugReporter(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
    String? context,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'Mystic ${fatal ? 'fatal' : 'non-fatal'} error'
      '${context == null ? '' : ' [$context]'}: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }
}
