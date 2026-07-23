import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/monetization.dart';
import 'package:mystic_tarot/src/paywall.dart';

void main() {
  testWidgets('renders yearly-first launch offers and safe web messaging', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MysticPaywallScreen(
        source: PaywallSource.dailyLimit,
        priceByPlan: {
          MysticPlan.yearly: r'$39.99/year',
          MysticPlan.monthly: r'$6.99/month',
        },
      ),
    ));

    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text(r'$39.99/year'), findsOneWidget);
    expect(find.text(r'$6.99/month'), findsOneWidget);
    expect(find.text('Start 7-day free trial'), findsOneWidget);
    expect(find.textContaining('free deep-reading limit'), findsOneWidget);
    expect(find.textContaining('No payment is processed'), findsOneWidget);
  });
}
