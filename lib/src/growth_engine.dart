import 'models.dart';

enum MysticGrowthStage { newUser, activated, engaged, habit, powerUser }

enum MysticNextActionType {
  firstReading,
  dailyReading,
  mirrorCheckIn,
  continueJourney,

  /// Legacy enum name retained for source compatibility. In the current
  /// advertising-only product this means "explore a deeper spread"; it does
  /// not imply a paid unlock.
  explorePremiumSpread,

  /// Opens the private Journal. When a durable pattern exists this reviews the
  /// pattern; immediately after the very first reading it reviews the saved
  /// reading and reinforces the 24-hour Mystic Mirror return instead of
  /// pushing the user into more content.
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

  /// Legacy field name retained for compatibility with earlier releases.
  /// The value now represents continuity maturity, not willingness to pay,
  /// entitlement, prediction accuracy, or completed-Mirror evidence.
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
    final score = _continuityValueScore(
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
    required int mirrorDueCount,
    required bool visiblePattern,
    required DateTime now,
  }) {
    if (records.isEmpty) {
      return const MysticNextAction(
        type: MysticNextActionType.firstReading,
        title: 'Your first signal is waiting',
        body:
            'Begin with one focused question. The useful part is what you can compare with reality later.',
        cta: 'Start my first reading',
        priority: 100,
      );
    }

    if (mirrorDueCount > 0) {
      return MysticNextAction(
        type: MysticNextActionType.mirrorCheckIn,
        title: mirrorDueCount == 1
            ? 'Yesterday is ready for reality'
            : '$mirrorDueCount readings are ready for reality',
        body:
            'Close the 24-hour loop before adding more input. Honest follow-up turns a reading into private evidence.',
        cta: 'Complete my Mirror',
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
            'A brief return keeps your private pattern history alive without turning reflection into work.',
        cta: 'Reveal today’s card',
        priority: 95,
      );
    }

    if (records.length == 1 && completedArcanaDays == 0) {
      return const MysticNextAction(
        type: MysticNextActionType.reviewPattern,
        title: 'Your first reading is saved',
        body:
            'You are done for today. Review the grounded action if you want; the useful next step is tomorrow’s Mystic Mirror.',
        cta: 'Review my saved reading',
        priority: 92,
      );
    }

    if (visiblePattern) {
      return const MysticNextAction(
        type: MysticNextActionType.reviewPattern,
        title: 'A repeating pattern is becoming visible',
        body:
            'Compare the cards, emotions, and choices that keep returning across your private history.',
        cta: 'View my pattern',
        priority: 90,
      );
    }

    if (completedArcanaDays < 22 && completedArcanaDays < records.length) {
      return MysticNextAction(
        type: MysticNextActionType.continueJourney,
        title: 'Your next Arcana chapter is ready',
        body:
            '${22 - completedArcanaDays} chapters remain. Continue only if today has room for another reflection.',
        cta: 'Continue my path',
        priority: 80,
      );
    }

    return const MysticNextAction(
      type: MysticNextActionType.explorePremiumSpread,
      title: 'Go deeper only when the question needs it',
      body:
          'Use a larger spread for context, not because the app needs another tap.',
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

  String _returnMessage(MysticReturnState state, int streak) {
    switch (state) {
      case MysticReturnState.firstVisit:
        return 'Your path begins with one honest question.';
      case MysticReturnState.activeToday:
        return 'Today’s signal is already part of your evidence trail.';
      case MysticReturnState.returnedNextDay:
        return 'You came back at the moment yesterday can be compared with reality.';
      case MysticReturnState.continuingStreak:
        return 'Your $streak-day practice is building continuity, not just a streak.';
      case MysticReturnState.resumedPath:
        return 'Your private history kept its place. Continue from where you left it.';
    }
  }

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

  int _continuityValueScore({
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

  int _activeDayCount(List<ReadingRecord> records) {
    return records
        .map((record) => _calendarDayKey(record.createdAt))
        .toSet()
        .length;
  }

  int _calendarDayDifference(DateTime earlier, DateTime later) {
    final earlierDay = DateTime(earlier.year, earlier.month, earlier.day);
    final laterDay = DateTime(later.year, later.month, later.day);
    return laterDay.difference(earlierDay).inDays;
  }

  String _calendarDayKey(DateTime value) {
    return '${value.year}-${value.month}-${value.day}';
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
