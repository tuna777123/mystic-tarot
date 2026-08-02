from pathlib import Path

APP = Path('lib/src/app.dart')
JOURNAL = Path('lib/src/mystic_living_journal_feature.dart')
EXPORT = Path('lib/src/journal_export.dart')
PUBSPEC = Path('pubspec.yaml')
NOTES = Path('RELEASE_NOTES.md')


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected one match, found {count}')
    return text.replace(old, new, 1)


app = APP.read_text()
if "import 'oracle_conversation.dart';" not in app:
    app = replace_once(
        app,
        "import 'mystic_next_step.dart';\n",
        "import 'mystic_next_step.dart';\nimport 'oracle_conversation.dart';\n",
        'Oracle import',
    )
    app = replace_once(
        app,
        "          onPremium: () => _showPremium(source: 'living_journal'),\n          onMirrorChanged: _refreshMirrorDueState,\n",
        "          onPremium: () => _showPremium(source: 'living_journal'),\n          onOpenOracle: _openSavedOracle,\n          onMirrorChanged: _refreshMirrorDueState,\n",
        'Journal Oracle callback',
    )
    app = replace_once(
        app,
        "  Future<void> _showCardDiscovery(List<TarotCardData> cards) async {\n",
        "  Future<void> _openSavedOracle(ReadingRecord record) async {\n"
        "    await navigatorKey.currentState!.push(\n"
        "      MaterialPageRoute(\n"
        "        builder: (_) => OracleDialogueScreen(\n"
        "          record: record,\n"
        "          pastRecords: journal,\n"
        "          userName: userName,\n"
        "          intention: intention,\n"
        "          language: language,\n"
        "          isPlus: isPlus,\n"
        "          onQuestionUsed: () {},\n"
        "          onPremium: () => _showPremium(source: 'oracle_dialogue'),\n"
        "        ),\n"
        "      ),\n"
        "    );\n"
        "  }\n\n"
        "  Future<void> _showCardDiscovery(List<TarotCardData> cards) async {\n",
        'Saved Oracle route',
    )
    app = replace_once(
        app,
        "class _OracleDialogueScreenState extends State<OracleDialogueScreen> {\n"
        "  final controller = TextEditingController();\n"
        "  String? askedQuestion;\n"
        "  String? answer;\n"
        "  bool thinking = false;\n\n"
        "  @override\n"
        "  void dispose() {\n",
        "class _OracleDialogueScreenState extends State<OracleDialogueScreen> {\n"
        "  final controller = TextEditingController();\n"
        "  final conversationStore = OracleConversationStore();\n"
        "  List<OracleConversationTurn> turns = <OracleConversationTurn>[];\n"
        "  String? askedQuestion;\n"
        "  String? answer;\n"
        "  String? saveError;\n"
        "  String? lastSavedTurnId;\n"
        "  bool thinking = false;\n"
        "  bool historyLoading = true;\n\n"
        "  List<OracleConversationTurn> get _historyTurns => lastSavedTurnId == null\n"
        "      ? turns\n"
        "      : turns\n"
        "          .where((turn) => turn.turnId != lastSavedTurnId)\n"
        "          .toList(growable: false);\n\n"
        "  @override\n"
        "  void initState() {\n"
        "    super.initState();\n"
        "    _loadConversation();\n"
        "  }\n\n"
        "  Future<void> _loadConversation() async {\n"
        "    final loaded = await conversationStore.loadForRecord(widget.record);\n"
        "    if (!mounted) return;\n"
        "    setState(() {\n"
        "      turns = loaded;\n"
        "      historyLoading = false;\n"
        "    });\n"
        "  }\n\n"
        "  @override\n"
        "  void dispose() {\n",
        'Oracle state and loading',
    )
    app = replace_once(
        app,
        "            const SizedBox(height: 22),\n"
        "            if (askedQuestion == null) ...[\n",
        "            const SizedBox(height: 22),\n"
        "            if (historyLoading)\n"
        "              const Center(\n"
        "                child: Padding(\n"
        "                  padding: EdgeInsets.symmetric(vertical: 18),\n"
        "                  child: CircularProgressIndicator(\n"
        "                    strokeWidth: 2,\n"
        "                    color: MysticColors.gold,\n"
        "                  ),\n"
        "                ),\n"
        "              ),\n"
        "            if (!historyLoading && _historyTurns.isNotEmpty) ...[\n"
        "              _buildSavedHistory(context),\n"
        "              const SizedBox(height: 18),\n"
        "            ],\n"
        "            if (!historyLoading &&\n"
        "                askedQuestion == null &&\n"
        "                !widget.isPlus &&\n"
        "                turns.isNotEmpty)\n"
        "              _buildLockedHistoryCard(context),\n"
        "            if (!historyLoading &&\n"
        "                askedQuestion == null &&\n"
        "                (widget.isPlus || turns.isEmpty)) ...[\n",
        'Oracle history gate',
    )
    app = replace_once(
        app,
        "              if (answer != null)\n"
        "                _messageBubble(context, answer!, fromOracle: true),\n"
        "              if (answer != null) const SizedBox(height: 18),\n",
        "              if (answer != null)\n"
        "                _messageBubble(context, answer!, fromOracle: true),\n"
        "              if (saveError != null) ...[\n"
        "                const SizedBox(height: 10),\n"
        "                Text(\n"
        "                  saveError!,\n"
        "                  textAlign: TextAlign.center,\n"
        "                  style: const TextStyle(\n"
        "                    color: Color(0xFFFFB3BC),\n"
        "                    fontSize: 11,\n"
        "                  ),\n"
        "                ),\n"
        "              ],\n"
        "              if (answer != null) const SizedBox(height: 18),\n",
        'Oracle save disclosure',
    )
    app = replace_once(
        app,
        "  void _resetConversation() {\n"
        "    controller.clear();\n"
        "    setState(() {\n"
        "      askedQuestion = null;\n"
        "      answer = null;\n"
        "      thinking = false;\n"
        "    });\n"
        "  }\n\n"
        "  Widget _messageBubble(\n",
        "  void _resetConversation() {\n"
        "    controller.clear();\n"
        "    setState(() {\n"
        "      askedQuestion = null;\n"
        "      answer = null;\n"
        "      saveError = null;\n"
        "      lastSavedTurnId = null;\n"
        "      thinking = false;\n"
        "    });\n"
        "  }\n\n"
        "  Widget _buildSavedHistory(BuildContext context) {\n"
        "    final history = _historyTurns;\n"
        "    return Container(\n"
        "      width: double.infinity,\n"
        "      padding: const EdgeInsets.all(17),\n"
        "      decoration: BoxDecoration(\n"
        "        color: Colors.white.withValues(alpha: .04),\n"
        "        borderRadius: BorderRadius.circular(20),\n"
        "        border: Border.all(\n"
        "          color: MysticColors.lavender.withValues(alpha: .18),\n"
        "        ),\n"
        "      ),\n"
        "      child: Column(\n"
        "        crossAxisAlignment: CrossAxisAlignment.start,\n"
        "        children: [\n"
        "          Row(\n"
        "            children: [\n"
        "              const Icon(Icons.memory_rounded, color: MysticColors.gold),\n"
        "              const SizedBox(width: 9),\n"
        "              Expanded(\n"
        "                child: Text(\n"
        "                  _oracleCopy(\n"
        "                    en: 'SAVED ORACLE MEMORY',\n"
        "                    tr: 'KAYITLI ORACLE HAFIZASI',\n"
        "                    es: 'MEMORIA GUARDADA DEL ORÁCULO',\n"
        "                    fr: 'MÉMOIRE ENREGISTRÉE DE L’ORACLE',\n"
        "                    pt: 'MEMÓRIA SALVA DO ORÁCULO',\n"
        "                  ),\n"
        "                  style: const TextStyle(\n"
        "                    color: MysticColors.gold,\n"
        "                    fontSize: 9,\n"
        "                    fontWeight: FontWeight.w900,\n"
        "                    letterSpacing: 1,\n"
        "                  ),\n"
        "                ),\n"
        "              ),\n"
        "              Text(\n"
        "                '${history.length}',\n"
        "                style: const TextStyle(\n"
        "                  color: MysticColors.gold,\n"
        "                  fontWeight: FontWeight.w900,\n"
        "                ),\n"
        "              ),\n"
        "            ],\n"
        "          ),\n"
        "          const SizedBox(height: 6),\n"
        "          Text(\n"
        "            _oracleCopy(\n"
        "              en: 'Stored only on this device and linked to this reading.',\n"
        "              tr: 'Yalnızca bu cihazda saklanır ve bu okumaya bağlıdır.',\n"
        "              es: 'Se guarda solo en este dispositivo y está vinculada a esta lectura.',\n"
        "              fr: 'Stockée uniquement sur cet appareil et liée à ce tirage.',\n"
        "              pt: 'Armazenada somente neste dispositivo e ligada a esta leitura.',\n"
        "            ),\n"
        "            style: const TextStyle(\n"
        "              color: MysticColors.muted,\n"
        "              fontSize: 10,\n"
        "            ),\n"
        "          ),\n"
        "          for (final turn in history) ...[\n"
        "            const SizedBox(height: 14),\n"
        "            Text(\n"
        "              _formatOracleTime(turn.createdAt),\n"
        "              style: const TextStyle(\n"
        "                color: MysticColors.muted,\n"
        "                fontSize: 9,\n"
        "              ),\n"
        "            ),\n"
        "            const SizedBox(height: 6),\n"
        "            _messageBubble(context, turn.question, fromOracle: false),\n"
        "            const SizedBox(height: 8),\n"
        "            _messageBubble(context, turn.answer, fromOracle: true),\n"
        "          ],\n"
        "        ],\n"
        "      ),\n"
        "    );\n"
        "  }\n\n"
        "  Widget _buildLockedHistoryCard(BuildContext context) => Container(\n"
        "    padding: const EdgeInsets.all(18),\n"
        "    decoration: BoxDecoration(\n"
        "      gradient: const LinearGradient(\n"
        "        colors: [Color(0xFF493269), Color(0xFF20162D)],\n"
        "      ),\n"
        "      borderRadius: BorderRadius.circular(20),\n"
        "      border: Border.all(color: MysticColors.gold.withValues(alpha: .3)),\n"
        "    ),\n"
        "    child: Column(\n"
        "      crossAxisAlignment: CrossAxisAlignment.start,\n"
        "      children: [\n"
        "        Text(\n"
        "          _oracleCopy(\n"
        "            en: 'Your free answer is saved',\n"
        "            tr: 'Ücretsiz cevabın kaydedildi',\n"
        "            es: 'Tu respuesta gratuita está guardada',\n"
        "            fr: 'Votre réponse gratuite est enregistrée',\n"
        "            pt: 'Sua resposta gratuita foi salva',\n"
        "          ),\n"
        "          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),\n"
        "        ),\n"
        "        const SizedBox(height: 7),\n"
        "        Text(\n"
        "          _oracleCopy(\n"
        "            en: 'You can revisit it here at any time. Mystic Plus continues the same private conversation.',\n"
        "            tr: 'Buraya istediğin zaman dönebilirsin. Mystic Plus aynı özel konuşmayı sürdürür.',\n"
        "            es: 'Puedes volver aquí cuando quieras. Mystic Plus continúa la misma conversación privada.',\n"
        "            fr: 'Vous pouvez la relire ici à tout moment. Mystic Plus poursuit la même conversation privée.',\n"
        "            pt: 'Você pode voltar aqui quando quiser. O Mystic Plus continua a mesma conversa privada.',\n"
        "          ),\n"
        "          style: Theme.of(context).textTheme.bodyMedium,\n"
        "        ),\n"
        "        const SizedBox(height: 14),\n"
        "        GoldButton(\n"
        "          label: _oracleCopy(\n"
        "            en: 'Continue with Mystic Plus',\n"
        "            tr: 'Mystic Plus ile devam et',\n"
        "            es: 'Continuar con Mystic Plus',\n"
        "            fr: 'Continuer avec Mystic Plus',\n"
        "            pt: 'Continuar com Mystic Plus',\n"
        "          ),\n"
        "          icon: Icons.lock_open_rounded,\n"
        "          onPressed: widget.onPremium,\n"
        "        ),\n"
        "      ],\n"
        "    ),\n"
        "  );\n\n"
        "  String _oracleCopy({\n"
        "    required String en,\n"
        "    required String tr,\n"
        "    required String es,\n"
        "    required String fr,\n"
        "    required String pt,\n"
        "  }) => switch (widget.language) {\n"
        "    MysticLanguage.turkish => tr,\n"
        "    MysticLanguage.spanish => es,\n"
        "    MysticLanguage.french => fr,\n"
        "    MysticLanguage.portugueseBrazil => pt,\n"
        "    _ => en,\n"
        "  };\n\n"
        "  String _formatOracleTime(DateTime value) {\n"
        "    final local = value.toLocal();\n"
        "    String two(int number) => number.toString().padLeft(2, '0');\n"
        "    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';\n"
        "  }\n\n"
        "  Widget _messageBubble(\n",
        'Oracle history widgets',
    )
    app = replace_once(
        app,
        "  Future<void> _ask(String question) async {\n"
        "    if (askedQuestion != null || question.trim().isEmpty) return;\n"
        "    FocusScope.of(context).unfocus();\n"
        "    widget.onQuestionUsed();\n"
        "    setState(() {\n"
        "      askedQuestion = question.trim();\n"
        "      thinking = true;\n"
        "    });\n"
        "    await Future<void>.delayed(const Duration(milliseconds: 1100));\n"
        "    if (!mounted) return;\n"
        "    setState(() {\n"
        "      thinking = false;\n"
        "      answer = _composeAnswer(question);\n"
        "    });\n"
        "  }\n",
        "  Future<void> _ask(String question) async {\n"
        "    final cleanQuestion = question.trim();\n"
        "    if (askedQuestion != null || cleanQuestion.isEmpty || historyLoading) return;\n"
        "    if (!widget.isPlus && turns.isNotEmpty) return;\n"
        "    FocusScope.of(context).unfocus();\n"
        "    widget.onQuestionUsed();\n"
        "    setState(() {\n"
        "      askedQuestion = cleanQuestion;\n"
        "      thinking = true;\n"
        "      saveError = null;\n"
        "    });\n"
        "    await Future<void>.delayed(const Duration(milliseconds: 1100));\n"
        "    if (!mounted) return;\n"
        "    final response = _composeAnswer(cleanQuestion);\n"
        "    final turn = OracleConversationTurn.create(\n"
        "      record: widget.record,\n"
        "      question: cleanQuestion,\n"
        "      answer: response,\n"
        "    );\n"
        "    var saved = false;\n"
        "    try {\n"
        "      await conversationStore.saveTurn(turn);\n"
        "      saved = true;\n"
        "    } catch (_) {\n"
        "      saved = false;\n"
        "    }\n"
        "    if (!mounted) return;\n"
        "    setState(() {\n"
        "      thinking = false;\n"
        "      answer = response;\n"
        "      if (saved) {\n"
        "        turns = <OracleConversationTurn>[...turns, turn]\n"
        "          ..sort((first, second) => first.createdAt.compareTo(second.createdAt));\n"
        "        lastSavedTurnId = turn.turnId;\n"
        "      } else {\n"
        "        saveError = _oracleCopy(\n"
        "          en: 'The answer is visible, but this device could not save it. Copy it before leaving.',\n"
        "          tr: 'Cevap görünür durumda ancak bu cihaz kaydedemedi. Çıkmadan önce kopyala.',\n"
        "          es: 'La respuesta está visible, pero el dispositivo no pudo guardarla. Cópiala antes de salir.',\n"
        "          fr: 'La réponse est visible, mais l’appareil n’a pas pu l’enregistrer. Copiez-la avant de quitter.',\n"
        "          pt: 'A resposta está visível, mas o dispositivo não conseguiu salvá-la. Copie antes de sair.',\n"
        "        );\n"
        "      }\n"
        "    });\n"
        "  }\n",
        'Oracle persisted ask',
    )
    app = replace_once(
        app,
        "    final memory = _oracleMemory();\n",
        "    final memory = '${_oracleMemory()}${_oracleConversationThread()}';\n",
        'Oracle thread memory',
    )
    app = replace_once(
        app,
        "  String _oracleMemory() {\n",
        "  String _oracleConversationThread() {\n"
        "    if (turns.isEmpty) return '';\n"
        "    final previous = turns.last;\n"
        "    return _oracleCopy(\n"
        "      en: ' Your previous question in this reading was “${previous.question}”. Keep the new answer consistent with that thread without treating it as certainty.',\n"
        "      tr: ' Bu okumadaki önceki sorun “${previous.question}” idi. Yeni cevabı kesinlik gibi sunmadan bu çizgiyle tutarlı tut.',\n"
        "      es: ' Tu pregunta anterior en esta lectura fue “${previous.question}”. Mantén la nueva respuesta coherente con ese hilo sin presentarla como certeza.',\n"
        "      fr: ' Votre question précédente pour ce tirage était « ${previous.question} ». Gardez la nouvelle réponse cohérente avec ce fil sans la présenter comme une certitude.',\n"
        "      pt: ' Sua pergunta anterior nesta leitura foi “${previous.question}”. Mantenha a nova resposta coerente com esse fio sem tratá-la como certeza.',\n"
        "    );\n"
        "  }\n\n"
        "  String _oracleMemory() {\n",
        'Oracle previous turn context',
    )
    app = replace_once(
        app,
        "  Future<void> _exportJournal() async {\n"
        "    final mirrors = await MysticMirrorStore().load();\n"
        "    if (!mounted) return;\n"
        "    final text = buildMysticJournalExport(\n"
        "      records: widget.records,\n"
        "      mirrors: mirrors,\n"
        "      language: widget.language,\n"
        "    );\n",
        "  Future<void> _exportJournal() async {\n"
        "    final mirrors = await MysticMirrorStore().load();\n"
        "    final oracleConversations = await OracleConversationStore().loadGrouped();\n"
        "    if (!mounted) return;\n"
        "    final text = buildMysticJournalExport(\n"
        "      records: widget.records,\n"
        "      mirrors: mirrors,\n"
        "      oracleConversations: oracleConversations,\n"
        "      language: widget.language,\n"
        "    );\n",
        'Oracle export loading',
    )
    app = replace_once(
        app,
        "This cannot be undone. Your journal, card collection, streak, XP, and preferences will be removed from this device.",
        "This cannot be undone. Your journal, Oracle conversations, card collection, streak, XP, and preferences will be removed from this device.",
        'English deletion disclosure',
    )
    app = replace_once(
        app,
        "Bu işlem geri alınamaz. Günlüğün, kart koleksiyonun, serin, XP’n ve tercihlerin bu cihazdan kaldırılır.",
        "Bu işlem geri alınamaz. Günlüğün, Oracle konuşmaların, kart koleksiyonun, serin, XP’n ve tercihlerin bu cihazdan kaldırılır.",
        'Turkish deletion disclosure',
    )
    APP.write_text(app)

