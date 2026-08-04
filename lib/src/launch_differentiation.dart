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
        icon: Icons.bookmark_added_outlined,
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
          en: 'Your reading is saved privately on this device.',
          es: 'Tu lectura se guarda de forma privada en este dispositivo.',
          fr: 'Votre tirage est enregistré en privé sur cet appareil.',
          pt: 'Sua leitura é salva de forma privada neste dispositivo.',
          tr: 'Okuman bu cihazda özel olarak kaydedilir.',
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
          en: 'Mystic Mirror asks what actually changed after 24 hours.',
          es: 'Mystic Mirror pregunta qué cambió realmente después de 24 horas.',
          fr: 'Mystic Mirror demande ce qui a réellement changé après 24 heures.',
          pt: 'O Mystic Mirror pergunta o que realmente mudou após 24 horas.',
          tr: 'Mystic Mirror 24 saat sonra gerçekte neyin değiştiğini sorar.',
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
          en: 'Mystic Intelligence reveals recurring cards, emotions, and choices.',
          es: 'Mystic Intelligence revela cartas, emociones y decisiones recurrentes.',
          fr: 'Mystic Intelligence révèle les cartes, émotions et choix récurrents.',
          pt: 'O Mystic Intelligence revela cartas, emoções e escolhas recorrentes.',
          tr: 'Mystic Intelligence tekrar eden kartları, duyguları ve seçimleri gösterir.',
        ),
      ),
    ];

    return Semantics(
      container: true,
      label: _copy(
        language,
        en: 'How Mystic becomes more useful over time',
        es: 'Cómo Mystic se vuelve más útil con el tiempo',
        fr: 'Comment Mystic devient plus utile avec le temps',
        pt: 'Como o Mystic se torna mais útil com o tempo',
        tr: 'Mystic zamanla nasıl daha faydalı hale gelir',
      ),
      child: Container(
        key: const ValueKey('launch-continuity-timeline'),
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 13 : 17),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .035),
          borderRadius: BorderRadius.circular(compact ? 16 : 20),
          border: Border.all(
            color: MysticColors.lavender.withValues(alpha: .18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              Text(
                _copy(
                  language,
                  en: 'ONE READING. A CONTINUING STORY.',
                  es: 'UNA LECTURA. UNA HISTORIA QUE CONTINÚA.',
                  fr: 'UN TIRAGE. UNE HISTOIRE QUI CONTINUE.',
                  pt: 'UMA LEITURA. UMA HISTÓRIA QUE CONTINUA.',
                  tr: 'TEK OKUMA. DEVAM EDEN BİR HİKÂYE.',
                ),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.05,
                ),
              ),
              const SizedBox(height: 11),
            ],
            for (var index = 0; index < steps.length; index++) ...[
              _TimelineStepRow(step: steps[index], compact: compact),
              if (index != steps.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: compact ? 13 : 15),
                  child: Container(
                    width: 1,
                    height: compact ? 8 : 11,
                    color: MysticColors.lavender.withValues(alpha: .24),
                  ),
                ),
            ],
          ],
        ),
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
  Widget build(BuildContext context) => Semantics(
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
          colors: [Color(0xFF1E1830), Color(0xFF12101B)],
        ),
        borderRadius: BorderRadius.circular(compact ? 15 : 19),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 34 : 40,
            height: compact ? 34 : 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MysticColors.gold.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(12),
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
                    color: MysticColors.gold,
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _copy(
                    language,
                    en: 'No account, ads, cross-app tracking, or cloud journal. Your private history stays on this device, with an optional six-digit PIN and biometrics on supported devices for the whole app.',
                    es: 'Sin cuenta, anuncios, rastreo entre apps ni diario en la nube. Tu historial privado permanece en este dispositivo, con PIN opcional de seis dígitos y biometría en dispositivos compatibles para toda la app.',
                    fr: 'Aucun compte, aucune publicité, aucun suivi inter-apps ni journal cloud. Votre historique privé reste sur cet appareil, avec un code PIN facultatif à six chiffres et la biométrie sur les appareils compatibles pour toute l’app.',
                    pt: 'Sem conta, anúncios, rastreamento entre apps ou diário na nuvem. Seu histórico privado fica neste dispositivo, com PIN opcional de seis dígitos e biometria em dispositivos compatíveis para todo o app.',
                    tr: 'Hesap, reklam, uygulamalar arası takip veya bulut günlüğü yok. Özel geçmişin bu cihazda kalır; istersen tüm uygulamayı altı haneli PIN ve desteklenen cihazlarda biyometriyle koruyabilirsin.',
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
  const _TimelineStepRow({required this.step, required this.compact});

  final _ContinuityStep step;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: compact ? 27 : 31,
        height: compact ? 27 : 31,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MysticColors.violet.withValues(alpha: .22),
          shape: BoxShape.circle,
        ),
        child: Icon(
          step.icon,
          color: MysticColors.lavender,
          size: compact ? 15 : 17,
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
                  letterSpacing: .8,
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

String _copy(
  MysticLanguage language, {
  required String en,
  required String es,
  required String fr,
  required String pt,
  required String tr,
}) => switch (language) {
  MysticLanguage.turkish => tr,
  MysticLanguage.spanish => es,
  MysticLanguage.french => fr,
  MysticLanguage.portugueseBrazil => pt,
  _ => en,
};
