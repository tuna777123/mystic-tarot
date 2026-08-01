import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_language.dart';
import 'package:mystic_tarot/src/language_picker.dart';
import 'package:mystic_tarot/src/theme.dart';

void main() {
  testWidgets('shows only the five complete launch languages', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: Scaffold(
          body: AppLanguagePicker(
            value: AppLanguage.english,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    for (final language in AppLanguage.launchValues) {
      expect(find.text(language.label), findsOneWidget);
    }
    expect(find.text(AppLanguage.german.label), findsNothing);
    expect(find.text(AppLanguage.italian.label), findsNothing);
  });

  testWidgets('returns a selected launch-ready language', (tester) async {
    AppLanguage selected = AppLanguage.english;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: Scaffold(
          body: AppLanguagePicker(
            value: selected,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Français'));
    await tester.pump();

    expect(selected, AppLanguage.french);
  });
}
