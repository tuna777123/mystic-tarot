import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_mirror.dart';
import 'package:mystic_tarot/src/mystic_reality_evidence.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

ReadingRecord _reading({
  required DateTime createdAt,
  EmotionalState emotion = EmotionalState.uncertain,
  ReadingKind kind = ReadingKind.daily,
}) {
  return ReadingRecord(
    kind: kind,
    question: '',
    cards: [DrawnCard(tarotDeck.first, false)],
    createdAt: createdAt,
    emotion: emotion,
    alignedAction: 'Take one grounded step.',
  );
}

MysticMirrorReflection _mirror(
  ReadingRecord reading, {
  required MysticMirrorOutcome outcome,
  required EmotionalState emotion,
  required DateTime completedAt,
}) {
  return MysticMirrorReflection(
    recordId: mysticMirrorRecordId(reading),
    outcome: outcome,
    emotion: emotion,
    note: '',
    completedAt: completedAt,
  );
}

void main() {
  group('MysticRealityEvidence', () {
    test('counts only readings whose 24h Mirror is eligible', () {
      final now = DateTime.utc(2026, 8, 31, 12);
      final mature = _reading(createdAt: now.subtract(const Duration(days: 2)));
      final recent = _reading(createdAt: now.subtract(const Duration(hours: 6)));

      final snapshot = MysticRealityEvidence.analyze(
        readings: [mature, recent],
        reflections: const {},
        generatedAt: now,
      );

      expect(snapshot.eligibleReadingCount, 1);
      expect(snapshot.completedMirrorCount, 0);
      expect(snapshot.completionRate, 0);
    });

    test('treats unchanged and unclear as valid evidence', () {
      final now = DateTime.utc(2026, 8, 31, 12);
      final unchanged = _reading(
        createdAt: now.subtract(const Duration(days: 3)),
        emotion: EmotionalState.anxious,
      );
      final unclear = _reading(
        createdAt: now.subtract(const Duration(days: 2)),
        emotion: EmotionalState.curious,
      );

      final snapshot = MysticRealityEvidence.analyze(
        readings: [unchanged, unclear],
        reflections: {
          mysticMirrorRecordId(unchanged): _mirror(
            unchanged,
            outcome: MysticMirrorOutcome.unchanged,
            emotion: EmotionalState.grounded,
            completedAt: now.subtract(const Duration(days: 2)),
          ),
          mysticMirrorRecordId(unclear): _mirror(
            unclear,
            outcome: MysticMirrorOutcome.unclear,
            emotion: EmotionalState.curious,
            completedAt: now.subtract(const Duration(days: 1)),
          ),
        },
        generatedAt: now,
      );

      expect(snapshot.completedMirrorCount, 2);
      expect(snapshot.countFor(MysticMirrorOutcome.unchanged), 1);
      expect(snapshot.countFor(MysticMirrorOutcome.unclear), 1);
      expect(snapshot.completionRate, 1);
    });

    test('requires repeated evidence before surfacing patterns', () {
      final now = DateTime.utc(2026, 8, 31, 12);
      final readings = List.generate(
        3,
        (index) => _reading(
          createdAt: now.subtract(Duration(days: 5 - index)),
        ),
      );

      final twoMirrors = {
        for (final reading in readings.take(2))
          mysticMirrorRecordId(reading): _mirror(
            reading,
            outcome: MysticMirrorOutcome.partlyShifted,
            emotion: EmotionalState.hopeful,
            completedAt: reading.mirrorCheckInAt.add(const Duration(hours: 2)),
          ),
      };

      final two = MysticRealityEvidence.analyze(
        readings: readings,
        reflections: twoMirrors,
        generatedAt: now,
      );
      expect(two.hasEnoughEvidence, isFalse);

      final allMirrors = {
        ...twoMirrors,
        mysticMirrorRecordId(readings.last): _mirror(
          readings.last,
          outcome: MysticMirrorOutcome.unchanged,
          emotion: EmotionalState.grounded,
          completedAt: readings.last.mirrorCheckInAt.add(
            const Duration(hours: 1),
          ),
        ),
      };
      final three = MysticRealityEvidence.analyze(
        readings: readings,
        reflections: allMirrors,
        generatedAt: now,
      );
      expect(three.hasEnoughEvidence, isTrue);
    });

    test('reports descriptive emotion transitions deterministically', () {
      final now = DateTime.utc(2026, 8, 31, 12);
      final first = _reading(
        createdAt: now.subtract(const Duration(days: 4)),
        emotion: EmotionalState.anxious,
      );
      final second = _reading(
        createdAt: now.subtract(const Duration(days: 3)),
        emotion: EmotionalState.anxious,
      );
      final third = _reading(
        createdAt: now.subtract(const Duration(days: 2)),
        emotion: EmotionalState.curious,
      );

      final snapshot = MysticRealityEvidence.analyze(
        readings: [first, second, third],
        reflections: {
          mysticMirrorRecordId(first): _mirror(
            first,
            outcome: MysticMirrorOutcome.shifted,
            emotion: EmotionalState.grounded,
            completedAt: first.mirrorCheckInAt,
          ),
          mysticMirrorRecordId(second): _mirror(
            second,
            outcome: MysticMirrorOutcome.unchanged,
            emotion: EmotionalState.grounded,
            completedAt: second.mirrorCheckInAt,
          ),
          mysticMirrorRecordId(third): _mirror(
            third,
            outcome: MysticMirrorOutcome.unclear,
            emotion: EmotionalState.curious,
            completedAt: third.mirrorCheckInAt,
          ),
        },
        generatedAt: now,
      );

      final transitions = snapshot.rankedEmotionTransitions;
      expect(transitions.first.count, 2);
      expect(transitions.first.transition.from, EmotionalState.anxious);
      expect(transitions.first.transition.to, EmotionalState.grounded);
      expect(transitions.last.transition.changed, isFalse);
    });

    test('outcome ordering is count-first and stable on ties', () {
      final now = DateTime.utc(2026, 8, 31, 12);
      final readings = List.generate(
        3,
        (index) => _reading(
          createdAt: now.subtract(Duration(days: 5 - index)),
        ),
      );
      final outcomes = [
        MysticMirrorOutcome.unchanged,
        MysticMirrorOutcome.shifted,
        MysticMirrorOutcome.unchanged,
      ];

      final snapshot = MysticRealityEvidence.analyze(
        readings: readings,
        reflections: {
          for (var i = 0; i < readings.length; i++)
            mysticMirrorRecordId(readings[i]): _mirror(
              readings[i],
              outcome: outcomes[i],
              emotion: EmotionalState.grounded,
              completedAt: readings[i].mirrorCheckInAt,
            ),
        },
        generatedAt: now,
      );

      expect(snapshot.rankedOutcomes.first.outcome, MysticMirrorOutcome.unchanged);
      expect(snapshot.rankedOutcomes.first.count, 2);
      expect(snapshot.rankedOutcomes[1].outcome, MysticMirrorOutcome.shifted);
    });
  });
}
