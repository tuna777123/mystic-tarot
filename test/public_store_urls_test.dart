import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/public_store_urls.dart';

void main() {
  const expectedEndpoints = <String, String>{
    '': 'flutter_bootstrap.js',
    'landing.html': 'Kartların ötesini',
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

  test('public store endpoints cover every live launch-language page', () {
    expect(publicStoreEndpoints, hasLength(expectedEndpoints.length));
    expect(
      publicStoreEndpoints.map((endpoint) => endpoint.path).toList(),
      expectedEndpoints.keys.toList(),
    );
    expect(
      publicStoreEndpoints.map((endpoint) => endpoint.marker).toList(),
      expectedEndpoints.values.toList(),
    );
  });

  test('accepts only HTTP 200 with the endpoint-specific marker', () {
    final endpoint = publicStoreEndpoints[2];

    expect(
      validatePublicStoreResponse(
        endpoint,
        PublicStoreResponse(statusCode: HttpStatus.ok, body: endpoint.marker),
      ),
      isEmpty,
    );
    expect(
      validatePublicStoreResponse(
        endpoint,
        const PublicStoreResponse(statusCode: 404, body: 'Not found'),
      ),
      hasLength(2),
    );
  });

  test(
    'retries transient failures and succeeds without hiding endpoints',
    () async {
      final callsByUri = <Uri, int>{};
      final errors = await verifyPublicStoreEndpoints(
        attempts: 3,
        retryDelay: Duration.zero,
        fetcher: (uri) async {
          final calls = callsByUri.update(
            uri,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
          if (calls == 1) throw const SocketException('temporary failure');
          final endpoint = publicStoreEndpoints.firstWhere(
            (candidate) => candidate.uri == uri,
          );
          return PublicStoreResponse(
            statusCode: HttpStatus.ok,
            body: endpoint.marker,
          );
        },
      );

      expect(errors, isEmpty);
      expect(callsByUri.length, publicStoreEndpoints.length);
      expect(callsByUri.values, everyElement(2));
    },
  );

  test(
    'reports unreachable and stale pages without exposing response bodies',
    () async {
      final errors = await verifyPublicStoreEndpoints(
        attempts: 2,
        retryDelay: Duration.zero,
        fetcher: (uri) async {
          if (uri.path.endsWith('support.html')) {
            throw const SocketException('private network detail');
          }
          return const PublicStoreResponse(
            statusCode: HttpStatus.ok,
            body: 'generic page',
          );
        },
      );

      expect(errors, hasLength(publicStoreEndpoints.length));
      expect(errors.join('\n'), contains('expected page marker'));
      expect(errors.join('\n'), contains('could not be reached'));
      expect(errors.join('\n'), isNot(contains('private network detail')));
      expect(errors.join('\n'), isNot(contains('generic page')));
    },
  );

  test('signed Android and iOS releases require the live URL verifier', () {
    final preflight = File(
      'tool/store_release_preflight.dart',
    ).readAsStringSync();
    final workflow = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();
    final pages = File('.github/workflows/pages.yml').readAsStringSync();

    expect(preflight, contains("import 'src/public_store_urls.dart';"));
    expect(preflight, contains('await verifyPublicStoreEndpoints()'));
    expect(preflight, contains('Verified \${publicStoreEndpoints.length}'));

    final androidPreflight = workflow.indexOf(
      'Validate protected Android release inputs',
    );
    final androidSigning = workflow.indexOf(
      'Install and verify Android upload key',
    );
    final iosPreflight = workflow.indexOf(
      'Validate protected iOS release inputs',
    );
    final iosSigning = workflow.indexOf(
      'Install and verify Apple signing identity',
    );
    expect(androidPreflight, greaterThanOrEqualTo(0));
    expect(androidSigning, greaterThan(androidPreflight));
    expect(iosPreflight, greaterThanOrEqualTo(0));
    expect(iosSigning, greaterThan(iosPreflight));

    for (final endpoint in publicStoreEndpoints) {
      expect(pages, contains(endpoint.path));
      expect(pages, contains(endpoint.marker));
    }
  });
}
