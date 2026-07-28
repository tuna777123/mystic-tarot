import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_analytics.dart';

final class _RecordingSink implements MysticAnalyticsSink {
  String? eventName;
  Map<String, Object?> properties = const {};

  @override
  Future<void> track(
    String eventName, {
    Map<String, Object?> properties = const {},
  }) async {
    this.eventName = eventName;
    this.properties = properties;
  }
}

void main() {
  test('keeps launch-critical event names stable', () {
    expect(
      MysticAnalyticsEvent.values.map((event) => event.value),
      const [
        'app_opened',
        'onboarding_completed',
        'reading_started',
        'reading_completed',
        'journal_viewed',
        'premium_viewed',
        'purchase_started',
        'purchase_completed',
        'purchase_restored',
        'memory_search_used',
        'insight_viewed',
      ],
    );
  });

  test('tracks stable event names and safe metadata', () async {
    final sink = _RecordingSink();
    MysticAnalytics.instance.configure(
      sink: sink,
      sessionId: 'session-1',
    );

    await MysticAnalytics.instance.track(
      MysticAnalyticsEvent.readingCompleted,
      properties: const {
        'reading_kind': 'daily',
        'card_count': 1,
      },
    );

    expect(sink.eventName, 'reading_completed');
    expect(sink.properties['session_id'], 'session-1');
    expect(sink.properties['reading_kind'], 'daily');
    expect(sink.properties['card_count'], 1);
  });

  test('removes sensitive free-text properties', () async {
    final sink = _RecordingSink();
    MysticAnalytics.instance.configure(sink: sink);

    await MysticAnalytics.instance.track(
      MysticAnalyticsEvent.insightViewed,
      properties: const {
        'journal_text': 'private entry',
        'reflection': 'private reflection',
        'user_name': 'private name',
        'question_category': 'private question',
        'theme': 'career',
      },
    );

    expect(sink.properties.containsKey('journal_text'), isFalse);
    expect(sink.properties.containsKey('reflection'), isFalse);
    expect(sink.properties.containsKey('user_name'), isFalse);
    expect(sink.properties.containsKey('question_category'), isFalse);
    expect(sink.properties['theme'], 'career');
  });

  test('rejects oversized strings and complex values', () async {
    final sink = _RecordingSink();
    MysticAnalytics.instance.configure(sink: sink);

    await MysticAnalytics.instance.track(
      MysticAnalyticsEvent.premiumViewed,
      properties: {
        'source': 'daily_limit',
        'oversized': 'x' * 65,
        'cards': const ['sun', 'moon'],
        'metadata': const {'plan': 'annual'},
      },
    );

    expect(sink.properties['source'], 'daily_limit');
    expect(sink.properties.containsKey('oversized'), isFalse);
    expect(sink.properties.containsKey('cards'), isFalse);
    expect(sink.properties.containsKey('metadata'), isFalse);
  });

  test('does not call sink when disabled', () async {
    final sink = _RecordingSink();
    MysticAnalytics.instance.configure(sink: sink, enabled: false);

    await MysticAnalytics.instance.track(MysticAnalyticsEvent.appOpened);

    expect(sink.eventName, isNull);
  });
}
