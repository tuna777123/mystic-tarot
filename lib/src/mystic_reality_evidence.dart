import 'models.dart';
import 'mystic_mirror.dart';

/// Descriptive, local-only evidence derived from completed Mystic Mirror
/// check-ins. This deliberately avoids any notion of prediction accuracy.
class MysticRealityEvidenceSnapshot {
  const MysticRealityEvidenceSnapshot({
    required this.eligibleReadingCount,
    required this.completedMirrorCount,
    required this.outcomeCounts,
    required this.emotionTransitionCounts,
    required this.generatedAt,
  });

  static const minimumCompletedMirrorsForPatterns = 3;

  final int eligibleReadingCount;
  final int completedMirrorCount;
  final Map<MysticMirrorOutcome, int> outcomeCounts;
  final Map<EmotionTransition, int> emotionTransitionCounts;
  final DateTime generatedAt;

  bool get hasEnoughEvidence =>
      completedMirrorCount >= minimumCompletedMirrorsForPatterns;

  double get completionRate => eligibleReadingCount == 0
      ? 0
      : completedMirrorCount / eligibleReadingCount;

  int countFor(MysticMirrorOutcome outcome) => outcomeCounts[outcome] ?? 0;

  List<OutcomeEvidence> get rankedOutcomes {
    final rows = MysticMirrorOutcome.values
        .map(
          (outcome) => OutcomeEvidence(
            outcome: outcome,
            count: countFor(outcome),
          ),
        )
        .where((row) => row.count > 0)
        .toList(growable: false);
    return rows.toList()
      ..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        return byCount != 0
            ? byCount
            : a.outcome.index.compareTo(b.outcome.index);
      });
  }

  List<EmotionTransitionEvidence> get rankedEmotionTransitions {
    final rows = emotionTransitionCounts.entries
        .map(
          (entry) => EmotionTransitionEvidence(
            transition: entry.key,
            count: entry.value,
          ),
        )
        .toList(growable: false);
    return rows.toList()
      ..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        if (byCount != 0) return byCount;
        final from = a.transition.from.index.compareTo(b.transition.from.index);
        return from != 0
            ? from
            : a.transition.to.index.compareTo(b.transition.to.index);
      });
  }
}

class OutcomeEvidence {
  const OutcomeEvidence({required this.outcome, required this.count});

  final MysticMirrorOutcome outcome;
  final int count;
}

class EmotionTransition {
  const EmotionTransition({required this.from, required this.to});

  final EmotionalState from;
  final EmotionalState to;

  bool get changed => from != to;

  @override
  bool operator ==(Object other) =>
      other is EmotionTransition && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

class EmotionTransitionEvidence {
  const EmotionTransitionEvidence({
    required this.transition,
    required this.count,
  });

  final EmotionTransition transition;
  final int count;
}

/// Computes transparent observations from the reading -> 24h Mirror loop.
///
/// Every Mirror outcome is treated as valid evidence. In particular,
/// `unchanged` and `unclear` are never scored as failures. The engine does not
/// calculate, expose, or imply prediction accuracy and does not upload data.
abstract final class MysticRealityEvidence {
  static MysticRealityEvidenceSnapshot analyze({
    required Iterable<ReadingRecord> readings,
    required Map<String, MysticMirrorReflection> reflections,
    required DateTime generatedAt,
  }) {
    final history = readings.toList(growable: false);
    final outcomes = <MysticMirrorOutcome, int>{};
    final transitions = <EmotionTransition, int>{};
    var eligible = 0;
    var completed = 0;

    for (final reading in history) {
      if (generatedAt.isBefore(reading.mirrorCheckInAt)) continue;
      eligible++;

      final mirror = reflections[mysticMirrorRecordId(reading)];
      if (mirror == null) continue;
      completed++;
      outcomes.update(
        mirror.outcome,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      final transition = EmotionTransition(
        from: reading.emotion,
        to: mirror.emotion,
      );
      transitions.update(
        transition,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    return MysticRealityEvidenceSnapshot(
      eligibleReadingCount: eligible,
      completedMirrorCount: completed,
      outcomeCounts: Map.unmodifiable(outcomes),
      emotionTransitionCounts: Map.unmodifiable(transitions),
      generatedAt: generatedAt,
    );
  }
}
