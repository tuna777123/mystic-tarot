import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const listings = <String>[
    'docs/STORE_LISTING_TR.md',
    'docs/STORE_LISTING_ES.md',
    'docs/STORE_LISTING_FR.md',
    'docs/STORE_LISTING_PT_BR.md',
  ];

  test('all localized store listings preserve the v1.11 trust baseline', () {
    const mirrorNames = <String, String>{
      'docs/STORE_LISTING_TR.md': 'mystic ayna',
      'docs/STORE_LISTING_ES.md': 'mystic mirror',
      'docs/STORE_LISTING_FR.md': 'mystic mirror',
      'docs/STORE_LISTING_PT_BR.md': 'mystic mirror',
    };

    for (final path in listings) {
      final content = File(path).readAsStringSync();
      expect(content, isNot(contains('1.10.1')), reason: path);
      expect(content.toLowerCase(), contains(mirrorNames[path]), reason: path);
    }
  });

  test(
    'every listing discloses explainability and twenty-four-hour follow-up',
    () {
      final requiredTerms = <String, List<String>>{
        'docs/STORE_LISTING_TR.md': <String>[
          'Bu yorumun nedenini gör',
          '24 saat sonra',
        ],
        'docs/STORE_LISTING_ES.md': <String>[
          'COMPRENDE LA INTERPRETACIÓN',
          'DESPUÉS DE 24 HORAS',
        ],
        'docs/STORE_LISTING_FR.md': <String>[
          'COMPRENEZ L’INTERPRÉTATION',
          'APRÈS 24 HEURES',
        ],
        'docs/STORE_LISTING_PT_BR.md': <String>[
          'ENTENDA A INTERPRETAÇÃO',
          'APÓS 24 HORAS',
        ],
      };

      for (final entry in requiredTerms.entries) {
        final content = File(entry.key).readAsStringSync();
        for (final term in entry.value) {
          expect(content, contains(term), reason: '${entry.key}: $term');
        }
      }
    },
  );

  test('store copy keeps the free Mirror promise honest', () {
    final expected = <String, String>{
      'docs/STORE_LISTING_TR.md': 'temel 24 saatlik Mystic Ayna ücretsiz kalır',
      'docs/STORE_LISTING_ES.md':
          'Mystic Mirror básico de 24 horas permanecen gratuitos',
      'docs/STORE_LISTING_FR.md':
          'Mystic Mirror de base sur 24 heures restent gratuits',
      'docs/STORE_LISTING_PT_BR.md':
          'Mystic Mirror básico de 24 horas continuam gratuitos',
    };

    for (final entry in expected.entries) {
      expect(
        File(entry.key).readAsStringSync(),
        contains(entry.value),
        reason: entry.key,
      );
    }
  });

  test('localized short descriptions stay within Google Play limit', () {
    final shortDescriptions = <String>[
      'Açıklanabilir tarot, 24 saatlik Mystic Ayna ve sana ait özel günlük.',
      'Tarot explicable, Mystic Mirror de 24 horas y diario privado.',
      'Tarot explicable, Mystic Mirror sur 24 h et journal privé.',
      'Tarô explicável, Mystic Mirror de 24 horas e diário privado.',
    ];

    for (final description in shortDescriptions) {
      expect(description.length, lessThanOrEqualTo(80), reason: description);
    }
  });
}
