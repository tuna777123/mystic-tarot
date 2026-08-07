import 'dart:convert';

enum StoreReleasePlatform { android, ios }

class StoreReleaseContract {
  const StoreReleaseContract._();

  static const appName = 'Mystic Tarot';
  static const bundleIdentifier = 'com.tunabozcali.mystictarot';
  static const monetizationModel = 'advertising-only';

  static const androidRequiredEnvironment = <String>[
    'ADMOB_ANDROID_APP_ID',
    'ADMOB_ANDROID_APP_OPEN_ID',
    'ADMOB_ANDROID_INTERSTITIAL_ID',
    'ANDROID_UPLOAD_KEYSTORE_BASE64',
    'ANDROID_KEY_ALIAS',
    'ANDROID_KEY_PASSWORD',
    'ANDROID_STORE_PASSWORD',
    'ANDROID_UPLOAD_CERT_SHA256',
  ];

  static const iosRequiredEnvironment = <String>[
    'ADMOB_IOS_APP_ID',
    'ADMOB_IOS_APP_OPEN_ID',
    'ADMOB_IOS_INTERSTITIAL_ID',
    'IOS_DISTRIBUTION_CERTIFICATE_BASE64',
    'IOS_DISTRIBUTION_CERTIFICATE_PASSWORD',
    'IOS_DISTRIBUTION_CERT_SHA256',
    'IOS_PROVISIONING_PROFILE_BASE64',
    'IOS_TEAM_ID',
  ];
}

StoreReleasePlatform parseStoreReleasePlatform(String value) {
  return switch (value.trim().toLowerCase()) {
    'android' => StoreReleasePlatform.android,
    'ios' => StoreReleasePlatform.ios,
    _ => throw FormatException('Unsupported store platform: $value'),
  };
}

List<String> missingEnvironmentValues(
  Map<String, String> environment,
  Iterable<String> requiredNames,
) {
  return requiredNames
      .where((name) => (environment[name] ?? '').trim().isEmpty)
      .toList(growable: false);
}

List<String> validateAdMobAppId(String value, {required String label}) {
  final appId = value.trim();
  if (appId.isEmpty) return ['$label is missing.'];
  if (!RegExp(r'^ca-app-pub-\d{16}~\d{10}$').hasMatch(appId)) {
    return ['$label must be a valid AdMob application ID.'];
  }
  if (appId == 'ca-app-pub-3940256099942544~3347511713' ||
      appId == 'ca-app-pub-3940256099942544~1458002511') {
    return ['$label must not use a Google demo application ID in production.'];
  }
  return const [];
}

List<String> validateAdMobAdUnitId(String value, {required String label}) {
  final adUnitId = value.trim();
  if (adUnitId.isEmpty) return ['$label is missing.'];
  if (!RegExp(r'^ca-app-pub-\d{16}/\d{10}$').hasMatch(adUnitId)) {
    return ['$label must be a valid AdMob ad unit ID.'];
  }
  if (adUnitId.startsWith('ca-app-pub-3940256099942544/')) {
    return ['$label must not use a Google demo ad unit in production.'];
  }
  return const [];
}

List<String> validateBase64Secret(String value, {required String label}) {
  final clean = value.replaceAll(RegExp(r'\s'), '');
  if (clean.isEmpty) return ['$label is missing.'];
  try {
    final decoded = base64Decode(clean);
    if (decoded.isEmpty) return ['$label decodes to an empty file.'];
  } on FormatException {
    return ['$label is not valid base64.'];
  }
  return const [];
}

String normalizeSha256Fingerprint(String value) {
  final fingerprint = value.replaceAll(RegExp(r'[:\s]'), '').toUpperCase();
  if (!RegExp(r'^[0-9A-F]{64}$').hasMatch(fingerprint)) {
    throw const FormatException(
      'SHA-256 certificate fingerprint must contain exactly 64 hexadecimal '
      'characters, with optional colons or whitespace.',
    );
  }
  return fingerprint;
}

List<String> validateSha256Fingerprint(String value, {required String label}) {
  if (value.trim().isEmpty) return ['$label is missing.'];
  try {
    normalizeSha256Fingerprint(value);
  } on FormatException catch (error) {
    return ['$label is invalid: ${error.message}'];
  }
  return const [];
}

List<String> validateTeamIdentifier(String value) {
  final teamId = value.trim();
  if (!RegExp(r'^[A-Z0-9]{10}$').hasMatch(teamId)) {
    return const [
      'Apple Team ID must contain exactly 10 uppercase letters or digits.',
    ];
  }
  return const [];
}

List<String> validateReleaseIdentity({required String bundleIdentifier}) {
  if (bundleIdentifier.trim() != StoreReleaseContract.bundleIdentifier) {
    return [
      'Bundle/application ID must remain ${StoreReleaseContract.bundleIdentifier}.',
    ];
  }
  return const [];
}

String readPubspecVersion(String source) {
  final match = RegExp(
    r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+\+[0-9]+)\s*$',
    multiLine: true,
  ).firstMatch(source);
  if (match == null) {
    throw const FormatException(
      'pubspec.yaml must contain a version in x.y.z+build format.',
    );
  }
  return match.group(1)!;
}

String releaseArtifactName({
  required StoreReleasePlatform platform,
  required String version,
  required String channel,
}) {
  final safeVersion = version.replaceAll('+', '-build');
  final safeChannel = channel
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9-]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  if (safeChannel.isEmpty) {
    throw const FormatException('Release channel cannot be empty.');
  }
  return 'mystic-tarot-$safeVersion-${platform.name}-$safeChannel';
}
