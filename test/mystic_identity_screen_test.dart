import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    signals: ['Transformation themes repeat.', 'A 5-day rhythm shows intention.'],
  );

  testWidgets('shows identity, evidence, and evolution progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: MysticIdentityScreen(
          snapshot: snapshot,
          isTurkish: false,
          onContinueJourney: () {},
        ),
      ),
    );

    expect(find.text('The Alchemist'), findsOneWidget);
    expect(find.text('68% identity confidence'), findsOneWidget);
    expect(find.text('The Sage'), findsOneWidget);
    expect(find.text('64%'), findsOneWidget);
    expect(find.text('Transformation themes repeat.'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('uses Turkish navigation copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: MysticIdentityScreen(
          snapshot: snapshot,
          isTurkish: true,
          onContinueJourney: () {},
        ),
      ),
    );

    expect(find.text('MİSTİK RUHUN'), findsOneWidget);
    expect(find.text('Yolculuğuma devam et'), findsOneWidget);
    expect(find.text('%68 kimlik güveni'), findsOneWidget);
  });
}
