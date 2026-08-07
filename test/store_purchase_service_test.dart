import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/store_purchase_service.dart';

void main() {
  test(
    'ad-only model exposes every formerly gated feature without payment',
    () async {
      final service = StorePurchaseService();

      await service.initialize();

      expect(service.phase, StorePurchasePhase.entitled);
      expect(service.isPlus, isTrue);
      expect(service.canPurchase, isFalse);
      expect(service.canRestore, isFalse);
      expect(service.products, isEmpty);
      expect(service.activeProductId, isNull);
      expect(service.message, contains('ad-supported'));
      service.dispose();
    },
  );

  test('legacy purchase calls cannot create a paid state', () async {
    final service = StorePurchaseService();
    await service.initialize();

    await service.buy(MysticProductIds.monthly);
    await service.restore();
    await service.refreshEntitlement();

    expect(service.isPlus, isTrue);
    expect(service.canPurchase, isFalse);
    expect(service.products, isEmpty);
    expect(service.activeProductId, isNull);
    service.dispose();
  });
}
