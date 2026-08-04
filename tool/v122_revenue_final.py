from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, content: str) -> None:
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding="utf-8")


def replace_once(path: str, old: str, new: str) -> None:
    source = read(path)
    if old not in source:
        raise SystemExit(f"Expected source not found in {path}: {old[:100]!r}")
    write(path, source.replace(old, new, 1))


# Version.
replace_once("pubspec.yaml", "version: 1.21.1+28", "version: 1.22.0+29")

# Conversion-focused, policy-safe premium flow.
premium_path = "lib/src/store_ready_premium_screen.dart"
premium = read(premium_path)
start_marker = "              _statusCard(context),\n"
end_marker = """              Text(
                t(
                  en: 'Subscriptions renew automatically unless cancelled in your store account. The store controls billing, eligibility, refunds, and cancellation.',
                  es: 'Las suscripciones se renuevan automáticamente salvo cancelación en la tienda.',
                  fr: 'Les abonnements se renouvellent automatiquement sauf annulation dans la boutique.',
                  pt: 'As assinaturas renovam automaticamente, salvo cancelamento na loja.',
                  tr: 'Abonelikler mağaza hesabından iptal edilmedikçe otomatik yenilenir. Faturalandırma, uygunluk, iade ve iptal işlemlerini mağaza yönetir.',
                  it: 'Gli abbonamenti si rinnovano automaticamente salvo annullamento nello store.',
                  de: 'Abonnements verlängern sich automatisch, sofern sie nicht im Store gekündigt werden.',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
"""
start = premium.find(start_marker)
if start < 0:
    raise SystemExit("Premium flow start marker not found")
end_start = premium.find(end_marker, start)
if end_start < 0:
    raise SystemExit("Premium flow end marker not found")
end = end_start + len(end_marker)
replacement = """              _statusCard(context),
              if (_canRetryStore) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  key: const ValueKey('premium-store-retry'),
                  onPressed: _retryStore,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    t(
                      en: 'Try the store connection again',
                      es: 'Reintentar la conexión con la tienda',
                      fr: 'Réessayer la connexion à la boutique',
                      pt: 'Tentar novamente a conexão com a loja',
                      tr: 'Mağaza bağlantısını yeniden dene',
                      it: 'Riprova la connessione allo store',
                      de: 'Store-Verbindung erneut versuchen',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (store.isPlus)
                _activeAccountCard(context)
              else
                ..._planIds.map((id) => _productTile(context, id)),
              const SizedBox(height: 12),
              KeyedSubtree(
                key: const ValueKey('premium-primary-action'),
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
              if (!store.isPlus) ...[
                const SizedBox(height: 10),
                _renewalDisclosure(context),
                const SizedBox(height: 8),
                Text(
                  t(
                    en: 'Daily Guidance and your saved journal remain available without Plus.',
                    es: 'La Guía diaria y tu diario guardado siguen disponibles sin Plus.',
                    fr: 'La Guidance quotidienne et votre journal restent disponibles sans Plus.',
                    pt: 'A Orientação diária e seu diário salvo continuam disponíveis sem o Plus.',
                    tr: 'Günlük Rehberlik ve kaydettiğin günlük Plus olmadan da kullanılabilir.',
                    it: 'La Guida quotidiana e il diario salvato restano disponibili senza Plus.',
                    de: 'Tägliche Führung und dein gespeichertes Journal bleiben ohne Plus verfügbar.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (store.isPlus) ...[
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    if (_managementUri != null)
                      TextButton.icon(
                        onPressed: _manageSubscription,
                        icon: const Icon(Icons.settings_outlined, size: 18),
                        label: Text(
                          t(
                            en: 'Manage subscription',
                            es: 'Gestionar suscripción',
                            fr: 'Gérer l’abonnement',
                            pt: 'Gerenciar assinatura',
                            tr: 'Aboneliği yönet',
                            it: 'Gestisci abbonamento',
                            de: 'Abo verwalten',
                          ),
                        ),
                      ),
                    TextButton.icon(
                      onPressed: store.refreshEntitlement,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(
                        t(
                          en: 'Refresh membership',
                          es: 'Actualizar membresía',
                          fr: 'Actualiser le statut',
                          pt: 'Atualizar status',
                          tr: 'Üyeliği yenile',
                          it: 'Aggiorna stato',
                          de: 'Mitgliedschaft aktualisieren',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              _benefits(context),
              const SizedBox(height: 12),
              LaunchContinuityTimeline(
                language: widget.language,
                compact: true,
              ),
              const SizedBox(height: 12),
              PrivateByDesignCard(language: widget.language),
              if (!store.isPlus) ...[
                const SizedBox(height: 14),
                Text(
                  t(
                    en: 'Subscriptions renew automatically unless cancelled in your store account. The store controls billing, eligibility, refunds, and cancellation.',
                    es: 'Las suscripciones se renuevan automáticamente salvo cancelación en la tienda.',
                    fr: 'Les abonnements se renouvellent automatiquement sauf annulation dans la boutique.',
                    pt: 'As assinaturas renovam automaticamente, salvo cancelamento na loja.',
                    tr: 'Abonelikler mağaza hesabından iptal edilmedikçe otomatik yenilenir. Faturalandırma, uygunluk, iade ve iptal işlemlerini mağaza yönetir.',
                    it: 'Gli abbonamenti si rinnovano automaticamente salvo annullamento nello store.',
                    de: 'Abonnements verlängern sich automatisch, sofern sie nicht im Store gekündigt werden.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
"""
premium = premium[:start] + replacement + premium[end:]

