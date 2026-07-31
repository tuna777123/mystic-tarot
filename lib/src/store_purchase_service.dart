import 'package:flutter/foundation.dart';

import 'monetization.dart' show MysticProductIds;
import 'subscription_client.dart';
import 'subscription_config.dart';
export 'monetization.dart' show MysticProductIds;

enum StorePurchasePhase {
  idle,
  loading,
  ready,
  purchasing,
  restoring,
  entitled,
  unavailable,
  error,
}

enum StorePurchaseNotice {
  nativeOnly,
  configurationMissing,
  purchaseStreamUnavailable,
  storeUnavailable,
  productsNotConfigured,
  productsLoadFailed,
  checkoutUnavailable,
  restoreFailed,
  restoreCompleted,
  restoreNothing,
  waitingForConfirmation,
  purchaseCompleted,
  alreadySubscribed,
  purchaseFailed,
  purchaseCancelled,
}

class StorePurchaseService extends ChangeNotifier {
  StorePurchaseService({
    SubscriptionClient? client,
    SubscriptionEnvironment? environment,
  })  : _client = client ?? RevenueCatSubscriptionClient(),
        _environment = environment ?? SubscriptionEnvironment.current();

  final SubscriptionClient _client;
  final SubscriptionEnvironment _environment;
  bool _listening = false;

  StorePurchasePhase phase = StorePurchasePhase.idle;
  List<SubscriptionProduct> products = const [];
  StorePurchaseNotice? notice;

  /// Diagnostic detail for development and support logs. UI surfaces must use
  /// localized notice copy rather than displaying this field directly.
  String? message;

  bool isPlus = false;
  String? activeProductId;
  DateTime? expiresAt;
  String? managementUrl;
  String? appUserId;
  bool isSandbox = false;

  bool get canPurchase =>
      _environment.configured &&
      phase == StorePurchasePhase.ready &&
      products.isNotEmpty;

  bool get canRestore => _environment.configured;

  Future<void> initialize() async {
    if (!_environment.supported) {
      phase = StorePurchasePhase.unavailable;
      notice = StorePurchaseNotice.nativeOnly;
      message = 'Subscriptions are available only in native mobile builds.';
      notifyListeners();
      return;
    }
    if (!_environment.configured) {
      phase = StorePurchasePhase.unavailable;
      notice = StorePurchaseNotice.configurationMissing;
      message = 'RevenueCat public SDK key is missing for this platform.';
      notifyListeners();
      return;
    }

    phase = StorePurchasePhase.loading;
    notice = null;
    message = null;
    notifyListeners();

    try {
      await _client.configure(_environment.apiKey!);
      if (!_listening) {
        _client.listen(_environment.entitlementId, _handleEntitlementUpdate);
        _listening = true;
      }

      products = await _client.loadProducts(MysticProductIds.launch);
      products = products.toList()
        ..sort((a, b) => _rank(a.id).compareTo(_rank(b.id)));
      final entitlement =
          await _client.getEntitlement(_environment.entitlementId);
      _applyEntitlement(entitlement);

      final foundIds = products.map((product) => product.id).toSet();
      final missingProducts = MysticProductIds.launch.difference(foundIds);
      if (isPlus) {
        phase = StorePurchasePhase.entitled;
        notice = StorePurchaseNotice.alreadySubscribed;
      } else if (products.isEmpty || missingProducts.isNotEmpty) {
        phase = StorePurchasePhase.unavailable;
        notice = StorePurchaseNotice.productsNotConfigured;
        message = 'RevenueCat current offering must contain monthly and yearly.';
      } else {
        phase = StorePurchasePhase.ready;
        notice = null;
      }
      notifyListeners();
    } on SubscriptionClientException catch (error) {
      phase = StorePurchasePhase.error;
      notice = StorePurchaseNotice.productsLoadFailed;
      message = '${error.code}: ${error.detail ?? ''}'.trim();
      notifyListeners();
    } catch (error) {
      phase = StorePurchasePhase.error;
      notice = StorePurchaseNotice.productsLoadFailed;
      message = error.toString();
      notifyListeners();
    }
  }

