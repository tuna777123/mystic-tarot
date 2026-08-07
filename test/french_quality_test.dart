import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> usePhone(
    WidgetTester tester, {
    double width = 390,
    double height = 844,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('French shell remains usable on a narrow phone', (tester) async {
    await usePhone(tester, width: 320, height: 700);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarded': true,
      'language': MysticLanguage.french.name,
    });

    await tester.pumpWidget(const MysticApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    for (final label in <String>['Tirages', 'Chemin', 'Journal', 'Vous']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Your cards are waiting'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('French reading flow fits a phone without English fallback', (
    tester,
  ) async {
    await usePhone(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'allow_reversals': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: ReadingFlow(
          kind: ReadingKind.daily,
          deckStyle: DeckStyle.midnight,
          userName: 'Camille',
          intention: 'Clarity',
          language: MysticLanguage.french,
          isPlus: false,
          pastRecords: const <ReadingRecord>[],
          onPremium: () {},
          onComplete: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Guide du jour'), findsOneWidget);
    expect(find.text('COMMENT VOUS SENTEZ-VOUS MAINTENANT ?'), findsOneWidget);
    expect(find.text('Écrivez votre question (facultatif)'), findsOneWidget);
    expect(find.text('CHOOSE YOUR CARDS'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('French premium preview remains localized and responsive', (
    tester,
  ) async {
    await usePhone(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: PremiumReadingPreview(
          kind: ReadingKind.compatibility,
          deckStyle: DeckStyle.midnight,
          language: MysticLanguage.french,
          onUnlock: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Compatibilité amoureuse'), findsOneWidget);
    expect(find.text('PLUS'), findsOneWidget);
    expect(find.text('PLUS PREVIEW'), findsNothing);
    expect(find.text('Chargement…'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 700));

    expect(tester.takeException(), isNull);
  });

  testWidgets('French profile and settings stay readable on a phone', (
    tester,
  ) async {
    await usePhone(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'allow_reversals': true,
      'sound_effects': true,
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: SoulProfileScreen(
          initialName: 'Camille',
          initialIntention: 'Clarity',
          language: MysticLanguage.french,
          onSave: (_, __) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Profil de l’âme'), findsOneWidget);
    expect(find.text('Faites de Mystic votre espace'), findsOneWidget);
    expect(find.text('Make Mystic yours'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('French legal and support pages ship with the web release', () {
    for (final path in <String>[
      'web/privacy-fr.html',
      'web/terms-fr.html',
      'web/support-fr.html',
    ]) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);
      final content = file.readAsStringSync();
      expect(content, contains('<html lang="fr">'));
      expect(content, contains('MYSTIC TAROT'));
    }

    final sitemap = File('web/sitemap.xml').readAsStringSync();
    expect(sitemap, contains('privacy-fr.html'));
    expect(sitemap, contains('terms-fr.html'));
    expect(sitemap, contains('support-fr.html'));
  });

  test('support links follow every selected launch language', () {
    const expectations = <MysticLanguage, String>{
      MysticLanguage.english: '/support.html',
      MysticLanguage.turkish: '/support-tr.html',
      MysticLanguage.spanish: '/support-es.html',
      MysticLanguage.french: '/support-fr.html',
      MysticLanguage.portugueseBrazil: '/support-pt-br.html',
    };

    for (final entry in expectations.entries) {
      expect(
        supportPageForLanguage(entry.key),
        endsWith(entry.value),
        reason: entry.key.name,
      );
    }
  });

  test('all public legal pages keep local-first and safety language', () {
    for (final path in <String>[
      'web/privacy.html',
      'web/terms.html',
      'web/support.html',
      'web/privacy-fr.html',
      'web/terms-fr.html',
      'web/support-fr.html',
    ]) {
      final content = File(path).readAsStringSync();
      expect(content.toLowerCase(), contains('mystic tarot'), reason: path);
    }
  });
}
