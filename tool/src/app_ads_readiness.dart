import 'dart:io';

import 'public_store_urls.dart';

const _googleSellerId = 'f08c47fec0942fa0';

Uri get publicAppAdsUri =>
    Uri.parse(publicStoreBaseUrl).resolve('app-ads.txt');

String? publisherIdFromAdMobAppId(String appId) {
  final match = RegExp(r'^ca-app-pub-(\d+)~\d+$').firstMatch(appId.trim());
  final publisherDigits = match?.group(1);
  if (publisherDigits == null || publisherDigits.isEmpty) return null;
  return 'pub-$publisherDigits';
}

List<String> validateAppAdsResponse({
  required String appId,
  required PublicStoreResponse response,
}) {
  final publisherId = publisherIdFromAdMobAppId(appId);
  if (publisherId == null) {
    return const <String>['AdMob application ID could not yield a publisher ID.'];
  }

  final errors = <String>[];
  if (response.statusCode != HttpStatus.ok) {
    errors.add('$publicAppAdsUri returned HTTP ${response.statusCode}.');
    return errors;
  }

  final found = response.body
      .split(RegExp(r'\r?\n'))
      .map((line) => line.split('#').first.trim())
      .where((line) => line.isNotEmpty)
      .map((line) => line.split(',').map((field) => field.trim()).toList())
      .any(
        (fields) =>
            fields.length >= 4 &&
            fields[0].toLowerCase() == 'google.com' &&
            fields[1] == publisherId &&
            fields[2].toUpperCase() == 'DIRECT' &&
            fields[3].toLowerCase() == _googleSellerId,
      );

  if (!found) {
    errors.add(
      '$publicAppAdsUri is missing the Google DIRECT record for the configured AdMob publisher.',
    );
  }
  return errors;
}

Future<List<String>> verifyPublicAppAds({
  required String appId,
  PublicStoreFetcher? fetcher,
  int attempts = 3,
  Duration retryDelay = const Duration(seconds: 5),
}) async {
  if (attempts < 1) {
    throw ArgumentError.value(attempts, 'attempts', 'Must be at least one.');
  }

  final request = fetcher ?? fetchPublicStoreUrl;
  List<String> latestErrors = const <String>[];
  Object? latestFailure;

  for (var attempt = 1; attempt <= attempts; attempt++) {
    try {
      final response = await request(publicAppAdsUri);
      latestErrors = validateAppAdsResponse(appId: appId, response: response);
      latestFailure = null;
      if (latestErrors.isEmpty) return const <String>[];
    } catch (error) {
      latestFailure = error;
      latestErrors = const <String>[];
    }

    if (attempt < attempts && retryDelay > Duration.zero) {
      await Future<void>.delayed(retryDelay);
    }
  }

  if (latestFailure != null) {
    return <String>[
      '$publicAppAdsUri could not be reached after $attempts attempts.',
    ];
  }
  return latestErrors;
}
