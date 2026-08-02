from pathlib import Path
import re


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected exactly one match, found {count}')
    return text.replace(old, new, 1)


def regex_once(text: str, pattern: str, replacement: str, label: str) -> str:
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.S)
    if count != 1:
        raise SystemExit(f'{label}: expected exactly one match, found {count}')
    return updated


# ---------------------------------------------------------------------------
# App integration
# ---------------------------------------------------------------------------
app_path = Path('lib/src/app.dart')
app = app_path.read_text(encoding='utf-8')

app = replace_once(
    app,
    "import 'package:flutter/services.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\n",
    "import 'package:flutter/services.dart';\nimport 'package:share_plus/share_plus.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\nimport 'package:url_launcher/url_launcher.dart';\n",
    'add sharing and support launcher imports',
)
app = replace_once(
    app,
    "import 'models.dart';\nimport 'reading_journal_store.dart';\n",
    "import 'journal_export.dart';\nimport 'journal_recovery_notice.dart';\nimport 'models.dart';\nimport 'mystic_mirror.dart';\nimport 'mystic_mirror_due.dart';\nimport 'reading_explanation.dart';\nimport 'reading_journal_store.dart';\nimport 'reading_position.dart';\n",
    'add v1.11 feature imports',
)
app = replace_once(
    app,
    "  final subscriptionStore = StorePurchaseService();\n  final readingJournalStore = ReadingJournalStore();\n",
    "  final subscriptionStore = StorePurchaseService();\n  final readingJournalStore = ReadingJournalStore();\n  final mirrorStore = MysticMirrorStore();\n  Timer? _mirrorDueTimer;\n  int mirrorDueCount = 0;\n  String? journalRecoveryMessage;\n",
    'add Mirror due and recovery state',
)
app = replace_once(
    app,
    "    if (state == AppLifecycleState.resumed) {\n      subscriptionStore.refreshEntitlement();\n    }\n",
    "    if (state == AppLifecycleState.resumed) {\n      subscriptionStore.refreshEntitlement();\n      _refreshMirrorDueState();\n    }\n",
    'refresh due state on resume',
)
app = replace_once(
    app,
    "    subscriptionStore.removeListener(_syncSubscription);\n    subscriptionStore.dispose();\n    super.dispose();\n",
    "    _mirrorDueTimer?.cancel();\n    subscriptionStore.removeListener(_syncSubscription);\n    subscriptionStore.dispose();\n    super.dispose();\n",
    'dispose Mirror due timer',
)
app = replace_once(
    app,
    "          onPremium: () => _showPremium(source: 'living_journal'),\n        ),\n",
    "          onPremium: () => _showPremium(source: 'living_journal'),\n          onMirrorChanged: _refreshMirrorDueState,\n        ),\n",
    'connect journal Mirror callback',
)
app = replace_once(
    app,
    "        NavigationDestination(\n          icon: const Icon(Icons.menu_book_outlined),\n          selectedIcon: const Icon(Icons.menu_book),\n          label: mysticText(language, 'Journal', 'Günlük'),\n        ),\n",
    "        NavigationDestination(\n          icon: _journalNavigationIcon(Icons.menu_book_outlined),\n          selectedIcon: _journalNavigationIcon(Icons.menu_book),\n          label: mysticText(language, 'Journal', 'Günlük'),\n        ),\n",
    'add Mirror due badge to journal navigation',
)
app = replace_once(
    app,
    "  void _startReading(ReadingKind kind) {\n",
    """  Widget _journalNavigationIcon(IconData icon) {
    final baseIcon = Icon(icon);
    if (mirrorDueCount <= 0) return baseIcon;
    return Semantics(
      label: localizedMirrorDueSemantics(mirrorDueCount, language),
      child: Badge(
        label: Text(compactMirrorDueLabel(mirrorDueCount)),
        child: ExcludeSemantics(child: baseIcon),
      ),
    );
  }

  Future<void> _refreshMirrorDueState() async {
    final reflections = await mirrorStore.load();
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      mirrorDueCount = countDueMysticMirrors(
        records: journal,
        reflections: reflections,
        now: now,
      );
    });
    _scheduleNextMirrorDue(reflections, now);
  }

  void _scheduleNextMirrorDue(
    Map<String, MysticMirrorReflection> reflections,
    DateTime now,
  ) {
    _mirrorDueTimer?.cancel();
    final wait = durationUntilNextMysticMirror(
      records: journal,
      reflections: reflections,
      now: now,
    );
    if (wait == null) return;
    _mirrorDueTimer = Timer(wait + const Duration(seconds: 1), () {
      _refreshMirrorDueState();
    });
  }

  void _showJournalRecoveryMessage() {
    final message = journalRecoveryMessage;
    final context = navigatorKey.currentContext;
    if (message == null || context == null || !mounted) return;
    journalRecoveryMessage = null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _startReading(ReadingKind kind) {
""",
    'insert Mirror due helpers',
)
app = replace_once(
    app,
    "            _saveProgress();\n            if (newlyDiscovered.isNotEmpty) {\n",
    "            _saveProgress();\n            _refreshMirrorDueState();\n            if (newlyDiscovered.isNotEmpty) {\n",
    'schedule Mirror after saving a reading',
)
app = replace_once(
    app,
    "      final journalLoad = await readingJournalStore.load(\n        legacyRecords:\n            prefs.getStringList(ReadingJournalStore.legacyKey) ?? const <String>[],\n      );\n      final today = _dayKey(DateTime.now());\n",
    "      final journalLoad = await readingJournalStore.load(\n        legacyRecords:\n            prefs.getStringList(ReadingJournalStore.legacyKey) ?? const <String>[],\n      );\n      final mirrorReflections = await mirrorStore.load();\n      final savedLanguage = _languageFromName(prefs.getString('language'));\n      final now = DateTime.now();\n      final today = _dayKey(now);\n",
    'load Mirror and recovery state with progress',
)
app = replace_once(
    app,
    "        language = _languageFromName(prefs.getString('language'));\n",
    "        language = savedLanguage;\n",
    'reuse resolved launch language',
)
app = replace_once(
    app,
    "        journal.addAll(journalLoad.records);\n        if (ritualDay == today)\n",
    "        journal.addAll(journalLoad.records);\n        mirrorDueCount = countDueMysticMirrors(\n          records: journalLoad.records,\n          reflections: mirrorReflections,\n          now: now,\n        );\n        journalRecoveryMessage = localizedJournalRecoveryNotice(\n          journalLoad,\n          savedLanguage,\n        );\n        if (ritualDay == today)\n",
    'calculate initial due count and recovery notice',
)
app = replace_once(
    app,
    "      if (journalLoad.migratedFromLegacy) {\n        await readingJournalStore.save(journalLoad.records);\n        await readingJournalStore.finishLegacyMigration();\n      }\n",
    "      if (journalLoad.migratedFromLegacy) {\n        await readingJournalStore.save(journalLoad.records);\n        await readingJournalStore.finishLegacyMigration();\n      }\n      _scheduleNextMirrorDue(mirrorReflections, now);\n      if (journalRecoveryMessage != null) {\n        WidgetsBinding.instance.addPostFrameCallback((_) {\n          _showJournalRecoveryMessage();\n        });\n      }\n",
    'schedule due state and recovery transparency',
)
app = replace_once(
    app,
    "      deepReadingsToday = 0;\n      deckStyle = DeckStyle.midnight;\n",
    "      deepReadingsToday = 0;\n      mirrorDueCount = 0;\n      _mirrorDueTimer?.cancel();\n      deckStyle = DeckStyle.midnight;\n",
    'reset Mirror state on deletion',
)

