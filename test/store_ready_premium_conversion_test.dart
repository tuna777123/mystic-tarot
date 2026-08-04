import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/store_purchase_service.dart';
import 'package:mystic_tarot/src/store_ready_premium_screen.dart';
import 'package:mystic_tarot/src/subscription_client.dart';
import 'package:mystic_tarot/src/subscription_config.dart';
import 'package:mystic_tarot/src/theme.dart';

void main() {
  const environment = SubscriptionEnvironment(
    supported: true,
    apiKey: 'test_public_sdk_key',
    entitlementId: 'mystic_plus',
  );

  testWidgets('plans stay before proof and purchase stays visible at 320px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = StorePurchaseService(
      client: _FakeSubscriptionClient(),
      environment: environment,
    );
    addTearDown(service.dispose);

    await _pumpPremium(tester, service);

    final yearly = find.byKey(
      const ValueKey('premium-plan-mystic_plus_yearly'),
    );
    final monthly = find.byKey(
      const ValueKey('premium-plan-mystic_plus_monthly'),
    );
    final stickyAction = find.byKey(
      const ValueKey('premium-sticky-primary-action'),
    );

    expect(stickyAction, findsOneWidget);
    final actionRect = tester.getRect(stickyAction);
    expect(actionRect.top, greaterThanOrEqualTo(0));
    expect(actionRect.bottom, lessThanOrEqualTo(900));
    expect(
      find.text(
        r'The store charges $39.99 for one year. It renews yearly unless cancelled before the next renewal.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      yearly,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(yearly, findsOneWidget);
    await tester.scrollUntilVisible(
      monthly,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(monthly, findsOneWidget);

    final freeAccess = find.text(
      'Daily Guidance and your saved journal remain available without Plus.',
    );
    await tester.scrollUntilVisible(
      freeAccess,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(freeAccess, findsOneWidget);
    expect(stickyAction, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verified members continue before management actions', (
    tester,
  ) async {
    final service = StorePurchaseService(
      client: _FakeSubscriptionClient(
        entitlement: const SubscriptionEntitlement(
          active: true,
          productId: MysticProductIds.yearly,
          managementUrl: 'https://apps.apple.com/account/subscriptions',
        ),
      ),
      environment: environment,
    );
    addTearDown(service.dispose);

    await _pumpPremium(tester, service);

    final stickyAction = find.byKey(
      const ValueKey('premium-sticky-primary-action'),
    );
    expect(stickyAction, findsOneWidget);
    expect(find.text('Continue with Mystic Plus'), findsWidgets);

    final manage = find.text('Manage subscription');
    await tester.scrollUntilVisible(
      manage,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(manage, findsOneWidget);
    expect(find.text('Refresh membership'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('store failure exposes retry and recovers products', (
    tester,
  ) async {
    final client = _FakeSubscriptionClient(failedLoadsRemaining: 1);
    final service = StorePurchaseService(
      client: client,
      environment: environment,
    );
    addTearDown(service.dispose);

    await _pumpPremium(tester, service);

    final retry = find.byKey(const ValueKey('premium-store-retry'));
    expect(retry, findsOneWidget);
    await tester.tap(retry);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(retry, findsNothing);
    expect(
      find.byKey(const ValueKey('premium-plan-mystic_plus_yearly')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpPremium(
  WidgetTester tester,
  StorePurchaseService service,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildMysticTheme(),
      home: StoreReadyPremiumScreen(
        source: 'organic',
        language: MysticLanguage.english,
        subscriptionStore: service,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));
}

class _FakeSubscriptionClient implements SubscriptionClient {
  _FakeSubscriptionClient({
    this.entitlement = const SubscriptionEntitlement.inactive(),
    this.failedLoadsRemaining = 0,
  });

  SubscriptionEntitlement entitlement;
  int failedLoadsRemaining;
  ValueChanged<SubscriptionEntitlement>? listener;

  @override
  Future<void> configure(String apiKey) async {}

  @override
  Future<SubscriptionEntitlement> getEntitlement(String entitlementId) async =>
      entitlement;

  @override
  void listen(
    String entitlementId,
    ValueChanged<SubscriptionEntitlement> listener,
  ) {
    this.listener = listener;
  }

  @override
  Future<List<SubscriptionProduct>> loadProducts(Set<String> productIds) async {
    if (failedLoadsRemaining > 0) {
      failedLoadsRemaining--;
      throw const SubscriptionClientException(
        code: 'network_error',
        cancelled: false,
      );
    }
    return const [
      SubscriptionProduct(
        id: MysticProductIds.yearly,
        title: 'Yearly',
        description: 'Yearly plan',
        price: r'$39.99',
        priceValue: 39.99,
        currencyCode: 'USD',
        pricePerMonth: r'$3.33',
        subscriptionPeriod: 'P1Y',
      ),
      SubscriptionProduct(
        id: MysticProductIds.monthly,
        title: 'Monthly',
        description: 'Monthly plan',
        price: r'$9.99',
        priceValue: 9.99,
        currencyCode: 'USD',
        pricePerMonth: r'$9.99',
        subscriptionPeriod: 'P1M',
      ),
    ];
  }

  @override
  Future<SubscriptionEntitlement> purchase(
    String productId,
    String entitlementId,
  ) async => entitlement;

  @override
  Future<SubscriptionEntitlement> restore(String entitlementId) async =>
      entitlement;

  @override
  void dispose() {}
}
