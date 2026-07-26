import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/mystic_journey.dart';
import 'package:mystic_tarot/src/mystic_journey_codec.dart';

void main() {
  test('round-trips complete journey data deterministically', () {
    final createdAt = DateTime.utc(2026, 7, 20, 9);
    final journey = MysticJourney(
      id: 'career-1',
      title: 'Career clarity',
      area: JourneyArea.career,
      createdAt: createdAt,
      status: JourneyStatus.paused,
      intention: 'Choose the next step calmly',
      targetDate: createdAt.add(const Duration(days: 30)),
      entries: [
        JourneyEntry(
          id: 'entry-1',
          createdAt: createdAt.add(const Duration(days: 1)),
          title: 'First reflection',
          readingId: 'reading-7',
          reflection: 'I noticed a recurring confidence theme.',
          mood: 'hopeful',
          tags: const {'Work', 'confidence'},
        ),
      ],
    );

    final encoded = MysticJourneyCodec.encode([journey]);
    final report = MysticJourneyCodec.decode(encoded);
    final decoded = report.journeys.single;

    expect(report.schemaVersion, MysticJourneyCodec.schemaVersion);
    expect(report.rejectedItems, 0);
    expect(decoded.id, journey.id);
    expect(decoded.title, journey.title);
    expect(decoded.area, JourneyArea.career);
    expect(decoded.status, JourneyStatus.paused);
    expect(decoded.createdAt.toUtc(), createdAt);
    expect(decoded.targetDate?.toUtc(), journey.targetDate);
    expect(decoded.entries.single.readingId, 'reading-7');
    expect(decoded.entries.single.tags, {'confidence', 'work'});
  });

  test('rejects one damaged journey without losing valid history', () {
    final payload = jsonEncode({
      'schemaVersion': 1,
      'journeys': [
        {
          'id': 'valid',
          'title': 'Valid path',
          'area': 'wellbeing',
          'createdAt': '2026-07-20T09:00:00.000Z',
          'status': 'active',
          'entries': [],
        },
        {
          'id': '',
          'title': 'Damaged path',
          'createdAt': 'not-a-date',
          'entries': [],
        },
      ],
    });

    final report = MysticJourneyCodec.decode(payload);

    expect(report.journeys.map((item) => item.id), ['valid']);
    expect(report.rejectedItems, 1);
  });

  test('uses safe defaults for future enum values', () {
    final payload = jsonEncode({
      'schemaVersion': 1,
      'journeys': [
        {
          'id': 'future',
          'title': 'Future path',
          'area': 'unreleased_area',
          'createdAt': '2026-07-20T09:00:00.000Z',
          'status': 'unreleased_status',
          'entries': [],
        },
      ],
    });

    final journey = MysticJourneyCodec.decode(payload).journeys.single;

    expect(journey.area, JourneyArea.custom);
    expect(journey.status, JourneyStatus.active);
  });

  test('rejects duplicate journey ids deterministically', () {
    final payload = jsonEncode({
      'schemaVersion': 1,
      'journeys': [
        {
          'id': 'same',
          'title': 'First',
          'area': 'custom',
          'createdAt': '2026-07-20T09:00:00.000Z',
          'status': 'active',
          'entries': [],
        },
        {
          'id': 'same',
          'title': 'Second',
          'area': 'custom',
          'createdAt': '2026-07-21T09:00:00.000Z',
          'status': 'active',
          'entries': [],
        },
      ],
    });

    final report = MysticJourneyCodec.decode(payload);

    expect(report.journeys.single.title, 'First');
    expect(report.rejectedItems, 1);
  });

  test('rejects unsupported schema versions', () {
    final payload = jsonEncode({'schemaVersion': 99, 'journeys': []});

    expect(() => MysticJourneyCodec.decode(payload), throwsFormatException);
  });
}
