import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_intelligence_teaser.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

void main() {
  final now = DateTime(2026, 8, 2, 12);

  ReadingRecord record(int daysAgo, int cardIndex) => ReadingRecord(
    kind: ReadingKind.love,
    question: 'Question',
    cards: <DrawnCard>[DrawnCard(tarotDeck[cardIndex], false)],
    createdAt: now.subtract(Duration(days: daysAgo)),
    emotion: EmotionalState.curious,
    alignedAction: 'Action',
  );

  testWidgets('shows exact report readiness before three readings', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MysticIntelligenceTeaser(
            records: <ReadingRecord>[record(1, 0)],
            language: MysticLanguage.turkish,
            isPlus: false,
            onOpen: () {},
            now: now,
          ),
        ),
      ),
    );

    expect(find.text('1/3'), findsOneWidget);
    expect(find.textContaining('2 kayıtlı okuma'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reveals a real recurring symbol when the report is ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MysticIntelligenceTeaser(
            records: <ReadingRecord>[
              record(1, 6),
              record(2, 6),
              record(3, 1),
              record(8, 15),
            ],
            language: MysticLanguage.english,
            isPlus: false,
            onOpen: () {},
            now: now,
          ),
        ),
      ),
    );

    expect(find.text('READY'), findsOneWidget);
    expect(find.textContaining('has started repeating'), findsOneWidget);
    expect(find.text('Open report'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('is tappable and supports narrow localized layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: MysticIntelligenceTeaser(
              records: <ReadingRecord>[
                record(1, 0),
                record(2, 1),
                record(3, 2),
              ],
              language: MysticLanguage.french,
              isPlus: true,
              onOpen: () => opened = true,
              now: now,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MysticIntelligenceTeaser));
    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });
}
