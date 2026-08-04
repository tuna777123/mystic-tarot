import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/launch_differentiation.dart';
import 'package:mystic_tarot/src/theme.dart';

void main() {
  const languages = <MysticLanguage>[
    MysticLanguage.english,
    MysticLanguage.turkish,
    MysticLanguage.spanish,
    MysticLanguage.french,
    MysticLanguage.portugueseBrazil,
  ];

  for (final language in languages) {
    testWidgets('launch continuity fits a 320px phone in ${language.code}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildMysticTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  LaunchContinuityTimeline(language: language),
                  const SizedBox(height: 12),
                  PrivateByDesignCard(language: language),
                ],
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('launch-continuity-timeline')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('private-by-design-card')),
        findsOneWidget,
      );
      expect(find.text(_nowLabel(language)), findsOneWidget);
      expect(find.text(_tomorrowLabel(language)), findsOneWidget);
      expect(find.text(_evidenceLabel(language)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

String _nowLabel(MysticLanguage language) => switch (language) {
  MysticLanguage.turkish => 'ŞİMDİ',
  MysticLanguage.spanish => 'AHORA',
  MysticLanguage.french => 'MAINTENANT',
  MysticLanguage.portugueseBrazil => 'AGORA',
  _ => 'NOW',
};

String _tomorrowLabel(MysticLanguage language) => switch (language) {
  MysticLanguage.turkish => 'YARIN',
  MysticLanguage.spanish => 'MAÑANA',
  MysticLanguage.french => 'DEMAIN',
  MysticLanguage.portugueseBrazil => 'AMANHÃ',
  _ => 'TOMORROW',
};

String _evidenceLabel(MysticLanguage language) => switch (language) {
  MysticLanguage.turkish => 'KANIT BİRİKTİKÇE',
  MysticLanguage.spanish => 'CON EVIDENCIA',
  MysticLanguage.french => 'AVEC DES INDICES',
  MysticLanguage.portugueseBrazil => 'COM EVIDÊNCIAS',
  _ => 'WITH EVIDENCE',
};
