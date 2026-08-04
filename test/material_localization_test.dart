import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_locale.dart';

void main() {
  testWidgets('Material controls use the selected launch locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: mysticSupportedLocales,
        home: Builder(
          builder: (context) =>
              Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ),
    );

    expect(find.text('Cancelar'), findsOneWidget);
  });

  test('the product shell and private lock wire native localization', () {
    final app = File('lib/src/app.dart').readAsStringSync();
    final lock = File('lib/src/app_lock_gate.dart').readAsStringSync();

    expect(app, contains('locale: mysticLocale(language)'));
    expect(app, contains('GlobalMaterialLocalizations.delegates'));
    expect(app, contains('supportedLocales: mysticSupportedLocales'));
    expect(lock, contains('locale: mysticLocaleFromCode(_languageCode)'));
    expect(lock, contains('GlobalMaterialLocalizations.delegates'));
  });
}
