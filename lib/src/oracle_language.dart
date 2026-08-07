import 'flagship.dart';

enum OracleQuestionIntent { hidden, keyCard, general }

OracleQuestionIntent detectOracleQuestionIntent(
  String question,
  MysticLanguage language,
) {
  final normalized = _normalizeOracleText(question);
  final hiddenTerms = switch (language) {
    MysticLanguage.turkish => const <String>[
      'goremiyorum',
      'gormuyorum',
      'gozden kaciriyorum',
      'hafife aliyorum',
      'gizli',
      'risk',
    ],
    MysticLanguage.spanish => const <String>[
      'no estoy viendo',
      'no veo',
      'subestimando',
      'oculto',
      'riesgo',
    ],
    MysticLanguage.french => const <String>[
      'je ne vois pas',
      'que dois je voir',
      'sous estime',
      'cache',
      'risque',
    ],
    MysticLanguage.portugueseBrazil => const <String>[
      'nao estou vendo',
      'nao vejo',
      'subestimando',
      'oculto',
      'risco',
    ],
    _ => const <String>[
      'not seeing',
      'do not see',
      'underestimating',
      'hidden',
      'risk',
    ],
  };
  if (hiddenTerms.any(normalized.contains)) {
    return OracleQuestionIntent.hidden;
  }

  final keyCardTerms = switch (language) {
    MysticLanguage.turkish => const <String>[
      'hangi kart',
      'en onemli kart',
      'en cok onemli',
    ],
    MysticLanguage.spanish => const <String>[
      'que carta',
      'cual carta',
      'carta mas importante',
    ],
    MysticLanguage.french => const <String>[
      'quelle carte',
      'carte la plus importante',
      'quelle est la carte',
    ],
    MysticLanguage.portugueseBrazil => const <String>[
      'qual carta',
      'carta mais importante',
    ],
    _ => const <String>['which card', 'key card', 'most important card'],
  };
  if (keyCardTerms.any(normalized.contains)) {
    return OracleQuestionIntent.keyCard;
  }
  return OracleQuestionIntent.general;
}

String _normalizeOracleText(String value) {
  const replacements = <String, String>{
    'ç': 'c',
    'Ç': 'c',
    'ğ': 'g',
    'Ğ': 'g',
    'ı': 'i',
    'İ': 'i',
    'ö': 'o',
    'Ö': 'o',
    'ş': 's',
    'Ş': 's',
    'ü': 'u',
    'Ü': 'u',
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ñ': 'n',
    'œ': 'oe',
  };
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final character = String.fromCharCode(rune);
    buffer.write(replacements[character] ?? character.toLowerCase());
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}
