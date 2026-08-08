import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const legalPages = <String, String>{
    'web/privacy.html': 'en',
    'web/terms.html': 'en',
    'web/support.html': 'en',
    'web/privacy-tr.html': 'tr',
    'web/terms-tr.html': 'tr',
    'web/support-tr.html': 'tr',
    'web/privacy-es.html': 'es',
    'web/terms-es.html': 'es',
    'web/support-es.html': 'es',
    'web/privacy-fr.html': 'fr',
    'web/terms-fr.html': 'fr',
    'web/support-fr.html': 'fr',
    'web/privacy-pt-br.html': 'pt-BR',
    'web/terms-pt-br.html': 'pt-BR',
    'web/support-pt-br.html': 'pt-BR',
  };

  test('all five launch languages ship privacy terms and support pages', () {
    for (final entry in legalPages.entries) {
      final file = File(entry.key);
      expect(file.existsSync(), isTrue, reason: entry.key);
      final content = file.readAsStringSync();
      expect(
        content,
        contains('<html lang="${entry.value}">'),
        reason: entry.key,
      );
      expect(
        content.toLowerCase(),
        contains('mystic tarot'),
        reason: entry.key,
      );
      expect(content, contains('legal.css'), reason: entry.key);
    }
  });

  test('the sitemap indexes every localized legal page', () {
    final sitemap = File('web/sitemap.xml').readAsStringSync();
    for (final path in legalPages.keys) {
      final fileName = path.split('/').last;
      expect(sitemap, contains(fileName), reason: path);
    }
  });

  test('generic support routes every non-English launch language', () {
    final support = File('web/support.html').readAsStringSync();
    expect(support, contains("params.get('stay') === 'en'"));
    for (final target in <String>[
      'support-tr.html',
      'support-es.html',
      'support-fr.html',
      'support-pt-br.html',
    ]) {
      expect(support, contains(target));
    }
  });

  test('localized support pages preserve an explicit English choice', () {
    for (final path in <String>[
      'web/support-tr.html',
      'web/support-es.html',
      'web/support-fr.html',
      'web/support-pt-br.html',
    ]) {
      final content = File(path).readAsStringSync();
      expect(content, contains('support.html?stay=en'), reason: path);
    }
  });

  test('every support page exposes the complete language navigation', () {
    for (final path in <String>[
      'web/support.html',
      'web/support-tr.html',
      'web/support-es.html',
      'web/support-fr.html',
      'web/support-pt-br.html',
    ]) {
      final content = File(path).readAsStringSync();
      for (final target in <String>[
        'support-tr.html',
        'support-es.html',
        'support-fr.html',
        'support-pt-br.html',
      ]) {
        if (path.endsWith(target)) continue;
        expect(content, contains(target), reason: '$path -> $target');
      }
    }
  });

  test('localized store listing handoffs are advertising-only', () {
    for (final path in <String>[
      'docs/STORE_LISTING_TR.md',
      'docs/STORE_LISTING_ES.md',
      'docs/STORE_LISTING_FR.md',
      'docs/STORE_LISTING_PT_BR.md',
    ]) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);
      final content = file.readAsStringSync();
      expect(content, contains('Mystic Tarot'), reason: path);
      expect(content, isNot(contains('Mystic Plus')), reason: path);
      expect(
        content.toLowerCase(),
        anyOf(
          contains('reklam'),
          contains('publicidad'),
          contains('publicité'),
          contains('publicidade'),
        ),
        reason: path,
      );
    }
  });

  test('canonical release pack declares the five-language launch', () {
    final releasePack = File('STORE_RELEASE.md').readAsStringSync();
    for (final language in <String>[
      'English',
      'Turkish',
      'Spanish',
      'French',
      'Brazilian Portuguese',
    ]) {
      expect(releasePack, contains(language));
    }
    expect(
      releasePack,
      isNot(contains('Version 1 launches in English and Turkish.')),
    );
  });
}
