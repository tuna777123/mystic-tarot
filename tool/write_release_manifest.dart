import 'dart:convert';
import 'dart:io';

import 'configure_store_identifiers.dart' as store_identifiers;
import 'src/ios_admob_plist_audit.dart';
import 'src/ios_artifact_admob.dart';
import 'src/ios_artifact_certificate.dart';
import 'src/ios_privacy_manifest_audit.dart';
import 'src/mobile_ads_sdk_evidence.dart';
import 'src/store_release_contract.dart';

Future<void> main(List<String> arguments) async {
  try {
    final values = _parseArguments(arguments);
    final platform = parseStoreReleasePlatform(_required(values, 'platform'));
    final artifact = File(_required(values, 'artifact'));
    final checksum = _required(values, 'sha256').toLowerCase();
    final output = File(_required(values, 'output'));
    final channel = _required(values, 'channel');

    if (!artifact.existsSync()) {
      throw FormatException(
        'Release artifact does not exist: ${artifact.path}',
      );
    }
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(checksum)) {
      throw const FormatException(
        'Artifact SHA-256 must be 64 hex characters.',
      );
    }

    String? signingCertificateSha256;
    IosAdMobPlistAuditResult? iosAdMobAudit;
    IosPrivacyManifestAuditResult? iosPrivacyManifestAudit;
    if (platform == StoreReleasePlatform.ios) {
      final reviewedFingerprint =
          Platform.environment['IOS_DISTRIBUTION_CERT_SHA256'] ?? '';
      if (reviewedFingerprint.trim().isEmpty) {
        throw const FormatException(
          'IOS_DISTRIBUTION_CERT_SHA256 is required to verify the final IPA.',
        );
      }
      signingCertificateSha256 = await verifyIosArtifactSigningCertificate(
        ipaFile: artifact,
        expectedFingerprint: reviewedFingerprint,
      );

      final productionAdMobAppId =
          Platform.environment['ADMOB_IOS_APP_ID']?.trim() ?? '';
      if (productionAdMobAppId.isEmpty) {
        throw const FormatException(
          'ADMOB_IOS_APP_ID is required to verify the final IPA.',
        );
      }
      try {
        iosAdMobAudit = await verifyIosArtifactAdMobConfiguration(
          ipaFile: artifact,
          expectedAppId: productionAdMobAppId,
        );
      } on IosAdMobPlistAuditFailure catch (error) {
        throw FormatException(error.message);
      }

      try {
        iosPrivacyManifestAudit = await verifyIosArtifactPrivacyManifests(
          ipaFile: artifact,
        );
      } on IosPrivacyManifestAuditFailure catch (error) {
        throw FormatException(error.message);
      }
    }

    final mobileAdsSdkEvidence = await collectMobileAdsSdkEvidence(
      platform: platform,
      androidReportPath: platform == StoreReleasePlatform.android
          ? 'build/release/android/release-runtime-classpath.txt'
          : null,
    );

    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      throw const FormatException('pubspec.yaml was not found.');
    }
    final version = readPubspecVersion(pubspec.readAsStringSync());
    final manifest = <String, Object?>{
      'schemaVersion': 3,
      'app': StoreReleaseContract.appName,
      'version': version,
      'platform': platform.name,
      'channel': channel,
      'bundleIdentifier': StoreReleaseContract.bundleIdentifier,
      'monetizationModel': StoreReleaseContract.monetizationModel,
      'adProvider': 'Google Mobile Ads',
      'consentProvider': 'Google User Messaging Platform',
      'mobileAdsSdkEvidence': mobileAdsSdkEvidence.toJson(),
      'paidProducts': const <String>[],
      'artifact': artifact.uri.pathSegments.last,
      'artifactBytes': artifact.lengthSync(),
      'artifactSha256': checksum,
      if (signingCertificateSha256 != null)
        'signingCertificateSha256': signingCertificateSha256,
      if (iosAdMobAudit != null) ...<String, Object?>{
        'productionAdMobAppIdVerified': true,
        'skAdNetworkCatalogReviewedOn':
            store_identifiers.iosSkAdNetworkSourceReviewedOn,
        'skAdNetworkCount': iosAdMobAudit.skAdNetworkCount,
      },
      if (iosPrivacyManifestAudit != null) ...<String, Object?>{
        'privacyManifestsVerified': true,
        'privacyManifestCount': iosPrivacyManifestAudit.manifestCount,
        'privacyManifestPaths': iosPrivacyManifestAudit.manifestPaths,
      },
      'signed': true,
      'gitSha': Platform.environment['GITHUB_SHA'],
      'sourceRef': Platform.environment['GITHUB_REF_NAME'],
      'builtAtUtc': DateTime.now().toUtc().toIso8601String(),
    };

    output.parent.createSync(recursive: true);
    writeMobileAdsSdkEvidence(
      mobileAdsSdkEvidence,
      '${output.parent.path}/mobile-ads-sdk-evidence.json',
    );
    if (iosPrivacyManifestAudit != null) {
      File(
        '${output.parent.path}/ios-privacy-manifest-evidence.json',
      ).writeAsStringSync(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(iosPrivacyManifestAudit.toJson()),
      );
    }
    output.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(manifest),
    );
    stdout.writeln(
      'Release manifest written for '
      '${releaseArtifactName(platform: platform, version: version, channel: channel)}.',
    );
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(
      'Usage: dart run tool/write_release_manifest.dart '
      '--platform=android|ios --artifact=<path> --sha256=<digest> '
      '--channel=<name> --output=<path>',
    );
    exitCode = 64;
  }
}

Map<String, String> _parseArguments(List<String> arguments) {
  final values = <String, String>{};
  for (final argument in arguments) {
    if (!argument.startsWith('--') || !argument.contains('=')) continue;
    final separator = argument.indexOf('=');
    values[argument.substring(2, separator)] = argument.substring(
      separator + 1,
    );
  }
  return values;
}

String _required(Map<String, String> values, String name) {
  final value = values[name]?.trim();
  if (value == null || value.isEmpty) {
    throw FormatException('The --$name argument is required.');
  }
  return value;
}
