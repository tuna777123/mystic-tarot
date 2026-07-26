enum MemoryEventType {
  reading,
  reflection,
  journeyStarted,
  journeyUpdated,
  journeyCompleted,
  milestone,
  note,
}

enum MemoryTheme {
  relationship,
  career,
  wellbeing,
  education,
  creativity,
  confidence,
  finance,
  spirituality,
  growth,
  decision,
  general,
}

class TimelineEvent {
  TimelineEvent({
    required String id,
    required this.occurredAt,
    required this.type,
    required String title,
    String? reflection,
    Iterable<MemoryTheme> themes = const <MemoryTheme>{},
    Iterable<String> tags = const <String>{},
    Iterable<String> cardIds = const <String>[],
    String? mood,
    String? journeyId,
    String? sourceId,
  })  : id = _requiredText(id, 'id'),
        title = _requiredText(title, 'title'),
        reflection = _optionalText(reflection),
        themes = Set.unmodifiable(themes),
        tags = Set.unmodifiable(_normalizedStrings(tags, lowercase: true)),
        cardIds = List.unmodifiable(_normalizedStrings(cardIds)),
        mood = _optionalText(mood),
        journeyId = _optionalText(journeyId),
        sourceId = _optionalText(sourceId);

  final String id;
  final DateTime occurredAt;
  final MemoryEventType type;
  final String title;
  final String? reflection;
  final Set<MemoryTheme> themes;
  final Set<String> tags;
  final List<String> cardIds;
  final String? mood;
  final String? journeyId;
  final String? sourceId;

  bool get hasReflection => reflection != null;
}

class ThemeFrequency {
  const ThemeFrequency({required this.theme, required this.count});

  final MemoryTheme theme;
  final int count;
}

class CardOccurrence {
  const CardOccurrence({required this.cardId, required this.count});

  final String cardId;
  final int count;
}

class ThemeNode {
  const ThemeNode({required this.theme, required this.eventCount});

  final MemoryTheme theme;
  final int eventCount;
}

class ThemeConnection {
  const ThemeConnection({
    required this.first,
    required this.second,
    required this.weight,
    required this.sharedEventIds,
  });

  final MemoryTheme first;
  final MemoryTheme second;
  final int weight;
  final List<String> sharedEventIds;
}

class ThemeGraph {
  const ThemeGraph({required this.nodes, required this.connections});

  final List<ThemeNode> nodes;
  final List<ThemeConnection> connections;

  ThemeConnection? connectionBetween(MemoryTheme first, MemoryTheme second) {
    for (final connection in connections) {
      final direct = connection.first == first && connection.second == second;
      final reverse = connection.first == second && connection.second == first;
      if (direct || reverse) return connection;
    }
    return null;
  }
}

class InsightCache {
  const InsightCache({
    required this.eventCount,
    required this.activeDays,
    required this.reflectionRate,
    required this.topThemes,
    required this.repeatedCards,
    required this.generatedAt,
    required this.sourceFingerprint,
  });

  final int eventCount;
  final int activeDays;
  final double reflectionRate;
  final List<ThemeFrequency> topThemes;
  final List<CardOccurrence> repeatedCards;
  final DateTime generatedAt;
  final String sourceFingerprint;

  bool matches(Iterable<TimelineEvent> events) =>
      sourceFingerprint == MysticMemoryEngine.fingerprint(events);
}

class MysticMemorySnapshot {
  const MysticMemorySnapshot({
    required this.timeline,
    required this.themeGraph,
    required this.insights,
  });

  final List<TimelineEvent> timeline;
  final ThemeGraph themeGraph;
  final InsightCache insights;
}

