import '../configure_store_identifiers.dart';

class IosAdMobPlistAuditFailure implements Exception {
  const IosAdMobPlistAuditFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class IosAdMobPlistAuditResult {
  const IosAdMobPlistAuditResult({
    required this.appId,
    required this.skAdNetworkCount,
  });

  final String appId;
  final int skAdNetworkCount;
}

IosAdMobPlistAuditResult auditIosAdMobPlistXml(
  String xml, {
  required String expectedAppId,
}) {
  final appIdMatches = RegExp(
    r'<key>GADApplicationIdentifier</key>\s*<string>([^<]+)</string>',
    multiLine: true,
  ).allMatches(xml).toList(growable: false);
  if (appIdMatches.length != 1) {
    throw IosAdMobPlistAuditFailure(
      'Expected exactly one GADApplicationIdentifier, found '
      '${appIdMatches.length}.',
    );
  }
  final appId = appIdMatches.single.group(1)!;
  if (appId != expectedAppId) {
    throw IosAdMobPlistAuditFailure(
      'Exported iOS AdMob application ID does not match the protected '
      'production value.',
    );
  }

  final skAdNetworkBlockMatches = RegExp(
    r'<key>SKAdNetworkItems</key>\s*<array>(.*?)</array>',
    multiLine: true,
    dotAll: true,
  ).allMatches(xml).toList(growable: false);
  if (skAdNetworkBlockMatches.length != 1) {
    throw IosAdMobPlistAuditFailure(
      'Expected exactly one SKAdNetworkItems array, found '
      '${skAdNetworkBlockMatches.length}.',
    );
  }

  final identifiers =
      RegExp(
            r'<key>SKAdNetworkIdentifier</key>\s*<string>([^<]+)</string>',
            multiLine: true,
          )
          .allMatches(skAdNetworkBlockMatches.single.group(1)!)
          .map((match) => match.group(1)!)
          .toList(growable: false);
  final uniqueIdentifiers = identifiers.toSet();
  if (identifiers.length != uniqueIdentifiers.length) {
    throw const IosAdMobPlistAuditFailure(
      'Exported iOS SKAdNetworkItems contains duplicate identifiers.',
    );
  }

  final expectedIdentifiers = iosSkAdNetworkIdentifiers.toSet();
  final missing = expectedIdentifiers.difference(uniqueIdentifiers).toList()
    ..sort();
  final unexpected = uniqueIdentifiers.difference(expectedIdentifiers).toList()
    ..sort();
  if (missing.isNotEmpty || unexpected.isNotEmpty) {
    throw IosAdMobPlistAuditFailure(
      'Exported iOS SKAdNetworkItems does not match the reviewed '
      '$iosSkAdNetworkSourceReviewedOn catalog. '
      'Missing: ${missing.isEmpty ? 'none' : missing.join(', ')}. '
      'Unexpected: ${unexpected.isEmpty ? 'none' : unexpected.join(', ')}.',
    );
  }

  return IosAdMobPlistAuditResult(
    appId: appId,
    skAdNetworkCount: identifiers.length,
  );
}
