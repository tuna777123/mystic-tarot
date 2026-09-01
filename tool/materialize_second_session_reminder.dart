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
  const secondSessionAnchor = '''            final shouldOfferRitualReminder =
                journal.isNotEmpty && record.kind == ReadingKind.daily;''';

  if (source.contains(secondSessionAnchor)) return source;
  if (!source.contains(firstSessionAnchor)) {
    throw StateError(
      'First-session ritual reminder anchor changed unexpectedly.',
    );
  }

  return source.replaceFirst(firstSessionAnchor, secondSessionAnchor);
}