app = regex_once(
    app,
    r"  Widget _interpretation\(BuildContext context, int index, DrawnCard card\) \{\n    final positions = <String>\[.*?\n    final meaning = _localizedCardMeaning\(card, widget.language\);",
    """  Widget _interpretation(BuildContext context, int index, DrawnCard card) {
    final position = localizedReadingPosition(
      kind: widget.kind,
      index: index,
      language: widget.language,
    );
    final meaning = _localizedCardMeaning(card, widget.language);""",
    'replace generic reading positions',
)
app = replace_once(
    app,
    "            index < positions.length\n                ? positions[index].toUpperCase()\n                : mysticText(widget.language, 'MESSAGE', 'MESAJ'),\n",
    "            position.toUpperCase(),\n",
    'show spread-specific position heading',
)
app = replace_once(
    app,
    "          const SizedBox(height: 8),\n          Text(meaning, style: Theme.of(context).textTheme.bodyLarge),\n        ],\n",
    "          const SizedBox(height: 8),\n          Text(meaning, style: Theme.of(context).textTheme.bodyLarge),\n          const SizedBox(height: 8),\n          ReadingExplanationPanel(\n            explanation: buildReadingExplanation(\n              kind: widget.kind,\n              card: card,\n              positionIndex: index,\n              emotion: emotion,\n              intention: widget.intention,\n              language: widget.language,\n            ),\n          ),\n        ],\n",
    'insert transparent reading explanation panel',
)

