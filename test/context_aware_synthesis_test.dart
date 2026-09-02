import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/reading_synthesis.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

void main() {
  const languages = <MysticLanguage>[
    MysticLanguage.english,
    MysticLanguage.turkish,
    MysticLanguage.spanish,
    MysticLanguage.french,
    MysticLanguage.portugueseBrazil,
  ];

  const loveTokens = <MysticLanguage, String>{
    MysticLanguage.english: 'relationship context',
    MysticLanguage.turkish: 'ilişki bağlamında',
    MysticLanguage.spanish: 'contexto relacional',
    MysticLanguage.french: 'contexte relationnel',
    MysticLanguage.portugueseBrazil: 'contexto de relacionamento',
  };

  const careerTokens = <MysticLanguage, String>{
    MysticLanguage.english: 'career context',
    MysticLanguage.turkish: 'kariyer bağlamında',
    MysticLanguage.spanish: 'contexto profesional',
    MysticLanguage.french: 'contexte professionnel',
    MysticLanguage.portugueseBrazil: 'contexto profissional',
  };

  const reversedTokens = <MysticLanguage, String>{
    MysticLanguage.english: 'because the card is reversed',
    MysticLanguage.turkish: 'kart ters olduğu için',
    MysticLanguage.spanish: 'como la carta está invertida',
    MysticLanguage.french: 'comme la carte est renversée',
    MysticLanguage.portugueseBrazil: 'como a carta está invertida',
  };

  final card = tarotDeck.firstWhere((item) => item.name == 'Ace of Cups');

  for (final language in languages) {
    test(
      'same card changes meaning by reading context in ${language.code}',
      () {
        final love = buildReadingSynthesis(
          kind: ReadingKind.love,
          cards: [DrawnCard(card, false)],
          emotion: EmotionalState.curious,
          intention: 'Love',
          language: language,
        );
        final career = buildReadingSynthesis(
          kind: ReadingKind.career,
          cards: [DrawnCard(card, false)],
          emotion: EmotionalState.curious,
          intention: 'Purpose',
          language: language,
        );

        expect(love, isNot(career));
        expect(love.toLowerCase(), contains(loveTokens[language]!));
        expect(career.toLowerCase(), contains(careerTokens[language]!));
      },
    );

    test('reversal changes contextual framing in ${language.code}', () {
      final upright = buildReadingSynthesis(
        kind: ReadingKind.money,
        cards: [DrawnCard(card, false)],
        emotion: EmotionalState.grounded,
        intention: 'Clarity',
        language: language,
      );
      final reversed = buildReadingSynthesis(
        kind: ReadingKind.money,
        cards: [DrawnCard(card, true)],
        emotion: EmotionalState.grounded,
        intention: 'Clarity',
        language: language,
      );

      expect(upright, isNot(reversed));
      expect(reversed.toLowerCase(), contains(reversedTokens[language]!));
    });
  }
}
