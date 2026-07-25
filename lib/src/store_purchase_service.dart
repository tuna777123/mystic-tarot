import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Store product identifiers. These values must match App Store Connect and
/// Google Play Console before paid access is enabled.
abstract final class MysticProductIds {
  static const weekly = 'mystic_plus_weekly';
  static const monthly = 'mystic_plus_monthly';
  static const yearly = 'mystic_plus_yearly';

  /// Version 1 launches with monthly and yearly only. Weekly remains reserved
  /// for a future pricing experiment and must not block launch readiness.
  static const launch = <String>{monthly, yearly};
  static const all = <String>{weekly, monthly, yearly};
}

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

class StorePurchaseService extends ChangeNotifier {
  StorePurchaseService({InAppPurchase? store})
      : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;
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
        // Never unlock premium from a client-side receipt alone. A production
        // verification endpoint must validate the receipt and subscription
        // state before the app persists entitlement.
        phase = StorePurchasePhase.verificationRequired;
        message =
            'Purchase received. Secure entitlement verification is required.';
      } else if (purchase.status == PurchaseStatus.error) {
        phase = StorePurchasePhase.error;
        message = purchase.error?.message ?? 'The purchase was not completed.';
      } else if (purchase.status == PurchaseStatus.canceled) {
        phase = StorePurchasePhase.ready;
        message = 'The purchase was cancelled.';
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
