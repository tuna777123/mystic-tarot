import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart' as store;

import 'monetization.dart';

/// Native Apple/Google billing adapter.
///
/// Entitlements remain fail-closed: a transaction only unlocks Plus after the
/// caller's verification callback accepts the store verification payload.
class MysticStoreBilling {
  MysticStoreBilling({
    required this.verifyPurchase,
    store.InAppPurchase? storeClient,
  }) : _store = storeClient ?? store.InAppPurchase.instance;

  final store.InAppPurchase _store;
  final Future<bool> Function(store.PurchaseDetails purchase) verifyPurchase;

  StreamSubscription<List<store.PurchaseDetails>>? _subscription;
  final _updates = StreamController<PurchaseStatus>.broadcast();
  final Map<MysticPlan, store.ProductDetails> _products = {};

  Stream<PurchaseStatus> get updates => _updates.stream;
  Map<MysticPlan, String> get localizedPrices => {
        for (final entry in _products.entries) entry.key: entry.value.price,
      };

  Future<bool> initialize() async {
    if (!await _store.isAvailable()) return false;
    _subscription ??= _store.purchaseStream.listen(
      _handlePurchases,
      onError: (_) => _updates.add(PurchaseStatus.failed),
    );
    final response = await _store.queryProductDetails(
      MysticPlan.values.map((plan) => plan.productId).toSet(),
    );
    if (response.error != null) return false;
    _products
      ..clear()
      ..addEntries(response.productDetails.map((product) {
        final plan = MysticPlan.values.firstWhere(
          (candidate) => candidate.productId == product.id,
        );
        return MapEntry(plan, product);
      }));
    return _products.length == MysticPlan.values.length;
  }

  Future<PurchaseStatus> purchase(MysticPlan plan) async {
    final product = _products[plan];
    if (product == null) return PurchaseStatus.failed;
    _updates.add(PurchaseStatus.loading);
    final started = await _store.buyNonConsumable(
      purchaseParam: store.PurchaseParam(productDetails: product),
    );
    return started ? PurchaseStatus.pending : PurchaseStatus.failed;
  }

  Future<PurchaseStatus> restore() async {
    _updates.add(PurchaseStatus.loading);
    try {
      await _store.restorePurchases();
      return PurchaseStatus.pending;
    } catch (_) {
      return PurchaseStatus.failed;
    }
  }

  Future<void> _handlePurchases(List<store.PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final mapped = await _mapPurchase(purchase);
      _updates.add(mapped);
      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }
  }

  Future<PurchaseStatus> _mapPurchase(store.PurchaseDetails purchase) async {
    switch (purchase.status) {
      case store.PurchaseStatus.pending:
        return PurchaseStatus.pending;
      case store.PurchaseStatus.canceled:
        return PurchaseStatus.cancelled;
      case store.PurchaseStatus.error:
        return PurchaseStatus.failed;
      case store.PurchaseStatus.purchased:
      case store.PurchaseStatus.restored:
        final verified = await verifyPurchase(purchase);
        if (!verified) return PurchaseStatus.failed;
        return purchase.status == store.PurchaseStatus.restored
            ? PurchaseStatus.restored
            : PurchaseStatus.purchased;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _updates.close();
  }
}
