import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'app_language.dart';
import 'app_locale.dart';
import 'flagship.dart';
import 'local_growth_ledger.dart';
import 'theme.dart';

const mysticGrowthDiagnosticsEnabled = bool.fromEnvironment(
  'MYSTIC_GROWTH_DIAGNOSTICS',
  defaultValue: false,
);

class MysticGrowthEvidenceScreen extends StatefulWidget {
  const MysticGrowthEvidenceScreen({required this.language, super.key});

  final MysticLanguage language;

  @override
  State<MysticGrowthEvidenceScreen> createState() =>
      _MysticGrowthEvidenceScreenState();
}

class _MysticGrowthEvidenceScreenState
    extends State<MysticGrowthEvidenceScreen> {
  MysticGrowthEvidenceSnapshot? snapshot;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await MysticLocalGrowthLedger.instance.snapshot();
    if (!mounted) return;
    setState(() {
      snapshot = loaded;
      loading = false;
    });
  }

  String _copy({
    required String en,
    required String tr,
    required String es,
    required String fr,
    required String pt,
  }) => localized(
    widget.language.appLanguage,
    english: en,
    turkish: tr,
    spanish: es,
    french: fr,
    portugueseBrazil: pt,
  );

  @override
  Widget build(BuildContext context) {
    final evidence = snapshot;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _copy(
            en: 'Growth evidence',
            tr: 'Büyüme kanıtı',
            es: 'Evidencia de crecimiento',
            fr: 'Preuves de croissance',
            pt: 'Evidência de crescimento',
          ),
        ),
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF171027), Color(0xFF080711)],
            ),
          ),
          child: loading || evidence == null
              ? const Center(
                  child: CircularProgressIndicator(color: MysticColors.gold),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                  children: [
                    _privacyCard(),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _retentionCard('D1', evidence.reachedD1),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _retentionCard('D7', evidence.reachedD7),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _retentionCard('D30', evidence.reachedD30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _eventCard(evidence),
                    const SizedBox(height: 14),
                    _mirrorCard(evidence),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _shareEvidence,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: Text(
                        _copy(
                          en: 'Share aggregate evidence',
                          tr: 'Toplu kanıtı paylaş',
                          es: 'Compartir evidencia agregada',
                          fr: 'Partager les preuves agrégées',
                          pt: 'Compartilhar evidência agregada',
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _privacyCard() => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFF151120),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: MysticColors.gold.withValues(alpha: .22)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.shield_outlined, color: MysticColors.gold),
        const SizedBox(height: 10),
        Text(
          _copy(
            en: 'Aggregate-only. No private tarot content.',
            tr: 'Yalnızca toplu veri. Özel tarot içeriği yok.',
            es: 'Solo datos agregados. Sin contenido privado de tarot.',
            fr: 'Données agrégées uniquement. Aucun contenu tarot privé.',
            pt: 'Somente dados agregados. Sem conteúdo privado de tarot.',
          ),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 7),
        Text(
          _copy(
            en: 'This beta diagnostic contains event/day counts only. It does not include your questions, cards, notes, emotions, outcomes, name, intention, journal text, PIN or search history.',
            tr: 'Bu beta tanılama yalnızca olay/gün sayılarını içerir. Soruların, kartların, notların, duyguların, sonuçların, adın, niyetin, günlük metnin, PIN’in veya arama geçmişin yer almaz.',
            es: 'Este diagnóstico beta solo contiene recuentos de eventos y días. No incluye preguntas, cartas, notas, emociones, resultados, nombre, intención, diario, PIN ni búsquedas.',
            fr: 'Ce diagnostic bêta contient uniquement des comptes d’événements et de jours. Il n’inclut ni questions, cartes, notes, émotions, résultats, nom, intention, journal, PIN ou recherches.',
            pt: 'Este diagnóstico beta contém apenas contagens de eventos e dias. Não inclui perguntas, cartas, notas, emoções, resultados, nome, intenção, diário, PIN ou pesquisas.',
          ),
          style: const TextStyle(color: MysticColors.mist, height: 1.4),
        ),
      ],
    ),
  );

  Widget _retentionCard(String label, bool reached) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    decoration: BoxDecoration(
      color: const Color(0xFF151120),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: MysticColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Icon(
          reached ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: reached ? MysticColors.gold : MysticColors.muted,
          size: 20,
        ),
      ],
    ),
  );

  Widget _eventCard(MysticGrowthEvidenceSnapshot evidence) {
    final rows = <(String, int)>[
      (
        _copy(
          en: 'App opens',
          tr: 'Uygulama açılışları',
          es: 'Aperturas',
          fr: 'Ouvertures',
          pt: 'Aberturas',
        ),
        evidence.eventCounts['appOpened'] ?? 0,
      ),
      (
        _copy(
          en: 'Readings saved',
          tr: 'Kaydedilen okumalar',
          es: 'Lecturas guardadas',
          fr: 'Tirages enregistrés',
          pt: 'Leituras salvas',
        ),
        evidence.eventCounts['readingCompleted'] ?? 0,
      ),
      (
        _copy(
          en: 'Mirrors completed',
          tr: 'Tamamlanan Aynalar',
          es: 'Mirrors completados',
          fr: 'Mirrors terminés',
          pt: 'Mirrors concluídos',
        ),
        evidence.eventCounts['mirrorCompleted'] ?? 0,
      ),
      (
        _copy(
          en: 'Generic shares started',
          tr: 'Başlatılan genel paylaşımlar',
          es: 'Compartidos iniciados',
          fr: 'Partages lancés',
          pt: 'Compartilhamentos iniciados',
        ),
        evidence.eventCounts['mirrorShareStarted'] ?? 0,
      ),
      (
        _copy(
          en: 'Ad impressions',
          tr: 'Reklam gösterimleri',
          es: 'Impresiones de anuncios',
          fr: 'Impressions publicitaires',
          pt: 'Impressões de anúncios',
        ),
        evidence.eventCounts['adImpression'] ?? 0,
      ),
    ];
    return _listCard(
      title: _copy(
        en: 'Local product evidence',
        tr: 'Yerel ürün kanıtı',
        es: 'Evidencia local del producto',
        fr: 'Preuves produit locales',
        pt: 'Evidência local do produto',
      ),
      rows: rows,
    );
  }

  Widget _mirrorCard(MysticGrowthEvidenceSnapshot evidence) {
    final matureWindows = evidence.eventCounts['mirrorWindowMatured'] ?? 0;
    final completedWithin72 =
        evidence
            .dimensionCounts['mirrorWindowMatured|growth_stage|completed_within_72h'] ??
        0;
    final notCompletedWithin72 =
        evidence
            .dimensionCounts['mirrorWindowMatured|growth_stage|not_completed_within_72h'] ??
        0;
    final rate = matureWindows <= 0
        ? '—'
        : '${((completedWithin72 / matureWindows) * 100).toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4B2E72), Color(0xFF21152F)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _copy(
              en: 'Mature 72h Mystic Mirror KPI',
              tr: 'Olgun 72s Mystic Ayna KPI’ı',
              es: 'KPI maduro de Mystic Mirror 72 h',
              fr: 'KPI Mystic Mirror mature à 72 h',
              pt: 'KPI maduro do Mystic Mirror em 72 h',
            ),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 9),
          Text(
            rate,
            style: const TextStyle(
              color: MysticColors.gold,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            matureWindows == 0
                ? _copy(
                    en: 'Not proven yet — no 72-hour window has matured.',
                    tr: 'Henüz kanıtlanmadı — olgunlaşmış 72 saatlik pencere yok.',
                    es: 'Aún no demostrado: no ha madurado ninguna ventana de 72 h.',
                    fr: 'Pas encore démontré : aucune fenêtre de 72 h n’est arrivée à maturité.',
                    pt: 'Ainda não comprovado — nenhuma janela de 72 h amadureceu.',
                  )
                : '$completedWithin72 / $matureWindows',
            style: const TextStyle(color: MysticColors.mist),
          ),
          const SizedBox(height: 13),
          _metricRow(
            _copy(
              en: 'Mature windows',
              tr: 'Olgun pencereler',
              es: 'Ventanas maduras',
              fr: 'Fenêtres matures',
              pt: 'Janelas maduras',
            ),
            matureWindows,
          ),
          _metricRow(
            _copy(
              en: 'Completed within 72h',
              tr: '72 saat içinde tamamlandı',
              es: 'Completado en 72 h',
              fr: 'Terminé sous 72 h',
              pt: 'Concluído em 72 h',
            ),
            completedWithin72,
          ),
          _metricRow(
            _copy(
              en: 'Not completed within 72h',
              tr: '72 saat içinde tamamlanmadı',
              es: 'No completado en 72 h',
              fr: 'Non terminé sous 72 h',
              pt: 'Não concluído em 72 h',
            ),
            notCompletedWithin72,
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, int value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: MysticColors.mist)),
        ),
        Text(
          '$value',
          style: const TextStyle(
            color: MysticColors.gold,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  Widget _listCard({
    required String title,
    required List<(String, int)> rows,
  }) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFF151120),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        ...rows.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row.$1,
                    style: const TextStyle(color: MysticColors.mist),
                  ),
                ),
                Text(
                  '${row.$2}',
                  style: const TextStyle(
                    color: MysticColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _shareEvidence() async {
    final json = await MysticLocalGrowthLedger.instance.exportJson();
    if (!mounted) return;
    final renderObject = context.findRenderObject();
    final origin = renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : const Rect.fromLTWH(0, 0, 1, 1);
    await SharePlus.instance.share(
      ShareParams(
        text: json,
        subject: 'Mystic Tarot aggregate growth evidence',
        sharePositionOrigin: origin,
      ),
    );
  }
}