app = replace_once(
    app,
    "  String t(String english, String turkish) =>\n      mysticText(widget.language, english, turkish);\n",
    """  String t(String english, String turkish) =>
      mysticText(widget.language, english, turkish);

  String localizedProfileCopy({
    required String en,
    required String tr,
    required String es,
    required String fr,
    required String pt,
  }) =>
      switch (widget.language) {
        MysticLanguage.turkish => tr,
        MysticLanguage.spanish => es,
        MysticLanguage.french => fr,
        MysticLanguage.portugueseBrazil => pt,
        _ => en,
      };
""",
    'add explicit five-language profile copy',
)
app = replace_once(
    app,
    "          subtitle: Text(\n            t(\n              '${widget.records.length} saved readings',\n              '${widget.records.length} kayıtlı okuma',\n            ),\n          ),\n",
    "          subtitle: Text(\n            localizedProfileCopy(\n              en: '${widget.records.length} readings; includes private questions and Mirror notes',\n              tr: '${widget.records.length} okuma; özel soruları ve Ayna notlarını içerir',\n              es: '${widget.records.length} lecturas; incluye preguntas privadas y notas de Mirror',\n              fr: '${widget.records.length} tirages ; inclut les questions privées et notes Mirror',\n              pt: '${widget.records.length} leituras; inclui perguntas privadas e notas do Mirror',\n            ),\n          ),\n",
    'warn about private export content',
)
app = replace_once(
    app,
    """      GoldButton(
        label: t('Copy support link', 'Destek bağlantısını kopyala'),
        icon: Icons.support_agent,
        onPressed: () async {
          await Clipboard.setData(
            ClipboardData(text: supportPageForLanguage(widget.language)),
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                t('Support link copied.', 'Destek bağlantısı kopyalandı.'),
              ),
            ),
          );
        },
      ),
""",
    """      GoldButton(
        label: localizedProfileCopy(
          en: 'Open support',
          tr: 'Desteği aç',
          es: 'Abrir soporte',
          fr: 'Ouvrir l’assistance',
          pt: 'Abrir suporte',
        ),
        icon: Icons.support_agent,
        onPressed: () async {
          final supportLink = supportPageForLanguage(widget.language);
          var opened = false;
          try {
            opened = await launchUrl(Uri.parse(supportLink));
          } catch (_) {
            opened = false;
          }
          if (opened || !context.mounted) return;
          await Clipboard.setData(ClipboardData(text: supportLink));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizedProfileCopy(
                  en: 'Support could not open, so the link was copied.',
                  tr: 'Destek açılamadı; bağlantı kopyalandı.',
                  es: 'No se pudo abrir el soporte; se copió el enlace.',
                  fr: 'Impossible d’ouvrir l’assistance ; le lien a été copié.',
                  pt: 'Não foi possível abrir o suporte; o link foi copiado.',
                ),
              ),
            ),
          );
        },
      ),
""",
    'open localized support directly with safe fallback',
)
app = regex_once(
    app,
    r"  Future<void> _exportJournal\(\) async \{.*?\n  \}\n\n  Future<void> _confirmDelete",
    """  Future<void> _exportJournal() async {
    final mirrors = await MysticMirrorStore().load();
    final text = buildMysticJournalExport(
      records: widget.records,
      mirrors: mirrors,
      language: widget.language,
    );
    final renderObject = context.findRenderObject();
    final origin = renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : const Rect.fromLTWH(0, 0, 1, 1);

    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: text,
          title: localizedProfileCopy(
            en: 'Mystic Tarot private journal export',
            tr: 'Mystic Tarot özel günlük dışa aktarımı',
            es: 'Exportación del diario privado de Mystic Tarot',
            fr: 'Export du journal privé Mystic Tarot',
            pt: 'Exportação do diário privado do Mystic Tarot',
          ),
          subject: localizedProfileCopy(
            en: 'My private Mystic Tarot journal',
            tr: 'Özel Mystic Tarot günlüğüm',
            es: 'Mi diario privado de Mystic Tarot',
            fr: 'Mon journal privé Mystic Tarot',
            pt: 'Meu diário privado do Mystic Tarot',
          ),
          sharePositionOrigin: origin,
        ),
      );
      if (!mounted || result.status == ShareResultStatus.dismissed) return;
      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizedProfileCopy(
                en: 'Your private journal was shared.',
                tr: 'Özel günlüğün paylaşıldı.',
                es: 'Tu diario privado se compartió.',
                fr: 'Votre journal privé a été partagé.',
                pt: 'Seu diário privado foi compartilhado.',
              ),
            ),
          ),
        );
        return;
      }
    } catch (_) {
      // A clipboard fallback remains available when the platform share sheet fails.
    }

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizedProfileCopy(
            en: 'Sharing was unavailable. Your journal was copied instead.',
            tr: 'Paylaşım kullanılamadı. Günlüğün bunun yerine kopyalandı.',
            es: 'No se pudo compartir. El diario se copió en su lugar.',
            fr: 'Le partage était indisponible. Le journal a été copié.',
            pt: 'O compartilhamento não estava disponível. O diário foi copiado.',
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete""",
    'replace clipboard-only export with private share flow',
)

