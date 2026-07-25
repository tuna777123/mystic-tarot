import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_language.dart';
import 'flagship.dart';
import 'language_bridge.dart';
import 'store_purchase_service.dart';
import 'theme.dart';
import 'widgets.dart';

class StoreReadyPremiumScreen extends StatefulWidget {
  const StoreReadyPremiumScreen({
    required this.source,
    required this.language,
    super.key,
  });

  final String source;
  final MysticLanguage language;

  @override
  State<StoreReadyPremiumScreen> createState() =>
      _StoreReadyPremiumScreenState();
}

class _StoreReadyPremiumScreenState extends State<StoreReadyPremiumScreen> {
  final store = StorePurchaseService();
  String selectedId = MysticProductIds.yearly;

  String t({
    required String en,
    required String es,
    required String fr,
    required String pt,
    required String tr,
    required String it,
    required String de,
  }) =>
      localized(
        widget.language.appLanguage,
        english: en,
        spanish: es,
        french: fr,
        portugueseBrazil: pt,
        turkish: tr,
        italian: it,
        german: de,
      );

  @override
  void initState() {
    super.initState();
    store.initialize();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: MysticBackground(
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                Row(children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: kIsWeb ||
                            store.phase == StorePurchasePhase.restoring
                        ? null
                        : store.restore,
                    child: Text(t(
                      en: 'Restore',
                      es: 'Restaurar',
                      fr: 'Restaurer',
                      pt: 'Restaurar',
                      tr: 'Geri yükle',
                      it: 'Ripristina',
                      de: 'Wiederherstellen',
                    )),
                  ),
                ]),
                const Center(
                  child: Text('✦',
                      style: TextStyle(fontSize: 58, color: MysticColors.gold)),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.source == 'daily_limit'
                      ? t(
                          en: 'Your insight does not\nhave to stop here.',
                          es: 'Tu claridad no tiene\nque terminar aquí.',
                          fr: 'Votre réflexion ne doit\npas s’arrêter ici.',
                          pt: 'Sua percepção não precisa\nparar aqui.',
                          tr: 'İçgörün burada\nbitmek zorunda değil.',
                          it: 'La tua intuizione non deve\nfermarsi qui.',
                          de: 'Deine Erkenntnis muss\nhier nicht enden.',
                        )
                      : t(
                          en: 'Choose your Mystic Plus path.',
                          es: 'Elige tu camino Mystic Plus.',
                          fr: 'Choisissez votre parcours Mystic Plus.',
                          pt: 'Escolha seu caminho Mystic Plus.',
                          tr: 'Mystic Plus planını seç.',
                          it: 'Scegli il tuo percorso Mystic Plus.',
                          de: 'Wähle deinen Mystic-Plus-Weg.',
                        ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  t(
                    en: 'Official store products and localized prices appear here when App Store Connect or Google Play is configured.',
                    es: 'Los productos y precios oficiales aparecerán aquí cuando la tienda esté configurada.',
                    fr: 'Les produits et prix officiels apparaîtront ici après configuration de la boutique.',
                    pt: 'Os produtos e preços oficiais aparecerão aqui após a configuração da loja.',
                    tr: 'App Store Connect veya Google Play yapılandırıldığında resmi ürünler ve yerel fiyatlar burada görünür.',
                    it: 'Prodotti e prezzi ufficiali appariranno qui dopo la configurazione dello store.',
                    de: 'Offizielle Produkte und lokale Preise erscheinen hier nach der Store-Konfiguration.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                _statusCard(context),
                const SizedBox(height: 18),
                ..._planIds.map((id) => _productTile(context, id)),
                const SizedBox(height: 16),
                GoldButton(
                  label: _buttonLabel(),
                  icon: Icons.lock_open_rounded,
                  onPressed: store.canPurchase
                      ? () => store.buy(selectedId)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  t(
                    en: 'Premium access is never activated from an unverified client receipt. Production release requires secure entitlement verification.',
                    es: 'El acceso premium nunca se activa con un recibo sin verificar. La versión final requiere verificación segura.',
                    fr: 'L’accès premium n’est jamais activé depuis un reçu non vérifié. Une vérification sécurisée est requise.',
                    pt: 'O acesso premium nunca é ativado com recibo não verificado. A versão final exige verificação segura.',
                    tr: 'Premium erişim doğrulanmamış istemci makbuzuyla asla açılmaz. Yayın sürümü güvenli hak doğrulaması gerektirir.',
                    it: 'L’accesso premium non viene mai attivato da una ricevuta non verificata. Serve una verifica sicura.',
                    de: 'Premium wird nie durch einen ungeprüften Client-Beleg aktiviert. Eine sichere Prüfung ist erforderlich.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );

  List<String> get _planIds => const [
        MysticProductIds.weekly,
        MysticProductIds.monthly,
        MysticProductIds.yearly,
      ];

  Widget _statusCard(BuildContext context) {
    final loading = store.phase == StorePurchasePhase.loading ||
        store.phase == StorePurchasePhase.restoring ||
        store.phase == StorePurchasePhase.purchasing;
    final icon = store.phase == StorePurchasePhase.ready
        ? Icons.verified_outlined
        : store.phase == StorePurchasePhase.verificationRequired
            ? Icons.security_outlined
            : Icons.storefront_outlined;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .22)),
      ),
      child: Row(children: [
        loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MysticColors.gold,
                ),
              )
            : Icon(icon, color: MysticColors.gold),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            store.message ?? _defaultStatus(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ]),
    );
  }

