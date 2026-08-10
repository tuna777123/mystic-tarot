import 'package:flutter_test/flutter_test.dart';

import '../tool/configure_store_identifiers.dart';

void main() {
  const productionLikeAppId = 'ca-app-pub-1234567890123456~1234567890';
  const minimalPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
\t<key>CFBundleDisplayName</key>
\t<string>Mystic Tarot</string>
</dict>
</plist>
''';

  test('locks the reviewed Google iOS SKAdNetwork catalog', () {
    expect(iosSkAdNetworkSourceReviewedOn, '2026-07-22');
    expect(iosSkAdNetworkIdentifiers, hasLength(50));
    expect(iosSkAdNetworkIdentifiers.toSet(), hasLength(50));
    expect(iosSkAdNetworkIdentifiers.first, 'cstr6suwn9.skadnetwork');
    expect(
      iosSkAdNetworkIdentifiers.every(
        (identifier) =>
            RegExp(r'^[a-z0-9]{10}\.skadnetwork$').hasMatch(identifier),
      ),
      isTrue,
    );
  });

  test('materializes the app id and every SKAdNetwork identifier once', () {
    final materialized = materializeIosAdMobPlist(
      minimalPlist,
      productionLikeAppId,
    );

    expect(
      RegExp(r'<key>GADApplicationIdentifier</key>').allMatches(materialized),
      hasLength(1),
    );
    expect(materialized, contains('<string>$productionLikeAppId</string>'));
    expect(
      RegExp(r'<key>SKAdNetworkItems</key>').allMatches(materialized),
      hasLength(1),
    );
    for (final identifier in iosSkAdNetworkIdentifiers) {
      expect(
        RegExp(RegExp.escape(identifier)).allMatches(materialized),
        hasLength(1),
        reason: identifier,
      );
    }
  });

  test('materialization is byte-for-byte idempotent', () {
    final first = materializeIosAdMobPlist(minimalPlist, productionLikeAppId);
    final second = materializeIosAdMobPlist(first, productionLikeAppId);

    expect(second, first);
  });

  test('replaces an old app id and stale SKAdNetwork block', () {
    const stale = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
\t<key>GADApplicationIdentifier</key>
\t<string>ca-app-pub-3940256099942544~1458002511</string>
\t<key>SKAdNetworkItems</key>
\t<array>
\t\t<dict>
\t\t\t<key>SKAdNetworkIdentifier</key>
\t\t\t<string>aaaaaaaaaa.skadnetwork</string>
\t\t</dict>
\t</array>
</dict>
</plist>
''';

    final materialized = materializeIosAdMobPlist(stale, productionLikeAppId);

    expect(materialized, isNot(contains('aaaaaaaaaa.skadnetwork')));
    expect(materialized, contains('<string>$productionLikeAppId</string>'));
    expect(
      RegExp(r'<key>SKAdNetworkItems</key>').allMatches(materialized),
      hasLength(1),
    );
    for (final identifier in iosSkAdNetworkIdentifiers) {
      expect(materialized, contains('<string>$identifier</string>'));
    }
  });

  test('fails closed when Info.plist has no root dictionary', () {
    expect(
      () => materializeIosAdMobPlist(
        '<plist version="1.0"></plist>',
        productionLikeAppId,
      ),
      throwsStateError,
    );
  });
}
