import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_analytics.dart';
import 'package:mystic_tarot/src/app_analytics_bindings.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

final class _RecordingSink implements MysticAnalyticsSink {
  final events = <String>[];
  final payloads = <Map<String, Object?>>[];

  @override
  Future<void> track(
    String eventName, {
    Map<String, Object?> properties = const {},
  }) async {
    events.add(eventName);
    payloads.add(properties);
  }
}

void main() {
  late _RecordingSink sink;
  late MysticAnalyticsBindings bindings;

  setUp(() {
    sink = _RecordingSink();
    MysticAnalytics.instance.configure(sink: sink);
    bindings = const MysticAnalyticsBindings();
  });

  test('tracks reading start with stable coarse metadata', () async {
    await bindings.readingStarted(ReadingKind.daily);

    expect(sink.events.single, 'reading_started');
    expect(sink.payloads.single, {
      'reading_kind': 'daily',
      'card_count': ReadingKind.daily.cardCount,
    });
  });

  test('reading completion excludes question and journal content', () async {
    final record = ReadingRecord(
      kind: ReadingKind.daily,
      question: 'private question',
      cards: [DrawnCard(tarotDeck.first, false)],
      createdAt: DateTime(2026, 7, 29),
      emotion: EmotionalState.curious,
      alignedAction: 'private reflection',
    );

    await bindings.readingCompleted(
      record,
      elapsed: const Duration(seconds: 42),
    );

    expect(sink.events.single, 'reading_completed');
    expect(sink.payloads.single, {
      'reading_kind': 'daily',
      'card_count': 1,
      'duration_seconds': 42,
    });
    expect(sink.payloads.single.containsKey('question'), isFalse);
    expect(sink.payloads.single.containsKey('aligned_action'), isFalse);
  });

  test('tracks journal and premium attribution without content', () async {
    await bindings.journalViewed(savedReadingCount: 7);
    await bindings.premiumViewed(source: 'daily_limit');

    expect(sink.events, ['journal_viewed', 'premium_viewed']);
    expect(sink.payloads, [
      {'saved_reading_count': 7},
      {'source': 'daily_limit'},
    ]);
  });

  test('tracks completion only with coarse verified purchase metadata', () async {
    await bindings.purchaseCompleted(
      source: 'store_checkout',
      plan: 'mystic_plus_yearly',
      restored: false,
    );

    expect(sink.events.single, 'purchase_completed');
    expect(sink.payloads.single, {
      'source': 'store_checkout',
      'plan': 'mystic_plus_yearly',
      'restored': false,
    });
  });
}
