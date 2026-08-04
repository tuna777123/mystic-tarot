from pathlib import Path

root = Path('.')

position = root / 'lib/src/reading_position.dart'
source = position.read_text(encoding='utf-8')
compatibility_old = """      copy(
        en: 'The dynamic between you',
        tr: 'Aranızdaki dinamik',
        es: 'La dinámica entre ustedes',
        fr: 'La dynamique entre vous',
        pt: 'A dinâmica entre vocês',
      ),
    ],
    ReadingKind.timeline => <String>[
"""
compatibility_new = """      copy(
        en: 'The dynamic between you',
        tr: 'Aranızdaki dinamik',
        es: 'La dinámica entre ustedes',
        fr: 'La dynamique entre vous',
        pt: 'A dinâmica entre vocês',
      ),
      copy(
        en: 'The shared growth edge',
        tr: 'Birlikte gelişebileceğiniz alan',
        es: 'El punto de crecimiento compartido',
        fr: 'La zone de croissance partagée',
        pt: 'O ponto de crescimento compartilhado',
      ),
      copy(
        en: 'The next honest step for the connection',
        tr: 'Bağ için sıradaki dürüst adım',
        es: 'El siguiente paso honesto para el vínculo',
        fr: 'La prochaine étape honnête pour le lien',
        pt: 'O próximo passo honesto para a conexão',
      ),
    ],
    ReadingKind.timeline => <String>[
"""
timeline_old = """      copy(
        en: 'The longer horizon if the pattern continues',
        tr: 'Örüntü sürerse daha uzun vade',
        es: 'El horizonte más lejano si continúa el patrón',
        fr: 'L’horizon plus lointain si le schéma continue',
        pt: 'O horizonte mais longo se o padrão continuar',
      ),
    ],
    ReadingKind.celticCross => <String>[
"""
timeline_new = """      copy(
        en: 'The longer horizon if the pattern continues',
        tr: 'Örüntü sürerse daha uzun vade',
        es: 'El horizonte más lejano si continúa el patrón',
        fr: 'L’horizon plus lointain si le schéma continue',
        pt: 'O horizonte mais longo se o padrão continuar',
      ),
      copy(
        en: 'The choice that can change the trajectory',
        tr: 'Gidişatı değiştirebilecek seçim',
        es: 'La elección que puede cambiar la trayectoria',
        fr: 'Le choix qui peut changer la trajectoire',
        pt: 'A escolha que pode mudar a trajetória',
      ),
    ],
    ReadingKind.celticCross => <String>[
"""
if compatibility_old in source:
    source = source.replace(compatibility_old, compatibility_new, 1)
if timeline_old in source:
    source = source.replace(timeline_old, timeline_new, 1)
position.write_text(source, encoding='utf-8')

synthesis = root / 'lib/src/reading_synthesis.dart'
source = synthesis.read_text(encoding='utf-8')
grammar_replacements = {
    'One grounded experiment is to ${_lowerFirst(_sentence(card.advice))}': 'Try this grounded action: ${_sentence(card.advice)}',
    'Un experimento concreto es ${_lowerFirst(_sentence(card.advice))}': 'Prueba esta acción concreta: ${_sentence(card.advice)}',
    'Une expérience concrète consiste à ${_lowerFirst(_sentence(card.advice))}': 'Essayez cette action concrète : ${_sentence(card.advice)}',
    'Um experimento concreto é ${_lowerFirst(_sentence(card.advice))}': 'Experimente esta ação concreta: ${_sentence(card.advice)}',
    'Tek ve somut deney şu olabilir: ${_lowerFirst(_sentence(card.advice))}': 'Şu somut eylemi dene: ${_sentence(card.advice)}',
    'One grounded experiment is to ${_lowerFirst(_sentence(second.advice))}': 'Try this grounded action: ${_sentence(second.advice)}',
    'Un experimento concreto es ${_lowerFirst(_sentence(second.advice))}': 'Prueba esta acción concreta: ${_sentence(second.advice)}',
    'Une expérience concrète consiste à ${_lowerFirst(_sentence(second.advice))}': 'Essayez cette action concrète : ${_sentence(second.advice)}',
    'Um experimento concreto é ${_lowerFirst(_sentence(second.advice))}': 'Experimente esta ação concreta: ${_sentence(second.advice)}',
    'Tek somut deney şu olabilir: ${_lowerFirst(_sentence(second.advice))}': 'Şu somut eylemi dene: ${_sentence(second.advice)}',
}
for old, new in grammar_replacements.items():
    source = source.replace(old, new)
source = source.replace(
    "\nString _lowerFirst(String value) {\n  final text = value.trim();\n  if (text.isEmpty) return text;\n  return '${text[0].toLowerCase()}${text.substring(1)}';\n}\n",
    '\n',
)
synthesis.write_text(source, encoding='utf-8')

