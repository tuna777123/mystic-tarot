import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/store_purchase_service.dart';
import 'package:mystic_tarot/src/subscription_client.dart';
import 'package:mystic_tarot/src/subscription_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  const environment = SubscriptionEnvironment(
    supported: true,
    apiKey: 'test_public_sdk_key',
    entitlementId: 'mystic_plus',
  );

  test('initialization exposes active verified entitlement', () async {
    final client = _FakeSubscriptionClient(
      entitlement: const SubscriptionEntitlement(
        active: true,
        productId: MysticProductIds.yearly,
      ),
    );
    final service = StorePurchaseService(
      client: client,
      environment: environment,
    );

    await service.initialize();

    expect(service.phase, StorePurchasePhase.entitled);
    expect(service.isPlus, isTrue);
    expect(service.activeProductId, MysticProductIds.yearly);
    expect(service.notice, StorePurchaseNotice.alreadySubscribed);
    service.dispose();
  });

  test('purchase unlocks Plus only when entitlement is active', () async {
    final client = _FakeSubscriptionClient();
    final service = StorePurchaseService(
      client: client,
      environment: environment,
    );
    await service.initialize();

    client.purchaseResult = const SubscriptionEntitlement(
      active: true,
      productId: MysticProductIds.monthly,
    );
    await service.buy(MysticProductIds.monthly);

    expect(service.phase, StorePurchasePhase.entitled);
    expect(service.isPlus, isTrue);
    expect(service.notice, StorePurchaseNotice.purchaseCompleted);
    service.dispose();
  });

  test('inactive purchase never grants Plus', () async {
    final client = _FakeSubscriptionClient();
    final service = StorePurchaseService(
      client: client,
      environment: environment,
    );
    await service.initialize();

    await service.buy(MysticProductIds.monthly);

    expect(service.phase, StorePurchasePhase.ready);
    expect(service.isPlus, isFalse);
    expect(service.notice, StorePurchaseNotice.waitingForConfirmation);
    service.dispose();
  });

  test('restore without an active purchase stays free', () async {
    final client = _FakeSubscriptionClient();
    final service = StorePurchaseService(
      client: client,
      environment: environment,
    );
    await service.initialize();

    await service.restore();

    expect(service.phase, StorePurchasePhase.ready);
    expect(service.isPlus, isFalse);
    expect(service.notice, StorePurchaseNotice.restoreNothing);
    service.dispose();
  });

  test('live entitlement revocation closes Plus access', () async {
    final client = _FakeSubscriptionClient(
      entitlement: const SubscriptionEntitlement(
        active: true,
        productId: MysticProductIds.yearly,
      ),
    );
    final service = StorePurchaseService(
      client: client,
      environment: environment,
    );
    await service.initialize();

    client.emit(const SubscriptionEntitlement.inactive());

    expect(service.phase, StorePurchasePhase.ready);
    expect(service.isPlus, isFalse);
    service.dispose();
  });

  test('missing public SDK key fails closed', () async {
    final client = _FakeSubscriptionClient();
    final service = StorePurchaseService(
      client: client,
      environment: const SubscriptionEnvironment(
        supported: true,
        apiKey: null,
        entitlementId: 'mystic_plus',
      ),
    );

    await service.initialize();

    expect(service.phase, StorePurchasePhase.unavailable);
    expect(service.notice, StorePurchaseNotice.configurationMissing);
    expect(service.isPlus, isFalse);
    expect(client.configureCalls, 0);
    service.dispose();
  });

  test('only trusted entitlement signatures may unlock Plus', () {
    expect(
      isTrustedEntitlementVerification(VerificationResult.verified),
      isTrue,
    );
    expect(
      isTrustedEntitlementVerification(VerificationResult.verifiedOnDevice),
      isTrue,
    );
    expect(
      isTrustedEntitlementVerification(VerificationResult.failed),
      isFalse,
    );
    expect(
      isTrustedEntitlementVerification(VerificationResult.notRequested),
      isFalse,
    );
  });
}

class _FakeSubscriptionClient implements SubscriptionClient {
  _FakeSubscriptionClient({
    this.entitlement = const SubscriptionEntitlement.inactive(),
  });

  SubscriptionEntitlement entitlement;
  SubscriptionEntitlement purchaseResult =
      const SubscriptionEntitlement.inactive();
  SubscriptionEntitlement restoreResult =
      const SubscriptionEntitlement.inactive();
  ValueChanged<SubscriptionEntitlement>? listener;
  int configureCalls = 0;

  @override
  Future<void> configure(String apiKey) async {
    configureCalls++;
  }

  @override
  Future<SubscriptionEntitlement> getEntitlement(
    String entitlementId,
  ) async =>
      entitlement;

  @override
  void listen(
    String entitlementId,
    ValueChanged<SubscriptionEntitlement> listener,
  ) {
    this.listener = listener;
  }

  @override
  Future<List<SubscriptionProduct>> loadProducts(
    Set<String> productIds,
  ) async =>
      const [
        SubscriptionProduct(
          id: MysticProductIds.yearly,
          title: 'Yearly',
          description: 'Yearly plan',
          price: r'$39.99',
        ),
        SubscriptionProduct(
          id: MysticProductIds.monthly,
          title: 'Monthly',
          description: 'Monthly plan',
          price: r'$9.99',
        ),
      ];

  @override
  Future<SubscriptionEntitlement> purchase(
    String productId,
    String entitlementId,
  ) async =>
      purchaseResult;

  @override
  Future<SubscriptionEntitlement> restore(String entitlementId) async =>
      restoreResult;

  void emit(SubscriptionEntitlement value) => listener?.call(value);

  @override
  void dispose() {}
}
