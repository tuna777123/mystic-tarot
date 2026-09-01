import 'dart:io';

void main() => materializeSecondSessionReminder();

/// Keeps the first completed reading uninterrupted. The optional ritual
/// notification offer is deferred until a later daily return, when the user
/// has already experienced Mystic's core reading → Mirror loop.
void materializeSecondSessionReminder() {
  final app = File('lib/src/app.dart');
  if (!app.existsSync()) {
    throw StateError('Mystic Tarot app source is missing.');
  }

  final original = app.readAsStringSync();
  final updated = transformSecondSessionReminder(original);
  app.writeAsStringSync(updated);
}

String transformSecondSessionReminder(String source) {
  const firstSessionAnchor = '''            final shouldOfferRitualReminder =
                journal.isEmpty && record.kind == ReadingKind.daily;''';
  const sameDaySecondReadingAnchor =
      '''            final shouldOfferRitualReminder =
                journal.isNotEmpty && record.kind == ReadingKind.daily;''';
  const laterDailyReturnAnchor = '''            final shouldOfferRitualReminder =
                journal.any(
                  (saved) =>
                      saved.kind == ReadingKind.daily &&
                      _dayKey(saved.createdAt) != _dayKey(record.createdAt),
                ) &&
                record.kind == ReadingKind.daily;''';

  if (source.contains(laterDailyReturnAnchor)) return source;

  final sourceAnchor = source.contains(sameDaySecondReadingAnchor)
      ? sameDaySecondReadingAnchor
      : firstSessionAnchor;
  if (!source.contains(sourceAnchor)) {
    throw StateError(
      'First-session ritual reminder anchor changed unexpectedly.',
    );
  }

  return source.replaceFirst(sourceAnchor, laterDailyReturnAnchor);
}
