import 'dart:convert';
import 'dart:io';

const _googleSellerId = 'f08c47fec0942fa0';

Future<void> main() async {
  final publisherId = Platform.environment['ADMOB_PUBLISHER_ID']?.trim() ?? '';
  final url = Platform.environment['APP_ADS_TXT_URL']?.trim() ?? '';

  if (!RegExp(r'^pub-\d{10,}$').hasMatch(publisherId)) {
    stderr.writeln(
      'ADMOB_PUBLISHER_ID must be the real AdMob publisher id in pub-<digits> format.',
    );
    exitCode = 2;
    return;
  }

  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.path != '/app-ads.txt' ||
      uri.hasQuery ||
      uri.hasFragment) {
    stderr.writeln(
      'APP_ADS_TXT_URL must be an HTTPS root app-ads.txt URL, for example https://example.com/app-ads.txt.',
    );
    exitCode = 2;
    return;
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final request = await client.getUrl(uri).timeout(const Duration(seconds: 20));
    request.headers.set(HttpHeaders.acceptHeader, 'text/plain,*/*;q=0.8');
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != HttpStatus.ok) {
      stderr.writeln(
        'app-ads.txt returned HTTP ${response.statusCode}: $uri',
      );
      exitCode = 3;
      return;
    }

    final body = await utf8.decoder.bind(response).join();
    final expectedFields = <String>[
      'google.com',
      publisherId,
      'DIRECT',
      _googleSellerId,
    ];
    final found = body
        .split(RegExp(r'\r?\n'))
        .map((line) => line.split('#').first.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.split(',').map((field) => field.trim()).toList())
        .any(
          (fields) =>
              fields.length >= 4 &&
              fields[0].toLowerCase() == expectedFields[0] &&
              fields[1] == expectedFields[1] &&
              fields[2].toUpperCase() == expectedFields[2] &&
              fields[3].toLowerCase() == expectedFields[3],
        );

    if (!found) {
      stderr.writeln(
        'app-ads.txt does not contain the required Google DIRECT record for $publisherId.',
      );
      exitCode = 4;
      return;
    }

    stdout.writeln('Verified production app-ads.txt ownership at $uri.');
  } on Object catch (error) {
    stderr.writeln('Unable to verify app-ads.txt: $error');
    exitCode = 5;
  } finally {
    client.close(force: true);
  }
}
