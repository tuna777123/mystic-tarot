import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/materialize_optional_name_onboarding.dart';

void main() {
  test('onboarding can continue without collecting a name', () {
    final source = File('lib/src/app.dart').readAsStringSync();
    final materialized = materializeOptionalNameOnboardingSource(source);

    expect(
      materialized,
      isNot(contains('page == 1 && name.text.trim().isEmpty')),
    );
    expect(materialized, contains('Your first name (optional)'));
    expect(
      materialized,
      contains(
        'Your name is optional. It stays on this device with your private app data.',
      ),
    );
    expect(materialized, contains("tr: 'Adın (isteğe bağlı)'"));
    expect(materialized, contains("es: 'Tu nombre (opcional)'"));
    expect(materialized, contains("fr: 'Votre prénom (facultatif)'"));
    expect(materialized, contains("pt: 'Seu nome (opcional)'"));
  });

  test('verified builds materialize the optional-name experience', () {
    final source = File(
      'tool/configure_store_identifiers.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        "import 'materialize_optional_name_onboarding.dart' as optional_name_onboarding;",
      ),
    );
    expect(
      source,
      contains('optional_name_onboarding.materializeOptionalNameOnboarding();'),
    );
  });

  test('optional-name materializer is idempotent', () {
    final source = File('lib/src/app.dart').readAsStringSync();
    final once = materializeOptionalNameOnboardingSource(source);
    final twice = materializeOptionalNameOnboardingSource(once);

    expect(twice, once);
  });
}
