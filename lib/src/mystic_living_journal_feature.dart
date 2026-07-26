import 'package:flutter/material.dart';

import 'flagship.dart';
import 'models.dart';
import 'mystic_journey.dart';
import 'mystic_journey_store.dart';
import 'mystic_memory.dart';
import 'mystic_memory_adapters.dart';
import 'theme.dart';

class MysticLivingJournalFeature extends StatefulWidget {
  const MysticLivingJournalFeature({
    super.key,
    required this.records,
    required this.language,
    this.journeyStore,
    this.clock,
  });

  final List<ReadingRecord> records;
  final MysticLanguage language;
  final MysticJourneyStore? journeyStore;
  final DateTime Function()? clock;

  @override
  State<MysticLivingJournalFeature> createState() =>
      _MysticLivingJournalFeatureState();
}

class _MysticLivingJournalFeatureState
    extends State<MysticLivingJournalFeature> {
  late final MysticJourneyStore _journeyStore =
      widget.journeyStore ?? SharedPreferencesMysticJourneyStore();
  late final DateTime Function() _clock = widget.clock ?? DateTime.now;
  final TextEditingController _searchController = TextEditingController();

  List<MysticJourney> _journeys = const [];
  JourneyLoadResult? _journeyLoadResult;
  bool _loading = true;
  bool _loadFailed = false;
  int _section = 0;

  @override
  void initState() {
    super.initState();
    _loadJourneys();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJourneys() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadFailed = false;
      });
    }
    try {
      final result = await _journeyStore.load();
      if (!mounted) return;
      setState(() {
        _journeys = result.journeys;
        _journeyLoadResult = result;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: MysticColors.ink,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadFailed) {
      return Scaffold(
        backgroundColor: MysticColors.ink,
        appBar: AppBar(
          title: Text(_copy('Living Journal', 'Yaşayan Günlük')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_stories_outlined, size: 52),
                const SizedBox(height: 16),
                Text(
                  _copy(
                    'Your private journal could not be opened safely.',
                    'Özel günlüğün güvenli şekilde açılamadı.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _loadJourneys,
                  child: Text(_copy('Try again', 'Tekrar dene')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final events = _buildEvents();
    final snapshot = MysticMemoryEngine.build(
      events,
      generatedAt: _clock(),
    );

    return Scaffold(
      backgroundColor: MysticColors.ink,
      appBar: AppBar(
        title: Text(_copy('Living Journal', 'Yaşayan Günlük')),
        actions: [
          IconButton(
            tooltip: _copy('Refresh memories', 'Anıları yenile'),
            onPressed: _loadJourneys,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_journeyLoadResult?.recoveredFromBackup ?? false)
              _MemoryNotice(
                text: _copy(
                  'Mystic restored your last safe Journey backup.',
                  'Mystic son güvenli Yolculuk yedeğini geri yükledi.',
                ),
              ),
            if ((_journeyLoadResult?.rejectedItems ?? 0) > 0)
              _MemoryNotice(
                text: _copy(
                  '${_journeyLoadResult!.rejectedItems} damaged item(s) were skipped safely.',
                  '${_journeyLoadResult!.rejectedItems} bozuk kayıt güvenle atlandı.',
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: _SectionSelector(
                selected: _section,
                labels: [
                  _copy('Timeline', 'Zaman'),
                  _copy('Insights', 'İçgörüler'),
                  _copy('Search', 'Ara'),
                ],
                onSelected: (value) => setState(() => _section = value),
              ),
            ),
            Expanded(
              child: switch (_section) {
                0 => _TimelineView(
                    snapshot: snapshot,
                    language: widget.language,
                  ),
                1 => _InsightsView(
                    snapshot: snapshot,
                    now: _clock(),
                    language: widget.language,
                  ),
                _ => _SearchView(
                    events: snapshot.timeline,
                    language: widget.language,
                    controller: _searchController,
                    onChanged: () => setState(() {}),
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }

  List<TimelineEvent> _buildEvents() {
    final events = <TimelineEvent>[];
    for (var index = 0; index < widget.records.length; index++) {
      events.add(_readingEvent(widget.records[index], index));
    }
    for (final journey in _journeys) {
      events.addAll(MysticMemoryAdapters.fromJourney(journey));
    }
    events.addAll(_milestones());
    return events;
  }

  TimelineEvent _readingEvent(ReadingRecord record, int index) {
    return TimelineEvent(
      id: 'app-reading:${record.createdAt.microsecondsSinceEpoch}:$index',
      occurredAt: record.createdAt,
      type: MemoryEventType.reading,
      title: record.kind.title,
      reflection: record.alignedAction.trim().isNotEmpty
          ? record.alignedAction
          : record.question,
      themes: {_themeForReading(record.kind)},
      tags: {record.kind.name, record.emotion.name},
      cardIds: record.cards.map((item) => item.card.name),
      mood: record.emotion.label,
      sourceId: '${record.createdAt.microsecondsSinceEpoch}:$index',
    );
  }

  List<TimelineEvent> _milestones() {
    if (widget.records.isEmpty) return const [];
    final chronological = widget.records.toList(growable: false)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    const thresholds = [1, 10, 25, 50, 100];
    final milestones = <TimelineEvent>[];
    for (final threshold in thresholds) {
      if (chronological.length < threshold) continue;
      final record = chronological[threshold - 1];
      milestones.add(
        TimelineEvent(
          id: 'milestone:readings:$threshold',
          occurredAt: record.createdAt,
          type: MemoryEventType.milestone,
          title: threshold == 1
              ? _copy('First reading', 'İlk açılım')
              : _copy('$threshold readings', '$threshold açılım'),
          themes: const {MemoryTheme.growth},
          tags: const {'milestone'},
          sourceId: 'reading-count-$threshold',
        ),
      );
    }
    return milestones;
  }

  MemoryTheme _themeForReading(ReadingKind kind) {
    switch (kind) {
      case ReadingKind.love:
      case ReadingKind.compatibility:
        return MemoryTheme.relationship;
      case ReadingKind.career:
        return MemoryTheme.career;
      case ReadingKind.money:
        return MemoryTheme.finance;
      case ReadingKind.decision:
        return MemoryTheme.decision;
      case ReadingKind.spiritual:
        return MemoryTheme.spirituality;
      case ReadingKind.shadow:
        return MemoryTheme.growth;
      case ReadingKind.timeline:
        return MemoryTheme.growth;
      case ReadingKind.daily:
      case ReadingKind.celticCross:
        return MemoryTheme.general;
    }
  }

  String _copy(String english, String turkish) =>
      mysticText(widget.language, english, turkish);
}

class _SectionSelector extends StatelessWidget {
  const _SectionSelector({
    required this.selected,
    required this.labels,
    required this.onSelected,
  });

  final int selected;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: Semantics(
                button: true,
                selected: selected == index,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: selected == index
                          ? MysticColors.violet.withValues(alpha: .52)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: selected == index
                                ? MysticColors.mist
                                : MysticColors.muted,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView({required this.snapshot, required this.language});

  final MysticMemorySnapshot snapshot;
  final MysticLanguage language;

  @override
  Widget build(BuildContext context) {
    if (snapshot.timeline.isEmpty) {
      return _MemoryEmptyState(
        icon: Icons.auto_stories_outlined,
        title: mysticText(language, 'Your story starts here', 'Hikâyen burada başlıyor'),
        message: mysticText(
          language,
          'Complete a reading or begin a Journey. Mystic will connect the moments privately on this device.',
          'Bir açılım tamamla veya Yolculuk başlat. Mystic anları bu cihazda özel olarak birbirine bağlayacak.',
        ),
      );
    }

    final descending = snapshot.timeline.reversed.toList(growable: false);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
      children: [
        Text(
          mysticText(language, 'Your unfolding story', 'Gelişen hikâyen'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          mysticText(
            language,
            'Readings, reflections, Journeys, and milestones in one private timeline.',
            'Açılımlar, düşünceler, Yolculuklar ve kilometre taşları tek bir özel zaman çizelgesinde.',
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        for (final event in descending) ...[
          _TimelineCard(event: event, language: language),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.event, required this.language});

  final TimelineEvent event;
  final MysticLanguage language;

  @override
  Widget build(BuildContext context) {
    final isMilestone = event.type == MemoryEventType.milestone;
    return Semantics(
      label: '${_eventTypeLabel(event.type, language)}: ${event.title}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isMilestone
                ? [
                    MysticColors.gold.withValues(alpha: .18),
                    MysticColors.night,
                  ]
                : [
                    MysticColors.violet.withValues(alpha: .13),
                    MysticColors.night,
                  ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isMilestone
                ? MysticColors.gold.withValues(alpha: .38)
                : Colors.white.withValues(alpha: .09),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _eventColor(event.type).withValues(alpha: .16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _eventIcon(event.type),
                size: 21,
                color: _eventColor(event.type),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 17,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _dateText(event.occurredAt, language),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _eventTypeLabel(event.type, language),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _eventColor(event.type),
                          fontSize: 11,
                        ),
                  ),
                  if (event.reflection != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      event.reflection!,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: MysticColors.mist,
                          ),
                    ),
                  ],
                  if (event.themes.isNotEmpty) ...[
                    const SizedBox(height: 11),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        for (final theme in event.themes)
                          _SmallPill(
                            label: _themeLabel(theme, language),
                            icon: _themeIcon(theme),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView({
    required this.snapshot,
    required this.now,
    required this.language,
  });

  final MysticMemorySnapshot snapshot;
  final DateTime now;
  final MysticLanguage language;

  @override
  Widget build(BuildContext context) {
    if (snapshot.timeline.isEmpty) {
      return _MemoryEmptyState(
        icon: Icons.insights_outlined,
        title: mysticText(language, 'Insights need history', 'İçgörüler geçmiş ister'),
        message: mysticText(
          language,
          'After a few readings and reflections, transparent patterns will appear here.',
          'Birkaç açılım ve düşünceden sonra şeffaf örüntüler burada görünecek.',
        ),
      );
    }

    final yearEvents = snapshot.timeline
        .where((event) => event.occurredAt.year == now.year)
        .toList(growable: false);
    final yearSnapshot = MysticMemoryEngine.build(
      yearEvents,
      generatedAt: now,
    );
    final strongestConnections = snapshot.themeGraph.connections.take(4);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
      children: [
        Text(
          mysticText(language, 'Patterns, not predictions', 'Kehanet değil, örüntüler'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          mysticText(
            language,
            'Every insight below is calculated locally from your own history.',
            'Aşağıdaki her içgörü kendi geçmişinden, cihazında hesaplanır.',
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                value: '${snapshot.insights.eventCount}',
                label: mysticText(language, 'Moments', 'An'),
                icon: Icons.bubble_chart_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                value: '${snapshot.insights.activeDays}',
                label: mysticText(language, 'Active days', 'Aktif gün'),
                icon: Icons.calendar_month_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                value:
                    '${(snapshot.insights.reflectionRate * 100).round()}%',
                label: mysticText(language, 'Reflected', 'Düşünüldü'),
                icon: Icons.edit_note_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InsightPanel(
          title: '$now'.isEmpty
              ? ''
              : mysticText(
                  language,
                  '${now.year} Review',
                  '${now.year} Özeti',
                ),
          icon: Icons.auto_awesome_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mysticText(
                  language,
                  '${yearSnapshot.insights.eventCount} meaningful moments were recorded this year.',
                  'Bu yıl ${yearSnapshot.insights.eventCount} anlamlı an kaydedildi.',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (yearSnapshot.insights.topThemes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  mysticText(
                    language,
                    'Leading theme: ${_themeLabel(yearSnapshot.insights.topThemes.first.theme, language)}',
                    'Öne çıkan tema: ${_themeLabel(yearSnapshot.insights.topThemes.first.theme, language)}',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InsightPanel(
          title: mysticText(language, 'Top themes', 'Öne çıkan temalar'),
          icon: Icons.interests_outlined,
          child: snapshot.insights.topThemes.isEmpty
              ? Text(mysticText(language, 'Not enough history yet.', 'Henüz yeterli geçmiş yok.'))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in snapshot.insights.topThemes)
                      _CountPill(
                        label: _themeLabel(item.theme, language),
                        count: item.count,
                        icon: _themeIcon(item.theme),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        _InsightPanel(
          title: mysticText(language, 'Memory Map', 'Hafıza Haritası'),
          icon: Icons.hub_outlined,
          child: strongestConnections.isEmpty
              ? Text(
                  mysticText(
                    language,
                    'Themes will connect after they appear together.',
                    'Temalar birlikte göründükçe birbirine bağlanacak.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : Column(
                  children: [
                    for (final connection in strongestConnections)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _themeLabel(connection.first, language),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            const Icon(
                              Icons.link_rounded,
                              size: 18,
                              color: MysticColors.lavender,
                            ),
                            Expanded(
                              child: Text(
                                _themeLabel(connection.second, language),
                                textAlign: TextAlign.end,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '×${connection.weight}',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: MysticColors.gold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        _InsightPanel(
          title: mysticText(language, 'Repeated cards', 'Tekrarlanan kartlar'),
          icon: Icons.style_outlined,
          child: snapshot.insights.repeatedCards.isEmpty
              ? Text(
                  mysticText(
                    language,
                    'No card has repeated enough to form a pattern yet.',
                    'Henüz örüntü oluşturacak kadar tekrarlanan kart yok.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final card in snapshot.insights.repeatedCards)
                      _CountPill(
                        label: card.cardId,
                        count: card.count,
                        icon: Icons.auto_awesome_outlined,
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: MysticColors.gold.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: MysticColors.gold.withValues(alpha: .18),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: MysticColors.gold,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mysticText(
                    language,
                    'Private by design: these insights are descriptive, local, and never claim certainty about your future.',
                    'Tasarım gereği özel: Bu içgörüler betimleyici ve yereldir; geleceğin hakkında kesinlik iddia etmez.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView({
    required this.events,
    required this.language,
    required this.controller,
    required this.onChanged,
  });

  final List<TimelineEvent> events;
  final MysticLanguage language;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final query = controller.text;
    final results = MysticMemorySearch.search(events, query);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
      children: [
        Text(
          mysticText(language, 'Search your story', 'Hikâyende ara'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          mysticText(
            language,
            'Search by meaning, theme, mood, tag, or card.',
            'Anlam, tema, ruh hâli, etiket veya karta göre ara.',
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: mysticText(
              language,
              'Career, exam, love, confidence…',
              'Kariyer, sınav, aşk, özgüven…',
            ),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: mysticText(language, 'Clear', 'Temizle'),
                    onPressed: () {
                      controller.clear();
                      onChanged();
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        if (query.trim().isEmpty) ...[
          Text(
            mysticText(language, 'Try a theme', 'Bir tema dene'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in [
                mysticText(language, 'career', 'kariyer'),
                mysticText(language, 'love', 'aşk'),
                mysticText(language, 'exam', 'sınav'),
                mysticText(language, 'confidence', 'özgüven'),
                mysticText(language, 'money', 'para'),
              ])
                ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    controller.text = suggestion;
                    onChanged();
                  },
                ),
            ],
          ),
          const SizedBox(height: 26),
          _MemoryEmptyState(
            icon: Icons.manage_search_rounded,
            title: mysticText(language, 'Meaning-aware search', 'Anlam odaklı arama'),
            message: mysticText(
              language,
              'For example, “job” can find memories tagged as career even when the exact word was never written.',
              'Örneğin “iş”, tam olarak bu kelime yazılmamış olsa bile kariyer temalı anıları bulabilir.',
            ),
            compact: true,
          ),
        ] else if (results.isEmpty)
          _MemoryEmptyState(
            icon: Icons.search_off_rounded,
            title: mysticText(language, 'No matching memory', 'Eşleşen anı yok'),
            message: mysticText(
              language,
              'Try a broader theme, mood, or card name.',
              'Daha geniş bir tema, ruh hâli veya kart adı dene.',
            ),
            compact: true,
          )
        else ...[
          Text(
            mysticText(
              language,
              '${results.length} result(s)',
              '${results.length} sonuç',
            ),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: MysticColors.lavender,
                ),
          ),
          const SizedBox(height: 12),
          for (final result in results) ...[
            _TimelineCard(event: result.event, language: language),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 19, color: MysticColors.lavender),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: MysticColors.gold,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      );
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: MysticColors.night,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: MysticColors.lavender),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .055),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: MysticColors.lavender),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: MysticColors.mist,
                  ),
            ),
          ],
        ),
      );
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: MysticColors.violet.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: MysticColors.violet.withValues(alpha: .22),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: MysticColors.lavender),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 7),
            Text(
              '$count',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: MysticColors.gold,
                  ),
            ),
          ],
        ),
      );
}

class _MemoryEmptyState extends StatelessWidget {
  const _MemoryEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? 18 : 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 42 : 58, color: MysticColors.lavender),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
}

class _MemoryNotice extends StatelessWidget {
  const _MemoryNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: MysticColors.gold.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: MysticColors.gold,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      );
}

String _eventTypeLabel(MemoryEventType type, MysticLanguage language) {
  switch (type) {
    case MemoryEventType.reading:
      return mysticText(language, 'Reading', 'Açılım');
    case MemoryEventType.reflection:
      return mysticText(language, 'Reflection', 'Düşünce');
    case MemoryEventType.journeyStarted:
      return mysticText(language, 'Journey started', 'Yolculuk başladı');
    case MemoryEventType.journeyUpdated:
      return mysticText(language, 'Journey update', 'Yolculuk güncellemesi');
    case MemoryEventType.journeyCompleted:
      return mysticText(language, 'Journey completed', 'Yolculuk tamamlandı');
    case MemoryEventType.milestone:
      return mysticText(language, 'Milestone', 'Kilometre taşı');
    case MemoryEventType.note:
      return mysticText(language, 'Note', 'Not');
  }
}

IconData _eventIcon(MemoryEventType type) {
  switch (type) {
    case MemoryEventType.reading:
      return Icons.style_rounded;
    case MemoryEventType.reflection:
      return Icons.edit_note_rounded;
    case MemoryEventType.journeyStarted:
      return Icons.flag_outlined;
    case MemoryEventType.journeyUpdated:
      return Icons.route_outlined;
    case MemoryEventType.journeyCompleted:
      return Icons.check_circle_outline_rounded;
    case MemoryEventType.milestone:
      return Icons.emoji_events_outlined;
    case MemoryEventType.note:
      return Icons.notes_rounded;
  }
}

Color _eventColor(MemoryEventType type) =>
    type == MemoryEventType.milestone ? MysticColors.gold : MysticColors.lavender;

String _themeLabel(MemoryTheme theme, MysticLanguage language) {
  switch (theme) {
    case MemoryTheme.relationship:
      return mysticText(language, 'Relationships', 'İlişkiler');
    case MemoryTheme.career:
      return mysticText(language, 'Career', 'Kariyer');
    case MemoryTheme.wellbeing:
      return mysticText(language, 'Wellbeing', 'İyi oluş');
    case MemoryTheme.education:
      return mysticText(language, 'Education', 'Eğitim');
    case MemoryTheme.creativity:
      return mysticText(language, 'Creativity', 'Yaratıcılık');
    case MemoryTheme.confidence:
      return mysticText(language, 'Confidence', 'Özgüven');
    case MemoryTheme.finance:
      return mysticText(language, 'Finance', 'Finans');
    case MemoryTheme.spirituality:
      return mysticText(language, 'Spirituality', 'Maneviyat');
    case MemoryTheme.growth:
      return mysticText(language, 'Growth', 'Gelişim');
    case MemoryTheme.decision:
      return mysticText(language, 'Decisions', 'Kararlar');
    case MemoryTheme.general:
      return mysticText(language, 'General', 'Genel');
  }
}

IconData _themeIcon(MemoryTheme theme) {
  switch (theme) {
    case MemoryTheme.relationship:
      return Icons.favorite_border_rounded;
    case MemoryTheme.career:
      return Icons.work_outline_rounded;
    case MemoryTheme.wellbeing:
      return Icons.spa_outlined;
    case MemoryTheme.education:
      return Icons.school_outlined;
    case MemoryTheme.creativity:
      return Icons.palette_outlined;
    case MemoryTheme.confidence:
      return Icons.bolt_outlined;
    case MemoryTheme.finance:
      return Icons.account_balance_wallet_outlined;
    case MemoryTheme.spirituality:
      return Icons.nightlight_outlined;
    case MemoryTheme.growth:
      return Icons.eco_outlined;
    case MemoryTheme.decision:
      return Icons.alt_route_rounded;
    case MemoryTheme.general:
      return Icons.auto_awesome_outlined;
  }
}

String _dateText(DateTime value, MysticLanguage language) {
  const englishMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const turkishMonths = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];
  final months =
      language == MysticLanguage.turkish ? turkishMonths : englishMonths;
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}
