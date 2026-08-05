import 'dart:convert';

enum StoreReleasePlatform { android, ios }

class StoreReleaseContract {
  const StoreReleaseContract._();

  static const appName = 'Mystic Tarot';
  static const bundleIdentifier = 'com.tunabozcali.mystictarot';
  static const entitlementId = 'mystic_plus';
  static const monthlyProductId = 'mystic_plus_monthly';
  static const yearlyProductId = 'mystic_plus_yearly';

  static const androidRequiredEnvironment = <String>[
    'REVENUECAT_ANDROID_API_KEY',
    'ANDROID_UPLOAD_KEYSTORE_BASE64',
    'ANDROID_KEY_ALIAS',
    'ANDROID_KEY_PASSWORD',
    'ANDROID_STORE_PASSWORD',
    'ANDROID_UPLOAD_CERT_SHA256',
  ];

  static const iosRequiredEnvironment = <String>[
    'REVENUECAT_IOS_API_KEY',
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

List<String> validateRevenueCatPublicKey(
  String value, {
  required StoreReleasePlatform platform,
}) {
  final key = value.trim();
  final errors = <String>[];
  if (key.isEmpty) {
    return const ['RevenueCat public SDK key is missing.'];
  }
  if (key.length < 12) {
    errors.add('RevenueCat public SDK key is unexpectedly short.');
  }
  if (RegExp(r'\s').hasMatch(key)) {
    errors.add('RevenueCat public SDK key must not contain whitespace.');
  }

  final lower = key.toLowerCase();
  const forbiddenPrefixes = <String>[
    'sk_',
    'secret_',
    'rc_secret_',
    'bearer ',
  ];
  if (forbiddenPrefixes.any(lower.startsWith)) {
    errors.add('A secret API key must never be embedded in a client release.');
  }

  final expectedPrefix =
      platform == StoreReleasePlatform.android ? 'goog_' : 'appl_';
  if (!lower.startsWith(expectedPrefix)) {
    errors.add(
      'RevenueCat key does not match the expected $expectedPrefix public '
      'application-key prefix.',
    );
  }
  return errors;
}

List<String> validateBase64Secret(
  String value, {
  required String label,
}) {
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

List<String> validateSha256Fingerprint(
  String value, {
  required String label,
}) {
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

List<String> validateReleaseIdentity({
  required String bundleIdentifier,
  required String entitlementId,
}) {
  final errors = <String>[];
  if (bundleIdentifier.trim() != StoreReleaseContract.bundleIdentifier) {
    errors.add(
      'Bundle/application ID must remain '
      '${StoreReleaseContract.bundleIdentifier}.',
    );
  }
  if (entitlementId.trim() != StoreReleaseContract.entitlementId) {
    errors.add(
      'RevenueCat entitlement must remain '
      '${StoreReleaseContract.entitlementId}.',
    );
  }
  return errors;
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
