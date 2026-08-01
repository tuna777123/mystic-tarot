import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mystic_tarot/src/app.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_text_catalog.dart';
import 'package:mystic_tarot/src/tarot_data.dart';
import 'package:mystic_tarot/src/tarot_localization.dart';

void main() {
  const globalLanguages = <MysticLanguage>[
    MysticLanguage.spanish,
    MysticLanguage.french,
    MysticLanguage.portugueseBrazil,
  ];

  test('launch selector exposes the five complete languages', () {
    expect(
      launchLanguages,
      const <MysticLanguage>[
        MysticLanguage.english,
        MysticLanguage.turkish,
        MysticLanguage.spanish,
        MysticLanguage.french,
        MysticLanguage.portugueseBrazil,
      ],
    );
  });

  test('Spanish, French, and Brazilian Portuguese catalogs are complete', () {
    expect(MysticTextCatalog.launchLanguageCodes, <String>{'ES', 'FR', 'PT-BR'});
    for (final code in MysticTextCatalog.launchLanguageCodes) {
      expect(MysticTextCatalog.exactTranslationCount(code), 423);
      expect(MysticTextCatalog.templateTranslationCount(code), 40);
      expect(
        MysticTextCatalog.exactTranslationCount(code) +
            MysticTextCatalog.templateTranslationCount(code),
        463,
      );
      expect(MysticTextCatalog.hasTranslation(code, 'Read'), isTrue);
      expect(
        MysticTextCatalog.hasTranslation(
          code,
          'CURRENT CHAPTER • {{p0}}',
        ),
        isTrue,
      );
      expect(
        MysticTextCatalog.translate(code, 'What surrounds you'),
        isNot('What surrounds you'),
      );
    }
  });

  test('all 78 cards have localized names, meanings, and advice', () {
    expect(tarotDeck.length, 78);
    for (final language in globalLanguages) {
      for (final card in tarotDeck) {
        final name = localizedTarotCardName(
          card.name,
          languageCode: language.code,
        );
        expect(name, isNotEmpty, reason: '${language.code}: ${card.name}');
        expect(name, isNot(card.name), reason: '${language.code}: ${card.name}');

        for (final reversed in <bool>[false, true]) {
          final drawn = DrawnCard(card, reversed);
          final meaning = localizedTarotCardMeaning(
            drawn,
            languageCode: language.code,
          );
          final advice = localizedTarotCardAdvice(
            drawn,
            languageCode: language.code,
          );
          expect(
            meaning,
            isNotEmpty,
            reason: '${language.code}: ${card.name} reversed=$reversed',
          );
          expect(
            advice,
            isNotEmpty,
            reason: '${language.code}: ${card.name} reversed=$reversed',
          );
          expect(
            meaning,
            isNot(reversed ? card.shadow : card.light),
            reason: '${language.code}: ${card.name} fell back to English',
          );
        }
      }
    }
  });

  test('reading types, emotions, and deck names never fall back to English', () {
    for (final language in globalLanguages) {
      for (final kind in ReadingKind.values) {
        expect(
          localizedReadingKindTitle(kind, languageCode: language.code),
          isNot(kind.title),
        );
        expect(
          localizedReadingKindSubtitle(kind, languageCode: language.code),
          isNot(kind.subtitle),
        );
      }
      for (final emotion in EmotionalState.values) {
        expect(
          localizedEmotionLabel(emotion, languageCode: language.code),
          isNot(emotion.label),
        );
      }
      for (final style in DeckStyle.values) {
        expect(
          localizedDeckStyleLabel(style, languageCode: language.code),
          isNot(style.label),
        );
      }
    }
  });

  test('dynamic global copy keeps translated captures', () {
    expect(
      mysticText(
        MysticLanguage.spanish,
        'CURRENT CHAPTER • EL SOL',
        'MEVCUT BÖLÜM • GÜNEŞ',
      ),
      'CAPÍTULO ACTUAL • EL SOL',
    );
    expect(
      mysticText(
        MysticLanguage.french,
        'CURRENT CHAPTER • LE SOLEIL',
        'MEVCUT BÖLÜM • GÜNEŞ',
      ),
      'CHAPITRE ACTUEL • LE SOLEIL',
    );
    expect(
      mysticText(
        MysticLanguage.portugueseBrazil,
        'Your recent Amor e Conexão questions have carried esperançoso energy. This chapter asks you to nomear um limite',
        'Son aşk soruların umutlu enerji taşıdı.',
      ),
      'Suas perguntas recentes sobre Amor e Conexão carregaram uma energia esperançoso. Este capítulo convida você a nomear um limite',
    );
  });

  for (final scenario in <({MysticLanguage language, List<String> labels})>[
    (
      language: MysticLanguage.spanish,
      labels: <String>['Leer', 'Camino', 'Diario', 'Tú'],
    ),
    (
      language: MysticLanguage.french,
      labels: <String>['Tirages', 'Chemin', 'Journal', 'Vous'],
    ),
    (
      language: MysticLanguage.portugueseBrazil,
      labels: <String>['Ler', 'Caminho', 'Diário', 'Você'],
    ),
  ]) {
    testWidgets('${scenario.language.code} restores a fully localized shell', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboarded': true,
        'language': scenario.language.name,
      });

      await tester.pumpWidget(const MysticApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      for (final label in scenario.labels) {
        expect(find.text(label), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

}
