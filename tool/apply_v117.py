from pathlib import Path
import re

APP = Path('lib/src/app.dart')
PUBSPEC = Path('pubspec.yaml')
NOTES = Path('RELEASE_NOTES.md')

app = APP.read_text()

if "import 'oracle_language.dart';" not in app:
    app = app.replace(
        "import 'oracle_conversation.dart';\n",
        "import 'oracle_conversation.dart';\nimport 'oracle_language.dart';\n",
        1,
    )

pattern = re.compile(
    r"    final lower = question\.toLowerCase\(\);\n"
    r"    final memory = '\$\{_oracleMemory\(\)\}\$\{_oracleConversationThread\(\)\}';\n"
    r"    final hiddenQuestion = .*?;\n"
    r"    final keyCardQuestion = .*?;\n",
    re.S,
)
replacement = (
    "    final memory = '${_oracleMemory()}${_oracleConversationThread()}';\n"
    "    final intent = detectOracleQuestionIntent(question, widget.language);\n"
    "    final hiddenQuestion = intent == OracleQuestionIntent.hidden;\n"
    "    final keyCardQuestion = intent == OracleQuestionIntent.keyCard;\n"
)
app, count = pattern.subn(replacement, app, count=1)
if count != 1:
    raise SystemExit(f'Oracle intent block: expected 1 replacement, got {count}')

french_answer = """      case MysticLanguage.french:
        if (hiddenQuestion) {
          return '$firstName suggère que la partie cachée peut être celle-ci : '
              '$firstMeaning $lastAdvice Votre état ${emotion.toLowerCase()} '
              'peut donner trop de poids à un détail. Séparez ce que vous savez '
              'de ce que vous craignez ou espérez.$memory';
        }
        if (keyCardQuestion) {
          return '$lastName porte le poids final de ce tirage. $lastMeaning '
              'Son invitation pratique est simple : $lastAdvice Observez comment '
              'cela soutient votre chemin de ${_localizedIntention(widget.intention, widget.language).toLowerCase()}.$memory';
        }
        return '$firstName décrit l’énergie dans laquelle vous entrez, tandis que '
            '$lastName indique la réponse qui vous est disponible. $lastAdvice '
            'Gardez la prochaine étape petite, observable et réversible ; les '
            'cartes proposent une perspective, pas un ordre.$memory';
"""
marker = "      case MysticLanguage.portugueseBrazil:\n"
if french_answer not in app:
    if marker not in app:
        raise SystemExit('French answer insertion marker missing')
    app = app.replace(marker, french_answer + marker, 1)

french_memory = """      MysticLanguage.french =>
        ' Dans les ${recent.length} tirages mémorisés, $cardName est apparue '
        '${recurring.value} fois et $emotion était votre émotion de départ la '
        'plus fréquente. Ce n’est pas une prédiction, mais un fil récurrent qui '
        'mérite votre attention.',
"""
marker = "      MysticLanguage.portugueseBrazil =>\n"
if french_memory not in app:
    if marker not in app:
        raise SystemExit('French memory insertion marker missing')
    app = app.replace(marker, french_memory + marker, 1)

APP.write_text(app)

pubspec = PUBSPEC.read_text()
pubspec, count = re.subn(r'^version: .*$', 'version: 1.17.0+23', pubspec, count=1, flags=re.M)
if count != 1:
    raise SystemExit('Version line not replaced')
PUBSPEC.write_text(pubspec)

notes = NOTES.read_text()
header = """# Mystic Tarot 1.17.0 — Oracle Language Integrity

This release closes the last major language break inside Oracle Dialogue so every launch language receives a complete, grounded response instead of a translated shell around an English answer.

## Complete French Oracle

- French Oracle responses now have native hidden-risk, key-card, and general guidance branches.
- French recurring-card memory and conversation continuity remain French from question to answer.
- The safety framing remains intact: cards offer a perspective, not certainty or commands.

## Better multilingual intent detection

- Hidden-risk and key-card questions are detected independently in English, Turkish, Spanish, French, and Brazilian Portuguese.
- Matching is accent-tolerant and punctuation-tolerant, so natural questions such as “Quelle carte…” and “Neyi gözden kaçırıyorum?” route correctly.
- Ordinary follow-ups remain general instead of being forced into the wrong response template.

## Release integrity

- Version `1.17.0+23`.
- No cloud profile, analytics payload, advertising identifier, store operation, or account mutation is introduced.
- The complete language behavior is protected by deterministic unit and release-contract tests.

---

"""
if not notes.startswith('# Mystic Tarot 1.17.0 — Oracle Language Integrity'):
    NOTES.write_text(header + notes)
