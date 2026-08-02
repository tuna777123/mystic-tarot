import 'flagship.dart';
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

DateTime? nextMysticMirrorDueAt({
  required Iterable<ReadingRecord> records,
  required Map<String, MysticMirrorReflection> reflections,
  required DateTime now,
}) {
  final completed = reflections.keys.toSet();
  DateTime? next;
  for (final record in records) {
    if (completed.contains(mysticMirrorRecordId(record))) continue;
    final checkInAt = record.mirrorCheckInAt;
    if (!checkInAt.isAfter(now)) continue;
    if (next == null || checkInAt.isBefore(next)) next = checkInAt;
  }
  return next;
}

Duration? durationUntilNextMysticMirror({
  required Iterable<ReadingRecord> records,
  required Map<String, MysticMirrorReflection> reflections,
  required DateTime now,
}) {
  final next = nextMysticMirrorDueAt(
    records: records,
    reflections: reflections,
    now: now,
  );
  return next?.difference(now);
}

String compactMirrorDueLabel(int count) => count > 99 ? '99+' : '$count';

String localizedMirrorDueSemantics(int count, MysticLanguage language) {
  if (count <= 0) {
    return switch (language) {
      MysticLanguage.turkish => 'Bekleyen Mystic Ayna kontrolü yok',
      MysticLanguage.spanish => 'No hay revisiones de Mystic Mirror pendientes',
      MysticLanguage.french => 'Aucun bilan Mystic Mirror en attente',
      MysticLanguage.portugueseBrazil =>
        'Nenhum check-in do Mystic Mirror pendente',
      _ => 'No Mystic Mirror check-ins are due',
    };
  }

  return switch (language) {
    MysticLanguage.turkish => '$count Mystic Ayna kontrolü hazır',
    MysticLanguage.spanish =>
      '$count ${count == 1 ? 'revisión' : 'revisiones'} de Mystic Mirror ${count == 1 ? 'lista' : 'listas'}',
    MysticLanguage.french =>
      '$count ${count == 1 ? 'bilan Mystic Mirror est prêt' : 'bilans Mystic Mirror sont prêts'}',
    MysticLanguage.portugueseBrazil =>
      '$count ${count == 1 ? 'check-in do Mystic Mirror está pronto' : 'check-ins do Mystic Mirror estão prontos'}',
    _ =>
      '$count Mystic Mirror ${count == 1 ? 'check-in is' : 'check-ins are'} ready',
  };
}
