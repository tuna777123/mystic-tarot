import 'package:flutter/material.dart';

import 'app_language.dart';
import 'models.dart';
import 'theme.dart';

class MysticLivingJournalFeature extends StatefulWidget {
  const MysticLivingJournalFeature({
    required this.records,
    required this.language,
    required this.onPremium,
    super.key,
  });

  final List<ReadingRecord> records;
  final MysticLanguage language;
  final VoidCallback onPremium;

  @override
  State<MysticLivingJournalFeature> createState() =>
      _MysticLivingJournalFeatureState();
}

class _MysticLivingJournalFeatureState
    extends State<MysticLivingJournalFeature> {
  int section = 0;
  String query = '';

  bool get isTurkish => widget.language == MysticLanguage.turkish;
  String copy(String en, String tr) => isTurkish ? tr : en;

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF171027), Color(0xFF080711)],
            ),
          ),
          child: Column(
            children: [
              _header(context),
              _sectionPicker(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: switch (section) {
                    0 => _timeline(records),
                    1 => _insights(),
                    _ => _search(records),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy('LIVING JOURNAL', 'YAŞAYAN GÜNLÜK'),
                    style: const TextStyle(
                      color: MysticColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    copy('Your story remembers.', 'Hikâyen seni hatırlıyor.'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    copy(
                      'See what returns, what shifts, and what asks for your attention.',
                      'Tekrar edenleri, değişenleri ve dikkat isteyenleri gör.',
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: MysticColors.mist),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: MysticColors.violet.withValues(alpha: .24),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MysticColors.lavender.withValues(alpha: .24),
                ),
              ),
              child: Text(
                '${widget.records.length}',
                style: const TextStyle(
                  color: MysticColors.gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _sectionPicker() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SegmentedButton<int>(
          segments: [
            ButtonSegment(
              value: 0,
              icon: const Icon(Icons.timeline, size: 17),
              label: Text(copy('Timeline', 'Zaman')), 
            ),
            ButtonSegment(
              value: 1,
              icon: const Icon(Icons.auto_graph, size: 17),
              label: Text(copy('Insights', 'İçgörü')),
            ),
            ButtonSegment(
              value: 2,
              icon: const Icon(Icons.search, size: 17),
              label: Text(copy('Search', 'Ara')),
            ),
          ],
          selected: {section},
          onSelectionChanged: (value) => setState(() => section = value.first),
          showSelectedIcon: false,
        ),
      );

  Widget _timeline(List<ReadingRecord> records) {
    if (records.isEmpty) return _emptyState();
    return ListView.separated(
      key: const ValueKey('timeline'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _recordCard(context, records[index]),
    );
  }

  Widget _recordCard(BuildContext context, ReadingRecord record) {
    final cardNames = record.cards.map((item) => item.card.name).join(' · ');
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
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MysticColors.violet.withValues(alpha: .28),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text('✦', style: TextStyle(color: MysticColors.gold)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kindLabel(record.kind),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _date(record.createdAt),
                      style: const TextStyle(
                        color: MysticColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (record.question.trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            Text(
              record.question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 11),
          Text(
            cardNames,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MysticColors.lavender,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (record.alignedAction.trim().isNotEmpty) ...[
            const SizedBox(height: 11),
            Text(
              record.alignedAction,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: MysticColors.mist),
            ),
          ],
        ],
      ),
    );
  }

  Widget _insights() {
    final records = widget.records;
    if (records.isEmpty) return _emptyState();
    final cardCounts = <String, int>{};
    for (final record in records) {
      for (final drawn in record.cards) {
        cardCounts.update(drawn.card.name, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    final ranked = cardCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.take(3).toList();
    final last30 = records
        .where((r) => DateTime.now().difference(r.createdAt).inDays <= 30)
        .length;

    return ListView(
      key: const ValueKey('insights'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      children: [
        Row(
          children: [
            Expanded(child: _metric(copy('Total readings', 'Toplam okuma'), '${records.length}')),
            const SizedBox(width: 10),
            Expanded(child: _metric(copy('Last 30 days', 'Son 30 gün'), '$last30')),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
                copy('Cards returning to you', 'Sana dönen kartlar'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              ...top.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: Row(
                      children: [
                        const Text('✦', style: TextStyle(color: MysticColors.gold)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(entry.key)),
                        Text(
                          '${entry.value}×',
                          style: const TextStyle(
                            color: MysticColors.lavender,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _premiumInsightCard(),
      ],
    );
  }

  Widget _metric(String label, String value) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151120),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: MysticColors.gold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: MysticColors.mist, fontSize: 12)),
          ],
        ),
      );

  Widget _premiumInsightCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF4B2E72), Color(0xFF21152F)]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_open_rounded, color: MysticColors.gold),
            const SizedBox(height: 10),
            Text(
              copy('Unlock your full pattern map', 'Tüm örüntü haritanı aç'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(
              copy(
                'See emotional cycles, repeating themes, yearly review, and deeper memory connections.',
                'Duygusal döngüleri, tekrar eden temaları, yıllık özeti ve derin hafıza bağlantılarını gör.',
              ),
              style: const TextStyle(color: MysticColors.mist),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: widget.onPremium,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(copy('Explore Premium', 'Premium’u keşfet')),
            ),
          ],
        ),
      );

  Widget _search(List<ReadingRecord> records) => Column(
        key: const ValueKey('search'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              onChanged: (value) => setState(() => query = value.trim()),
              decoration: InputDecoration(
                hintText: copy('Search cards, questions, actions…', 'Kart, soru veya eylem ara…'),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(child: _timeline(records)),
        ],
      );

  List<ReadingRecord> get _filteredRecords {
    if (query.isEmpty) return widget.records;
    final normalized = query.toLowerCase();
    return widget.records.where((record) {
      final haystack = [
        record.question,
        record.alignedAction,
        ...record.cards.map((item) => item.card.name),
      ].join(' ').toLowerCase();
      return haystack.contains(normalized);
    }).toList();
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('☾', style: TextStyle(fontSize: 50, color: MysticColors.gold)),
              const SizedBox(height: 14),
              Text(
                copy('Your journal is waiting.', 'Günlüğün seni bekliyor.'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                copy(
                  'Complete a reading and your timeline will begin to remember what matters.',
                  'Bir okuma tamamla; zaman çizgin önemli olanları hatırlamaya başlasın.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: MysticColors.mist),
              ),
            ],
          ),
        ),
      );

  String _kindLabel(ReadingKind kind) => switch (kind) {
        ReadingKind.daily => copy('Daily Reading', 'Günlük Okuma'),
        _ => kind.name
            .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
            .trim(),
      };

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}
