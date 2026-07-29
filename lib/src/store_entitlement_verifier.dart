import 'package:in_app_purchase/in_app_purchase.dart';

/// Result returned by the trusted entitlement verification layer.
enum MysticEntitlementVerificationStatus {
  verified,
  rejected,
  unavailable,
}

final class MysticEntitlementVerificationResult {
  const MysticEntitlementVerificationResult(this.status);

  final MysticEntitlementVerificationStatus status;

  bool get isVerified =>
      status == MysticEntitlementVerificationStatus.verified;
}

/// Verifies an App Store or Google Play purchase with a trusted backend.
///
/// Implementations may forward [PurchaseDetails.verificationData] to a secure
/// server. The client must never grant premium access from receipt data alone.
abstract interface class MysticEntitlementVerifier {
  Future<MysticEntitlementVerificationResult> verify(
    PurchaseDetails purchase,
  );
}

/// Production-safe default used until a verification backend is configured.
///
/// Returning [MysticEntitlementVerificationStatus.unavailable] deliberately
/// keeps the purchase pending instead of unlocking premium on the device.
final class DeferredMysticEntitlementVerifier
    implements MysticEntitlementVerifier {
  const DeferredMysticEntitlementVerifier();

  @override
  Future<MysticEntitlementVerificationResult> verify(
    PurchaseDetails purchase,
  ) async =>
      const MysticEntitlementVerificationResult(
        MysticEntitlementVerificationStatus.unavailable,
      );
}
