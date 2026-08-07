import 'monetization.dart';

enum StorePlatform { apple, google }

/// Receipt data sent to a trusted backend. The client must never use this
/// request as proof of premium access.
class EntitlementVerificationRequest {
  const EntitlementVerificationRequest({
    required this.platform,
    required this.productId,
    required this.verificationData,
    required this.purchaseId,
  });

  final StorePlatform platform;
  final String productId;
  final String verificationData;
  final String purchaseId;

  bool get targetsLaunchProduct => MysticProductIds.launch.contains(productId);

  Map<String, Object> toJson() => {
    'platform': platform.name,
    'productId': productId,
    'verificationData': verificationData,
    'purchaseId': purchaseId,
  };
}

/// Server-authoritative response. Only a successfully verified, active
/// entitlement may unlock Mystic Plus.
class EntitlementVerificationResult {
  const EntitlementVerificationResult({
    required this.verified,
    required this.entitlement,
    required this.serverTime,
  });

  final bool verified;
  final MysticEntitlement entitlement;
  final DateTime serverTime;

  bool get grantsPlus => verified && entitlement.isActiveAt(serverTime);

  factory EntitlementVerificationResult.denied(DateTime serverTime) =>
      EntitlementVerificationResult(
        verified: false,
        entitlement: const MysticEntitlement.free(),
        serverTime: serverTime,
      );
}

abstract interface class EntitlementVerifier {
  Future<EntitlementVerificationResult> verify(
    EntitlementVerificationRequest request,
  );
}
