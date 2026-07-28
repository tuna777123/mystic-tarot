import 'dart:async';

import 'package:flutter/foundation.dart';

/// Stable product events used across the application.
///
/// Keep names backwards compatible once a production backend is connected.
enum MysticAnalyticsEvent {
  appOpened,
  onboardingCompleted,
  readingStarted,
  readingCompleted,
  journalViewed,
  premiumViewed,
  purchaseStarted,
  purchaseCompleted,
  purchaseRestored,
  memorySearchUsed,
  insightViewed,
}

extension MysticAnalyticsEventName on MysticAnalyticsEvent {
  String get value => switch (this) {
        MysticAnalyticsEvent.appOpened => 'app_opened',
        MysticAnalyticsEvent.onboardingCompleted => 'onboarding_completed',
        MysticAnalyticsEvent.readingStarted => 'reading_started',
        MysticAnalyticsEvent.readingCompleted => 'reading_completed',
        MysticAnalyticsEvent.journalViewed => 'journal_viewed',
        MysticAnalyticsEvent.premiumViewed => 'premium_viewed',
        MysticAnalyticsEvent.purchaseStarted => 'purchase_started',
        MysticAnalyticsEvent.purchaseCompleted => 'purchase_completed',
        MysticAnalyticsEvent.purchaseRestored => 'purchase_restored',
        MysticAnalyticsEvent.memorySearchUsed => 'memory_search_used',
        MysticAnalyticsEvent.insightViewed => 'insight_viewed',
      };
}

abstract interface class MysticAnalyticsSink {
  Future<void> track(
    String eventName, {
    Map<String, Object?> properties = const {},
  });
}

/// Safe default used until a production analytics provider is configured.
final class DebugMysticAnalyticsSink implements MysticAnalyticsSink {
  const DebugMysticAnalyticsSink();

  @override
  Future<void> track(
    String eventName, {
    Map<String, Object?> properties = const {},
  }) async {
    if (kDebugMode) {
      debugPrint('[analytics] $eventName $properties');
    }
  }
}

/// Privacy-first analytics facade.
///
/// Personally identifying text, journal content and card reflections must never
/// be passed through [properties]. Only coarse product metadata is accepted.
final class MysticAnalytics {
  MysticAnalytics._();

  static final MysticAnalytics instance = MysticAnalytics._();

  MysticAnalyticsSink _sink = const DebugMysticAnalyticsSink();
  bool _enabled = true;
  String? _sessionId;

  void configure({
    required MysticAnalyticsSink sink,
    bool enabled = true,
    String? sessionId,
  }) {
    _sink = sink;
    _enabled = enabled;
    _sessionId = sessionId;
  }

  void setEnabled(bool value) => _enabled = value;

  Future<void> track(
    MysticAnalyticsEvent event, {
    Map<String, Object?> properties = const {},
  }) async {
    if (!_enabled) return;

    final sanitized = <String, Object?>{
      if (_sessionId != null) 'session_id': _sessionId,
      ..._sanitize(properties),
    };

    try {
      await _sink.track(event.value, properties: sanitized);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[analytics-error] $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Map<String, Object?> _sanitize(Map<String, Object?> input) {
    const blockedFragments = {
      'name',
      'email',
      'phone',
      'journal',
      'reflection',
      'question',
      'answer',
      'message',
      'content',
      'text',
    };

    final output = <String, Object?>{};
    for (final entry in input.entries) {
      final key = entry.key.toLowerCase();
      if (blockedFragments.any(key.contains)) continue;

      final value = entry.value;
      if (value == null || value is num || value is bool) {
        output[entry.key] = value;
      } else if (value is String && value.length <= 64) {
        output[entry.key] = value;
      }
    }
    return output;
  }
}
