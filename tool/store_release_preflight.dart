import 'dart:io';

import 'src/store_release_contract.dart';

void main(List<String> arguments) {
  try {
    final platform = _platformFromArguments(arguments);
    final environment = Platform.environment;
    final requiredNames = platform == StoreReleasePlatform.android
        ? StoreReleaseContract.androidRequiredEnvironment
        : StoreReleaseContract.iosRequiredEnvironment;
    final missing = missingEnvironmentValues(environment, requiredNames);
    final errors = <String>[
      if (missing.isNotEmpty)
        'Missing protected values: ${missing.join(', ')}.',
      ...validateReleaseIdentity(
        bundleIdentifier: environment['STORE_BUNDLE_ID'] ??
            StoreReleaseContract.bundleIdentifier,
        entitlementId: environment['REVENUECAT_ENTITLEMENT_ID'] ??
            StoreReleaseContract.entitlementId,
      ),
    ];

    if (platform == StoreReleasePlatform.android) {
      errors.addAll(
        validateRevenueCatPublicKey(
          environment['REVENUECAT_ANDROID_API_KEY'] ?? '',
          platform: platform,
        ),
      );
      errors.addAll(
        validateBase64Secret(
          environment['ANDROID_UPLOAD_KEYSTORE_BASE64'] ?? '',
          label: 'Android upload keystore',
        ),
      );
    } else {
      errors.addAll(
        validateRevenueCatPublicKey(
          environment['REVENUECAT_IOS_API_KEY'] ?? '',
          platform: platform,
        ),
      );
      errors.addAll(
        validateBase64Secret(
          environment['IOS_DISTRIBUTION_CERTIFICATE_BASE64'] ?? '',
          label: 'iOS distribution certificate',
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
      stderr.writeln('Store release preflight failed:');
      for (final error in errors) {
        stderr.writeln('- $error');
      }
      exitCode = 1;
      return;
    }

    stdout.writeln(
      'Store release preflight passed for ${platform.name}.',
    );
    stdout.writeln(
      'Validated protected value names: ${requiredNames.join(', ')}.',
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

StoreReleasePlatform _platformFromArguments(List<String> arguments) {
  for (final argument in arguments) {
    if (argument.startsWith('--platform=')) {
      return parseStoreReleasePlatform(argument.substring('--platform='.length));
    }
  }
  throw const FormatException('The --platform argument is required.');
}
