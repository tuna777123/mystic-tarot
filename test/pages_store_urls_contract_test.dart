import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const localizedStorePages = <String, String>{
    'privacy.html': '<h1>Privacy Policy</h1>',
    'privacy-tr.html': '<h1>Gizlilik Politikası</h1>',
    'privacy-es.html': '<h1>Política de privacidad</h1>',
    'privacy-fr.html': '<h1>Politique de confidentialité</h1>',
    'privacy-pt-br.html': '<h1>Política de Privacidade</h1>',
    'terms.html': '<h1>Terms of Use</h1>',
    'terms-tr.html': '<h1>Kullanım Koşulları</h1>',
    'terms-es.html': '<h1>Condiciones de uso</h1>',
    'terms-fr.html': '<h1>Conditions d’utilisation</h1>',
    'terms-pt-br.html': '<h1>Termos de Uso</h1>',
    'support.html': '<h1>Support</h1>',
    'support-tr.html': '<h1>Destek</h1>',
    'support-es.html': '<h1>Soporte</h1>',
    'support-fr.html': '<h1>Assistance</h1>',
    'support-pt-br.html': '<h1>Suporte</h1>',
  };

  test('all launch-language store pages ship with their expected marker', () {
    for (final entry in localizedStorePages.entries) {
      final file = File('web/${entry.key}');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Missing public store page: ${file.path}',
      );
      expect(
        file.readAsStringSync(),
        contains(entry.value),
        reason: '${file.path} must expose its localized heading',
      );
    }
  });

  test('Pages verifies every public launch URL after deployment', () {
    final workflow = File('.github/workflows/pages.yml').readAsStringSync();

    for (final entry in localizedStorePages.entries) {
      expect(
        workflow,
        contains('"${entry.key}"'),
        reason: '${entry.key} must be requested from the live Pages site',
      );
      expect(
        workflow,
        contains('"${entry.value}"'),
        reason: '${entry.key} must verify its localized live marker',
      );
    }

    expect(
      workflow,
      contains('Verify live application, sharing, and localized store URLs'),
    );
    expect(workflow, contains('"press-kit.html"'));
    expect(workflow, contains('"Official press & sharing kit"'));
    expect(workflow, contains('flutter_bootstrap.js'));
    expect(workflow, contains('Kartların ötesini'));
    expect(workflow, contains(r'${#paths[@]}'));
    expect(workflow, contains(r'${#markers[@]}'));
    expect(workflow, contains('--retry-all-errors'));
    expect(workflow, contains(r'LIVE_RESULT: ${{ steps.live.outcome }}'));
    expect(
      workflow,
      contains(
        'Mystic Tarot Pages, press kit, and localized store URLs are live',
      ),
    );
    expect(workflow, contains('exit 1'));
  });
}
