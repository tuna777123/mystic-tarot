import 'mystic_journey.dart';
import 'mystic_memory.dart';
import 'mystic_patterns.dart' as patterns;

/// Converts the app's existing local models into the unified memory timeline.
abstract final class MysticMemoryAdapters {
  static List<TimelineEvent> fromJourney(MysticJourney journey) {
    final theme = _fromJourneyArea(journey.area);
    final events = <TimelineEvent>[
      TimelineEvent(
        id: 'journey:${journey.id}:started',
        occurredAt: journey.createdAt,
        type: MemoryEventType.journeyStarted,
        title: journey.title,
        reflection: journey.intention,
        themes: {theme},
        journeyId: journey.id,
        sourceId: journey.id,
      ),
    ];

    for (final entry in journey.entries) {
      events.add(
        TimelineEvent(
          id: 'journey:${journey.id}:entry:${entry.id}',
          occurredAt: entry.createdAt,
          type: entry.readingId == null
              ? MemoryEventType.reflection
              : MemoryEventType.reading,
          title: entry.title,
          reflection: entry.reflection,
          themes: {theme},
          tags: entry.tags,
          mood: entry.mood,
          journeyId: journey.id,
          sourceId: entry.readingId ?? entry.id,
        ),
      );
    }

    if (journey.status == JourneyStatus.completed) {
      events.add(
        TimelineEvent(
          id: 'journey:${journey.id}:completed',
          occurredAt: journey.lastActivityAt ?? journey.createdAt,
          type: MemoryEventType.journeyCompleted,
          title: '${journey.title} completed',
          themes: {theme},
          journeyId: journey.id,
          sourceId: journey.id,
        ),
      );
    }

    return List.unmodifiable(events);
  }

  static TimelineEvent fromPatternReading(patterns.PatternReading reading) {
    return TimelineEvent(
      id: 'reading:${reading.id}',
      occurredAt: reading.createdAt,
      type: MemoryEventType.reading,
      title: 'Tarot reading',
      reflection: reading.reflection,
      themes: {_fromReadingTheme(reading.theme)},
      cardIds: reading.cardIds,
      mood: reading.mood,
      sourceId: reading.id,
    );
  }

  static List<TimelineEvent> combine({
    Iterable<patterns.PatternReading> readings =
        const <patterns.PatternReading>[],
    Iterable<MysticJourney> journeys = const <MysticJourney>[],
  }) {
    final events = <TimelineEvent>[
      ...readings.map(fromPatternReading),
      ...journeys.expand(fromJourney),
    ];
    events.sort((a, b) {
      final byDate = a.occurredAt.compareTo(b.occurredAt);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return List.unmodifiable(events);
  }

  static MemoryTheme _fromJourneyArea(JourneyArea area) {
    switch (area) {
      case JourneyArea.relationship:
        return MemoryTheme.relationship;
      case JourneyArea.career:
        return MemoryTheme.career;
      case JourneyArea.wellbeing:
        return MemoryTheme.wellbeing;
      case JourneyArea.education:
        return MemoryTheme.education;
      case JourneyArea.creativity:
        return MemoryTheme.creativity;
      case JourneyArea.confidence:
        return MemoryTheme.confidence;
      case JourneyArea.custom:
        return MemoryTheme.general;
    }
  }

  static MemoryTheme _fromReadingTheme(patterns.ReadingTheme theme) {
    switch (theme) {
      case patterns.ReadingTheme.love:
        return MemoryTheme.relationship;
      case patterns.ReadingTheme.career:
        return MemoryTheme.career;
      case patterns.ReadingTheme.wellbeing:
        return MemoryTheme.wellbeing;
      case patterns.ReadingTheme.growth:
        return MemoryTheme.growth;
      case patterns.ReadingTheme.decision:
        return MemoryTheme.decision;
      case patterns.ReadingTheme.general:
        return MemoryTheme.general;
    }
  }
}
