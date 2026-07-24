import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/identity_engine.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

ReadingRecord record({
  required ReadingKind kind,
  EmotionalState emotion = EmotionalState.curious,
  bool reversed = false,
}) =>
    ReadingRecord(
      kind: kind,
      question: 'What should I notice?',
      cards: [DrawnCard(tarotDeck.first, reversed)],
      createdAt: DateTime(2026, 7, 24),
      emotion: emotion,
      alignedAction: 'Take one grounded and honest step today.',
    );

void main() {
  const engine = MysticIdentityEngine();

  test('new users begin as seekers with no false confidence', () {
    final result = engine.analyze(
      records: const [],
      streak: 0,
      completedArcanaDays: 0,
    );

    expect(result.primary, MysticArchetype.seeker);
    expect(result.confidence, 0);
    expect(result.progressToEvolution, 0);
  });

  test('shadow practice develops the alchemist identity', () {
    final result = engine.analyze(
      records: [
        record(kind: ReadingKind.shadow, emotion: EmotionalState.anxious),
        record(kind: ReadingKind.spiritual, reversed: true),
        record(kind: ReadingKind.shadow, reversed: true),
      ],
      streak: 1,
      completedArcanaDays: 0,
    );

    expect(result.primary, MysticArchetype.alchemist);
    expect(result.title, 'The Alchemist');
    expect(result.nextEvolution, 'The Sage');
  });

  test('consistent grounded action develops the guardian identity', () {
    final result = engine.analyze(
      records: [
        record(kind: ReadingKind.career, emotion: EmotionalState.grounded),
        record(kind: ReadingKind.money, emotion: EmotionalState.grounded),
      ],
      streak: 7,
      completedArcanaDays: 0,
    );

    expect(result.primary, MysticArchetype.guardian);
    expect(result.progressToEvolution, greaterThan(.4));
  });

  test('deep study and Arcana completion develop the sage identity', () {
    final result = engine.analyze(
      records: [
        record(kind: ReadingKind.timeline),
        record(kind: ReadingKind.celticCross),
      ],
      streak: 2,
      completedArcanaDays: 8,
    );

    expect(result.primary, MysticArchetype.sage);
    expect(result.signals, isNotEmpty);
  });
}
