import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_locale.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every launch language resolves to its native locale', () {
    expect(mysticLocale(MysticLanguage.english), const Locale('en'));
    expect(mysticLocale(MysticLanguage.turkish), const Locale('tr'));
    expect(mysticLocale(MysticLanguage.spanish), const Locale('es'));
    expect(mysticLocale(MysticLanguage.french), const Locale('fr'));
    expect(
      mysticLocale(MysticLanguage.portugueseBrazil),
      const Locale('pt', 'BR'),
    );
  });

  test('locale codes tolerate store and platform variants', () {
    expect(mysticLocaleFromCode('tr-TR'), const Locale('tr'));
    expect(mysticLocaleFromCode('es_ES'), const Locale('es'));
    expect(mysticLocaleFromCode('fr-FR'), const Locale('fr'));
    expect(mysticLocaleFromCode('pt_BR'), const Locale('pt', 'BR'));
    expect(mysticLocaleFromCode('unknown'), const Locale('en'));
  });

  test('app lock reads the language selected inside Mystic', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'language': MysticLanguage.turkish.name,
    });
    expect(await loadPersistedMysticLanguageCode(), 'tr');

    SharedPreferences.setMockInitialValues(<String, Object>{
      'language': MysticLanguage.portugueseBrazil.name,
    });
    expect(await loadPersistedMysticLanguageCode(), 'pt-BR');
  });
}
