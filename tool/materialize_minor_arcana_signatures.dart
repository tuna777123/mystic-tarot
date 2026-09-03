import 'dart:io';

void main() => materializeMinorArcanaSignatures();

void materializeMinorArcanaSignatures() {
  final turkishFile = File('lib/src/tarot_localization.dart');
  final globalFile = File('lib/src/tarot_localization_global.dart');
  if (!turkishFile.existsSync() || !globalFile.existsSync()) {
    throw StateError('Tarot localization source is missing.');
  }

  final turkish = materializeTurkishMinorSignaturesSource(
    turkishFile.readAsStringSync(),
  );
  final global = materializeGlobalMinorSignaturesSource(
    globalFile.readAsStringSync(),
  );
  turkishFile.writeAsStringSync(turkish);
  globalFile.writeAsStringSync(global);

  if (!turkish.contains("minorArcanaSignature(drawn.card.name, 'TR')") ||
      !global.contains('minorArcanaSignature(drawn.card.name, languageCode)')) {
    throw StateError('Minor Arcana signature verification failed.');
  }

  stdout.writeln(
    'Minor Arcana signatures materialized: card-specific motifs enrich '
    'TR/ES/FR/PT-BR meanings while preserving reflective rank/suit context.',
  );
}

String materializeTurkishMinorSignaturesSource(String source) {
  var updated = source;
  updated = _replaceRequired(
    updated,
    "import 'models.dart';\nimport 'tarot_localization_global.dart';",
    "import 'models.dart';\nimport 'tarot_localization_global.dart';\nimport 'tarot_minor_signatures.dart';",
    'Turkish Minor Arcana signature import',
  );

  const oldReturn =
      "  return '\${rank[drawn.reversed ? 1 : 0]} \${suit[0]}';";
  const newReturn = '''  final signature = minorArcanaSignature(drawn.card.name, 'TR');
  if (signature == null) {
    throw StateError(
      'Missing Turkish Minor Arcana signature for \${drawn.card.name}.',
    );
  }
  return '\$signature \${rank[drawn.reversed ? 1 : 0]} \${suit[0]}';''';
  updated = _replaceRequired(
    updated,
    oldReturn,
    newReturn,
    'Turkish Minor Arcana meaning signature',
  );
  return updated;
}

String materializeGlobalMinorSignaturesSource(String source) {
  var updated = source;
  updated = _replaceRequired(
    updated,
    "import 'models.dart';",
    "import 'models.dart';\nimport 'tarot_minor_signatures.dart';",
    'global Minor Arcana signature import',
  );

  const oldReturn =
      "  return '\${rank[drawn.reversed ? 1 : 0]} \${suit[0]}';";
  const newReturn = '''  final signature = minorArcanaSignature(drawn.card.name, languageCode);
  if (signature == null) {
    throw StateError(
      'Missing \$languageCode Minor Arcana signature for \${drawn.card.name}.',
    );
  }
  return '\$signature \${rank[drawn.reversed ? 1 : 0]} \${suit[0]}';''';
  updated = _replaceRequired(
    updated,
    oldReturn,
    newReturn,
    'global Minor Arcana meaning signature',
  );
  return updated;
}

String _replaceRequired(
  String source,
  String oldValue,
  String newValue,
  String label,
) {
  if (source.contains(newValue)) return source;
  final count = oldValue.allMatches(source).length;
  if (count != 1) {
    throw StateError(
      'Unable to materialize $label: expected exactly one source anchor, '
      'found $count.',
    );
  }
  return source.replaceFirst(oldValue, newValue);
}
