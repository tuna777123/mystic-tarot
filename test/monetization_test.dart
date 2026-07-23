import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/monetization.dart';

void main() {
  group('Mystic launch catalog', () {
    test('offers yearly first and excludes weekly', () {
      expect(MysticOffer.launchCatalog.map((offer) => offer.plan), [
        MysticPlan.yearly,
        MysticPlan.monthly,
      ]);
      expect(MysticOffer.launchCatalog.length, 2);
    });

    test('only yearly includes the launch trial', () {
      expect(MysticPlan.yearly.includesTrial, isTrue);
      expect(MysticPlan.yearly.trialDays, 7);
      expect(MysticPlan.monthly.includesTrial, isFalse);
      expect(MysticPlan.monthly.trialDays, 0);
    });
  });

  group('Mystic entitlement', () {
    final now = DateTime(2026, 7, 24);

    test('free users never receive Plus access', () {
      const entitlement = MysticEntitlement.free();
      expect(entitlement.isActiveAt(now), isFalse);
    });

    test('valid purchases remain active before expiration', () {
      final entitlement = MysticEntitlement(
        isPlus: true,
        plan: MysticPlan.yearly,
        expiresAt: now.add(const Duration(days: 30)),
        status: PurchaseStatus.purchased,
      );
      expect(entitlement.isActiveAt(now), isTrue);
    });

    test('expired and refunded purchases are denied', () {
      final expired = MysticEntitlement(
        isPlus: true,
        plan: MysticPlan.monthly,
        expiresAt: now.subtract(const Duration(seconds: 1)),
        status: PurchaseStatus.expired,
      );
      const refunded = MysticEntitlement(
        isPlus: true,
        plan: MysticPlan.yearly,
        status: PurchaseStatus.refunded,
      );
      expect(expired.isActiveAt(now), isFalse);
      expect(refunded.isActiveAt(now), isFalse);
    });
  });

  test('paywall source mapping is deterministic', () {
    expect(paywallSourceFromName('daily_limit'), PaywallSource.dailyLimit);
    expect(paywallSourceFromName('premium_spread'), PaywallSource.premiumSpread);
    expect(paywallSourceFromName('unknown'), PaywallSource.organic);
  });
}