journal = JOURNAL.read_text()
if "import 'oracle_conversation.dart';" not in journal:
    journal = replace_once(
        journal,
        "import 'mystic_search.dart';\n",
        "import 'mystic_search.dart';\nimport 'oracle_conversation.dart';\nimport 'oracle_memory_action.dart';\n",
        'Journal Oracle imports',
    )
    journal = replace_once(
        journal,
        "    required this.onPremium,\n    this.onStartReading,\n",
        "    required this.onPremium,\n    required this.onOpenOracle,\n    this.onStartReading,\n",
        'Journal Oracle constructor',
    )
    journal = replace_once(
        journal,
        "  final VoidCallback onPremium;\n  final VoidCallback? onStartReading;\n",
        "  final VoidCallback onPremium;\n  final Future<void> Function(ReadingRecord record) onOpenOracle;\n  final VoidCallback? onStartReading;\n",
        'Journal Oracle field',
    )
    journal = replace_once(
        journal,
        "  final MysticMirrorStore _mirrorStore = MysticMirrorStore();\n",
        "  final MysticMirrorStore _mirrorStore = MysticMirrorStore();\n  final OracleConversationStore _oracleStore = OracleConversationStore();\n",
        'Journal Oracle store',
    )
    journal = replace_once(
        journal,
        "  bool mirrorsLoading = true;\n",
        "  bool mirrorsLoading = true;\n  bool oracleLoading = true;\n  Map<String, int> oracleTurnCounts = const <String, int>{};\n",
        'Journal Oracle state',
    )
    journal = replace_once(
        journal,
        "  void initState() {\n    super.initState();\n    _loadMirrors();\n  }\n",
        "  void initState() {\n    super.initState();\n    _loadMirrors();\n    _loadOracleMemory();\n  }\n",
        'Journal Oracle init',
    )
    journal = replace_once(
        journal,
        "  @override\n  Widget build(BuildContext context) {\n",
        "  Future<void> _loadOracleMemory() async {\n"
        "    final grouped = await _oracleStore.loadGrouped();\n"
        "    if (!mounted) return;\n"
        "    setState(() {\n"
        "      oracleTurnCounts = grouped.map(\n"
        "        (recordId, turns) => MapEntry(recordId, turns.length),\n"
        "      );\n"
        "      oracleLoading = false;\n"
        "    });\n"
        "  }\n\n"
        "  Future<void> _openOracle(ReadingRecord record) async {\n"
        "    await widget.onOpenOracle(record);\n"
        "    if (!mounted) return;\n"
        "    await _loadOracleMemory();\n"
        "  }\n\n"
        "  @override\n  Widget build(BuildContext context) {\n",
        'Journal Oracle methods',
    )
    journal = replace_once(
        journal,
        "          if (mirror == null && !due && !mirrorsLoading)\n"
        "            _buildWaitingMirror(record),\n",
        "          if (mirror == null && !due && !mirrorsLoading)\n"
        "            _buildWaitingMirror(record),\n"
        "          if (!oracleLoading) ...[\n"
        "            const SizedBox(height: 12),\n"
        "            OracleMemoryAction(\n"
        "              turnCount:\n"
        "                  oracleTurnCounts[oracleConversationRecordId(record)] ?? 0,\n"
        "              language: widget.language,\n"
        "              onTap: () => _openOracle(record),\n"
        "            ),\n"
        "          ],\n",
        'Journal Oracle action',
    )
    JOURNAL.write_text(journal)

