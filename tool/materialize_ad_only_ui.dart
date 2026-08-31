import 'dart:io';

void main() => materializeAdOnlyUi();

/// Removes the final user-visible paid-tier remnants from historical source
/// before every verified build. The migration is deterministic, idempotent and
/// fails closed if a known source anchor disappears unexpectedly.
void materializeAdOnlyUi() {
  final app = File('lib/src/app.dart');
  final intelligence = File('lib/src/mystic_plus_intelligence_screen.dart');
  final journal = File('lib/src/mystic_living_journal_feature.dart');
  if (!app.existsSync() ||
      !intelligence.existsSync() ||
      !journal.existsSync()) {
    throw StateError('Mystic Tarot UI source files are missing.');
  }

  var appSource = app.readAsStringSync();
  appSource = _insertAfterRequired(
    appSource,
    "import 'ad_revenue_service.dart';\n",
    "import 'business_metrics.dart';\n",
    'business metrics app import',
  );
  appSource = _insertAfterRequired(
    appSource,
    "import 'growth_engine.dart';\n",
    "import 'growth_evidence_screen.dart';\n",
    'growth evidence app import',
  );
  appSource = _insertAfterRequired(
    appSource,
    "import 'mystic_mirror.dart';\n",
    "import 'mirror_growth_tracker.dart';\n",
    'Mirror growth tracker app import',
  );
  appSource = _replaceRequired(
    appSource,
    '''                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: MysticColors.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PLUS',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            color: MysticColors.ink,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7,
                          ),
                        ),
                      ),''',
    '''                      const Icon(
                        Icons.lock_open_rounded,
                        color: MysticColors.gold,
                        size: 18,
                      ),''',
    'deep-reading paid badge',
  );
  appSource = appSource.replaceAll("'PLUS'", "'OPEN'");
  appSource = _replaceRequired(
    appSource,
    "'\${kind.cardCount}-card premium spread'",
    "'\${kind.cardCount}-card deep spread'",
    'English premium-spread copy',
  );
  appSource = _replaceRequired(
    appSource,
    "'\${kind.cardCount} kartlık premium açılım'",
    "'\${kind.cardCount} kartlık derin açılım'",
    'Turkish premium-spread copy',
  );
  appSource = _replaceRequired(
    appSource,
    "mysticText(language, 'PLUS ACTIVE', 'PLUS ETKİN')",
    "mysticText(language, 'ALL OPEN', 'HEPSİ AÇIK')",
    'active paid-tier label',
  );
  appSource = _replaceRequired(
    appSource,
    "mysticText(language, 'VIEW PLUS', 'PLUS’I GÖR')",
    "mysticText(language, 'ALL OPEN', 'HEPSİ AÇIK')",
    'paid-tier action label',
  );
  appSource = _replaceRequired(
    appSource,
    "'Free deep readings used'",
    "'Deep readings stay open'",
    'English exhausted-reading copy',
  );
  appSource = _replaceRequired(
    appSource,
    "'Ücretsiz derin okumalar kullanıldı'",
    "'Derin okumalar açık kalır'",
    'Turkish exhausted-reading copy',
  );
  appSource = _replaceRequired(
    appSource,
    '''  Future<void> _refreshMirrorDueState() async {
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
  }''',
    '''  Future<void> _refreshMirrorDueState() async {
    final reflections = await mirrorStore.load();
    if (!mounted) return;
    final now = DateTime.now();
    final previousMirrorDueCount = mirrorDueCount;
    setState(() {
      mirrorDueCount = countDueMysticMirrors(
        records: journal,
        reflections: reflections,
        now: now,
      );
    });
    if (previousMirrorDueCount == 0 && mirrorDueCount > 0) {
      unawaited(
        MysticBusinessMetrics.record(
          MysticBusinessEvent.mirrorDueSeen,
          dimensions: <String, String>{
            'language': language.code,
            'source': 'mirror_due_state',
          },
        ),
      );
    }
    unawaited(
      MysticMirrorGrowthTracker.instance.sync(
        records: journal,
        reflections: reflections,
        languageCode: language.code,
        now: now,
      ),
    );
    _scheduleNextMirrorDue(reflections, now);
  }''',
    'Mirror due and mature-window business events',
  );
  appSource = _replaceRequired(
    appSource,
    '''  Future<void> _finishOnboarding(
    String name,
    String selectedIntention,
    MysticLanguage selectedLanguage,
  ) async {
    final cleanName = name.trim();
    setState(() {
      onboarded = true;
      userName = cleanName.length > 18 ? cleanName.substring(0, 18) : cleanName;
      intention = selectedIntention;
      language = selectedLanguage;
    });
    await _saveProgress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startReading(ReadingKind.daily);
    });
  }''',
    '''  Future<void> _finishOnboarding(
    String name,
    String selectedIntention,
    MysticLanguage selectedLanguage,
  ) async {
    final cleanName = name.trim();
    setState(() {
      onboarded = true;
      userName = cleanName.length > 18 ? cleanName.substring(0, 18) : cleanName;
      intention = selectedIntention;
      language = selectedLanguage;
    });
    await _saveProgress();
    unawaited(
      MysticBusinessMetrics.record(
        MysticBusinessEvent.onboardingCompleted,
        dimensions: <String, String>{
          'language': selectedLanguage.code,
          'source': 'onboarding',
        },
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startReading(ReadingKind.daily);
    });
  }''',
    'onboarding business event',
  );
  appSource = _insertAfterRequired(
    appSource,
    '      _scheduleNextMirrorDue(mirrorReflections, now);\n',
    '''      unawaited(
        MysticMirrorGrowthTracker.instance.sync(
          records: journalLoad.records,
          reflections: mirrorReflections,
          languageCode: savedLanguage.code,
          now: now,
        ),
      );
''',
    'initial mature Mirror cohort sync',
  );
  appSource = _insertBeforeRequired(
    appSource,
    '''          const SizedBox(height: 18),
          ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SoulProfileScreen(''',
    '''          if (mysticGrowthDiagnosticsEnabled) ...[
            const SizedBox(height: 8),
            ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MysticGrowthEvidenceScreen(
                    language: language,
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(
                Icons.monitor_heart_outlined,
                color: MysticColors.gold,
              ),
              title: Text(
                localized(
                  language.appLanguage,
                  english: 'Growth evidence',
                  turkish: 'Büyüme kanıtı',
                  spanish: 'Evidencia de crecimiento',
                  french: 'Preuves de croissance',
                  portugueseBrazil: 'Evidência de crescimento',
                ),
                style: const TextStyle(fontFamily: 'Arial'),
              ),
              subtitle: Text(
                localized(
                  language.appLanguage,
                  english: 'Aggregate-only beta diagnostics. No private tarot content.',
                  turkish: 'Yalnızca toplu beta tanılama verisi. Özel tarot içeriği yok.',
                  spanish: 'Diagnóstico beta agregado. Sin contenido privado de tarot.',
                  french: 'Diagnostic bêta agrégé. Aucun contenu tarot privé.',
                  portugueseBrazil: 'Diagnóstico beta agregado. Sem conteúdo privado de tarot.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
''',
    'growth evidence profile entry',
  );
  _rejectLegacyUserCopy(appSource, 'lib/src/app.dart');
  if (!appSource.contains('MysticGrowthEvidenceScreen(') ||
      !appSource.contains('MysticMirrorGrowthTracker.instance.sync(')) {
    throw StateError('Growth evidence runtime wiring was not materialized.');
  }
  app.writeAsStringSync(appSource);

  var intelligenceSource = intelligence.readAsStringSync();
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    '''        const Spacer(),
        const Text(
          'MYSTIC INTELLIGENCE',
          style: TextStyle(
            color: MysticColors.gold,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const Spacer(),''',
    '''        const Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'MYSTIC INTELLIGENCE',
              style: TextStyle(
                color: MysticColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),''',
    'responsive Intelligence header',
  );
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    'Preview the intelligence layer that connects premium spreads across time.',
    'Explore the intelligence layer that connects deep spreads across time.',
    'English Intelligence paid-tier copy',
  );
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    'Previsualiza la capa de inteligencia que conecta las tiradas premium con el tiempo.',
    'Explora la capa de inteligencia que conecta las tiradas profundas con el tiempo.',
    'Spanish Intelligence paid-tier copy',
  );
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    'Découvrez la couche d’intelligence qui relie les tirages premium dans le temps.',
    'Découvrez la couche d’intelligence qui relie les tirages approfondis dans le temps.',
    'French Intelligence paid-tier copy',
  );
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    'Veja a camada de inteligência que conecta tiragens premium ao longo do tempo.',
    'Veja a camada de inteligência que conecta tiragens profundas ao longo do tempo.',
    'Portuguese Intelligence paid-tier copy',
  );
  intelligenceSource = _replaceRequired(
    intelligenceSource,
    'Premium açılımları zaman içinde birbirine bağlayan intelligence katmanını önizle.',
    'Derin açılımları zaman içinde birbirine bağlayan intelligence katmanını keşfet.',
    'Turkish Intelligence paid-tier copy',
  );
  _rejectLegacyUserCopy(
    intelligenceSource,
    'lib/src/mystic_plus_intelligence_screen.dart',
  );
  intelligence.writeAsStringSync(intelligenceSource);

  var journalSource = journal.readAsStringSync();
  journalSource = _insertAfterRequired(
    journalSource,
    "import 'mystic_mirror.dart';\n",
    "import 'mystic_reality_evidence.dart';\n",
    'Reality Evidence journal import',
  );
  journalSource = _insertAfterRequired(
    journalSource,
    '                    subject: mysticMirrorShareSubject(widget.language),\n',
    '                    sharePositionOrigin: _mirrorShareOrigin(),\n',
    'iPad-safe Mirror share origin parameter',
  );
  journalSource = _replaceRequired(
    journalSource,
    '''                                await MysticBusinessMetrics.record(
                                  MysticBusinessEvent.mirrorCompleted,
                                  dimensions: {
                                    'language': widget.language.code,
                                    'source': 'living_journal',
                                  },
                                );''',
    '''                                final completionDelay = reflection.completedAt
                                    .toLocal()
                                    .difference(record.createdAt);
                                final growthStage =
                                    completionDelay <= const Duration(hours: 72)
                                    ? 'within_72h'
                                    : 'after_72h';
                                await MysticBusinessMetrics.record(
                                  MysticBusinessEvent.mirrorCompleted,
                                  dimensions: {
                                    'language': widget.language.code,
                                    'growth_stage': growthStage,
                                    'source': 'living_journal',
                                  },
                                );''',
    'Mirror 72-hour completion stage',
  );
  journalSource = _replaceRequired(
    journalSource,
    '''    final completedMirrors = mirrors.values.toList();
    final movementCount = completedMirrors.where((mirror) {
      return mirror.outcome == MysticMirrorOutcome.shifted ||
          mirror.outcome == MysticMirrorOutcome.partlyShifted;
    }).length;
    final movementRate = completedMirrors.isEmpty
        ? 0
        : ((movementCount / completedMirrors.length) * 100).round();
    final transitionCounts = <String, int>{};
    for (final record in widget.records) {
      final mirror = mirrors[mysticMirrorRecordId(record)];
      if (mirror == null) continue;
      final transition =
          '\${localizedEmotionLabel(record.emotion, languageCode: _languageCode)} → \${localizedEmotionLabel(mirror.emotion, languageCode: _languageCode)}';
      transitionCounts.update(
        transition,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    final rankedTransitions = transitionCounts.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));''',
    '''    final realityEvidence = MysticRealityEvidence.analyze(
      readings: widget.records,
      reflections: mirrors,
      generatedAt: DateTime.now(),
    );
    final evidenceCoverage = realityEvidence.eligibleReadingCount == 0
        ? '—'
        : '\${(realityEvidence.completionRate * 100).round()}%';
    final rankedOutcomes = realityEvidence.hasEnoughEvidence
        ? realityEvidence.rankedOutcomes
        : const <OutcomeEvidence>[];
    final rankedTransitions = realityEvidence.hasEnoughEvidence
        ? realityEvidence.rankedEmotionTransitions
        : const <EmotionTransitionEvidence>[];''',
    'prediction-like movement metric replacement',
  );
  journalSource = _replaceRequired(
    journalSource,
    '''                completedMirrors.length.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetric(
                _mirrorCopy(
                  en: 'Movement noticed',
                  tr: 'Hareket fark edildi',
                  es: 'Cambio observado',
                  fr: 'Mouvement observé',
                  pt: 'Mudança percebida',
                ),
                completedMirrors.isEmpty ? '—' : '\$movementRate%',
              ),''',
    '''                realityEvidence.completedMirrorCount.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetric(
                _mirrorCopy(
                  en: 'Evidence captured',
                  tr: 'Kaydedilen kanıt',
                  es: 'Evidencia registrada',
                  fr: 'Preuves consignées',
                  pt: 'Evidência registrada',
                ),
                evidenceCoverage,
              ),''',
    'Reality Evidence coverage metric',
  );
  journalSource = _replaceRequired(
    journalSource,
    '''        _buildPatternCard(
          title: _mirrorCopy(
            en: 'How your emotional state shifted',
            tr: 'Duygun nasıl değişti',
            es: 'Cómo cambió tu estado emocional',
            fr: 'Comment votre état émotionnel a évolué',
            pt: 'Como seu estado emocional mudou',
          ),
          rows: rankedTransitions
              .take(4)
              .map((entry) => _InsightRow(entry.key, '\${entry.value}×'))
              .toList(),
        ),''',
    '''        _buildPatternCard(
          title: _mirrorCopy(
            en: 'Reality outcomes · not a prediction score',
            tr: 'Gerçeklik sonuçları · kehanet puanı değil',
            es: 'Resultados reales · no es una puntuación predictiva',
            fr: 'Résultats réels · pas un score de prédiction',
            pt: 'Resultados reais · não é pontuação de previsão',
          ),
          rows: rankedOutcomes
              .take(4)
              .map(
                (entry) => _InsightRow(
                  _outcomeLabel(entry.outcome),
                  '\${entry.count}×',
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        _buildPatternCard(
          title: _mirrorCopy(
            en: 'How your emotional state changed',
            tr: 'Duygusal durumun nasıl değişti',
            es: 'Cómo cambió tu estado emocional',
            fr: 'Comment votre état émotionnel a évolué',
            pt: 'Como seu estado emocional mudou',
          ),
          rows: rankedTransitions
              .take(4)
              .map(
                (entry) => _InsightRow(
                  '\${localizedEmotionLabel(entry.transition.from, languageCode: _languageCode)} → \${localizedEmotionLabel(entry.transition.to, languageCode: _languageCode)}',
                  '\${entry.count}×',
                ),
              )
              .toList(),
        ),''',
    'Reality Evidence outcome and emotion cards',
  );
  journalSource = _insertBeforeRequired(
    journalSource,
    '  Widget _buildDueMirrorAction(ReadingRecord record) {\n',
    '''  Rect _mirrorShareOrigin() {
    final renderObject = context.findRenderObject();
    return renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : const Rect.fromLTWH(0, 0, 1, 1);
  }

''',
    'iPad-safe Mirror share origin helper',
  );
  if (!journalSource.contains('sharePositionOrigin: _mirrorShareOrigin(),')) {
    throw StateError('Mirror share origin was not materialized.');
  }
  if (!journalSource.contains("'growth_stage': growthStage")) {
    throw StateError('Mirror 72-hour growth stage was not materialized.');
  }
  if (!journalSource.contains('MysticRealityEvidence.analyze(') ||
      journalSource.contains('Movement noticed') ||
      journalSource.contains('movementRate')) {
    throw StateError(
      'Reality Evidence journal insights were not materialized.',
    );
  }
  journal.writeAsStringSync(journalSource);

  stdout.writeln(
    'Advertising-only UI materialized: paid-tier user copy removed, '
    'growth events, mature Mirror cohort evidence, transparent Reality Evidence '
    'and opt-in diagnostics installed; narrow-screen and iPad share hardening '
    'retained.',
  );
}