privacy = root / 'lib/src/launch_differentiation.dart'
source = privacy.read_text(encoding='utf-8')
replacements = {
    'No account, ads, cross-app tracking, or cloud journal. Your private history stays on this device, with an optional six-digit PIN and device biometrics for the whole app.': 'No account, ads, cross-app tracking, or cloud journal. Your private history stays on this device, with an optional six-digit PIN and biometrics on supported devices for the whole app.',
    'Sin cuenta, anuncios, rastreo entre apps ni diario en la nube. Tu historial privado permanece en este dispositivo, con PIN opcional de seis dígitos y biometría para toda la app.': 'Sin cuenta, anuncios, rastreo entre apps ni diario en la nube. Tu historial privado permanece en este dispositivo, con PIN opcional de seis dígitos y biometría en dispositivos compatibles para toda la app.',
    'Aucun compte, aucune publicité, aucun suivi inter-apps ni journal cloud. Votre historique privé reste sur cet appareil, avec un code PIN facultatif à six chiffres et la biométrie pour toute l’app.': 'Aucun compte, aucune publicité, aucun suivi inter-apps ni journal cloud. Votre historique privé reste sur cet appareil, avec un code PIN facultatif à six chiffres et la biométrie sur les appareils compatibles pour toute l’app.',
    'Sem conta, anúncios, rastreamento entre apps ou diário na nuvem. Seu histórico privado fica neste dispositivo, com PIN opcional de seis dígitos e biometria para todo o app.': 'Sem conta, anúncios, rastreamento entre apps ou diário na nuvem. Seu histórico privado fica neste dispositivo, com PIN opcional de seis dígitos e biometria em dispositivos compatíveis para todo o app.',
    'Hesap, reklam, uygulamalar arası takip veya bulut günlüğü yok. Özel geçmişin bu cihazda kalır; istersen tüm uygulamayı altı haneli PIN ve cihaz biyometrisiyle koruyabilirsin.': 'Hesap, reklam, uygulamalar arası takip veya bulut günlüğü yok. Özel geçmişin bu cihazda kalır; istersen tüm uygulamayı altı haneli PIN ve desteklenen cihazlarda biyometriyle koruyabilirsin.',
}
for old, new in replacements.items():
    source = source.replace(old, new)
privacy.write_text(source, encoding='utf-8')

readme = root / 'README.md'
source = readme.read_text(encoding='utf-8').replace(
    'local PIN and optional biometrics.',
    'local PIN and optional biometrics on supported devices.',
)
readme.write_text(source, encoding='utf-8')

for name in ('RELEASE_NOTES.md', 'RELEASE_NOTES_1.21.md'):
    notes = root / name
    source = notes.read_text(encoding='utf-8')
    source = source.replace(
        '- Complete spreads now end with one deterministic synthesis that connects the opening card, the central tension, and the direction card.',
        '- Complete spreads now end with one deterministic, spread-aware synthesis; Compatibility connects both people, the shared dynamic, growth edge, and next honest step; Timeline preserves agency across six stages; Celtic Cross links the present situation, immediate challenge, near-future movement, and conditional direction.',
    )
    source = source.replace(
        'optional device biometrics.',
        'optional device biometrics on supported devices.',
    )
    notes.write_text(source, encoding='utf-8')

store = root / 'STORE_RELEASE.md'
source = store.read_text(encoding='utf-8').replace(
    'optional whole-app PIN/biometric protection',
    'optional whole-app PIN and supported-device biometric protection',
)
store.write_text(source, encoding='utf-8')

contract = root / 'test/v121_launch_differentiation_contract_test.dart'
source = contract.read_text(encoding='utf-8')
source = source.replace(
    "    final synthesis = File('lib/src/reading_synthesis.dart').readAsStringSync();\n",
    "    final positions = File('lib/src/reading_position.dart').readAsStringSync();\n    final synthesis = File('lib/src/reading_synthesis.dart').readAsStringSync();\n",
)
source = source.replace(
    "    expect(continuity, contains('optional six-digit PIN'));\n",
    "    expect(continuity, contains('optional six-digit PIN'));\n    expect(continuity, contains('biometrics on supported devices'));\n",
)
source = source.replace(
    "    expect(synthesis, contains('Taken together'));\n    expect(synthesis, contains('lenses.length == 2'));\n    expect(synthesis, contains('localizedEmotionLabel'));\n    expect(synthesis, contains('not a prediction'));\n",
    "    expect(synthesis, contains('Taken together'));\n    expect(synthesis, contains('lenses.length == 2'));\n    expect(synthesis, contains('ReadingKind.compatibility'));\n    expect(synthesis, contains('ReadingKind.timeline'));\n    expect(synthesis, contains('ReadingKind.celticCross'));\n    expect(synthesis, contains('Try this grounded action'));\n    expect(synthesis, contains('localizedEmotionLabel'));\n    expect(synthesis, contains('not a prediction'));\n    expect(positions, contains('The shared growth edge'));\n    expect(positions, contains('The next honest step for the connection'));\n    expect(positions, contains('The choice that can change the trajectory'));\n",
)
contract.write_text(source, encoding='utf-8')
