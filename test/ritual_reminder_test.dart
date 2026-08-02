import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/ritual_reminder.dart';
import 'package:mystic_tarot/src/ritual_reminder_screen.dart';

void main() {
  test('next reminder stays today when the selected time is ahead', () {
    final now = DateTime(2026, 8, 2, 18, 30);
    expect(
      nextRitualReminderTime(now: now, hour: 20, minute: 0),
      DateTime(2026, 8, 2, 20),
    );
  });

  test('next reminder moves to tomorrow after the selected time', () {
    final now = DateTime(2026, 8, 2, 21, 1);
    expect(
      nextRitualReminderTime(now: now, hour: 21, minute: 0),
      DateTime(2026, 8, 3, 21),
    );
  });

  test('settings sanitize invalid persisted times', () {
    const settings = RitualReminderSettings.defaults();
    final sanitized = settings.copyWith(hour: 99, minute: -8);
    expect(sanitized.hour, 23);
    expect(sanitized.minute, 0);
    expect(sanitized.formattedTime, '23:00');
  });

  test('all launch languages receive complete notification copy', () {
    for (final language in const [
      MysticLanguage.english,
      MysticLanguage.turkish,
      MysticLanguage.spanish,
      MysticLanguage.french,
      MysticLanguage.portugueseBrazil,
    ]) {
      final copy = RitualReminderCopy.forLanguage(language);
      expect(copy.title.trim(), isNotEmpty);
      expect(copy.body.trim(), isNotEmpty);
      expect(copy.channelName.trim(), isNotEmpty);
      expect(copy.channelDescription.trim(), isNotEmpty);
    }
  });

  test('stored language aliases resolve without accidental English fallback', () {
    expect(
      ritualReminderLanguageFromCode('pt_BR'),
      MysticLanguage.portugueseBrazil,
    );
    expect(ritualReminderLanguageFromCode('tr'), MysticLanguage.turkish);
  });
  testWidgets('French reminder offer fits a narrow phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showRitualReminderOfferSheet(
                context: context,
                language: MysticLanguage.french,
                now: DateTime(2026, 8, 2, 14),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Gardez ce rituel pour vous'), findsOneWidget);
    expect(find.text('Pas maintenant'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('web and desktop explain that native reminders are unavailable', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RitualReminderSettingsPanel(
              language: MysticLanguage.english,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Available in the iOS and Android apps'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

}
