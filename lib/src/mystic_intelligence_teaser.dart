import 'package:flutter/material.dart';

import 'app_language.dart';
import 'flagship.dart';
import 'language_bridge.dart';
import 'models.dart';
import 'tarot_localization.dart';
import 'theme.dart';

class MysticIntelligenceTeaser extends StatelessWidget {
  const MysticIntelligenceTeaser({
    required this.records,
    required this.language,
    required this.isPlus,
    required this.onOpen,
    this.now,
    super.key,
  });

  final List<ReadingRecord> records;
  final MysticLanguage language;

  /// Compatibility parameter retained from the former paid-tier UI. Pattern
  /// Lab is part of the current ad-supported experience for everyone.
  final bool isPlus;
  final VoidCallback onOpen;
  final DateTime? now;

  String t({
    required String en,
    required String es,
    required String fr,
    required String pt,
    required String tr,
  }) {
    return localized(
      language.appLanguage,
      english: en,
      spanish: es,
      french: fr,
      portugueseBrazil: pt,
      turkish: tr,
      italian: en,
      german: en,
    );
  }

  @override
  Widget build(BuildContext context) {
    final generatedAt = now ?? DateTime.now();
    final periodStart = generatedAt.subtract(const Duration(days: 7));
    final recent = <ReadingRecord>[];
    for (final record in records) {
      final isBeforeWindow = record.createdAt.isBefore(periodStart);
      final isAfterWindow = record.createdAt.isAfter(generatedAt);
      if (!isBeforeWindow && !isAfterWindow) recent.add(record);
    }

    final cardCounts = <String, int>{};
    for (final record in recent) {
      for (final drawn in record.cards) {
        cardCounts.update(
          drawn.card.name,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    MapEntry<String, int>? topCard;
    for (final entry in cardCounts.entries) {
      if (entry.value <= 1) continue;
      final current = topCard;
      if (current == null ||
          entry.value > current.value ||
          (entry.value == current.value &&
              entry.key.compareTo(current.key) < 0)) {
        topCard = entry;
      }
    }

    final ready = recent.length >= 3;
    final remaining = ready ? 0 : 3 - recent.length;
    String? topCardName;
    if (topCard != null) {
      topCardName = localizedTarotCardName(
        topCard.key,
        languageCode: language.code,
      );
    }
    final title = _title(
      ready: ready,
      topCardName: topCardName,
      remaining: remaining,
    );
    final body = _body(ready: ready, remaining: remaining);
    final actionLabel = ready
        ? t(
            en: 'Open report',
            es: 'Abrir informe',
            fr: 'Ouvrir le rapport',
            pt: 'Abrir relatório',
            tr: 'Raporu aç',
          )
        : t(
            en: 'See progress',
            es: 'Ver progreso',
            fr: 'Voir la progression',
            pt: 'Ver progresso',
            tr: 'İlerlemeyi gör',
          );

    return Semantics(
      button: true,
      label: ready
          ? t(
              en: 'Open your seven-day Pattern Lab evidence',
              es: 'Abrir la evidencia de siete días de Pattern Lab',
              fr: 'Ouvrir vos indices Pattern Lab sur sept jours',
              pt: 'Abrir suas evidências de sete dias no Pattern Lab',
              tr: 'Yedi günlük Pattern Lab kanıtını aç',
            )
          : t(
              en:
                  '$remaining more saved readings until Pattern Lab has enough evidence to compare',
              es:
                  'Faltan $remaining lecturas guardadas para que Pattern Lab tenga evidencia suficiente',
              fr:
                  'Encore $remaining tirages enregistrés avant que Pattern Lab ait assez d’indices',
              pt:
                  'Faltam $remaining leituras salvas para o Pattern Lab ter evidências suficientes',
              tr:
                  'Pattern Lab karşılaştırması için $remaining kayıtlı okuma daha gerekiyor',
            ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          key: const ValueKey('pattern-lab-teaser'),
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3F2D5F), Color(0xFF21172F), Color(0xFF12101A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ready
                  ? MysticColors.gold.withValues(alpha: .42)
                  : MysticColors.lavender.withValues(alpha: .2),
            ),
            boxShadow: ready
                ? [
                    BoxShadow(
                      color: MysticColors.violet.withValues(alpha: .14),
                      blurRadius: 26,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  color: MysticColors.gold.withValues(alpha: .09),
                  border: Border.all(
                    color: MysticColors.gold.withValues(alpha: .3),
                  ),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 24,
                  color: MysticColors.gold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(ready, recent.length),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MysticColors.mist,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MysticColors.mist,
                        height: 1.34,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: MysticColors.muted,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            t(
                              en: 'Calculated privately on this device',
                              es: 'Calculado en privado en este dispositivo',
                              fr: 'Calculé en privé sur cet appareil',
                              pt: 'Calculado em privado neste dispositivo',
                              tr: 'Bu cihazda özel olarak hesaplanır',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              color: MysticColors.muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          actionLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            color: MysticColors.gold,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: MysticColors.gold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(bool ready, int recentCount) {
    final badge = ready
        ? t(
            en: 'READY',
            es: 'LISTO',
            fr: 'PRÊT',
            pt: 'PRONTO',
            tr: 'HAZIR',
          )
        : '$recentCount/3';
    return Row(
      children: [
        const Expanded(
          child: Text(
            'PATTERN LAB',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Arial',
              color: MysticColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.35,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ready
                ? MysticColors.gold
                : Colors.white.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            badge,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Arial',
              color: ready ? MysticColors.ink : MysticColors.lavender,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  String _title({
    required bool ready,
    required String? topCardName,
    required int remaining,
  }) {
    if (!ready) {
      return t(
        en: 'Evidence first. Patterns second.',
        es: 'Primero evidencia. Después patrones.',
        fr: 'D’abord les indices. Ensuite les tendances.',
        pt: 'Primeiro evidências. Depois padrões.',
        tr: 'Önce kanıt. Sonra örüntü.',
      );
    }
    if (topCardName != null) {
      return t(
        en: '$topCardName has started repeating',
        es: '$topCardName ha empezado a repetirse',
        fr: '$topCardName commence à revenir',
        pt: '$topCardName começou a se repetir',
        tr: '$topCardName tekrar etmeye başladı',
      );
    }
    return t(
      en: 'Your seven-day pattern comparison is ready',
      es: 'Tu comparación de patrones de siete días está lista',
      fr: 'Votre comparaison sur sept jours est prête',
      pt: 'Sua comparação de padrões de sete dias está pronta',
      tr: 'Yedi günlük örüntü karşılaştırman hazır',
    );
  }

  String _body({required bool ready, required int remaining}) {
    if (ready) {
      return t(
        en:
            'Compare recurring symbols and emotional direction from your own saved history — never a prediction score.',
        es:
            'Compara símbolos recurrentes y dirección emocional de tu propio historial, nunca una puntuación de predicción.',
        fr:
            'Comparez les symboles récurrents et la direction émotionnelle de votre historique, jamais un score de prédiction.',
        pt:
            'Compare símbolos recorrentes e direção emocional do seu próprio histórico, nunca uma pontuação de previsão.',
        tr:
            'Kendi kayıtlı geçmişindeki tekrar eden sembolleri ve duygusal yönü karşılaştır; kehanet puanı üretmez.',
      );
    }
    return t(
      en:
          '$remaining more saved reading${remaining == 1 ? '' : 's'} will give Pattern Lab enough evidence for its first comparison.',
      es:
          '$remaining lectura(s) guardada(s) más darán a Pattern Lab evidencia suficiente para su primera comparación.',
      fr:
          '$remaining tirage(s) enregistré(s) de plus donneront à Pattern Lab assez d’indices pour une première comparaison.',
      pt:
          'Mais $remaining leitura(s) salva(s) darão ao Pattern Lab evidências suficientes para a primeira comparação.',
      tr:
          '$remaining kayıtlı okuma daha Pattern Lab’in ilk karşılaştırması için yeterli kanıtı oluşturacak.',
    );
  }
}
