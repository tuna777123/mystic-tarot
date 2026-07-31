import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'monetization.dart' show MysticProductIds;
export 'monetization.dart' show MysticProductIds;

enum StorePurchasePhase {
  idle,
  loading,
  ready,
  purchasing,
  restoring,
  verificationRequired,
  unavailable,
  error,
}

enum StorePurchaseNotice {
  nativeOnly,
  purchaseStreamUnavailable,
  storeUnavailable,
  productsNotConfigured,
  productsLoadFailed,
  checkoutUnavailable,
  restoreFailed,
  restoreCompleted,
  waitingForConfirmation,
  verificationRequired,
  purchaseFailed,
  purchaseCancelled,
}

class StorePurchaseService extends ChangeNotifier {
  StorePurchaseService({InAppPurchase? store})
      : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  StorePurchasePhase phase = StorePurchasePhase.idle;
  List<ProductDetails> products = const [];
  StorePurchaseNotice? notice;

  /// Diagnostic detail for development and support logs. UI surfaces should
  /// render [notice] through localized, product-safe copy instead of exposing
  /// raw store or plugin messages directly to the user.
  String? message;

  bool get canPurchase =>
      !kIsWeb && phase == StorePurchasePhase.ready && products.isNotEmpty;

  Future<void> initialize() async {
    if (kIsWeb) {
      phase = StorePurchasePhase.unavailable;
      notice = StorePurchaseNotice.nativeOnly;
      message = 'Store purchases are available only in native mobile builds.';
      notifyListeners();
      return;
    }

    phase = StorePurchasePhase.loading;
    notice = null;
    message = null;
    notifyListeners();

    _subscription ??= _store.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) {
        phase = StorePurchasePhase.error;
        notice = StorePurchaseNotice.purchaseStreamUnavailable;
        message = error.toString();
        notifyListeners();
      },
    );

    try {
      final available = await _store.isAvailable();
      if (!available) {
        phase = StorePurchasePhase.unavailable;
        notice = StorePurchaseNotice.storeUnavailable;
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
        notice = StorePurchaseNotice.productsLoadFailed;
        message = response.error!.message;
      } else if (products.isEmpty || missingLaunchProducts.isNotEmpty) {
        phase = StorePurchasePhase.unavailable;
        notice = StorePurchaseNotice.productsNotConfigured;
        message = 'Monthly and yearly subscriptions are not configured yet.';
      } else {
        phase = StorePurchasePhase.ready;
        notice = null;
        message = null;
      }
      notifyListeners();
    } catch (error) {
      phase = StorePurchasePhase.error;
      notice = StorePurchaseNotice.productsLoadFailed;
      message = error.toString();
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

    phase = StorePurchasePhase.purchasing;
    notice = null;
    message = null;
    notifyListeners();

    try {
      final opened = await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!opened) {
        phase = StorePurchasePhase.ready;
        notice = StorePurchaseNotice.checkoutUnavailable;
        message = 'The official store checkout did not open.';
        notifyListeners();
      }
    } catch (error) {
      phase = StorePurchasePhase.error;
      notice = StorePurchaseNotice.checkoutUnavailable;
      message = error.toString();
      notifyListeners();
    }
  }

  Future<void> restore() async {
    if (kIsWeb) return;
    phase = StorePurchasePhase.restoring;
    notice = null;
    message = null;
    notifyListeners();
    try {
      await _store.restorePurchases();
      if (phase == StorePurchasePhase.restoring) {
        phase = products.isEmpty
            ? StorePurchasePhase.unavailable
            : StorePurchasePhase.ready;
        notice = StorePurchaseNotice.restoreCompleted;
        notifyListeners();
      }
    } catch (error) {
      phase = StorePurchasePhase.error;
      notice = StorePurchaseNotice.restoreFailed;
      message = error.toString();
      notifyListeners();
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> updates) async {
    for (final purchase in updates) {
      if (purchase.status == PurchaseStatus.pending) {
        phase = StorePurchasePhase.purchasing;
        notice = StorePurchaseNotice.waitingForConfirmation;
        message = null;
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Never unlock premium from a client-side receipt alone. A production
        // verification endpoint must validate the receipt and subscription
        // state before the app persists entitlement.
        phase = StorePurchasePhase.verificationRequired;
        notice = StorePurchaseNotice.verificationRequired;
        message = null;
      } else if (purchase.status == PurchaseStatus.error) {
        phase = StorePurchasePhase.error;
        notice = StorePurchaseNotice.purchaseFailed;
        message = purchase.error?.message;
      } else if (purchase.status == PurchaseStatus.canceled) {
        phase = StorePurchasePhase.ready;
        notice = StorePurchaseNotice.purchaseCancelled;
        message = null;
      }

      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }
    notifyListeners();
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
