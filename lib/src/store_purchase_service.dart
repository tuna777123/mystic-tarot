import 'package:flutter/foundation.dart';

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

/// Compatibility surface retained while Mystic Tarot transitions to an
/// advertising-only business model.
///
/// No purchase, restore, RevenueCat configuration, or entitlement network call
/// is performed. `isPlus` remains true so every feature that used to be gated
/// is available to everyone without payment.
class StorePurchaseService extends ChangeNotifier {
  StorePurchaseService({
    SubscriptionClient? client,
    SubscriptionEnvironment? environment,
  });

  StorePurchasePhase phase = StorePurchasePhase.entitled;
  List<SubscriptionProduct> products = const [];
  StorePurchaseNotice? notice = StorePurchaseNotice.alreadySubscribed;
  String? message = 'All features are unlocked. Mystic Tarot is ad-supported.';

  bool isPlus = true;
  String? activeProductId;
  DateTime? expiresAt;
  String? managementUrl;
  String? appUserId;
  bool isSandbox = false;

  bool get canPurchase => false;
  bool get canRestore => false;

  Future<void> initialize() async {
    phase = StorePurchasePhase.entitled;
    notice = StorePurchaseNotice.alreadySubscribed;
    message = 'All features are unlocked. Mystic Tarot is ad-supported.';
    isPlus = true;
    products = const [];
    notifyListeners();
  }

  SubscriptionProduct? productFor(String id) => null;

  Future<void> buy(String productId) async {
    phase = StorePurchasePhase.entitled;
    notice = StorePurchaseNotice.alreadySubscribed;
    isPlus = true;
    notifyListeners();
  }

  Future<void> restore() async {
    phase = StorePurchasePhase.entitled;
    notice = StorePurchaseNotice.restoreNothing;
    isPlus = true;
    notifyListeners();
  }

  Future<void> refreshEntitlement() async {
    phase = StorePurchasePhase.entitled;
    isPlus = true;
    notifyListeners();
  }
}
