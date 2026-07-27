import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/mystic_living_journal_feature.dart';

void main() {
  testWidgets('Living Journal exposes the Memory Map tab', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MysticLivingJournalFeature(
          records: const [],
          language: MysticLanguage.english,
          onPremium: () {},
        ),
      ),
    );

    expect(find.text('Map'), findsOneWidget);

    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.hub_outlined), findsWidgets);
  });
}
