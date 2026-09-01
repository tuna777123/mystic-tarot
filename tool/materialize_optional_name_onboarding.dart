import 'dart:io';

import 'materialize_second_session_reminder.dart' as second_session_reminder;

void main() => materializeOptionalNameOnboarding();

/// Removes unnecessary identity friction from first-run onboarding.
///
/// A name can make readings feel warmer, but it is not required for Mystic's
/// core reflection loop. The transformation is deterministic and fails closed
/// when onboarding source changes unexpectedly.
void materializeOptionalNameOnboarding() {
  final app = File('lib/src/app.dart');
  if (!app.existsSync()) {
    throw StateError('Mystic Tarot app source is missing.');
  }

  final original = app.readAsStringSync();
  final updated = materializeOptionalNameOnboardingSource(original);
  app.writeAsStringSync(updated);

  if (updated.contains('page == 1 && name.text.trim().isEmpty')) {
    throw StateError('Onboarding still requires a name.');
  }
  if (!updated.contains('Your name is optional. It stays on this device')) {
    throw StateError('Optional-name privacy copy was not materialized.');
  }
  if (!updated.contains('Your first name (optional)')) {
    throw StateError('Optional-name field hint was not materialized.');
  }

  second_session_reminder.materializeSecondSessionReminder();

  stdout.writeln(
    'Optional-name onboarding materialized: identity friction removed and '
    'local-first privacy copy retained.',
  );
}

String materializeOptionalNameOnboardingSource(String source) {
  var updated = source;

  updated = _replaceRequired(
    updated,
    '''              onPressed: page == 1 && name.text.trim().isEmpty
                  ? null
                  : () => page < 2
                        ? setState(() => page++)
                        : widget.onDone(name.text.trim(), intention, language),''',
    '''              onPressed: () => page < 2
                  ? setState(() => page++)
                  : widget.onDone(name.text.trim(), intention, language),''',
    'optional onboarding name action',
  );

  updated = _replaceRequired(
    updated,
    "en: 'Your name helps each reading feel personal.',",
    "en: 'Your name is optional. It stays on this device with your private app data.',",
    'English optional-name privacy copy',
  );
  updated = _replaceRequired(
    updated,
    "es: 'Tu nombre hace que cada lectura se sienta personal.',",
    "es: 'Tu nombre es opcional. Permanece en este dispositivo con los datos privados de la app.',",
    'Spanish optional-name privacy copy',
  );
  updated = _replaceRequired(
    updated,
    "fr: 'Votre nom rend chaque tirage plus personnel.',",
    "fr: 'Votre nom est facultatif. Il reste sur cet appareil avec les données privées de l’app.',",
    'French optional-name privacy copy',
  );
  updated = _replaceRequired(
    updated,
    "pt: 'Seu nome torna cada leitura mais pessoal.',",
    "pt: 'Seu nome é opcional. Ele permanece neste dispositivo com os dados privados do app.',",
    'Portuguese optional-name privacy copy',
  );
  updated = _replaceRequired(
    updated,
    "tr: 'Adın her okumayı sana özel hissettirir.',",
    "tr: 'Adın isteğe bağlıdır. Uygulamadaki özel verilerinle birlikte bu cihazda kalır.',",
    'Turkish optional-name privacy copy',
  );
  updated = _replaceRequired(
    updated,
    "it: 'Il tuo nome rende ogni lettura più personale.',",
    "it: 'Il nome è facoltativo e resta su questo dispositivo con i dati privati dell’app.',",
    'Italian optional-name privacy copy',
  );
  updated = _replaceRequired(
    updated,
    "de: 'Dein Name lässt jede Lesung persönlicher wirken.',",
    "de: 'Dein Name ist optional und bleibt mit den privaten App-Daten auf diesem Gerät.',",
    'German optional-name privacy copy',
  );

  updated = _replaceRequired(
    updated,
    "en: 'Your first name',",
    "en: 'Your first name (optional)',",
    'English optional-name hint',
  );
  updated = _replaceRequired(
    updated,
    "es: 'Tu nombre',",
    "es: 'Tu nombre (opcional)',",
    'Spanish optional-name hint',
  );
  updated = _replaceRequired(
    updated,
    "fr: 'Votre prénom',",
    "fr: 'Votre prénom (facultatif)',",
    'French optional-name hint',
  );
  updated = _replaceRequired(
    updated,
    "pt: 'Seu nome',",
    "pt: 'Seu nome (opcional)',",
    'Portuguese optional-name hint',
  );
  updated = _replaceRequired(
    updated,
    "tr: 'Adın',",
    "tr: 'Adın (isteğe bağlı)',",
    'Turkish optional-name hint',
  );
  updated = _replaceRequired(
    updated,
    "it: 'Il tuo nome',",
    "it: 'Il tuo nome (facoltativo)',",
    'Italian optional-name hint',
  );
  updated = _replaceRequired(
    updated,
    "de: 'Dein Vorname',",
    "de: 'Dein Vorname (optional)',",
    'German optional-name hint',
  );

  return updated;
}

String _replaceRequired(
  String source,
  String oldValue,
  String newValue,
  String label,
) {
  if (source.contains(newValue)) return source;
  final count = oldValue.allMatches(source).length;
  if (count != 1) {
    throw StateError(
      'Unable to materialize $label: expected exactly one source anchor, '
      'found $count.',
    );
  }
  return source.replaceFirst(oldValue, newValue);
}
