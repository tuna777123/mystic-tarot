import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'business_metrics.dart';
import 'flagship.dart';
import 'models.dart';
import 'mystic_memory_map_feature.dart';
import 'mystic_mirror.dart';
import 'mystic_mirror_share.dart';
import 'mystic_search.dart';
import 'oracle_conversation.dart';
import 'oracle_memory_action.dart';
import 'tarot_localization.dart';
import 'theme.dart';

enum _JournalSection { timeline, insights, map, search }

class MysticLivingJournalFeature extends StatefulWidget {
  const MysticLivingJournalFeature({
    required this.records,
    required this.language,
    required this.onPremium,
    required this.onOpenOracle,
    this.onStartReading,
    this.onMirrorChanged,
    super.key,
  });

  final List<ReadingRecord> records;
  final MysticLanguage language;

  /// Retained for source compatibility with the pre-advertising UI contract.
  /// The Living Journal no longer exposes a paid-tier action.
  final VoidCallback onPremium;
  final Future<void> Function(ReadingRecord record) onOpenOracle;
  final VoidCallback? onStartReading;
  final VoidCallback? onMirrorChanged;

  @override
  State<MysticLivingJournalFeature> createState() =>
      _MysticLivingJournalFeatureState();
}

class _MysticLivingJournalFeatureState
    extends State<MysticLivingJournalFeature> {
  final MysticMirrorStore _mirrorStore = MysticMirrorStore();
  final OracleConversationStore _oracleStore = OracleConversationStore();
  _JournalSection section = _JournalSection.timeline;
  Map<String, MysticMirrorReflection> mirrors =
      const <String, MysticMirrorReflection>{};
  String query = '';
  bool mirrorsLoading = true;
  bool oracleLoading = true;
  Map<String, int> oracleTurnCounts = const <String, int>{};

  String get _languageCode => widget.language.code;

  Set<String> get _completedMirrorIds => mirrors.keys.toSet();

  List<ReadingRecord> get _dueRecords {
    final now = DateTime.now();
    return widget.records
        .where(
          (record) => mysticMirrorIsDue(
            record,
            now,
            completedRecordIds: _completedMirrorIds,
          ),
        )
        .toList()
      ..sort(
        (first, second) =>
            first.mirrorCheckInAt.compareTo(second.mirrorCheckInAt),
      );
  }

  String _copy(String english, String turkish) =>
      mysticText(widget.language, english, turkish);

  String _mirrorCopy({
    required String en,
    required String tr,
    required String es,
    required String fr,
    required String pt,
  }) => switch (widget.language) {
    MysticLanguage.turkish => tr,
    MysticLanguage.spanish => es,
    MysticLanguage.french => fr,
    MysticLanguage.portugueseBrazil => pt,
    _ => en,
  };

  @override
  void initState() {
    super.initState();
    _loadMirrors();
    _loadOracleMemory();
  }

  Future<void> _loadMirrors() async {
    final loaded = await _mirrorStore.load();
    if (!mounted) return;
    setState(() {
      mirrors = loaded;
      mirrorsLoading = false;
    });
  }

  Future<void> _loadOracleMemory() async {
    final grouped = await _oracleStore.loadGrouped();
    if (!mounted) return;
    setState(() {
      oracleTurnCounts = grouped.map(
        (recordId, turns) => MapEntry(recordId, turns.length),
      );
      oracleLoading = false;
    });
  }

  Future<void> _openOracle(ReadingRecord record) async {
    await widget.onOpenOracle(record);
    if (!mounted) return;
    await _loadOracleMemory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF171027), Color(0xFF080711)],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              _buildSectionPicker(),
              Expanded(child: _buildSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dueCount = mirrorsLoading ? 0 : _dueRecords.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _copy('LIVING JOURNAL', 'YAŞAYAN GÜNLÜK'),
                  style: const TextStyle(
                    color: MysticColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _copy('Your story remembers.', 'Hikâyen seni hatırlıyor.'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  dueCount > 0
                      ? _mirrorCopy(
                          en: '$dueCount Mystic Mirror check-in${dueCount == 1 ? '' : 's'} ready.',
                          tr: '$dueCount Mystic Ayna kontrolü hazır.',
                          es: '$dueCount revisión de Mystic Mirror lista.',
                          fr: '$dueCount bilan Mystic Mirror est prêt.',
                          pt: '$dueCount check-in do Mystic Mirror está pronto.',
                        )
                      : _copy(
                          'See what returns, what shifts, and what asks for attention.',
                          'Tekrar edenleri, değişenleri ve dikkat isteyenleri gör.',
                        ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dueCount > 0 ? MysticColors.gold : MysticColors.mist,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: MysticColors.violet.withValues(alpha: .24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: MysticColors.lavender.withValues(alpha: .24),
                  ),
                ),
                child: Text(
                  widget.records.length.toString(),
                  style: const TextStyle(
                    color: MysticColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (dueCount > 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: MysticColors.gold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$dueCount DUE',
                    style: const TextStyle(
                      color: MysticColors.ink,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SegmentedButton<_JournalSection>(
        segments: [
          ButtonSegment<_JournalSection>(
            value: _JournalSection.timeline,
            icon: const Icon(Icons.timeline, size: 17),
            label: Text(_copy('Timeline', 'Zaman')),
          ),
          ButtonSegment<_JournalSection>(
            value: _JournalSection.insights,
            icon: const Icon(Icons.auto_graph, size: 17),
            label: Text(_copy('Insights', 'İçgörü')),
          ),
          ButtonSegment<_JournalSection>(
            value: _JournalSection.map,
            icon: const Icon(Icons.hub_outlined, size: 17),
            label: Text(_copy('Map', 'Harita')),
          ),
          ButtonSegment<_JournalSection>(
            value: _JournalSection.search,
            icon: const Icon(Icons.search, size: 17),
            label: Text(_copy('Search', 'Ara')),
          ),
        ],
        selected: <_JournalSection>{section},
        onSelectionChanged: (selection) {
          setState(() => section = selection.first);
        },
        showSelectedIcon: false,
      ),
    );
  }

  Widget _buildSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: switch (section) {
        _JournalSection.timeline => _buildTimeline(
          widget.records,
          key: const ValueKey<String>('timeline'),
          showDueBanner: true,
        ),
        _JournalSection.insights => _buildInsights(),
        _JournalSection.map => MysticMemoryMapFeature(
          key: const ValueKey<String>('memory-map'),
          records: widget.records,
          language: widget.language,
        ),
        _JournalSection.search => _buildSearch(),
      },
    );
  }

  Widget _buildTimeline(
    List<ReadingRecord> records, {
    required Key key,
    bool showDueBanner = false,
  }) {
    if (records.isEmpty) {
      return _buildEmptyState(key: key);
    }

    final children = <Widget>[
      if (showDueBanner && !mirrorsLoading && _dueRecords.isNotEmpty)
        _buildDueBanner(_dueRecords),
      ...records.map((record) => _buildRecordCard(context, record)),
    ];

    return ListView.separated(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      itemCount: children.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildDueBanner(List<ReadingRecord> dueRecords) {
    final first = dueRecords.first;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B4A91), Color(0xFF241832)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .5)),
        boxShadow: [
          BoxShadow(
            color: MysticColors.violet.withValues(alpha: .18),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timelapse_rounded, color: MysticColors.gold),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _mirrorCopy(
                    en: 'MYSTIC MIRROR IS READY',
                    tr: 'MYSTIC AYNA HAZIR',
                    es: 'MYSTIC MIRROR ESTÁ LISTO',
                    fr: 'MYSTIC MIRROR EST PRÊT',
                    pt: 'MYSTIC MIRROR ESTÁ PRONTO',
                  ),
                  style: const TextStyle(
                    color: MysticColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                '${dueRecords.length}',
                style: const TextStyle(
                  color: MysticColors.gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            _mirrorCopy(
              en: 'Twenty-four hours passed. What actually changed?',
              tr: 'Yirmi dört saat geçti. Gerçekte ne değişti?',
              es: 'Pasaron veinticuatro horas. ¿Qué cambió de verdad?',
              fr: 'Vingt-quatre heures ont passé. Qu’est-ce qui a vraiment changé ?',
              pt: 'Vinte e quatro horas se passaram. O que realmente mudou?',
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            _mirrorCopy(
              en: 'Compare your action with reality. Your answer becomes evidence in your private pattern history.',
              tr: 'Eylemini gerçekle karşılaştır. Cevabın özel örüntü geçmişinde kanıta dönüşür.',
              es: 'Compara tu acción con la realidad. Tu respuesta se convierte en evidencia dentro de tu historial privado de patrones.',
              fr: 'Comparez votre action à la réalité. Votre réponse devient une preuve dans votre historique privé de schémas.',
              pt: 'Compare sua ação com a realidade. Sua resposta vira evidência no seu histórico privado de padrões.',
            ),
            style: const TextStyle(color: MysticColors.mist, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openMirrorCheckIn(first),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(
                _mirrorCopy(
                  en: 'Complete oldest check-in',
                  tr: 'En eski kontrolü tamamla',
                  es: 'Completar la revisión más antigua',
                  fr: 'Compléter le bilan le plus ancien',
                  pt: 'Concluir o check-in mais antigo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, ReadingRecord record) {
    final recordId = mysticMirrorRecordId(record);
    final mirror = mirrors[recordId];
    final due =
        !mirrorsLoading &&
        mysticMirrorIsDue(
          record,
          DateTime.now(),
          completedRecordIds: _completedMirrorIds,
        );
    final cards = record.cards
        .map((drawn) {
          final orientation = drawn.reversed
              ? _copy('reversed', 'ters')
              : _copy('upright', 'düz');
          return '${localizedTarotCardName(drawn.card.name, languageCode: _languageCode)} · $orientation';
        })
        .join('\n');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151120),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: due
              ? MysticColors.gold.withValues(alpha: .45)
              : Colors.white.withValues(alpha: .08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MysticColors.violet.withValues(alpha: .28),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  record.kind.symbol,
                  style: const TextStyle(color: MysticColors.gold),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedReadingKindTitle(
                        record.kind,
                        languageCode: _languageCode,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(record.createdAt),
                      style: const TextStyle(
                        color: MysticColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${record.emotion.symbol} ${localizedEmotionLabel(record.emotion, languageCode: _languageCode)}',
                style: const TextStyle(
                  color: MysticColors.lavender,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (record.question.trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            Text(
              record.question,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 11),
          Text(
            cards,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MysticColors.lavender,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          if (record.alignedAction.trim().isNotEmpty) ...[
            const SizedBox(height: 11),
            Text(
              record.alignedAction,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: MysticColors.mist),
            ),
          ],
          const SizedBox(height: 14),
          if (mirror != null) _buildCompletedMirror(record, mirror),
          if (mirror == null && due) _buildDueMirrorAction(record),
          if (mirror == null && !due && !mirrorsLoading)
            _buildWaitingMirror(record),
          if (!oracleLoading) ...[
            const SizedBox(height: 12),
            OracleMemoryAction(
              turnCount:
                  oracleTurnCounts[oracleConversationRecordId(record)] ?? 0,
              language: widget.language,
              onTap: () => _openOracle(record),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedMirror(
    ReadingRecord record,
    MysticMirrorReflection mirror,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: MysticColors.gold.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 17,
                color: MysticColors.gold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _mirrorCopy(
                    en: '24H MIRROR COMPLETED',
                    tr: '24 SAATLİK AYNA TAMAMLANDI',
                    es: 'MIRROR DE 24 H COMPLETADO',
                    fr: 'MIROIR 24 H TERMINÉ',
                    pt: 'MIRROR DE 24 H CONCLUÍDO',
                  ),
                  style: const TextStyle(
                    color: MysticColors.gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(mirror.emotion.symbol, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_outcomeLabel(mirror.outcome)} • ${localizedEmotionLabel(mirror.emotion, languageCode: _languageCode)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (mirror.note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              mirror.note,
              style: const TextStyle(color: MysticColors.mist, height: 1.4),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                await MysticBusinessMetrics.record(
                  MysticBusinessEvent.mirrorShareStarted,
                  dimensions: {
                    'language': widget.language.code,
                    'source': 'living_journal',
                  },
                );
                await SharePlus.instance.share(
                  ShareParams(
                    text: mysticMirrorShareText(widget.language),
                    subject: mysticMirrorShareSubject(widget.language),
                  ),
                );
              },
              icon: const Icon(Icons.ios_share_rounded, size: 17),
              label: Text(
                _mirrorCopy(
                  en: 'Share the 24h ritual',
                  tr: '24 saatlik ritüeli paylaş',
                  es: 'Compartir el ritual de 24 h',
                  fr: 'Partager le rituel de 24 h',
                  pt: 'Compartilhar o ritual de 24 h',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueMirrorAction(ReadingRecord record) {
    return InkWell(
      onTap: () => _openMirrorCheckIn(record),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5A3E7B), Color(0xFF271A35)],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.timelapse_rounded, color: MysticColors.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _mirrorCopy(
                      en: 'What actually changed?',
                      tr: 'Gerçekte ne değişti?',
                      es: '¿Qué cambió de verdad?',
                      fr: 'Qu’est-ce qui a vraiment changé ?',
                      pt: 'O que realmente mudou?',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _mirrorCopy(
                      en: 'Complete your 24-hour check-in',
                      tr: '24 saatlik kontrolünü tamamla',
                      es: 'Completa tu revisión de 24 horas',
                      fr: 'Complétez votre bilan après 24 heures',
                      pt: 'Conclua seu check-in de 24 horas',
                    ),
                    style: const TextStyle(
                      color: MysticColors.lavender,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: MysticColors.gold),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingMirror(ReadingRecord record) {
    final minutes = record.mirrorCheckInAt.difference(DateTime.now()).inMinutes;
    final hours = (minutes / 60).ceil().clamp(1, 24);
    return Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 16, color: MysticColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _mirrorCopy(
              en: 'Mystic Mirror opens in about $hours h',
              tr: 'Mystic Ayna yaklaşık $hours saat sonra açılır',
              es: 'Mystic Mirror se abre en unas $hours h',
              fr: 'Mystic Mirror s’ouvre dans environ $hours h',
              pt: 'Mystic Mirror abre em cerca de $hours h',
            ),
            style: const TextStyle(color: MysticColors.muted, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildMirrorEvidenceContext(ReadingRecord record) {
    final action = record.alignedAction.trim();
    return Container(
      key: const ValueKey('mirror-evidence-context'),
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D2348), Color(0xFF171321)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _mirrorCopy(
              en: "YESTERDAY'S SIGNAL",
              tr: 'DÜNÜN İŞARETİ',
              es: 'LA SEÑAL DE AYER',
              fr: 'LE SIGNAL D’HIER',
              pt: 'O SINAL DE ONTEM',
            ),
            style: const TextStyle(
              color: MysticColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${record.emotion.symbol} ${localizedEmotionLabel(record.emotion, languageCode: _languageCode)}',
            style: const TextStyle(
              color: MysticColors.lavender,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (action.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _mirrorCopy(
                en: 'ACTION YOU CHOSE',
                tr: 'SEÇTİĞİN EYLEM',
                es: 'LA ACCIÓN QUE ELEGISTE',
                fr: 'L’ACTION CHOISIE',
                pt: 'A AÇÃO QUE VOCÊ ESCOLHEU',
              ),
              style: const TextStyle(
                color: MysticColors.muted,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              action,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: MysticColors.mist, height: 1.4),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Colors.white10),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.compare_arrows_rounded,
                color: MysticColors.gold,
                size: 18,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _mirrorCopy(
                    en: 'Record reality, not whether tarot was right.',
                    tr: 'Tarotun doğru çıkıp çıkmadığını değil, gerçeği kaydet.',
                    es: 'Registra la realidad, no si el tarot acertó.',
                    fr: 'Notez la réalité, pas si le tarot avait raison.',
                    pt: 'Registre a realidade, não se o tarô acertou.',
                  ),
                  style: const TextStyle(
                    color: MysticColors.mist,
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openMirrorCheckIn(ReadingRecord record) async {
    MysticMirrorOutcome? outcome;
    var emotion = record.emotion;
    var saving = false;
    final noteController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF171321),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _mirrorCopy(
                      en: 'Mystic Mirror',
                      tr: 'Mystic Ayna',
                      es: 'Mystic Mirror',
                      fr: 'Mystic Mirror',
                      pt: 'Mystic Mirror',
                    ),
                    style: Theme.of(sheetContext).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _mirrorCopy(
                      en: 'Look back without forcing a positive result. Honest evidence is more useful than a perfect story.',
                      tr: 'Olumlu bir sonuç çıkarmaya çalışma. Dürüst kanıt, kusursuz bir hikâyeden daha değerlidir.',
                      es: 'Mira atrás sin forzar un resultado positivo. La evidencia honesta es más útil que una historia perfecta.',
                      fr: 'Regardez en arrière sans forcer un résultat positif. Une preuve honnête vaut mieux qu’une histoire parfaite.',
                      pt: 'Olhe para trás sem forçar um resultado positivo. Evidência honesta vale mais que uma história perfeita.',
                    ),
                    style: const TextStyle(
                      color: MysticColors.mist,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMirrorEvidenceContext(record),
                  const SizedBox(height: 20),
                  Text(
                    _mirrorCopy(
                      en: 'WHAT HAPPENED?',
                      tr: 'NE OLDU?',
                      es: '¿QUÉ PASÓ?',
                      fr: 'QUE S’EST-IL PASSÉ ?',
                      pt: 'O QUE ACONTECEU?',
                    ),
                    style: const TextStyle(
                      color: MysticColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MysticMirrorOutcome.values
                        .map(
                          (item) => ChoiceChip(
                            label: Text(_outcomeLabel(item)),
                            selected: outcome == item,
                            onSelected: (_) {
                              setSheetState(() => outcome = item);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _mirrorCopy(
                      en: 'HOW DO YOU FEEL NOW?',
                      tr: 'ŞİMDİ NASIL HİSSEDİYORSUN?',
                      es: '¿CÓMO TE SIENTES AHORA?',
                      fr: 'COMMENT VOUS SENTEZ-VOUS MAINTENANT ?',
                      pt: 'COMO VOCÊ SE SENTE AGORA?',
                    ),
                    style: const TextStyle(
                      color: MysticColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: EmotionalState.values
                        .map(
                          (item) => ChoiceChip(
                            label: Text(
                              '${item.symbol} ${localizedEmotionLabel(item, languageCode: _languageCode)}',
                            ),
                            selected: emotion == item,
                            onSelected: (_) {
                              setSheetState(() => emotion = item);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: noteController,
                    maxLength: 500,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: _mirrorCopy(
                        en: 'What changed, or what stayed the same? (optional)',
                        tr: 'Ne değişti veya ne aynı kaldı? (isteğe bağlı)',
                        es: '¿Qué cambió o qué siguió igual? (opcional)',
                        fr: 'Qu’est-ce qui a changé ou est resté identique ? (facultatif)',
                        pt: 'O que mudou ou continuou igual? (opcional)',
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: outcome == null || saving
                          ? null
                          : () async {
                              setSheetState(() => saving = true);
                              final reflection = MysticMirrorReflection(
                                recordId: mysticMirrorRecordId(record),
                                outcome: outcome!,
                                emotion: emotion,
                                note: noteController.text.trim(),
                                completedAt: DateTime.now().toUtc(),
                              );
                              try {
                                await _mirrorStore.save(reflection);
                                if (!mounted) return;
                                setState(() {
                                  mirrors = <String, MysticMirrorReflection>{
                                    ...mirrors,
                                    reflection.recordId: reflection,
                                  };
                                });
                                await MysticBusinessMetrics.record(
                                  MysticBusinessEvent.mirrorCompleted,
                                  dimensions: {
                                    'language': widget.language.code,
                                    'source': 'living_journal',
                                  },
                                );
                                widget.onMirrorChanged?.call();
                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              } catch (_) {
                                if (sheetContext.mounted) {
                                  setSheetState(() => saving = false);
                                  ScaffoldMessenger.of(
                                    sheetContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _mirrorCopy(
                                          en: 'The reflection could not be saved. Nothing was changed; please try again.',
                                          tr: 'Yansıma kaydedilemedi. Hiçbir şey değiştirilmedi; lütfen tekrar dene.',
                                          es: 'No se pudo guardar la reflexión. No se cambió nada; inténtalo de nuevo.',
                                          fr: 'La réflexion n’a pas pu être enregistrée. Rien n’a été modifié ; réessayez.',
                                          pt: 'Não foi possível salvar a reflexão. Nada foi alterado; tente novamente.',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        saving
                            ? _mirrorCopy(
                                en: 'Saving…',
                                tr: 'Kaydediliyor…',
                                es: 'Guardando…',
                                fr: 'Enregistrement…',
                                pt: 'Salvando…',
                              )
                            : _mirrorCopy(
                                en: 'Save honest reflection',
                                tr: 'Dürüst yansımayı kaydet',
                                es: 'Guardar reflexión honesta',
                                fr: 'Enregistrer la réflexion honnête',
                                pt: 'Salvar reflexão honesta',
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _mirrorCopy(
                      en: 'Stored privately on this device. This is reflection, not a prediction score.',
                      tr: 'Bu cihazda özel olarak saklanır. Bu bir düşünme kaydıdır, kehanet puanı değildir.',
                      es: 'Se guarda de forma privada en este dispositivo. Es una reflexión, no una puntuación de predicción.',
                      fr: 'Enregistré en privé sur cet appareil. Il s’agit d’une réflexion, pas d’un score de prédiction.',
                      pt: 'Armazenado de forma privada neste dispositivo. É uma reflexão, não uma pontuação de previsão.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: MysticColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    noteController.dispose();
  }

  Widget _buildInsights() {
    if (widget.records.isEmpty) {
      return _buildEmptyState(key: const ValueKey<String>('insights-empty'));
    }

    final cardCounts = <String, int>{};
    final emotionCounts = <EmotionalState, int>{};
    for (final record in widget.records) {
      emotionCounts.update(
        record.emotion,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      for (final drawn in record.cards) {
        cardCounts.update(
          drawn.card.name,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final rankedCards = cardCounts.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));
    final rankedEmotions = emotionCounts.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));
    final recentCount = widget.records.where((record) {
      return DateTime.now().difference(record.createdAt).inDays <= 30;
    }).length;
    final completedMirrors = mirrors.values.toList();
    final movementCount = completedMirrors.where((mirror) {
      return mirror.outcome == MysticMirrorOutcome.shifted ||
          mirror.outcome == MysticMirrorOutcome.partlyShifted;
    }).length;
    final movementRate = completedMirrors.isEmpty
        ? 0
        : ((movementCount / completedMirrors.length) * 100).round();
    final transitionCounts = <String, int>{};
    for (final record in widget.records) {
      final mirror = mirrors[mysticMirrorRecordId(record)];
      if (mirror == null) continue;
      final transition =
          '${localizedEmotionLabel(record.emotion, languageCode: _languageCode)} → ${localizedEmotionLabel(mirror.emotion, languageCode: _languageCode)}';
      transitionCounts.update(
        transition,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    final rankedTransitions = transitionCounts.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));

    return ListView(
      key: const ValueKey<String>('insights'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetric(
                _copy('Total readings', 'Toplam okuma'),
                widget.records.length.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetric(
                _copy('Last 30 days', 'Son 30 gün'),
                recentCount.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetric(
                _mirrorCopy(
                  en: 'Mirror check-ins',
                  tr: 'Ayna kontrolleri',
                  es: 'Revisiones Mirror',
                  fr: 'Bilans Mirror',
                  pt: 'Check-ins Mirror',
                ),
                completedMirrors.length.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetric(
                _mirrorCopy(
                  en: 'Movement noticed',
                  tr: 'Hareket fark edildi',
                  es: 'Cambio observado',
                  fr: 'Mouvement observé',
                  pt: 'Mudança percebida',
                ),
                completedMirrors.isEmpty ? '—' : '$movementRate%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPatternCard(
          title: _copy('Cards returning to you', 'Sana dönen kartlar'),
          rows: rankedCards.take(4).map((entry) {
            return _InsightRow(
              localizedTarotCardName(entry.key, languageCode: _languageCode),
              '${entry.value}×',
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildPatternCard(
          title: _copy('Emotional weather', 'Duygusal hava'),
          rows: rankedEmotions.take(3).map((entry) {
            return _InsightRow(
              '${entry.key.symbol} ${_emotionLabel(entry.key)}',
              '${entry.value}×',
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildPatternCard(
          title: _mirrorCopy(
            en: 'How your emotional state shifted',
            tr: 'Duygun nasıl değişti',
            es: 'Cómo cambió tu estado emocional',
            fr: 'Comment votre état émotionnel a évolué',
            pt: 'Como seu estado emocional mudou',
          ),
          rows: rankedTransitions
              .take(4)
              .map((entry) => _InsightRow(entry.key, '${entry.value}×'))
              .toList(),
        ),
        const SizedBox(height: 12),
        _buildPatternLabCard(),
      ],
    );
  }

  Widget _buildMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151120),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: MysticColors.gold,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: MysticColors.mist, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard({
    required String title,
    required List<_InsightRow> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF151120),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            Text(
              _copy(
                'More readings will reveal this pattern.',
                'Daha fazla okuma bu örüntüyü gösterecek.',
              ),
              style: const TextStyle(color: MysticColors.mist),
            )
          else
            ...rows.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(
                  children: [
                    const Text('✦', style: TextStyle(color: MysticColors.gold)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(row.label)),
                    Text(
                      row.value,
                      style: const TextStyle(
                        color: MysticColors.lavender,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPatternLabCard() {
    final completed = mirrors.length;
    final readingCount = widget.records.length;
    final evidenceCount = completed.clamp(0, readingCount);
    final progress = readingCount == 0 ? 0.0 : evidenceCount / readingCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4B2E72), Color(0xFF21152F)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.hub_outlined, color: MysticColors.gold),
          const SizedBox(height: 10),
          Text(
            _mirrorCopy(
              en: 'Your Pattern Lab grows with evidence',
              tr: 'Örüntü Laboratuvarın kanıtla büyür',
              es: 'Tu Laboratorio de Patrones crece con evidencia',
              fr: 'Votre Laboratoire de schémas grandit avec les preuves',
              pt: 'Seu Laboratório de Padrões cresce com evidências',
            ),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            _mirrorCopy(
              en: 'Every saved reading and honest 24-hour check-in adds context. Nothing is locked: richer patterns appear as your private history earns enough evidence.',
              tr: 'Her kayıtlı okuma ve dürüst 24 saatlik kontrol yeni bağlam ekler. Hiçbir şey kilitli değil: özel geçmişin yeterli kanıt biriktirdikçe daha zengin örüntüler görünür.',
              es: 'Cada lectura guardada y revisión honesta de 24 horas añade contexto. Nada está bloqueado: los patrones más ricos aparecen cuando tu historial privado reúne suficiente evidencia.',
              fr: 'Chaque tirage enregistré et bilan honnête après 24 h ajoute du contexte. Rien n’est verrouillé : des schémas plus riches apparaissent lorsque votre historique privé accumule assez de preuves.',
              pt: 'Cada leitura salva e check-in honesto de 24 horas adiciona contexto. Nada fica bloqueado: padrões mais ricos aparecem quando seu histórico privado reúne evidências suficientes.',
            ),
            style: const TextStyle(color: MysticColors.mist),
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white10,
              color: MysticColors.gold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _mirrorCopy(
              en: '$completed reality check-ins • $readingCount saved readings',
              tr: '$completed gerçeklik kontrolü • $readingCount kayıtlı okuma',
              es: '$completed revisiones de realidad • $readingCount lecturas guardadas',
              fr: '$completed bilans de réalité • $readingCount tirages enregistrés',
              pt: '$completed check-ins de realidade • $readingCount leituras salvas',
            ),
            style: const TextStyle(
              color: MysticColors.lavender,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => setState(() => section = _JournalSection.map),
            icon: const Icon(Icons.hub_rounded, size: 18),
            label: Text(
              _mirrorCopy(
                en: 'Open my Pattern Map',
                tr: 'Örüntü Haritamı aç',
                es: 'Abrir mi Mapa de Patrones',
                fr: 'Ouvrir ma Carte des schémas',
                pt: 'Abrir meu Mapa de Padrões',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    final results = _filteredRecords;
    return Column(
      key: const ValueKey<String>('search'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: TextField(
            onChanged: (value) {
              setState(() => query = value.trim());
            },
            decoration: InputDecoration(
              hintText: _copy(
                'Search cards, questions, feelings, actions…',
                'Kart, soru, duygu veya eylem ara…',
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: _buildTimeline(
            results,
            key: ValueKey<String>('search-$query-${results.length}'),
          ),
        ),
      ],
    );
  }

  List<ReadingRecord> get _filteredRecords {
    if (query.isEmpty) return widget.records;

    return widget.records.where((record) {
      final mirror = mirrors[mysticMirrorRecordId(record)];
      return mysticSearchMatches(
        query: query,
        values: <String>[
          record.kind.title,
          localizedReadingKindTitle(record.kind, languageCode: _languageCode),
          record.question,
          record.emotion.label,
          localizedEmotionLabel(record.emotion, languageCode: _languageCode),
          record.alignedAction,
          if (mirror != null) mirror.note,
          if (mirror != null) _outcomeLabel(mirror.outcome),
          if (mirror != null)
            localizedEmotionLabel(mirror.emotion, languageCode: _languageCode),
          ...record.cards.map((drawn) => drawn.card.name),
          ...record.cards.map(
            (drawn) => localizedTarotCardName(
              drawn.card.name,
              languageCode: _languageCode,
            ),
          ),
        ],
      );
    }).toList();
  }

  String _outcomeLabel(MysticMirrorOutcome outcome) => switch (outcome) {
    MysticMirrorOutcome.shifted => _mirrorCopy(
      en: 'Something shifted',
      tr: 'Bir şey değişti',
      es: 'Algo cambió',
      fr: 'Quelque chose a changé',
      pt: 'Algo mudou',
    ),
    MysticMirrorOutcome.partlyShifted => _mirrorCopy(
      en: 'Partly changed',
      tr: 'Kısmen değişti',
      es: 'Cambió en parte',
      fr: 'Partiellement changé',
      pt: 'Mudou em parte',
    ),
    MysticMirrorOutcome.unchanged => _mirrorCopy(
      en: 'Nothing changed yet',
      tr: 'Henüz değişmedi',
      es: 'Aún no cambió',
      fr: 'Rien n’a encore changé',
      pt: 'Ainda não mudou',
    ),
    MysticMirrorOutcome.unclear => _mirrorCopy(
      en: 'Still unclear',
      tr: 'Hâlâ belirsiz',
      es: 'Sigue sin estar claro',
      fr: 'Toujours incertain',
      pt: 'Ainda não está claro',
    ),
  };

  String _emotionLabel(EmotionalState emotion) => switch (emotion) {
    EmotionalState.anxious => _copy('Anxious', 'Kaygılı'),
    EmotionalState.hopeful => _copy('Hopeful', 'Umutlu'),
    EmotionalState.grounded => _copy('Grounded', 'Dengeli'),
    EmotionalState.curious => _copy('Curious', 'Meraklı'),
    EmotionalState.uncertain => _copy('Uncertain', 'Kararsız'),
  };

  Widget _buildEmptyState({required Key key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D4DB3), Color(0xFF271A42)],
                ),
                border: Border.all(
                  color: MysticColors.gold.withValues(alpha: .45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: MysticColors.violet.withValues(alpha: .32),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Text(
                '☾',
                style: TextStyle(fontSize: 42, color: MysticColors.gold),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _copy('Your journal is waiting.', 'Günlüğün seni bekliyor.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              _copy(
                'Complete a reading and your timeline will begin to remember what matters.',
                'Bir okuma tamamla; zaman çizgin önemli olanları hatırlamaya başlasın.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: MysticColors.mist),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF251B3D), Color(0xFF15111F)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: MysticColors.lavender.withValues(alpha: .22),
                ),
              ),
              child: Column(
                children: [
                  _emptyPreviewRow(
                    Icons.timeline_rounded,
                    _copy('Your reading timeline', 'Okuma zaman çizgin'),
                    _copy(
                      'Every saved reading, in context',
                      'Her kayıtlı okuma, kendi bağlamında',
                    ),
                  ),
                  const Divider(height: 22, color: Colors.white10),
                  _emptyPreviewRow(
                    Icons.timelapse_rounded,
                    _mirrorCopy(
                      en: '24-hour reality check',
                      tr: '24 saatlik gerçeklik kontrolü',
                      es: 'Comprobación de realidad a las 24 horas',
                      fr: 'Vérification de réalité après 24 heures',
                      pt: 'Verificação de realidade após 24 horas',
                    ),
                    _mirrorCopy(
                      en: 'Compare guidance with what happened',
                      tr: 'Rehberliği yaşananlarla karşılaştır',
                      es: 'Compara la guía con lo que ocurrió',
                      fr: 'Comparez la guidance à ce qui s’est passé',
                      pt: 'Compare a orientação com o que aconteceu',
                    ),
                  ),
                  const Divider(height: 22, color: Colors.white10),
                  _emptyPreviewRow(
                    Icons.hub_outlined,
                    _copy('Private memory map', 'Özel hafıza haritası'),
                    _copy(
                      'Connections only you can see',
                      'Yalnızca senin görebileceğin bağlar',
                    ),
                  ),
                ],
              ),
            ),
            if (widget.onStartReading != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: widget.onStartReading,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    _copy('Create my first memory', 'İlk anımı oluştur'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyPreviewRow(IconData icon, String title, String body) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MysticColors.violet.withValues(alpha: .22),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, size: 19, color: MysticColors.gold),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(height: 3),
            Text(
              body,
              style: const TextStyle(color: MysticColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
      const Icon(
        Icons.arrow_forward_rounded,
        size: 16,
        color: MysticColors.lavender,
      ),
    ],
  );

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}

class _InsightRow {
  const _InsightRow(this.label, this.value);

  final String label;
  final String value;
}
