import 'package:flutter_test/flutter_test.dart';
import '../tool/src/app_ads_readiness.dart';
import '../tool/src/public_store_urls.dart';

void main() {
  const appId = 'ca-app-pub-1234567890123456~1234567890';

  test('publisher id is derived from the configured AdMob app id', () {
    expect(
      publisherIdFromAdMobAppId(appId),
      'pub-1234567890123456',
    );
    expect(publisherIdFromAdMobAppId('invalid'), isNull);
  });

  test('valid Google DIRECT app-ads record passes', () {
    final errors = validateAppAdsResponse(
      appId: appId,
      response: const PublicStoreResponse(
        statusCode: 200,
        body:
            'google.com, pub-1234567890123456, DIRECT, f08c47fec0942fa0\n',
      ),
    );
    expect(errors, isEmpty);
  });

  test('wrong publisher or missing file fails closed', () {
    expect(
      validateAppAdsResponse(
        appId: appId,
        response: const PublicStoreResponse(
          statusCode: 200,
          body: 'google.com, pub-9999999999999999, DIRECT, f08c47fec0942fa0',
        ),
      ),
      isNotEmpty,
    );
    expect(
      validateAppAdsResponse(
        appId: appId,
        response: const PublicStoreResponse(statusCode: 404, body: ''),
      ),
      isNotEmpty,
    );
  });

  test('live verifier retries and accepts the exact publisher record', () async {
    var calls = 0;
    final errors = await verifyPublicAppAds(
      appId: appId,
      attempts: 2,
      retryDelay: Duration.zero,
      fetcher: (uri) async {
        expect(uri, publicAppAdsUri);
        calls += 1;
        if (calls == 1) {
          return const PublicStoreResponse(statusCode: 503, body: '');
        }
        return const PublicStoreResponse(
          statusCode: 200,
          body:
              '# Mystic Tarot\ngoogle.com, pub-1234567890123456, DIRECT, f08c47fec0942fa0',
        );
      },
    );

    expect(errors, isEmpty);
    expect(calls, 2);
  });
}