method_marker = "  Uri? get _managementUri {\n"
methods = """  bool get _canRetryStore =>
      !store.isPlus &&
      (store.phase == StorePurchasePhase.error ||
          store.phase == StorePurchasePhase.unavailable) &&
      store.notice != StorePurchaseNotice.nativeOnly &&
      store.notice != StorePurchaseNotice.configurationMissing;

  Future<void> _retryStore() async {
    await store.initialize();
  }

  Widget _renewalDisclosure(BuildContext context) {
    final product = store.productFor(selectedId);
    final price = product?.price;
    final yearly = selectedId == MysticProductIds.yearly;
    final disclosure = price == null
        ? t(
            en: 'The official store will show the exact price and billing period before purchase.',
            es: 'La tienda oficial mostrará el precio exacto y el periodo de cobro antes de la compra.',
            fr: 'La boutique officielle affichera le prix exact et la période de facturation avant l’achat.',
            pt: 'A loja oficial mostrará o preço exato e o período de cobrança antes da compra.',
            tr: 'Resmi mağaza satın almadan önce kesin fiyatı ve faturalandırma dönemini gösterir.',
            it: 'Lo store ufficiale mostrerà prezzo e periodo di fatturazione prima dell’acquisto.',
            de: 'Der offizielle Store zeigt Preis und Abrechnungszeitraum vor dem Kauf.',
          )
        : yearly
        ? t(
            en: 'The store charges $price for one year. It renews yearly unless cancelled before the next renewal.',
            es: 'La tienda cobra $price por un año. Se renueva cada año salvo cancelación antes de la siguiente renovación.',
            fr: 'La boutique facture $price pour un an. Le renouvellement est annuel sauf annulation avant la prochaine échéance.',
            pt: 'A loja cobra $price por um ano. A renovação é anual, salvo cancelamento antes da próxima renovação.',
            tr: 'Mağaza bir yıl için $price tahsil eder. Sonraki yenilemeden önce iptal edilmezse yıllık yenilenir.',
            it: 'Lo store addebita $price per un anno. Si rinnova ogni anno salvo annullamento prima del rinnovo successivo.',
            de: 'Der Store berechnet $price für ein Jahr. Das Abo verlängert sich jährlich, sofern es nicht vorher gekündigt wird.',
          )
        : t(
            en: 'The store charges $price for one month. It renews monthly unless cancelled before the next renewal.',
            es: 'La tienda cobra $price por un mes. Se renueva cada mes salvo cancelación antes de la siguiente renovación.',
            fr: 'La boutique facture $price pour un mois. Le renouvellement est mensuel sauf annulation avant la prochaine échéance.',
            pt: 'A loja cobra $price por um mês. A renovação é mensal, salvo cancelamento antes da próxima renovação.',
            tr: 'Mağaza bir ay için $price tahsil eder. Sonraki yenilemeden önce iptal edilmezse aylık yenilenir.',
            it: 'Lo store addebita $price per un mese. Si rinnova ogni mese salvo annullamento prima del rinnovo successivo.',
            de: 'Der Store berechnet $price für einen Monat. Das Abo verlängert sich monatlich, sofern es nicht vorher gekündigt wird.',
          );
    return Semantics(
      label: disclosure,
      child: Text(
        disclosure,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: MysticColors.lavender,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

"""
if method_marker not in premium:
    raise SystemExit("Premium method insertion marker not found")
