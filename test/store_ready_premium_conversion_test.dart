import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/store_purchase_service.dart';
import 'package:mystic_tarot/src/store_ready_premium_screen.dart';
import 'package:mystic_tarot/src/theme.dart';

void main() {
  testWidgets('free access surface fits a narrow phone without checkout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = StorePurchaseService();
    addTearDown(service.dispose);
    await service.initialize();

    await _pumpAccess(tester, service);

    expect(find.text('Everything is unlocked.'), findsOneWidget);
    expect(
      find.textContaining('there is no subscription to buy'),
      findsOneWidget,
    );
    expect(find.text('All readings and spreads'), findsOneWidget);
    expect(find.text('Mystic Mirror · 24h reality check'), findsOneWidget);
    expect(find.textContaining('Living Journal'), findsOneWidget);
    expect(find.textContaining(r'$39.99'), findsNothing);
    expect(find.textContaining('Manage subscription'), findsNothing);
    expect(find.textContaining('Restore'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Continue free'),
      180,
      scrollable: find.byType(ListView),
    );
    expect(find.text('Continue free'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('continue free closes the historical paywall route', (
    tester,
  ) async {
    final service = StorePurchaseService();
    addTearDown(service.dispose);
    await service.initialize();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => StoreReadyPremiumScreen(
                      source: 'organic',
                      language: MysticLanguage.english,
                      subscriptionStore: service,
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Continue free'),
      180,
      scrollable: find.byType(ListView),
    );
    expect(find.text('Continue free'), findsOneWidget);

    await tester.tap(find.text('Continue free'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Turkish disclosure states ads are the only revenue model', (
    tester,
  ) async {
    final service = StorePurchaseService();
    addTearDown(service.dispose);
    await service.initialize();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: StoreReadyPremiumScreen(
          source: 'organic',
          language: MysticLanguage.turkish,
          subscriptionStore: service,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Her şey açık.'), findsOneWidget);
    expect(
      find.textContaining('satın alınacak abonelik yoktur'),
      findsOneWidget,
    );
    expect(find.textContaining('reklamlardan gelir'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ücretsiz devam et'),
      180,
      scrollable: find.byType(ListView),
    );
    expect(find.text('Ücretsiz devam et'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpAccess(
  WidgetTester tester,
  StorePurchaseService service,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildMysticTheme(),
      home: StoreReadyPremiumScreen(
        source: 'organic',
        language: MysticLanguage.english,
        subscriptionStore: service,
      ),
    ),
  );
  await tester.pump();
}
