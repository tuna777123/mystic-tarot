import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flagship.dart';

const List<Locale> mysticSupportedLocales = <Locale>[
  Locale('en'),
  Locale('tr'),
  Locale('es'),
  Locale('fr'),
  Locale('pt', 'BR'),
];

Locale mysticLocale(MysticLanguage language) => switch (language) {
      MysticLanguage.turkish => const Locale('tr'),
      MysticLanguage.spanish => const Locale('es'),
      MysticLanguage.french => const Locale('fr'),
      MysticLanguage.portugueseBrazil => const Locale('pt', 'BR'),
      _ => const Locale('en'),
    };

Locale mysticLocaleFromCode(String languageCode) {
  final normalized = languageCode.trim().toLowerCase().replaceAll('_', '-');
  return switch (normalized) {
    'tr' || 'tr-tr' => const Locale('tr'),
    'es' || 'es-es' => const Locale('es'),
    'fr' || 'fr-fr' => const Locale('fr'),
    'pt' || 'pt-br' => const Locale('pt', 'BR'),
    _ => const Locale('en'),
  };
}

String mysticLanguageCode(MysticLanguage language) => switch (language) {
      MysticLanguage.turkish => 'tr',
      MysticLanguage.spanish => 'es',
      MysticLanguage.french => 'fr',
      MysticLanguage.portugueseBrazil => 'pt-BR',
      _ => 'en',
    };

Future<String> loadPersistedMysticLanguageCode() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString('language');
  for (final language in MysticLanguage.values) {
    if (language.name == stored) return mysticLanguageCode(language);
  }
  return 'en';
}
