import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/app_language.dart';
import 'package:mystic_tarot/src/store_purchase_service.dart';
import 'package:mystic_tarot/src/store_status_localization.dart';

void main() {
  test('every purchase notice has distinct Turkish copy', () {
    for (final notice in StorePurchaseNotice.values) {
      final english = localizedStorePurchaseNotice(AppLanguage.english, notice);
      final turkish = localizedStorePurchaseNotice(AppLanguage.turkish, notice);

      expect(english.trim(), isNotEmpty, reason: notice.name);
      expect(turkish.trim(), isNotEmpty, reason: notice.name);
      expect(turkish, isNot(equals(english)), reason: notice.name);
    }
  });

  test('Turkish store states use safe customer-facing language', () {
    expect(
      localizedStorePurchaseNotice(
        AppLanguage.turkish,
        StorePurchaseNotice.nativeOnly,
      ),
      'Abonelikler yalnızca iOS ve Android uygulamalarında kullanılabilir.',
    );
    expect(
      localizedStorePurchaseNotice(
        AppLanguage.turkish,
        StorePurchaseNotice.purchaseCompleted,
      ),
      contains('doğrulandı'),
    );
    expect(
      localizedStorePurchaseNotice(
        AppLanguage.turkish,
        StorePurchaseNotice.purchaseCancelled,
      ),
      contains('Herhangi bir ücret alınmadı'),
    );
  });

  test('all supported interface languages resolve every purchase notice', () {
    for (final language in AppLanguage.values) {
      for (final notice in StorePurchaseNotice.values) {
        expect(
          localizedStorePurchaseNotice(language, notice).trim(),
          isNotEmpty,
          reason: '${language.name}/${notice.name}',
        );
      }
    }
  });
}