premium = premium.replace(method_marker, methods + method_marker, 1)
semantics_marker = """      child: Semantics(
        button: true,
        selected: active,
"""
if semantics_marker not in premium:
    raise SystemExit("Plan semantics marker not found")
premium = premium.replace(
    semantics_marker,
    """      child: Semantics(
        key: ValueKey('premium-plan-$id'),
        button: true,
        selected: active,
""",
    1,
)
write(premium_path, premium)

# Release notes.
release_intro = """# Mystic Tarot 1.22.0 — Revenue-Ready Final

- Official plans and the primary purchase action now appear before long-form proof, while yearly remains the honest default value path.
- Every selected plan shows its actual store price, billing period, renewal cadence, and an explicit reminder that Daily Guidance and the saved journal remain usable without Plus.
- A failed store connection now exposes a visible localized retry instead of leaving a disabled purchase screen.
- After verified purchase or restore, the primary action returns the member to Mystic; subscription management remains a clear secondary action.
- Production Android and iOS workflows now apply store identity, ritual notifications, and private app-lock configuration before signed packaging.
- Release workflows are pinned to Flutter `3.44.8` and current Node 24 GitHub Actions.
- Version `1.22.0+29`.

"""
write("RELEASE_NOTES.md", release_intro + read("RELEASE_NOTES.md"))
write(
    "RELEASE_NOTES_1.22.md",
    """# Mystic Tarot 1.22.0 — Revenue-Ready Final

This is the final source release before store-account signing and submission. It improves conversion without false urgency, fake discounts, hidden renewal terms, or unnecessary tracking.

## Clearer conversion path

- Official monthly and yearly plans appear before the longer continuity, benefits, and privacy explanation.
- Yearly remains selected by default, while savings are calculated only from matching official store prices and currencies.
- The primary action stays visible on a narrow phone and always reflects the selected plan and localized store price.
- Daily Guidance and the saved local journal are explicitly identified as available without Mystic Plus.

## Purchase completion and recovery

- A verified member returns directly to Mystic through the primary action instead of being sent to subscription settings.
- Manage subscription and refresh membership remain visible secondary actions.
- Store loading failures and delayed product propagation expose a localized retry path.
- Purchase, restore, revocation, and verification continue to fail closed unless RevenueCat returns an active trusted entitlement.

## Billing transparency

- The selected plan states the full store price and whether it is charged monthly or yearly.
- Auto-renewal is disclosed next to the purchase action and again in the legal purchase note.
- Trial language is not shown unless a future store-aware eligibility implementation can display complete duration, conversion price, and cancellation terms.

## Production release integrity

- Signed Android and iOS workflows configure permanent identifiers, daily ritual notifications, and private app lock before packaging.
- Source validation, QA, Android, iOS, web, format, whitespace, and fatal-analysis gates use Flutter `3.44.8` for reproducible builds.
- GitHub actions use Node 24-compatible checkout, Java setup, and artifact upload releases.

## Version

- `1.22.0+29`

Apple/Google developer enrollment, banking/tax agreements, RevenueCat dashboard products, public SDK keys, signing certificates, provisioning profiles, keystores, sandbox purchases, screenshots, and final submission remain account-owned operations.
""",
)

store_release = read("STORE_RELEASE.md")
store_release = store_release.replace(
    "Current verified source version: `1.21.1+28`.",
    "Current verified source version: `1.22.0+29`.",
    1,
)
position_marker = """**Differentiator:** Mystic connects cinematic readings, transparent interpretation, the 24-hour Mystic Mirror, weekly pattern evidence, and optional whole-app PIN and supported-device biometric protection instead of delivering one disposable prediction or generic AI fortune.

"""
position_addition = position_marker + """## Final conversion and billing controls

- The official yearly and monthly plans and purchase action appear before long-form proof so users can understand the offer without scrolling through multiple promotional sections.
- Yearly is the default value path, but savings appear only when official monthly and yearly prices share the same currency and the yearly total is genuinely lower.
- The selected plan discloses the full store price, charge period, and automatic renewal cadence next to the purchase action.
- The paywall states that Daily Guidance and the saved journal remain available without Mystic Plus.
- Store connection failures provide a localized retry; verified purchases return users to the product instead of subscription-management settings.
- No countdown, fake scarcity, invented popularity claim, hidden trial conversion, or hardcoded price is used.

"""
if position_marker not in store_release:
    raise SystemExit("STORE_RELEASE positioning marker not found")