String _replaceRequired(
  String source,
  String oldValue,
  String newValue,
  String label,
) {
  if (source.contains(oldValue)) {
    return source.replaceAll(oldValue, newValue);
  }
  if (source.contains(newValue)) return source;
  throw StateError(
    'Unable to materialize $label: expected source anchor missing.',
  );
}

String _insertAfterRequired(
  String source,
  String anchor,
  String addition,
  String label,
) {
  final materialized = '$anchor$addition';
  if (source.contains(materialized)) return source;
  final count = anchor.allMatches(source).length;
  if (count != 1) {
    throw StateError(
      'Unable to materialize $label: expected exactly one source anchor, '
      'found $count.',
    );
  }
  return source.replaceFirst(anchor, materialized);
}

String _insertBeforeRequired(
  String source,
  String anchor,
  String addition,
  String label,
) {
  final materialized = '$addition$anchor';
  if (source.contains(materialized)) return source;
  final count = anchor.allMatches(source).length;
  if (count != 1) {
    throw StateError(
      'Unable to materialize $label: expected exactly one source anchor, '
      'found $count.',
    );
  }
  return source.replaceFirst(anchor, materialized);
}

void _rejectLegacyUserCopy(String source, String path) {
  const forbidden = <String>[
    "'PLUS'",
    'PLUS ACTIVE',
    'PLUS ETKİN',
    'VIEW PLUS',
    'PLUS’I GÖR',
    'premium spread',
    'premium açılım',
    'tiradas premium',
    'tirages premium',
    'tiragens premium',
    'Mystic Plus',
    'Manage subscription',
    'View plan and manage subscription',
  ];
  for (final token in forbidden) {
    if (source.toLowerCase().contains(token.toLowerCase())) {
      throw StateError('Legacy paid-tier user copy remains in $path: $token');
    }
  }
}
