import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/reading_position.dart';
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
  const boundaryTokens = <MysticLanguage, String>{
    MysticLanguage.english: 'reflective invitation',
    MysticLanguage.turkish: 'düşünmeye yönelik bir davet',
    MysticLanguage.spanish: 'invitación a reflexionar',
    MysticLanguage.french: 'invitation à réfléchir',
    MysticLanguage.portugueseBrazil: 'convite à reflexão',
  };
  const unsafeTokens = <MysticLanguage, List<String>>{
    MysticLanguage.english: ['guaranteed', 'definitely will', 'must happen'],
    MysticLanguage.turkish: ['kesin olacak', 'garantili', 'mutlaka gerçekleşecek'],
    MysticLanguage.spanish: ['garantizado', 'ocurrirá sin duda'],
    MysticLanguage.french: ['garanti', 'arrivera certainement'],
    MysticLanguage.portugueseBrazil: ['garantido', 'vai acontecer com certeza'],
  };

  for (final language in languages) {
    test('single-card synthesis is grounded and bounded in ${language.code}', () {
      final card = DrawnCard(tarotDeck.first, false);
      final result = buildReadingSynthesis(
        kind: ReadingKind.daily,
        cards: [card],
        emotion: EmotionalState.grounded,
        intention: 'Clarity',
        language: language,
      );
      final lower = result.toLowerCase();
      expect(result.trim().length, greaterThan(150));
      expect(
        result,
        contains(localizedTarotCardName(
          card.card.name,
          languageCode: language.code,
        )),
      );
      expect(lower, contains(boundaryTokens[language]!));
      for (final token in unsafeTokens[language]!) {
        expect(lower, isNot(contains(token)));
      }
      _expectCleanCopy(result);
    });

    for (final kind in ReadingKind.values.where((item) => item.cardCount > 1)) {
      test('${kind.name} synthesis is coherent in ${language.code}', () {
        final cards = <DrawnCard>[
          for (var index = 0; index < kind.cardCount; index++)
            DrawnCard(tarotDeck[(index * 7) % tarotDeck.length], index.isOdd),
        ];
        final result = buildReadingSynthesis(
          kind: kind,
          cards: cards,
          emotion: EmotionalState.anxious,
          intention: 'Purpose',
          language: language,
        );
        final lower = result.toLowerCase();
        final names = <String>[
          for (final card in cards)
            localizedTarotCardName(
              card.card.name,
              languageCode: language.code,
            ),
        ];
        expect(result.trim().length, greaterThan(260));
        expect(result, contains(names.first));
        expect(result, contains(names.last));
        _expectCleanCopy(result);
        for (final token in unsafeTokens[language]!) {
          expect(lower, isNot(contains(token)));
        }
        final sentences = result
            .split(RegExp(r'[.!?…]+'))
            .map((item) => item.trim().toLowerCase())
            .where((item) => item.length > 20)
            .toList();
        expect(sentences.toSet().length, sentences.length);

        if (kind.cardCount == 2 && names.first != names.last) {
          expect(_occurrences(result, names.first), 1);
          expect(_occurrences(result, names.last), 1);
        }
        if (kind == ReadingKind.compatibility || kind == ReadingKind.timeline) {
          for (final name in names) {
            expect(result, contains(name));
          }
        }
        if (kind == ReadingKind.celticCross) {
          expect(result, contains(names[1]));
          expect(result, contains(names[5]));
          expect(result, contains(names[9]));
        }
      });
    }

    test('deep-spread positions are complete in ${language.code}', () {
      final compatibilityLast = localizedReadingPosition(
        kind: ReadingKind.compatibility,
        index: 4,
        language: language,
      );
      final timelineLast = localizedReadingPosition(
        kind: ReadingKind.timeline,
        index: 5,
        language: language,
      );
      expect(compatibilityLast, _compatibilityActionLabel(language));
      expect(timelineLast, _timelineAgencyLabel(language));
    });
  }

  test('empty intention uses a localized fallback without placeholders', () {
    for (final language in languages) {
      final result = buildReadingSynthesis(
        kind: ReadingKind.daily,
        cards: [DrawnCard(tarotDeck[3], true)],
        emotion: EmotionalState.curious,
        intention: '   ',
        language: language,
      );
      expect(result.trim(), isNotEmpty);
      _expectCleanCopy(result);
    }
  });
}

void _expectCleanCopy(String result) {
  expect(result, isNot(contains('{{')));
  expect(result, isNot(contains('}}')));
  expect(result, isNot(contains('null')));
  expect(result, isNot(contains('  ')));
}

int _occurrences(String source, String pattern) =>
    pattern.isEmpty ? 0 : source.split(pattern).length - 1;

String _compatibilityActionLabel(MysticLanguage language) => switch (language) {
      MysticLanguage.turkish => 'Bağ için sıradaki dürüst adım',
      MysticLanguage.spanish => 'El siguiente paso honesto para el vínculo',
      MysticLanguage.french => 'La prochaine étape honnête pour le lien',
      MysticLanguage.portugueseBrazil => 'O próximo passo honesto para a conexão',
      _ => 'The next honest step for the connection',
    };

String _timelineAgencyLabel(MysticLanguage language) => switch (language) {
      MysticLanguage.turkish => 'Gidişatı değiştirebilecek seçim',
      MysticLanguage.spanish => 'La elección que puede cambiar la trayectoria',
      MysticLanguage.french => 'Le choix qui peut changer la trajectoire',
      MysticLanguage.portugueseBrazil => 'A escolha que pode mudar a trajetória',
      _ => 'The choice that can change the trajectory',
    };
