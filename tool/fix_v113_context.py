#!/usr/bin/env python3
from pathlib import Path

path = Path('lib/src/app.dart')
source = path.read_text(encoding='utf-8')
replacements = [
    (
        """    final context = navigatorKey.currentState?.overlay?.context;\n    if (context == null) return;\n    final choice = await showRitualReminderOfferSheet(\n""",
        """    final context = navigatorKey.currentState?.overlay?.context;\n    if (context == null || !context.mounted) return;\n    final choice = await showRitualReminderOfferSheet(\n""",
    ),
    (
        """    if (!mounted) return;\n    if (choice == null) {\n""",
        """    if (!mounted || !context.mounted) return;\n    if (choice == null) {\n""",
    ),
    (
        """    final permission = await ritualReminderService.requestPermission();\n    if (!mounted) return;\n""",
        """    final permission = await ritualReminderService.requestPermission();\n    if (!mounted || !context.mounted) return;\n""",
    ),
    (
        """      );\n      final message = switch (permission) {\n""",
        """      );\n      if (!mounted || !context.mounted) return;\n      final message = switch (permission) {\n""",
    ),
    (
        """    await ritualReminderStore.save(updated);\n    if (!mounted) return;\n    ScaffoldMessenger.of(context).showSnackBar(\n""",
        """    await ritualReminderStore.save(updated);\n    if (!mounted || !context.mounted) return;\n    ScaffoldMessenger.of(context).showSnackBar(\n""",
    ),
]
for old, new in replacements:
    count = source.count(old)
    if count != 1:
        raise SystemExit(f'Expected exactly one context pattern, found {count}.')
    source = source.replace(old, new, 1)
path.write_text(source, encoding='utf-8')
Path(__file__).unlink()
print('Applied v1.13 async BuildContext safety fix.')
