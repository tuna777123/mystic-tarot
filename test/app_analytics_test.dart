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
        'theme': 'career',
      },
    );

    expect(sink.properties.containsKey('journal_text'), isFalse);
    expect(sink.properties.containsKey('reflection'), isFalse);
    expect(sink.properties['theme'], 'career');
  });

  test('does not call sink when disabled', () async {
    final sink = _RecordingSink();
    MysticAnalytics.instance.configure(sink: sink, enabled: false);

    await MysticAnalytics.instance.track(MysticAnalyticsEvent.appOpened);

    expect(sink.eventName, isNull);
  });
}
