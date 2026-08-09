import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/growth_engine.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

ReadingRecord record({
  required DateTime createdAt,
  ReadingKind kind = ReadingKind.daily,
  EmotionalState emotion = EmotionalState.curious,
  String cardName = 'The Fool',
}) {
  final card = tarotDeck.firstWhere((item) => item.name == cardName);
  return ReadingRecord(
    kind: kind,
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
    expect(result.returnState, MysticReturnState.firstVisit);
    expect(result.premiumValueScore, 0);
  });

  test(
    'returning users without a due Mirror are directed to daily guidance',
    () {
      final result = engine.analyze(
        records: [record(createdAt: now.subtract(const Duration(days: 1)))],
        streak: 2,
        completedArcanaDays: 1,
        freeReadingsLeft: 0,
        mirrorDueCount: 0,
        now: now,
      );

      expect(result.nextAction.type, MysticNextActionType.dailyReading);
      expect(result.nextAction.priority, 95);
    },
  );

  test('a due Mirror outranks a not-yet-completed daily reading', () {
    final result = engine.analyze(
      records: [record(createdAt: now.subtract(const Duration(days: 2)))],
      streak: 2,
      completedArcanaDays: 1,
      freeReadingsLeft: 3,
      mirrorDueCount: 1,
      now: now,
    );

    expect(result.nextAction.type, MysticNextActionType.mirrorCheckIn);
    expect(result.nextAction.priority, 98);
    expect(result.nextAction.cta, 'Complete my Mirror');
  });

  test('a non-daily reading today never completes the daily return', () {
    final result = engine.analyze(
      records: [record(createdAt: now, kind: ReadingKind.love)],
      streak: 2,
      completedArcanaDays: 1,
      freeReadingsLeft: 2,
      mirrorDueCount: 0,
      now: now,
    );

    expect(result.nextAction.type, MysticNextActionType.dailyReading);
  });

  test('verified due Mirrors outrank journey and pattern suggestions', () {
    final records = [
      record(createdAt: now),
      record(
        createdAt: now.subtract(const Duration(days: 2)),
        cardName: 'The Star',
      ),
      record(
        createdAt: now.subtract(const Duration(days: 3)),
        cardName: 'The Star',
      ),
    ];

    final result = engine.analyze(
      records: records,
      streak: 4,
      completedArcanaDays: 1,
      freeReadingsLeft: 2,
      mirrorDueCount: 2,
      now: now,
    );

    expect(result.nextAction.type, MysticNextActionType.mirrorCheckIn);
    expect(result.nextAction.priority, 98);
  });

  test('earned private patterns surface before another content chapter', () {
    final records = [
      record(createdAt: now, cardName: 'The Star'),
      record(
        createdAt: now.subtract(const Duration(days: 1)),
        cardName: 'The Star',
      ),
      record(
        createdAt: now.subtract(const Duration(days: 2)),
        emotion: EmotionalState.hopeful,
      ),
    ];

    final result = engine.analyze(
      records: records,
      streak: 3,
      completedArcanaDays: 1,
      freeReadingsLeft: 2,
      now: now,
    );

    expect(result.hasVisiblePattern, isTrue);
    expect(result.nextAction.type, MysticNextActionType.reviewPattern);
    expect(result.nextAction.priority, 85);
  });

  test(
    'old readings do not resurface as Mirror tasks without due evidence',
    () {
      final records = [
        record(createdAt: now),
        record(createdAt: now.subtract(const Duration(days: 2))),
      ];

      final result = engine.analyze(
        records: records,
        streak: 2,
        completedArcanaDays: 0,
        freeReadingsLeft: 2,
        mirrorDueCount: 0,
        now: now,
      );

      expect(result.nextAction.type, MysticNextActionType.continueJourney);
    },
  );

  test('deeper-reading fallback contains no paid-tier call to action', () {
    final records = [record(createdAt: now)];

    final result = engine.analyze(
      records: records,
      streak: 1,
      completedArcanaDays: 1,
      freeReadingsLeft: 0,
      mirrorDueCount: 0,
      now: now,
    );

    expect(result.nextAction.type, MysticNextActionType.explorePremiumSpread);
    expect(result.nextAction.cta, 'Explore deep readings');
    expect(result.nextAction.body.toLowerCase(), isNot(contains('premium')));
    expect(result.nextAction.cta.toLowerCase(), isNot(contains('plus')));
  });

  test('repeating cards create a visible pattern and higher value score', () {
    final records = [
      record(createdAt: now, cardName: 'The Star'),
      record(
        createdAt: now.subtract(const Duration(days: 1)),
        cardName: 'The Star',
      ),
      record(
        createdAt: now.subtract(const Duration(days: 2)),
        emotion: EmotionalState.hopeful,
      ),
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

  test('same-day binge use does not masquerade as a durable habit', () {
    final records = List.generate(
      12,
      (index) => record(
        createdAt: now.subtract(Duration(minutes: index * 5)),
        kind: ReadingKind.love,
        cardName: index.isEven ? 'The Star' : 'The Fool',
      ),
    );

    final result = engine.analyze(
      records: records,
      streak: 1,
      completedArcanaDays: 0,
      freeReadingsLeft: 0,
      now: now,
    );

    expect(result.stage, MysticGrowthStage.activated);
    expect(result.premiumValueScore, lessThan(100));
  });

  test(
    'calendar-day return is recognized even when less than 24 hours passed',
    () {
      final afterMidnight = DateTime(2026, 7, 25, 1);
      final result = engine.analyze(
        records: [record(createdAt: DateTime(2026, 7, 24, 23))],
        streak: 2,
        completedArcanaDays: 0,
        freeReadingsLeft: 3,
        now: afterMidnight,
      );

      expect(result.returnState, MysticReturnState.returnedNextDay);
    },
  );

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
