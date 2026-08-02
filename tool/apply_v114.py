from pathlib import Path

APP = Path('lib/src/app.dart')
NOTES = Path('RELEASE_NOTES.md')


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected one match, found {count}')
    return text.replace(old, new, 1)


app = APP.read_text()
if "import 'daily_practice.dart';" not in app:
    app = replace_once(
        app,
        "import 'app_language.dart';\n",
        "import 'app_language.dart';\nimport 'daily_practice.dart';\nimport 'daily_state.dart';\n",
        'daily imports',
    )

    app = replace_once(
        app,
        "  Timer? _mirrorDueTimer;\n  int mirrorDueCount = 0;\n",
        "  Timer? _mirrorDueTimer;\n  Timer? _dayBoundaryTimer;\n  String _activeDayKey = mysticDayKey(DateTime.now());\n  int mirrorDueCount = 0;\n",
        'daily fields',
    )

    app = replace_once(
        app,
        "    if (state == AppLifecycleState.resumed) {\n      subscriptionStore.refreshEntitlement();\n      _refreshMirrorDueState();\n    }\n",
        "    if (state == AppLifecycleState.resumed) {\n      subscriptionStore.refreshEntitlement();\n      _refreshMirrorDueState();\n      _refreshDailyState();\n      _scheduleDayBoundary();\n    }\n",
        'resume refresh',
    )

    app = replace_once(
        app,
        "    _mirrorDueTimer?.cancel();\n    subscriptionStore.removeListener(_syncSubscription);\n",
        "    _mirrorDueTimer?.cancel();\n    _dayBoundaryTimer?.cancel();\n    subscriptionStore.removeListener(_syncSubscription);\n",
        'timer disposal',
    )

    app = replace_once(
        app,
        "          onClaimDailyQuest: _claimDailyQuest,\n          onPremiumSpread: isPlus ? _startReading : _previewPremiumReading,\n",
        "          onClaimDailyQuest: _claimDailyQuest,\n          onRitual: _openDailyPractice,\n          onPremiumSpread: isPlus ? _startReading : _previewPremiumReading,\n",
        'home ritual callback',
    )

    app = replace_once(
        app,
        "  void _startReading(ReadingKind kind) {\n    if (!isPlus && _premiumReadingKinds.contains(kind)) {\n",
        "  void _startReading(ReadingKind kind) {\n    _refreshDailyState();\n    if (!isPlus && _premiumReadingKinds.contains(kind)) {\n",
        'reading daily refresh',
    )

    app = replace_once(
        app,
        "  void _claimDailyQuest() {\n    final today = _dayKey(DateTime.now());\n",
        "  Future<void> _openDailyPractice() async {\n    _refreshDailyState();\n    if (completedRituals.isNotEmpty) return;\n    final context = navigatorKey.currentState?.overlay?.context;\n    if (context == null || !context.mounted) return;\n    final result = await showDailyPracticeSheet(\n      context: context,\n      language: language,\n    );\n    if (!mounted || !context.mounted || result == null) return;\n    setState(() => completedRituals.add(dailyPracticeId(result)));\n    await _saveProgress();\n    if (!mounted || !context.mounted) return;\n    final today = _dayKey(DateTime.now());\n    final readToday = journal.any(\n      (record) =>\n          record.kind == ReadingKind.daily &&\n          _dayKey(record.createdAt) == today,\n    );\n    if (readToday) {\n      ScaffoldMessenger.of(context).showSnackBar(\n        SnackBar(\n          content: Text(\n            localized(\n              language.appLanguage,\n              english: 'Ritual complete. Your Soul Chest is ready.',\n              spanish: 'Ritual completado. Tu Cofre del Alma está listo.',\n              french: 'Rituel terminé. Votre Coffre de l’Âme est prêt.',\n              portugueseBrazil: 'Ritual concluído. Seu Baú da Alma está pronto.',\n              turkish: 'Ritüel tamamlandı. Ruh Sandığın açılmaya hazır.',\n            ),\n          ),\n        ),\n      );\n    }\n  }\n\n  void _claimDailyQuest() {\n    _refreshDailyState();\n    final today = _dayKey(DateTime.now());\n",
        'daily practice action',
    )

    app = replace_once(
        app,
        "        deepReadingsDay = savedReadingDay;\n        deepReadingsToday = savedReadingDay == today\n",
        "        deepReadingsDay = savedReadingDay;\n        _activeDayKey = today;\n        deepReadingsToday = savedReadingDay == today\n",
        'load active day',
    )

    app = replace_once(
        app,
        "      await _restoreRitualReminder();\n      if (journalRecoveryMessage != null) {\n",
        "      await _restoreRitualReminder();\n      _scheduleDayBoundary();\n      if (journalRecoveryMessage != null) {\n",
        'schedule boundary after load',
    )

    app = replace_once(
        app,
        "        prefs.setString('ritual_day', _dayKey(DateTime.now())),\n",
        "        prefs.setString('ritual_day', _activeDayKey),\n",
        'persist active ritual day',
    )

    app = replace_once(
        app,
        "  void _updateStreak() {\n",
        "  void _refreshDailyState() {\n    if (!mounted || !ready) return;\n    final now = DateTime.now();\n    final refresh = evaluateMysticDailyRefresh(\n      now: now,\n      activeDay: _activeDayKey,\n      deepReadingsDay: deepReadingsDay,\n      dailyQuestClaimedDay: dailyQuestClaimedDay,\n      lastActiveDay: lastActiveDay,\n      streak: streak,\n    );\n    final changed = refresh.dayChanged ||\n        refresh.resetDeepReadings ||\n        refresh.clearQuestClaim ||\n        refresh.visibleStreak != streak;\n    if (changed) {\n      setState(() {\n        if (refresh.dayChanged) {\n          _activeDayKey = refresh.today;\n          completedRituals.clear();\n        }\n        if (refresh.resetDeepReadings) {\n          deepReadingsDay = refresh.today;\n          deepReadingsToday = 0;\n        }\n        if (refresh.clearQuestClaim) dailyQuestClaimedDay = null;\n        streak = refresh.visibleStreak;\n      });\n      unawaited(_saveProgress());\n    }\n    _scheduleDayBoundary();\n  }\n\n  void _scheduleDayBoundary() {\n    if (!mounted || !ready) return;\n    _dayBoundaryTimer?.cancel();\n    _dayBoundaryTimer = Timer(\n      durationUntilNextMysticDay(DateTime.now()),\n      _refreshDailyState,\n    );\n  }\n\n  void _updateStreak() {\n",
        'daily boundary methods',
    )

    app = replace_once(
        app,
        "    required this.onClaimDailyQuest,\n    required this.onPremiumSpread,\n",
        "    required this.onClaimDailyQuest,\n    required this.onRitual,\n    required this.onPremiumSpread,\n",
        'home constructor ritual',
    )

    app = replace_once(
        app,
        "  final VoidCallback onClaimDailyQuest;\n  final ValueChanged<ReadingKind> onPremiumSpread;\n",
        "  final VoidCallback onClaimDailyQuest;\n  final VoidCallback onRitual;\n  final ValueChanged<ReadingKind> onPremiumSpread;\n",
        'home field ritual',
    )

    app = replace_once(
        app,
        "                language: language,\n                onClaim: onClaimDailyQuest,\n              ),\n",
        "                language: language,\n                onClaim: onClaimDailyQuest,\n                onRitual: onRitual,\n              ),\n",
        'daily quest wiring',
    )

    app = replace_once(
        app,
        "    required this.onClaim,\n  });\n  final bool readingDone;\n",
        "    required this.onClaim,\n    required this.onRitual,\n  });\n  final bool readingDone;\n",
        'quest constructor ritual',
    )

    app = replace_once(
        app,
        "  final MysticLanguage language;\n  final VoidCallback onClaim;\n",
        "  final MysticLanguage language;\n  final VoidCallback onClaim;\n  final VoidCallback onRitual;\n",
        'quest field ritual',
    )

    app = replace_once(
        app,
        "          ClipRRect(\n            borderRadius: BorderRadius.circular(8),\n            child: LinearProgressIndicator(\n              value: claimed ? 1.0 : progress,\n              minHeight: 5,\n              backgroundColor: Colors.white10,\n              color: MysticColors.gold,\n            ),\n          ),\n",
        "          ClipRRect(\n            borderRadius: BorderRadius.circular(8),\n            child: LinearProgressIndicator(\n              value: claimed ? 1.0 : progress,\n              minHeight: 5,\n              backgroundColor: Colors.white10,\n              color: MysticColors.gold,\n            ),\n          ),\n          if (!ritualDone) ...[\n            const SizedBox(height: 12),\n            SizedBox(\n              width: double.infinity,\n              child: OutlinedButton.icon(\n                onPressed: onRitual,\n                icon: const Icon(Icons.self_improvement_rounded),\n                label: Text(dailyPracticeCta(language)),\n              ),\n            ),\n          ],\n",
        'quest actionable ritual',
    )

    APP.write_text(app)

