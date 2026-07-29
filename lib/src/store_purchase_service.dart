import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'app_analytics_bindings.dart';
import 'monetization.dart' show MysticProductIds;
import 'store_entitlement_verifier.dart';
export 'monetization.dart' show MysticProductIds;

enum StorePurchasePhase {
  idle,
  loading,
  ready,
  purchasing,
  restoring,
  verificationRequired,
  entitled,
  unavailable,
  error,
}

class StorePurchaseService extends ChangeNotifier {
  StorePurchaseService({
    InAppPurchase? store,
    MysticAnalyticsBindings? analytics,
    MysticEntitlementVerifier? verifier,
    this.analyticsSource = 'store_checkout',
  })  : _store = store ?? InAppPurchase.instance,
        _analytics = analytics ?? const MysticAnalyticsBindings(),
        _verifier = verifier ?? const DeferredMysticEntitlementVerifier();

  final InAppPurchase _store;
  final MysticAnalyticsBindings _analytics;
  final MysticEntitlementVerifier _verifier;
  final String analyticsSource;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  StorePurchasePhase phase = StorePurchasePhase.idle;
  List<ProductDetails> products = const [];
  String? message;

  bool get canPurchase =>
      !kIsWeb && phase == StorePurchasePhase.ready && products.isNotEmpty;

  Future<void> initialize() async {
    if (kIsWeb) {
      phase = StorePurchasePhase.unavailable;
      message = 'Store purchases are available only in native mobile builds.';
      notifyListeners();
      return;
    }

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
        phase = StorePurchasePhase.unavailable;
        message = 'The App Store or Google Play is currently unavailable.';
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
        phase = StorePurchasePhase.unavailable;
        message = 'Monthly and yearly subscriptions are not configured yet.';
      } else {
        phase = StorePurchasePhase.ready;
      }
      notifyListeners();
    } catch (_) {
      phase = StorePurchasePhase.error;
      message = 'Subscription products could not be loaded.';
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
      phase = StorePurchasePhase.error;
      message = 'Previous purchases could not be restored.';
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
        phase = StorePurchasePhase.ready;
        message = 'The purchase was cancelled.';
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
      phase = StorePurchasePhase.verificationRequired;
      message = verification.status ==
              MysticEntitlementVerificationStatus.rejected
          ? 'The store receipt could not be verified. Premium remains locked.'
          : 'Purchase received. Secure entitlement verification is required.';
      return;
    }

    phase = StorePurchasePhase.entitled;
    message = 'Mystic Plus is verified and active.';
    unawaited(
      _analytics.purchaseCompleted(
        source: analyticsSource,
        plan: purchase.productID,
        restored: purchase.status == PurchaseStatus.restored,
      ),
    );

    if (purchase.pendingCompletePurchase) {
      await _store.completePurchase(purchase);
    }
  }

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
