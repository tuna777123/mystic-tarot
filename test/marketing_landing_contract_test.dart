import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('premium marketing landing page stays complete and honest', () {
    final page = File('web/landing.html').readAsStringSync();

    expect(page, contains('<html lang="tr">'));
    expect(
      page,
      contains(
        'Mystic Tarot; günlük tarot ritüelini, 24 saatlik Mystic Mirror',
      ),
    );
    expect(page, contains('Kartların ötesini'));
    expect(page, contains('Kartını çek. Ertesi gün gerçeği kontrol et.'));
    expect(page, contains('id="nasil-calisir"'));
    expect(page, contains('id="ozellikler"'));
    expect(page, contains('id="gizlilik"'));
    expect(page, contains('id="karsilastirma"'));
    expect(page, contains('id="plus"'));
    expect(page, contains('id="sss"'));
    expect(page, contains('Mystic Mirror'));
    expect(page, contains('Oracle Dialogue'));
    expect(page, contains('Inner Constellation'));
    expect(page, contains('Arcana Vault'));
    expect(page, contains('privacy-tr.html'));
    expect(page, contains('terms-tr.html'));
    expect(page, contains('support-tr.html'));
    expect(page, contains('application/ld+json'));
    expect(page, contains('prefers-reduced-motion'));
    expect(page, isNot(contains('href="#"')));
    expect(page, isNot(contains('Lorem ipsum')));
    expect(page, isNot(contains('4.9/5')));
    expect(page, isNot(contains('milyon kullanıcı')));
    expect(page, isNot(contains('sınırlı süre')));
    expect(page, isNot(contains(r'$9.99')));
  });
}
