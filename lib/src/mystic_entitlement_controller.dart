import 'package:flutter/foundation.dart';

import 'store_entitlement_cache.dart';

enum MysticEntitlementState {
  loading,
  locked,
  cached,
  active,
}

/// App-wide source of truth for Mystic Plus access.
///
/// A cached snapshot is advisory and never unlocks premium by itself. Access
/// becomes active only after a trusted verifier confirms a current expiry in
/// the running app session.
final class MysticEntitlementController extends ChangeNotifier {
  MysticEntitlementController({
    MysticEntitlementCache? cache,
    DateTime Function()? now,
  })  : _cache = cache ?? const SharedPreferencesMysticEntitlementCache(),
        _now = now ?? DateTime.now;

  static final MysticEntitlementController instance =
      MysticEntitlementController();

  final MysticEntitlementCache _cache;
  final DateTime Function() _now;

  MysticEntitlementState state = MysticEntitlementState.loading;
  MysticEntitlementSnapshot? snapshot;
  bool _initialized = false;

  bool get isActive =>
      state == MysticEntitlementState.active &&
      (snapshot?.isActiveAt(_now().toUtc()) ?? false);

  bool get hasCachedEntitlement =>
      snapshot?.isActiveAt(_now().toUtc()) ?? false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final stored = await _cache.load();
      if (stored == null) {
        state = MysticEntitlementState.locked;
      } else if (!stored.isActiveAt(_now().toUtc())) {
        await _cache.clear();
        state = MysticEntitlementState.locked;
      } else {
        snapshot = stored;
        state = MysticEntitlementState.cached;
      }
    } catch (_) {
      snapshot = null;
      state = MysticEntitlementState.locked;
    }
    notifyListeners();
  }

  Future<bool> markVerified({
    required String productId,
    required DateTime expiresAt,
  }) async {
    final expiry = expiresAt.toUtc();
    if (!expiry.isAfter(_now().toUtc())) {
      await markRejected();
      return false;
    }

    final verified = MysticEntitlementSnapshot(
      productId: productId,
      verifiedAt: _now().toUtc(),
      expiresAt: expiry,
    );
    snapshot = verified;
    state = MysticEntitlementState.active;
    await _cache.save(verified);
    notifyListeners();
    return true;
  }

  Future<void> requireReverification() async {
    state = hasCachedEntitlement
        ? MysticEntitlementState.cached
        : MysticEntitlementState.locked;
    notifyListeners();
  }

  Future<void> markRejected() async {
    snapshot = null;
    state = MysticEntitlementState.locked;
    await _cache.clear();
    notifyListeners();
  }

  Future<void> clearLocalState() async {
    snapshot = null;
    state = MysticEntitlementState.locked;
    await _cache.clear();
    notifyListeners();
  }
}
