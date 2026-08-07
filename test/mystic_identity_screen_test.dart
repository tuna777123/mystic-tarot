import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_language.dart';
import 'package:mystic_tarot/src/identity_engine.dart';
import 'package:mystic_tarot/src/mystic_identity_screen.dart';
import 'package:mystic_tarot/src/theme.dart';

void main() {
  const snapshot = MysticIdentitySnapshot(
    primary: MysticArchetype.alchemist,
    secondary: MysticArchetype.seeker,
    confidence: 68,
    title: 'The Alchemist',
    summary: 'You transform uncertainty into action.',
    nextEvolution: 'The Sage',
    progressToEvolution: .64,
    signals: [
      'Transformation themes repeat.',
      'A 5-day rhythm shows intention.',
    ],
  );

  Future<void> pumpLanguage(WidgetTester tester, AppLanguage language) =>
      tester.pumpWidget(
        MaterialApp(
          theme: buildMysticTheme(),
          home: MysticIdentityScreen(
            snapshot: snapshot,
            language: language,
            onContinueJourney: () {},
          ),
        ),
      );

  testWidgets('shows identity, evidence, and evolution progress', (
    tester,
  ) async {
    await pumpLanguage(tester, AppLanguage.english);

    expect(find.text('The Alchemist'), findsOneWidget);
    expect(find.text('68% identity confidence'), findsOneWidget);
    expect(find.text('The Sage'), findsOneWidget);
    expect(find.text('64%'), findsOneWidget);
    expect(find.text('Transformation themes repeat.'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  final localizedHeaders = <AppLanguage, String>{
    AppLanguage.english: 'YOUR MYSTIC SOUL',
    AppLanguage.spanish: 'TU ALMA MÍSTICA',
    AppLanguage.french: 'VOTRE ÂME MYSTIQUE',
    AppLanguage.portugueseBrazil: 'SUA ALMA MÍSTICA',
    AppLanguage.turkish: 'MİSTİK RUHUN',
    AppLanguage.italian: 'LA TUA ANIMA MISTICA',
    AppLanguage.german: 'DEINE MYSTISCHE SEELE',
  };

  for (final entry in localizedHeaders.entries) {
    testWidgets('renders ${entry.key.name} interface copy', (tester) async {
      await pumpLanguage(tester, entry.key);
      expect(find.text(entry.value), findsOneWidget);
    });
  }

  test('English is the default for unknown persisted values', () {
    expect(AppLanguage.fromName(null), AppLanguage.english);
    expect(AppLanguage.fromName('unsupported'), AppLanguage.english);
  });

  test('all requested languages are available', () {
    expect(AppLanguage.values, [
      AppLanguage.english,
      AppLanguage.spanish,
      AppLanguage.french,
      AppLanguage.portugueseBrazil,
      AppLanguage.turkish,
      AppLanguage.italian,
      AppLanguage.german,
    ]);
  });
}