store_release = store_release.replace(position_marker, position_addition, 1)
write("STORE_RELEASE.md", store_release)

# Reproducible, fully configured release workflows.
workflow_paths = [
    ".github/workflows/flutter-ci.yml",
    ".github/workflows/ios-ci.yml",
    ".github/workflows/release-candidate.yml",
    ".github/workflows/store-release.yml",
]
for path in workflow_paths:
    source = read(path)
    source = source.replace("actions/checkout@v4", "actions/checkout@v6")
    source = source.replace("actions/setup-java@v4", "actions/setup-java@v5")
    source = source.replace("actions/upload-artifact@v4", "actions/upload-artifact@v7")
    source = source.replace(
        """        with:
          channel: stable
          cache: true
""",
        """        with:
          flutter-version: '3.44.8'
          cache: true
""",
    )
    source = source.replace(
        """        with:
          channel: stable
          cache: true
""",
        """        with:
          flutter-version: "3.44.8"
          cache: true
""",
    )
    source = source.replace("run: flutter analyze\n", "run: flutter analyze --fatal-infos\n")
    write(path, source)

# QA build must configure both private native features.
release_candidate = read(".github/workflows/release-candidate.yml")
qa_marker = """      - name: Configure private app lock
        run: dart run tool/configure_app_lock.dart
"""
if qa_marker not in release_candidate:
    raise SystemExit("QA app-lock marker not found")
release_candidate = release_candidate.replace(
    qa_marker,
    """      - name: Configure daily ritual notifications
        run: dart run tool/configure_ritual_notifications.dart

      - name: Configure private app lock
        run: dart run tool/configure_app_lock.dart
""",
    1,
)
write(".github/workflows/release-candidate.yml", release_candidate)

# Every production job receives the same native identity/privacy configuration.
store_workflow = read(".github/workflows/store-release.yml")
store_workflow = store_workflow.replace(
    """      - name: Generate Android project shell
        run: flutter create . --platforms=android --org com.tunabozcali
""",
    """      - name: Generate native project shells
        run: flutter create . --platforms=android,ios --org com.tunabozcali
""",
    1,
)
store_workflow = store_workflow.replace(
    """      - name: Generate iOS project shell
        run: flutter create . --platforms=ios --org com.tunabozcali
""",
    """      - name: Generate native project shells
        run: flutter create . --platforms=android,ios --org com.tunabozcali
""",
    1,
)
config_marker = """      - name: Apply permanent store identifiers
        run: dart run tool/configure_store_identifiers.dart
"""
if store_workflow.count(config_marker) != 3:
    raise SystemExit(
        f"Expected three store identifier steps, found {store_workflow.count(config_marker)}"
    )
store_workflow = store_workflow.replace(
    config_marker,
    config_marker
    + """
      - name: Configure daily ritual notifications
        run: dart run tool/configure_ritual_notifications.dart

      - name: Configure private app lock
        run: dart run tool/configure_app_lock.dart
""",
)
write(".github/workflows/store-release.yml", store_workflow)

