import 'dart:async';
import 'dart:convert';
import 'dart:io';

const publicStoreBaseUrl = 'https://tuna777123.github.io/mystic-tarot/';

class PublicStoreEndpoint {
  const PublicStoreEndpoint({required this.path, required this.marker});

  final String path;
  final String marker;

  Uri get uri => Uri.parse(publicStoreBaseUrl).resolve(path);
}

const publicStoreEndpoints = <PublicStoreEndpoint>[
  PublicStoreEndpoint(path: '', marker: 'flutter_bootstrap.js'),
  PublicStoreEndpoint(path: 'landing.html', marker: 'Kartların ötesini'),
  PublicStoreEndpoint(path: 'privacy.html', marker: '<h1>Privacy Policy</h1>'),
  PublicStoreEndpoint(
    path: 'privacy-tr.html',
    marker: '<h1>Gizlilik Politikası</h1>',
  ),
  PublicStoreEndpoint(
    path: 'privacy-es.html',
    marker: '<h1>Política de privacidad</h1>',
  ),
  PublicStoreEndpoint(
    path: 'privacy-fr.html',
    marker: '<h1>Politique de confidentialité</h1>',
  ),
  PublicStoreEndpoint(
    path: 'privacy-pt-br.html',
    marker: '<h1>Política de Privacidade</h1>',
  ),
  PublicStoreEndpoint(path: 'terms.html', marker: '<h1>Terms of Use</h1>'),
  PublicStoreEndpoint(
    path: 'terms-tr.html',
    marker: '<h1>Kullanım Koşulları</h1>',
  ),
  PublicStoreEndpoint(
    path: 'terms-es.html',
    marker: '<h1>Condiciones de uso</h1>',
  ),
  PublicStoreEndpoint(
    path: 'terms-fr.html',
    marker: '<h1>Conditions d’utilisation</h1>',
  ),
  PublicStoreEndpoint(
    path: 'terms-pt-br.html',
    marker: '<h1>Termos de Uso</h1>',
  ),
  PublicStoreEndpoint(path: 'support.html', marker: '<h1>Support</h1>'),
  PublicStoreEndpoint(path: 'support-tr.html', marker: '<h1>Destek</h1>'),
  PublicStoreEndpoint(path: 'support-es.html', marker: '<h1>Soporte</h1>'),
  PublicStoreEndpoint(path: 'support-fr.html', marker: '<h1>Assistance</h1>'),
  PublicStoreEndpoint(path: 'support-pt-br.html', marker: '<h1>Suporte</h1>'),
];

class PublicStoreResponse {
  const PublicStoreResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

typedef PublicStoreFetcher = Future<PublicStoreResponse> Function(Uri uri);

Future<List<String>> verifyPublicStoreEndpoints({
  PublicStoreFetcher? fetcher,
  int attempts = 3,
  Duration retryDelay = const Duration(seconds: 5),
}) async {
  if (attempts < 1) {
    throw ArgumentError.value(attempts, 'attempts', 'Must be at least one.');
  }

  final request = fetcher ?? fetchPublicStoreUrl;
  final endpointErrors = await Future.wait(
    publicStoreEndpoints.map(
      (endpoint) => _verifyPublicStoreEndpoint(
        endpoint,
        request: request,
        attempts: attempts,
        retryDelay: retryDelay,
      ),
    ),
  );
  return endpointErrors.expand((errors) => errors).toList(growable: false);
}

Future<List<String>> _verifyPublicStoreEndpoint(
  PublicStoreEndpoint endpoint, {
  required PublicStoreFetcher request,
  required int attempts,
  required Duration retryDelay,
}) async {
  List<String> latestErrors = const [];
  Object? latestFailure;

  for (var attempt = 1; attempt <= attempts; attempt++) {
    try {
      final response = await request(endpoint.uri);
      latestErrors = validatePublicStoreResponse(endpoint, response);
      latestFailure = null;
      if (latestErrors.isEmpty) return const [];
    } catch (error) {
      latestFailure = error;
      latestErrors = const [];
    }

    if (attempt < attempts && retryDelay > Duration.zero) {
      await Future<void>.delayed(retryDelay);
    }
  }

  if (latestFailure != null) {
    return <String>[
      '${endpoint.uri} could not be reached after $attempts attempts.',
    ];
  }
  return latestErrors;
}

List<String> validatePublicStoreResponse(
  PublicStoreEndpoint endpoint,
  PublicStoreResponse response,
) {
  final errors = <String>[];
  if (response.statusCode != HttpStatus.ok) {
    errors.add('${endpoint.uri} returned HTTP ${response.statusCode}.');
  }
  if (!response.body.contains(endpoint.marker)) {
    errors.add('${endpoint.uri} did not contain its expected page marker.');
  }
  return errors;
}

Future<PublicStoreResponse> fetchPublicStoreUrl(Uri uri) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  client.userAgent = 'MysticTarotStoreReleasePreflight/1.0';

  try {
    final request = await client
        .getUrl(uri)
        .timeout(const Duration(seconds: 20));
    request.followRedirects = true;
    request.maxRedirects = 5;
    final response = await request.close().timeout(const Duration(seconds: 30));
    final body = await utf8.decoder
        .bind(response)
        .join()
        .timeout(const Duration(seconds: 30));
    return PublicStoreResponse(statusCode: response.statusCode, body: body);
  } finally {
    client.close(force: true);
  }
}
