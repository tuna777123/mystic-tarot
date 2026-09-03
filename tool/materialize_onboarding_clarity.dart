import 'dart:io';

void main() => materializeOnboardingClarity();

/// Sharpens the first-run promise around Mystic's core continuity loop.
///
/// The premium portal and the continuity timeline stay intact. Redundant proof
/// chips are collapsed so the user sees one clear promise, one privacy signal,
/// language choice, and the activation CTA.
void materializeOnboardingClarity() {
  final app = File('lib/src/app.dart');
  if (!app.existsSync()) {
    throw StateError('Mystic Tarot app source is missing.');
  }

  final transformed = materializeOnboardingClaritySource(
    app.readAsStringSync(),
  );
  app.writeAsStringSync(transformed);

  final firstPage = _firstOnboardingPage(transformed);
  if (!firstPage.contains("en: 'Read today.\\nCheck reality tomorrow.',") ||
      !firstPage.contains('Mystic Mirror asks what actually changed.') ||
      !firstPage.contains("en: 'PRIVATE JOURNAL',") ||
      firstPage.contains("en: '78 ARCANA',") ||
      firstPage.contains("en: 'PATTERN MEMORY',")) {
    throw StateError('Onboarding clarity verification failed.');
  }

  stdout.writeln(
    'Onboarding clarity materialized: one continuity promise, one privacy '
    'signal, five launch-language choices, and a concrete first-reading CTA.',
  );
}

