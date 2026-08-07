import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/monetization.dart';

void main() {
  group('native store catalog', () {
    test('uses permanent launch identifiers', () {
      expect(MysticPlan.monthly.productId, MysticProductIds.monthly);
      expect(MysticPlan.yearly.productId, MysticProductIds.yearly);
      expect(MysticProductIds.monthly, 'mystic_plus_monthly');
      expect(MysticProductIds.yearly, 'mystic_plus_yearly');
    });

    test('launches with yearly and monthly only', () {
      expect(MysticOffer.launchCatalog.map((offer) => offer.plan), [
        MysticPlan.yearly,
        MysticPlan.monthly,
      ]);
      expect(MysticProductIds.launch, <String>{
        MysticProductIds.monthly,
        MysticProductIds.yearly,
      });
      expect(MysticProductIds.launch, isNot(contains(MysticProductIds.weekly)));
      expect(MysticProductIds.launch.difference(MysticProductIds.all), isEmpty);
    });
  });
}
