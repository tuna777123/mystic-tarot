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

  Widget cardApp({required bool disableAnimations, required bool selected}) =>
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: Scaffold(
            body: Center(child: TarotCardFace(selected: selected)),
          ),
        ),
      );

  Finder mysticAnimation() => find.descendant(
    of: find.byType(MysticBackground),
    matching: find.byType(AnimatedBuilder),
  );

  Finder cardScaleAnimation() => find.descendant(
    of: find.byType(TarotCardFace),
    matching: find.byWidgetPredicate(
      (widget) => widget is TweenAnimationBuilder<double>,
    ),
  );

  AnimatedContainer cardContainer(WidgetTester tester) =>
      tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(TarotCardFace),
          matching: find.byType(AnimatedContainer),
        ),
      );

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

  testWidgets('tarot card selection removes motion but keeps selection', (
    tester,
  ) async {
    await tester.pumpWidget(cardApp(disableAnimations: true, selected: false));

    expect(cardScaleAnimation(), findsNothing);
    expect(cardContainer(tester).duration, Duration.zero);

    await tester.pumpWidget(cardApp(disableAnimations: true, selected: true));
    await tester.pump();

    expect(cardScaleAnimation(), findsNothing);
    final selectedCard = cardContainer(tester);
    expect(selectedCard.duration, Duration.zero);
    final decoration = selectedCard.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    expect(border.top.width, 2.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tarot card selection keeps the premium motion normally', (
    tester,
  ) async {
    await tester.pumpWidget(cardApp(disableAnimations: false, selected: true));

    expect(cardScaleAnimation(), findsOneWidget);
    expect(cardContainer(tester).duration, const Duration(milliseconds: 320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tarot cards respond when motion preference changes', (
    tester,
  ) async {
    await tester.pumpWidget(cardApp(disableAnimations: false, selected: true));
    expect(cardScaleAnimation(), findsOneWidget);

    await tester.pumpWidget(cardApp(disableAnimations: true, selected: true));
    await tester.pump();
    expect(cardScaleAnimation(), findsNothing);
    expect(cardContainer(tester).duration, Duration.zero);

    await tester.pumpWidget(cardApp(disableAnimations: false, selected: true));
    await tester.pump();
    expect(cardScaleAnimation(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
