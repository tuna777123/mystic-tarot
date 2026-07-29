import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'app_analytics_bindings.dart';
import 'monetization.dart' show MysticProductIds;
import 'store_entitlement_cache.dart';
import 'store_entitlement_verifier.dart';
export 'monetization.dart' show MysticProductIds;

enum StorePurchasePhase {
  idle,
  loading,
  ready,
  purchasing,
  restoring,
  verificationRequired,
  cachedEntitlement,
  entitled,
  unavailable,
  error,
}

class StorePurchaseService extends ChangeNotifier {
  StorePurchaseService({
    InAppPurchase? store,
    MysticAnalyticsBindings? analytics,
    MysticEntitlementVerifier? verifier,
    MysticEntitlementCache? entitlementCache,
    DateTime Function()? now,
    this.analyticsSource = 'store_checkout',
  })  : _store = store ?? InAppPurchase.instance,
        _analytics = analytics ?? const MysticAnalyticsBindings(),
        _verifier = verifier ?? const DeferredMysticEntitlementVerifier(),
        _entitlementCache = entitlementCache ??
            const SharedPreferencesMysticEntitlementCache(),
        _now = now ?? DateTime.now;

  final InAppPurchase _store;
  final MysticAnalyticsBindings _analytics;
  final MysticEntitlementVerifier _verifier;
  final MysticEntitlementCache _entitlementCache;
  final DateTime Function() _now;
  final String analyticsSource;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  StorePurchasePhase phase = StorePurchasePhase.idle;
  List<ProductDetails> products = const [];
  MysticEntitlementSnapshot? cachedEntitlement;
  String? message;

  bool get canPurchase =>
      !kIsWeb && phase == StorePurchasePhase.ready && products.isNotEmpty;

  bool get isEntitled => phase == StorePurchasePhase.entitled;

  bool get hasCachedEntitlement =>
      cachedEntitlement?.isActiveAt(_now().toUtc()) ?? false;

