String normalizeMysticSearch(String value) {
  final lower = value.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final character = String.fromCharCode(rune);
    buffer.write(
      switch (character) {
        'á' || 'à' || 'â' || 'ä' || 'ã' || 'å' => 'a',
        'æ' => 'ae',
        'ç' => 'c',
        'é' || 'è' || 'ê' || 'ë' => 'e',
        'ğ' => 'g',
        'í' || 'ì' || 'î' || 'ï' || 'ı' => 'i',
        'ñ' => 'n',
        'ó' || 'ò' || 'ô' || 'ö' || 'õ' => 'o',
        'œ' => 'oe',
        'ş' => 's',
        'ú' || 'ù' || 'û' || 'ü' => 'u',
        'ý' || 'ÿ' => 'y',
        _ => character,
      },
    );
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

bool mysticSearchMatches({
  required String query,
  required Iterable<String> values,
}) {
  final normalizedQuery = normalizeMysticSearch(query);
  if (normalizedQuery.isEmpty) return true;
  final haystack = normalizeMysticSearch(values.join(' '));
  return haystack.contains(normalizedQuery);
}