export = EXPORT.read_text()
if "import 'oracle_conversation.dart';" not in export:
    export = replace_once(
        export,
        "import 'mystic_mirror.dart';\n",
        "import 'mystic_mirror.dart';\nimport 'oracle_conversation.dart';\n",
        'Export Oracle import',
    )
    export = replace_once(
        export,
        "  required Map<String, MysticMirrorReflection> mirrors,\n  required MysticLanguage language,\n",
        "  required Map<String, MysticMirrorReflection> mirrors,\n  Map<String, List<OracleConversationTurn>> oracleConversations =\n      const <String, List<OracleConversationTurn>>{},\n  required MysticLanguage language,\n",
        'Export Oracle argument',
    )
    export = replace_once(
        export,
        "    final mirror = mirrors[mysticMirrorRecordId(record)];\n",
        "    final mirror = mirrors[mysticMirrorRecordId(record)];\n"
        "    final oracleTurns =\n"
        "        oracleConversations[oracleConversationRecordId(record)] ??\n"
        "            const <OracleConversationTurn>[];\n",
        'Export Oracle turns',
    )
    export = replace_once(
        export,
        "    blocks.add(lines.join('\\n'));\n",
        "    if (oracleTurns.isNotEmpty) {\n"
        "      lines.add('');\n"
        "      lines.add(\n"
        "        copy(\n"
        "          en: 'Oracle Dialogue — saved on this device',\n"
        "          tr: 'Oracle Diyaloğu — bu cihazda kayıtlı',\n"
        "          es: 'Diálogo del Oráculo — guardado en este dispositivo',\n"
        "          fr: 'Dialogue de l’Oracle — enregistré sur cet appareil',\n"
        "          pt: 'Diálogo do Oráculo — salvo neste dispositivo',\n"
        "        ),\n"
        "      );\n"
        "      for (var turnIndex = 0; turnIndex < oracleTurns.length; turnIndex++) {\n"
        "        final turn = oracleTurns[turnIndex];\n"
        "        lines.add('');\n"
        "        lines.add(\n"
        "          '${turnIndex + 1}. ${copy(en: 'Question', tr: 'Soru', es: 'Pregunta', fr: 'Question', pt: 'Pergunta')}: ${turn.question}',\n"
        "        );\n"
        "        lines.add(\n"
        "          '${copy(en: 'Oracle answer', tr: 'Oracle cevabı', es: 'Respuesta del Oráculo', fr: 'Réponse de l’Oracle', pt: 'Resposta do Oráculo')}: ${turn.answer}',\n"
        "        );\n"
        "        lines.add(\n"
        "          '${copy(en: 'Saved', tr: 'Kaydedilme', es: 'Guardado', fr: 'Enregistré', pt: 'Salvo')}: ${_formatExportDate(turn.createdAt)}',\n"
        "        );\n"
        "      }\n"
        "    }\n\n"
        "    blocks.add(lines.join('\\n'));\n",
        'Export Oracle section',
    )
    EXPORT.write_text(export)

