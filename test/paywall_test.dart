import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/monetization.dart';
import 'package:mystic_tarot/src/paywall.dart';

void main() {
  testWidgets('yearly is selected first and web checkout stays disabled', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MysticPaywallScreen(source: PaywallSource.organic)));

    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Start 7-day free trial'), findsOneWidget);
    expect(find.textContaining('No payment is processed'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('monthly can be selected and localized prices render', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MysticPaywallScreen(
        source: PaywallSource.premiumSpread,
        priceByPlan: {
          MysticPlan.yearly: r'$39.99/year',
          MysticPlan.monthly: r'$6.99/month',
        },
      ),
    ));

    expect(find.text(r'$39.99/year'), findsOneWidget);
    expect(find.text(r'$6.99/month'), findsOneWidget);

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();

    expect(find.text('Continue with monthly'), findsOneWidget);
  });

  testWidgets('source-specific copy is shown', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MysticPaywallScreen(source: PaywallSource.dailyLimit)));
    expect(find.textContaining('free deep-reading limit'), findsOneWidget);
  });
}
