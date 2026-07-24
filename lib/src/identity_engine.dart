import 'models.dart';

enum MysticArchetype {
  seeker,
  alchemist,
  sage,
  guardian,
  visionary,
}

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

    for (final record in records) {
      _scoreKind(scores, record.kind);
      _scoreEmotion(scores, record.emotion);
      if (record.cards.any((card) => card.reversed)) {
        scores[MysticArchetype.alchemist] =
            scores[MysticArchetype.alchemist]! + 2;
      }
      if (record.alignedAction.trim().length >= 18) {
        scores[MysticArchetype.guardian] =
            scores[MysticArchetype.guardian]! + 1;
      }
    }

    scores[MysticArchetype.sage] =
        scores[MysticArchetype.sage]! + completedArcanaDays * 2;
    scores[MysticArchetype.guardian] =
        scores[MysticArchetype.guardian]! + streak;
    if (records.length >= 8) {
      scores[MysticArchetype.alchemist] =
          scores[MysticArchetype.alchemist]! + 4;
    }

    final ranked = scores.entries.toList()
      ..sort((a, b) {
        final scoreComparison = b.value.compareTo(a.value);
        if (scoreComparison != 0) return scoreComparison;
        return a.key.index.compareTo(b.key.index);
      });

    final primary = ranked.first.key;
    final secondary = ranked.length > 1 ? ranked[1].key : primary;
    final total = scores.values.fold<int>(0, (sum, score) => sum + score);
    final confidence = total == 0
        ? 0
        : ((ranked.first.value / total) * 100).round().clamp(0, 100);
    final evolutionTarget = _nextEvolution(primary);
    final progress = _evolutionProgress(
      records: records.length,
      streak: streak,
      completedArcanaDays: completedArcanaDays,
    );

    return MysticIdentitySnapshot(
      primary: primary,
      secondary: secondary,
      confidence: confidence,
      title: _title(primary),
      summary: _summary(primary),
      nextEvolution: _title(evolutionTarget),
      progressToEvolution: progress,
      signals: _signals(
        primary: primary,
        records: records,
        streak: streak,
        completedArcanaDays: completedArcanaDays,
      ),
    );
  }

  void _scoreKind(Map<MysticArchetype, int> scores, ReadingKind kind) {
    switch (kind) {
      case ReadingKind.daily:
      case ReadingKind.decision:
        scores[MysticArchetype.seeker] =
            scores[MysticArchetype.seeker]! + 2;
      case ReadingKind.shadow:
      case ReadingKind.spiritual:
        scores[MysticArchetype.alchemist] =
            scores[MysticArchetype.alchemist]! + 3;
      case ReadingKind.career:
      case ReadingKind.money:
        scores[MysticArchetype.guardian] =
            scores[MysticArchetype.guardian]! + 3;
      case ReadingKind.love:
      case ReadingKind.compatibility:
        scores[MysticArchetype.visionary] =
            scores[MysticArchetype.visionary]! + 3;
      case ReadingKind.timeline:
      case ReadingKind.celticCross:
        scores[MysticArchetype.sage] = scores[MysticArchetype.sage]! + 4;
    }
  }

  void _scoreEmotion(
    Map<MysticArchetype, int> scores,
    EmotionalState emotion,
  ) {
    switch (emotion) {
      case EmotionalState.uncertain:
      case EmotionalState.curious:
        scores[MysticArchetype.seeker] =
            scores[MysticArchetype.seeker]! + 2;
      case EmotionalState.anxious:
        scores[MysticArchetype.alchemist] =
            scores[MysticArchetype.alchemist]! + 2;
      case EmotionalState.grounded:
        scores[MysticArchetype.guardian] =
            scores[MysticArchetype.guardian]! + 2;
      case EmotionalState.hopeful:
        scores[MysticArchetype.visionary] =
            scores[MysticArchetype.visionary]! + 2;
    }
  }

  MysticArchetype _nextEvolution(MysticArchetype current) {
    switch (current) {
      case MysticArchetype.seeker:
        return MysticArchetype.alchemist;
      case MysticArchetype.alchemist:
        return MysticArchetype.sage;
      case MysticArchetype.sage:
        return MysticArchetype.visionary;
      case MysticArchetype.guardian:
        return MysticArchetype.sage;
      case MysticArchetype.visionary:
        return MysticArchetype.guardian;
    }
  }

  double _evolutionProgress({
    required int records,
    required int streak,
    required int completedArcanaDays,
  }) {
    final value = records * 4 + streak * 5 + completedArcanaDays * 3;
    return (value.clamp(0, 100)) / 100;
  }

  List<String> _signals({
    required MysticArchetype primary,
    required List<ReadingRecord> records,
    required int streak,
    required int completedArcanaDays,
  }) {
    final signals = <String>[];
    if (records.isEmpty) return const ['Your identity begins with your first reading.'];
    signals.add('${records.length} readings are shaping this identity.');
    if (streak >= 3) signals.add('A $streak-day rhythm shows sustained intention.');
    if (completedArcanaDays >= 3) {
      signals.add('$completedArcanaDays Arcana chapters deepen your profile.');
    }
    signals.add(_signalFor(primary));
    return signals.take(3).toList(growable: false);
  }

  String _title(MysticArchetype archetype) {
    switch (archetype) {
      case MysticArchetype.seeker:
        return 'The Seeker';
      case MysticArchetype.alchemist:
        return 'The Alchemist';
      case MysticArchetype.sage:
        return 'The Sage';
      case MysticArchetype.guardian:
        return 'The Guardian';
      case MysticArchetype.visionary:
        return 'The Visionary';
    }
  }

  String _summary(MysticArchetype archetype) {
    switch (archetype) {
      case MysticArchetype.seeker:
        return 'You grow by asking honest questions and following what keeps returning.';
      case MysticArchetype.alchemist:
        return 'You transform uncertainty into action by facing difficult patterns directly.';
      case MysticArchetype.sage:
        return 'You seek meaning across time and turn repeated experience into perspective.';
      case MysticArchetype.guardian:
        return 'You value stability, responsibility, and choices that protect your future.';
      case MysticArchetype.visionary:
        return 'You are guided by possibility, connection, and the future you can imagine.';
    }
  }

  String _signalFor(MysticArchetype archetype) {
    switch (archetype) {
      case MysticArchetype.seeker:
        return 'Curiosity is currently your strongest recurring signal.';
      case MysticArchetype.alchemist:
        return 'Transformation themes are appearing across your choices.';
      case MysticArchetype.sage:
        return 'Long-range reflection is becoming central to your path.';
      case MysticArchetype.guardian:
        return 'Grounded action is defining your current chapter.';
      case MysticArchetype.visionary:
        return 'Hope and connection are shaping your next direction.';
    }
  }
}
