import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/mystic_journey.dart';

void main() {
  final createdAt = DateTime.utc(2026, 7, 26);

  MysticJourney journey({
    JourneyStatus status = JourneyStatus.active,
    List<JourneyEntry> entries = const [],
  }) {
    return MysticJourney(
      id: 'journey-1',
      title: 'Career change',
      area: JourneyArea.career,
      createdAt: createdAt,
      status: status,
      entries: entries,
    );
  }

  test('adds entries in chronological order without mutating the source', () {
    final source = journey();
    final later = JourneyEntry(
      id: '2',
      createdAt: createdAt.add(const Duration(days: 2)),
      title: 'Second reflection',
    );
    final earlier = JourneyEntry(
      id: '1',
      createdAt: createdAt.add(const Duration(days: 1)),
      title: 'First reflection',
    );

    final updated = source.addEntry(later).addEntry(earlier);

    expect(source.entries, isEmpty);
    expect(updated.entries.map((entry) => entry.id), ['1', '2']);
  });

  test('rejects duplicate entry ids', () {
    final entry = JourneyEntry(
      id: 'entry-1',
      createdAt: createdAt,
      title: 'Reflection',
    );

    expect(() => journey(entries: [entry]).addEntry(entry), throwsStateError);
  });

  test('completed and archived journeys are immutable timelines', () {
    final entry = JourneyEntry(
      id: 'entry-1',
      createdAt: createdAt,
      title: 'Reflection',
    );

    expect(
      () => journey(status: JourneyStatus.completed).addEntry(entry),
      throwsStateError,
    );
    expect(
      () => journey(status: JourneyStatus.archived).addEntry(entry),
      throwsStateError,
    );
  });

  test('summarizes active days, reflections and normalized tags', () {
    final subject = journey(
      entries: [
        JourneyEntry(
          id: '1',
          createdAt: createdAt,
          title: 'Morning',
          reflection: 'I need to prepare carefully.',
          tags: const {'Career', 'confidence'},
        ),
        JourneyEntry(
          id: '2',
          createdAt: createdAt.add(const Duration(hours: 4)),
          title: 'Evening',
          tags: const {'career'},
        ),
        JourneyEntry(
          id: '3',
          createdAt: createdAt.add(const Duration(days: 1)),
          title: 'Next day',
          reflection: 'The next step feels clearer.',
          tags: const {'clarity'},
        ),
      ],
    );

    final snapshot = JourneyInsights.summarize(
      subject,
      generatedAt: createdAt.add(const Duration(days: 2)),
    );

    expect(snapshot.entryCount, 3);
    expect(snapshot.activeDays, 2);
    expect(snapshot.reflectionRate, closeTo(2 / 3, 0.0001));
    expect(snapshot.topTags, ['career', 'clarity', 'confidence']);
    expect(subject.lastActivityAt, createdAt.add(const Duration(days: 1)));
  });

  test('rejects invalid tag limits', () {
    expect(
      () => JourneyInsights.summarize(
        journey(),
        generatedAt: createdAt,
        tagLimit: 0,
      ),
      throwsArgumentError,
    );
  });
}