# Widget-level conversion and recovery coverage.
write(
    "test/store_ready_premium_conversion_test.dart",
    r'''import 'package:flutter/foundation.dart';
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

  testWidgets('plans and purchase action fit before proof on a 320px phone', (
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

    expect(
      find.byKey(
        const ValueKey('premium-plan-${MysticProductIds.yearly}'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('premium-plan-${MysticProductIds.monthly}'),
      ),
      findsOneWidget,
    );
    final action = find.byKey(const ValueKey('premium-primary-action'));
    expect(action, findsOneWidget);
    expect(tester.getRect(action).bottom, lessThanOrEqualTo(900));
    expect(
      find.text(
        'The store charges \$39.99 for one year. It renews yearly unless cancelled before the next renewal.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Daily Guidance and your saved journal remain available without Plus.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('verified members return to Mystic before management actions', (
    tester,
  ) async {
    final service = StorePurchaseService(
      client: _FakeSubscriptionClient(
        entitlement: const SubscriptionEntitlement(
          active: true,
          productId: MysticProductIds.yearly,
        ),
      ),
      environment: environment,
    );
    addTearDown(service.dispose);

    await _pumpPremium(tester, service);

    expect(find.text('Continue with Mystic Plus'), findsOneWidget);
    expect(find.text('Manage subscription'), findsOneWidget);
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
    await tester.pump(const Duration(milliseconds: 50));

    expect(retry, findsNothing);
    expect(
      find.byKey(
        const ValueKey('premium-plan-${MysticProductIds.yearly}'),
      ),
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
  await tester.pump(const Duration(milliseconds: 50));
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
        price: '\$39.99',
        priceValue: 39.99,
        currencyCode: 'USD',
        pricePerMonth: '\$3.33',
        subscriptionPeriod: 'P1Y',
      ),
      SubscriptionProduct(
        id: MysticProductIds.monthly,
        title: 'Monthly',
        description: 'Monthly plan',
        price: '\$9.99',
        priceValue: 9.99,
        currencyCode: 'USD',
        pricePerMonth: '\$9.99',
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
)

write(
    "test/v122_revenue_final_contract_test.dart",
    r'''import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.22 revenue-ready final contract stays complete', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final premium = File(
      'lib/src/store_ready_premium_screen.dart',
    ).readAsStringSync();
    final flutterCi = File(
      '.github/workflows/flutter-ci.yml',
    ).readAsStringSync();
    final iosCi = File('.github/workflows/ios-ci.yml').readAsStringSync();
    final qa = File(
      '.github/workflows/release-candidate.yml',
    ).readAsStringSync();
    final production = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();
    final notes = File('RELEASE_NOTES_1.22.md').readAsStringSync();
    final storePack = File('STORE_RELEASE.md').readAsStringSync();

    expect(pubspec, contains('version: 1.22.0+29'));
    expect(
      premium.indexOf("..._planIds.map((id) => _productTile(context, id))"),
      lessThan(premium.indexOf('LaunchContinuityTimeline(')),
    );
    expect(
      premium.indexOf("ValueKey('premium-primary-action')"),
      lessThan(premium.indexOf('LaunchContinuityTimeline(')),
    );
    expect(premium, contains("ValueKey('premium-store-retry')"));
    expect(premium, contains('Future<void> _retryStore()'));
    expect(premium, contains('Widget _renewalDisclosure'));
    expect(premium, contains('Navigator.pop(context, true)'));
    expect(
      premium,
      contains(
        'Daily Guidance and your saved journal remain available without Plus.',
      ),
    );
    expect(premium, isNot(contains('MOST POPULAR')));
    expect(premium, isNot(contains('limited time')));

    for (final workflow in [flutterCi, iosCi, qa, production]) {
      expect(workflow, contains('actions/checkout@v6'));
      expect(workflow, contains("flutter-version: '3.44.8'"));
      expect(workflow, isNot(contains('channel: stable')));
    }
    expect(flutterCi, contains('actions/setup-java@v5'));
    expect(flutterCi, contains('actions/upload-artifact@v7'));
    expect(qa, contains('actions/setup-java@v5'));
    expect(qa, contains('actions/upload-artifact@v7'));
    expect(qa, contains('configure_ritual_notifications.dart'));
    expect(qa, contains('configure_app_lock.dart'));
    expect(production, contains('actions/setup-java@v5'));
    expect(production, contains('actions/upload-artifact@v7'));
    expect(
      'flutter create . --platforms=android,ios'.allMatches(production).length,
      greaterThanOrEqualTo(3),
    );
    expect(
      'configure_ritual_notifications.dart'.allMatches(production).length,
      greaterThanOrEqualTo(3),
    );
    expect(
      'configure_app_lock.dart'.allMatches(production).length,
      greaterThanOrEqualTo(3),
    );
    expect(production, contains('REVENUECAT_ANDROID_API_KEY'));
    expect(production, contains('REVENUECAT_IOS_API_KEY'));
    expect(production, contains('Verify Android signature'));
    expect(production, contains('Verify iOS signature and identity'));
    expect(notes, startsWith('# Mystic Tarot 1.22.0'));
    expect(storePack, contains('Current verified source version: `1.22.0+29`'));
    expect(storePack, contains('No countdown, fake scarcity'));
    expect(File('tool/v122_revenue_final.py').existsSync(), isFalse);
    expect(
      File('.github/workflows/v122-materialize.yml').existsSync(),
      isFalse,
    );
  });
}
''',
)

# The materializer is one-shot and must not survive in the clean release tree.
Path(__file__).unlink()
trigger = ROOT / "tool/v122_trigger.txt"
if trigger.exists():
    trigger.unlink()
