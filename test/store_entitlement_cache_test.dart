import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/store_entitlement_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const cache = SharedPreferencesMysticEntitlementCache();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists only coarse verified entitlement metadata', () async {
    final snapshot = MysticEntitlementSnapshot(
      productId: 'mystic_plus_yearly',
      verifiedAt: DateTime.utc(2026, 7, 29, 1, 30),
      expiresAt: DateTime.utc(2027, 7, 29, 1, 30),
    );

    await cache.save(snapshot);
    final restored = await cache.load();

    expect(restored, isNotNull);
    expect(restored!.productId, snapshot.productId);
    expect(restored.verifiedAt, snapshot.verifiedAt);
    expect(restored.expiresAt, snapshot.expiresAt);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getKeys(),
      {
        'mystic_entitlement_product_id',
        'mystic_entitlement_verified_at',
        'mystic_entitlement_expires_at',
      },
    );
  });

  test('clears malformed cached entitlement metadata', () async {
    SharedPreferences.setMockInitialValues({
      'mystic_entitlement_product_id': 'mystic_plus_monthly',
      'mystic_entitlement_verified_at': 'not-a-date',
      'mystic_entitlement_expires_at': 'also-not-a-date',
    });

    expect(await cache.load(), isNull);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), isEmpty);
  });

  test('evaluates entitlement activity in UTC', () {
    final snapshot = MysticEntitlementSnapshot(
      productId: 'mystic_plus_monthly',
      verifiedAt: DateTime.utc(2026, 7, 1),
      expiresAt: DateTime.utc(2026, 8, 1),
    );

    expect(snapshot.isActiveAt(DateTime.utc(2026, 7, 31)), isTrue);
    expect(snapshot.isActiveAt(DateTime.utc(2026, 8, 1)), isFalse);
  });

  test('clear removes the complete entitlement snapshot', () async {
    await cache.save(
      MysticEntitlementSnapshot(
        productId: 'mystic_plus_yearly',
        verifiedAt: DateTime.utc(2026, 7, 29),
        expiresAt: DateTime.utc(2027, 7, 29),
      ),
    );

    await cache.clear();

    expect(await cache.load(), isNull);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), isEmpty);
  });
}
