import 'models.dart';

class CardFrequency {
  const CardFrequency({required this.cardName, required this.count, required this.reversedCount});

  final String cardName;
  final int count;
  final int reversedCount;

  double get reversedRatio => count == 0 ? 0 : reversedCount / count;
}

class CardTransition {
  const CardTransition({required this.from, required this.to, required this.count});

  final String from;
  final String to;
  final int count;
}

class FateCheckIn {
  const FateCheckIn({required this.record, required this.dueAt});

  final ReadingRecord record;
  final DateTime dueAt;

  bool isDue(DateTime now) => !dueAt.isAfter(now);
}

class LivingFateSnapshot {
  const LivingFateSnapshot({
    required this.totalReadings,
    required this.frequencies,
    required this.transitions,
    required this.emotionCounts,
    required this.dueCheckIns,
    required this.dominantReadingKind,
  });

  final int totalReadings;
  final List<CardFrequency> frequencies;
  final List<CardTransition> transitions;
  final Map<EmotionalState, int> emotionCounts;
  final List<FateCheckIn> dueCheckIns;
  final ReadingKind? dominantReadingKind;

  CardFrequency? get mostRecurringCard => frequencies.isEmpty ? null : frequencies.first;

  EmotionalState? get dominantEmotion {
    if (emotionCounts.isEmpty) return null;
    return emotionCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

class LivingFateEngine {
  const LivingFateEngine();

  LivingFateSnapshot analyze(List<ReadingRecord> records, {DateTime? now}) {
    final referenceTime = now ?? DateTime.now();
    final cardCounts = <String, int>{};
    final reversedCounts = <String, int>{};
    final emotionCounts = <EmotionalState, int>{};
    final kindCounts = <ReadingKind, int>{};
    final transitionCounts = <String, int>{};

    final chronological = [...records]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    String? previousPrimaryCard;
    for (final record in chronological) {
      emotionCounts.update(record.emotion, (value) => value + 1, ifAbsent: () => 1);
      kindCounts.update(record.kind, (value) => value + 1, ifAbsent: () => 1);

      for (final drawn in record.cards) {
        cardCounts.update(drawn.card.name, (value) => value + 1, ifAbsent: () => 1);
        if (drawn.reversed) {
          reversedCounts.update(drawn.card.name, (value) => value + 1, ifAbsent: () => 1);
        }
      }

      if (record.cards.isNotEmpty) {
        final primary = record.cards.first.card.name;
        if (previousPrimaryCard != null) {
          final key = '$previousPrimaryCard\u0000$primary';
          transitionCounts.update(key, (value) => value + 1, ifAbsent: () => 1);
        }
        previousPrimaryCard = primary;
      }
    }

    final frequencies = cardCounts.entries
        .map((entry) => CardFrequency(
              cardName: entry.key,
              count: entry.value,
              reversedCount: reversedCounts[entry.key] ?? 0,
            ))
        .toList()
      ..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        return byCount != 0 ? byCount : a.cardName.compareTo(b.cardName);
      });

    final transitions = transitionCounts.entries.map((entry) {
      final parts = entry.key.split('\u0000');
      return CardTransition(from: parts.first, to: parts.last, count: entry.value);
    }).toList()
      ..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        if (byCount != 0) return byCount;
        final byFrom = a.from.compareTo(b.from);
        return byFrom != 0 ? byFrom : a.to.compareTo(b.to);
      });

    final dueCheckIns = chronological
        .map((record) => FateCheckIn(record: record, dueAt: record.mirrorCheckInAt))
        .where((checkIn) => checkIn.isDue(referenceTime))
        .toList()
      ..sort((a, b) => b.dueAt.compareTo(a.dueAt));

    ReadingKind? dominantKind;
    if (kindCounts.isNotEmpty) {
      dominantKind = kindCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    return LivingFateSnapshot(
      totalReadings: records.length,
      frequencies: frequencies,
      transitions: transitions,
      emotionCounts: Map.unmodifiable(emotionCounts),
      dueCheckIns: dueCheckIns,
      dominantReadingKind: dominantKind,
    );
  }
}