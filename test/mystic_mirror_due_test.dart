import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/mystic_mirror.dart';
import 'package:mystic_tarot/src/mystic_mirror_due.dart';
import 'package:mystic_tarot/src/tarot_data.dart';

ReadingRecord recordAt(DateTime createdAt) => ReadingRecord(
      kind: ReadingKind.daily,
      question: '',
      cards: <DrawnCard>[DrawnCard(tarotDeck.first, false)],
      createdAt: createdAt,
      emotion: EmotionalState.curious,
      alignedAction: 'Take one step.',
    );

void main() {
  test('only incomplete readings older than twenty-four hours are counted', () {
    final now = DateTime.utc(2026, 8, 3, 12);
    final due = recordAt(now.subtract(const Duration(hours: 25)));
    final waiting = recordAt(now.subtract(const Duration(hours: 23)));
    final completed = recordAt(now.subtract(const Duration(days: 3)));
    final reflection = MysticMirrorReflection(
      recordId: mysticMirrorRecordId(completed),
      outcome: MysticMirrorOutcome.shifted,
      emotion: EmotionalState.grounded,
      note: '',
      completedAt: now.subtract(const Duration(days: 2)),
    );

    expect(
      countDueMysticMirrors(
        records: <ReadingRecord>[due, waiting, completed],
        reflections: <String, MysticMirrorReflection>{
          reflection.recordId: reflection,
        },
        now: now,
      ),
      1,
    );
  });

  test('multiple due readings produce the exact badge count', () {
    final now = DateTime.utc(2026, 8, 3, 12);
    final records = List<ReadingRecord>.generate(
      7,
      (index) => recordAt(now.subtract(Duration(days: index + 2))),
    );

    expect(
      countDueMysticMirrors(
        records: records,
        reflections: const <String, MysticMirrorReflection>{},
        now: now,
      ),
      7,
    );
  });

  test('badge label stays compact above two digits', () {
    expect(compactMirrorDueLabel(0), '0');
    expect(compactMirrorDueLabel(9), '9');
    expect(compactMirrorDueLabel(99), '99');
    expect(compactMirrorDueLabel(100), '99+');
    expect(compactMirrorDueLabel(248), '99+');
  });
}
