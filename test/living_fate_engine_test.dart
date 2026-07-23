import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/living_fate_engine.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

void main() {
  TarotCardData card(String name) => tarotDeck.firstWhere((item) => item.name == name);

  ReadingRecord record({
    required DateTime at,
    required String cardName,
    bool reversed = false,
    EmotionalState emotion = EmotionalState.curious,
    ReadingKind kind = ReadingKind.daily,
  }) =>
      ReadingRecord(
        kind: kind,
        question: 'Test question',
        cards: [DrawnCard(card(cardName), reversed)],
        createdAt: at,
        emotion: emotion,
        alignedAction: 'Test action',
      );

  test('sorts recurring cards and tracks reversed appearances', () {
    final snapshot = const LivingFateEngine().analyze([
      record(at: DateTime(2026, 7, 20), cardName: 'The Moon', reversed: true),
      record(at: DateTime(2026, 7, 21), cardName: 'The Star'),
      record(at: DateTime(2026, 7, 22), cardName: 'The Moon'),
    ], now: DateTime(2026, 7, 24));

    expect(snapshot.totalReadings, 3);
    expect(snapshot.mostRecurringCard?.cardName, 'The Moon');
    expect(snapshot.mostRecurringCard?.count, 2);
    expect(snapshot.mostRecurringCard?.reversedCount, 1);
    expect(snapshot.mostRecurringCard?.reversedRatio, .5);
  });

  test('builds chronological primary-card transitions', () {
    final snapshot = const LivingFateEngine().analyze([
      record(at: DateTime(2026, 7, 22), cardName: 'The Star'),
      record(at: DateTime(2026, 7, 20), cardName: 'The Moon'),
      record(at: DateTime(2026, 7, 21), cardName: 'The Sun'),
    ], now: DateTime(2026, 7, 24));

    expect(snapshot.transitions, hasLength(2));
    expect(snapshot.transitions.first.from, 'The Moon');
    expect(snapshot.transitions.first.to, 'The Sun');
  });

  test('detects dominant emotion, reading kind, and due check-ins', () {
    final snapshot = const LivingFateEngine().analyze([
      record(
        at: DateTime(2026, 7, 20),
        cardName: 'The Moon',
        emotion: EmotionalState.anxious,
        kind: ReadingKind.love,
      ),
      record(
        at: DateTime(2026, 7, 22),
        cardName: 'The Star',
        emotion: EmotionalState.anxious,
        kind: ReadingKind.love,
      ),
      record(
        at: DateTime(2026, 7, 24, 12),
        cardName: 'The Sun',
        emotion: EmotionalState.hopeful,
      ),
    ], now: DateTime(2026, 7, 24, 13));

    expect(snapshot.dominantEmotion, EmotionalState.anxious);
    expect(snapshot.dominantReadingKind, ReadingKind.love);
    expect(snapshot.dueCheckIns, hasLength(2));
  });

  test('returns an empty, safe snapshot for new users', () {
    final snapshot = const LivingFateEngine().analyze(const []);

    expect(snapshot.totalReadings, 0);
    expect(snapshot.frequencies, isEmpty);
    expect(snapshot.transitions, isEmpty);
    expect(snapshot.dueCheckIns, isEmpty);
    expect(snapshot.mostRecurringCard, isNull);
    expect(snapshot.dominantEmotion, isNull);
  });
}