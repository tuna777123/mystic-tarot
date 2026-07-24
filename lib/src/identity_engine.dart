import 'models.dart';

enum MysticArchetype { seeker, alchemist, sage, guardian, visionary }

class MysticIdentitySnapshot {
  const MysticIdentitySnapshot({
    required this.primary,
    required this.secondary,
    required this.confidence,
    required this.title,
    required this.summary,
    required this.nextEvolution,
    required this.progressToEvolution,
    required this.signals,
  });

  final MysticArchetype primary;
  final MysticArchetype secondary;
  final int confidence;
  final String title;
  final String summary;
  final String nextEvolution;
  final double progressToEvolution;
  final List<String> signals;
}

class MysticIdentityEngine {
  const MysticIdentityEngine();

  MysticIdentitySnapshot analyze({
    required List<ReadingRecord> records,
    required int streak,
    required int completedArcanaDays,
  }) {
    final scores = <MysticArchetype, int>{
      for (final archetype in MysticArchetype.values) archetype: 0,
    };

    void add(MysticArchetype archetype, int value) {
      scores[archetype] = scores[archetype]! + value;
    }

    for (final record in records) {
      add(_kindArchetype(record.kind), _kindWeight(record.kind));
      add(_emotionArchetype(record.emotion), 2);
      if (record.cards.any((card) => card.reversed)) {
        add(MysticArchetype.alchemist, 2);
      }
      if (record.alignedAction.trim().length >= 18) {
        add(MysticArchetype.guardian, 1);
      }
    }

    add(MysticArchetype.sage, completedArcanaDays * 2);
    add(MysticArchetype.guardian, streak);
    if (records.length >= 8) add(MysticArchetype.alchemist, 4);

    final ranked = scores.entries.toList()
      ..sort((a, b) {
        final byScore = b.value.compareTo(a.value);
        return byScore != 0 ? byScore : a.key.index.compareTo(b.key.index);
      });
    final primary = ranked.first.key;
    final secondary = ranked[1].key;
    final total = scores.values.fold<int>(0, (sum, value) => sum + value);
    final confidence = total == 0
        ? 0
        : ((ranked.first.value / total) * 100).round().clamp(0, 100);

    return MysticIdentitySnapshot(
      primary: primary,
      secondary: secondary,
      confidence: confidence,
      title: _title(primary),
      summary: _summary(primary),
      nextEvolution: _title(_nextEvolution(primary)),
      progressToEvolution:
          (records.length * 4 + streak * 5 + completedArcanaDays * 3)
                  .clamp(0, 100) /
              100,
      signals: _signals(
        primary: primary,
        records: records.length,
        streak: streak,
        completedArcanaDays: completedArcanaDays,
      ),
    );
  }

  MysticArchetype _kindArchetype(ReadingKind kind) => switch (kind) {
        ReadingKind.daily || ReadingKind.decision => MysticArchetype.seeker,
        ReadingKind.shadow || ReadingKind.spiritual =>
          MysticArchetype.alchemist,
        ReadingKind.career || ReadingKind.money => MysticArchetype.guardian,
        ReadingKind.love || ReadingKind.compatibility =>
          MysticArchetype.visionary,
        ReadingKind.timeline || ReadingKind.celticCross => MysticArchetype.sage,
      };

  int _kindWeight(ReadingKind kind) => switch (kind) {
        ReadingKind.timeline || ReadingKind.celticCross => 4,
        ReadingKind.shadow ||
        ReadingKind.spiritual ||
        ReadingKind.career ||
        ReadingKind.money ||
        ReadingKind.love ||
        ReadingKind.compatibility =>
          3,
        ReadingKind.daily || ReadingKind.decision => 2,
      };

  MysticArchetype _emotionArchetype(EmotionalState emotion) => switch (emotion) {
        EmotionalState.uncertain || EmotionalState.curious =>
          MysticArchetype.seeker,
        EmotionalState.anxious => MysticArchetype.alchemist,
        EmotionalState.grounded => MysticArchetype.guardian,
        EmotionalState.hopeful => MysticArchetype.visionary,
      };

  MysticArchetype _nextEvolution(MysticArchetype current) => switch (current) {
        MysticArchetype.seeker => MysticArchetype.alchemist,
        MysticArchetype.alchemist => MysticArchetype.sage,
        MysticArchetype.sage => MysticArchetype.visionary,
        MysticArchetype.guardian => MysticArchetype.sage,
        MysticArchetype.visionary => MysticArchetype.guardian,
      };

  String _title(MysticArchetype archetype) => switch (archetype) {
        MysticArchetype.seeker => 'The Seeker',
        MysticArchetype.alchemist => 'The Alchemist',
        MysticArchetype.sage => 'The Sage',
        MysticArchetype.guardian => 'The Guardian',
        MysticArchetype.visionary => 'The Visionary',
      };

  String _summary(MysticArchetype archetype) => switch (archetype) {
        MysticArchetype.seeker =>
          'You grow by asking honest questions and following what keeps returning.',
        MysticArchetype.alchemist =>
          'You transform uncertainty into action by facing difficult patterns directly.',
        MysticArchetype.sage =>
          'You seek meaning across time and turn repeated experience into perspective.',
        MysticArchetype.guardian =>
          'You value stability, responsibility, and choices that protect your future.',
        MysticArchetype.visionary =>
          'You are guided by possibility, connection, and the future you can imagine.',
      };

  List<String> _signals({
    required MysticArchetype primary,
    required int records,
    required int streak,
    required int completedArcanaDays,
  }) {
    if (records == 0) {
      return const ['Your identity begins with your first reading.'];
    }
    final result = <String>['$records readings are shaping this identity.'];
    if (streak >= 3) result.add('A $streak-day rhythm shows sustained intention.');
    if (completedArcanaDays >= 3) {
      result.add('$completedArcanaDays Arcana chapters deepen your profile.');
    }
    result.add(switch (primary) {
      MysticArchetype.seeker => 'Curiosity is your strongest recurring signal.',
      MysticArchetype.alchemist => 'Transformation themes repeat in your choices.',
      MysticArchetype.sage => 'Long-range reflection is central to your path.',
      MysticArchetype.guardian => 'Grounded action defines your current chapter.',
      MysticArchetype.visionary => 'Hope and connection shape your direction.',
    });
    return result.take(3).toList(growable: false);
  }
}
