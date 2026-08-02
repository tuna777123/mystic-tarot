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
  final bool isPlus;
  final VoidCallback onOpen;
  final DateTime? now;

  String t({
    required String en,
    required String es,
    required String fr,
    required String pt,
    required String tr,
  }) =>
      localized(
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
  Widget build(BuildContext context) {
    final generatedAt = now ?? DateTime.now();
    final periodStart = generatedAt.subtract(const Duration(days: 7));
    final recent = records
        .where(
          (record) =>
              !record.createdAt.isBefore(periodStart) &&
              !record.createdAt.isAfter(generatedAt),
        )
        .toList(growable: false);
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
    final repeated = cardCounts.entries
        .where((entry) => entry.value > 1)
        .toList(growable: false)
      ..sort((first, second) {
        final byCount = second.value.compareTo(first.value);
        return byCount != 0 ? byCount : first.key.compareTo(second.key);
      });
    final topCard = repeated.isEmpty ? null : repeated.first;
    final ready = recent.length >= 3;
    final remaining = ready ? 0 : 3 - recent.length;
    final topCardName = topCard == null
        ? null
        : localizedTarotCardName(
            topCard.key,
            languageCode: language.code,
          );

    return Semantics(
      button: true,
      label: ready
          ? t(
              en: 'Open your seven-day Mystic Intelligence report',
              es: 'Abrir tu informe Mystic Intelligence de siete días',
              fr: 'Ouvrir votre rapport Mystic Intelligence sur sept jours',
              pt: 'Abrir seu relatório Mystic Intelligence de sete dias',
              tr: 'Yedi günlük Mystic Intelligence raporunu aç',
            )
          : t(
              en: '$remaining more saved readings until your first Mystic Intelligence report',
              es: 'Faltan $remaining lecturas guardadas para tu primer informe Mystic Intelligence',
              fr: 'Encore $remaining tirages enregistrés avant votre premier rapport Mystic Intelligence',
              pt: 'Faltam $remaining leituras salvas para seu primeiro relatório Mystic Intelligence',
              tr: 'İlk Mystic Intelligence raporuna $remaining kayıtlı okuma kaldı',
            ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF49316E), Color(0xFF21152F)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: MysticColors.gold.withValues(alpha: ready ? .5 : .28),
            ),
            boxShadow: ready
                ? [
                    BoxShadow(
                      color: MysticColors.violet.withValues(alpha: .18),
                      blurRadius: 26,
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
                  shape: BoxShape.circle,
                  color: MysticColors.gold.withValues(alpha: .11),
                  border: Border.all(
                    color: MysticColors.gold.withValues(alpha: .5),
                  ),
                ),
                child: const Text(
                  '◉',
                  style: TextStyle(fontSize: 25, color: MysticColors.gold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'MYSTIC INTELLIGENCE',
                            style: const TextStyle(
                              color: MysticColors.gold,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ready
                                ? MysticColors.gold
                                : Colors.white.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            ready
                                ? t(
                                    en: 'READY',
                                    es: 'LISTO',
                                    fr: 'PRÊT',
                                    pt: 'PRONTO',
                                    tr: 'HAZIR',
                                  )
                                : '${recent.length}/3',
                            style: TextStyle(
                              color: ready
                                  ? MysticColors.ink
                                  : MysticColors.lavender,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      ready
                          ? topCardName == null
                              ? t(
                                  en: 'Your seven-day pattern report is ready',
                                  es: 'Tu informe de patrones de siete días está listo',
                                  fr: 'Votre rapport de schémas sur sept jours est prêt',
                                  pt: 'Seu relatório de padrões de sete dias está pronto',
                                  tr: 'Yedi günlük örüntü raporun hazır',
                                )
                              : t(
                                  en: '$topCardName has started repeating',
                                  es: '$topCardName ha empezado a repetirse',
                                  fr: '$topCardName commence à revenir',
                                  pt: '$topCardName começou a se repetir',
                                  tr: '$topCardName tekrar etmeye başladı',
                                )
                          : t(
                              en: 'Your private report is learning your pattern',
                              es: 'Tu informe privado está aprendiendo tu patrón',
                              fr: 'Votre rapport privé apprend votre schéma',
                              pt: 'Seu relatório privado está aprendendo seu padrão',
                              tr: 'Özel raporun örüntünü öğreniyor',
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ready
                          ? isPlus
                              ? t(
                                  en: 'Open recurring symbols, reality-loop evidence, and emotional direction.',
                                  es: 'Abre símbolos recurrentes, evidencia de realidad y dirección emocional.',
                                  fr: 'Ouvrez les symboles récurrents, les preuves de réalité et la direction émotionnelle.',
                                  pt: 'Abra símbolos recorrentes, evidências da realidade e direção emocional.',
                                  tr: 'Tekrar eden sembolleri, gerçeklik kanıtını ve duygusal yönü aç.',
                                )
                              : t(
                                  en: 'Preview the real signal your saved readings have already created.',
                                  es: 'Previsualiza la señal real que tus lecturas ya han creado.',
                                  fr: 'Découvrez le signal réel déjà créé par vos tirages.',
                                  pt: 'Veja o sinal real que suas leituras já criaram.',
                                  tr: 'Kayıtlı okumalarının oluşturduğu gerçek sinyali önizle.',
                                )
                          : t(
                              en: '$remaining more saved reading${remaining == 1 ? '' : 's'} will unlock your first preview.',
                              es: '$remaining lectura(s) guardada(s) más desbloquearán tu primera vista previa.',
                              fr: '$remaining tirage(s) enregistré(s) de plus débloqueront votre premier aperçu.',
                              pt: 'Mais $remaining leitura(s) salva(s) liberarão sua primeira prévia.',
                              tr: '$remaining kayıtlı okuma daha ilk önizlemeni açacak.',
                            ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: MysticColors.mist,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Text(
                          ready
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
                                ),
                          style: const TextStyle(
                            color: MysticColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
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
}
