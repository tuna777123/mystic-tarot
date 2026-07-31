import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_language.dart';
import 'flagship.dart';
import 'language_bridge.dart';
import 'store_purchase_service.dart';
import 'store_status_localization.dart';
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
          child: SafeArea(
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
                              !store.canRestore ||
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
                  Center(
                    child: Text(
                      store.isPlus ? '✓' : '✦',
                      style: const TextStyle(
                        fontSize: 58,
                        color: MysticColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    store.isPlus
                        ? t(
                            en: 'Mystic Plus is active.',
                            es: 'Mystic Plus está activo.',
                            fr: 'Mystic Plus est actif.',
                            pt: 'O Mystic Plus está ativo.',
                            tr: 'Mystic Plus etkin.',
                            it: 'Mystic Plus è attivo.',
                            de: 'Mystic Plus ist aktiv.',
                          )
                        : widget.source == 'daily_limit'
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
                    store.isPlus
                        ? t(
                            en: 'Unlimited deep readings and premium paths are unlocked on this device.',
                            es: 'Las lecturas profundas y caminos premium están desbloqueados.',
                            fr: 'Les lectures approfondies et parcours premium sont déverrouillés.',
                            pt: 'As leituras profundas e caminhos premium estão liberados.',
                            tr: 'Sınırsız derin okumalar ve premium yollar bu cihazda açıldı.',
                            it: 'Le letture approfondite e i percorsi premium sono sbloccati.',
                            de: 'Unbegrenzte Tiefenlesungen und Premium-Pfade sind freigeschaltet.',
                          )
                        : t(
                            en: 'Prices and billing terms come directly from the App Store or Google Play. Purchases are verified securely before Plus opens.',
                            es: 'Los precios y condiciones vienen de la tienda oficial. Plus se activa solo tras una verificación segura.',
                            fr: 'Les prix et conditions proviennent de la boutique officielle. Plus s’active après vérification sécurisée.',
                            pt: 'Preços e condições vêm da loja oficial. O Plus abre somente após verificação segura.',
                            tr: 'Fiyatlar ve ödeme koşulları doğrudan App Store veya Google Play’den gelir. Plus yalnızca güvenli doğrulamadan sonra açılır.',
                            it: 'Prezzi e condizioni provengono dallo store ufficiale. Plus si attiva dopo la verifica sicura.',
                            de: 'Preise und Bedingungen kommen direkt vom offiziellen Store. Plus wird erst nach sicherer Prüfung aktiviert.',
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
                    icon: store.isPlus
                        ? Icons.verified_rounded
                        : Icons.lock_open_rounded,
                    onPressed: store.canPurchase && !store.isPlus
                        ? () => store.buy(selectedId)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t(
                      en: 'Subscriptions renew automatically unless cancelled in your store account. Restore is available on this screen.',
                      es: 'Las suscripciones se renuevan automáticamente salvo cancelación. Puedes restaurarlas aquí.',
                      fr: 'Les abonnements se renouvellent automatiquement sauf annulation. La restauration est disponible ici.',
                      pt: 'As assinaturas renovam automaticamente, salvo cancelamento. A restauração está disponível aqui.',
                      tr: 'Abonelikler mağaza hesabından iptal edilmedikçe otomatik yenilenir. Satın alımları bu ekrandan geri yükleyebilirsin.',
                      it: 'Gli abbonamenti si rinnovano automaticamente salvo annullamento. Puoi ripristinarli qui.',
                      de: 'Abonnements verlängern sich automatisch, sofern sie nicht gekündigt werden. Wiederherstellung ist hier möglich.',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  List<String> get _planIds => const [
        MysticProductIds.yearly,
        MysticProductIds.monthly,
      ];

  Widget _statusCard(BuildContext context) {
    final loading = store.phase == StorePurchasePhase.loading ||
        store.phase == StorePurchasePhase.restoring ||
        store.phase == StorePurchasePhase.purchasing;
    final icon = store.phase == StorePurchasePhase.entitled
        ? Icons.verified_rounded
        : store.phase == StorePurchasePhase.ready
            ? Icons.verified_outlined
            : Icons.storefront_outlined;
    final status = store.notice == null
        ? _defaultStatus()
        : localizedStorePurchaseNotice(
            widget.language.appLanguage,
            store.notice!,
          );

    return Semantics(
      liveRegion: true,
      label: status,
      child: Container(
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
              status,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _productTile(BuildContext context, String id) {
    final product = store.productFor(id);
    final active = selectedId == id;
    final purchased = store.activeProductId == id;
    final title = switch (id) {
      MysticProductIds.monthly => t(
          en: 'Monthly',
          es: 'Mensual',
          fr: 'Mensuel',
          pt: 'Mensal',
          tr: 'Aylık',
          it: 'Mensile',
          de: 'Monatlich',
        ),
      _ => t(
          en: 'Yearly',
          es: 'Anual',
          fr: 'Annuel',
          pt: 'Anual',
          tr: 'Yıllık',
          it: 'Annuale',
          de: 'Jährlich',
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: !store.isPlus,
        selected: active || purchased,
        label: title,
        child: InkWell(
          onTap: store.isPlus ? null : () => setState(() => selectedId = id),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: active || purchased
                  ? MysticColors.violet.withValues(alpha: .3)
                  : Colors.white.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: active || purchased
                    ? MysticColors.gold
                    : Colors.white12,
                width: active || purchased ? 2 : 1,
              ),
            ),
            child: Row(children: [
              Icon(
                purchased
                    ? Icons.verified_rounded
                    : active
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                color: active || purchased
                    ? MysticColors.gold
                    : MysticColors.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (product != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
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
      ),
    );
  }

  String _defaultStatus() => switch (store.phase) {
        StorePurchasePhase.idle || StorePurchasePhase.loading => t(
            en: 'Loading secure subscription options…',
            es: 'Cargando opciones seguras…',
            fr: 'Chargement des abonnements sécurisés…',
            pt: 'Carregando opções seguras…',
            tr: 'Güvenli abonelik seçenekleri yükleniyor…',
            it: 'Caricamento delle opzioni sicure…',
            de: 'Sichere Abo-Optionen werden geladen…',
          ),
        StorePurchasePhase.ready => t(
            en: 'Official store products are ready.',
            es: 'Los productos oficiales están listos.',
            fr: 'Les produits officiels sont prêts.',
            pt: 'Os produtos oficiais estão prontos.',
            tr: 'Resmi mağaza ürünleri hazır.',
            it: 'I prodotti ufficiali sono pronti.',
            de: 'Die offiziellen Store-Produkte sind bereit.',
          ),
        StorePurchasePhase.purchasing => t(
            en: 'Opening the official store checkout…',
            es: 'Abriendo el pago oficial…',
            fr: 'Ouverture du paiement officiel…',
            pt: 'Abrindo o pagamento oficial…',
            tr: 'Resmi mağaza ödeme ekranı açılıyor…',
            it: 'Apertura del pagamento ufficiale…',
            de: 'Der offizielle Checkout wird geöffnet…',
          ),
        StorePurchasePhase.restoring => t(
            en: 'Restoring previous purchases…',
            es: 'Restaurando compras anteriores…',
            fr: 'Restauration des achats précédents…',
            pt: 'Restaurando compras anteriores…',
            tr: 'Önceki satın alımlar geri yükleniyor…',
            it: 'Ripristino degli acquisti precedenti…',
            de: 'Frühere Käufe werden wiederhergestellt…',
          ),
        StorePurchasePhase.entitled => t(
            en: 'Mystic Plus is verified and active.',
            es: 'Mystic Plus está verificado y activo.',
            fr: 'Mystic Plus est vérifié et actif.',
            pt: 'O Mystic Plus está verificado e ativo.',
            tr: 'Mystic Plus doğrulandı ve etkin.',
            it: 'Mystic Plus è verificato e attivo.',
            de: 'Mystic Plus ist verifiziert und aktiv.',
          ),
        StorePurchasePhase.unavailable => t(
            en: 'Subscription products are not available right now.',
            es: 'Los productos de suscripción no están disponibles ahora.',
            fr: 'Les abonnements ne sont pas disponibles actuellement.',
            pt: 'Os produtos de assinatura não estão disponíveis agora.',
            tr: 'Abonelik ürünleri şu anda kullanılamıyor.',
            it: 'I prodotti in abbonamento non sono disponibili.',
            de: 'Abo-Produkte sind derzeit nicht verfügbar.',
          ),
        StorePurchasePhase.error => t(
            en: 'The subscription connection needs another try.',
            es: 'Es necesario volver a intentar la conexión.',
            fr: 'La connexion d’abonnement doit être réessayée.',
            pt: 'É preciso tentar novamente a conexão.',
            tr: 'Abonelik bağlantısının yeniden denenmesi gerekiyor.',
            it: 'È necessario riprovare la connessione.',
            de: 'Die Abo-Verbindung muss erneut versucht werden.',
          ),
      };

  String _buttonLabel() {
    if (store.isPlus) {
      return t(
        en: 'Mystic Plus active',
        es: 'Mystic Plus activo',
        fr: 'Mystic Plus actif',
        pt: 'Mystic Plus ativo',
        tr: 'Mystic Plus etkin',
        it: 'Mystic Plus attivo',
        de: 'Mystic Plus aktiv',
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
            de: 'Produkt nicht verfügbar',
          )
        : t(
            en: 'Continue with ${product.price}',
            es: 'Continuar con ${product.price}',
            fr: 'Continuer avec ${product.price}',
            pt: 'Continuar com ${product.price}',
            tr: '${product.price} ile devam et',
            it: 'Continua con ${product.price}',
            de: 'Weiter mit ${product.price}',
          );
  }
}
