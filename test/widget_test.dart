import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the Mystic onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MysticApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Your patterns are\nalready speaking.'), findsOneWidget);
    expect(find.text('Begin my journey'), findsOneWidget);
  });

  testWidgets('privacy policy describes local-first storage', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const LegalDocumentScreen(title: 'Privacy Policy'),
      ),
    );

    expect(find.text('Privacy, in plain language'), findsOneWidget);
    expect(
      find.textContaining('transmit journal content to us'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Effective July 23, 2026'),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Effective July 23, 2026'), findsOneWidget);
  });

  testWidgets('terms identify the product as reflection', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: const LegalDocumentScreen(title: 'Terms of Use'),
      ),
    );

    expect(find.text('A fair mystical space'), findsOneWidget);
    expect(find.textContaining('self-reflection and entertainment'), findsOneWidget);
  });

  testWidgets('living fate map is visible in both launch languages', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Column(
            children: [
              DestinyFlagshipCard(
                records: const [],
                completedDays: const {},
                language: MysticLanguage.english,
                onOpen: () {},
              ),
              DestinyFlagshipCard(
                records: const [],
                completedDays: const {},
                language: MysticLanguage.turkish,
                onOpen: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('LIVING FATE MAP'), findsOneWidget);
    expect(find.text('YAŞAYAN KADER HARİTASI'), findsOneWidget);
    expect(find.textContaining('Day 1 of 22'), findsOneWidget);
    expect(find.textContaining('22 günün 1. günü'), findsOneWidget);
  });

  testWidgets('destiny hub opens its private empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: DestinyHubScreen(
          records: const [],
          completedDays: const {},
          reflections: const {},
          lastCompletionDay: null,
          language: MysticLanguage.english,
          onCompleteChapter: (_, __) {},
          onStartReading: () {},
        ),
      ),
    );
    expect(find.text('My Living Path'), findsOneWidget);
    expect(find.text('Fate Map'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Create my first signal'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Create my first signal'), findsOneWidget);
  });

  testWidgets('Turkish remains active inside the card selection flow',
      (tester) async {
    SharedPreferences.setMockInitialValues({'allow_reversals': true});
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: ReadingFlow(
          kind: ReadingKind.daily,
          deckStyle: DeckStyle.midnight,
          userName: 'Tuna',
          intention: 'Clarity',
          language: MysticLanguage.turkish,
          pastRecords: const [],
          onPremium: () {},
          onComplete: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Günlük Rehberlik'), findsOneWidget);
    expect(find.text('ŞU ANDA NASIL HİSSEDİYORSUN?'), findsOneWidget);
    expect(find.text('Sorunu yaz (isteğe bağlı)'), findsOneWidget);
    expect(find.text('Kararsız'), findsOneWidget);
    expect(
      find.text(
        'Breathe slowly. Hold your question in mind, then choose the cards that call to you.',
      ),
      findsNothing,
    );
  });

  testWidgets('saved Turkish preference restores the Turkish shell',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarded': true,
      'language': 'turkish',
    });
    await tester.pumpWidget(const MysticApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Oku'), findsOneWidget);
    expect(find.text('Yol'), findsOneWidget);
    expect(find.text('Günlük'), findsOneWidget);
    expect(find.text('Sen'), findsOneWidget);
  });
}
