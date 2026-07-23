import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/monetization.dart';

void main() {
  test('native store catalog uses permanent launch identifiers', () {
    expect(MysticPlan.monthly.productId, 'mystic_plus_monthly');
    expect(MysticPlan.yearly.productId, 'mystic_plus_yearly');
    expect(MysticOffer.launchCatalog.map((offer) => offer.plan), [
      MysticPlan.yearly,
      MysticPlan.monthly,
    ]);
  });
}
