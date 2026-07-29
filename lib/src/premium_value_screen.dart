import 'dart:async';

import 'package:flutter/material.dart';

import 'app_analytics_bindings.dart';
import 'app_language.dart';
import 'flagship.dart';
import 'language_bridge.dart';
import 'theme.dart';
import 'widgets.dart';

class PremiumValueScreen extends StatefulWidget {
  const PremiumValueScreen({
    required this.source,
    required this.language,
    required this.onContinue,
    super.key,
  });

  final String source;
  final MysticLanguage language;
  final VoidCallback onContinue;

  @override
  State<PremiumValueScreen> createState() => _PremiumValueScreenState();
}

class _PremiumValueScreenState extends State<PremiumValueScreen> {
  static const _analytics = MysticAnalyticsBindings();

  @override
  void initState() {
    super.initState();
    unawaited(_analytics.premiumViewed(source: widget.source));
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = widget.language.appLanguage;
    final message = _sourceMessage(appLanguage);
    final benefits = <({IconData icon, String title, String body})>[
      (
        icon: Icons.all_inclusive,
        title: localized(appLanguage, english: 'Unlimited deep readings', spanish: 'Lecturas profundas ilimitadas', french: 'Tirages approfondis illimités', portugueseBrazil: 'Leituras profundas ilimitadas', turkish: 'Sınırsız derin okuma', italian: 'Letture approfondite illimitate', german: 'Unbegrenzte Tiefenlegungen'),
        body: localized(appLanguage, english: 'Continue beyond the daily free allowance whenever a question needs more space.', spanish: 'Continúa más allá del límite gratuito diario cuando una pregunta necesite más espacio.', french: 'Dépassez la limite gratuite quotidienne lorsqu’une question demande plus d’espace.', portugueseBrazil: 'Continue além do limite diário gratuito quando uma pergunta precisar de mais espaço.', turkish: 'Bir soru daha fazla alan istediğinde günlük ücretsiz sınırın ötesine geç.', italian: 'Continua oltre il limite gratuito giornaliero quando una domanda richiede più spazio.', german: 'Gehe über das tägliche Gratislimit hinaus, wenn eine Frage mehr Raum braucht.'),
      ),
      (
        icon: Icons.hub_outlined,
        title: localized(appLanguage, english: 'Premium spreads', spanish: 'Tiradas premium', french: 'Tirages premium', portugueseBrazil: 'Tiragens premium', turkish: 'Premium açılımlar', italian: 'Stese premium', german: 'Premium-Legungen'),
        body: localized(appLanguage, english: 'Unlock Compatibility, Timeline, and Celtic Cross readings.', spanish: 'Desbloquea Compatibilidad, Línea temporal y Cruz Celta.', french: 'Débloquez Compatibilité, Chronologie et Croix Celtique.', portugueseBrazil: 'Desbloqueie Compatibilidade, Linha do tempo e Cruz Celta.', turkish: 'Uyum, Zaman Çizgisi ve Kelt Haçı okumalarını aç.', italian: 'Sblocca Compatibilità, Linea temporale e Croce Celtica.', german: 'Schalte Kompatibilität, Zeitlinie und Keltisches Kreuz frei.'),
      ),
      (
        icon: Icons.forum_outlined,
        title: localized(appLanguage, english: 'Longer Oracle dialogue', spanish: 'Diálogo más largo con el Oráculo', french: 'Dialogue prolongé avec l’Oracle', portugueseBrazil: 'Diálogo mais longo com o Oráculo', turkish: 'Daha uzun Oracle diyaloğu', italian: 'Dialogo più lungo con l’Oracolo', german: 'Längerer Orakel-Dialog'),
        body: localized(appLanguage, english: 'Ask follow-up questions without ending the reflection after one answer.', spanish: 'Haz preguntas de seguimiento sin terminar la reflexión tras una sola respuesta.', french: 'Posez des questions de suivi sans arrêter la réflexion après une seule réponse.', portugueseBrazil: 'Faça perguntas de acompanhamento sem encerrar a reflexão após uma única resposta.', turkish: 'Yansımayı tek cevapta bitirmeden devam soruları sor.', italian: 'Fai domande successive senza fermare la riflessione dopo una sola risposta.', german: 'Stelle Folgefragen, ohne die Reflexion nach einer Antwort zu beenden.'),
      ),
      (
        icon: Icons.lock_outline,
        title: localized(appLanguage, english: 'Private by design', spanish: 'Privado por diseño', french: 'Privé par conception', portugueseBrazil: 'Privado por padrão', turkish: 'Tasarım gereği özel', italian: 'Privato per progettazione', german: 'Von Grund auf privat'),
        body: localized(appLanguage, english: 'Your journal and identity analysis stay on your device.', spanish: 'Tu diario y el análisis de identidad permanecen en tu dispositivo.', french: 'Votre journal et l’analyse de votre identité restent sur votre appareil.', portugueseBrazil: 'Seu diário e a análise de identidade permanecem no seu dispositivo.', turkish: 'Günlüğün ve kimlik analizin cihazında kalır.', italian: 'Il diario e l’analisi dell’identità restano sul tuo dispositivo.', german: 'Dein Tagebuch und deine Identitätsanalyse bleiben auf deinem Gerät.'),
      ),
    ];

    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                const Spacer(),
                const Text('MYSTIC PLUS', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                const Spacer(),
                const SizedBox(width: 48),
              ]),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(center: Alignment(0, -.85), radius: 1.35, colors: [Color(0xFF7651B7), Color(0xFF2B1A46), Color(0xFF15101F)]),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: MysticColors.gold.withValues(alpha: .45)),
                  boxShadow: [BoxShadow(color: MysticColors.violet.withValues(alpha: .22), blurRadius: 38)],
                ),
                child: Column(children: [
                  Container(width: 78, height: 78, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: .18), border: Border.all(color: MysticColors.gold.withValues(alpha: .62))), child: const Text('✦', style: TextStyle(fontSize: 38, color: MysticColors.gold))),
                  const SizedBox(height: 18),
                  Text(message.$1, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(message.$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                ]),
              ),
              const SizedBox(height: 18),
              ...benefits.map((benefit) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .045), borderRadius: BorderRadius.circular(19), border: Border.all(color: Colors.white10)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 43, height: 43, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: MysticColors.gold.withValues(alpha: .12)), child: Icon(benefit.icon, color: MysticColors.gold, size: 21)),
                      const SizedBox(width: 13),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(benefit.title, style: const TextStyle(fontFamily: 'Arial', fontSize: 13, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 5),
                        Text(benefit.body, style: Theme.of(context).textTheme.bodyMedium),
                      ])),
                    ]),
                  )),
              const SizedBox(height: 8),
              GoldButton(
                label: localized(appLanguage, english: 'See plans', spanish: 'Ver planes', french: 'Voir les offres', portugueseBrazil: 'Ver planos', turkish: 'Planları gör', italian: 'Vedi i piani', german: 'Pläne ansehen'),
                icon: Icons.arrow_forward,
                onPressed: widget.onContinue,
              ),
              const SizedBox(height: 10),
              Text(
                localized(appLanguage, english: 'Review pricing and terms before making any purchase.', spanish: 'Revisa el precio y las condiciones antes de realizar cualquier compra.', french: 'Consultez le prix et les conditions avant tout achat.', portugueseBrazil: 'Revise o preço e os termos antes de qualquer compra.', turkish: 'Herhangi bir satın alma yapmadan önce fiyatı ve koşulları incele.', italian: 'Controlla prezzo e condizioni prima di qualsiasi acquisto.', german: 'Prüfe Preis und Bedingungen vor jedem Kauf.'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, String) _sourceMessage(AppLanguage language) {
    return switch (widget.source) {
      'daily_limit' => (
          localized(language, english: 'Keep going when the question still matters.', spanish: 'Continúa cuando la pregunta aún importa.', french: 'Continuez lorsque la question compte encore.', portugueseBrazil: 'Continue quando a pergunta ainda importa.', turkish: 'Soru hâlâ önemliyken devam et.', italian: 'Continua quando la domanda conta ancora.', german: 'Mach weiter, wenn die Frage noch wichtig ist.'),
          localized(language, english: 'You used today’s free deep readings. Mystic Plus removes the daily limit while keeping Daily Guidance free.', spanish: 'Usaste las lecturas profundas gratuitas de hoy. Mystic Plus elimina el límite diario y mantiene gratuita la Guía diaria.', french: 'Vous avez utilisé les tirages approfondis gratuits du jour. Mystic Plus supprime la limite quotidienne tout en gardant le Guide du jour gratuit.', portugueseBrazil: 'Você usou as leituras profundas gratuitas de hoje. O Mystic Plus remove o limite diário e mantém a Orientação Diária gratuita.', turkish: 'Bugünkü ücretsiz derin okumalarını kullandın. Mystic Plus günlük sınırı kaldırırken Günlük Rehberlik ücretsiz kalır.', italian: 'Hai usato le letture approfondite gratuite di oggi. Mystic Plus rimuove il limite giornaliero mantenendo gratuita la Guida quotidiana.', german: 'Du hast die heutigen kostenlosen Tiefenlegungen genutzt. Mystic Plus entfernt das Tageslimit, während die tägliche Führung kostenlos bleibt.'),
        ),
      'premium_spread' => (
          localized(language, english: 'Some questions deserve a wider spread.', spanish: 'Algunas preguntas merecen una tirada más amplia.', french: 'Certaines questions méritent un tirage plus large.', portugueseBrazil: 'Algumas perguntas merecem uma tiragem mais ampla.', turkish: 'Bazı sorular daha geniş bir açılımı hak eder.', italian: 'Alcune domande meritano una stesa più ampia.', german: 'Manche Fragen verdienen eine größere Legung.'),
          localized(language, english: 'Unlock the high-depth spreads designed for compatibility, timing, and complex decisions.', spanish: 'Desbloquea tiradas profundas para compatibilidad, tiempos y decisiones complejas.', french: 'Débloquez des tirages approfondis pour la compatibilité, le timing et les décisions complexes.', portugueseBrazil: 'Desbloqueie tiragens profundas para compatibilidade, tempo e decisões complexas.', turkish: 'Uyum, zamanlama ve karmaşık kararlar için tasarlanan derin açılımları aç.', italian: 'Sblocca le stese approfondite per compatibilità, tempistiche e decisioni complesse.', german: 'Schalte Tiefenlegungen für Kompatibilität, Timing und komplexe Entscheidungen frei.'),
        ),
      'oracle_dialogue' => (
          localized(language, english: 'Stay with the question a little longer.', spanish: 'Quédate un poco más con la pregunta.', french: 'Restez encore un peu avec la question.', portugueseBrazil: 'Fique mais um pouco com a pergunta.', turkish: 'Soruyla biraz daha kal.', italian: 'Resta ancora un po’ con la domanda.', german: 'Bleib noch etwas länger bei der Frage.'),
          localized(language, english: 'Continue the Oracle dialogue with more personal follow-up questions.', spanish: 'Continúa el diálogo con el Oráculo mediante más preguntas personales.', french: 'Poursuivez le dialogue avec l’Oracle grâce à davantage de questions personnelles.', portugueseBrazil: 'Continue o diálogo com o Oráculo com mais perguntas pessoais.', turkish: 'Daha fazla kişisel devam sorusuyla Oracle diyaloğunu sürdür.', italian: 'Continua il dialogo con l’Oracolo con altre domande personali.', german: 'Setze den Orakel-Dialog mit weiteren persönlichen Folgefragen fort.'),
        ),
      _ => (
          localized(language, english: 'Build a deeper private practice.', spanish: 'Construye una práctica privada más profunda.', french: 'Construisez une pratique privée plus profonde.', portugueseBrazil: 'Crie uma prática privada mais profunda.', turkish: 'Daha derin ve özel bir pratik oluştur.', italian: 'Costruisci una pratica privata più profonda.', german: 'Baue eine tiefere private Praxis auf.'),
          localized(language, english: 'See what Mystic Plus adds before reviewing the available plans.', spanish: 'Descubre lo que añade Mystic Plus antes de revisar los planes disponibles.', french: 'Découvrez ce que Mystic Plus ajoute avant de consulter les offres disponibles.', portugueseBrazil: 'Veja o que o Mystic Plus adiciona antes de revisar os planos disponíveis.', turkish: 'Mevcut planları incelemeden önce Mystic Plus’ın neler eklediğini gör.', italian: 'Scopri cosa aggiunge Mystic Plus prima di consultare i piani disponibili.', german: 'Sieh dir an, was Mystic Plus hinzufügt, bevor du die verfügbaren Pläne prüfst.'),
        ),
    };
  }
}
