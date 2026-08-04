import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_language.dart';
import 'flagship.dart';
import 'language_bridge.dart';
import 'launch_differentiation.dart';
import 'store_purchase_service.dart';
import 'store_status_localization.dart';
import 'subscription_value.dart';
import 'theme.dart';
import 'widgets.dart';

class StoreReadyPremiumScreen extends StatefulWidget {
  const StoreReadyPremiumScreen({
    required this.source,
    required this.language,
    this.subscriptionStore,
    super.key,
  });

  final String source;
  final MysticLanguage language;
  final StorePurchaseService? subscriptionStore;

  @override
  State<StoreReadyPremiumScreen> createState() =>
      _StoreReadyPremiumScreenState();
}

class _StoreReadyPremiumScreenState extends State<StoreReadyPremiumScreen>
    with WidgetsBindingObserver {
  late final StorePurchaseService store;
  late final bool ownsStore;
  String selectedId = MysticProductIds.yearly;

  String t({
    required String en,
    required String es,
    required String fr,
    required String pt,
    required String tr,
    required String it,
    required String de,
  }) => localized(
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
    WidgetsBinding.instance.addObserver(this);
    ownsStore = widget.subscriptionStore == null;
    store = widget.subscriptionStore ?? StorePurchaseService();
    if (store.phase == StorePurchasePhase.idle) {
      store.initialize();
    } else {
      store.refreshEntitlement();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      store.refreshEntitlement();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (ownsStore) store.dispose();
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
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed:
                        !store.canRestore ||
                            store.phase == StorePurchasePhase.restoring
                        ? null
                        : store.restore,
                    child: Text(
                      t(
                        en: 'Restore',
                        es: 'Restaurar',
                        fr: 'Restaurer',
                        pt: 'Restaurar',
                        tr: 'Geri yükle',
                        it: 'Ripristina',
                        de: 'Wiederherstellen',
                      ),
                    ),
                  ),
                ],
              ),
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
                        en: 'Your Mystic Plus is active.',
                        es: 'Tu Mystic Plus está activo.',
                        fr: 'Votre Mystic Plus est actif.',
                        pt: 'Seu Mystic Plus está ativo.',
                        tr: 'Mystic Plus üyeliğin etkin.',
                        it: 'Il tuo Mystic Plus è attivo.',
                        de: 'Dein Mystic Plus ist aktiv.',
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
                        en: 'Review your verified plan, restore access, or open the official store subscription settings.',
                        es: 'Revisa tu plan verificado o abre la gestión oficial de la tienda.',
                        fr: 'Consultez votre formule vérifiée ou ouvrez la gestion officielle.',
                        pt: 'Revise seu plano verificado ou abra o gerenciamento oficial.',
                        tr: 'Doğrulanmış planını gör, erişimi geri yükle veya resmi mağaza abonelik ayarlarını aç.',
                        it: 'Controlla il piano verificato o apri la gestione ufficiale.',
                        de: 'Prüfe deinen verifizierten Plan oder öffne die offizielle Verwaltung.',
                      )
                    : t(
                        en: 'Official localized prices come directly from the App Store or Google Play. Plus opens only after secure verification.',
                        es: 'Los precios oficiales vienen de la tienda. Plus se activa tras una verificación segura.',
                        fr: 'Les prix officiels viennent de la boutique. Plus s’active après vérification.',
                        pt: 'Os preços oficiais vêm da loja. O Plus abre após verificação segura.',
                        tr: 'Yerel fiyatlar doğrudan App Store veya Google Play’den gelir. Plus yalnızca güvenli doğrulamadan sonra açılır.',
                        it: 'I prezzi ufficiali arrivano dallo store. Plus si attiva dopo la verifica.',
                        de: 'Offizielle Preise kommen aus dem Store. Plus wird nach sicherer Prüfung aktiviert.',
                      ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _statusCard(context),
              const SizedBox(height: 18),
              LaunchContinuityTimeline(
                language: widget.language,
                compact: true,
              ),
              const SizedBox(height: 12),
              _benefits(context),
              const SizedBox(height: 12),
              PrivateByDesignCard(language: widget.language),
              const SizedBox(height: 18),
              if (store.isPlus) _activeAccountCard(context),
              if (!store.isPlus)
                ..._planIds.map((id) => _productTile(context, id)),
              const SizedBox(height: 18),
              GoldButton(
                label: store.isPlus
                    ? t(
                        en: 'Manage subscription',
                        es: 'Gestionar suscripción',
                        fr: 'Gérer l’abonnement',
                        pt: 'Gerenciar assinatura',
                        tr: 'Aboneliği yönet',
                        it: 'Gestisci abbonamento',
                        de: 'Abo verwalten',
                      )
                    : _purchaseButtonLabel(),
                icon: store.isPlus
                    ? Icons.settings_outlined
                    : Icons.lock_open_rounded,
                onPressed: store.isPlus
                    ? (_managementUri == null ? null : _manageSubscription)
                    : (store.canPurchase ? () => store.buy(selectedId) : null),
              ),
              const SizedBox(height: 8),
              if (store.isPlus)
                TextButton.icon(
                  onPressed: store.refreshEntitlement,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    t(
                      en: 'Refresh membership status',
                      es: 'Actualizar membresía',
                      fr: 'Actualiser le statut',
                      pt: 'Atualizar status',
                      tr: 'Üyelik durumunu yenile',
                      it: 'Aggiorna stato',
                      de: 'Mitgliedschaft aktualisieren',
                    ),
                  ),
                ),
              const SizedBox(height: 8),
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
          ),
        ),
      ),
    ),
  );

  List<String> get _planIds => const [
    MysticProductIds.yearly,
    MysticProductIds.monthly,
  ];

  Uri? get _managementUri {
    final direct = Uri.tryParse(store.managementUrl ?? '');
    if (direct != null && direct.hasScheme) return direct;
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => Uri.parse(
        'https://apps.apple.com/account/subscriptions',
      ),
      TargetPlatform.android => Uri.parse(
        'https://play.google.com/store/account/subscriptions',
      ),
      _ => null,
    };
  }

  Future<void> _manageSubscription() async {
    final uri = _managementUri;
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t(
              en: 'The official subscription settings could not be opened.',
              es: 'No se pudo abrir la gestión oficial.',
              fr: 'La gestion officielle n’a pas pu être ouverte.',
              pt: 'Não foi possível abrir o gerenciamento oficial.',
              tr: 'Resmi abonelik ayarları açılamadı.',
              it: 'Impossibile aprire la gestione ufficiale.',
              de: 'Die offizielle Verwaltung konnte nicht geöffnet werden.',
            ),
          ),
        ),
      );
    }
  }

  Widget _statusCard(BuildContext context) {
    final loading =
        store.phase == StorePurchasePhase.loading ||
        store.phase == StorePurchasePhase.restoring ||
        store.phase == StorePurchasePhase.purchasing;
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
        child: Row(
          children: [
            if (loading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MysticColors.gold,
                ),
              )
            else
              Icon(
                store.isPlus
                    ? Icons.verified_rounded
                    : Icons.storefront_outlined,
                color: MysticColors.gold,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeAccountCard(BuildContext context) {
    final product = store.activeProductId == null
        ? null
        : store.productFor(store.activeProductId!);
    final through = store.expiresAt == null
        ? null
        : '${store.expiresAt!.toLocal().year}-'
              '${store.expiresAt!.toLocal().month.toString().padLeft(2, '0')}-'
              '${store.expiresAt!.toLocal().day.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6847B7), Color(0xFF2B1B4A)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MysticColors.gold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: MysticColors.gold),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _planTitle(store.activeProductId),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (store.isSandbox)
                _chip(
                  t(
                    en: 'SANDBOX',
                    es: 'PRUEBA',
                    fr: 'TEST',
                    pt: 'TESTE',
                    tr: 'TEST',
                    it: 'TEST',
                    de: 'TEST',
                  ),
                ),
            ],
          ),
          if (product != null) ...[
            const SizedBox(height: 8),
            Text(
              product.price,
              style: const TextStyle(
                color: MysticColors.gold,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
          if (through != null) ...[
            const SizedBox(height: 8),
            Text(
              t(
                en: 'Current verified access through $through.',
                es: 'Acceso verificado hasta $through.',
                fr: 'Accès vérifié jusqu’au $through.',
                pt: 'Acesso verificado até $through.',
                tr: 'Doğrulanmış mevcut erişim tarihi: $through.',
                it: 'Accesso verificato fino al $through.',
                de: 'Verifizierter Zugriff bis $through.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            t(
              en: 'Cancellation or plan changes are completed in the official store account.',
              es: 'La cancelación y los cambios se realizan en la tienda oficial.',
              fr: 'L’annulation et les changements se font dans la boutique officielle.',
              pt: 'Cancelamentos e mudanças são feitos na loja oficial.',
              tr: 'İptal veya plan değişikliği resmi mağaza hesabından yapılır.',
              it: 'Annullamento e modifiche avvengono nello store ufficiale.',
              de: 'Kündigung und Änderungen erfolgen im offiziellen Store.',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _productTile(BuildContext context, String id) {
    final product = store.productFor(id);
    final active = selectedId == id;
    final savings = id == MysticProductIds.yearly
        ? yearlySavingsPercent(
            monthly: store.productFor(MysticProductIds.monthly),
            yearly: product,
          )
        : null;
    final equivalent = id == MysticProductIds.yearly
        ? yearlyMonthlyEquivalent(product)
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        selected: active,
        label: _planTitle(id),
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
            child: Row(
              children: [
                Icon(
                  active ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: active ? MysticColors.gold : MysticColors.muted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _planTitle(id),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (savings != null) ...[
                            const SizedBox(width: 8),
                            _chip(
                              t(
                                en: 'SAVE $savings%',
                                es: 'AHORRA $savings%',
                                fr: 'ÉCONOMISEZ $savings%',
                                pt: 'ECONOMIZE $savings%',
                                tr: '%$savings TASARRUF',
                                it: 'RISPARMIA $savings%',
                                de: '$savings% SPAREN',
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (equivalent != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          t(
                            en: '$equivalent per month, billed yearly',
                            es: '$equivalent al mes, facturado anualmente',
                            fr: '$equivalent par mois, facturé annuellement',
                            pt: '$equivalent por mês, cobrado anualmente',
                            tr: 'Aylık karşılığı $equivalent, yıllık faturalandırılır',
                            it: '$equivalent al mese, fatturato annualmente',
                            de: '$equivalent pro Monat, jährlich abgerechnet',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ] else if (product != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  product?.price ?? '—',
                  style: const TextStyle(
                    color: MysticColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _benefits(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .035),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      children: [
        _benefit(
          Icons.insights_outlined,
          t(
            en: 'A fresh private intelligence report every seven days',
            es: 'Un nuevo informe privado de inteligencia cada siete días',
            fr: 'Un nouveau rapport privé d’intelligence tous les sept jours',
            pt: 'Um novo relatório privado de inteligência a cada sete dias',
            tr: 'Her yedi günde yenilenen özel intelligence raporu',
            it: 'Un nuovo report privato ogni sette giorni',
            de: 'Ein neuer privater Intelligence-Bericht alle sieben Tage',
          ),
        ),
        _benefit(
          Icons.all_inclusive,
          t(
            en: 'Unlimited deep readings',
            es: 'Lecturas profundas ilimitadas',
            fr: 'Lectures approfondies illimitées',
            pt: 'Leituras profundas ilimitadas',
            tr: 'Sınırsız derin okuma',
            it: 'Letture approfondite illimitate',
            de: 'Unbegrenzte Tiefenlesungen',
          ),
        ),
        _benefit(
          Icons.auto_awesome,
          t(
            en: 'Premium spreads and unlimited Oracle follow-ups',
            es: 'Tiradas premium y preguntas ilimitadas',
            fr: 'Tirages premium et questions illimitées',
            pt: 'Tiragens premium e perguntas ilimitadas',
            tr: 'Premium açılımlar ve sınırsız Oracle sorusu',
            it: 'Stese premium e domande illimitate',
            de: 'Premium-Legungen und unbegrenzte Fragen',
          ),
        ),
        _benefit(
          Icons.verified_user_outlined,
          t(
            en: 'Secure verification and restore across installs',
            es: 'Verificación segura y restauración',
            fr: 'Vérification sécurisée et restauration',
            pt: 'Verificação segura e restauração',
            tr: 'Güvenli doğrulama ve yeniden kurulumda geri yükleme',
            it: 'Verifica sicura e ripristino',
            de: 'Sichere Prüfung und Wiederherstellung',
          ),
        ),
      ],
    ),
  );

  Widget _benefit(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Icon(icon, color: MysticColors.gold, size: 21),
        const SizedBox(width: 11),
        Expanded(child: Text(text)),
      ],
    ),
  );

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: MysticColors.gold.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: MysticColors.gold.withValues(alpha: .5)),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: MysticColors.gold,
        fontSize: 9,
        fontWeight: FontWeight.w900,
      ),
    ),
  );

  String _planTitle(String? id) => id == MysticProductIds.monthly
      ? t(
          en: 'Monthly Mystic Plus',
          es: 'Mystic Plus mensual',
          fr: 'Mystic Plus mensuel',
          pt: 'Mystic Plus mensal',
          tr: 'Aylık Mystic Plus',
          it: 'Mystic Plus mensile',
          de: 'Monatliches Mystic Plus',
        )
      : t(
          en: 'Yearly Mystic Plus',
          es: 'Mystic Plus anual',
          fr: 'Mystic Plus annuel',
          pt: 'Mystic Plus anual',
          tr: 'Yıllık Mystic Plus',
          it: 'Mystic Plus annuale',
          de: 'Jährliches Mystic Plus',
        );

  String _purchaseButtonLabel() {
    final product = store.productFor(selectedId);
    if (store.phase == StorePurchasePhase.purchasing) {
      return t(
        en: 'Opening store…',
        es: 'Abriendo tienda…',
        fr: 'Ouverture…',
        pt: 'Abrindo loja…',
        tr: 'Mağaza açılıyor…',
        it: 'Apertura store…',
        de: 'Store wird geöffnet…',
      );
    }
    return product == null
        ? t(
            en: 'Continue with Mystic Plus',
            es: 'Continuar con Mystic Plus',
            fr: 'Continuer avec Mystic Plus',
            pt: 'Continuar com Mystic Plus',
            tr: 'Mystic Plus ile devam et',
            it: 'Continua con Mystic Plus',
            de: 'Mit Mystic Plus fortfahren',
          )
        : '${_planTitle(selectedId)} • ${product.price}';
  }

  String _defaultStatus() => switch (store.phase) {
    StorePurchasePhase.idle || StorePurchasePhase.loading => t(
      en: 'Loading secure subscription options…',
      es: 'Cargando opciones seguras…',
      fr: 'Chargement des options sécurisées…',
      pt: 'Carregando opções seguras…',
      tr: 'Güvenli abonelik seçenekleri yükleniyor…',
      it: 'Caricamento delle opzioni sicure…',
      de: 'Sichere Optionen werden geladen…',
    ),
    StorePurchasePhase.ready => t(
      en: 'Official store products are ready.',
      es: 'Los productos oficiales están listos.',
      fr: 'Les produits officiels sont prêts.',
      pt: 'Os produtos oficiais estão prontos.',
      tr: 'Resmi mağaza ürünleri hazır.',
      it: 'I prodotti ufficiali sono pronti.',
      de: 'Die offiziellen Produkte sind bereit.',
    ),
    StorePurchasePhase.purchasing => t(
      en: 'Opening official checkout…',
      es: 'Abriendo el pago oficial…',
      fr: 'Ouverture du paiement officiel…',
      pt: 'Abrindo o pagamento oficial…',
      tr: 'Resmi ödeme ekranı açılıyor…',
      it: 'Apertura del pagamento ufficiale…',
      de: 'Der offizielle Checkout wird geöffnet…',
    ),
    StorePurchasePhase.restoring => t(
      en: 'Restoring previous purchases…',
      es: 'Restaurando compras…',
      fr: 'Restauration des achats…',
      pt: 'Restaurando compras…',
      tr: 'Satın alımlar geri yükleniyor…',
      it: 'Ripristino degli acquisti…',
      de: 'Käufe werden wiederhergestellt…',
    ),
    StorePurchasePhase.entitled => t(
      en: 'Mystic Plus is verified and active.',
      es: 'Mystic Plus está verificado y activo.',
      fr: 'Mystic Plus est vérifié et actif.',
      pt: 'Mystic Plus está verificado e ativo.',
      tr: 'Mystic Plus doğrulandı ve etkin.',
      it: 'Mystic Plus è verificato e attivo.',
      de: 'Mystic Plus ist verifiziert und aktiv.',
    ),
    StorePurchasePhase.unavailable => t(
      en: 'Subscription products are unavailable right now.',
      es: 'Las suscripciones no están disponibles.',
      fr: 'Les abonnements ne sont pas disponibles.',
      pt: 'As assinaturas não estão disponíveis.',
      tr: 'Abonelik ürünleri şu anda kullanılamıyor.',
      it: 'Gli abbonamenti non sono disponibili.',
      de: 'Abos sind derzeit nicht verfügbar.',
    ),
    StorePurchasePhase.error => t(
      en: 'The subscription connection needs another try.',
      es: 'Vuelve a intentar la conexión.',
      fr: 'Veuillez réessayer la connexion.',
      pt: 'Tente novamente a conexão.',
      tr: 'Abonelik bağlantısını yeniden denemek gerekiyor.',
      it: 'Riprova la connessione.',
      de: 'Bitte versuche die Verbindung erneut.',
    ),
  };
}
