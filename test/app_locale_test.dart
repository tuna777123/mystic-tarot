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

  test('locale codes tolerate regional store and platform variants', () {
    expect(mysticLocaleFromCode('tr-TR'), const Locale('tr'));
    expect(mysticLocaleFromCode('es_MX'), const Locale('es'));
    expect(mysticLocaleFromCode('fr-CA'), const Locale('fr'));
    expect(mysticLocaleFromCode('pt_PT'), const Locale('pt', 'BR'));
    expect(mysticLocaleFromCode('unknown'), const Locale('en'));
  });

  test('only launch-ready languages can be restored', () {
    expect(
      mysticLanguageFromCode(MysticLanguage.spanish.name),
      MysticLanguage.spanish,
    );
    expect(mysticLanguageFromCode('italian'), isNull);
    expect(mysticLanguageFromCode('de-DE'), isNull);
  });

  test('explicit in-app selection wins over the device language', () {
    expect(
      resolveMysticLanguage(
        storedValue: MysticLanguage.french.name,
        platformLocale: const Locale('tr', 'TR'),
      ),
      MysticLanguage.french,
    );
  });

  test('clean and corrupt installs fall back to a launch device language', () {
    expect(
      resolveMysticLanguage(platformLocale: const Locale('es', 'AR')),
      MysticLanguage.spanish,
    );
    expect(
      resolveMysticLanguage(
        storedValue: 'retired-locale',
        platformLocale: const Locale('pt', 'PT'),
      ),
      MysticLanguage.portugueseBrazil,
    );
  });

  test('unsupported device languages fall back to English', () {
    expect(
      resolveMysticLanguage(platformLocale: const Locale('ja', 'JP')),
      MysticLanguage.english,
    );
  });

  test('app lock reads the language selected inside Mystic', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'language': MysticLanguage.turkish.name,
    });
    expect(
      await loadPersistedMysticLanguageCode(
        platformLocale: const Locale('en', 'US'),
      ),
      'tr',
    );

    SharedPreferences.setMockInitialValues(<String, Object>{
      'language': MysticLanguage.portugueseBrazil.name,
    });
    expect(
      await loadPersistedMysticLanguageCode(
        platformLocale: const Locale('fr', 'FR'),
      ),
      'pt-BR',
    );
  });

  test('app lock uses the device language before onboarding', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    expect(
      await loadPersistedMysticLanguageCode(
        platformLocale: const Locale('fr', 'CA'),
      ),
      'fr',
    );
  });
}
