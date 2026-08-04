import 'models.dart';

enum MysticGrowthStage {
  newUser,
  activated,
  engaged,
  habit,
  powerUser,
}

enum MysticNextActionType {
  firstReading,
  dailyReading,
  mirrorCheckIn,
  continueJourney,
  explorePremiumSpread,
  reviewPattern,
}

enum MysticReturnState {
  firstVisit,
  activeToday,
  returnedNextDay,
  continuingStreak,
  resumedPath,
}

class MysticNextAction {
  const MysticNextAction({
    required this.type,
    required this.title,
    required this.body,
    required this.cta,
    required this.priority,
  });

  final MysticNextActionType type;
  final String title;
  final String body;
  final String cta;
  final int priority;
}

class MysticGrowthSnapshot {
  const MysticGrowthSnapshot({
    required this.stage,
    required this.nextAction,
    required this.returnState,
    required this.returnMessage,
    required this.premiumValueScore,
    required this.hasVisiblePattern,
  });

  final MysticGrowthStage stage;
  final MysticNextAction nextAction;
  final MysticReturnState returnState;
  final String returnMessage;
  final int premiumValueScore;
  final bool hasVisiblePattern;
}

class MysticGrowthEngine {
  const MysticGrowthEngine();

  MysticGrowthSnapshot analyze({
    required List<ReadingRecord> records,
    required int streak,
    required int completedArcanaDays,
    required int freeReadingsLeft,
    int mirrorDueCount = 0,
    DateTime? now,
  }) {
    final moment = now ?? DateTime.now();
    final stage = _stage(
      records: records,
      streak: streak,
      completedArcanaDays: completedArcanaDays,
    );
    final visiblePattern = _hasVisiblePattern(records);
    final returnState = _returnState(records, streak, moment);
    final score = _premiumValueScore(
      records: records,
      streak: streak,
      completedArcanaDays: completedArcanaDays,
      visiblePattern: visiblePattern,
    );

    return MysticGrowthSnapshot(
      stage: stage,
      nextAction: _nextAction(
        records: records,
        streak: streak,
        completedArcanaDays: completedArcanaDays,
        freeReadingsLeft: freeReadingsLeft,
        mirrorDueCount: mirrorDueCount,
        visiblePattern: visiblePattern,
        now: moment,
      ),
      returnState: returnState,
      returnMessage: _returnMessage(returnState, streak),
      premiumValueScore: score,
      hasVisiblePattern: visiblePattern,
    );
  }

  MysticGrowthStage _stage({
    required List<ReadingRecord> records,
    required int streak,
    required int completedArcanaDays,
  }) {
    final readings = records.length;
    if (readings == 0) return MysticGrowthStage.newUser;

    final activeDays = _activeDayCount(records);
    if (readings < 3 || activeDays < 2) {
      return MysticGrowthStage.activated;
    }
    if (readings < 8 || activeDays < 4 || streak < 3) {
      return MysticGrowthStage.engaged;
    }
    if (readings < 20 ||
        activeDays < 10 ||
        streak < 7 ||
        completedArcanaDays < 5) {
      return MysticGrowthStage.habit;
    }
    return MysticGrowthStage.powerUser;
  }

