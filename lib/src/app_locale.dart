import 'dart:ui' as ui;

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

/// Resolves a launch-ready Mystic language from an enum name, locale tag, or
/// short language code. Non-launch languages intentionally return null so an
/// older experimental preference cannot expose an incomplete product locale.
MysticLanguage? mysticLanguageFromCode(String? value) {
  final normalized = value
      ?.trim()
      .toLowerCase()
      .replaceAll('_', '-')
      .replaceAll(' ', '');
  if (normalized == null || normalized.isEmpty) return null;

  if (normalized == MysticLanguage.turkish.name.toLowerCase() ||
      normalized == 'tr' ||
      normalized.startsWith('tr-')) {
    return MysticLanguage.turkish;
  }
  if (normalized == MysticLanguage.spanish.name.toLowerCase() ||
      normalized == 'es' ||
      normalized.startsWith('es-')) {
    return MysticLanguage.spanish;
  }
  if (normalized == MysticLanguage.french.name.toLowerCase() ||
      normalized == 'fr' ||
      normalized.startsWith('fr-')) {
    return MysticLanguage.french;
  }
  if (normalized == MysticLanguage.portugueseBrazil.name.toLowerCase() ||
      normalized == 'pt' ||
      normalized.startsWith('pt-')) {
    return MysticLanguage.portugueseBrazil;
  }
  if (normalized == MysticLanguage.english.name.toLowerCase() ||
      normalized == 'en' ||
      normalized.startsWith('en-')) {
    return MysticLanguage.english;
  }
  return null;
}

MysticLanguage mysticLanguageFromLocale(Locale? locale) =>
    mysticLanguageFromCode(locale?.toLanguageTag()) ?? MysticLanguage.english;

/// An explicit in-app choice always wins. On a clean install, a missing,
/// corrupt, or retired preference falls back to the device language when that
/// language is part of the five-language launch set.
MysticLanguage resolveMysticLanguage({
  String? storedValue,
  Locale? platformLocale,
}) =>
    mysticLanguageFromCode(storedValue) ??
    mysticLanguageFromLocale(platformLocale);

Locale mysticLocaleFromCode(String languageCode) =>
    mysticLocale(mysticLanguageFromCode(languageCode) ?? MysticLanguage.english);

String mysticLanguageCode(MysticLanguage language) => switch (language) {
  MysticLanguage.turkish => 'tr',
  MysticLanguage.spanish => 'es',
  MysticLanguage.french => 'fr',
  MysticLanguage.portugueseBrazil => 'pt-BR',
  _ => 'en',
};

Future<String> loadPersistedMysticLanguageCode({Locale? platformLocale}) async {
  final prefs = await SharedPreferences.getInstance();
  final language = resolveMysticLanguage(
    storedValue: prefs.getString('language'),
    platformLocale: platformLocale ?? ui.PlatformDispatcher.instance.locale,
  );
  return mysticLanguageCode(language);
}
