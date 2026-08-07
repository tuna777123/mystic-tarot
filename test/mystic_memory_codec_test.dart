import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/mystic_memory.dart';
import 'package:mystic_tarot/src/mystic_memory_codec.dart';

void main() {
  final createdAt = DateTime.utc(2026, 7, 27, 12);

  TimelineEvent subject() => TimelineEvent(
    id: 'event-1',
    occurredAt: createdAt,
    type: MemoryEventType.reflection,
    title: 'Career reflection',
    reflection: 'A clearer next step.',
    themes: const {MemoryTheme.career, MemoryTheme.confidence},
    tags: const {'Career', ' planning '},
    cardIds: const ['the-star', 'the-star', 'the-hermit'],
    mood: 'Hopeful',
    journeyId: 'journey-1',
    sourceId: 'entry-1',
  );

  test('round-trips a complete memory event deterministically', () {
    final encoded = MysticMemoryCodec.encode([subject()]);
    final report = MysticMemoryCodec.decode(encoded);
    final decoded = report.events.single;

    expect(report.schemaVersion, MysticMemoryCodec.schemaVersion);
    expect(report.rejectedItems, 0);
    expect(decoded.id, 'event-1');
    expect(decoded.occurredAt.isAtSameMomentAs(createdAt), isTrue);
    expect(decoded.type, MemoryEventType.reflection);
    expect(decoded.themes, {MemoryTheme.career, MemoryTheme.confidence});
    expect(decoded.tags, {'career', 'planning'});
    expect(decoded.cardIds, ['the-hermit', 'the-star']);
    expect(decoded.mood, 'Hopeful');
    expect(decoded.journeyId, 'journey-1');
    expect(decoded.sourceId, 'entry-1');
  });

  test(
    'rejects damaged and duplicate records without losing valid history',
    () {
      final root = jsonDecode(MysticMemoryCodec.encode([subject()])) as Map;
      final events = root['events'] as List;
      events
        ..add('damaged')
        ..add(Map<String, dynamic>.from(events.first as Map));

      final report = MysticMemoryCodec.decode(jsonEncode(root));

      expect(report.events.single.id, 'event-1');
      expect(report.rejectedItems, 2);
    },
  );

  test('uses safe enum fallbacks for future unknown event types', () {
    final root = jsonDecode(MysticMemoryCodec.encode([subject()])) as Map;
    final event = (root['events'] as List).single as Map;
    event['type'] = 'futureEventType';

    final decoded = MysticMemoryCodec.decode(jsonEncode(root)).events.single;

    expect(decoded.type, MemoryEventType.note);
  });

  test('rejects unsupported schema versions and invalid roots', () {
    expect(
      () => MysticMemoryCodec.decode(
        jsonEncode({'schemaVersion': 99, 'events': []}),
      ),
      throwsFormatException,
    );
    expect(() => MysticMemoryCodec.decode('[]'), throwsFormatException);
  });
}
