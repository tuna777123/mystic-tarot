from pathlib import Path
import runpy

ROOT = Path(__file__).resolve().parents[1]

runpy.run_path(
    str(ROOT / 'tool/v122_revenue_final_v3.py'),
    run_name='__main__',
)

premium_path = ROOT / 'lib/src/store_ready_premium_screen.dart'
premium = premium_path.read_text(encoding='utf-8')
build_marker = """  Widget build(BuildContext context) => Scaffold(
    body: MysticBackground(
"""
if build_marker not in premium:
    raise SystemExit('Premium Scaffold marker not found')
premium = premium.replace(
    build_marker,
    """  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: _purchaseDock(context),
    body: MysticBackground(
""",
    1,
)
method_marker = """  List<String> get _planIds => const [
"""
if method_marker not in premium:
    raise SystemExit('Premium plan-list marker not found')
dock = """  Widget _purchaseDock(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => Material(
      elevation: 18,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!store.isPlus) ...[
              _renewalDisclosure(context),
              const SizedBox(height: 8),
            ],
            KeyedSubtree(
              key: const ValueKey('premium-sticky-primary-action'),
              child: GoldButton(
                label: store.isPlus
                    ? t(
                        en: 'Continue with Mystic Plus',
                        es: 'Continuar con Mystic Plus',
                        fr: 'Continuer avec Mystic Plus',
                        pt: 'Continuar com Mystic Plus',
                        tr: 'Mystic Plus ile devam et',
                        it: 'Continua con Mystic Plus',
                        de: 'Mit Mystic Plus fortfahren',
                      )
                    : _purchaseButtonLabel(),
                icon: store.isPlus
                    ? Icons.arrow_forward_rounded
                    : Icons.lock_open_rounded,
                onPressed: store.isPlus
                    ? () => Navigator.pop(context, true)
                    : (store.canPurchase
                          ? () => store.buy(selectedId)
                          : null),
              ),
            ),
          ],
        ),
      ),
    ),
  );

"""
premium = premium.replace(method_marker, dock + method_marker, 1)
premium_path.write_text(premium, encoding='utf-8')

widget_test = ROOT / 'test/store_ready_premium_conversion_test.dart'
widget_test.write_text(
    r'''import 'package:flutter/material.dart';
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

    expect(yearly, findsOneWidget);
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
    await tester.pumpAndSettle();

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
  await tester.pumpAndSettle();
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
  ) async {
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
  ) async =>
      entitlement;

  @override
  Future<SubscriptionEntitlement> restore(String entitlementId) async =>
      entitlement;

  @override
  void dispose() {}
}
''',
    encoding='utf-8',
)

contract_path = ROOT / 'test/v122_revenue_final_contract_test.dart'
contract = contract_path.read_text(encoding='utf-8')
contract = contract.replace(
    "expect(File('tool/v122_revenue_final_v2.py').existsSync(), isFalse);",
    """expect(File('tool/v122_revenue_final_v2.py').existsSync(), isFalse);
    expect(File('tool/v122_revenue_final_v3.py').existsSync(), isFalse);
    expect(File('tool/v122_revenue_final_v4.py').existsSync(), isFalse);""",
    1,
)
contract = contract.replace(
    "expect(premium, contains(\"ValueKey('premium-store-retry')\"));",
    """expect(premium, contains("ValueKey('premium-store-retry')"));
    expect(
      premium,
      contains("ValueKey('premium-sticky-primary-action')"),
    );""",
    1,
)
contract_path.write_text(contract, encoding='utf-8')

# Tests must see the clean release tree. The workflow is removed from the
# branch through the GitHub API after the clean product commit is created.
materializer = ROOT / '.github/workflows/v122-materialize.yml'
if materializer.exists():
    materializer.unlink()

Path(__file__).unlink()
