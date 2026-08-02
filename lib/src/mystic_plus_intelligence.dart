import 'models.dart';
import 'mystic_mirror.dart';

class MysticPlusIntelligenceSnapshot {
  const MysticPlusIntelligenceSnapshot({
    required this.generatedAt,
    required this.periodStart,
    required this.readingCount,
    required this.activeDays,
    required this.uniqueCardCount,
    required this.topCardName,
    required this.topCardCount,
    required this.topReadingKind,
    required this.topReadingKindCount,
    required this.dominantStartingEmotion,
    required this.mirrorEligibleCount,
    required this.mirrorCompletedCount,
    required this.mirrorShiftCount,
    required this.emotionalComparisonCount,
    required this.emotionalLiftCount,
  });

  final DateTime generatedAt;
  final DateTime periodStart;
  final int readingCount;
  final int activeDays;
  final int uniqueCardCount;
  final String? topCardName;
  final int topCardCount;
  final ReadingKind? topReadingKind;
  final int topReadingKindCount;
  final EmotionalState? dominantStartingEmotion;
  final int mirrorEligibleCount;
  final int mirrorCompletedCount;
  final int mirrorShiftCount;
  final int emotionalComparisonCount;
  final int emotionalLiftCount;

  bool get hasEnoughHistory => readingCount >= 3;

  int get readingsUntilReady => readingCount >= 3 ? 0 : 3 - readingCount;

  double get mirrorCompletionRate => mirrorEligibleCount == 0
      ? 0
      : mirrorCompletedCount / mirrorEligibleCount;

  double get mirrorShiftRate => mirrorCompletedCount == 0
      ? 0
      : mirrorShiftCount / mirrorCompletedCount;

  double get emotionalLiftRate => emotionalComparisonCount == 0
      ? 0
      : emotionalLiftCount / emotionalComparisonCount;
}

/// Builds a descriptive, local-only seven-day report from reading history.
///
/// The report exposes counts and observed changes. It does not predict future
/// events, diagnose the user, or assign a truth score to tarot interpretations.
abstract final class MysticPlusIntelligence {
  static MysticPlusIntelligenceSnapshot analyze({
    required Iterable<ReadingRecord> records,
    required Map<String, MysticMirrorReflection> reflections,
    required DateTime generatedAt,
    Duration window = const Duration(days: 7),
  }) {
    if (window.inMicroseconds <= 0) {
      throw ArgumentError.value(window, 'window', 'must be positive');
    }

    final periodStart = generatedAt.subtract(window);
    final history = records
        .where(
          (record) =>
              !record.createdAt.isBefore(periodStart) &&
              !record.createdAt.isAfter(generatedAt),
        )
        .toList(growable: false);

    final activeDays = <String>{};
    final uniqueCards = <String>{};
    final cardCounts = <String, int>{};
    final kindCounts = <ReadingKind, int>{};
    final emotionCounts = <EmotionalState, int>{};

    var mirrorEligible = 0;
    var mirrorCompleted = 0;
    var mirrorShifted = 0;
    var emotionalComparisons = 0;
    var emotionalLift = 0;

    for (final record in history) {
      activeDays.add(_dayKey(record.createdAt));
      kindCounts.update(record.kind, (value) => value + 1, ifAbsent: () => 1);
      emotionCounts.update(
        record.emotion,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      for (final drawn in record.cards) {
        uniqueCards.add(drawn.card.name);
        cardCounts.update(
          drawn.card.name,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }

      if (record.mirrorCheckInAt.isAfter(generatedAt)) continue;
      mirrorEligible++;
      final mirror = reflections[mysticMirrorRecordId(record)];
      if (mirror == null) continue;
      mirrorCompleted++;
      if (mirror.outcome == MysticMirrorOutcome.shifted ||
          mirror.outcome == MysticMirrorOutcome.partlyShifted) {
        mirrorShifted++;
      }
      emotionalComparisons++;
      if (_emotionScore(mirror.emotion) > _emotionScore(record.emotion)) {
        emotionalLift++;
      }
    }

    final topCard = _topEntry(cardCounts, (_) => 0);
    final topKind = _topEntry(kindCounts, (value) => value.index);
    final topEmotion = _topEntry(emotionCounts, (value) => value.index);

    return MysticPlusIntelligenceSnapshot(
      generatedAt: generatedAt,
      periodStart: periodStart,
      readingCount: history.length,
      activeDays: activeDays.length,
      uniqueCardCount: uniqueCards.length,
      topCardName: topCard?.key,
      topCardCount: topCard?.value ?? 0,
      topReadingKind: topKind?.key,
      topReadingKindCount: topKind?.value ?? 0,
      dominantStartingEmotion: topEmotion?.key,
      mirrorEligibleCount: mirrorEligible,
      mirrorCompletedCount: mirrorCompleted,
      mirrorShiftCount: mirrorShifted,
      emotionalComparisonCount: emotionalComparisons,
      emotionalLiftCount: emotionalLift,
    );
  }

  static MapEntry<T, int>? _topEntry<T>(
    Map<T, int> counts,
    int Function(T value) tieBreaker,
  ) {
    final entries = counts.entries.toList(growable: false)
      ..sort((first, second) {
        final byCount = second.value.compareTo(first.value);
        if (byCount != 0) return byCount;
        if (first.key is String && second.key is String) {
          return (first.key as String).compareTo(second.key as String);
        }
        return tieBreaker(first.key).compareTo(tieBreaker(second.key));
      });
    return entries.isEmpty ? null : entries.first;
  }

  static int _emotionScore(EmotionalState emotion) => switch (emotion) {
        EmotionalState.anxious => 0,
        EmotionalState.uncertain => 0,
        EmotionalState.curious => 1,
        EmotionalState.hopeful => 2,
        EmotionalState.grounded => 3,
      };

  static String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