String materializeOnboardingClaritySource(String source) {
  var updated = source;

  updated = _replaceRequired(
    updated,
    '''              en: 'Your patterns are\\nalready speaking.',
              es: 'Tus patrones ya\\nestán hablando.',
              fr: 'Vos schémas parlent\\ndéjà.',
              pt: 'Seus padrões já\\nestão falando.',
              tr: 'Örüntülerin\\nçoktan konuşuyor.',
              it: 'I tuoi schemi stanno\\ngià parlando.',
              de: 'Deine Muster\\nsprechen bereits.',''',
    '''              en: 'Read today.\\nCheck reality tomorrow.',
              es: 'Lee hoy.\\nComprueba mañana.',
              fr: 'Tirez aujourd’hui.\\nVérifiez demain.',
              pt: 'Leia hoje.\\nConfira amanhã.',
              tr: 'Bugün oku.\\nYarın gerçekle karşılaştır.',
              it: 'Leggi oggi.\\nVerifica domani.',
              de: 'Heute lesen.\\nMorgen prüfen.',''',
    'first-screen continuity headline',
  );

  updated = _replaceRequired(
    updated,
    '''              en: 'One private reading becomes tomorrow’s reality check and, with enough evidence, a pattern you can understand.',
              es: 'Una lectura privada se convierte mañana en una comprobación de la realidad y, con suficiente evidencia, en un patrón que puedes comprender.',
              fr: 'Un tirage privé devient demain une confrontation au réel puis, avec assez d’indices, une tendance que vous pouvez comprendre.',
              pt: 'Uma leitura privada se torna amanhã uma verificação da realidade e, com evidências suficientes, um padrão que você pode compreender.',
              tr: 'Tek bir özel okuma yarın gerçeklik kontrolüne, yeterli kanıt biriktiğinde anlayabileceğin bir örüntüye dönüşür.',
              it: 'Una lettura privata diventa domani un confronto con la realtà e, con abbastanza elementi, uno schema che puoi comprendere.',
              de: 'Eine private Lesung wird morgen zum Realitätscheck und mit genügend Hinweisen zu einem verständlichen Muster.',''',
    '''              en: 'One private reading. One grounded action. In 24 hours, Mystic Mirror asks what actually changed.',
              es: 'Una lectura privada. Una acción concreta. En 24 horas, Mystic Mirror pregunta qué cambió realmente.',
              fr: 'Un tirage privé. Une action concrète. Dans 24 heures, Mystic Mirror demande ce qui a réellement changé.',
              pt: 'Uma leitura privada. Uma ação concreta. Em 24 horas, o Mystic Mirror pergunta o que realmente mudou.',
              tr: 'Tek bir özel okuma. Tek bir somut adım. 24 saat sonra Mystic Mirror gerçekte neyin değiştiğini sorar.',
              it: 'Una lettura privata. Un’azione concreta. Dopo 24 ore, Mystic Mirror chiede cosa è cambiato davvero.',
              de: 'Eine private Lesung. Eine konkrete Handlung. Nach 24 Stunden fragt Mystic Mirror, was sich wirklich verändert hat.',''',
    'first-screen continuity explanation',
  );

  updated = _replaceRequired(
    updated,
    '''          Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: [
              _OnboardingProof(
                icon: '✦',
                label: _copy(
                  en: '78 ARCANA',
                  es: '78 ARCANOS',
                  fr: '78 ARCANES',
                  pt: '78 ARCANOS',
                  tr: '78 ARKANA',
                  it: '78 ARCANI',
                  de: '78 ARKANA',
                ),
              ),
              _OnboardingProof(
                icon: '◉',
                label: _copy(
                  en: 'PATTERN MEMORY',
                  es: 'MEMORIA DE PATRONES',
                  fr: 'MÉMOIRE DES SCHÉMAS',
                  pt: 'MEMÓRIA DE PADRÕES',
                  tr: 'ÖRÜNTÜ HAFIZASI',
                  it: 'MEMORIA DEGLI SCHEMI',
                  de: 'MUSTERGEDÄCHTNIS',
                ),
              ),
              _OnboardingProof(
                icon: '☾',
                label: _copy(
                  en: 'PRIVATE JOURNAL',
                  es: 'DIARIO PRIVADO',
                  fr: 'JOURNAL PRIVÉ',
                  pt: 'DIÁRIO PRIVADO',
                  tr: 'ÖZEL GÜNLÜK',
                  it: 'DIARIO PRIVATO',
                  de: 'PRIVATES TAGEBUCH',
                ),
              ),
            ],
          ),''',
    '''          _OnboardingProof(
            icon: '☾',
            label: _copy(
              en: 'PRIVATE JOURNAL',
              es: 'DIARIO PRIVADO',
              fr: 'JOURNAL PRIVÉ',
              pt: 'DIÁRIO PRIVADO',
              tr: 'ÖZEL GÜNLÜK',
              it: 'DIARIO PRIVATO',
              de: 'PRIVATES TAGEBUCH',
            ),
          ),''',
    'redundant onboarding proof chips',
  );

  updated = _replaceRequired(
    updated,
    '''                      en: 'Begin my journey',
                      es: 'Comenzar mi viaje',
                      fr: 'Commencer mon voyage',
                      pt: 'Começar minha jornada',
                      tr: 'Yolculuğuma başla',
                      it: 'Inizia il mio viaggio',
                      de: 'Meine Reise beginnen',''',
    '''                      en: 'Start with one reading',
                      es: 'Empezar con una lectura',
                      fr: 'Commencer par un tirage',
                      pt: 'Começar com uma leitura',
                      tr: 'Tek bir okumayla başla',
                      it: 'Inizia con una lettura',
                      de: 'Mit einer Lesung starten',''',
    'first-screen activation CTA',
  );

  final firstPage = _firstOnboardingPage(updated);
  final timelineIndex = firstPage.indexOf('LaunchContinuityTimeline(');
  final privacyIndex = firstPage.indexOf("en: 'PRIVATE JOURNAL',");
  final languageIndex = firstPage.indexOf('children: launchLanguages');
  if (timelineIndex < 0 ||
      privacyIndex <= timelineIndex ||
      languageIndex <= privacyIndex) {
    throw StateError('Onboarding hierarchy changed unexpectedly.');
  }

  return updated;
}

String _firstOnboardingPage(String source) {
  final start = source.indexOf('    if (page == 0) {');
  final end = source.indexOf('    if (page == 1) {', start + 1);
  if (start < 0 || end <= start) {
    throw StateError('Onboarding page anchors changed unexpectedly.');
  }
  return source.substring(start, end);
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
