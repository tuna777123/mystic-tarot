import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/mystic_journey.dart';
import 'package:mystic_tarot/src/mystic_memory.dart';
import 'package:mystic_tarot/src/mystic_memory_adapters.dart';
import 'package:mystic_tarot/src/mystic_patterns.dart';

void main() {
  final day = DateTime.utc(2026, 7, 27);

  TimelineEvent event({
    required String id,
    required DateTime occurredAt,
    MemoryEventType type = MemoryEventType.reading,
    String? reflection,
    Set<MemoryTheme> themes = const {MemoryTheme.career},
    Set<String> tags = const {},
    List<String> cardIds = const [],
    String? mood,
  }) {
    return TimelineEvent(
      id: id,
      occurredAt: occurredAt,
      type: type,
      title: 'Event $id',
      reflection: reflection,
      themes: themes,
      tags: tags,
      cardIds: cardIds,
      mood: mood,
    );
  }

  test('builds a chronological immutable timeline and explainable insights', () {
    final snapshot = MysticMemoryEngine.build(
      [
        event(
          id: 'later',
          occurredAt: day.add(const Duration(days: 1)),
          reflection: 'I feel ready.',
          themes: const {MemoryTheme.career, MemoryTheme.confidence},
          cardIds: const ['the-star', 'the-hermit'],
        ),
        event(
          id: 'early',
          occurredAt: day,
          reflection: 'I need a plan.',
          themes: const {MemoryTheme.career, MemoryTheme.confidence},
          cardIds: const ['the-star'],
        ),
        event(
          id: 'same-day-note',
          occurredAt: day.add(const Duration(hours: 2)),
          type: MemoryEventType.note,
          themes: const {MemoryTheme.education},
        ),
      ],
      generatedAt: day.add(const Duration(days: 2)),
    );

    expect(
      snapshot.timeline.map((item) => item.id),
      ['early', 'same-day-note', 'later'],
    );
    expect(snapshot.insights.eventCount, 3);
    expect(snapshot.insights.activeDays, 2);
    expect(snapshot.insights.reflectionRate, closeTo(2 / 3, 0.0001));
    expect(snapshot.insights.topThemes.first.theme, MemoryTheme.career);
    expect(snapshot.insights.topThemes.first.count, 2);
    expect(snapshot.insights.repeatedCards.single.cardId, 'the-star');
    expect(snapshot.insights.repeatedCards.single.count, 2);
    expect(snapshot.insights.matches(snapshot.timeline), isTrue);
  });

  test('creates weighted theme connections with supporting event ids', () {
    final snapshot = MysticMemoryEngine.build(
      [
        event(
          id: 'one',
          occurredAt: day,
          themes: const {MemoryTheme.career, MemoryTheme.confidence},
        ),
        event(
          id: 'two',
          occurredAt: day.add(const Duration(days: 1)),
          themes: const {MemoryTheme.career, MemoryTheme.confidence},
        ),
      ],
      generatedAt: day,
    );

    final connection = snapshot.themeGraph.connectionBetween(
      MemoryTheme.confidence,
      MemoryTheme.career,
    );

    expect(connection, isNotNull);
    expect(connection!.weight, 2);
    expect(connection.sharedEventIds, ['one', 'two']);
  });

  test('rejects duplicate event ids and invalid limits', () {
    final duplicate = event(id: 'duplicate', occurredAt: day);

    expect(
      () => MysticMemoryEngine.build(
        [duplicate, duplicate],
        generatedAt: day,
      ),
      throwsStateError,
    );
    expect(
      () => MysticMemoryEngine.build([], generatedAt: day, topLimit: 0),
      throwsArgumentError,
    );
    expect(
      () => MysticMemorySearch.search([], 'career', limit: 0),
      throwsArgumentError,
    );
  });

  test('finds semantically related events with transparent aliases', () {
    final career = event(
      id: 'career',
      occurredAt: day,
      themes: const {MemoryTheme.career},
      tags: const {'promotion'},
    );
    final relationship = event(
      id: 'relationship',
      occurredAt: day.add(const Duration(days: 1)),
      themes: const {MemoryTheme.relationship},
    );

    final TurkishResults = MysticMemorySearch.search(
      [relationship, career],
      'iş',
    );
    final tagResults = MysticMemorySearch.search(
      [relationship, career],
      'promotion',
    );

    expect(TurkishResults.single.event.id, 'career');
    expect(
      TurkishResults.single.matchedTerms,
      contains(MemoryTheme.career.name),
    );
    expect(tagResults.single.event.id, 'career');
  });

  test('adapts existing readings and completed journeys into one timeline', () {
    final reading = PatternReading(
      id: 'reading-1',
      createdAt: day,
      cardIds: const ['the-lovers'],
      theme: ReadingTheme.love,
      reflection: 'Connection matters.',
    );
    final journey = MysticJourney(
      id: 'journey-1',
      title: 'Career clarity',
      area: JourneyArea.career,
      createdAt: day.add(const Duration(days: 1)),
      status: JourneyStatus.completed,
      entries: [
        JourneyEntry(
          id: 'entry-1',
          createdAt: day.add(const Duration(days: 2)),
          title: 'First step',
          reflection: 'I updated my plan.',
          tags: const {'Planning'},
        ),
      ],
    );

    final events = MysticMemoryAdapters.combine(
      readings: [reading],
      journeys: [journey],
    );

    expect(events.length, 4);
    expect(events.first.id, 'reading:reading-1');
    expect(events.first.themes, contains(MemoryTheme.relationship));
    expect(
      events.where((item) => item.type == MemoryEventType.journeyCompleted),
      hasLength(1),
    );
    expect(
      events.where((item) => item.journeyId == 'journey-1'),
      hasLength(3),
    );
  });
}
