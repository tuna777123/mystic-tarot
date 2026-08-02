import 'models.dart';
import 'mystic_mirror.dart';

int countDueMysticMirrors({
  required Iterable<ReadingRecord> records,
  required Map<String, MysticMirrorReflection> reflections,
  required DateTime now,
}) {
  final completed = reflections.keys.toSet();
  return records.where((record) {
    return mysticMirrorIsDue(
      record,
      now,
      completedRecordIds: completed,
    );
  }).length;
}

String compactMirrorDueLabel(int count) => count > 99 ? '99+' : '$count';
