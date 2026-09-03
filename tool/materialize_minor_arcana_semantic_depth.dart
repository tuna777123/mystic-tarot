import 'dart:io';

void main() => materializeMinorArcanaSemanticDepth();

/// Replaces rank+suit Minor Arcana templates with authored per-card semantics
/// in production-verified sources.
///
/// The transform is deterministic, idempotent and fail-closed. Major Arcana,
/// card names, symbols, ordering and numbering are left untouched.
void materializeMinorArcanaSemanticDepth() {
  final tarotData = File('lib/src/tarot_data.dart');
  final localization = File('lib/src/tarot_localization.dart');
  if (!tarotData.existsSync() || !localization.existsSync()) {
    throw StateError('Tarot semantic source files are missing.');
  }

  tarotData.writeAsStringSync(
    materializeTarotDataSemanticDepth(tarotData.readAsStringSync()),
  );
  localization.writeAsStringSync(
    materializeTarotLocalizationSemanticDepth(
      localization.readAsStringSync(),
    ),
  );

  final tarotSource = tarotData.readAsStringSync();
  final localizationSource = localization.readAsStringSync();
  if (!tarotSource.contains("minorArcanaSemantic(name, 'EN')") ||
      tarotSource.contains('The same energy may be blocked, exaggerated') ||
      !localizationSource.contains(
        'minorArcanaSemantic(drawn.card.name, code)',
      )) {
    throw StateError('Minor Arcana semantic-depth verification failed.');
  }

  stdout.writeln(
    'Minor Arcana semantic depth materialized: 56 authored cards now feed '
    'upright, shadow, and grounded-action guidance across launch languages.',
  );
}

String materializeTarotDataSemanticDepth(String source) {
  var updated = _ensureImport(source);
  if (updated.contains("minorArcanaSemantic(name, 'EN')")) return updated;

  final start = updated.indexOf('List<TarotCardData> _minorArcana() {');
  final oldTail = "String _capitalize(String value) => "
      "'\${value[0].toUpperCase()}\${value.substring(1)}';";
  final tailStart = updated.indexOf(oldTail, start);
  if (start < 0 || tailStart < 0) {
    throw StateError(
      'Unable to materialize Minor Arcana deck semantics: source anchors '
      'changed unexpectedly.',
    );
  }
  final end = tailStart + oldTail.length;
  const replacement = r'''List<TarotCardData> _minorArcana() {
  const suits = <(String, String)>[
    ('Wands', '♢'),
    ('Cups', '◡'),
    ('Swords', '†'),
    ('Pentacles', '⬟'),
  ];
  const ranks = <String>[
    'Ace',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Page',
    'Knight',
    'Queen',
    'King',
  ];

  return [
    for (final suit in suits)
      for (var i = 0; i < ranks.length; i++)
        _minorCard(ranks[i], suit.$1, suit.$2, i + 1),
  ];
}

TarotCardData _minorCard(
  String rank,
  String suit,
  String symbol,
  int number,
) {
  final name = '$rank of $suit';
  final semantic = minorArcanaSemantic(name, 'EN');
  if (semantic == null || semantic.length != 3) {
    throw StateError('Missing authored Minor Arcana semantics for $name.');
  }
  return TarotCardData(
    name: name,
    number: '$number',
    symbol: symbol,
    light: semantic[0],
    shadow: semantic[1],
    advice: semantic[2],
  );
}''';
  return updated.replaceRange(start, end, replacement);
}

String materializeTarotLocalizationSemanticDepth(String source) {
  var updated = _ensureImport(source);

  const meaningOld = '''  final code = languageCode ?? (turkish ? 'TR' : 'EN');
  final global = globalTarotCardMeaning(drawn, code);''';
  const meaningNew = '''  final code = languageCode ?? (turkish ? 'TR' : 'EN');
  final semantic = minorArcanaSemantic(drawn.card.name, code);
  if (semantic != null) return semantic[drawn.reversed ? 1 : 0];
  final global = globalTarotCardMeaning(drawn, code);''';
  updated = _replaceOnceOrAlready(
    updated,
    meaningOld,
    meaningNew,
    'localized Minor Arcana meaning bridge',
  );

  const adviceOld = '''  final code = languageCode ?? (turkish ? 'TR' : 'EN');
  final global = globalTarotCardAdvice(drawn, code);''';
  const adviceNew = '''  final code = languageCode ?? (turkish ? 'TR' : 'EN');
  final semantic = minorArcanaSemantic(drawn.card.name, code);
  if (semantic != null) return semantic[2];
  final global = globalTarotCardAdvice(drawn, code);''';
  updated = _replaceOnceOrAlready(
    updated,
    adviceOld,
    adviceNew,
    'localized Minor Arcana advice bridge',
  );
  return updated;
}

String _ensureImport(String source) {
  const importLine = "import 'minor_arcana_semantics.dart';";
  if (source.contains(importLine)) return source;
  const anchor = "import 'models.dart';";
  final matches = anchor.allMatches(source).length;
  if (matches != 1) {
    throw StateError(
      'Unable to install Minor Arcana semantic import: expected one models '
      'import, found $matches.',
    );
  }
  return source.replaceFirst(anchor, "$anchor\n$importLine");
}

String _replaceOnceOrAlready(
  String source,
  String oldValue,
  String newValue,
  String label,
) {
  if (source.contains(newValue)) return source;
  final count = oldValue.allMatches(source).length;
  if (count != 1) {
    throw StateError(
      'Unable to materialize $label: expected one source anchor, found '
      '$count.',
    );
  }
  return source.replaceFirst(oldValue, newValue);
}
