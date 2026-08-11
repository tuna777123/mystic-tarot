import 'package:flutter/material.dart';

import 'flagship.dart';
import 'theme.dart';

class LaunchContinuityTimeline extends StatelessWidget {
  const LaunchContinuityTimeline({
    required this.language,
    this.compact = false,
    this.showTitle = true,
    super.key,
  });

  final MysticLanguage language;
  final bool compact;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final steps = <_ContinuityStep>[
      _ContinuityStep(
        icon: Icons.auto_awesome_rounded,
        label: _copy(
          language,
          en: 'NOW',
          es: 'AHORA',
          fr: 'MAINTENANT',
          pt: 'AGORA',
          tr: 'ŞİMDİ',
        ),
        body: _copy(
          language,
          en: 'Reveal a focused reading and choose one small action worth testing.',
          es: 'Revela una lectura concreta y elige una pequeña acción que valga la pena probar.',
          fr: 'Révélez un tirage ciblé et choisissez une petite action à tester.',
          pt: 'Revele uma leitura focada e escolha uma pequena ação que valha testar.',
          tr: 'Odaklı bir okuma aç ve gerçekten denemeye değer tek bir küçük eylem seç.',
        ),
      ),
      _ContinuityStep(
        icon: Icons.compare_arrows_rounded,
        label: _copy(
          language,
          en: 'TOMORROW',
          es: 'MAÑANA',
          fr: 'DEMAIN',
          pt: 'AMANHÃ',
          tr: 'YARIN',
        ),
        body: _copy(
          language,
          en: 'Mystic Mirror asks what actually happened — never whether tarot “won.”',
          es: 'Mystic Mirror pregunta qué ocurrió de verdad, nunca si el tarot “ganó”.',
          fr: 'Mystic Mirror demande ce qui s’est vraiment passé, jamais si le tarot a « gagné ».',
          pt: 'O Mystic Mirror pergunta o que realmente aconteceu — nunca se o tarô “venceu”.',
          tr: 'Mystic Mirror tarotun “tutup tutmadığını” değil, gerçekte ne olduğunu sorar.',
        ),
      ),
      _ContinuityStep(
        icon: Icons.insights_rounded,
        label: _copy(
          language,
          en: 'WITH EVIDENCE',
          es: 'CON EVIDENCIA',
          fr: 'AVEC DES INDICES',
          pt: 'COM EVIDÊNCIAS',
          tr: 'KANIT BİRİKTİKÇE',
        ),
        body: _copy(
          language,
          en: 'Repeated check-ins expose the cards, emotions, and choices that keep returning.',
          es: 'Las revisiones repetidas revelan las cartas, emociones y decisiones que siguen volviendo.',
          fr: 'Les bilans répétés révèlent les cartes, émotions et choix qui reviennent.',
          pt: 'Check-ins repetidos revelam as cartas, emoções e escolhas que continuam voltando.',
          tr: 'Tekrarlanan kontroller geri dönen kartları, duyguları ve seçimleri görünür kılar.',
        ),
      ),
    ];

