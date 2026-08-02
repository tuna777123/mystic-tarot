import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/daily_practice.dart';
import 'package:mystic_tarot/src/flagship.dart';

void main() {
  const launchLanguages = [
    MysticLanguage.english,
    MysticLanguage.turkish,
    MysticLanguage.spanish,
    MysticLanguage.french,
    MysticLanguage.portugueseBrazil,
  ];

  test('every launch language receives complete practice choices', () {
    for (final language in launchLanguages) {
      final definitions = dailyPracticeDefinitions(language);
      expect(definitions, hasLength(3));
      expect(definitions.map((item) => item.kind).toSet(), hasLength(3));
      for (final definition in definitions) {
        expect(definition.title.trim(), isNotEmpty);
        expect(definition.body.trim(), isNotEmpty);
        expect(dailyPracticeId(definition.kind), startsWith('daily-'));
      }
      expect(dailyPracticeCta(language).trim(), isNotEmpty);
    }
  });

  testWidgets('French practice sheet fits a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DailyPracticeSheet(language: MysticLanguage.french),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Le rituel privé du jour'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('written intention is required but never returned as data', (
    tester,
  ) async {
    DailyPracticeKind? completed;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  completed = await showDailyPracticeSheet(
                    context: context,
                    language: MysticLanguage.english,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('practice-intention')));
    await tester.pumpAndSettle();

    final completeButton = find.widgetWithText(
      FilledButton,
      'Complete this ritual',
    );
    expect(tester.widget<FilledButton>(completeButton).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('daily-practice-note')),
      'Send one honest message.',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(completeButton).onPressed, isNotNull);

    await tester.tap(completeButton);
    await tester.pumpAndSettle();
    expect(completed, DailyPracticeKind.intention);
  });

  testWidgets('breathing ritual requires the guided cycle', (tester) async {
    DailyPracticeKind? completed;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                completed = await showDailyPracticeSheet(
                  context: context,
                  language: MysticLanguage.english,
                );
              },
              child: const Text('Open breath'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open breath'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('start-breath-practice')));
    await tester.pump(const Duration(seconds: 24));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Complete this ritual'));
    await tester.pumpAndSettle();
    expect(completed, DailyPracticeKind.breath);
  });
}
