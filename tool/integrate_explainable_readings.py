from pathlib import Path

app_path = Path('lib/src/app.dart')
app = app_path.read_text(encoding='utf-8')


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected exactly one match, found {count}')
    return text.replace(old, new, 1)


app = replace_once(
    app,
    "import 'premium_value_screen.dart';\n",
    "import 'premium_value_screen.dart';\nimport 'reading_explanation.dart';\n",
    'add explanation import',
)
app = replace_once(
    app,
    """          const SizedBox(height: 8),
          Text(meaning, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
""",
    """          const SizedBox(height: 8),
          Text(meaning, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          ReadingExplanationPanel(
            explanation: buildReadingExplanation(
              card: card,
              positionIndex: index,
              emotion: emotion,
              intention: widget.intention,
              language: widget.language,
            ),
          ),
        ],
      ),
    );
  }
""",
    'insert explanation panel',
)
app_path.write_text(app, encoding='utf-8')

explanation_path = Path('lib/src/reading_explanation.dart')
explanation = explanation_path.read_text(encoding='utf-8')
explanation = replace_once(
    explanation,
    """  final cleanIntention = intention.trim().isEmpty
      ? copy(
          en: 'your chosen path',
          tr: 'seçtiğin yol',
          es: 'tu camino elegido',
          fr: 'votre chemin choisi',
          pt: 'seu caminho escolhido',
        )
      : intention.trim();
""",
    """  final cleanIntention = _localizedExplanationIntention(
    intention,
    language,
    fallback: copy(
      en: 'your chosen path',
      tr: 'seçtiğin yol',
      es: 'tu camino elegido',
      fr: 'votre chemin choisi',
      pt: 'seu caminho escolhido',
    ),
  );
""",
    'localize intention context',
)
explanation = replace_once(
    explanation,
    "\nclass ReadingExplanationPanel extends StatelessWidget {\n",
    """
String _localizedExplanationIntention(
  String intention,
  MysticLanguage language, {
  required String fallback,
}) {
  final normalized = intention.trim();
  if (normalized.isEmpty) return fallback;

  return switch ((language, normalized)) {
    (MysticLanguage.turkish, 'Love') => 'Aşk',
    (MysticLanguage.turkish, 'Purpose') => 'Amaç',
    (MysticLanguage.turkish, 'Healing') => 'İyileşme',
    (MysticLanguage.turkish, 'Clarity') => 'Netlik',
    (MysticLanguage.spanish, 'Love') => 'Amor',
    (MysticLanguage.spanish, 'Purpose') => 'Propósito',
    (MysticLanguage.spanish, 'Healing') => 'Sanación',
    (MysticLanguage.spanish, 'Clarity') => 'Claridad',
    (MysticLanguage.french, 'Love') => 'Amour',
    (MysticLanguage.french, 'Purpose') => 'Mission',
    (MysticLanguage.french, 'Healing') => 'Guérison',
    (MysticLanguage.french, 'Clarity') => 'Clarté',
    (MysticLanguage.portugueseBrazil, 'Love') => 'Amor',
    (MysticLanguage.portugueseBrazil, 'Purpose') => 'Propósito',
    (MysticLanguage.portugueseBrazil, 'Healing') => 'Cura',
    (MysticLanguage.portugueseBrazil, 'Clarity') => 'Clareza',
    _ => normalized,
  };
}

class ReadingExplanationPanel extends StatelessWidget {
""",
    'add intention localization helper',
)
explanation_path.write_text(explanation, encoding='utf-8')
