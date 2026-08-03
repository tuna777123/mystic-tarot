import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
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

  testWidgets('protected transfer stays usable on a narrow phone',
      (tester) async {
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

    final scrollable = find.byType(Scrollable).first;
    final codeField = find.byKey(const Key('privateTransferCodeField'));
    await tester.scrollUntilVisible(codeField, 220, scrollable: scrollable);
    await tester.enterText(codeField, 'not-a-transfer');
    await tester.scrollUntilVisible(
      find.text('Unlock and validate'),
      120,
      scrollable: scrollable,
    );
    await tester.tap(find.text('Unlock and validate'));
    await tester.pump();
    for (var attempt = 0;
        attempt < 20 &&
            find
                .textContaining('not a valid or supported')
                .evaluate()
                .isEmpty;
        attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(
      find.textContaining('not a valid or supported'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('short creation passphrase is rejected before encryption',
      (tester) async {
    final record = ReadingRecord(
      kind: ReadingKind.daily,
      question: 'What matters?',
      cards: <DrawnCard>[DrawnCard(tarotDeck.first, false)],
      createdAt: DateTime.utc(2026, 8, 4, 8),
      emotion: EmotionalState.curious,
      alignedAction: 'Take one grounded step.',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: PrivateJournalTransferScreen(
          records: <ReadingRecord>[record],
          language: MysticLanguage.english,
          onRestored: (_) {},
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('privateTransferCreatePassphrase')),
      'short',
    );
    await tester.enterText(
      find.byKey(const Key('privateTransferConfirmPassphrase')),
      'short',
    );
    await tester.tap(find.text('Create protected code'));
    await tester.pump();

    expect(find.textContaining('at least 8 characters'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