  Future<void> initialize() async {
    if (kIsWeb) {
      phase = StorePurchasePhase.unavailable;
      message = 'Store purchases are available only in native mobile builds.';
      notifyListeners();
      return;
    }

    await _loadCachedEntitlement();

    phase = StorePurchasePhase.loading;
    message = null;
    notifyListeners();

    _subscription ??= _store.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) {
        phase = StorePurchasePhase.error;
        message = 'The store purchase stream could not be reached.';
        notifyListeners();
      },
    );

    try {
      final available = await _store.isAvailable();
      if (!available) {
        phase = hasCachedEntitlement
            ? StorePurchasePhase.cachedEntitlement
            : StorePurchasePhase.unavailable;
        message = hasCachedEntitlement
            ? _cachedEntitlementMessage()
            : 'The App Store or Google Play is currently unavailable.';
        notifyListeners();
        return;
      }

      final response =
          await _store.queryProductDetails(MysticProductIds.launch);
      products = response.productDetails.toList()
        ..sort((a, b) => _rank(a.id).compareTo(_rank(b.id)));

      final missingLaunchProducts = response.notFoundIDs
          .where(MysticProductIds.launch.contains)
          .toList(growable: false);

      if (response.error != null) {
        phase = StorePurchasePhase.error;
        message = response.error!.message;
      } else if (products.isEmpty || missingLaunchProducts.isNotEmpty) {
        phase = hasCachedEntitlement
            ? StorePurchasePhase.cachedEntitlement
            : StorePurchasePhase.unavailable;
        message = hasCachedEntitlement
            ? _cachedEntitlementMessage()
            : 'Monthly and yearly subscriptions are not configured yet.';
      } else if (hasCachedEntitlement) {
        phase = StorePurchasePhase.cachedEntitlement;
        message = _cachedEntitlementMessage();
      } else {
        phase = StorePurchasePhase.ready;
      }
      notifyListeners();
    } catch (_) {
      phase = hasCachedEntitlement
          ? StorePurchasePhase.cachedEntitlement
          : StorePurchasePhase.error;
      message = hasCachedEntitlement
          ? _cachedEntitlementMessage()
          : 'Subscription products could not be loaded.';
      notifyListeners();
    }
  }

  ProductDetails? productFor(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> buy(String productId) async {
    final product = productFor(productId);
    if (!canPurchase || product == null) return;

    unawaited(
      _analytics.purchaseStarted(
        source: analyticsSource,
        plan: productId,
      ),
    );

    phase = StorePurchasePhase.purchasing;
    message = null;
    notifyListeners();

    try {
      await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (_) {
      phase = StorePurchasePhase.error;
      message = 'The official store checkout could not be opened.';
      notifyListeners();
    }
  }

  Future<void> restore() async {
    if (kIsWeb) return;

    unawaited(
      _analytics.purchaseRestored(source: analyticsSource),
    );

    phase = StorePurchasePhase.restoring;
    message = null;
    notifyListeners();
    try {
      await _store.restorePurchases();
    } catch (_) {
      phase = hasCachedEntitlement
          ? StorePurchasePhase.cachedEntitlement
          : StorePurchasePhase.error;
      message = hasCachedEntitlement
          ? _cachedEntitlementMessage()
          : 'Previous purchases could not be restored.';
      notifyListeners();
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> updates) async {
    for (final purchase in updates) {
      if (purchase.status == PurchaseStatus.pending) {
        phase = StorePurchasePhase.purchasing;
        message = 'Waiting for the official store confirmation.';
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _verifyPurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        phase = StorePurchasePhase.error;
        message = purchase.error?.message ?? 'The purchase was not completed.';
      } else if (purchase.status == PurchaseStatus.canceled) {
        phase = hasCachedEntitlement
            ? StorePurchasePhase.cachedEntitlement
            : StorePurchasePhase.ready;
        message = hasCachedEntitlement
            ? _cachedEntitlementMessage()
            : 'The purchase was cancelled.';
      }
    }
    notifyListeners();
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    MysticEntitlementVerificationResult verification;
    try {
      verification = await _verifier.verify(purchase);
    } catch (_) {
      verification = const MysticEntitlementVerificationResult(
        MysticEntitlementVerificationStatus.unavailable,
      );
    }

    if (!verification.isVerified) {
      if (verification.status == MysticEntitlementVerificationStatus.rejected) {
        cachedEntitlement = null;
        await _entitlementCache.clear();
      }
      phase = StorePurchasePhase.verificationRequired;
      message = verification.status ==
              MysticEntitlementVerificationStatus.rejected
          ? 'The store receipt could not be verified. Premium remains locked.'
          : 'Purchase received. Secure entitlement verification is required.';
      return;
    }

    final productId = verification.productId ?? purchase.productID;
    final expiresAt = verification.expiresAt?.toUtc();
    if (verification.canBeCached &&
        expiresAt != null &&
        expiresAt.isAfter(_now().toUtc())) {
      final snapshot = MysticEntitlementSnapshot(
        productId: productId,
        verifiedAt: _now().toUtc(),
        expiresAt: expiresAt,
      );
      cachedEntitlement = snapshot;
      await _entitlementCache.save(snapshot);
    }

    phase = StorePurchasePhase.entitled;
    message = 'Mystic Plus is verified and active.';
    unawaited(
      _analytics.purchaseCompleted(
        source: analyticsSource,
        plan: productId,
        restored: purchase.status == PurchaseStatus.restored,
      ),
    );

    if (purchase.pendingCompletePurchase) {
      await _store.completePurchase(purchase);
    }
  }

  Future<void> _loadCachedEntitlement() async {
    try {
      final snapshot = await _entitlementCache.load();
      if (snapshot == null) return;
      if (!snapshot.isActiveAt(_now().toUtc())) {
        await _entitlementCache.clear();
        return;
      }
      cachedEntitlement = snapshot;
      phase = StorePurchasePhase.cachedEntitlement;
      message = _cachedEntitlementMessage();
      notifyListeners();
    } catch (_) {
      cachedEntitlement = null;
    }
  }

  String _cachedEntitlementMessage() =>
      'A previously verified Mystic Plus membership was found. Restore purchases to securely confirm current access.';

  static int _rank(String id) => switch (id) {
        MysticProductIds.monthly => 0,
        MysticProductIds.yearly => 1,
        MysticProductIds.weekly => 2,
        _ => 99,
      };

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
