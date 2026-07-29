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
  late final StorePurchaseService store;
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
    store = StorePurchaseService(analyticsSource: widget.source);
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
                            store.phase == StorePurchasePhase.restoring ||
                            store.phase == StorePurchasePhase.purchasing ||
                            store.phase == StorePurchasePhase.entitled
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
                  _headline(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 12),
                Text(
                  _supportingCopy(),
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
                  icon: _buttonIcon(),
                  onPressed: _primaryAction(),
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
        MysticProductIds.monthly,
        MysticProductIds.yearly,
      ];

  String _headline() {
    if (store.phase == StorePurchasePhase.entitled) {
      return t(
        en: 'Mystic Plus is active.',
        es: 'Mystic Plus está activo.',
        fr: 'Mystic Plus est actif.',
        pt: 'Mystic Plus está ativo.',
        tr: 'Mystic Plus aktif.',
        it: 'Mystic Plus è attivo.',
        de: 'Mystic Plus ist aktiv.',
      );
    }
    if (store.phase == StorePurchasePhase.cachedEntitlement) {
      return t(
        en: 'Welcome back to Mystic Plus.',
        es: 'Te damos la bienvenida de nuevo a Mystic Plus.',
        fr: 'Bon retour sur Mystic Plus.',
        pt: 'Boas-vindas de volta ao Mystic Plus.',
        tr: 'Mystic Plus’a yeniden hoş geldin.',
        it: 'Bentornato su Mystic Plus.',
        de: 'Willkommen zurück bei Mystic Plus.',
      );
    }
    return widget.source == 'daily_limit'
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
          );
  }

  String _supportingCopy() {
    if (store.phase == StorePurchasePhase.entitled) {
      return t(
        en: 'Your membership has been securely verified.',
        es: 'Tu membresía se verificó de forma segura.',
        fr: 'Votre abonnement a été vérifié de manière sécurisée.',
        pt: 'Sua assinatura foi verificada com segurança.',
        tr: 'Üyeliğin güvenli şekilde doğrulandı.',
        it: 'Il tuo abbonamento è stato verificato in modo sicuro.',
        de: 'Deine Mitgliedschaft wurde sicher bestätigt.',
      );
    }
    if (store.phase == StorePurchasePhase.cachedEntitlement) {
      return t(
        en: 'A previous verified membership was found. Restore purchases to confirm that it is still active.',
        es: 'Se encontró una membresía verificada anteriormente. Restaura las compras para confirmar que sigue activa.',
        fr: 'Un abonnement précédemment vérifié a été trouvé. Restaurez les achats pour confirmer qu’il est toujours actif.',
        pt: 'Uma assinatura verificada anteriormente foi encontrada. Restaure as compras para confirmar que ainda está ativa.',
        tr: 'Daha önce doğrulanmış bir üyelik bulundu. Hâlâ aktif olduğunu doğrulamak için satın alımları geri yükle.',
        it: 'È stato trovato un abbonamento verificato in precedenza. Ripristina gli acquisti per confermare che sia ancora attivo.',
        de: 'Eine zuvor bestätigte Mitgliedschaft wurde gefunden. Stelle Käufe wieder her, um sie erneut zu bestätigen.',
      );
    }
    return t(
      en: 'Official store products and localized prices appear here when App Store Connect or Google Play is configured.',
      es: 'Los productos y precios oficiales aparecerán aquí cuando la tienda esté configurada.',
      fr: 'Les produits et prix officiels apparaîtront ici après configuration de la boutique.',
      pt: 'Os produtos e preços oficiais aparecerão aqui após a configuração da loja.',
      tr: 'App Store Connect veya Google Play yapılandırıldığında resmi ürünler ve yerel fiyatlar burada görünür.',
      it: 'Prodotti e prezzi ufficiali appariranno qui dopo la configurazione dello store.',
      de: 'Offizielle Produkte und lokale Preise erscheinen hier nach der Store-Konfiguration.',
    );
  }

  Widget _statusCard(BuildContext context) {
    final loading = store.phase == StorePurchasePhase.loading ||
        store.phase == StorePurchasePhase.restoring ||
        store.phase == StorePurchasePhase.purchasing;
    final icon = switch (store.phase) {
      StorePurchasePhase.entitled => Icons.workspace_premium,
      StorePurchasePhase.cachedEntitlement => Icons.history_rounded,
      StorePurchasePhase.ready => Icons.verified_outlined,
      StorePurchasePhase.verificationRequired => Icons.security_outlined,
      _ => Icons.storefront_outlined,
    };
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
    final selected = selectedId == id;
    final membershipProduct = store.cachedEntitlement?.productId == id;
    final active = store.phase == StorePurchasePhase.entitled
        ? membershipProduct
        : selected;
    final title = switch (id) {
      MysticProductIds.monthly => t(
          en: 'Monthly',
          es: 'Mensual',
          fr: 'Mensuel',
          pt: 'Mensal',
          tr: 'Aylık',
          it: 'Mensile',
          de: 'Monatlich'),
      _ => t(
          en: 'Yearly',
          es: 'Anual',
          fr: 'Annuel',
          pt: 'Anual',
          tr: 'Yıllık',
          it: 'Annuale',
          de: 'Jährlich'),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: store.canPurchase ? () => setState(() => selectedId = id) : null,
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

  VoidCallback? _primaryAction() {
    if (store.phase == StorePurchasePhase.cachedEntitlement && !kIsWeb) {
      return store.restore;
    }
    if (store.canPurchase) {
      return () => store.buy(selectedId);
    }
    return null;
  }

  IconData _buttonIcon() => switch (store.phase) {
        StorePurchasePhase.entitled => Icons.verified_rounded,
        StorePurchasePhase.cachedEntitlement => Icons.restore_rounded,
        StorePurchasePhase.verificationRequired => Icons.security_rounded,
        _ => Icons.lock_open_rounded,
      };

  String _buttonLabel() {
    if (store.phase == StorePurchasePhase.entitled) {
      return t(
        en: 'Mystic Plus is active',
        es: 'Mystic Plus está activo',
        fr: 'Mystic Plus est actif',
        pt: 'Mystic Plus está ativo',
        tr: 'Mystic Plus aktif',
        it: 'Mystic Plus è attivo',
        de: 'Mystic Plus ist aktiv',
      );
    }
    if (store.phase == StorePurchasePhase.cachedEntitlement) {
      return t(
        en: 'Restore to confirm access',
        es: 'Restaurar para confirmar acceso',
        fr: 'Restaurer pour confirmer l’accès',
        pt: 'Restaurar para confirmar acesso',
        tr: 'Erişimi doğrulamak için geri yükle',
        it: 'Ripristina per confermare l’accesso',
        de: 'Wiederherstellen und Zugriff bestätigen',
      );
    }
    if (store.phase == StorePurchasePhase.restoring) {
      return t(
        en: 'Restoring purchases…',
        es: 'Restaurando compras…',
        fr: 'Restauration des achats…',
        pt: 'Restaurando compras…',
        tr: 'Satın alımlar geri yükleniyor…',
        it: 'Ripristino degli acquisti…',
        de: 'Käufe werden wiederhergestellt…',
      );
    }
    if (store.phase == StorePurchasePhase.verificationRequired) {
      return t(
        en: 'Secure verification required',
        es: 'Se requiere verificación segura',
        fr: 'Vérification sécurisée requise',
        pt: 'Verificação segura necessária',
        tr: 'Güvenli doğrulama gerekli',
        it: 'Verifica sicura necessaria',
        de: 'Sichere Bestätigung erforderlich',
      );
    }
    if (store.phase == StorePurchasePhase.purchasing) {
      return t(
        en: 'Opening checkout…',
        es: 'Abriendo pago…',
        fr: 'Ouverture du paiement…',
        pt: 'Abrindo pagamento…',
        tr: 'Ödeme ekranı açılıyor…',
        it: 'Apertura pagamento…',
        de: 'Checkout wird geöffnet…',
      );
    }
    final product = store.productFor(selectedId);
    return product == null
        ? t(
            en: 'Store product unavailable',
            es: 'Producto no disponible',
            fr: 'Produit indisponible',
            pt: 'Produto indisponível',
            tr: 'Mağaza ürünü hazır değil',
            it: 'Prodotto non disponibile',
            de: 'Produkt nicht verfügbar')
        : t(
            en: 'Continue with ${product.price}',
            es: 'Continuar con ${product.price}',
            fr: 'Continuer avec ${product.price}',
            pt: 'Continuar com ${product.price}',
            tr: '${product.price} ile devam et',
            it: 'Continua con ${product.price}',
            de: 'Weiter mit ${product.price}');
  }
}
