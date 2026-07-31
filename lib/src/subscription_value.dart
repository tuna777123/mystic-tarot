import 'subscription_client.dart';

int? yearlySavingsPercent({
  required SubscriptionProduct? monthly,
  required SubscriptionProduct? yearly,
}) {
  if (monthly == null || yearly == null) return null;
  final monthlyPrice = monthly.priceValue;
  final yearlyPrice = yearly.priceValue;
  if (monthlyPrice == null || yearlyPrice == null || monthlyPrice <= 0) {
    return null;
  }
  if (monthly.currencyCode != null &&
      yearly.currencyCode != null &&
      monthly.currencyCode != yearly.currencyCode) {
    return null;
  }

  final annualizedMonthly = monthlyPrice * 12;
  if (yearlyPrice >= annualizedMonthly) return null;
  final percent =
      ((annualizedMonthly - yearlyPrice) / annualizedMonthly * 100).round();
  return percent.clamp(1, 99);
}

String? yearlyMonthlyEquivalent(SubscriptionProduct? yearly) {
  if (yearly == null) return null;
  final formatted = yearly.pricePerMonth?.trim();
  return formatted == null || formatted.isEmpty ? null : formatted;
}
