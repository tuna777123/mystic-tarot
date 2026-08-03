import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_language.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/private_journal_transfer_screen.dart';
import 'package:mystic_tarot/src/tarot_data.dart';
import 'package:mystic_tarot/src/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('private transfer stays usable on a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final records = <ReadingRecord>[
      ReadingRecord(
        kind: ReadingKind.daily,
        question: 'What matters?',
        cards: <DrawnCard>[DrawnCard(tarotDeck.first, false)],
        createdAt: DateTime.utc(2026, 8, 4, 8),
        emotion: EmotionalState.curious,
        alignedAction: 'Take one grounded step.',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: PrivateJournalTransferScreen(
          records: records,
          language: MysticLanguage.english,
          onRestored: (_) {},
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField), 'not-a-transfer');
    await tester.tap(find.text('Validate transfer'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('not a valid or supported'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