app_path.write_text(app, encoding='utf-8')


# ---------------------------------------------------------------------------
# Living Journal integration
# ---------------------------------------------------------------------------
journal_path = Path('lib/src/mystic_living_journal_feature.dart')
journal = journal_path.read_text(encoding='utf-8')

journal = replace_once(
    journal,
    "import 'mystic_mirror.dart';\n",
    "import 'mystic_mirror.dart';\nimport 'mystic_search.dart';\n",
    'add accent-tolerant search import',
)
journal = replace_once(
    journal,
    "    this.onStartReading,\n    super.key,\n",
    "    this.onStartReading,\n    this.onMirrorChanged,\n    super.key,\n",
    'add Mirror callback constructor argument',
)
journal = replace_once(
    journal,
    "  final VoidCallback? onStartReading;\n",
    "  final VoidCallback? onStartReading;\n  final VoidCallback? onMirrorChanged;\n",
    'add Mirror callback field',
)
journal = replace_once(
    journal,
    "    var emotion = record.emotion;\n    final noteController = TextEditingController();\n",
    "    var emotion = record.emotion;\n    var saving = false;\n    final noteController = TextEditingController();\n",
    'track Mirror save state',
)
journal = replace_once(
    journal,
    """                      onPressed: outcome == null
                          ? null
                          : () async {
                              final reflection = MysticMirrorReflection(
                                recordId: mysticMirrorRecordId(record),
                                outcome: outcome!,
                                emotion: emotion,
                                note: noteController.text.trim(),
                                completedAt: DateTime.now().toUtc(),
                              );
                              await _mirrorStore.save(reflection);
                              if (!mounted) return;
                              setState(() {
                                mirrors = <String, MysticMirrorReflection>{
                                  ...mirrors,
                                  reflection.recordId: reflection,
                                };
                              });
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            },
""",
    """                      onPressed: outcome == null || saving
                          ? null
                          : () async {
                              setSheetState(() => saving = true);
                              final reflection = MysticMirrorReflection(
                                recordId: mysticMirrorRecordId(record),
                                outcome: outcome!,
                                emotion: emotion,
                                note: noteController.text.trim(),
                                completedAt: DateTime.now().toUtc(),
                              );
                              try {
                                await _mirrorStore.save(reflection);
                                if (!mounted) return;
                                setState(() {
                                  mirrors = <String, MysticMirrorReflection>{
                                    ...mirrors,
                                    reflection.recordId: reflection,
                                  };
                                });
                                widget.onMirrorChanged?.call();
                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              } catch (_) {
                                if (sheetContext.mounted) {
                                  setSheetState(() => saving = false);
                                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _mirrorCopy(
                                          en: 'The reflection could not be saved. Nothing was changed; please try again.',
                                          tr: 'Yansıma kaydedilemedi. Hiçbir şey değiştirilmedi; lütfen tekrar dene.',
                                          es: 'No se pudo guardar la reflexión. No se cambió nada; inténtalo de nuevo.',
                                          fr: 'La réflexion n’a pas pu être enregistrée. Rien n’a été modifié ; réessayez.',
                                          pt: 'Não foi possível salvar a reflexão. Nada foi alterado; tente novamente.',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
""",
    'make Mirror save failure explicit and retryable',
)
journal = replace_once(
    journal,
    "                      label: Text(\n                        _mirrorCopy(\n                          en: 'Save honest reflection',\n                          tr: 'Dürüst yansımayı kaydet',\n                          es: 'Guardar reflexión honesta',\n                          fr: 'Enregistrer la réflexion honnête',\n                          pt: 'Salvar reflexão honesta',\n                        ),\n                      ),\n",
    "                      label: Text(\n                        saving\n                            ? _mirrorCopy(\n                                en: 'Saving…',\n                                tr: 'Kaydediliyor…',\n                                es: 'Guardando…',\n                                fr: 'Enregistrement…',\n                                pt: 'Salvando…',\n                              )\n                            : _mirrorCopy(\n                                en: 'Save honest reflection',\n                                tr: 'Dürüst yansımayı kaydet',\n                                es: 'Guardar reflexión honesta',\n                                fr: 'Enregistrer la réflexion honnête',\n                                pt: 'Salvar reflexão honesta',\n                              ),\n                      ),\n",
    'show Mirror save progress',
)
journal = regex_once(
    journal,
    r"  List<ReadingRecord> get _filteredRecords \{\n    if \(query.isEmpty\) return widget.records;\n\n    final normalized = query.toLowerCase\(\);\n    return widget.records.where\(\(record\) \{\n      final mirror = mirrors\[mysticMirrorRecordId\(record\)\];\n      final searchableText = <String>\[(.*?)\n      \]\.join\(' '\)\.toLowerCase\(\);\n      return searchableText.contains\(normalized\);\n    \}\)\.toList\(\);\n  \}",
    """  List<ReadingRecord> get _filteredRecords {
    if (query.isEmpty) return widget.records;

    return widget.records.where((record) {
      final mirror = mirrors[mysticMirrorRecordId(record)];
      return mysticSearchMatches(
        query: query,
        values: <String>[
          record.kind.title,
          localizedReadingKindTitle(record.kind, languageCode: _languageCode),
          record.question,
          record.emotion.label,
          localizedEmotionLabel(record.emotion, languageCode: _languageCode),
          record.alignedAction,
          if (mirror != null) mirror.note,
          if (mirror != null) _outcomeLabel(mirror.outcome),
          if (mirror != null)
            localizedEmotionLabel(mirror.emotion, languageCode: _languageCode),
          ...record.cards.map((drawn) => drawn.card.name),
          ...record.cards.map(
            (drawn) => localizedTarotCardName(
              drawn.card.name,
              languageCode: _languageCode,
            ),
          ),
        ],
      );
    }).toList();
  }""",
    'replace raw lowercase journal search',
)
journal_path.write_text(journal, encoding='utf-8')


