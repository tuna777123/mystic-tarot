import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_mirror.dart';
import 'package:mystic_tarot/src/mystic_plus_intelligence.dart';
import 'package:mystic_tarot/src/mystic_plus_intelligence_screen.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

void main() {
  final now = DateTime(2026, 8, 2, 12);

  ReadingRecord record({
    required int daysAgo,
    required ReadingKind kind,
    required EmotionalState emotion,
    required int cardIndex,
  }) =>
      ReadingRecord(
        kind: kind,
        question: 'Question $daysAgo',
        cards: <DrawnCard>[DrawnCard(tarotDeck[cardIndex], false)],
        createdAt: now.subtract(Duration(days: daysAgo)),
        emotion: emotion,
        alignedAction: 'One observable action',
      );

  test('builds a deterministic seven-day private intelligence report', () {
    final records = <ReadingRecord>[
      record(
        daysAgo: 1,
        kind: ReadingKind.love,
        emotion: EmotionalState.uncertain,
        cardIndex: 6,
      ),
      record(
        daysAgo: 2,
        kind: ReadingKind.love,
        emotion: EmotionalState.uncertain,
        cardIndex: 6,
      ),
      record(
        daysAgo: 3,
        kind: ReadingKind.career,
        emotion: EmotionalState.curious,
        cardIndex: 1,
      ),
      record(
        daysAgo: 8,
        kind: ReadingKind.shadow,
        emotion: EmotionalState.anxious,
        cardIndex: 15,
      ),
    ];

    final report = MysticPlusIntelligence.analyze(
      records: records,
      reflections: const <String, MysticMirrorReflection>{},
      generatedAt: now,
    );

    expect(report.readingCount, 3);
    expect(report.activeDays, 3);
    expect(report.uniqueCardCount, 2);
    expect(report.topCardName, tarotDeck[6].name);
    expect(report.topCardCount, 2);
    expect(report.topReadingKind, ReadingKind.love);
    expect(report.topReadingKindCount, 2);
    expect(report.dominantStartingEmotion, EmotionalState.uncertain);
    expect(report.hasEnoughHistory, isTrue);
  });

  test('measures completed reality loops and emotional lift transparently', () {
    final first = record(
      daysAgo: 3,
      kind: ReadingKind.decision,
      emotion: EmotionalState.anxious,
      cardIndex: 2,
    );
    final second = record(
      daysAgo: 2,
      kind: ReadingKind.spiritual,
      emotion: EmotionalState.uncertain,
      cardIndex: 3,
    );
    final third = record(
      daysAgo: 0,
      kind: ReadingKind.daily,
      emotion: EmotionalState.hopeful,
      cardIndex: 4,
    );
    final reflections = <String, MysticMirrorReflection>{
      mysticMirrorRecordId(first): MysticMirrorReflection(
        recordId: mysticMirrorRecordId(first),
        outcome: MysticMirrorOutcome.shifted,
        emotion: EmotionalState.grounded,
        note: 'The action helped.',
        completedAt: now.subtract(const Duration(days: 1)),
      ),
      mysticMirrorRecordId(second): MysticMirrorReflection(
        recordId: mysticMirrorRecordId(second),
        outcome: MysticMirrorOutcome.unchanged,
        emotion: EmotionalState.uncertain,
        note: '',
        completedAt: now.subtract(const Duration(hours: 12)),
      ),
    };

    final report = MysticPlusIntelligence.analyze(
      records: <ReadingRecord>[first, second, third],
      reflections: reflections,
      generatedAt: now,
    );

    expect(report.mirrorEligibleCount, 2);
    expect(report.mirrorCompletedCount, 2);
    expect(report.mirrorShiftCount, 1);
    expect(report.mirrorCompletionRate, 1);
    expect(report.mirrorShiftRate, .5);
    expect(report.emotionalComparisonCount, 2);
    expect(report.emotionalLiftCount, 1);
    expect(report.emotionalLiftRate, .5);
  });

  test('reports exactly how many readings remain before the first report', () {
    final report = MysticPlusIntelligence.analyze(
      records: <ReadingRecord>[
        record(
          daysAgo: 1,
          kind: ReadingKind.daily,
          emotion: EmotionalState.curious,
          cardIndex: 0,
        ),
      ],
      reflections: const <String, MysticMirrorReflection>{},
      generatedAt: now,
    );

    expect(report.hasEnoughHistory, isFalse);
    expect(report.readingsUntilReady, 2);
  });

  test('rejects a non-positive report window', () {
    expect(
      () => MysticPlusIntelligence.analyze(
        records: const <ReadingRecord>[],
        reflections: const <String, MysticMirrorReflection>{},
        generatedAt: now,
        window: Duration.zero,
      ),
      throwsArgumentError,
    );
  });

  testWidgets('free users receive a personalized report preview without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final records = <ReadingRecord>[
      record(
        daysAgo: 1,
        kind: ReadingKind.love,
        emotion: EmotionalState.uncertain,
        cardIndex: 6,
      ),
      record(
        daysAgo: 2,
        kind: ReadingKind.love,
        emotion: EmotionalState.hopeful,
        cardIndex: 6,
      ),
      record(
        daysAgo: 3,
        kind: ReadingKind.career,
        emotion: EmotionalState.curious,
        cardIndex: 1,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: MysticPlusIntelligenceScreen(
          source: 'organic',
          language: MysticLanguage.turkish,
          isPlus: false,
          onContinue: () {},
          initialRecords: records,
          initialReflections: const <String, MysticMirrorReflection>{},
          generatedAt: now,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('ÖNİZLEME'), findsOneWidget);
    expect(find.text('Tam raporun kilidini aç'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView), const Offset(0, -650));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byIcon(Icons.lock_outline), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Plus members see the full reality and emotion report', (
    tester,
  ) async {
    final first = record(
      daysAgo: 3,
      kind: ReadingKind.decision,
      emotion: EmotionalState.anxious,
      cardIndex: 2,
    );
    final records = <ReadingRecord>[
      first,
      record(
        daysAgo: 2,
        kind: ReadingKind.spiritual,
        emotion: EmotionalState.curious,
        cardIndex: 3,
      ),
      record(
        daysAgo: 1,
        kind: ReadingKind.daily,
        emotion: EmotionalState.hopeful,
        cardIndex: 4,
      ),
    ];
    final mirrors = <String, MysticMirrorReflection>{
      mysticMirrorRecordId(first): MysticMirrorReflection(
        recordId: mysticMirrorRecordId(first),
        outcome: MysticMirrorOutcome.shifted,
        emotion: EmotionalState.grounded,
        note: 'A real change.',
        completedAt: now.subtract(const Duration(days: 1)),
      ),
    };

    await tester.pumpWidget(
      MaterialApp(
        home: MysticPlusIntelligenceScreen(
          source: 'organic',
          language: MysticLanguage.english,
          isPlus: true,
          onContinue: () {},
          initialRecords: records,
          initialReflections: mirrors,
          generatedAt: now,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('ACTIVE'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('REALITY LOOP'), findsOneWidget);
    expect(find.text('EMOTIONAL DIRECTION'), findsOneWidget);
    expect(find.text('NEXT GROUNDED PRACTICE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
