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
  PublicStoreEndpoint(path: 'terms.html', marker: '<h1>Terms of Use</h1>'),
  PublicStoreEndpoint(path: 'support.html', marker: '<h1>Support</h1>'),
];

class PublicStoreResponse {
  const PublicStoreResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

typedef PublicStoreFetcher = Future<PublicStoreResponse> Function(Uri uri);

Future<List<String>> verifyPublicStoreEndpoints({
  PublicStoreFetcher? fetcher,
  int attempts = 4,
  Duration retryDelay = const Duration(seconds: 5),
}) async {
  if (attempts < 1) {
    throw ArgumentError.value(attempts, 'attempts', 'Must be at least one.');
  }

  final request = fetcher ?? fetchPublicStoreUrl;
  final errors = <String>[];

  for (final endpoint in publicStoreEndpoints) {
    List<String> latestErrors = const [];
    Object? latestFailure;

    for (var attempt = 1; attempt <= attempts; attempt++) {
      try {
        final response = await request(endpoint.uri);
        latestErrors = validatePublicStoreResponse(endpoint, response);
        latestFailure = null;
        if (latestErrors.isEmpty) break;
      } catch (error) {
        latestFailure = error;
        latestErrors = const [];
      }

      if (attempt < attempts && retryDelay > Duration.zero) {
        await Future<void>.delayed(retryDelay);
      }
    }

    if (latestFailure != null) {
      errors.add('${endpoint.uri} could not be reached after $attempts attempts.');
    } else {
      errors.addAll(latestErrors);
    }
  }

  return errors;
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
    final request = await client.getUrl(uri).timeout(const Duration(seconds: 20));
    request.followRedirects = true;
    request.maxRedirects = 5;
    final response = await request.close().timeout(const Duration(seconds: 30));
    final body = await utf8
        .decoder
        .bind(response)
        .join()
        .timeout(const Duration(seconds: 30));
    return PublicStoreResponse(statusCode: response.statusCode, body: body);
  } finally {
    client.close(force: true);
  }
}