# ---------------------------------------------------------------------------
# Explainable reading integration
# ---------------------------------------------------------------------------
explanation_path = Path('lib/src/reading_explanation.dart')
explanation = explanation_path.read_text(encoding='utf-8')
explanation = replace_once(
    explanation,
    "import 'models.dart';\n",
    "import 'models.dart';\nimport 'reading_position.dart';\n",
    'add spread position import',
)
explanation = replace_once(
    explanation,
    "ReadingExplanation buildReadingExplanation({\n  required DrawnCard card,\n",
    "ReadingExplanation buildReadingExplanation({\n  required ReadingKind kind,\n  required DrawnCard card,\n",
    'add reading kind to explanation contract',
)
explanation = regex_once(
    explanation,
    r"  final positions = <String>\[.*?\n        \);\n\n  final orientation =",
    """  final position = localizedReadingPosition(
    kind: kind,
    index: positionIndex,
    language: language,
  );

  final orientation =""",
    'use spread-specific explanation positions',
)
explanation_path.write_text(explanation, encoding='utf-8')

explanation_test_path = Path('test/reading_explanation_test.dart')
explanation_test = explanation_test_path.read_text(encoding='utf-8')
explanation_test, count = re.subn(
    r"buildReadingExplanation\(\n(\s*)card:",
    r"buildReadingExplanation(\n\1kind: ReadingKind.daily,\n\1card:",
    explanation_test,
)
if count != 5:
    raise SystemExit(
        f'update explanation test call sites: expected 5 matches, found {count}'
    )
