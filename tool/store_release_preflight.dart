import 'dart:io';

import 'src/app_ads_readiness.dart';
import 'src/public_store_urls.dart';
import 'src/store_release_contract.dart';

Future<void> main(List<String> arguments) async {
  try {
    final platform = _platformFromArguments(arguments);
    final environment = Platform.environment;
    final requiredNames = platform == StoreReleasePlatform.android
        ? StoreReleaseContract.androidRequiredEnvironment
        : StoreReleaseContract.iosRequiredEnvironment;
    final adMobAppId = platform == StoreReleasePlatform.android
        ? environment['ADMOB_ANDROID_APP_ID'] ?? ''
        : environment['ADMOB_IOS_APP_ID'] ?? '';
    final missing = missingEnvironmentValues(environment, requiredNames);
    final errors = <String>[
      if (missing.isNotEmpty)
        'Missing protected values: ${missing.join(', ')}.',
      ...validateReleaseIdentity(
        bundleIdentifier:
            environment['STORE_BUNDLE_ID'] ??
            StoreReleaseContract.bundleIdentifier,
      ),
    ];

    if (platform == StoreReleasePlatform.android) {
      errors.addAll(
        validateAdMobAppId(
          adMobAppId,
          label: 'Android AdMob application ID',
        ),
      );
      errors.addAll(
        validateAdMobAdUnitId(
          environment['ADMOB_ANDROID_APP_OPEN_ID'] ?? '',
          label: 'Android app-open ad unit ID',
        ),
      );
      errors.addAll(
        validateAdMobAdUnitId(
          environment['ADMOB_ANDROID_INTERSTITIAL_ID'] ?? '',
          label: 'Android interstitial ad unit ID',
        ),
      );
      errors.addAll(
        validateBase64Secret(
          environment['ANDROID_UPLOAD_KEYSTORE_BASE64'] ?? '',
          label: 'Android upload keystore',
        ),
      );
      errors.addAll(
        validateSha256Fingerprint(
          environment['ANDROID_UPLOAD_CERT_SHA256'] ?? '',
          label: 'Android upload certificate SHA-256 fingerprint',
        ),
      );
    } else {
      errors.addAll(
        validateAdMobAppId(
          adMobAppId,
          label: 'iOS AdMob application ID',
        ),
      );
      errors.addAll(
        validateAdMobAdUnitId(
          environment['ADMOB_IOS_APP_OPEN_ID'] ?? '',
          label: 'iOS app-open ad unit ID',
        ),
      );
      errors.addAll(
        validateAdMobAdUnitId(
          environment['ADMOB_IOS_INTERSTITIAL_ID'] ?? '',
          label: 'iOS interstitial ad unit ID',
        ),
      );
      errors.addAll(
        validateBase64Secret(
          environment['IOS_DISTRIBUTION_CERTIFICATE_BASE64'] ?? '',
          label: 'iOS distribution certificate',
        ),
      );
      errors.addAll(
        validateSha256Fingerprint(
          environment['IOS_DISTRIBUTION_CERT_SHA256'] ?? '',
          label: 'iOS distribution certificate SHA-256 fingerprint',
        ),
      );
      errors.addAll(
        validateBase64Secret(
          environment['IOS_PROVISIONING_PROFILE_BASE64'] ?? '',
          label: 'iOS provisioning profile',
        ),
      );
      errors.addAll(validateTeamIdentifier(environment['IOS_TEAM_ID'] ?? ''));
    }

    if (errors.isNotEmpty) {
      _fail(errors);
      return;
    }

    if (platform == StoreReleasePlatform.ios) {
      final appleSdkResult = await Process.run('bash', [
        'tool/verify_apple_submission_sdk.sh',
      ]);
      if (appleSdkResult.exitCode != 0) {
        final message = '${appleSdkResult.stderr}'.trim();
        _fail([
          message.isEmpty
              ? 'Apple submission SDK verification failed.'
              : message,
        ]);
        return;
      }
      stdout.write(appleSdkResult.stdout);
    }

    final publicUrlErrors = await verifyPublicStoreEndpoints();
    if (publicUrlErrors.isNotEmpty) {
      _fail(publicUrlErrors);
      return;
    }

    final appAdsErrors = await verifyPublicAppAds(appId: adMobAppId);
    if (appAdsErrors.isNotEmpty) {
      _fail(appAdsErrors);
      return;
    }

    stdout.writeln('Store release preflight passed for ${platform.name}.');
    stdout.writeln(
      'Validated protected value names: ${requiredNames.join(', ')}.',
    );
    stdout.writeln(
      'Verified ${publicStoreEndpoints.length} live public store endpoints.',
    );
    stdout.writeln('Verified public app-ads.txt ownership for production ads.');
    stdout.writeln(
      'Production AdMob IDs were validated without printing them.',
    );
    stdout.writeln('No protected values were printed.');
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(
      'Usage: dart run tool/store_release_preflight.dart '
      '--platform=android|ios',
    );
    exitCode = 64;
  }
}

void _fail(List<String> errors) {
  stderr.writeln('Store release preflight failed:');
  for (final error in errors) {
    stderr.writeln('- $error');
  }
  exitCode = 1;
}

StoreReleasePlatform _platformFromArguments(List<String> arguments) {
  for (final argument in arguments) {
    if (argument.startsWith('--platform=')) {
      return parseStoreReleasePlatform(
        argument.substring('--platform='.length),
      );
    }
  }
  throw const FormatException('The --platform argument is required.');
}
