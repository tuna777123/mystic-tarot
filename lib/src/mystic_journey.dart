enum JourneyArea {
  relationship,
  career,
  wellbeing,
  education,
  creativity,
  confidence,
  custom,
}

enum JourneyStatus { active, paused, completed, archived }

class JourneyEntry {
  const JourneyEntry({
    required this.id,
    required this.createdAt,
    required this.title,
    this.readingId,
    this.reflection,
    this.mood,
    this.tags = const <String>{},
  });

  final String id;
  final DateTime createdAt;
  final String title;
  final String? readingId;
  final String? reflection;
  final String? mood;
  final Set<String> tags;

  bool get hasReflection => reflection?.trim().isNotEmpty ?? false;
}

class MysticJourney {
  const MysticJourney({
    required this.id,
    required this.title,
    required this.area,
    required this.createdAt,
    this.status = JourneyStatus.active,
    this.intention,
    this.targetDate,
    this.entries = const <JourneyEntry>[],
  });

  final String id;
  final String title;
  final JourneyArea area;
  final DateTime createdAt;
  final JourneyStatus status;
  final String? intention;
  final DateTime? targetDate;
  final List<JourneyEntry> entries;

  bool get canAcceptEntries =>
      status == JourneyStatus.active || status == JourneyStatus.paused;

  int get reflectionCount =>
      entries.where((entry) => entry.hasReflection).length;

  double get reflectionRate =>
      entries.isEmpty ? 0 : reflectionCount / entries.length;

  DateTime? get lastActivityAt {
    if (entries.isEmpty) return null;
    return entries
        .map((entry) => entry.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  MysticJourney addEntry(JourneyEntry entry) {
    if (!canAcceptEntries) {
      throw StateError('Completed or archived journeys cannot accept entries.');
    }
    if (entry.id.trim().isEmpty) {
      throw ArgumentError.value(entry.id, 'entry.id', 'must not be empty');
    }
    if (entries.any((existing) => existing.id == entry.id)) {
      throw StateError('Journey entry ids must be unique.');
    }

    final nextEntries = [...entries, entry]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return copyWith(entries: List.unmodifiable(nextEntries));
  }

  MysticJourney copyWith({
    String? title,
    JourneyArea? area,
    JourneyStatus? status,
    String? intention,
    DateTime? targetDate,
    List<JourneyEntry>? entries,
  }) {
    return MysticJourney(
      id: id,
      title: title ?? this.title,
      area: area ?? this.area,
      createdAt: createdAt,
      status: status ?? this.status,
      intention: intention ?? this.intention,
      targetDate: targetDate ?? this.targetDate,
      entries: entries ?? this.entries,
    );
  }
}

class JourneySnapshot {
  const JourneySnapshot({
    required this.entryCount,
    required this.activeDays,
    required this.reflectionRate,
    required this.topTags,
    required this.generatedAt,
  });

  final int entryCount;
  final int activeDays;
  final double reflectionRate;
  final List<String> topTags;
  final DateTime generatedAt;
}

abstract final class JourneyInsights {
  static JourneySnapshot summarize(
    MysticJourney journey, {
    required DateTime generatedAt,
    int tagLimit = 3,
  }) {
    if (tagLimit < 1) {
      throw ArgumentError.value(tagLimit, 'tagLimit', 'must be at least 1');
    }

    final activeDays = journey.entries
        .map((entry) => _dateKey(entry.createdAt))
        .toSet()
        .length;
    final tagCounts = <String, int>{};

    for (final entry in journey.entries) {
      for (final rawTag in entry.tags) {
        final tag = rawTag.trim().toLowerCase();
        if (tag.isEmpty) continue;
        tagCounts.update(tag, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });

    return JourneySnapshot(
      entryCount: journey.entries.length,
      activeDays: activeDays,
      reflectionRate: journey.reflectionRate,
      topTags: sortedTags
          .take(tagLimit)
          .map((entry) => entry.key)
          .toList(growable: false),
      generatedAt: generatedAt,
    );
  }

  static String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
