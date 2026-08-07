import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String read(String path) => File(path).readAsStringSync();

void main() {
  group('public launch surface', () {
    test('press kit is indexable, canonical, shareable, and claim-safe', () {
      final html = read('web/press-kit.html');

      expect(html, contains('<meta name="robots" content="index,follow'));
      expect(
        html,
        contains(
          '<link rel="canonical" href="https://tuna777123.github.io/mystic-tarot/press-kit.html">',
        ),
      );
      expect(html, contains('Mystic Tarot — Official Press Kit'));
      expect(html, contains('Public web edition available now'));
      expect(html, contains('Native iOS and Android store candidates'));
      expect(html, contains('No advertising SDK'));
      expect(html, contains('No account is required for the public web experience'));
      expect(html, contains('navigator.share'));
      expect(html, contains('navigator.clipboard'));
      expect(html, contains('privacy.html'));
      expect(html, contains('terms.html'));
      expect(html, contains('support.html'));
      expect(html, contains('EN · TR · ES · FR · PT-BR'));

      for (final forbidden in <String>[
        'Download on the App Store',
        'Get it on Google Play',
        '#1 tarot app',
        'guaranteed prediction',
        'guaranteed future',
        'googletagmanager.com',
        'connect.facebook.net',
        'analytics.tiktok.com',
      ]) {
        expect(html.toLowerCase(), isNot(contains(forbidden.toLowerCase())));
      }
    });

    test('sitemap and robots expose the complete public sharing surface', () {
      final sitemap = read('web/sitemap.xml');
      final robots = read('web/robots.txt');

      expect(
        robots,
        contains('Sitemap: https://tuna777123.github.io/mystic-tarot/sitemap.xml'),
      );
      expect(
        sitemap,
        contains('https://tuna777123.github.io/mystic-tarot/press-kit.html'),
      );

      for (final landing in <String>[
        'landing.html',
        'landing-en.html',
        'landing-es.html',
        'landing-fr.html',
        'landing-pt-br.html',
      ]) {
        expect(
          sitemap,
          contains('https://tuna777123.github.io/mystic-tarot/$landing'),
        );
        expect(File('web/$landing').existsSync(), isTrue, reason: landing);
      }

      for (final localeSuffix in <String>['', '-tr', '-es', '-fr', '-pt-br']) {
        for (final page in <String>['privacy', 'terms', 'support']) {
          expect(
            File('web/$page$localeSuffix.html').existsSync(),
            isTrue,
            reason: '$page$localeSuffix.html',
          );
        }
      }
    });

    test('web entry point remains installable and social-preview ready', () {
      final index = read('web/index.html');
      final manifest = read('web/manifest.json');

      expect(index, contains('<link rel="manifest" href="manifest.json">'));
      expect(index, contains('beforeinstallprompt'));
      expect(index, contains('appinstalled'));
      expect(index, contains('og:title'));
      expect(index, contains('og:description'));
      expect(index, contains('og:image'));
      expect(index, contains('twitter:card'));
      expect(manifest, contains('"display": "standalone"'));
      expect(manifest, contains('"orientation": "portrait-primary"'));
      expect(manifest, contains('"purpose": "maskable"'));
    });
  });

  group('shareable launch handoff', () {
    test('marketing kit is versioned, localized, attributable, and claim-safe', () {
      final kit = read('docs/MARKETING_LAUNCH_KIT.md');
      final pubspec = read('pubspec.yaml');

      expect(pubspec, contains('version: 1.22.3+32'));
      expect(kit, contains('Version: `1.22.3+32`'));
      expect(kit, contains('### English'));
      expect(kit, contains('### Turkish'));
      expect(kit, contains('### Spanish'));
      expect(kit, contains('### French'));
      expect(kit, contains('### Brazilian Portuguese'));
      expect(kit, contains('utm_campaign=launch_1_22_3'));
      expect(kit, contains('Creative guardrails'));
      expect(kit, contains('fabricated testimonials'));
      expect(kit, contains('fake user counts'));
      expect(kit, contains('App Store / Google Play badges before'));
      expect(kit, contains('Do not add third-party tracking scripts'));
    });

    test('release pack and marketing kit agree on the product boundary', () {
      final release = read('STORE_RELEASE.md');
      final kit = read('docs/MARKETING_LAUNCH_KIT.md');

      for (final required in <String>[
        'Mystic Mirror',
        'local-first',
        'mystic_plus',
        'mystic_plus_monthly',
        'mystic_plus_yearly',
      ]) {
        expect(release.toLowerCase(), contains(required.toLowerCase()));
      }

      expect(kit.toLowerCase(), contains('reflection'));
      expect(kit.toLowerCase(), contains('entertainment'));
      expect(kit.toLowerCase(), contains('do not market mystic tarot as'));
      expect(kit.toLowerCase(), contains('hardcoded subscription prices'));
      expect(release.toLowerCase(), contains('do not hardcode price text'));
    });
  });
}
