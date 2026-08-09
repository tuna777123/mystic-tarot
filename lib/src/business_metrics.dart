import 'dart:async';

import 'package:flutter/foundation.dart';

enum MysticBusinessEvent {
  appOpened,
  onboardingCompleted,
  readingCompleted,
  mirrorDueSeen,
  mirrorWindowMatured,
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
/// Both dimension names and values are constrained to small coarse
/// vocabularies. This prevents private Mystic content from being smuggled into
/// an otherwise allow-listed field such as `source`.
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

  static const allowedValues = <String, Set<String>>{
    'language': <String>{
      'EN',
      'TR',
      'ES',
      'FR',
      'PT-BR',
      'en',
      'tr',
      'es',
      'fr',
      'pt-BR',
    },
    'platform': <String>{
      'android',
      'ios',
      'web',
      'macos',
      'windows',
      'linux',
      'fuchsia',
    },
    'reading_kind': <String>{
      'daily',
      'love',
      'career',
      'money',
      'decision',
      'spiritual',
      'shadow',
      'compatibility',
      'timeline',
      'celticCross',
    },
    'growth_stage': <String>{
      'within_72h',
      'after_72h',
      'completed_within_72h',
      'not_completed_within_72h',
    },
    'ad_format': <String>{'app_open', 'interstitial'},
    'source': <String>{
      'launch',
      'foreground',
      'onboarding',
      'journal_store',
      'living_journal',
      'mirror',
      'mirror_due_state',
      'mirror_window',
      'reading_completion',
      'reminder',
      'settings',
    },
  };

  static MysticBusinessMetricReporter _reporter = _debugReporter;

  static void configure({MysticBusinessMetricReporter? reporter}) {
    _reporter = reporter ?? _debugReporter;
  }

  static Future<void> record(
    MysticBusinessEvent event, {
    Map<String, String> dimensions = const <String, String>{},
  }) async {
    await tryRecord(event, dimensions: dimensions);
  }

  /// Returns whether the reporter accepted the event, while still keeping
  /// observability failures isolated from product behavior.
  ///
  /// This is used only when a local dedupe marker must not advance until the
  /// aggregate event is durably accepted. Normal product flows should call
  /// [record].
  static Future<bool> tryRecord(
    MysticBusinessEvent event, {
    Map<String, String> dimensions = const <String, String>{},
  }) async {
    final safe = validateDimensions(dimensions);
    try {
      await _reporter(event, safe);
      return true;
    } catch (error, stackTrace) {
      // Metrics are an observability side effect, never a product dependency.
      // A reporter outage must not block reading, Mirror, sharing or ads.
      if (kDebugMode) {
        debugPrint('Mystic metric reporter failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      return false;
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
      final vocabulary = allowedValues[key];
      if (vocabulary == null || !vocabulary.contains(value)) {
        throw ArgumentError.value(
          entry.value,
          'dimensions',
          'Metric value is not part of the approved coarse vocabulary for $key.',
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