/// Builds explainable, local-first memory summaries from user-owned events.
///
/// The engine reports transparent counts and connections. It does not diagnose,
/// predict outcomes, or silently transmit journal content.
abstract final class MysticMemoryEngine {
  static MysticMemorySnapshot build(
    Iterable<TimelineEvent> events, {
    required DateTime generatedAt,
    int topLimit = 5,
  }) {
    if (topLimit < 1) {
      throw ArgumentError.value(topLimit, 'topLimit', 'must be at least 1');
    }

    final timeline = events.toList(growable: false);
    final ids = <String>{};
    for (final event in timeline) {
      if (!ids.add(event.id)) {
        throw StateError('Timeline event ids must be unique.');
      }
    }
    timeline.sort((a, b) {
      final byDate = a.occurredAt.compareTo(b.occurredAt);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });

    final themeCounts = <MemoryTheme, int>{};
    final cardCounts = <String, int>{};
    final activeDays = <String>{};
    final connections = <String, _ConnectionAccumulator>{};
    var reflected = 0;

    for (final event in timeline) {
      activeDays.add(_dateKey(event.occurredAt));
      if (event.hasReflection) reflected++;

      final orderedThemes = event.themes.toList(growable: false)
        ..sort((a, b) => a.index.compareTo(b.index));
      for (final theme in orderedThemes) {
        themeCounts.update(theme, (count) => count + 1, ifAbsent: () => 1);
      }
      for (var firstIndex = 0;
          firstIndex < orderedThemes.length;
          firstIndex++) {
        for (var secondIndex = firstIndex + 1;
            secondIndex < orderedThemes.length;
            secondIndex++) {
          final first = orderedThemes[firstIndex];
          final second = orderedThemes[secondIndex];
          final key = '${first.index}:${second.index}';
          connections
              .putIfAbsent(
                key,
                () => _ConnectionAccumulator(first: first, second: second),
              )
              .eventIds
              .add(event.id);
        }
      }

      for (final cardId in event.cardIds.toSet()) {
        cardCounts.update(cardId, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    final nodes = themeCounts.entries
        .map(
          (entry) => ThemeNode(theme: entry.key, eventCount: entry.value),
        )
        .toList(growable: false)
      ..sort((a, b) {
        final byCount = b.eventCount.compareTo(a.eventCount);
        return byCount != 0
            ? byCount
            : a.theme.index.compareTo(b.theme.index);
      });

    final graphConnections = connections.values
        .map(
          (value) => ThemeConnection(
            first: value.first,
            second: value.second,
            weight: value.eventIds.length,
            sharedEventIds: List.unmodifiable(value.eventIds),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) {
        final byWeight = b.weight.compareTo(a.weight);
        if (byWeight != 0) return byWeight;
        final byFirst = a.first.index.compareTo(b.first.index);
        return byFirst != 0
            ? byFirst
            : a.second.index.compareTo(b.second.index);
      });

    final topThemes = themeCounts.entries
        .map(
          (entry) => ThemeFrequency(theme: entry.key, count: entry.value),
        )
        .toList(growable: false)
      ..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        return byCount != 0
            ? byCount
            : a.theme.index.compareTo(b.theme.index);
      });

    final repeatedCards = cardCounts.entries
        .where((entry) => entry.value > 1)
        .map(
          (entry) => CardOccurrence(cardId: entry.key, count: entry.value),
        )
        .toList(growable: false)
      ..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        return byCount != 0 ? byCount : a.cardId.compareTo(b.cardId);
      });