explanation_test_path.write_text(explanation_test, encoding='utf-8')


# ---------------------------------------------------------------------------
# Preserve only validated snapshots as backups
# ---------------------------------------------------------------------------
journal_store_path = Path('lib/src/reading_journal_store.dart')
journal_store = journal_store_path.read_text(encoding='utf-8')
journal_store = replace_once(
    journal_store,
    "    if (currentPayload != null && currentPayload.trim().isNotEmpty) {\n      final backupSaved =\n          await preferences.setString(backupKey, currentPayload);\n",
    "    if (currentPayload != null &&\n        currentPayload.trim().isNotEmpty &&\n        _isTrustworthyPayload(currentPayload)) {\n      final backupSaved =\n          await preferences.setString(backupKey, currentPayload);\n",
    'avoid replacing journal backup with corrupt primary',
)
journal_store = replace_once(
    journal_store,
    "  Future<void> finishLegacyMigration() async {\n",
    """  bool _isTrustworthyPayload(String payload) {
    try {
      final report = ReadingJournalCodec.decode(payload);
      return report.records.isNotEmpty || report.rejectedItems == 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> finishLegacyMigration() async {
""",
    'add journal payload validation',
)
journal_store_path.write_text(journal_store, encoding='utf-8')

mirror_store_path = Path('lib/src/mystic_mirror.dart')
mirror_store = mirror_store_path.read_text(encoding='utf-8')
mirror_store = replace_once(
    mirror_store,
    "    final currentPrimary = preferences.getStringList(storageKey);\n    if (currentPrimary != null && currentPrimary.isNotEmpty) {\n      final backupSaved =\n          await preferences.setStringList(backupKey, currentPrimary);\n",
    "    final currentPrimary = preferences.getStringList(storageKey);\n    final primaryIsFullyValid = currentPrimary != null &&\n        currentPrimary.isNotEmpty &&\n        currentPrimary.every(\n          (encoded) => MysticMirrorReflection.tryDecode(encoded) != null,\n        );\n    if (primaryIsFullyValid) {\n      final backupSaved =\n          await preferences.setStringList(backupKey, currentPrimary);\n",
    'avoid replacing Mirror backup with corrupt primary',
)
mirror_store_path.write_text(mirror_store, encoding='utf-8')


# ---------------------------------------------------------------------------
# Version and release documentation
# ---------------------------------------------------------------------------
pubspec_path = Path('pubspec.yaml')
pubspec = pubspec_path.read_text(encoding='utf-8')
pubspec = replace_once(
    pubspec,
    'version: 1.10.2+16\n',
    'version: 1.11.0+17\n',
    'advance release version',
)
pubspec_path.write_text(pubspec, encoding='utf-8')

release_notes_path = Path('RELEASE_NOTES.md')
release_notes = release_notes_path.read_text(encoding='utf-8')
release_header = """# Mystic Tarot 1.11.0 — Mirror & Trust

This release turns Mystic’s core promise into a complete, durable product loop.

## What is new

- Mystic Mirror is now a real 24-hour follow-up: record what changed, how you feel now, and an optional private reflection.
- Due Mirror check-ins surface in the Journal and on an accessible five-language navigation badge, including while the app remains open.
- Every card can explain the spread position, upright/reversed lens, traditional symbolic basis, practical bridge, and personal context used in the interpretation.
- Journal search tolerates Turkish characters and French, Spanish, and Portuguese accents.
- The full private export includes questions, cards, actions, Mirror outcomes, emotional transitions, and reflection notes; sharing remains user-initiated with a clipboard fallback.

## Trust and resilience

- The complete journal is stored without the previous 50-reading cap.
- Journal and Mirror data keep last-known-good local backups and recover from unreadable or partially damaged snapshots.
- Only validated primary snapshots may replace a good backup.
- Recovery and legacy migration are disclosed in the selected launch language instead of silently hiding damaged entries.
- Mirror save failures remain retryable and never close the sheet as if the data were saved.
- Reduced-motion support, timer disposal, localized support routing, and narrow-screen accessibility remain enforced.

## Launch languages

English, Turkish, neutral international Spanish, French, and Brazilian Portuguese remain complete across the release experience.

## Validation target

Flutter analysis, the complete automated test suite, web release, and Android App Bundle must all pass before this release candidate can merge.

---

"""
release_notes_path.write_text(release_header + release_notes, encoding='utf-8')
