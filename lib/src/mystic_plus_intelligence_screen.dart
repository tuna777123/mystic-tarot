import 'package:flutter/material.dart';

import 'app_language.dart';
import 'flagship.dart';
import 'language_bridge.dart';
import 'models.dart';
import 'mystic_mirror.dart';
import 'mystic_plus_intelligence.dart';
import 'reading_journal_store.dart';
import 'tarot_localization.dart';
import 'theme.dart';
import 'widgets.dart';

class MysticPlusIntelligenceScreen extends StatefulWidget {
  const MysticPlusIntelligenceScreen({
    required this.source,
    required this.language,
    required this.isPlus,
    required this.onContinue,
    this.initialRecords,
    this.initialReflections,
    this.generatedAt,
    super.key,
  });

  final String source;
  final MysticLanguage language;
  final bool isPlus;
  final VoidCallback onContinue;
  final List<ReadingRecord>? initialRecords;
  final Map<String, MysticMirrorReflection>? initialReflections;
  final DateTime? generatedAt;

  @override
  State<MysticPlusIntelligenceScreen> createState() =>
      _MysticPlusIntelligenceScreenState();
}

class _MysticPlusIntelligenceScreenState
    extends State<MysticPlusIntelligenceScreen> {
  MysticPlusIntelligenceSnapshot? snapshot;
  bool loading = true;
  bool loadFailed = false;

  AppLanguage get _language => widget.language.appLanguage;

  String t({
    required String en,
    required String es,
    required String fr,
    required String pt,
    required String tr,
  }) => localized(
    _language,
    english: en,
    spanish: es,
    french: fr,
    portugueseBrazil: pt,
    turkish: tr,
    italian: en,
    german: en,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final records =
          widget.initialRecords ?? (await ReadingJournalStore().load()).records;
      final mirrors =
          widget.initialReflections ?? await MysticMirrorStore().load();
      final report = MysticPlusIntelligence.analyze(
        records: records,
        reflections: mirrors,
        generatedAt: widget.generatedAt ?? DateTime.now(),
      );
      if (!mounted) return;
      setState(() {
        snapshot = report;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: MysticBackground(
      child: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: MysticColors.gold,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                      children: [
                        _hero(context),
                        const SizedBox(height: 14),
                        if (loadFailed)
                          _loadFailure(context)
                        else if (snapshot != null)
                          ..._report(context, snapshot!),
                        const SizedBox(height: 14),
                        _plusValue(context),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Column(
                children: [
                  GoldButton(
                    label: widget.isPlus
                        ? t(
                            en: 'Continue to my report',
                            es: 'Continuar a mi informe',
                            fr: 'Continuer vers mon rapport',
                            pt: 'Continuar para meu relatório',
                            tr: 'Raporuma devam et',
                          )
                        : t(
                            en: 'Open the full report',
                            es: 'Abrir el informe completo',
                            fr: 'Ouvrir le rapport complet',
                            pt: 'Abrir o relatório completo',
                            tr: 'Tam raporu aç',
                          ),
                    icon: widget.isPlus
                        ? Icons.arrow_forward_rounded
                        : Icons.lock_open_rounded,
                    onPressed: widget.onContinue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t(
                      en: 'Calculated privately on this device. No journal text is uploaded to create this report.',
                      es: 'Calculado de forma privada en este dispositivo. El texto del diario no se sube.',
                      fr: 'Calculé en privé sur cet appareil. Aucun texte du journal n’est envoyé.',
                      pt: 'Calculado de forma privada neste dispositivo. Nenhum texto do diário é enviado.',
                      tr: 'Bu cihazda özel olarak hesaplanır. Rapor için günlük metinlerin yüklenmez.',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: MysticColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(10, 6, 14, 4),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        const Spacer(),
        const Text(
          'MYSTIC INTELLIGENCE',
          style: TextStyle(
            color: MysticColors.gold,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: widget.isPlus
                ? MysticColors.gold
                : MysticColors.gold.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: MysticColors.gold),
          ),
          child: Text(
            widget.isPlus
                ? t(
                    en: 'ACTIVE',
                    es: 'ACTIVO',
                    fr: 'ACTIF',
                    pt: 'ATIVO',
                    tr: 'AKTİF',
                  )
                : t(
                    en: 'PREVIEW',
                    es: 'VISTA',
                    fr: 'APERÇU',
                    pt: 'PRÉVIA',
                    tr: 'ÖNİZLEME',
                  ),
            style: TextStyle(
              color: widget.isPlus ? MysticColors.ink : MysticColors.gold,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _hero(BuildContext context) {
    final message = _sourceMessage();
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 22),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -.9),
          radius: 1.4,
          colors: [Color(0xFF7751B6), Color(0xFF2B1A46), Color(0xFF15101F)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .46)),
        boxShadow: [
          BoxShadow(
            color: MysticColors.violet.withValues(alpha: .22),
            blurRadius: 34,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: .18),
              border: Border.all(
                color: MysticColors.gold.withValues(alpha: .65),
              ),
            ),
            child: const Text(
              '◉',
              style: TextStyle(fontSize: 35, color: MysticColors.gold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isPlus
                ? t(
                    en: 'Your 7-day Mystic Intelligence',
                    es: 'Tu Inteligencia Mystic de 7 días',
                    fr: 'Votre Intelligence Mystic sur 7 jours',
                    pt: 'Sua Inteligência Mystic de 7 dias',
                    tr: '7 Günlük Mystic Intelligence Raporun',
                  )
                : message.$1,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 9),
          Text(
            widget.isPlus
                ? t(
                    en: 'A transparent report built from the readings and reality check-ins you chose to save.',
                    es: 'Un informe transparente creado con las lecturas y revisiones que decidiste guardar.',
                    fr: 'Un rapport transparent construit à partir des tirages et bilans que vous avez enregistrés.',
                    pt: 'Um relatório transparente criado com as leituras e check-ins que você decidiu salvar.',
                    tr: 'Kaydetmeyi seçtiğin okumalar ve gerçeklik kontrollerinden oluşan şeffaf rapor.',
                  )
                : message.$2,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  List<Widget> _report(
    BuildContext context,
    MysticPlusIntelligenceSnapshot report,
  ) {
    if (!report.hasEnoughHistory) {
      return [
        _readinessCard(context, report),
        const SizedBox(height: 12),
        _lockedInsight(
          context,
          icon: Icons.repeat_rounded,
          title: t(
            en: 'Recurring symbols',
            es: 'Símbolos recurrentes',
            fr: 'Symboles récurrents',
            pt: 'Símbolos recorrentes',
            tr: 'Tekrar eden semboller',
          ),
        ),
        const SizedBox(height: 10),
        _lockedInsight(
          context,
          icon: Icons.compare_arrows_rounded,
          title: t(
            en: 'Reality and emotion shifts',
            es: 'Cambios en realidad y emoción',
            fr: 'Évolutions de réalité et d’émotion',
            pt: 'Mudanças na realidade e emoção',
            tr: 'Gerçeklik ve duygu değişimleri',
          ),
        ),
      ];
    }

    final widgets = <Widget>[
      _overview(context, report),
      const SizedBox(height: 12),
      _revealedPattern(context, report),
    ];

    if (widget.isPlus) {
      widgets.addAll([
        const SizedBox(height: 10),
        _mirrorEvidence(context, report),
        const SizedBox(height: 10),
        _emotionalDirection(context, report),
        const SizedBox(height: 10),
        _nextPractice(context, report),
      ]);
    } else {
      widgets.addAll([
        const SizedBox(height: 10),
        _lockedInsight(
          context,
          icon: Icons.fact_check_outlined,
          title: t(
            en: 'Reality-loop evidence',
            es: 'Evidencia del ciclo de realidad',
            fr: 'Preuves de la boucle de réalité',
            pt: 'Evidências do ciclo de realidade',
            tr: 'Gerçeklik döngüsü kanıtı',
          ),
        ),
        const SizedBox(height: 10),
        _lockedInsight(
          context,
          icon: Icons.trending_up_rounded,
          title: t(
            en: 'Emotional direction',
            es: 'Dirección emocional',
            fr: 'Direction émotionnelle',
            pt: 'Direção emocional',
            tr: 'Duygusal yön',
          ),
        ),
        const SizedBox(height: 10),
        _lockedInsight(
          context,
          icon: Icons.explore_outlined,
          title: t(
            en: 'Your next grounded practice',
            es: 'Tu próxima práctica concreta',
            fr: 'Votre prochaine pratique concrète',
            pt: 'Sua próxima prática concreta',
            tr: 'Bir sonraki somut pratiğin',
          ),
        ),
      ]);
    }
    return widgets;
  }

  Widget _readinessCard(
    BuildContext context,
    MysticPlusIntelligenceSnapshot report,
  ) {
    final progress = (report.readingCount / 3).clamp(0.0, 1.0);
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(
              en: 'Your report is learning your pattern',
              es: 'Tu informe está aprendiendo tu patrón',
              fr: 'Votre rapport apprend votre schéma',
              pt: 'Seu relatório está aprendendo seu padrão',
              tr: 'Raporun örüntünü öğreniyor',
            ),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 7),
          Text(
            t(
              en: '${report.readingsUntilReady} more saved reading${report.readingsUntilReady == 1 ? '' : 's'} will create the first meaningful seven-day report.',
              es: '${report.readingsUntilReady} lectura(s) guardada(s) más crearán el primer informe significativo.',
              fr: '${report.readingsUntilReady} tirage(s) enregistré(s) de plus créeront le premier rapport significatif.',
              pt: 'Mais ${report.readingsUntilReady} leitura(s) salva(s) criarão o primeiro relatório significativo.',
              tr: '${report.readingsUntilReady} kayıtlı okuma daha ilk anlamlı yedi günlük raporu oluşturacak.',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white10,
              color: MysticColors.gold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${report.readingCount}/3',
            style: const TextStyle(
              color: MysticColors.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overview(
    BuildContext context,
    MysticPlusIntelligenceSnapshot report,
  ) => _panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          t(
            en: 'SEVEN-DAY SIGNAL',
            es: 'SEÑAL DE SIETE DÍAS',
            fr: 'SIGNAL SUR SEPT JOURS',
            pt: 'SINAL DE SETE DIAS',
            tr: 'YEDİ GÜNLÜK SİNYAL',
          ),
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: _metric(
                context,
                '${report.readingCount}',
                t(
                  en: 'readings',
                  es: 'lecturas',
                  fr: 'tirages',
                  pt: 'leituras',
                  tr: 'okuma',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                context,
                '${report.activeDays}',
                t(
                  en: 'active days',
                  es: 'días activos',
                  fr: 'jours actifs',
                  pt: 'dias ativos',
                  tr: 'aktif gün',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                context,
                '${report.uniqueCardCount}',
                t(
                  en: 'unique cards',
                  es: 'cartas únicas',
                  fr: 'cartes uniques',
                  pt: 'cartas únicas',
                  tr: 'benzersiz kart',
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _revealedPattern(
    BuildContext context,
    MysticPlusIntelligenceSnapshot report,
  ) {
    final cardName = report.topCardName == null
        ? t(
            en: 'No recurring card yet',
            es: 'Aún no hay carta recurrente',
            fr: 'Aucune carte récurrente pour le moment',
            pt: 'Ainda não há carta recorrente',
            tr: 'Henüz tekrar eden kart yok',
          )
        : localizedTarotCardName(
            report.topCardName!,
            languageCode: widget.language.code,
          );
    final kind = report.topReadingKind == null
        ? '—'
        : localizedReadingKindTitle(
            report.topReadingKind!,
            languageCode: widget.language.code,
          );
    return _insight(
      context,
      icon: Icons.repeat_rounded,
      eyebrow: t(
        en: 'REVEALED IN PREVIEW',
        es: 'VISIBLE EN LA VISTA PREVIA',
        fr: 'VISIBLE DANS L’APERÇU',
        pt: 'VISÍVEL NA PRÉVIA',
        tr: 'ÖNİZLEMEDE AÇIK',
      ),
      title: cardName,
      body: report.topCardName == null
          ? t(
              en: 'Your saved history is varied. More returns will make recurring symbols visible.',
              es: 'Tu historial es variado. Más regresos harán visibles los símbolos recurrentes.',
              fr: 'Votre historique est varié. D’autres retours feront apparaître les symboles récurrents.',
              pt: 'Seu histórico é variado. Mais retornos tornarão os símbolos recorrentes visíveis.',
              tr: 'Kayıtlı geçmişin çeşitli. Daha fazla dönüş tekrar eden sembolleri görünür kılacak.',
            )
          : t(
              en: 'Appeared ${report.topCardCount} time${report.topCardCount == 1 ? '' : 's'}. Your most common reading focus was $kind (${report.topReadingKindCount}). These are descriptive counts, not a prediction.',
              es: 'Apareció ${report.topCardCount} vez/veces. Tu enfoque de lectura más común fue $kind (${report.topReadingKindCount}). Son recuentos descriptivos, no una predicción.',
              fr: 'Apparue ${report.topCardCount} fois. Votre type de tirage le plus fréquent était $kind (${report.topReadingKindCount}). Ce sont des comptes descriptifs, pas une prédiction.',
              pt: 'Apareceu ${report.topCardCount} vez(es). Seu foco de leitura mais comum foi $kind (${report.topReadingKindCount}). São contagens descritivas, não uma previsão.',
              tr: '${report.topCardCount} kez göründü. En sık okuma odağın $kind (${report.topReadingKindCount}) oldu. Bunlar betimleyici sayımlardır, kehanet değildir.',
            ),
    );
  }

  Widget _mirrorEvidence(
    BuildContext context,
    MysticPlusIntelligenceSnapshot report,
  ) {
    final completion = _percent(report.mirrorCompletionRate);
    final shift = _percent(report.mirrorShiftRate);
    return _insight(
      context,
      icon: Icons.fact_check_outlined,
      eyebrow: t(
        en: 'REALITY LOOP',
        es: 'CICLO DE REALIDAD',
        fr: 'BOUCLE DE RÉALITÉ',
        pt: 'CICLO DE REALIDADE',
        tr: 'GERÇEKLİK DÖNGÜSÜ',
      ),
      title: report.mirrorEligibleCount == 0
          ? t(
              en: 'Your first Mirror evidence is still forming',
              es: 'Tu primera evidencia de Mirror aún se está formando',
              fr: 'Votre première preuve Mirror est encore en formation',
              pt: 'Sua primeira evidência do Mirror ainda está se formando',
              tr: 'İlk Mirror kanıtın henüz oluşuyor',
            )
          : '$completion • $shift',
      body: report.mirrorEligibleCount == 0
          ? t(
              en: 'A saved reading becomes eligible for comparison after twenty-four hours.',
              es: 'Una lectura guardada puede compararse después de veinticuatro horas.',
              fr: 'Un tirage enregistré devient comparable après vingt-quatre heures.',
              pt: 'Uma leitura salva pode ser comparada depois de vinte e quatro horas.',
              tr: 'Kayıtlı bir okuma yirmi dört saat sonra karşılaştırmaya uygun olur.',
            )
          : t(
              en: '$completion of eligible readings received a Mirror check-in. $shift of completed check-ins recorded a full or partial shift.',
              es: '$completion de las lecturas elegibles recibió una revisión. $shift de las revisiones registró un cambio total o parcial.',
              fr: '$completion des tirages éligibles ont reçu un bilan. $shift des bilans terminés ont enregistré une évolution totale ou partielle.',
              pt: '$completion das leituras elegíveis receberam um check-in. $shift dos check-ins concluídos registraram mudança total ou parcial.',
              tr: 'Uygun okumaların $completion kadarı Mirror kontrolü aldı. Tamamlanan kontrollerin $shift kadarında tam veya kısmi değişim kaydedildi.',
            ),
    );
  }

  Widget _emotionalDirection(
    BuildContext context,
    MysticPlusIntelligenceSnapshot report,
  ) {
    final emotion = report.dominantStartingEmotion == null
        ? '—'
        : localizedEmotionLabel(
            report.dominantStartingEmotion!,
            languageCode: widget.language.code,
          );
    final lift = _percent(report.emotionalLiftRate);
    return _insight(
      context,
      icon: Icons.trending_up_rounded,
      eyebrow: t(
        en: 'EMOTIONAL DIRECTION',
        es: 'DIRECCIÓN EMOCIONAL',
        fr: 'DIRECTION ÉMOTIONNELLE',
        pt: 'DIREÇÃO EMOCIONAL',
        tr: 'DUYGUSAL YÖN',
      ),
      title: emotion,
      body: report.emotionalComparisonCount == 0
          ? t(
              en: 'Your most common starting emotion is shown above. Complete Mirror check-ins to compare how feelings changed afterward.',
              es: 'Arriba aparece tu emoción inicial más común. Completa revisiones para comparar cómo cambió después.',
              fr: 'Votre émotion de départ la plus fréquente apparaît ci-dessus. Complétez les bilans pour comparer son évolution.',
              pt: 'Sua emoção inicial mais comum aparece acima. Conclua check-ins para comparar como ela mudou.',
              tr: 'En sık başlangıç duygun yukarıda. Sonrasında nasıl değiştiğini karşılaştırmak için Mirror kontrollerini tamamla.',
            )
          : t(
              en: '$lift of comparable check-ins moved toward a more hopeful or grounded state. This describes your entries; it is not a wellbeing diagnosis.',
              es: '$lift de las revisiones comparables avanzó hacia un estado más esperanzado o estable. Describe tus registros; no es un diagnóstico.',
              fr: '$lift des bilans comparables ont évolué vers un état plus confiant ou ancré. Cela décrit vos entrées, sans diagnostic.',
              pt: '$lift dos check-ins comparáveis avançaram para um estado mais esperançoso ou centrado. Isso descreve seus registros, não é diagnóstico.',
              tr: 'Karşılaştırılabilir kontrollerin $lift kadarı daha umutlu veya dengeli bir duruma ilerledi. Bu yalnızca kayıtlarını betimler; tanı değildir.',
            ),
    );
  }

  Widget _nextPractice(
    BuildContext context,
    MysticPlusIntelligenceSnapshot report,
  ) => _insight(
    context,
    icon: Icons.explore_outlined,
    eyebrow: t(
      en: 'NEXT GROUNDED PRACTICE',
      es: 'PRÓXIMA PRÁCTICA CONCRETA',
      fr: 'PROCHAINE PRATIQUE CONCRÈTE',
      pt: 'PRÓXIMA PRÁTICA CONCRETA',
      tr: 'SONRAKİ SOMUT PRATİK',
    ),
    title: _practiceTitle(report),
    body: _practiceBody(report),
  );

  Widget _lockedInsight(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .035),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(
      children: [
        Container(
          width: 43,
          height: 43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MysticColors.violet.withValues(alpha: .25),
          ),
          child: Icon(icon, color: MysticColors.lavender),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                t(
                  en: 'Personalized insight ready inside Mystic Intelligence',
                  es: 'Información personalizada lista en Mystic Intelligence',
                  fr: 'Analyse personnalisée prête dans Mystic Intelligence',
                  pt: 'Insight personalizado pronto no Mystic Intelligence',
                  tr: 'Kişisel içgörü Mystic Intelligence içinde hazır',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const Icon(Icons.lock_outline, color: MysticColors.gold),
      ],
    ),
  );

  Widget _plusValue(BuildContext context) => _panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          t(
            en: 'MYSTIC INTELLIGENCE VALUE',
            es: 'VALOR DE MYSTIC INTELLIGENCE',
            fr: 'VALEUR DE MYSTIC INTELLIGENCE',
            pt: 'VALOR DO MYSTIC INTELLIGENCE',
            tr: 'MYSTIC INTELLIGENCE DEĞERİ',
          ),
        ),
        const SizedBox(height: 12),
        _benefit(
          Icons.insights_outlined,
          t(
            en: 'A fresh private intelligence report every seven days',
            es: 'Un nuevo informe privado de inteligencia cada siete días',
            fr: 'Un nouveau rapport privé d’intelligence tous les sept jours',
            pt: 'Um novo relatório privado de inteligência a cada sete dias',
            tr: 'Her yedi günde yenilenen özel intelligence raporu',
          ),
        ),
        _benefit(
          Icons.all_inclusive,
          t(
            en: 'Unlimited deep readings',
            es: 'Lecturas profundas ilimitadas',
            fr: 'Tirages approfondis illimités',
            pt: 'Leituras profundas ilimitadas',
            tr: 'Sınırsız derin okuma',
          ),
        ),
        _benefit(
          Icons.hub_outlined,
          t(
            en: 'Compatibility, Timeline, and Celtic Cross spreads',
            es: 'Tiradas de Compatibilidad, Línea temporal y Cruz Celta',
            fr: 'Tirages Compatibilité, Chronologie et Croix Celtique',
            pt: 'Tiragens Compatibilidade, Linha do tempo e Cruz Celta',
            tr: 'Uyum, Zaman Çizgisi ve Kelt Haçı açılımları',
          ),
        ),
        _benefit(
          Icons.forum_outlined,
          t(
            en: 'Unlimited Oracle follow-up questions',
            es: 'Preguntas de seguimiento ilimitadas al Oráculo',
            fr: 'Questions de suivi illimitées avec l’Oracle',
            pt: 'Perguntas de acompanhamento ilimitadas ao Oráculo',
            tr: 'Sınırsız Oracle devam sorusu',
          ),
        ),
      ],
    ),
  );

  Widget _loadFailure(BuildContext context) => _panel(
    child: Column(
      children: [
        const Icon(Icons.refresh_rounded, color: MysticColors.gold),
        const SizedBox(height: 10),
        Text(
          t(
            en: 'The private report could not be calculated right now.',
            es: 'El informe privado no pudo calcularse ahora.',
            fr: 'Le rapport privé n’a pas pu être calculé pour le moment.',
            pt: 'O relatório privado não pôde ser calculado agora.',
            tr: 'Özel rapor şu anda hesaplanamadı.',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {
            setState(() {
              loading = true;
              loadFailed = false;
            });
            _load();
          },
          icon: const Icon(Icons.refresh),
          label: Text(
            t(
              en: 'Try again',
              es: 'Intentar de nuevo',
              fr: 'Réessayer',
              pt: 'Tentar novamente',
              tr: 'Yeniden dene',
            ),
          ),
        ),
      ],
    ),
  );

  Widget _panel({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFF151120),
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: Colors.white.withValues(alpha: .09)),
    ),
    child: child,
  );

  Widget _insight(
    BuildContext context, {
    required IconData icon,
    required String eyebrow,
    required String title,
    required String body,
  }) => _panel(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MysticColors.gold.withValues(alpha: .11),
          ),
          child: Icon(icon, color: MysticColors.gold, size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel(eyebrow),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.42),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _metric(BuildContext context, String value, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
    decoration: BoxDecoration(
      color: MysticColors.violet.withValues(alpha: .17),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: MysticColors.gold,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );

  Widget _benefit(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: MysticColors.gold, size: 21),
        const SizedBox(width: 11),
        Expanded(child: Text(text)),
      ],
    ),
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: MysticColors.gold,
      fontSize: 9,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.15,
    ),
  );

  String _percent(double value) => '${(value * 100).round()}%';

  (String, String) _sourceMessage() => switch (widget.source) {
    'daily_limit' => (
      t(
        en: 'Your free readings ended. Your pattern did not.',
        es: 'Tus lecturas gratuitas terminaron. Tu patrón no.',
        fr: 'Vos tirages gratuits sont terminés. Pas votre schéma.',
        pt: 'Suas leituras gratuitas terminaram. Seu padrão não.',
        tr: 'Ücretsiz okumaların bitti. Örüntün bitmedi.',
      ),
      t(
        en: 'See the private evidence your saved readings are already building, and keep exploring the full report.',
        es: 'Mira la evidencia privada que tus lecturas ya están creando y sigue explorando el informe completo.',
        fr: 'Voyez les preuves privées que vos tirages construisent déjà, et poursuivez le rapport complet.',
        pt: 'Veja as evidências privadas que suas leituras já estão criando e continue explorando o relatório completo.',
        tr: 'Kayıtlı okumalarının oluşturduğu özel kanıtı gör; ve tam raporu keşfetmeye devam et.',
      ),
    ),
    'premium_spread' => (
      t(
        en: 'A wider spread should create a deeper pattern.',
        es: 'Una tirada más amplia debe crear un patrón más profundo.',
        fr: 'Un tirage plus large doit créer un schéma plus profond.',
        pt: 'Uma tiragem mais ampla deve criar um padrão mais profundo.',
        tr: 'Daha geniş bir açılım daha derin bir örüntü oluşturmalı.',
      ),
      t(
        en: 'Preview the intelligence layer that connects premium spreads across time.',
        es: 'Previsualiza la capa de inteligencia que conecta las tiradas premium con el tiempo.',
        fr: 'Découvrez la couche d’intelligence qui relie les tirages premium dans le temps.',
        pt: 'Veja a camada de inteligência que conecta tiragens premium ao longo do tempo.',
        tr: 'Premium açılımları zaman içinde birbirine bağlayan intelligence katmanını önizle.',
      ),
    ),
    'oracle_dialogue' => (
      t(
        en: 'Do not just ask more. Learn what keeps returning.',
        es: 'No solo preguntes más. Aprende qué sigue regresando.',
        fr: 'Ne posez pas seulement plus de questions. Voyez ce qui revient.',
        pt: 'Não apenas pergunte mais. Aprenda o que continua retornando.',
        tr: 'Yalnızca daha fazla sorma. Neyin geri döndüğünü öğren.',
      ),
      t(
        en: 'Mystic Intelligence connects follow-up questions with your seven-day private pattern report.',
        es: 'Mystic Intelligence conecta las preguntas de seguimiento con tu informe privado de siete días.',
        fr: 'Mystic Intelligence relie les questions de suivi à votre rapport privé sur sept jours.',
        pt: 'O Mystic Intelligence conecta perguntas de acompanhamento ao seu relatório privado de sete dias.',
        tr: 'Mystic Intelligence devam sorularını yedi günlük özel örüntü raporunla birleştirir.',
      ),
    ),
    _ => (
      t(
        en: 'See what your saved readings are building.',
        es: 'Mira lo que están construyendo tus lecturas guardadas.',
        fr: 'Découvrez ce que construisent vos tirages enregistrés.',
        pt: 'Veja o que suas leituras salvas estão construindo.',
        tr: 'Kayıtlı okumalarının ne oluşturduğunu gör.',
      ),
      t(
        en: 'Mystic Intelligence is not only more readings. It is a private intelligence layer that becomes more useful as you return.',
        es: 'Mystic Intelligence no es solo más lecturas. Es una capa privada de inteligencia que mejora con cada regreso.',
        fr: 'Mystic Intelligence ne signifie pas seulement plus de tirages. C’est une intelligence privée qui gagne en valeur à chaque retour.',
        pt: 'Mystic Intelligence não é apenas mais leituras. É uma camada privada de inteligência que melhora a cada retorno.',
        tr: 'Mystic Intelligence yalnızca daha fazla okuma değildir. Her dönüşünde değerlenen özel bir intelligence katmanıdır.',
      ),
    ),
  };

  String _practiceTitle(MysticPlusIntelligenceSnapshot report) =>
      switch (report.dominantStartingEmotion) {
        EmotionalState.anxious => t(
          en: 'Reduce the next question to one controllable action',
          es: 'Reduce la próxima pregunta a una acción controlable',
          fr: 'Ramenez la prochaine question à une action contrôlable',
          pt: 'Reduza a próxima pergunta a uma ação controlável',
          tr: 'Sonraki soruyu kontrol edilebilir tek eyleme indir',
        ),
        EmotionalState.uncertain => t(
          en: 'Separate facts, assumptions, and unknowns',
          es: 'Separa hechos, suposiciones y desconocidos',
          fr: 'Séparez les faits, les hypothèses et les inconnues',
          pt: 'Separe fatos, suposições e desconhecidos',
          tr: 'Gerçekleri, varsayımları ve bilinmeyenleri ayır',
        ),
        EmotionalState.curious => t(
          en: 'Follow one repeated symbol into action',
          es: 'Lleva un símbolo repetido a la acción',
          fr: 'Transformez un symbole répété en action',
          pt: 'Leve um símbolo repetido para a ação',
          tr: 'Tekrar eden bir sembolü eyleme taşı',
        ),
        EmotionalState.hopeful => t(
          en: 'Turn hope into one observable experiment',
          es: 'Convierte la esperanza en un experimento observable',
          fr: 'Transformez l’espoir en une expérience observable',
          pt: 'Transforme esperança em um experimento observável',
          tr: 'Umudu gözlemlenebilir tek deneye dönüştür',
        ),
        EmotionalState.grounded => t(
          en: 'Use stability to examine the avoided question',
          es: 'Usa la estabilidad para mirar la pregunta evitada',
          fr: 'Utilisez votre stabilité pour regarder la question évitée',
          pt: 'Use a estabilidade para encarar a pergunta evitada',
          tr: 'Dengeni kaçındığın soruya bakmak için kullan',
        ),
        null => t(
          en: 'Save one honest reading and return after 24 hours',
          es: 'Guarda una lectura honesta y vuelve después de 24 horas',
          fr: 'Enregistrez un tirage honnête et revenez après 24 heures',
          pt: 'Salve uma leitura honesta e volte após 24 horas',
          tr: 'Dürüst bir okuma kaydet ve 24 saat sonra geri dön',
        ),
      };

  String _practiceBody(MysticPlusIntelligenceSnapshot report) => t(
    en: 'This suggestion comes from the starting emotions you recorded most often. Treat it as a practical reflection prompt, not an instruction or prediction.',
    es: 'Esta sugerencia parte de las emociones iniciales que registraste con más frecuencia. Úsala como reflexión práctica, no como instrucción o predicción.',
    fr: 'Cette suggestion vient des émotions de départ que vous avez le plus souvent enregistrées. Utilisez-la comme piste de réflexion, pas comme instruction ou prédiction.',
    pt: 'Esta sugestão parte das emoções iniciais que você registrou com mais frequência. Use como reflexão prática, não como instrução ou previsão.',
    tr: 'Bu öneri en sık kaydettiğin başlangıç duygularından gelir. Onu talimat veya kehanet değil, pratik düşünme sorusu olarak kullan.',
  );
}
