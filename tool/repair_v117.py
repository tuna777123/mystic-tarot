from pathlib import Path

APP = Path('lib/src/app.dart')
app = APP.read_text()

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

french_memory = """      MysticLanguage.french =>
        ' Dans les ${recent.length} tirages mémorisés, $cardName est apparue '
        '${recurring.value} fois et $emotion était votre émotion de départ la '
        'plus fréquente. Ce n’est pas une prédiction, mais un fil récurrent qui '
        'mérite votre attention.',
"""

app = app.replace(french_answer, '')
app = app.replace(french_memory, '')

compose_start = app.index('  String _composeAnswer(String question) {')
compose_end = app.index('  String _oracleConversationThread() {', compose_start)
compose = app[compose_start:compose_end]
marker = '      case MysticLanguage.portugueseBrazil:\n'
if marker not in compose:
    raise SystemExit('Portuguese compose marker missing')
compose = compose.replace(marker, french_answer + marker, 1)
app = app[:compose_start] + compose + app[compose_end:]

memory_start = app.index('  String _oracleMemory() {')
memory_end = app.index('\n  }\n\n}', memory_start) + len('\n  }')
memory = app[memory_start:memory_end]
marker = '      MysticLanguage.portugueseBrazil =>\n'
if marker not in memory:
    raise SystemExit('Portuguese memory marker missing')
memory = memory.replace(marker, french_memory + marker, 1)
app = app[:memory_start] + memory + app[memory_end:]

APP.write_text(app)

contract = Path('test/v117_oracle_language_contract_test.dart')
text = contract.read_text().replace(
    "contains('Dans les \\\${recent.length} tirages mémorisés')",
    "contains(r'Dans les ${recent.length} tirages mémorisés')",
)
contract.write_text(text)
