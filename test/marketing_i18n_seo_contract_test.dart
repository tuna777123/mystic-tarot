import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('international marketing pages stay complete, linked, and honest', () {
    const pages = <String, String>{
      'web/landing-en.html': 'lang="en"',
      'web/landing-es.html': 'lang="es"',
      'web/landing-fr.html': 'lang="fr"',
      'web/landing-pt-br.html': 'lang="pt-BR"',
    };

    for (final entry in pages.entries) {
      final file = File(entry.key);
      expect(file.existsSync(), isTrue, reason: '${entry.key} must exist');
      final page = file.readAsStringSync();
      expect(page, contains(entry.value));
      expect(page, contains('rel="canonical"'));
      expect(page, contains('hreflang="tr"'));
      expect(page, contains('hreflang="en"'));
      expect(page, contains('hreflang="es"'));
      expect(page, contains('hreflang="fr"'));
      expect(page, contains('hreflang="pt-BR"'));
      expect(page, contains('hreflang="x-default"'));
      expect(page, contains('application/ld+json'));
      expect(page, contains('Mystic Mirror'));
      expect(page, contains('Oracle Dialogue'));
      expect(page, contains('Inner Constellation'));
      expect(page, contains('Arcana Vault'));
      expect(page, contains('marketing-i18n.css'));
      expect(page, contains('marketing-i18n.js'));
      expect(page, contains('href="./"'));
      expect(page, isNot(contains('aggregateRating')));
      expect(page, isNot(contains('million users')));
      expect(page, isNot(contains('millones de usuarios')));
      expect(page, isNot(contains('millions d’utilisateurs')));
      expect(page, isNot(contains('milhões de usuários')));
      expect(page, isNot(contains(r'$9.99')));
      expect(page, isNot(contains('limited time')));
      expect(page, isNot(contains('tiempo limitado')));
      expect(page, isNot(contains('durée limitée')));
      expect(page, isNot(contains('tempo limitado')));
    }
  });

  test('multilingual discovery files cover every launch locale', () {
    final sitemap = File('web/sitemap.xml').readAsStringSync();
    final robots = File('web/robots.txt').readAsStringSync();
    final notFound = File('web/404.html').readAsStringSync();

    for (final path in <String>[
      'landing.html',
      'landing-en.html',
      'landing-es.html',
      'landing-fr.html',
      'landing-pt-br.html',
    ]) {
      expect(sitemap, contains(path));
      expect(notFound, contains(path));
    }

    for (final locale in <String>[
      'tr',
      'en',
      'es',
      'fr',
      'pt-BR',
      'x-default',
    ]) {
      expect(sitemap, contains('hreflang="$locale"'));
    }

    expect(sitemap, contains('xmlns:xhtml='));
    expect(
      robots,
      contains('https://tuna777123.github.io/mystic-tarot/sitemap.xml'),
    );
    expect(notFound, contains('name="robots" content="noindex,follow"'));
    expect(File('web/marketing-i18n.css').existsSync(), isTrue);
    expect(File('web/marketing-i18n.js').existsSync(), isTrue);
  });
}
