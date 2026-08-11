import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

class _ListingLabels {
  const _ListingLabels({
    required this.path,
    required this.appName,
    required this.subtitle,
    required this.promotionalText,
    required this.description,
    required this.keywords,
    required this.playName,
    required this.shortDescription,
    required this.fullDescription,
    required this.releaseNotes,
  });

  final String path;
  final String appName;
  final String subtitle;
  final String promotionalText;
  final String description;
  final String keywords;
  final String playName;
  final String shortDescription;
  final String fullDescription;
  final String releaseNotes;
}

const _listings = <String, _ListingLabels>{
  'en': _ListingLabels(
    path: 'docs/STORE_LISTING_EN.md',
    appName: '**Name**',
    subtitle: '**Subtitle**',
    promotionalText: '**Promotional text**',
    description: '**Description**',
    keywords: '**Keywords**',
    playName: '**App name**',
    shortDescription: '**Short description**',
    fullDescription: '**Full description**',
    releaseNotes: '## Release notes',
  ),
  'tr': _ListingLabels(
    path: 'docs/STORE_LISTING_TR.md',
    appName: '**Ad**',
    subtitle: '**Alt başlık**',
    promotionalText: '**Tanıtım metni**',
    description: '**Açıklama**',
    keywords: '**Anahtar kelimeler**',
    playName: '**Uygulama adı**',
    shortDescription: '**Kısa açıklama**',
    fullDescription: '**Tam açıklama**',
    releaseNotes: '## Sürüm notları',
  ),
  'es': _ListingLabels(
    path: 'docs/STORE_LISTING_ES.md',
    appName: '**Nombre**',
    subtitle: '**Subtítulo**',
    promotionalText: '**Texto promocional**',
    description: '**Descripción**',
    keywords: '**Palabras clave**',
    playName: '**Nombre**',
    shortDescription: '**Descripción corta**',
    fullDescription: '**Descripción completa**',
    releaseNotes: '## Notas de la versión',
  ),
  'fr': _ListingLabels(
    path: 'docs/STORE_LISTING_FR.md',
    appName: '**Nom**',
    subtitle: '**Sous-titre**',
    promotionalText: '**Texte promotionnel**',
    description: '**Description**',
    keywords: '**Mots-clés**',
    playName: '**Nom**',
    shortDescription: '**Description courte**',
    fullDescription: '**Description complète**',
    releaseNotes: '## Notes de version',
  ),
  'pt-BR': _ListingLabels(
    path: 'docs/STORE_LISTING_PT_BR.md',
    appName: '**Nome**',
    subtitle: '**Subtítulo**',
    promotionalText: '**Texto promocional**',
    description: '**Descrição**',
    keywords: '**Palavras-chave**',
    playName: '**Nome**',
    shortDescription: '**Descrição curta**',
    fullDescription: '**Descrição completa**',
    releaseNotes: '## Notas da versão',
  ),
};

void main() {
  for (final entry in _listings.entries) {
    final locale = entry.key;
    final labels = entry.value;

    test('$locale store metadata is complete and within submission limits', () {
      final file = File(labels.path);
      expect(file.existsSync(), isTrue, reason: '${labels.path} must exist.');
      final source = file.readAsStringSync();
      final appStore = _section(source, '## App Store', '## Google Play');
      final googlePlay = _section(source, '## Google Play', null);

      final appName = _singleLineAfter(appStore, labels.appName);
      final subtitle = _singleLineAfter(appStore, labels.subtitle);
      final promotionalText = _singleLineAfter(
        appStore,
        labels.promotionalText,
      );
      final description = _blockBetween(
        appStore,
        labels.description,
        labels.keywords,
      );
      final keywords = _singleLineAfter(appStore, labels.keywords);
      final playName = _singleLineAfter(googlePlay, labels.playName);
      final shortDescription = _singleLineAfter(
        googlePlay,
        labels.shortDescription,
      );
      final fullDescription = _blockBetween(
        googlePlay,
        labels.fullDescription,
        labels.releaseNotes,
      );

      _expectCharacters(
        appName,
        min: 2,
        max: 30,
        field: '$locale App Store name',
      );
      _expectCharacters(subtitle, max: 30, field: '$locale App Store subtitle');
      _expectCharacters(
        promotionalText,
        max: 170,
        field: '$locale App Store promotional text',
      );
      _expectCharacters(
        description,
        max: 4000,
        field: '$locale App Store description',
      );
      expect(
        utf8.encode(keywords).length,
        lessThanOrEqualTo(100),
        reason: '$locale App Store keywords must be <=100 UTF-8 bytes.',
      );
      expect(keywords.trim(), isNotEmpty);

      _expectCharacters(playName, max: 30, field: '$locale Play app name');
      _expectCharacters(
        shortDescription,
        max: 80,
        field: '$locale Play short description',
      );
      _expectCharacters(
        fullDescription,
        max: 4000,
        field: '$locale Play full description',
      );

      expect(source, contains('1.23.0'));
      expect(source, isNot(contains('RevenueCat')));
      expect(source, isNot(contains('Mystic Plus')));
      expect(source, isNot(contains('mystic_plus')));
    });
  }
}

String _section(String source, String start, String? end) {
  final startIndex = source.indexOf(start);
  if (startIndex < 0) {
    throw FormatException('Missing section: $start');
  }
  final contentStart = startIndex + start.length;
  if (end == null) return source.substring(contentStart);
  final endIndex = source.indexOf(end, contentStart);
  if (endIndex < 0) {
    throw FormatException('Missing section boundary: $end');
  }
  return source.substring(contentStart, endIndex);
}

String _singleLineAfter(String source, String label) {
  final labelIndex = source.indexOf(label);
  if (labelIndex < 0) throw FormatException('Missing metadata label: $label');
  final tail = source.substring(labelIndex + label.length);
  for (final rawLine in const LineSplitter().convert(tail)) {
    final line = rawLine.trim();
    if (line.isNotEmpty) return line;
  }
  throw FormatException('Missing metadata value after: $label');
}

String _blockBetween(String source, String startLabel, String endLabel) {
  final startIndex = source.indexOf(startLabel);
  if (startIndex < 0) {
    throw FormatException('Missing metadata label: $startLabel');
  }
  final contentStart = startIndex + startLabel.length;
  final endIndex = source.indexOf(endLabel, contentStart);
  if (endIndex < 0) {
    throw FormatException('Missing metadata boundary: $endLabel');
  }
  final value = source.substring(contentStart, endIndex).trim();
  if (value.isEmpty) {
    throw FormatException('Missing metadata value after: $startLabel');
  }
  return value;
}

void _expectCharacters(
  String value, {
  int min = 1,
  required int max,
  required String field,
}) {
  final count = value.runes.length;
  expect(count, greaterThanOrEqualTo(min), reason: '$field is required.');
  expect(
    count,
    lessThanOrEqualTo(max),
    reason: '$field exceeds $max characters.',
  );
}
