import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/subscription_client.dart';
import 'package:mystic_tarot/src/subscription_value.dart';

void main() {
  const monthly = SubscriptionProduct(
    id: 'monthly',
    title: 'Monthly',
    description: 'Monthly access',
    price: r'$10.00',
    priceValue: 10,
    currencyCode: 'USD',
  );

  test('calculates honest yearly savings from official prices', () {
    const yearly = SubscriptionProduct(
      id: 'yearly',
      title: 'Yearly',
      description: 'Yearly access',
      price: r'$84.00',
      priceValue: 84,
      currencyCode: 'USD',
      pricePerMonth: r'$7.00',
    );

    expect(
      yearlySavingsPercent(monthly: monthly, yearly: yearly),
      30,
    );
    expect(yearlyMonthlyEquivalent(yearly), r'$7.00');
  });

  test('does not invent savings when yearly is not cheaper', () {
    const yearly = SubscriptionProduct(
      id: 'yearly',
      title: 'Yearly',
      description: 'Yearly access',
      price: r'$120.00',
      priceValue: 120,
      currencyCode: 'USD',
    );

    expect(
      yearlySavingsPercent(monthly: monthly, yearly: yearly),
      isNull,
    );
  });

  test('does not compare prices from different currencies', () {
    const yearly = SubscriptionProduct(
      id: 'yearly',
      title: 'Yearly',
      description: 'Yearly access',
      price: '₺900',
      priceValue: 900,
      currencyCode: 'TRY',
    );

    expect(
      yearlySavingsPercent(monthly: monthly, yearly: yearly),
      isNull,
    );
  });
}
