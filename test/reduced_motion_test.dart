import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/widgets.dart';

void main() {
  Widget app({required bool disableAnimations}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: const MysticBackground(
            child: Scaffold(body: Text('Mystic')),
          ),
        ),
      );

  Finder mysticAnimation() => find.descendant(
        of: find.byType(MysticBackground),
        matching: find.byType(AnimatedBuilder),
      );

  testWidgets('Mystic background honors the reduce-motion preference', (
    tester,
  ) async {
    await tester.pumpWidget(app(disableAnimations: true));

    expect(mysticAnimation(), findsNothing);
    expect(find.text('Mystic'), findsOneWidget);

    await tester.pump(const Duration(seconds: 13));
    expect(mysticAnimation(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mystic background responds when motion preference changes', (
    tester,
  ) async {
    await tester.pumpWidget(app(disableAnimations: false));
    expect(mysticAnimation(), findsOneWidget);

    await tester.pumpWidget(app(disableAnimations: true));
    await tester.pump();
    expect(mysticAnimation(), findsNothing);

    await tester.pumpWidget(app(disableAnimations: false));
    await tester.pump();
    expect(mysticAnimation(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
