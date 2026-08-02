import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/reading_explanation.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

void main() {
  final upright = DrawnCard(tarotDeck.first, false);
  final reversed = DrawnCard(tarotDeck.first, true);

  test('explanation exposes every input used to frame a reading', () {
    final explanation = buildReadingExplanation(
      kind: ReadingKind.love,
      card: upright,
      positionIndex: 1,
      emotion: EmotionalState.curious,
      intention: 'Clarity',
      language: MysticLanguage.english,
    );

    expect(explanation.positionLabel, contains('What shapes the connection'));
    expect(explanation.orientationLabel, contains('upright'));
    expect(explanation.symbolicBasis, isNotEmpty);
    expect(explanation.practicalBridge, isNotEmpty);
    expect(explanation.contextLabel, contains('curious'));
    expect(explanation.contextLabel, contains('Clarity'));
    expect(explanation.boundary.toLowerCase(), contains('not proof'));
    expect(explanation.boundary.toLowerCase(), contains('prediction score'));
  });

  test('reversed cards disclose how orientation changes the lens', () {
    final explanation = buildReadingExplanation(
      kind: ReadingKind.daily,
      card: reversed,
      positionIndex: 0,
      emotion: EmotionalState.uncertain,
      intention: 'Purpose',
      language: MysticLanguage.english,
    );

    expect(explanation.orientationLabel, contains('reversed'));
    expect(explanation.orientationLabel, contains('blocked'));
  });

  test('all five launch languages receive complete explanations', () {
    const titles = <MysticLanguage, String>{
      MysticLanguage.english: 'Why this interpretation?',
      MysticLanguage.turkish: 'Bu yorum neden çıktı?',
      MysticLanguage.spanish: '¿Por qué esta interpretación?',
      MysticLanguage.french: 'Pourquoi cette interprétation ?',
      MysticLanguage.portugueseBrazil: 'Por que esta interpretação?',
    };

    for (final entry in titles.entries) {
      final explanation = buildReadingExplanation(
        kind: ReadingKind.daily,
        card: upright,
        positionIndex: 2,
        emotion: EmotionalState.hopeful,
        intention: 'Healing',
        language: entry.key,
      );

      expect(explanation.title, entry.value, reason: entry.key.name);
      expect(explanation.positionLabel, isNotEmpty, reason: entry.key.name);
      expect(explanation.orientationLabel, isNotEmpty, reason: entry.key.name);
      expect(explanation.symbolicBasis, isNotEmpty, reason: entry.key.name);
      expect(explanation.practicalBridge, isNotEmpty, reason: entry.key.name);
      expect(explanation.contextLabel, isNotEmpty, reason: entry.key.name);
      expect(explanation.boundary, isNotEmpty, reason: entry.key.name);
    }
  });

  test('positions beyond the spread remain explicit', () {
    final explanation = buildReadingExplanation(
      kind: ReadingKind.daily,
      card: upright,
      positionIndex: 7,
      emotion: EmotionalState.grounded,
      intention: 'Clarity',
      language: MysticLanguage.english,
    );

    expect(explanation.positionLabel, contains('Supporting message 8'));
  });

  testWidgets('explanation panel reveals its evidence without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final explanation = buildReadingExplanation(
      kind: ReadingKind.daily,
      card: reversed,
      positionIndex: 2,
      emotion: EmotionalState.anxious,
      intention: 'Love',
      language: MysticLanguage.french,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ReadingExplanationPanel(explanation: explanation),
          ),
        ),
      ),
    );

    expect(find.text(explanation.title), findsOneWidget);
    await tester.tap(find.text(explanation.title));
    await tester.pumpAndSettle();

    expect(find.text(explanation.symbolicBasis), findsOneWidget);
    expect(find.text(explanation.contextLabel), findsOneWidget);
    expect(find.text(explanation.boundary), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