    return MysticMemorySnapshot(
      timeline: List.unmodifiable(timeline),
      themeGraph: ThemeGraph(
        nodes: List.unmodifiable(nodes),
        connections: List.unmodifiable(graphConnections),
      ),
      insights: InsightCache(
        eventCount: timeline.length,
        activeDays: activeDays.length,
        reflectionRate: timeline.isEmpty ? 0 : reflected / timeline.length,
        topThemes: List.unmodifiable(topThemes.take(topLimit)),
        repeatedCards: List.unmodifiable(repeatedCards.take(topLimit)),
        generatedAt: generatedAt,
        sourceFingerprint: fingerprint(timeline),
      ),
    );
  }

  static String fingerprint(Iterable<TimelineEvent> events) {
    final ordered = events.toList(growable: false)
      ..sort((a, b) => a.id.compareTo(b.id));
    final buffer = StringBuffer('memory-v1|');
    for (final event in ordered) {
      final themes = event.themes.toList(growable: false)
        ..sort((a, b) => a.index.compareTo(b.index));
      buffer
        ..write(event.id)
        ..write('|')
        ..write(event.occurredAt.toUtc().toIso8601String())
        ..write('|')
        ..write(event.type.name)
        ..write('|')
        ..write(themes.map((theme) => theme.name).join(','))
        ..write('|')
        ..write(event.tags.join(','))
        ..write('|')
        ..write(event.cardIds.join(','))
        ..write(';');
    }

    var hash = 0;
    for (final codeUnit in buffer.toString().codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return 'v1-${ordered.length}-${hash.toRadixString(16)}';
  }

  static String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class MemorySearchResult {
  const MemorySearchResult({
    required this.event,
    required this.score,
    required this.matchedTerms,
  });

  final TimelineEvent event;
  final int score;
  final Set<String> matchedTerms;
}

/// Deterministic semantic-style search using transparent theme aliases.
abstract final class MysticMemorySearch {
  static List<MemorySearchResult> search(
    Iterable<TimelineEvent> events,
    String query, {
    int limit = 20,
  }) {
    if (limit < 1) {
      throw ArgumentError.value(limit, 'limit', 'must be at least 1');
    }
    final normalizedQuery = _normalizeSearchText(query);
    if (normalizedQuery.isEmpty) return const <MemorySearchResult>[];

    final terms = normalizedQuery.split(' ').where((term) => term.isNotEmpty);
    final termSet = terms.toSet();
    final queryThemes = <MemoryTheme>{};
    for (final entry in _themeAliases.entries) {
      if (entry.value.any(termSet.contains)) queryThemes.add(entry.key);
    }

    final results = <MemorySearchResult>[];
    for (final event in events) {
      final title = _normalizeSearchText(event.title);
      final reflection = _normalizeSearchText(event.reflection ?? '');
      final mood = _normalizeSearchText(event.mood ?? '');
      final tags = event.tags.map(_normalizeSearchText).toSet();
      final cards = event.cardIds.map(_normalizeSearchText).toSet();
      final matched = <String>{};
      var score = 0;

      if (title.contains(normalizedQuery)) score += 10;
      if (reflection.contains(normalizedQuery)) score += 5;

      for (final term in termSet) {
        if (title.contains(term)) {
          score += 6;
          matched.add(term);
        }
        if (reflection.contains(term)) {
          score += 3;
          matched.add(term);
        }
        if (tags.any((tag) => tag == term || tag.contains(term))) {
          score += 5;
          matched.add(term);
        }
        if (cards.any((card) => card == term || card.contains(term))) {
          score += 3;
          matched.add(term);
        }
        if (mood.contains(term)) {
          score += 2;
          matched.add(term);
        }
      }

      for (final theme in queryThemes.intersection(event.themes)) {
        score += 8;
        matched.add(theme.name);
      }

      if (score > 0) {
        results.add(
          MemorySearchResult(
            event: event,
            score: score,
            matchedTerms: Set.unmodifiable(matched),
          ),
        );
      }
    }

    results.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byDate = b.event.occurredAt.compareTo(a.event.occurredAt);
      return byDate != 0 ? byDate : a.event.id.compareTo(b.event.id);
    });
    return List.unmodifiable(results.take(limit));
  }

  static const Map<MemoryTheme, Set<String>> _themeAliases = {
    MemoryTheme.relationship: {
      'relationship',
      'love',
      'partner',
      'dating',
      'ilişki',
      'aşk',
      'sevgili',
    },
    MemoryTheme.career: {
      'career',
      'work',
      'job',
      'salary',
      'boss',
      'kariyer',
      'iş',
      'maaş',
      'müdür',
    },
    MemoryTheme.wellbeing: {
      'wellbeing',
      'health',
      'energy',
      'sağlık',
      'enerji',
    },
    MemoryTheme.education: {
      'education',
      'school',
      'exam',
      'university',
      'eğitim',
      'okul',
      'sınav',
      'üniversite',
    },
    MemoryTheme.creativity: {
      'creativity',
      'art',
      'project',
      'yaratıcılık',
      'sanat',
      'proje',
    },
    MemoryTheme.confidence: {
      'confidence',
      'courage',
      'özgüven',
      'cesaret',
    },
    MemoryTheme.finance: {
      'finance',
      'money',
      'budget',
      'para',
      'bütçe',
    },
    MemoryTheme.spirituality: {
      'spirituality',
      'meaning',
      'spirit',
      'maneviyat',
      'anlam',
    },
    MemoryTheme.growth: {
      'growth',
      'change',
      'learning',
      'gelişim',
      'değişim',
      'öğrenme',
    },
    MemoryTheme.decision: {
      'decision',
      'choice',
      'karar',
      'seçim',
    },
  };
}

class _ConnectionAccumulator {
  _ConnectionAccumulator({required this.first, required this.second});

  final MemoryTheme first;
  final MemoryTheme second;
  final List<String> eventIds = <String>[];
}

String _requiredText(String value, String field) {
  final text = value.trim();
  if (text.isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
  return text;
}

String? _optionalText(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? null : text;
}

List<String> _normalizedStrings(
  Iterable<String> values, {
  bool lowercase = false,
}) {
  final normalized = <String>{};
  for (final raw in values) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    normalized.add(lowercase ? trimmed.toLowerCase() : trimmed);
  }
  final result = normalized.toList(growable: false)..sort();
  return result;
}

String _normalizeSearchText(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9çğıöşü]+'), ' ')
    .trim();
