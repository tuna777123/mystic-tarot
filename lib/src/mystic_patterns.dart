enum ReadingTheme { love, career, wellbeing, growth, decision, general }

class PatternReading {
  const PatternReading({
    required this.id,
    required this.createdAt,
    required this.cardIds,
    required this.theme,
    this.mood,
    this.reflection,
  });

  final String id;
  final DateTime createdAt;
  final List<String> cardIds;
  final ReadingTheme theme;
  final String? mood;
  final String? reflection;
}

class CardFrequency {
  const CardFrequency({required this.cardId, required this.count});

  final String cardId;
  final int count;
}

class ThemeFrequency {
  const ThemeFrequency({required this.theme, required this.count});

  final ReadingTheme theme;
  final int count;
}

class MysticPatternSnapshot {
  const MysticPatternSnapshot({
    required this.readingCount,
    required this.uniqueCardCount,
    required this.topCards,
    required this.topThemes,
    required this.activeDays,
    required this.reflectionRate,
    required this.generatedAt,
  });

  final int readingCount;
  final int uniqueCardCount;
  final List<CardFrequency> topCards;
  final List<ThemeFrequency> topThemes;
  final int activeDays;
  final double reflectionRate;
  final DateTime generatedAt;

  bool get hasEnoughHistory => readingCount >= 3;
}

/// Computes descriptive patterns from locally supplied reading history.
///
/// This engine does not predict outcomes, infer diagnoses, or upload data. It
/// returns transparent counts that a UI can explain to the user and optionally
/// pass to a trusted personalization service with explicit consent.
abstract final class MysticPatterns {
  static MysticPatternSnapshot analyze(
    Iterable<PatternReading> readings, {
    required DateTime generatedAt,
    int topLimit = 3,
  }) {
    if (topLimit < 1) {
      throw ArgumentError.value(topLimit, 'topLimit', 'must be at least 1');
    }

    final history = readings.toList(growable: false);
    final cardCounts = <String, int>{};
    final themeCounts = <ReadingTheme, int>{};
    final activeDates = <String>{};
    var reflected = 0;

    for (final reading in history) {
      for (final cardId in reading.cardIds.toSet()) {
        if (cardId.trim().isEmpty) continue;
        cardCounts.update(cardId, (count) => count + 1, ifAbsent: () => 1);
      }
      themeCounts.update(
        reading.theme,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      activeDates.add(_dateKey(reading.createdAt));
      if (reading.reflection?.trim().isNotEmpty ?? false) reflected++;
    }

    final topCards =
        cardCounts.entries
            .map(
              (entry) => CardFrequency(cardId: entry.key, count: entry.value),
            )
            .toList()
          ..sort((a, b) {
            final byCount = b.count.compareTo(a.count);
            return byCount != 0 ? byCount : a.cardId.compareTo(b.cardId);
          });

    final topThemes =
        themeCounts.entries
            .map(
              (entry) => ThemeFrequency(theme: entry.key, count: entry.value),
            )
            .toList()
          ..sort((a, b) {
            final byCount = b.count.compareTo(a.count);
            return byCount != 0
                ? byCount
                : a.theme.index.compareTo(b.theme.index);
          });

    return MysticPatternSnapshot(
      readingCount: history.length,
      uniqueCardCount: cardCounts.length,
      topCards: topCards.take(topLimit).toList(growable: false),
      topThemes: topThemes.take(topLimit).toList(growable: false),
      activeDays: activeDates.length,
      reflectionRate: history.isEmpty ? 0 : reflected / history.length,
      generatedAt: generatedAt,
    );
  }

  static String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