  Widget _productTile(BuildContext context, String id) {
    final product = store.productFor(id);
    final active = selectedId == id;
    final title = switch (id) {
      MysticProductIds.weekly => t(en: 'Weekly', es: 'Semanal', fr: 'Hebdo', pt: 'Semanal', tr: 'Haftalık', it: 'Settimanale', de: 'Wöchentlich'),
      MysticProductIds.monthly => t(en: 'Monthly', es: 'Mensual', fr: 'Mensuel', pt: 'Mensal', tr: 'Aylık', it: 'Mensile', de: 'Monatlich'),
      _ => t(en: 'Yearly', es: 'Anual', fr: 'Annuel', pt: 'Anual', tr: 'Yıllık', it: 'Annuale', de: 'Jährlich'),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => selectedId = id),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: active
                ? MysticColors.violet.withValues(alpha: .3)
                : Colors.white.withValues(alpha: .04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? MysticColors.gold : Colors.white12,
              width: active ? 2 : 1,
            ),
          ),
          child: Row(children: [
            Icon(
              active ? Icons.radio_button_checked : Icons.radio_button_off,
              color: active ? MysticColors.gold : MysticColors.muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'Arial', fontWeight: FontWeight.w800)),
                  if (product != null) ...[
                    const SizedBox(height: 3),
                    Text(product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            Text(
              product?.price ?? '—',
              style: const TextStyle(
                fontFamily: 'Arial',
                color: MysticColors.gold,
                fontWeight: FontWeight.w900,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _defaultStatus() => kIsWeb
      ? t(
          en: 'Web early access cannot process payments.',
          es: 'El acceso web anticipado no procesa pagos.',
          fr: 'L’accès web anticipé ne traite pas les paiements.',
          pt: 'O acesso web antecipado não processa pagamentos.',
          tr: 'Web erken erişim ödeme işlemez.',
          it: 'L’accesso web anticipato non gestisce pagamenti.',
          de: 'Der Web-Frühzugang verarbeitet keine Zahlungen.',
        )
      : t(
          en: 'Loading official store products…',
          es: 'Cargando productos oficiales…',
          fr: 'Chargement des produits officiels…',
          pt: 'Carregando produtos oficiais…',
          tr: 'Resmi mağaza ürünleri yükleniyor…',
          it: 'Caricamento dei prodotti ufficiali…',
          de: 'Offizielle Store-Produkte werden geladen…',
        );

  String _buttonLabel() {
    if (store.phase == StorePurchasePhase.purchasing) {
      return t(en: 'Opening checkout…', es: 'Abriendo pago…', fr: 'Ouverture du paiement…', pt: 'Abrindo pagamento…', tr: 'Ödeme ekranı açılıyor…', it: 'Apertura pagamento…', de: 'Checkout wird geöffnet…');
    }
    final product = store.productFor(selectedId);
    return product == null
        ? t(en: 'Store product unavailable', es: 'Producto no disponible', fr: 'Produit indisponible', pt: 'Produto indisponível', tr: 'Mağaza ürünü hazır değil', it: 'Prodotto non disponibile', de: 'Produkt nicht verfügbar')
        : t(en: 'Continue with ${product.price}', es: 'Continuar con ${product.price}', fr: 'Continuer avec ${product.price}', pt: 'Continuar com ${product.price}', tr: '${product.price} ile devam et', it: 'Continua con ${product.price}', de: 'Weiter mit ${product.price}');
  }
}
