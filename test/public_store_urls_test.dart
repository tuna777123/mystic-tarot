import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/public_store_urls.dart';

void main() {
  test('public store endpoints cover the live app and store-facing pages', () {
    expect(
      publicStoreEndpoints.map((endpoint) => endpoint.path).toList(),
      <String>[
        '',
        'landing.html',
        'privacy.html',
        'terms.html',
        'support.html',
      ],
    );
    expect(
      publicStoreEndpoints.map((endpoint) => endpoint.marker).toSet(),
      containsAll(<String>{
        'flutter_bootstrap.js',
        'Kartların ötesini',
        '<h1>Privacy Policy</h1>',
        '<h1>Terms of Use</h1>',
        '<h1>Support</h1>',
      }),
    );
  });

  test('accepts only HTTP 200 with the endpoint-specific marker', () {
    final endpoint = publicStoreEndpoints[2];

    expect(
      validatePublicStoreResponse(
        endpoint,
        PublicStoreResponse(
          statusCode: HttpStatus.ok,
          body: endpoint.marker,
        ),
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

  test('retries transient failures and succeeds without hiding endpoints', () async {
    final callsByUri = <Uri, int>{};
    final errors = await verifyPublicStoreEndpoints(
      attempts: 3,
      retryDelay: Duration.zero,
      fetcher: (uri) async {
        final calls = callsByUri.update(uri, (value) => value + 1, ifAbsent: () => 1);
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
  });

  test('reports unreachable and stale pages without exposing response bodies', () async {
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
  });

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
    final iosPreflight = workflow.indexOf('Validate protected iOS release inputs');
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
