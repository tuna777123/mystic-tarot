import 'package:shared_preferences/shared_preferences.dart';

/// A previously server-verified entitlement snapshot.
///
/// This cache is advisory only. It may improve continuity and explain the
/// membership state after restart, but it must never replace server-side
/// entitlement verification for protected premium features.
final class MysticEntitlementSnapshot {
  const MysticEntitlementSnapshot({
    required this.productId,
    required this.verifiedAt,
    required this.expiresAt,
  });

  final String productId;
  final DateTime verifiedAt;
  final DateTime expiresAt;

  bool isActiveAt(DateTime now) => expiresAt.isAfter(now.toUtc());
}

abstract interface class MysticEntitlementCache {
  Future<MysticEntitlementSnapshot?> load();

  Future<void> save(MysticEntitlementSnapshot snapshot);

  Future<void> clear();
}

/// Shared-preferences implementation for non-authoritative entitlement state.
///
/// No receipt, purchase token, account identifier, or payment details are
/// stored. A trusted verifier remains the source of truth.
final class SharedPreferencesMysticEntitlementCache
    implements MysticEntitlementCache {
  const SharedPreferencesMysticEntitlementCache();

  static const _productIdKey = 'mystic_entitlement_product_id';
  static const _verifiedAtKey = 'mystic_entitlement_verified_at';
  static const _expiresAtKey = 'mystic_entitlement_expires_at';

  @override
  Future<MysticEntitlementSnapshot?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final productId = preferences.getString(_productIdKey);
    final verifiedAtValue = preferences.getString(_verifiedAtKey);
    final expiresAtValue = preferences.getString(_expiresAtKey);

    if (productId == null || verifiedAtValue == null || expiresAtValue == null) {
      return null;
    }

    final verifiedAt = DateTime.tryParse(verifiedAtValue)?.toUtc();
    final expiresAt = DateTime.tryParse(expiresAtValue)?.toUtc();
    if (verifiedAt == null || expiresAt == null) {
      await clear();
      return null;
    }

    return MysticEntitlementSnapshot(
      productId: productId,
      verifiedAt: verifiedAt,
      expiresAt: expiresAt,
    );
  }

  @override
  Future<void> save(MysticEntitlementSnapshot snapshot) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setString(_productIdKey, snapshot.productId),
      preferences.setString(
        _verifiedAtKey,
        snapshot.verifiedAt.toUtc().toIso8601String(),
      ),
      preferences.setString(
        _expiresAtKey,
        snapshot.expiresAt.toUtc().toIso8601String(),
      ),
    ]);
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.remove(_productIdKey),
      preferences.remove(_verifiedAtKey),
      preferences.remove(_expiresAtKey),
    ]);
  }
}
