import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/mystic_patterns.dart';

void main() {
  final now = DateTime(2026, 7, 26, 12);

  test('returns an empty transparent snapshot without history', () {
    final snapshot = MysticPatterns.analyze(const [], generatedAt: now);

    expect(snapshot.readingCount, 0);
    expect(snapshot.uniqueCardCount, 0);
    expect(snapshot.topCards, isEmpty);
    expect(snapshot.topThemes, isEmpty);
    expect(snapshot.activeDays, 0);
    expect(snapshot.reflectionRate, 0);
    expect(snapshot.hasEnoughHistory, isFalse);
  });

  test('finds repeated cards, themes and reflection behavior', () {
    final snapshot = MysticPatterns.analyze(
      [
        PatternReading(
          id: '1',
          createdAt: DateTime(2026, 7, 24, 8),
          cardIds: const ['the_fool', 'the_star', 'the_fool'],
          theme: ReadingTheme.growth,
          reflection: 'A new beginning feels possible.',
        ),
        PatternReading(
          id: '2',
          createdAt: DateTime(2026, 7, 24, 20),
          cardIds: const ['the_fool', 'two_of_cups'],
          theme: ReadingTheme.love,
        ),
        PatternReading(
          id: '3',
          createdAt: DateTime(2026, 7, 25, 9),
          cardIds: const ['the_star'],
          theme: ReadingTheme.growth,
          reflection: 'I noticed the same hope theme again.',
        ),
      ],
      generatedAt: now,
    );

    expect(snapshot.readingCount, 3);
    expect(snapshot.uniqueCardCount, 3);
    expect(snapshot.activeDays, 2);
    expect(snapshot.hasEnoughHistory, isTrue);
    expect(snapshot.reflectionRate, closeTo(2 / 3, 0.0001));
    expect(snapshot.topCards.first.cardId, 'the_fool');
    expect(snapshot.topCards.first.count, 2);
    expect(snapshot.topThemes.first.theme, ReadingTheme.growth);
    expect(snapshot.topThemes.first.count, 2);
  });

  test('uses deterministic ordering when counts are equal', () {
    final snapshot = MysticPatterns.analyze(
      [
        PatternReading(
          id: '1',
          createdAt: now,
          cardIds: const ['z_card', 'a_card'],
          theme: ReadingTheme.career,
        ),
      ],
      generatedAt: now,
      topLimit: 2,
    );

    expect(snapshot.topCards.map((item) => item.cardId), ['a_card', 'z_card']);
  });

  test('rejects invalid result limits', () {
    expect(
      () => MysticPatterns.analyze(const [], generatedAt: now, topLimit: 0),
      throwsArgumentError,
    );
  });
}
