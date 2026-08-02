import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/reading_position.dart';

void main() {
  test('Celtic Cross exposes all ten traditional reading roles', () {
    final positions = List<String>.generate(
      10,
      (index) => localizedReadingPosition(
        kind: ReadingKind.celticCross,
        index: index,
        language: MysticLanguage.english,
      ),
    );

    expect(positions, hasLength(10));
    expect(positions.toSet(), hasLength(10));
    expect(positions.first, 'Present situation');
    expect(positions[1], 'Immediate challenge');
    expect(positions.last, 'Direction if the pattern continues');
  });

  test('compatibility distinguishes both people and their dynamic', () {
    final positions = List<String>.generate(
      3,
      (index) => localizedReadingPosition(
        kind: ReadingKind.compatibility,
        index: index,
        language: MysticLanguage.english,
      ),
    );

    expect(positions, <String>[
      'Your energy in the connection',
      'The other person’s energy',
      'The dynamic between you',
    ]);
  });

  test('decision positions never pretend both paths mean the same thing', () {
    final first = localizedReadingPosition(
      kind: ReadingKind.decision,
      index: 0,
      language: MysticLanguage.english,
    );
    final second = localizedReadingPosition(
      kind: ReadingKind.decision,
      index: 1,
      language: MysticLanguage.english,
    );

    expect(first, isNot(second));
    expect(first, contains('first path'));
    expect(second, contains('second path'));
  });

  test('every launch language has a localized timeline horizon', () {
    const expected = <MysticLanguage, String>{
      MysticLanguage.english: 'longer horizon',
      MysticLanguage.turkish: 'uzun vade',
      MysticLanguage.spanish: 'horizonte',
      MysticLanguage.french: 'horizon',
      MysticLanguage.portugueseBrazil: 'horizonte',
    };

    for (final entry in expected.entries) {
      final label = localizedReadingPosition(
        kind: ReadingKind.timeline,
        index: 4,
        language: entry.key,
      ).toLowerCase();
      expect(label, contains(entry.value), reason: entry.key.name);
    }
  });

  test('unknown extra positions remain explicit instead of disappearing', () {
    expect(
      localizedReadingPosition(
        kind: ReadingKind.daily,
        index: 4,
        language: MysticLanguage.english,
      ),
      'Supporting message 5',
    );
  });
}
