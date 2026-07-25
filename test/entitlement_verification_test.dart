import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/entitlement_verification.dart';
import 'package:mystic_tarot/src/monetization.dart';

void main() {
  final serverTime = DateTime.utc(2026, 7, 26);

  test('only launch products are accepted for verification', () {
    const monthly = EntitlementVerificationRequest(
      platform: StorePlatform.apple,
      productId: MysticProductIds.monthly,
      verificationData: 'signed-store-payload',
      purchaseId: 'purchase-1',
    );
    const weekly = EntitlementVerificationRequest(
      platform: StorePlatform.google,
      productId: MysticProductIds.weekly,
      verificationData: 'signed-store-payload',
      purchaseId: 'purchase-2',
    );

    expect(monthly.targetsLaunchProduct, isTrue);
    expect(weekly.targetsLaunchProduct, isFalse);
  });

  test('unverified result never grants Plus', () {
    final result = EntitlementVerificationResult(
      verified: false,
      entitlement: MysticEntitlement(
        isPlus: true,
        plan: MysticPlan.yearly,
        expiresAt: serverTime.add(const Duration(days: 30)),
        status: PurchaseStatus.purchased,
      ),
      serverTime: serverTime,
    );

    expect(result.grantsPlus, isFalse);
  });

  test('verified active entitlement grants Plus', () {
    final result = EntitlementVerificationResult(
      verified: true,
      entitlement: MysticEntitlement(
        isPlus: true,
        plan: MysticPlan.monthly,
        expiresAt: serverTime.add(const Duration(days: 30)),
        status: PurchaseStatus.purchased,
      ),
      serverTime: serverTime,
    );

    expect(result.grantsPlus, isTrue);
  });

  test('verified expired entitlement is denied', () {
    final result = EntitlementVerificationResult(
      verified: true,
      entitlement: MysticEntitlement(
        isPlus: true,
        plan: MysticPlan.monthly,
        expiresAt: serverTime.subtract(const Duration(seconds: 1)),
        status: PurchaseStatus.expired,
      ),
      serverTime: serverTime,
    );

    expect(result.grantsPlus, isFalse);
  });
}
