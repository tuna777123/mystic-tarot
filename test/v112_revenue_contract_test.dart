import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.12 revenue identity and intelligence wiring are complete', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final app = File('lib/src/app.dart').readAsStringSync();
    final releaseNotes = File('RELEASE_NOTES.md').readAsStringSync();

    expect(
      RegExp(r'version: 1\.(?:1[2-9]|[2-9]\d)\.\d+\+\d+').hasMatch(pubspec),
      isTrue,
    );
    expect(app, contains("import 'mystic_plus_intelligence_screen.dart';"));
    expect(app, contains('MysticPlusIntelligenceScreen('));
    expect(app, contains('MysticIntelligenceTeaser('));
    expect(app, contains('onOpen: onPremium'));
    expect(app, contains('isPlus: isPlus'));
    expect(app, isNot(contains('PremiumValueScreen(')));
    expect(
      releaseNotes,
      contains('# Mystic Tarot 1.12.0 — Revenue Intelligence'),
    );
  });

  test('official plan screen sells the accumulating weekly outcome', () {
    final store = File(
      'lib/src/store_ready_premium_screen.dart',
    ).readAsStringSync();
    expect(
      store,
      contains('A fresh private intelligence report every seven days'),
    );
    expect(
      store,
      contains('Her yedi günde yenilenen özel intelligence raporu'),
    );
    expect(store, contains('Unlimited deep readings'));
    expect(store, contains('Premium spreads and unlimited Oracle follow-ups'));
  });

  test('all localized store handoffs describe the v1.12 report', () {
    const listings = <String>[
      'docs/STORE_LISTING_TR.md',
      'docs/STORE_LISTING_ES.md',
      'docs/STORE_LISTING_FR.md',
      'docs/STORE_LISTING_PT_BR.md',
    ];
    for (final path in listings) {
      final content = File(path).readAsStringSync();
      expect(
        RegExp(r'1\.(?:1[2-9]|[2-9]\d)\.\d+').hasMatch(content),
        isTrue,
        reason: path,
      );
      expect(content.toLowerCase(), contains('intelligence'), reason: path);
      expect(
        content,
        isNot(contains('## Sürüm notları — 1.11.0')),
        reason: path,
      );
      expect(
        content,
        isNot(contains('## Notas de la versión — 1.11.0')),
        reason: path,
      );
      expect(
        content,
        isNot(contains('## Notes de version — 1.11.0')),
        reason: path,
      );
      expect(
        content,
        isNot(contains('## Notas da versão — 1.11.0')),
        reason: path,
      );
    }
  });

  test('temporary integration machinery is absent from the release tree', () {
    expect(File('tool/integrate_v112_revenue.py').existsSync(), isFalse);
    expect(
      File('.github/workflows/integrate-v112-revenue.yml').existsSync(),
      isFalse,
    );
  });
}
