import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionProduct {
  const SubscriptionProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  final String id;
  final String title;
  final String description;
  final String price;
}

class SubscriptionEntitlement {
  const SubscriptionEntitlement({
    required this.active,
    this.productId,
    this.expiresAt,
    this.managementUrl,
    this.appUserId,
    this.isSandbox = false,
  });

  const SubscriptionEntitlement.inactive({this.appUserId})
      : active = false,
        productId = null,
        expiresAt = null,
        managementUrl = null,
        isSandbox = false;

  final bool active;
  final String? productId;
  final DateTime? expiresAt;
  final String? managementUrl;
  final String? appUserId;
  final bool isSandbox;
}

class SubscriptionClientException implements Exception {
  const SubscriptionClientException({
    required this.code,
    required this.cancelled,
    this.detail,
  });

  final String code;
  final bool cancelled;
  final String? detail;
}

abstract interface class SubscriptionClient {
  Future<void> configure(String apiKey);

  Future<List<SubscriptionProduct>> loadProducts(Set<String> productIds);

  Future<SubscriptionEntitlement> getEntitlement(String entitlementId);

  Future<SubscriptionEntitlement> purchase(
    String productId,
    String entitlementId,
  );

  Future<SubscriptionEntitlement> restore(String entitlementId);

  void listen(
    String entitlementId,
    ValueChanged<SubscriptionEntitlement> listener,
  );

  void dispose();
}

@visibleForTesting
bool isTrustedEntitlementVerification(VerificationResult verification) =>
    verification == VerificationResult.verified ||
    verification == VerificationResult.verifiedOnDevice;

class RevenueCatSubscriptionClient implements SubscriptionClient {
  final Map<String, Package> _packages = {};
  final Map<String, StoreProduct> _storeProducts = {};
  CustomerInfoUpdateListener? _customerInfoListener;

  @override
  Future<void> configure(String apiKey) async {
    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }
    final configured = await Purchases.isConfigured;
    if (!configured) {
      final configuration = PurchasesConfiguration(apiKey)
        ..entitlementVerificationMode =
            EntitlementVerificationMode.informational
        ..automaticDeviceIdentifierCollectionEnabled = false
        ..diagnosticsEnabled = false;
      await Purchases.configure(configuration);
    }
  }

  @override
  Future<List<SubscriptionProduct>> loadProducts(
    Set<String> productIds,
  ) async {
    _packages.clear();
    _storeProducts.clear();

    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current != null) {
      for (final package in current.availablePackages) {
        final product = package.storeProduct;
        if (productIds.contains(product.identifier)) {
          _packages[product.identifier] = package;
          _storeProducts[product.identifier] = product;
        }
      }
    }

    final missing = productIds.difference(_storeProducts.keys.toSet());
    if (missing.isNotEmpty) {
      final products = await Purchases.getProducts(missing.toList());
      for (final product in products) {
        if (productIds.contains(product.identifier)) {
          _storeProducts[product.identifier] = product;
        }
      }
    }

    return _storeProducts.values
        .map(
          (product) => SubscriptionProduct(
            id: product.identifier,
            title: product.title,
            description: product.description,
            price: product.priceString,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<SubscriptionEntitlement> getEntitlement(
    String entitlementId,
  ) async {
    final customerInfo = await Purchases.getCustomerInfo();
    return _snapshot(customerInfo, entitlementId);
  }

  @override
  Future<SubscriptionEntitlement> purchase(
    String productId,
    String entitlementId,
  ) async {
    try {
      final package = _packages[productId];
      final product = _storeProducts[productId];
      if (package == null && product == null) {
        throw const SubscriptionClientException(
          code: 'product_not_loaded',
          cancelled: false,
        );
      }

      final result = package != null
          ? await Purchases.purchase(PurchaseParams.package(package))
          : await Purchases.purchase(PurchaseParams.storeProduct(product!));
      return _snapshot(result.customerInfo, entitlementId);
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      throw SubscriptionClientException(
        code: code.name,
        cancelled: code == PurchasesErrorCode.purchaseCancelledError,
        detail: error.message,
      );
    }
  }

  @override
  Future<SubscriptionEntitlement> restore(String entitlementId) async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return _snapshot(customerInfo, entitlementId);
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      throw SubscriptionClientException(
        code: code.name,
        cancelled: false,
        detail: error.message,
      );
    }
  }

  @override
  void listen(
    String entitlementId,
    ValueChanged<SubscriptionEntitlement> listener,
  ) {
    final previous = _customerInfoListener;
    if (previous != null) {
      Purchases.removeCustomerInfoUpdateListener(previous);
    }
    _customerInfoListener = (customerInfo) {
      listener(_snapshot(customerInfo, entitlementId));
    };
    Purchases.addCustomerInfoUpdateListener(_customerInfoListener!);
  }

  SubscriptionEntitlement _snapshot(
    CustomerInfo customerInfo,
    String entitlementId,
  ) {
    final appUserId = customerInfo.originalAppUserId;
    if (!isTrustedEntitlementVerification(
      customerInfo.entitlements.verification,
    )) {
      return SubscriptionEntitlement.inactive(appUserId: appUserId);
    }

    final entitlement = customerInfo.entitlements.active[entitlementId];
    if (entitlement == null || !entitlement.isActive) {
      return SubscriptionEntitlement.inactive(appUserId: appUserId);
    }
    return SubscriptionEntitlement(
      active: true,
      productId: entitlement.productIdentifier,
      expiresAt: entitlement.expirationDate == null
          ? null
          : DateTime.tryParse(entitlement.expirationDate!),
      managementUrl: customerInfo.managementURL,
      appUserId: appUserId,
      isSandbox: entitlement.isSandbox,
    );
  }

  @override
  void dispose() {
    final listener = _customerInfoListener;
    if (listener != null) {
      Purchases.removeCustomerInfoUpdateListener(listener);
    }
    _customerInfoListener = null;
  }
}
