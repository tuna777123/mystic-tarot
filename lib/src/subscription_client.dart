import 'package:flutter/foundation.dart';

/// Legacy data shape retained only so older internal call sites and tests can
/// compile during the advertising-only migration. No billing SDK is linked.
class SubscriptionProduct {
  const SubscriptionProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.priceValue,
    this.currencyCode,
    this.pricePerMonth,
    this.subscriptionPeriod,
  });

  final String id;
  final String title;
  final String description;
  final String price;
  final double? priceValue;
  final String? currencyCode;
  final String? pricePerMonth;
  final String? subscriptionPeriod;
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

/// Historical compatibility interface. Production code does not configure,
/// sell, restore, or verify subscriptions anymore.
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

/// Fail-closed no-op implementation for any legacy dependency injection path.
/// It never talks to a store or network and never creates a paid entitlement.
class DisabledSubscriptionClient implements SubscriptionClient {
  const DisabledSubscriptionClient();

  @override
  Future<void> configure(String apiKey) async {}

  @override
  Future<List<SubscriptionProduct>> loadProducts(Set<String> productIds) async =>
      const <SubscriptionProduct>[];

  @override
  Future<SubscriptionEntitlement> getEntitlement(String entitlementId) async =>
      const SubscriptionEntitlement.inactive();

  @override
  Future<SubscriptionEntitlement> purchase(
    String productId,
    String entitlementId,
  ) async => const SubscriptionEntitlement.inactive();

  @override
  Future<SubscriptionEntitlement> restore(String entitlementId) async =>
      const SubscriptionEntitlement.inactive();

  @override
  void listen(
    String entitlementId,
    ValueChanged<SubscriptionEntitlement> listener,
  ) {}

  @override
  void dispose() {}
}