  SubscriptionProduct? productFor(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> buy(String productId) async {
    if (isPlus) {
      phase = StorePurchasePhase.entitled;
      notice = StorePurchaseNotice.alreadySubscribed;
      notifyListeners();
      return;
    }
    if (!canPurchase || productFor(productId) == null) return;

    phase = StorePurchasePhase.purchasing;
    notice = null;
    message = null;
    notifyListeners();

    try {
      final entitlement = await _client.purchase(
        productId,
        _environment.entitlementId,
      );
      _applyEntitlement(entitlement);
      if (isPlus) {
        phase = StorePurchasePhase.entitled;
        notice = StorePurchaseNotice.purchaseCompleted;
      } else {
        phase = StorePurchasePhase.ready;
        notice = StorePurchaseNotice.waitingForConfirmation;
      }
      notifyListeners();
    } on SubscriptionClientException catch (error) {
      phase = error.cancelled
          ? StorePurchasePhase.ready
          : StorePurchasePhase.error;
      notice = error.cancelled
          ? StorePurchaseNotice.purchaseCancelled
          : StorePurchaseNotice.purchaseFailed;
      message = '${error.code}: ${error.detail ?? ''}'.trim();
      notifyListeners();
    } catch (error) {
      phase = StorePurchasePhase.error;
      notice = StorePurchaseNotice.purchaseFailed;
      message = error.toString();
      notifyListeners();
    }
  }

  Future<void> restore() async {
    if (!canRestore) return;
    phase = StorePurchasePhase.restoring;
    notice = null;
    message = null;
    notifyListeners();

    try {
      final entitlement =
          await _client.restore(_environment.entitlementId);
      _applyEntitlement(entitlement);
      if (isPlus) {
        phase = StorePurchasePhase.entitled;
        notice = StorePurchaseNotice.restoreCompleted;
      } else {
        phase = products.isEmpty
            ? StorePurchasePhase.unavailable
            : StorePurchasePhase.ready;
        notice = StorePurchaseNotice.restoreNothing;
      }
      notifyListeners();
    } on SubscriptionClientException catch (error) {
      phase = StorePurchasePhase.error;
      notice = StorePurchaseNotice.restoreFailed;
      message = '${error.code}: ${error.detail ?? ''}'.trim();
      notifyListeners();
    } catch (error) {
      phase = StorePurchasePhase.error;
      notice = StorePurchaseNotice.restoreFailed;
      message = error.toString();
      notifyListeners();
    }
  }

  Future<void> refreshEntitlement() async {
    if (!_environment.configured) return;
    try {
      final entitlement =
          await _client.getEntitlement(_environment.entitlementId);
      _handleEntitlementUpdate(entitlement);
    } catch (error) {
      message = error.toString();
    }
  }

  void _handleEntitlementUpdate(SubscriptionEntitlement entitlement) {
    final wasPlus = isPlus;
    _applyEntitlement(entitlement);
    if (isPlus) {
      phase = StorePurchasePhase.entitled;
      if (!wasPlus) notice = StorePurchaseNotice.purchaseCompleted;
    } else if (wasPlus) {
      phase = products.isEmpty
          ? StorePurchasePhase.unavailable
          : StorePurchasePhase.ready;
      notice = null;
    }
    notifyListeners();
  }

  void _applyEntitlement(SubscriptionEntitlement entitlement) {
    isPlus = entitlement.active;
    activeProductId = entitlement.productId;
    expiresAt = entitlement.expiresAt;
    managementUrl = entitlement.managementUrl;
    appUserId = entitlement.appUserId;
    isSandbox = entitlement.isSandbox;
  }

  static int _rank(String id) => switch (id) {
        MysticProductIds.yearly => 0,
        MysticProductIds.monthly => 1,
        MysticProductIds.weekly => 2,
        _ => 99,
      };

  @override
  void dispose() {
    _client.dispose();
    super.dispose();
  }
}
