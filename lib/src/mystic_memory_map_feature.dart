import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'flagship.dart';
import 'models.dart';
import 'tarot_localization.dart';
import 'theme.dart';

class MysticMemoryMapFeature extends StatefulWidget {
  const MysticMemoryMapFeature({
    required this.records,
    required this.language,
    super.key,
  });

  final List<ReadingRecord> records;
  final MysticLanguage language;

  @override
  State<MysticMemoryMapFeature> createState() =>
      _MysticMemoryMapFeatureState();
}

class _MysticMemoryMapFeatureState extends State<MysticMemoryMapFeature> {
  _MemoryTheme? selectedTheme;
  String query = '';

  bool get _isTurkish => widget.language == MysticLanguage.turkish;

  String _copy(String english, String turkish) =>
      _isTurkish ? turkish : english;

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return Center(
        key: const ValueKey<String>('memory-map-empty'),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hub_outlined,
                  size: 52, color: MysticColors.gold),
              const SizedBox(height: 14),
              Text(
                _copy('Your memory map is waiting.',
                    'Hafıza haritan seni bekliyor.'),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                _copy(
                  'Complete readings to reveal the themes connecting your story.',
                  'Hikâyeni birbirine bağlayan temaları görmek için okumalar tamamla.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: MysticColors.mist),
              ),
            ],
          ),
        ),
      );
    }

    final graph = _MemoryGraph.fromRecords(widget.records);
    final searchResults = _semanticSearch(widget.records, query);

    return ListView(
      key: const ValueKey<String>('memory-map'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      children: [
        _buildIntroCard(),
        const SizedBox(height: 12),
        _buildGraphCard(graph),
        const SizedBox(height: 12),
        if (selectedTheme != null) _buildThemeDetail(graph, selectedTheme!),
        if (selectedTheme != null) const SizedBox(height: 12),
        _buildSearchCard(searchResults),
      ],
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF32204D), Color(0xFF171020)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: MysticColors.gold),
          const SizedBox(height: 10),
          Text(
            _copy('Your patterns, connected.', 'Örüntülerin birbirine bağlı.'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            _copy(
              'Tap a theme to see which readings and emotions are shaping it. Connections grow stronger when themes return together.',
              'Bir temaya dokunarak onu hangi okumaların ve duyguların şekillendirdiğini gör. Temalar birlikte tekrarlandıkça bağlantılar güçlenir.',
            ),
            style: const TextStyle(color: MysticColors.mist, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard(_MemoryGraph graph) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151120),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _copy('Memory Map', 'Hafıza Haritası'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _copy('${graph.nodes.length} themes',
                    '${graph.nodes.length} tema'),
                style: const TextStyle(
                  color: MysticColors.lavender,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 310,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final positions = _positionsFor(graph.nodes, constraints.biggest);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MemoryConnectionsPainter(
                          graph: graph,
                          positions: positions,
                          selectedTheme: selectedTheme,
                        ),
                      ),
                    ),
                    for (final node in graph.nodes)
                      _buildNode(node, positions[node.theme]!),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _copy(
              'Node size shows frequency. Line strength shows how often themes appeared together.',
              'Düğüm boyutu sıklığı, çizgi gücü temaların birlikte kaç kez göründüğünü gösterir.',
            ),
            style: const TextStyle(color: MysticColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Map<_MemoryTheme, Offset> _positionsFor(
    List<_MemoryNode> nodes,
    Size size,
  ) {
    final result = <_MemoryTheme, Offset>{};
    final center = Offset(size.width / 2, size.height / 2);
    final radiusX = math.max(70.0, size.width * .34);
    final radiusY = math.max(82.0, size.height * .34);
    for (var index = 0; index < nodes.length; index++) {
      final angle = (-math.pi / 2) + (2 * math.pi * index / nodes.length);
      result[nodes[index].theme] = Offset(
        center.dx + math.cos(angle) * radiusX,
        center.dy + math.sin(angle) * radiusY,
      );
    }
    return result;
  }

  Widget _buildNode(_MemoryNode node, Offset position) {
    final selected = selectedTheme == node.theme;
    final diameter = 44.0 + math.min(node.count, 6) * 5.0;
    return Positioned(
      left: position.dx - diameter / 2,
      top: position.dy - diameter / 2,
      child: Semantics(
        button: true,
        label: '${_themeLabel(node.theme)} ${node.count}',
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedTheme = selected ? null : node.theme;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: diameter,
            height: diameter,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? MysticColors.gold
                  : MysticColors.violet.withValues(alpha: .88),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: .8)
                    : MysticColors.lavender.withValues(alpha: .44),
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (selected ? MysticColors.gold : MysticColors.violet)
                      .withValues(alpha: .28),
                  blurRadius: selected ? 20 : 10,
                ),
              ],
            ),
            child: Text(
              _themeLabel(node.theme),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? const Color(0xFF1B1027) : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeDetail(_MemoryGraph graph, _MemoryTheme theme) {
    final relatedRecords = widget.records
        .where((record) => _themeFor(record.kind) == theme)
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final strongest = graph.connections
        .where((connection) => connection.includes(theme))
        .toList(growable: false)
      ..sort((a, b) => b.weight.compareTo(a.weight));

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1426),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 12, color: MysticColors.gold),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _themeLabel(theme),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _copy('${relatedRecords.length} readings',
                    '${relatedRecords.length} okuma'),
                style: const TextStyle(color: MysticColors.lavender),
              ),
            ],
          ),
          if (strongest.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _copy('Strongest connection', 'En güçlü bağlantı'),
              style: const TextStyle(
                color: MysticColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${_themeLabel(strongest.first.other(theme))} · ${strongest.first.weight}×',
              style: const TextStyle(
                color: MysticColors.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...relatedRecords.take(3).map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.kind.symbol,
                          style: const TextStyle(color: MysticColors.gold)),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          record.question.trim().isEmpty
                              ? localizedReadingKindTitle(
                                  record.kind,
                                  turkish: _isTurkish,
                                )
                              : record.question,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: MysticColors.mist),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(List<_ScoredRecord> results) {
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
            _copy('Search by meaning', 'Anlama göre ara'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            _copy(
              'Try “love”, “money”, “anxious”, “change” or their Turkish equivalents.',
              '“Aşk”, “para”, “kaygı”, “değişim” ya da İngilizce karşılıklarını dene.',
            ),
            style: const TextStyle(color: MysticColors.mist, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => query = value.trim()),
            decoration: InputDecoration(
              hintText: _copy(
                'What were you moving through?',
                'Hangi süreçten geçiyordun?',
              ),
              prefixIcon: const Icon(Icons.manage_search),
            ),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 14),
            if (results.isEmpty)
              Text(
                _copy('No connected memory found yet.',
                    'Henüz bağlantılı bir anı bulunamadı.'),
                style: const TextStyle(color: MysticColors.mist),
              )
            else
              ...results.take(5).map(_buildSearchResult),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResult(_ScoredRecord result) {
    final record = result.record;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .035),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(record.kind.symbol,
              style: const TextStyle(color: MysticColors.gold, fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.question.trim().isEmpty
                      ? localizedReadingKindTitle(
                          record.kind,
                          turkish: _isTurkish,
                        )
                      : record.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_themeLabel(_themeFor(record.kind))} · ${localizedEmotionLabel(record.emotion, turkish: _isTurkish)}',
                  style: const TextStyle(
                    color: MysticColors.lavender,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${result.score}',
            style: const TextStyle(
              color: MysticColors.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  List<_ScoredRecord> _semanticSearch(
    List<ReadingRecord> records,
    String rawQuery,
  ) {
    final normalized = _normalize(rawQuery);
    if (normalized.isEmpty) return const <_ScoredRecord>[];
    final terms = normalized.split(' ').where((term) => term.isNotEmpty).toSet();
    final expandedTerms = <String>{...terms};
    for (final entry in _semanticAliases.entries) {
      if (entry.value.any(terms.contains)) {
        expandedTerms.addAll(entry.value);
      }
    }

    final results = <_ScoredRecord>[];
    for (final record in records) {
      final title = _normalize(record.kind.title);
      final localizedTitle = _normalize(
        localizedReadingKindTitle(record.kind, turkish: _isTurkish),
      );
      final question = _normalize(record.question);
      final emotion = _normalize(record.emotion.label);
      final localizedEmotion = _normalize(
        localizedEmotionLabel(record.emotion, turkish: _isTurkish),
      );
      final action = _normalize(record.alignedAction);
      final cards = record.cards.map((drawn) => _normalize(drawn.card.name));
      final themeTerms = _semanticAliases[_themeFor(record.kind).name] ?? const <String>{};
      var score = 0;

      for (final term in expandedTerms) {
        if (question.contains(term)) score += 8;
        if (title.contains(term) || localizedTitle.contains(term)) score += 6;
        if (action.contains(term)) score += 5;
        if (emotion.contains(term) || localizedEmotion.contains(term)) {
          score += 5;
        }
        if (cards.any((card) => card.contains(term))) score += 4;
        if (themeTerms.contains(term)) score += 7;
      }

      if (score > 0) results.add(_ScoredRecord(record, score));
    }

    results.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0
          ? byScore
          : b.record.createdAt.compareTo(a.record.createdAt);
    });
    return results;
  }

  String _themeLabel(_MemoryTheme theme) => switch (theme) {
        _MemoryTheme.daily => _copy('Daily', 'Günlük'),
        _MemoryTheme.relationship => _copy('Love', 'Aşk'),
        _MemoryTheme.career => _copy('Career', 'Kariyer'),
        _MemoryTheme.finance => _copy('Money', 'Para'),
        _MemoryTheme.decision => _copy('Decision', 'Karar'),
        _MemoryTheme.spirituality => _copy('Spirit', 'Ruh'),
        _MemoryTheme.shadow => _copy('Shadow', 'Gölge'),
        _MemoryTheme.future => _copy('Future', 'Gelecek'),
      };
}

enum _MemoryTheme {
  daily,
  relationship,
  career,
  finance,
  decision,
  spirituality,
  shadow,
  future,
}

_MemoryTheme _themeFor(ReadingKind kind) => switch (kind) {
      ReadingKind.daily => _MemoryTheme.daily,
      ReadingKind.love || ReadingKind.compatibility => _MemoryTheme.relationship,
      ReadingKind.career => _MemoryTheme.career,
      ReadingKind.money => _MemoryTheme.finance,
      ReadingKind.decision => _MemoryTheme.decision,
      ReadingKind.spiritual => _MemoryTheme.spirituality,
      ReadingKind.shadow => _MemoryTheme.shadow,
      ReadingKind.timeline || ReadingKind.celticCross => _MemoryTheme.future,
    };

class _MemoryNode {
  const _MemoryNode(this.theme, this.count);

  final _MemoryTheme theme;
  final int count;
}

class _MemoryConnection {
  const _MemoryConnection(this.first, this.second, this.weight);

  final _MemoryTheme first;
  final _MemoryTheme second;
  final int weight;

  bool includes(_MemoryTheme theme) => first == theme || second == theme;

  _MemoryTheme other(_MemoryTheme theme) => first == theme ? second : first;
}

class _MemoryGraph {
  const _MemoryGraph(this.nodes, this.connections);

  final List<_MemoryNode> nodes;
  final List<_MemoryConnection> connections;

  factory _MemoryGraph.fromRecords(List<ReadingRecord> records) {
    final counts = <_MemoryTheme, int>{};
    final pairCounts = <String, int>{};

    for (final record in records) {
      final primary = _themeFor(record.kind);
      counts.update(primary, (value) => value + 1, ifAbsent: () => 1);

      final secondary = _secondaryTheme(record);
      if (secondary != primary) {
        counts.update(secondary, (value) => value + 1, ifAbsent: () => 1);
        final ordered = [primary, secondary]..sort((a, b) => a.index.compareTo(b.index));
        final key = '${ordered.first.index}:${ordered.last.index}';
        pairCounts.update(key, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    final nodes = counts.entries
        .map((entry) => _MemoryNode(entry.key, entry.value))
        .toList(growable: false)
      ..sort((a, b) => b.count.compareTo(a.count));

    final connections = <_MemoryConnection>[];
    for (final entry in pairCounts.entries) {
      final parts = entry.key.split(':').map(int.parse).toList();
      connections.add(_MemoryConnection(
        _MemoryTheme.values[parts.first],
        _MemoryTheme.values[parts.last],
        entry.value,
      ));
    }
    return _MemoryGraph(nodes, connections);
  }

  static _MemoryTheme _secondaryTheme(ReadingRecord record) {
    final text = _normalize('${record.question} ${record.alignedAction}');
    for (final entry in _semanticAliases.entries) {
      if (entry.value.any(text.contains)) {
        final match = _MemoryTheme.values.where((theme) => theme.name == entry.key);
        if (match.isNotEmpty) return match.first;
      }
    }
    return _themeFor(record.kind);
  }
}

class _ScoredRecord {
  const _ScoredRecord(this.record, this.score);

  final ReadingRecord record;
  final int score;
}

class _MemoryConnectionsPainter extends CustomPainter {
  const _MemoryConnectionsPainter({
    required this.graph,
    required this.positions,
    required this.selectedTheme,
  });

  final _MemoryGraph graph;
  final Map<_MemoryTheme, Offset> positions;
  final _MemoryTheme? selectedTheme;

  @override
  void paint(Canvas canvas, Size size) {
    for (final connection in graph.connections) {
      final start = positions[connection.first];
      final end = positions[connection.second];
      if (start == null || end == null) continue;
      final highlighted = selectedTheme == null || connection.includes(selectedTheme!);
      final paint = Paint()
        ..color = MysticColors.lavender.withValues(
          alpha: highlighted ? .18 + math.min(connection.weight, 4) * .08 : .05,
        )
        ..strokeWidth = highlighted ? 1.2 + connection.weight : .8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MemoryConnectionsPainter oldDelegate) {
    return oldDelegate.selectedTheme != selectedTheme ||
        oldDelegate.graph != graph ||
        oldDelegate.positions != positions;
  }
}

String _normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

const Map<String, Set<String>> _semanticAliases = {
  'relationship': {
    'love', 'relationship', 'partner', 'dating', 'heart',
    'ask', 'iliski', 'sevgili', 'kalp',
  },
  'career': {
    'career', 'work', 'job', 'boss', 'success',
    'kariyer', 'is', 'mudur', 'basari',
  },
  'finance': {
    'money', 'finance', 'budget', 'salary', 'income',
    'para', 'butce', 'maas', 'gelir',
  },
  'decision': {
    'decision', 'choice', 'option', 'direction',
    'karar', 'secim', 'yon',
  },
  'spirituality': {
    'spirit', 'meaning', 'soul', 'purpose', 'faith',
    'ruh', 'anlam', 'amac', 'inanc',
  },
  'shadow': {
    'shadow', 'fear', 'anxious', 'anxiety', 'healing',
    'golge', 'korku', 'kaygi', 'iyilesme',
  },
  'future': {
    'future', 'change', 'growth', 'next', 'possibility',
    'gelecek', 'degisim', 'gelisim', 'sonraki', 'ihtimal',
  },
  'daily': {
    'daily', 'today', 'energy', 'guidance',
    'gunluk', 'bugun', 'enerji', 'rehberlik',
  },
};
