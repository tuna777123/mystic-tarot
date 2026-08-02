import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/growth_engine.dart';
import 'package:mystic_tarot/src/mystic_next_step.dart';
import 'package:mystic_tarot/src/theme.dart';

MysticGrowthSnapshot snapshot(
  MysticNextActionType type, {
  MysticGrowthStage stage = MysticGrowthStage.engaged,
  MysticReturnState returnState = MysticReturnState.returnedNextDay,
}) =>
    MysticGrowthSnapshot(
      stage: stage,
      nextAction: MysticNextAction(
        type: type,
        title: 'Internal title',
        body: 'Internal body',
        cta: 'Internal CTA',
        priority: 90,
      ),
      returnState: returnState,
      returnMessage: 'Internal return message',
      premiumValueScore: 40,
      hasVisiblePattern: type == MysticNextActionType.reviewPattern,
    );

Widget app({
  required MysticLanguage language,
  required MysticNextActionType type,
  VoidCallback? onTap,
}) =>
    MaterialApp(
      theme: buildMysticTheme(),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: MysticNextStepCard(
            snapshot: snapshot(type),
            language: language,
            streak: 6,
            mirrorDueCount: 2,
            completedArcanaDays: 4,
            freeReadingsLeft: 2,
            onTap: onTap ?? () {},
          ),
        ),
      ),
    );

void main() {
  const launchLanguages = [
    MysticLanguage.english,
    MysticLanguage.turkish,
    MysticLanguage.spanish,
    MysticLanguage.french,
    MysticLanguage.portugueseBrazil,
  ];

  testWidgets('every launch language renders a complete next step', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final language in launchLanguages) {
      await tester.pumpWidget(
        app(
          language: language,
          type: MysticNextActionType.mirrorCheckIn,
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('mystic-next-step-card')),
        findsOneWidget,
      );
      expect(find.text('Internal title'), findsNothing);
      expect(find.text('Internal CTA'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('card triggers the supplied next action', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        language: MysticLanguage.english,
        type: MysticNextActionType.dailyReading,
        onTap: () => taps += 1,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('mystic-next-step-card')));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('all action types remain readable on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final type in MysticNextActionType.values) {
      await tester.pumpWidget(
        app(language: MysticLanguage.french, type: type),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });
}