notes = NOTES.read_text()
header = '# Mystic Tarot 1.14.0 — Daily Practice & Reliable Return\n'
if not notes.startswith(header):
    section = """# Mystic Tarot 1.14.0 — Daily Practice & Reliable Return

This release turns the Daily Soul Quest into a complete, honest product loop and keeps daily state correct while the app remains open.

## Actionable daily ritual

- The previously passive “one ritual” step now opens a real private micro-practice.
- Users can complete a guided 24-second grounding breath, write one honest intention, or name a gratitude anchor.
- Intention and gratitude text exists only inside the open sheet and is never persisted; Mystic stores only the selected practice identifier.
- Completing the ritual immediately updates the Daily Soul Quest and reveals when the Soul Chest is ready.
- All practice choices, privacy language, breathing phases, writing prompts, and calls to action ship in English, Turkish, Spanish, French, and Brazilian Portuguese.

## Reliable daily boundaries

- Daily rituals, deep-reading allowances, quest claims, and stale streak displays refresh automatically after local midnight.
- The refresh runs when the app resumes and through a scheduled local day-boundary timer while the app remains open.
- A valid yesterday streak remains visible until today’s practice; a genuinely broken streak no longer appears active.
- Daily state rules are deterministic and covered independently from the interface.

## Release integrity

- Version `1.14.0+20`.
- Private writing is not added to SharedPreferences, notifications, exports, analytics, or purchase services.
- Narrow-phone layout and guided-practice completion are protected by automated widget tests.

---

"""
    NOTES.write_text(section + notes)
