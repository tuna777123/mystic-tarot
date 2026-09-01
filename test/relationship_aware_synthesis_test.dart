import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/reading_synthesis.dart';
import 'package:mystic_tarot/src/tarot_data.dart';
import 'package:mystic_tarot/src/tarot_localization.dart';

void main() {
  const languages = <MysticLanguage>[
    MysticLanguage.english,
    MysticLanguage.turkish,
    MysticLanguage.spanish,
    MysticLanguage.french,
    MysticLanguage.portugueseBrazil,
  ];

  const oppositeOrientationTokens = <MysticLanguage, String>{
    MysticLanguage.english: 'opposite orientations',
    MysticLanguage.turkish: 'zıt yönlerde',
    MysticLanguage.spanish: 'orientaciones opuestas',
    MysticLanguage.french: 'orientations opposées',
    MysticLanguage.portugueseBrazil: 'orientações opostas',
  };

  const reinforcementTokens = <MysticLanguage, String>{
    MysticLanguage.english: 'reinforce the',
    MysticLanguage.turkish: 'iki ayrı konumda güçlendiriyor',
    MysticLanguage.spanish: 'refuerzan el hilo',
    MysticLanguage.french: 'renforcent le fil',
    MysticLanguage.portugueseBrazil: 'reforçam o fio',
  };

  final firstWand = tarotDeck.firstWhere(
    (card) => card.name == 'Ace of Wands',
  );
  final secondWand = tarotDeck.firstWhere(
    (card) => card.name == 'Two of Wands',
  );
  final fool = tarotDeck.firstWhere((card) => card.name == 'The Fool');

  for (final language in languages) {
    test(
      'relationship synthesis names repeated theme tension in ${language.code}',
      () {
        final result = buildReadingSynthesis(
          kind: ReadingKind.career,
          cards: [
            DrawnCard(firstWand, false),
            DrawnCard(fool, false),
            DrawnCard(secondWand, true),
          ],
          emotion: EmotionalState.curious,
          intention: 'Purpose',
          language: language,
        );

        expect(
          result,
          contains(
            localizedTarotCardName(
              firstWand.name,
              languageCode: language.code,
            ),
          ),
        );
        expect(
          result,
          contains(
            localizedTarotCardName(
              secondWand.name,
              languageCode: language.code,
            ),
          ),
        );
        expect(
          result.toLowerCase(),
          contains(oppositeOrientationTokens[language]!),
        );
      },
    );

    test(
      'relationship synthesis detects reinforcement in ${language.code}',
      () {
        final result = buildReadingSynthesis(
          kind: ReadingKind.career,
          cards: [
            DrawnCard(firstWand, false),
            DrawnCard(fool, true),
            DrawnCard(secondWand, false),
          ],
          emotion: EmotionalState.grounded,
          intention: 'Clarity',
          language: language,
        );

        expect(
          result.toLowerCase(),
          contains(reinforcementTokens[language]!),
        );
      },
    );
  }

  test('changing orientation changes the relationship interpretation', () {
    final aligned = buildReadingSynthesis(
      kind: ReadingKind.career,
      cards: [
        DrawnCard(firstWand, false),
        DrawnCard(fool, false),
        DrawnCard(secondWand, false),
      ],
      emotion: EmotionalState.grounded,
      intention: 'Clarity',
      language: MysticLanguage.english,
    );
    final tension = buildReadingSynthesis(
      kind: ReadingKind.career,
      cards: [
        DrawnCard(firstWand, false),
        DrawnCard(fool, false),
        DrawnCard(secondWand, true),
      ],
      emotion: EmotionalState.grounded,
      intention: 'Clarity',
      language: MysticLanguage.english,
    );

    expect(aligned, isNot(tension));
    expect(aligned, contains('reinforce the'));
    expect(tension, contains('opposite orientations'));
  });
}
