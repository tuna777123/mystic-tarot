import 'dart:async';

import 'package:flutter/foundation.dart';

enum MysticBusinessEvent {
  appOpened,
  onboardingCompleted,
  readingCompleted,
  mirrorDueSeen,
  mirrorCompleted,
  mirrorShareStarted,
  ritualReminderEnabled,
  adOpportunity,
  adImpression,
}

typedef MysticBusinessMetricReporter =
    FutureOr<void> Function(
      MysticBusinessEvent event,
      Map<String, String> dimensions,
    );

/// Privacy-safe product analytics boundary.
///
/// This contract intentionally accepts only a small allow-list of coarse
/// dimensions. Private Mystic content must never enter growth telemetry.
/// A remote aggregate reporter can be connected later without changing product
/// flows or relaxing this privacy boundary.
class MysticBusinessMetrics {
  MysticBusinessMetrics._();

  static const allowedDimensions = <String>{
    'language',
    'platform',
    'reading_kind',
    'growth_stage',
    'ad_format',
    'source',
  };

  static const forbiddenDimensionFragments = <String>{
    'question',
    'note',
    'card',
    'name',
    'intention',
    'journal',
    'emotion',
    'outcome',
    'text',
    'pin',
    'query',
  };

  static MysticBusinessMetricReporter _reporter = _debugReporter;

  static void configure({MysticBusinessMetricReporter? reporter}) {
    _reporter = reporter ?? _debugReporter;
  }

  static Future<void> record(
    MysticBusinessEvent event, {
    Map<String, String> dimensions = const <String, String>{},
  }) async {
    final safe = validateDimensions(dimensions);
    try {
      await _reporter(event, safe);
    } catch (error, stackTrace) {
      // Metrics are an observability side effect, never a product dependency.
      // A remote reporter outage must not block reading, Mirror, sharing or ads.
      if (kDebugMode) {
        debugPrint('Mystic metric reporter failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  static Map<String, String> validateDimensions(Map<String, String> values) {
    final result = <String, String>{};
    for (final entry in values.entries) {
      final key = entry.key.trim().toLowerCase();
      if (!allowedDimensions.contains(key)) {
        throw ArgumentError.value(
          entry.key,
          'dimensions',
          'Business metric dimension is not allow-listed.',
        );
      }
      if (forbiddenDimensionFragments.any(key.contains)) {
        throw ArgumentError.value(
          entry.key,
          'dimensions',
          'Private Mystic content cannot be used as a metric dimension.',
        );
      }
      final value = entry.value.trim();
      if (value.isEmpty || value.length > 64) {
        throw ArgumentError.value(
          entry.value,
          'dimensions',
          'Metric values must contain 1–64 characters.',
        );
      }
      result[key] = value;
    }
    return Map<String, String>.unmodifiable(result);
  }

  static void _debugReporter(
    MysticBusinessEvent event,
    Map<String, String> dimensions,
  ) {
    if (!kDebugMode) return;
    debugPrint('Mystic metric ${event.name}: $dimensions');
  }
}
