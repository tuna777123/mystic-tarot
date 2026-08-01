import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/widgets.dart';

void main() {
  testWidgets('premium preview cancels its reveal timer when dismissed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PremiumReadingPreview(
          kind: ReadingKind.compatibility,
          deckStyle: DeckStyle.midnight,
          language: MysticLanguage.english,
          onUnlock: () {},
        ),
      ),
    );
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('gold action supports long localized labels on narrow phones', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    const label =
        'Débloquer la lecture complète de compatibilité amoureuse';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: GoldButton(
              label: label,
              icon: Icons.auto_awesome,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel(label), findsOneWidget);
    expect(find.text(label), findsOneWidget);
    expect(tester.getSize(find.byType(GoldButton)).height, greaterThanOrEqualTo(56));
    expect(tester.takeException(), isNull);
  });
}
