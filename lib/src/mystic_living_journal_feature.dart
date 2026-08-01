import 'package:flutter/material.dart';

import 'flagship.dart';
import 'models.dart';
import 'mystic_memory_map_feature.dart';
import 'tarot_localization.dart';
import 'theme.dart';

enum _JournalSection { timeline, insights, map, search }

class MysticLivingJournalFeature extends StatefulWidget {
  const MysticLivingJournalFeature({
    required this.records,
    required this.language,
    required this.onPremium,
    this.onStartReading,
    super.key,
  });

  final List<ReadingRecord> records;
  final MysticLanguage language;
  final VoidCallback onPremium;
  final VoidCallback? onStartReading;

  @override
  State<MysticLivingJournalFeature> createState() =>
      _MysticLivingJournalFeatureState();
}

class _MysticLivingJournalFeatureState
    extends State<MysticLivingJournalFeature> {
  _JournalSection section = _JournalSection.timeline;
  String query = '';

  String get _languageCode => widget.language.code;

  String _copy(String english, String turkish) =>
      mysticText(widget.language, english, turkish);

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
                  _copy(
                    'See what returns, what shifts, and what asks for attention.',
                    'Tekrar edenleri, değişenleri ve dikkat isteyenleri gör.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MysticColors.mist,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
  }) {
    if (records.isEmpty) {
      return _buildEmptyState(key: key);
    }

    return ListView.separated(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _buildRecordCard(context, records[index]);
      },
    );
  }

  Widget _buildRecordCard(BuildContext context, ReadingRecord record) {
    final cards = record.cards.map((drawn) {
      final orientation =
          drawn.reversed ? _copy('reversed', 'ters') : _copy('upright', 'düz');
      return '${localizedTarotCardName(drawn.card.name, languageCode: _languageCode)} · $orientation';
    }).join('\n');

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
        ],
      ),
    );
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
        _buildPremiumCard(),
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
                    const Text(
                      '✦',
                      style: TextStyle(color: MysticColors.gold),
                    ),
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

  Widget _buildPremiumCard() {
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
            _copy('Unlock your full pattern map', 'Tüm örüntü haritanı aç'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            _copy(
              'Reveal emotional cycles, repeating themes, yearly reviews, and deeper memory connections.',
              'Duygusal döngüleri, tekrar eden temaları, yıllık özetleri ve derin hafıza bağlantılarını gör.',
            ),
            style: const TextStyle(color: MysticColors.mist),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: widget.onPremium,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(_copy('Explore Premium', 'Premium’u keşfet')),
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

    final normalized = query.toLowerCase();
    return widget.records.where((record) {
      final searchableText = <String>[
        record.kind.title,
        localizedReadingKindTitle(record.kind, languageCode: _languageCode),
        record.question,
        record.emotion.label,
        localizedEmotionLabel(record.emotion, languageCode: _languageCode),
        record.alignedAction,
        ...record.cards.map((drawn) => drawn.card.name),
        ...record.cards.map(
          (drawn) =>
              localizedTarotCardName(drawn.card.name, languageCode: _languageCode),
        ),
      ].join(' ').toLowerCase();
      return searchableText.contains(normalized);
    }).toList();
  }

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
                border: Border.all(color: MysticColors.gold.withValues(alpha: .45)),
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
                border: Border.all(color: MysticColors.lavender.withValues(alpha: .22)),
              ),
              child: Column(
                children: [
                  _emptyPreviewRow(
                    Icons.timeline_rounded,
                    _copy('Your reading timeline', 'Okuma zaman çizgin'),
                    _copy('Every saved reading, in context', 'Her kayıtlı okuma, kendi bağlamında'),
                  ),
                  const Divider(height: 22, color: Colors.white10),
                  _emptyPreviewRow(
                    Icons.auto_graph_rounded,
                    _copy('Recurring patterns', 'Tekrar eden örüntüler'),
                    _copy('Cards and emotions that return', 'Geri dönen kartlar ve duygular'),
                  ),
                  const Divider(height: 22, color: Colors.white10),
                  _emptyPreviewRow(
                    Icons.hub_outlined,
                    _copy('Private memory map', 'Özel hafıza haritası'),
                    _copy('Connections only you can see', 'Yalnızca senin görebileceğin bağlar'),
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
                  label: Text(_copy('Create my first memory', 'İlk anımı oluştur')),
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 3),
                Text(body, style: const TextStyle(color: MysticColors.muted, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.lock_outline_rounded, size: 16, color: MysticColors.lavender),
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
