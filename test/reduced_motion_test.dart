import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/widgets.dart';

void main() {
  Widget backgroundApp({required bool disableAnimations}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: const MysticBackground(child: Scaffold(body: Text('Mystic'))),
    ),
  );

  Widget cardApp({required bool selected}) => MaterialApp(
    home: Scaffold(
      body: Center(child: TarotCardFace(selected: selected)),
    ),
  );

  Finder mysticAnimation() => find.descendant(
    of: find.byType(MysticBackground),
    matching: find.byType(AnimatedBuilder),
  );

  double cardScale(WidgetTester tester) {
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(TarotCardFace),
        matching: find.byType(Transform),
      ),
    );
    return transform.transform.getMaxScaleOnAxis();
  }

  testWidgets('Mystic background honors the reduce-motion preference', (
    tester,
  ) async {
    await tester.pumpWidget(backgroundApp(disableAnimations: true));

    expect(mysticAnimation(), findsNothing);
    expect(find.text('Mystic'), findsOneWidget);

    await tester.pump(const Duration(seconds: 13));
    expect(mysticAnimation(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mystic background responds when motion preference changes', (
    tester,
  ) async {
    await tester.pumpWidget(backgroundApp(disableAnimations: false));
    expect(mysticAnimation(), findsOneWidget);

    await tester.pumpWidget(backgroundApp(disableAnimations: true));
    await tester.pump();
    expect(mysticAnimation(), findsNothing);

    await tester.pumpWidget(backgroundApp(disableAnimations: false));
    await tester.pump();
    expect(mysticAnimation(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tarot card selection honors platform reduced motion', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(cardApp(selected: false));
    await tester.pumpWidget(cardApp(selected: true));
    await tester.pump(const Duration(milliseconds: 20));

    expect(cardScale(tester), closeTo(1.055, .0001));
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tarot card keeps its premium motion when reduction is off', (
    tester,
  ) async {
    await tester.pumpWidget(cardApp(selected: false));
    await tester.pumpWidget(cardApp(selected: true));
    await tester.pump(const Duration(milliseconds: 20));

    expect(cardScale(tester), isNot(closeTo(1.055, .0001)));
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    await tester.pumpAndSettle();
    expect(cardScale(tester), closeTo(1.055, .0001));
    expect(tester.takeException(), isNull);
  });
}
