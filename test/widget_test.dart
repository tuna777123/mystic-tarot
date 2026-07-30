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
    expect(find.textContaining('Kararsız'), findsOneWidget);
    expect(
      find.text(
        'Breathe slowly. Hold your question in mind, then choose the cards that call to you.',
      ),
      findsNothing,
    );
  });

  testWidgets('saved Turkish preference restores the Turkish shell',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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

  test('launch language selector exposes only complete languages', () {
    expect(
      launchLanguages,
      const [MysticLanguage.english, MysticLanguage.turkish],
    );
  });

  testWidgets('Turkish remains active in profile and settings',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'allow_reversals': true,
      'sound_effects': true,
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: SoulProfileScreen(
          initialName: 'Tuna',
          initialIntention: 'Clarity',
          language: MysticLanguage.turkish,
          onSave: (_, __) {},
        ),
      ),
    );

    expect(find.text('Ruh profili'), findsOneWidget);
    expect(find.text('Mystic’i kendine göre şekillendir'), findsOneWidget);
    expect(find.text('Ruh profilimi kaydet'), findsOneWidget);
    expect(find.text('Make Mystic yours'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MysticSettingsScreen(
          section: 'Reading preferences',
          title: 'Okuma tercihleri',
          language: MysticLanguage.turkish,
          records: const [],
          onDeleteData: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Okuma tercihleri'), findsOneWidget);
    expect(find.text('Ters kartlara izin ver'), findsOneWidget);
    expect(find.text('Daily Guidance reminder'), findsNothing);
  });

  testWidgets('Turkish premium preview never falls back to English',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: PremiumReadingPreview(
          kind: ReadingKind.compatibility,
          deckStyle: DeckStyle.midnight,
          language: MysticLanguage.turkish,
          onUnlock: () {},
        ),
      ),
    );

    expect(find.text('Aşk Uyumu'), findsOneWidget);
    expect(find.text('PLUS ÖNİZLEME'), findsOneWidget);
    expect(find.textContaining('kartlık hikâyenin tamamı'), findsOneWidget);
    expect(find.text('PLUS PREVIEW'), findsNothing);
  });
}