    return Semantics(
      container: true,
      label: _copy(
        language,
        en: 'Read today. Check reality tomorrow. Build private evidence over time.',
        es: 'Lee hoy. Comprueba la realidad mañana. Construye evidencia privada con el tiempo.',
        fr: 'Lisez aujourd’hui. Vérifiez la réalité demain. Construisez des indices privés dans le temps.',
        pt: 'Leia hoje. Confira a realidade amanhã. Construa evidências privadas ao longo do tempo.',
        tr: 'Bugün oku. Yarın gerçeği kontrol et. Zamanla özel kanıtını oluştur.',
      ),
      child: Container(
        key: const ValueKey('launch-continuity-timeline'),
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B1E49), Color(0xFF171223), Color(0xFF0F0D18)],
          ),
          borderRadius: BorderRadius.circular(compact ? 19 : 24),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .28)),
          boxShadow: [
            BoxShadow(
              color: MysticColors.violet.withValues(alpha: .15),
              blurRadius: compact ? 20 : 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimelineHeader(language: language),
            SizedBox(height: compact ? 10 : 12),
            Text(
              _signature(language),
              style: TextStyle(
                color: MysticColors.mist,
                fontSize: compact ? 16 : 19,
                height: 1.12,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (showTitle) ...[
              const SizedBox(height: 5),
              Text(
                _copy(
                  language,
                  en: 'A READING SHOULD LEAVE EVIDENCE, NOT JUST A FEELING.',
                  es: 'UNA LECTURA DEBE DEJAR EVIDENCIA, NO SOLO UNA SENSACIÓN.',
                  fr: 'UN TIRAGE DOIT LAISSER DES INDICES, PAS SEULEMENT UNE IMPRESSION.',
                  pt: 'UMA LEITURA DEVE DEIXAR EVIDÊNCIAS, NÃO SÓ UMA SENSAÇÃO.',
                  tr: 'BİR OKUMA SADECE HİS DEĞİL, KANIT BIRAKMALI.',
                ),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.lavender,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .72,
                ),
              ),
            ],
            SizedBox(height: compact ? 13 : 16),
            for (var index = 0; index < steps.length; index++) ...[
              _TimelineStepRow(
                step: steps[index],
                compact: compact,
                index: index + 1,
              ),
              if (index != steps.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: compact ? 14 : 16),
                  child: Container(
                    width: 1,
                    height: compact ? 9 : 12,
                    color: MysticColors.gold.withValues(alpha: .22),
                  ),
                ),
            ],
            SizedBox(height: compact ? 12 : 14),
            _RealityGuardrail(language: language, compact: compact),
          ],
        ),
      ),
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _copy(
              language,
              en: 'THE MYSTIC LOOP',
              es: 'EL CICLO MYSTIC',
              fr: 'LA BOUCLE MYSTIC',
              pt: 'O CICLO MYSTIC',
              tr: 'MYSTIC DÖNGÜSÜ',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Arial',
              color: MysticColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.25,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: MysticColors.lavender.withValues(alpha: .17),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: MysticColors.lavender,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                _copy(
                  language,
                  en: 'PRIVATE',
                  es: 'PRIVADO',
                  fr: 'PRIVÉ',
                  pt: 'PRIVADO',
                  tr: 'ÖZEL',
                ),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.lavender,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RealityGuardrail extends StatelessWidget {
  const _RealityGuardrail({required this.language, required this.compact});

  final MysticLanguage language;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: MysticColors.gold.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: MysticColors.gold,
            size: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _copy(
                language,
                en: 'No prediction score. No forced “accuracy.” Just your private pattern history.',
                es: 'Sin puntuación de predicción ni “precisión” forzada. Solo tu historial privado de patrones.',
                fr: 'Aucun score de prédiction ni « précision » forcée. Seulement votre historique privé de tendances.',
                pt: 'Sem pontuação de previsão ou “precisão” forçada. Só seu histórico privado de padrões.',
                tr: 'Kehanet puanı yok, zorlama “doğruluk” yok. Yalnızca sana ait özel örüntü geçmişi.',
              ),
              style: TextStyle(
                fontFamily: 'Arial',
                color: MysticColors.mist,
                fontSize: compact ? 9.5 : 10.5,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrivateByDesignCard extends StatelessWidget {
  const PrivateByDesignCard({
    required this.language,
    this.compact = false,
    super.key,
  });

  final MysticLanguage language;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: _copy(
        language,
        en: 'Private by design',
        es: 'Privado por diseño',
        fr: 'Privé dès la conception',
        pt: 'Privado desde a concepção',
        tr: 'Tasarımı gereği özel',
      ),
      child: Container(
        key: const ValueKey('private-by-design-card'),
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D1830), Color(0xFF11101A)],
          ),
          borderRadius: BorderRadius.circular(compact ? 16 : 20),
          border: Border.all(
            color: MysticColors.lavender.withValues(alpha: .18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: compact ? 35 : 42,
              height: compact ? 35 : 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MysticColors.gold.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.shield_outlined,
                size: compact ? 18 : 21,
                color: MysticColors.gold,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _copy(
                      language,
                      en: 'Private by design',
                      es: 'Privado por diseño',
                      fr: 'Privé dès la conception',
                      pt: 'Privado desde a concepção',
                      tr: 'Tasarımı gereği özel',
                    ),
                    style: TextStyle(
                      color: MysticColors.goldSoft,
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _copy(
                      language,
                      en: 'No account or cloud journal. Your reading history stays on this device, with optional PIN and biometrics. Native ads respect available advertising privacy choices; the public web edition stays ad-free.',
                      es: 'Sin cuenta ni diario en la nube. Tu historial permanece en este dispositivo, con PIN y biometría opcionales. Los anuncios nativos respetan las opciones de privacidad publicitaria disponibles; la web pública sigue sin anuncios.',
                      fr: 'Aucun compte ni journal cloud. Votre historique reste sur cet appareil, avec code PIN et biométrie en option. Les publicités natives respectent les choix de confidentialité disponibles ; la version web publique reste sans publicité.',
                      pt: 'Sem conta ou diário na nuvem. Seu histórico fica neste dispositivo, com PIN e biometria opcionais. Os anúncios nativos seguem as opções de privacidade disponíveis; a versão web pública continua sem anúncios.',
                      tr: 'Hesap veya bulut günlüğü yok. Okuma geçmişin bu cihazda kalır; istersen PIN ve biyometriyle korursun. Native reklamlar mevcut reklam gizlilik tercihlerine uyar; herkese açık web sürümü reklamsızdır.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MysticColors.mist,
                      fontSize: compact ? 10 : 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinuityStep {
  const _ContinuityStep({
    required this.icon,
    required this.label,
    required this.body,
  });

  final IconData icon;
  final String label;
  final String body;
}

class _TimelineStepRow extends StatelessWidget {
  const _TimelineStepRow({
    required this.step,
    required this.compact,
    required this.index,
  });

  final _ContinuityStep step;
  final bool compact;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: compact ? 29 : 33,
          height: compact ? 29 : 33,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MysticColors.gold.withValues(alpha: .095),
            shape: BoxShape.circle,
            border: Border.all(color: MysticColors.gold.withValues(alpha: .28)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                step.icon,
                color: MysticColors.gold,
                size: compact ? 15 : 17,
              ),
              Positioned(
                right: 1,
                bottom: 0,
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: MysticColors.lavender,
                    fontSize: 6.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: MysticColors.gold,
                    fontSize: compact ? 8 : 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .82,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MysticColors.mist,
                    fontSize: compact ? 10 : 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _signature(MysticLanguage language) {
  return _copy(
    language,
    en: 'Read today. Check reality tomorrow.',
    es: 'Lee hoy. Comprueba la realidad mañana.',
    fr: 'Lisez aujourd’hui. Vérifiez la réalité demain.',
    pt: 'Leia hoje. Confira a realidade amanhã.',
    tr: 'Bugün oku. Yarın gerçeği kontrol et.',
  );
}

String _copy(
  MysticLanguage language, {
  required String en,
  required String es,
  required String fr,
  required String pt,
  required String tr,
}) {
  switch (language) {
    case MysticLanguage.turkish:
      return tr;
    case MysticLanguage.spanish:
      return es;
    case MysticLanguage.french:
      return fr;
    case MysticLanguage.portugueseBrazil:
      return pt;
    default:
      return en;
  }
}
