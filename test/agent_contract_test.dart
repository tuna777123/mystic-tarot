import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('engineering agent contract', () {
    late String contract;

    setUpAll(() {
      contract = File('AGENTS.md').readAsStringSync();
    });

    test('locks advertising-only monetization and privacy boundaries', () {
      expect(contract, contains('advertising-only'));
      expect(contract, contains('RevenueCat'));
      expect(contract, contains('purchases_flutter'));
      expect(contract, contains('Growth evidence must remain aggregate-only'));
      expect(contract, contains('Generic public sharing must never include private tarot content'));
    });

    test('locks launch identity and required release validation', () {
      expect(contract, contains('com.tunabozcali.mystictarot'));
      expect(contract, contains('English, Turkish, Spanish, French, and Brazilian Portuguese'));
      expect(contract, contains('flutter analyze --fatal-infos'));
      expect(contract, contains('Android release AAB build'));
      expect(contract, contains('Unsigned iOS Release build'));
    });

    test('keeps owner-controlled production gates explicit', () {
      expect(contract, contains('app-ads.txt'));
      expect(contract, contains('AdMob app readiness'));
      expect(contract, contains('signed-device QA'));
      expect(contract, contains('store privacy declarations'));
      expect(contract, contains('store approvals'));
    });
  });
}
