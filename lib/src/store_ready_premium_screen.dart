import 'package:flutter/material.dart';

import 'ad_revenue_service.dart';
import 'app_language.dart';
import 'language_bridge.dart';
import 'store_purchase_service.dart';
import 'theme.dart';
import 'widgets.dart';

/// Backwards-compatible route for places that historically opened the Mystic
/// Plus paywall. The business model is now advertising-only, so this screen
/// never sells, restores, or manages a subscription.
class StoreReadyPremiumScreen extends StatelessWidget {
  const StoreReadyPremiumScreen({
    required this.source,
    required this.language,
    this.subscriptionStore,
    super.key,
  });

  final String source;
  final MysticLanguage language;
  final StorePurchaseService? subscriptionStore;

  String t({
    required String en,
    required String es,
    required String fr,
    required String pt,
    required String tr,
  }) => localized(
    language.appLanguage,
    english: en,
    spanish: es,
    french: fr,
    portugueseBrazil: pt,
    turkish: tr,
    italian: en,
    german: en,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: MysticBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 62,
                color: MysticColors.gold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t(
                en: 'Everything is unlocked.',
                es: 'Todo está desbloqueado.',
                fr: 'Tout est débloqué.',
                pt: 'Tudo está desbloqueado.',
                tr: 'Her şey açık.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            Text(
              t(
                en: 'Mystic Tarot is free to use. Revenue comes only from occasional ads in the native Android and iOS apps — there is no subscription to buy.',
                es: 'Mystic Tarot es gratis. Los ingresos provienen únicamente de anuncios ocasionales en las apps nativas de Android e iOS; no hay suscripción.',
                fr: 'Mystic Tarot est gratuit. Les revenus proviennent uniquement de publicités occasionnelles dans les apps Android et iOS ; aucun abonnement n’est vendu.',
                pt: 'Mystic Tarot é gratuito. A receita vem apenas de anúncios ocasionais nos apps nativos para Android e iOS; não há assinatura.',
                tr: 'Mystic Tarot ücretsizdir. Gelir yalnızca Android ve iOS uygulamalarındaki seyrek reklamlardan gelir; satın alınacak abonelik yoktur.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 22),
            _feature(
              context,
              Icons.style_rounded,
              t(
                en: 'All readings and spreads',
                es: 'Todas las lecturas y tiradas',
                fr: 'Tous les tirages et lectures',
                pt: 'Todas as leituras e tiragens',
                tr: 'Tüm okumalar ve açılımlar',
              ),
            ),
            _feature(
              context,
              Icons.hourglass_bottom_rounded,
              'Mystic Mirror · 24h reality check',
            ),
            _feature(
              context,
              Icons.menu_book_rounded,
              t(
                en: 'Living Journal, patterns and Oracle',
                es: 'Diario, patrones y Oráculo',
                fr: 'Journal, schémas et Oracle',
                pt: 'Diário, padrões e Oráculo',
                tr: 'Yaşayan Günlük, örüntüler ve Oracle',
              ),
            ),
            const SizedBox(height: 22),
            GoldButton(
              label: t(
                en: 'Continue free',
                es: 'Continuar gratis',
                fr: 'Continuer gratuitement',
                pt: 'Continuar grátis',
                tr: 'Ücretsiz devam et',
              ),
              icon: Icons.arrow_forward_rounded,
              onPressed: () => Navigator.pop(context, true),
            ),
            if (AdRevenueService.instance.privacyOptionsAvailable) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: AdRevenueService.instance.showPrivacyOptions,
                icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                label: Text(
                  t(
                    en: 'Advertising privacy choices',
                    es: 'Opciones de privacidad publicitaria',
                    fr: 'Choix de confidentialité publicitaire',
                    pt: 'Opções de privacidade de anúncios',
                    tr: 'Reklam gizlilik tercihleri',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              t(
                en: 'The public web edition remains ad-free. Native ads are requested only after the consent system says an ad request is allowed.',
                es: 'La versión web pública sigue sin anuncios. En móvil solo se solicitan anuncios cuando el sistema de consentimiento lo permite.',
                fr: 'La version web publique reste sans publicité. Sur mobile, les annonces ne sont demandées qu’après autorisation du système de consentement.',
                pt: 'A versão web pública continua sem anúncios. No celular, anúncios só são solicitados quando o sistema de consentimento permite.',
                tr: 'Herkese açık web sürümü reklamsız kalır. Mobilde reklam yalnızca izin sistemi reklam isteğine izin verdiğinde talep edilir.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _feature(BuildContext context, IconData icon, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MysticColors.violet.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: MysticColors.lavender.withValues(alpha: .18),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: MysticColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    ),
  );
}
