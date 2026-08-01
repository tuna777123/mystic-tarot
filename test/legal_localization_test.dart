import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const pagesByLanguage = <String, Map<String, String>>{
    'en': <String, String>{
      'privacy': 'web/privacy.html',
      'terms': 'web/terms.html',
      'support': 'web/support.html',
    },
    'tr': <String, String>{
      'privacy': 'web/privacy-tr.html',
      'terms': 'web/terms-tr.html',
      'support': 'web/support-tr.html',
    },
    'fr': <String, String>{
      'privacy': 'web/privacy-fr.html',
      'terms': 'web/terms-fr.html',
      'support': 'web/support-fr.html',
    },
    'es': <String, String>{
      'privacy': 'web/privacy-es.html',
      'terms': 'web/terms-es.html',
      'support': 'web/support-es.html',
    },
    'pt-BR': <String, String>{
      'privacy': 'web/privacy-pt-br.html',
      'terms': 'web/terms-pt-br.html',
      'support': 'web/support-pt-br.html',
    },
  };

  test('all five launch languages ship privacy, terms, and support pages', () {
    for (final languageEntry in pagesByLanguage.entries) {
      for (final pageEntry in languageEntry.value.entries) {
        final file = File(pageEntry.value);
        expect(file.existsSync(), isTrue, reason: pageEntry.value);
        final content = file.readAsStringSync();
        expect(
          content,
          contains('<html lang="${languageEntry.key}">'),
          reason: pageEntry.value,
        );
        expect(content, contains('MYSTIC TAROT'), reason: pageEntry.value);
      }
    }
  });

  test('Spanish trust pages stay inside the Spanish experience', () {
    final privacy = File('web/privacy-es.html').readAsStringSync();
    final terms = File('web/terms-es.html').readAsStringSync();
    final support = File('web/support-es.html').readAsStringSync();

    expect(privacy, contains('href="terms-es.html"'));
    expect(privacy, contains('href="support-es.html"'));
    expect(terms, contains('href="privacy-es.html"'));
    expect(terms, contains('href="support-es.html"'));
    expect(support, contains('href="privacy-es.html"'));
    expect(support, contains('href="terms-es.html"'));
  });

  test('Brazilian Portuguese trust pages stay inside the Portuguese experience', () {
    final privacy = File('web/privacy-pt-br.html').readAsStringSync();
    final terms = File('web/terms-pt-br.html').readAsStringSync();
    final support = File('web/support-pt-br.html').readAsStringSync();

    expect(privacy, contains('href="terms-pt-br.html"'));
    expect(privacy, contains('href="support-pt-br.html"'));
    expect(terms, contains('href="privacy-pt-br.html"'));
    expect(terms, contains('href="support-pt-br.html"'));
    expect(support, contains('href="privacy-pt-br.html"'));
    expect(support, contains('href="terms-pt-br.html"'));
  });

  test('generic support routes launch languages without trapping English', () {
    final support = File('web/support.html').readAsStringSync();

    for (final target in <String>[
      'support-tr.html',
      'support-fr.html',
      'support-es.html',
      'support-pt-br.html',
    ]) {
      expect(support, contains(target));
    }
    expect(support, contains("params.get('stay') === 'en'"));

    for (final path in <String>[
      'web/support-tr.html',
      'web/support-fr.html',
      'web/support-es.html',
      'web/support-pt-br.html',
    ]) {
      expect(
        File(path).readAsStringSync(),
        contains('support.html?stay=en'),
        reason: path,
      );
    }
  });

  test('sitemap indexes every public trust page', () {
    final sitemap = File('web/sitemap.xml').readAsStringSync();
    for (final pages in pagesByLanguage.values) {
      for (final path in pages.values) {
        expect(
          sitemap,
          contains(path.replaceFirst('web/', '')),
          reason: path,
        );
      }
    }
  });
}
