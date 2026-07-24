import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/growth_engine.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

ReadingRecord record({
  required DateTime createdAt,
  EmotionalState emotion = EmotionalState.curious,
  String cardName = 'The Fool',
}) {
  final card = tarotDeck.firstWhere((item) => item.name == cardName);
  return ReadingRecord(
    kind: ReadingKind.daily,
    question: 'What should I notice?',
    cards: [DrawnCard(card, false)],
    createdAt: createdAt,
    emotion: emotion,
    alignedAction: 'Take one honest step.',
  );
}

void main() {
  const engine = MysticGrowthEngine();
  final now = DateTime(2026, 7, 24, 18);

  test('new users are directed to the first reading', () {
    final result = engine.analyze(
      records: const [],
      streak: 0,
      completedArcanaDays: 0,
      freeReadingsLeft: 3,
      now: now,
    );

    expect(result.stage, MysticGrowthStage.newUser);
    expect(result.nextAction.type, MysticNextActionType.firstReading);
    expect(result.premiumValueScore, 0);
  });

  test('returning users are directed to daily guidance before upsell', () {
    final result = engine.analyze(
      records: [record(createdAt: now.subtract(const Duration(days: 1)))],
      streak: 2,
      completedArcanaDays: 1,
      freeReadingsLeft: 0,
      now: now,
    );

    expect(result.nextAction.type, MysticNextActionType.dailyReading);
    expect(result.nextAction.priority, 95);
  });

  test('repeating cards create a visible pattern and higher value score', () {
    final records = [
      record(createdAt: now, cardName: 'The Star'),
      record(createdAt: now.subtract(const Duration(days: 1)), cardName: 'The Star'),
      record(createdAt: now.subtract(const Duration(days: 2)), emotion: EmotionalState.hopeful),
    ];

    final result = engine.analyze(
      records: records,
      streak: 3,
      completedArcanaDays: 3,
      freeReadingsLeft: 2,
      now: now,
    );

    expect(result.hasVisiblePattern, isTrue);
    expect(result.premiumValueScore, greaterThanOrEqualTo(50));
  });

  test('habit stage requires meaningful repeated use', () {
    final records = List.generate(
      10,
      (index) => record(createdAt: now.subtract(Duration(days: index))),
    );

    final result = engine.analyze(
      records: records,
      streak: 5,
      completedArcanaDays: 4,
      freeReadingsLeft: 1,
      now: now,
    );

    expect(result.stage, MysticGrowthStage.habit);
  });
}
