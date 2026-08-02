import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/oracle_memory_action.dart';

void main() {
  testWidgets('every launch language renders a usable Oracle memory action', (
    tester,
  ) async {
    for (final language in <MysticLanguage>[
      MysticLanguage.english,
      MysticLanguage.turkish,
      MysticLanguage.spanish,
      MysticLanguage.french,
      MysticLanguage.portugueseBrazil,
    ]) {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: OracleMemoryAction(
                turnCount: 2,
                language: language,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(OracleMemoryAction));
      await tester.pump();
      expect(tapped, isTrue);
    }
  });

  testWidgets('new readings expose a grounded Oracle invitation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OracleMemoryAction(
            turnCount: 0,
            language: MysticLanguage.english,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Ask the Oracle'), findsOneWidget);
    expect(
      find.text('Continue this reading with one grounded follow-up'),
      findsOneWidget,
    );
  });
}