  MysticNextAction _nextAction({
    required List<ReadingRecord> records,
    required int streak,
    required int completedArcanaDays,
    required int freeReadingsLeft,
    required int mirrorDueCount,
    required bool visiblePattern,
    required DateTime now,
  }) {
    if (records.isEmpty) {
      return const MysticNextAction(
        type: MysticNextActionType.firstReading,
        title: 'Your first signal is waiting',
        body:
            'Begin with one focused question. Mystic becomes more useful as your history grows.',
        cta: 'Start my first reading',
        priority: 100,
      );
    }

    final dailyReadToday = records.any(
      (record) =>
          record.kind == ReadingKind.daily && _sameDay(record.createdAt, now),
    );
    if (!dailyReadToday) {
      return MysticNextAction(
        type: MysticNextActionType.dailyReading,
        title: streak > 0
            ? 'Protect your $streak-day rhythm'
            : 'Open today’s guidance',
        body:
            'A sixty-second return keeps your pattern map alive without turning the ritual into work.',
        cta: 'Reveal today’s card',
        priority: 95,
      );
    }

    if (mirrorDueCount > 0) {
      return const MysticNextAction(
        type: MysticNextActionType.mirrorCheckIn,
        title: 'What actually changed?',
        body:
            'Close the loop on a recent reading and teach Mystic which guidance became real.',
        cta: 'Complete my Mirror',
        priority: 90,
      );
    }

    // Mystic's strongest differentiator is evidence gathered from the user's
    // own private history. Surface that earned value before sending an engaged
    // user into another content loop or an upgrade path.
    if (visiblePattern) {
      return const MysticNextAction(
        type: MysticNextActionType.reviewPattern,
        title: 'A repeating pattern is becoming visible',
        body:
            'Compare the symbol, emotion, and choice that keep returning across your readings.',
        cta: 'View my pattern',
        priority: 85,
      );
    }

    if (completedArcanaDays < 22 && completedArcanaDays < records.length) {
      return MysticNextAction(
        type: MysticNextActionType.continueJourney,
        title: 'Your next Arcana chapter is ready',
        body:
            '${22 - completedArcanaDays} chapters remain in your personal path.',
        cta: 'Continue my journey',
        priority: 80,
      );
    }

    if (freeReadingsLeft == 0) {
      return const MysticNextAction(
        type: MysticNextActionType.explorePremiumSpread,
        title: 'Go deeper without breaking the moment',
        body:
            'Your daily free practice is complete. Premium spreads continue the same private story.',
        cta: 'Explore Mystic Plus',
        priority: 70,
      );
    }

    return const MysticNextAction(
      type: MysticNextActionType.explorePremiumSpread,
      title: 'Ask the question beneath the question',
      body: 'Use a deeper spread when a simple answer no longer feels honest.',
      cta: 'Explore deep readings',
      priority: 60,
    );
  }

  MysticReturnState _returnState(
    List<ReadingRecord> records,
    int streak,
    DateTime now,
  ) {
    if (records.isEmpty) return MysticReturnState.firstVisit;
    final latest = records.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );
    final days = _calendarDayDifference(latest.createdAt, now);
    if (days <= 0) return MysticReturnState.activeToday;
    if (days == 1) return MysticReturnState.returnedNextDay;
    if (streak >= 3) return MysticReturnState.continuingStreak;
    return MysticReturnState.resumedPath;
  }

  String _returnMessage(MysticReturnState state, int streak) => switch (state) {
        MysticReturnState.firstVisit =>
          'Your path begins with one honest question.',
        MysticReturnState.activeToday =>
          'Today’s signal is already part of your story.',
        MysticReturnState.returnedNextDay =>
          'You returned before yesterday’s insight went quiet.',
        MysticReturnState.continuingStreak =>
          'Your $streak-day practice is building real continuity.',
        MysticReturnState.resumedPath =>
          'Your path kept its place. Continue from where you left it.',
      };

  bool _hasVisiblePattern(List<ReadingRecord> records) {
    if (records.length < 3) return false;
    final cards = <String, int>{};
    final emotions = <EmotionalState, int>{};
    for (final record in records) {
      emotions.update(record.emotion, (value) => value + 1, ifAbsent: () => 1);
      for (final drawn in record.cards) {
        cards.update(drawn.card.name, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return cards.values.any((count) => count >= 2) ||
        emotions.values.any((count) => count >= 3);
  }

  int _premiumValueScore({
    required List<ReadingRecord> records,
    required int streak,
    required int completedArcanaDays,
    required bool visiblePattern,
  }) {
    final activeDays = _activeDayCount(records);
    var score =
        records.length.clamp(0, 12) * 3 +
        activeDays.clamp(0, 14) * 5 +
        streak.clamp(0, 14) * 4 +
        completedArcanaDays.clamp(0, 22) * 3;
    if (visiblePattern) score += 20;
    return score.clamp(0, 100);
  }

  int _activeDayCount(List<ReadingRecord> records) => records
      .map((record) => _calendarDayKey(record.createdAt))
      .toSet()
      .length;

  int _calendarDayDifference(DateTime earlier, DateTime later) {
    final earlierDay = DateTime(earlier.year, earlier.month, earlier.day);
    final laterDay = DateTime(later.year, later.month, later.day);
    return laterDay.difference(earlierDay).inDays;
  }

  String _calendarDayKey(DateTime value) =>
      '${value.year}-${value.month}-${value.day}';

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