pubspec = PUBSPEC.read_text()
pubspec = replace_once(
    pubspec,
    'version: 1.15.0+21',
    'version: 1.16.0+22',
    'v1.16 version',
)
PUBSPEC.write_text(pubspec)

notes = NOTES.read_text()
header = '# Mystic Tarot 1.16.0 — Private Oracle Memory\n'
if not notes.startswith(header):
    section = """# Mystic Tarot 1.16.0 — Private Oracle Memory

This release makes the Oracle Dialogue promise real: follow-up questions and answers are now saved privately, linked to the original reading, recoverable after local corruption, and available from the Living Journal.

## A conversation that remembers

- Every completed Oracle exchange is saved on this device and attached to the exact reading that produced it.
- Returning to a reading restores its complete Oracle thread instead of opening an empty conversation.
- Free users keep one saved answer per reading and can revisit it; Mystic Plus can continue the same private thread with additional questions.
- Later questions receive a small continuity signal from the previous saved turn without presenting the response as certainty.
- Save failure is disclosed immediately; Mystic never claims that an unsaved answer is stored.

## Living Journal and complete export

- Every Journal reading now exposes an Oracle action with its verified saved-exchange count.
- The action opens the same reading-linked dialogue and refreshes when the user returns.
- Private journal exports now include every saved Oracle question and answer beside the correct reading and Mystic Mirror evidence.
- Deleting all Mystic data explicitly includes Oracle conversations.

## Trust and resilience

- Oracle memory uses versioned local storage with a previous-snapshot backup and partial-corruption recovery.
- No Oracle question or answer is uploaded, added to analytics, or shared with advertisers.
- Complete English, Turkish, Spanish, French, and Brazilian Portuguese memory and recovery copy.
- Version `1.16.0+22`.

---

"""
    NOTES.write_text(section + notes)
