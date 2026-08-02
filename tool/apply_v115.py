from pathlib import Path

APP = Path('lib/src/app.dart')
NOTES = Path('RELEASE_NOTES.md')


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected one match, found {count}')
    return text.replace(old, new, 1)


app = APP.read_text()
if "import 'mystic_next_step.dart';" not in app:
    app = replace_once(
        app,
        "import 'flagship.dart';\n",
        "import 'flagship.dart';\nimport 'growth_engine.dart';\n",
        'growth engine import',
    )
    app = replace_once(
        app,
        "import 'mystic_mirror_due.dart';\n",
        "import 'mystic_mirror_due.dart';\nimport 'mystic_next_step.dart';\n",
        'next step import',
    )

    app = replace_once(
        app,
        "          freeReadingsLeft: isPlus\n              ? -1\n              : max(0, freeDeepReadingLimit - deepReadingsToday),\n          onReading: _startReading,\n",
        "          freeReadingsLeft: isPlus\n              ? -1\n              : max(0, freeDeepReadingLimit - deepReadingsToday),\n          mirrorDueCount: mirrorDueCount,\n          onReading: _startReading,\n",
        'home mirror count',
    )
    app = replace_once(
        app,
        "          onPremium: _showPremium,\n          onOpenDestiny: _openDestinyHub,\n",
        "          onPremium: _showPremium,\n          onOpenDestiny: _openDestinyHub,\n          onOpenJournal: () => setState(() => tab = 2),\n",
        'home journal callback',
    )

    app = replace_once(
        app,
        "    required this.freeReadingsLeft,\n    required this.onReading,\n",
        "    required this.freeReadingsLeft,\n    required this.mirrorDueCount,\n    required this.onReading,\n",
        'home constructor mirror count',
    )
    app = replace_once(
        app,
        "    required this.onPremium,\n    required this.onOpenDestiny,\n",
        "    required this.onPremium,\n    required this.onOpenDestiny,\n    required this.onOpenJournal,\n",
        'home constructor journal callback',
    )
    app = replace_once(
        app,
        "  final int freeReadingsLeft;\n  final ValueChanged<ReadingKind> onReading;\n",
        "  final int freeReadingsLeft;\n  final int mirrorDueCount;\n  final ValueChanged<ReadingKind> onReading;\n",
        'home mirror field',
    )
    app = replace_once(
        app,
        "  final VoidCallback onPremium;\n  final VoidCallback onOpenDestiny;\n\n  @override\n  Widget build(BuildContext context) => MysticBackground(\n",
        "  final VoidCallback onPremium;\n  final VoidCallback onOpenDestiny;\n  final VoidCallback onOpenJournal;\n\n  @override\n  Widget build(BuildContext context) {\n    final growthSnapshot = const MysticGrowthEngine().analyze(\n      records: records,\n      streak: streak,\n      completedArcanaDays: completedArcanaDays.length,\n      freeReadingsLeft: freeReadingsLeft,\n      mirrorDueCount: mirrorDueCount,\n    );\n    return MysticBackground(\n",
        'home growth snapshot',
    )

    app = replace_once(
        app,
        "              const SizedBox(height: 18),\n              _DailyCard(\n",
        "              const SizedBox(height: 18),\n              MysticNextStepCard(\n                snapshot: growthSnapshot,\n                language: language,\n                streak: streak,\n                mirrorDueCount: mirrorDueCount,\n                completedArcanaDays: completedArcanaDays.length,\n                freeReadingsLeft: freeReadingsLeft,\n                onTap: () => _runNextAction(\n                  context,\n                  growthSnapshot.nextAction.type,\n                ),\n              ),\n              const SizedBox(height: 14),\n              _DailyCard(\n",
        'home next step card',
    )

    app = replace_once(
        app,
        "      ],\n    ),\n  );\n\n  String _greeting() {\n",
        "      ],\n    ),\n  );\n  }\n\n  void _runNextAction(\n    BuildContext context,\n    MysticNextActionType type,\n  ) {\n    switch (type) {\n      case MysticNextActionType.firstReading:\n      case MysticNextActionType.dailyReading:\n        onReading(ReadingKind.daily);\n        return;\n      case MysticNextActionType.mirrorCheckIn:\n      case MysticNextActionType.reviewPattern:\n        onOpenJournal();\n        return;\n      case MysticNextActionType.continueJourney:\n        onOpenDestiny();\n        return;\n      case MysticNextActionType.explorePremiumSpread:\n        if (freeReadingsLeft == 0) {\n          onPremium();\n        } else {\n          _showAllReadings(context);\n        }\n        return;\n    }\n  }\n\n  String _greeting() {\n",
        'home next action routing',
    )

    APP.write_text(app)

notes = NOTES.read_text()
header = '# Mystic Tarot 1.15.0 — Personal Next Step\n'
if not notes.startswith(header):
    section = """# Mystic Tarot 1.15.0 — Personal Next Step

This release connects Mystic’s existing local growth engine to the real Home experience so each user sees one honest, actionable next step instead of a generic wall of features.

## One clear next step

- Home now calculates a private growth snapshot from local reading history, streak, completed Arcana chapters, free-reading allowance, and the verified Mirror due count.
- The card prioritizes first activation, the real Daily Guidance, due Mirror follow-up, the next Arcana chapter, visible patterns, and deeper reading discovery in that order.
- A non-daily spread completed today never falsely satisfies the Daily Guidance step.
- Old readings never reappear as Mirror tasks unless the backed local Mirror store reports that they are genuinely due.
- Every action routes to an existing destination: Daily Guidance, Living Journal, Living Fate, reading library, or Mystic Plus.

## Localized continuity

- The card explains why the suggested action matters and reflects whether the user is beginning, active today, returning the next day, continuing a streak, or resuming after time away.
- Complete English, Turkish, Spanish, French, and Brazilian Portuguese copy ships for every action, growth stage, return state, and CTA.
- Long French and Portuguese actions remain usable on narrow phones.

## Privacy and release integrity

- Personalization remains local-first and deterministic; no new account, cloud profile, analytics payload, or private text storage is introduced.
- Version `1.15.0+21`.
- Engine priorities, localization, action routing, and narrow-phone rendering are protected by automated tests.

---

"""
    NOTES.write_text(section + notes)
