import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';
import 'flagship.dart';
import 'identity_engine.dart';
import 'language_bridge.dart';
import 'models.dart';
import 'reading_journal_store.dart';
import 'premium_value_screen.dart';
import 'mystic_identity_screen.dart';
import 'mystic_journey_feature.dart';
import 'mystic_living_journal_feature.dart';
import 'sound.dart';
import 'store_purchase_service.dart';
import 'store_ready_premium_screen.dart';
import 'tarot_data.dart';
import 'tarot_localization.dart';
import 'theme.dart';
import 'widgets.dart';

const launchLanguages = <MysticLanguage>[
  MysticLanguage.english,
  MysticLanguage.turkish,
  MysticLanguage.spanish,
  MysticLanguage.french,
  MysticLanguage.portugueseBrazil,
];

String supportPageForLanguage(MysticLanguage language) => switch (language) {
      MysticLanguage.french =>
        'https://tuna777123.github.io/mystic-tarot/support-fr.html',
      MysticLanguage.turkish =>
        'https://tuna777123.github.io/mystic-tarot/support-tr.html',
      MysticLanguage.spanish =>
        'https://tuna777123.github.io/mystic-tarot/support-es.html',
      MysticLanguage.portugueseBrazil =>
        'https://tuna777123.github.io/mystic-tarot/support-pt-br.html',
      _ => 'https://tuna777123.github.io/mystic-tarot/support.html',
    };

class MysticApp extends StatefulWidget {
  const MysticApp({super.key});

  @override
  State<MysticApp> createState() => _MysticAppState();
}

class _MysticAppState extends State<MysticApp> with WidgetsBindingObserver {
  static const freeDeepReadingLimit = 3;
  final navigatorKey = GlobalKey<NavigatorState>();
  final subscriptionStore = StorePurchaseService();
  final readingJournalStore = ReadingJournalStore();
  bool isPlus = false;
  bool ready = false;
  bool onboarded = false;
  int tab = 0;
  int streak = 0;
  int xp = 0;
  int deepReadingsToday = 0;
  MysticLanguage language = MysticLanguage.english;
  DeckStyle deckStyle = DeckStyle.midnight;
  String userName = '';
  String intention = 'Clarity';
  String? lastActiveDay;
  String? dailyQuestClaimedDay;
  String? deepReadingsDay;
  final List<ReadingRecord> journal = [];
  final Set<String> discoveredCards = {};
  final Set<String> completedRituals = {};
  final Set<int> claimedRewards = {};
  final Set<int> completedArcanaDays = {};
  final Map<int, String> arcanaReflections = {};
  String? lastArcanaCompletionDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    subscriptionStore.addListener(_syncSubscription);
    subscriptionStore.initialize();
    MysticSoundscape.instance.load();
    _loadProgress();
  }

  void _syncSubscription() {
    if (!mounted || isPlus == subscriptionStore.isPlus) return;
    setState(() => isPlus = subscriptionStore.isPlus);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      subscriptionStore.refreshEntitlement();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    subscriptionStore.removeListener(_syncSubscription);
    subscriptionStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mystic Tarot',
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    theme: buildMysticTheme(),
    builder: (context, child) {
      final width = MediaQuery.sizeOf(context).width;
      final desktop = width > 620;
      return ColoredBox(
        color: const Color(0xFF080711),
        child: Center(
          child: Container(
            width: min(width, 520),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: desktop
                  ? BorderRadius.circular(28)
                  : BorderRadius.zero,
              border: desktop
                  ? Border.all(
                      color: MysticColors.lavender.withValues(alpha: .16),
                    )
                  : null,
              boxShadow: desktop
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .72),
                        blurRadius: 70,
                        spreadRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        ),
      );
    },
    home: !ready
        ? const _MysticLoadingScreen()
        : onboarded
        ? _shell()
        : OnboardingScreen(onDone: _finishOnboarding),
  );

  Widget _shell() => Scaffold(
    body: IndexedStack(
      index: tab,
      children: [
        HomeScreen(
          isPlus: isPlus,
          userName: userName,
          intention: intention,
          records: journal,
          language: language,
          completedArcanaDays: completedArcanaDays,
          streak: streak,
          xp: xp,
          dailyReadingDone: journal.any(
            (record) =>
                record.kind == ReadingKind.daily &&
                _dayKey(record.createdAt) == _dayKey(DateTime.now()),
          ),
          ritualDone: completedRituals.isNotEmpty,
          dailyQuestClaimed: dailyQuestClaimedDay == _dayKey(DateTime.now()),
          deckStyle: deckStyle,
          freeReadingsLeft: isPlus
              ? -1
              : max(0, freeDeepReadingLimit - deepReadingsToday),
          onReading: _startReading,
          onClaimDailyQuest: _claimDailyQuest,
          onPremiumSpread: isPlus ? _startReading : _previewPremiumReading,
          onPremium: _showPremium,
          onOpenDestiny: _openDestinyHub,
        ),
        MysticJourneysFeature(
          language: language,
          onOpenDestiny: _openDestinyHub,
          onStartReading: () {
            setState(() => tab = 0);
            _startReading(ReadingKind.daily);
          },
        ),
        MysticLivingJournalFeature(
          records: journal,
          language: language,
          onStartReading: () {
            setState(() => tab = 0);
            _startReading(ReadingKind.daily);
          },
          onPremium: () => _showPremium(source: 'living_journal'),
        ),
        ProfileScreen(
          isPlus: isPlus,
          userName: userName,
          intention: intention,
          streak: streak,
          xp: xp,
          readings: journal.length,
          discovered: discoveredCards.length,
          relics: claimedRewards.length,
          records: journal,
          completedArcanaDays: completedArcanaDays.length,
          deckStyle: deckStyle,
          language: language,
          onSelectLanguage: _selectLanguage,
          onSelectDeckStyle: _selectDeckStyle,
          onUpdateProfile: _updateProfile,
          onDeleteData: _deleteAllData,
          onPremium: _showPremium,
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (value) => setState(() => tab = value),
      backgroundColor: const Color(0xFF100D1E),
      indicatorColor: MysticColors.violet.withValues(alpha: .45),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.auto_awesome_outlined),
          selectedIcon: const Icon(Icons.auto_awesome),
          label: mysticText(language, 'Read', 'Oku'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.hub_outlined),
          selectedIcon: const Icon(Icons.hub),
          label: mysticText(language, 'Path', 'Yol'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: const Icon(Icons.menu_book),
          label: mysticText(language, 'Journal', 'Günlük'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: mysticText(language, 'You', 'Sen'),
        ),
      ],
    ),
  );

  void _startReading(ReadingKind kind) {
    if (!isPlus && _premiumReadingKinds.contains(kind)) {
      _showPremium(source: 'premium_spread');
      return;
    }
    if (!isPlus &&
        kind != ReadingKind.daily &&
        deepReadingsToday >= freeDeepReadingLimit) {
      _showPremium(source: 'daily_limit');
      return;
    }
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => ReadingFlow(
          kind: kind,
          deckStyle: deckStyle,
          userName: userName,
          intention: intention,
          language: language,
          isPlus: isPlus,
          pastRecords: journal,
          onPremium: () => _showPremium(source: 'oracle_dialogue'),
          onComplete: (record) {
            final newlyDiscovered = record.cards
                .map((item) => item.card)
                .where((card) => !discoveredCards.contains(card.name))
                .toList();
            setState(() {
              journal.insert(0, record);
              discoveredCards.addAll(
                record.cards.map((item) => item.card.name),
              );
              xp += 25;
              if (record.kind != ReadingKind.daily) {
                deepReadingsToday++;
                deepReadingsDay = _dayKey(DateTime.now());
              }
              _updateStreak();
            });
            _saveProgress();
            if (newlyDiscovered.isNotEmpty) {
              Future<void>.delayed(
                const Duration(milliseconds: 280),
                () => _showCardDiscovery(newlyDiscovered),
              );
            }
          },
        ),
      ),
    );
  }

  void _showCardDiscovery(List<TarotCardData> cards) {
    final context = navigatorKey.currentContext;
    if (context == null || !mounted) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: mysticText(language, 'Close discovery', 'Keşfi kapat'),
      barrierColor: Colors.black.withValues(alpha: .82),
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        ),
      ),
      pageBuilder: (_, __, ___) =>
          _CardDiscoveryDialog(cards: cards, language: language),
    );
  }

  void _claimDailyQuest() {
    final today = _dayKey(DateTime.now());
    final readToday = journal.any(
      (record) =>
          record.kind == ReadingKind.daily &&
          _dayKey(record.createdAt) == today,
    );
    if (!readToday || completedRituals.isEmpty || dailyQuestClaimedDay == today)
      return;
    setState(() {
      dailyQuestClaimedDay = today;
      xp += 40;
    });
    _saveProgress();
  }

  void _selectDeckStyle(DeckStyle style) {
    setState(() => deckStyle = style);
    _saveProgress();
  }

  void _selectLanguage(MysticLanguage value) {
    setState(() => language = value);
    _saveProgress();
  }

  void _openDestinyHub() {
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => DestinyHubScreen(
          records: journal,
          completedDays: completedArcanaDays,
          reflections: arcanaReflections,
          lastCompletionDay: lastArcanaCompletionDay,
          language: language,
          onCompleteChapter: _completeArcanaChapter,
          onStartReading: () {
            navigatorKey.currentState!.pop();
            setState(() => tab = 0);
            _startReading(ReadingKind.daily);
          },
        ),
      ),
    );
  }

  void _completeArcanaChapter(int index, String reflection) {
    if (completedArcanaDays.contains(index) ||
        lastArcanaCompletionDay == _dayKey(DateTime.now()))
      return;
    setState(() {
      completedArcanaDays.add(index);
      arcanaReflections[index] = reflection;
      lastArcanaCompletionDay = _dayKey(DateTime.now());
      discoveredCards.add(tarotDeck[index].name);
      xp += 50;
    });
    _saveProgress();
  }

  void _updateProfile(String name, String selectedIntention) {
    final cleanName = name.trim();
    setState(() {
      userName = cleanName.length > 18 ? cleanName.substring(0, 18) : cleanName;
      intention = selectedIntention;
    });
    _saveProgress();
  }

  Future<void> _deleteAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    setState(() {
      onboarded = false;
      tab = 0;
      streak = 0;
      xp = 0;
      deepReadingsToday = 0;
      deckStyle = DeckStyle.midnight;
      userName = '';
      intention = 'Clarity';
      lastActiveDay = null;
      dailyQuestClaimedDay = null;
      deepReadingsDay = null;
      journal.clear();
      discoveredCards.clear();
      completedRituals.clear();
      claimedRewards.clear();
      completedArcanaDays.clear();
      arcanaReflections.clear();
      lastArcanaCompletionDay = null;
      language = MysticLanguage.english;
    });
  }

  Future<void> _finishOnboarding(
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
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final journalLoad = await readingJournalStore.load(
        legacyRecords:
            prefs.getStringList(ReadingJournalStore.legacyKey) ?? const <String>[],
      );
      final today = _dayKey(DateTime.now());
      final ritualDay = prefs.getString('ritual_day');
      final savedReadingDay = prefs.getString('deep_readings_day');
      if (!mounted) return;
      setState(() {
        onboarded = prefs.getBool('onboarded') ?? false;
        userName = prefs.getString('user_name') ?? '';
        intention = prefs.getString('intention') ?? 'Clarity';
        xp = prefs.getInt('xp') ?? 0;
        streak = prefs.getInt('streak') ?? 0;
        lastActiveDay = prefs.getString('last_active_day');
        dailyQuestClaimedDay = prefs.getString('daily_quest_claimed_day');
        deepReadingsDay = savedReadingDay;
        deepReadingsToday = savedReadingDay == today
            ? prefs.getInt('deep_readings_today') ?? 0
            : 0;
        deckStyle = _deckStyleFromName(prefs.getString('deck_style'));
        language = _languageFromName(prefs.getString('language'));
        discoveredCards.addAll(
          prefs.getStringList('discovered_cards') ?? const [],
        );
        claimedRewards.addAll(
          (prefs.getStringList('claimed_rewards') ?? const [])
              .map(int.tryParse)
              .whereType<int>(),
        );
        completedArcanaDays.addAll(
          (prefs.getStringList('completed_arcana_days') ?? const [])
              .map(int.tryParse)
              .whereType<int>(),
        );
        lastArcanaCompletionDay = prefs.getString('last_arcana_completion_day');
        for (final encoded
            in prefs.getStringList('arcana_reflections') ?? const []) {
          final separator = encoded.indexOf(':');
          if (separator > 0) {
            final index = int.tryParse(encoded.substring(0, separator));
            if (index != null) {
              arcanaReflections[index] = encoded.substring(separator + 1);
            }
          }
        }
        journal.addAll(journalLoad.records);
        if (ritualDay == today)
          completedRituals.addAll(
            prefs.getStringList('completed_rituals') ?? const [],
          );
        ready = true;
      });
      if (journalLoad.migratedFromLegacy) {
        await readingJournalStore.save(journalLoad.records);
        await readingJournalStore.finishLegacyMigration();
      }
    } catch (_) {
      if (mounted) setState(() => ready = true);
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool('onboarded', onboarded),
        prefs.setString('user_name', userName),
        prefs.setString('intention', intention),
        prefs.setInt('xp', xp),
        prefs.setInt('streak', streak),
        prefs.setInt('deep_readings_today', deepReadingsToday),
        prefs.setStringList('discovered_cards', discoveredCards.toList()),
        prefs.setStringList('completed_rituals', completedRituals.toList()),
        prefs.setStringList(
          'claimed_rewards',
          claimedRewards.map((item) => '$item').toList(),
        ),
        prefs.setStringList(
          'completed_arcana_days',
          completedArcanaDays.map((item) => '$item').toList(),
        ),
        prefs.setStringList(
          'arcana_reflections',
          arcanaReflections.entries
              .map((entry) => '${entry.key}:${entry.value}')
              .toList(),
        ),
        prefs.setString('ritual_day', _dayKey(DateTime.now())),
        prefs.setString(
          'deep_readings_day',
          deepReadingsDay ?? _dayKey(DateTime.now()),
        ),
        prefs.setString('deck_style', deckStyle.name),
        prefs.setString('language', language.name),
        if (lastArcanaCompletionDay != null)
          prefs.setString(
            'last_arcana_completion_day',
            lastArcanaCompletionDay!,
          ),
        if (dailyQuestClaimedDay != null)
          prefs.setString('daily_quest_claimed_day', dailyQuestClaimedDay!),
        if (lastActiveDay != null)
          prefs.setString('last_active_day', lastActiveDay!),
      ]);
      await readingJournalStore.save(journal);
    } catch (_) {
      // The experience remains usable if local storage is temporarily unavailable.
    }
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = _dayKey(now);
    if (lastActiveDay == today) return;
    final yesterday = _dayKey(now.subtract(const Duration(days: 1)));
    streak = lastActiveDay == yesterday ? streak + 1 : 1;
    lastActiveDay = today;
  }

  String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DeckStyle _deckStyleFromName(String? name) {
    for (final style in DeckStyle.values) {
      if (style.name == name) return style;
    }
    return DeckStyle.midnight;
  }

  MysticLanguage _languageFromName(String? name) {
    for (final item in MysticLanguage.values) {
      if (item.name == name) return item;
    }
    return MysticLanguage.english;
  }

  void _showPremium({String source = 'organic'}) {
    final storeScreen = StoreReadyPremiumScreen(
      source: source,
      language: language,
      subscriptionStore: subscriptionStore,
    );
    if (isPlus) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => storeScreen),
      );
      return;
    }
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => PremiumValueScreen(
          source: source,
          language: language,
          onContinue: () => navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (_) => storeScreen),
          ),
        ),
      ),
    );
  }

  void _previewPremiumReading(ReadingKind kind) =>
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => PremiumReadingPreview(
            kind: kind,
            deckStyle: deckStyle,
            language: language,
            onUnlock: () => _showPremium(source: 'premium_spread'),
          ),
        ),
      );
}

class _MysticLoadingScreen extends StatelessWidget {
  const _MysticLoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: MysticBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('☾', style: TextStyle(fontSize: 68, color: MysticColors.gold)),
            SizedBox(height: 18),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: MysticColors.gold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CardDiscoveryDialog extends StatefulWidget {
  const _CardDiscoveryDialog({required this.cards, required this.language});
  final List<TarotCardData> cards;
  final MysticLanguage language;

  @override
  State<_CardDiscoveryDialog> createState() => _CardDiscoveryDialogState();
}

class _CardDiscoveryDialogState extends State<_CardDiscoveryDialog>
    with SingleTickerProviderStateMixin {
  int index = 0;
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.cards[index];
    final color = _cardRarityColor(card);
    final hasNext = index < widget.cards.length - 1;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 330,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment(0, -.3),
              radius: 1.2,
              colors: [Color(0xFF5B3D7D), Color(0xFF17101F)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withValues(alpha: .7)),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: .28), blurRadius: 55),
            ],
          ),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      '${index + 1}/${widget.cards.length}',
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: MysticColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: MysticColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  mysticText(
                    widget.language,
                    '✦  NEW ARCANA AWAKENED',
                    '✦  YENİ ARKANA UYANDI',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: MysticColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.25,
                  ),
                ),
                const SizedBox(height: 18),
                Transform.scale(
                  scale:
                      .72 + Curves.elasticOut.transform(controller.value) * .28,
                  child: Transform.rotate(
                    angle:
                        sin(controller.value * pi * 3) *
                        (1 - controller.value) *
                        .06,
                    child: Container(
                      width: 132,
                      height: 198,
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withValues(alpha: .45),
                            const Color(0xFF17101F),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: .32),
                            blurRadius: 35,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: color.withValues(alpha: .45),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              card.number,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 23),
                            Text(
                              card.symbol,
                              style: TextStyle(fontSize: 50, color: color),
                            ),
                            const SizedBox(height: 23),
                            Text(
                              _cardName(card.name),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                Text(
                  _localizedRarity(card).toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _cardName(card.name),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _localizedCardMeaning(
                    DrawnCard(card, false),
                    widget.language,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: MysticColors.mist),
                ),
                const SizedBox(height: 20),
                GoldButton(
                  label: hasNext
                      ? mysticText(
                          widget.language,
                          'Reveal next card',
                          'Sonraki kartı aç',
                        )
                      : mysticText(
                          widget.language,
                          'Add to Arcana Vault',
                          'Arkana Kasası’na ekle',
                        ),
                  onPressed: () {
                    if (hasNext) {
                      setState(() => index++);
                      controller.forward(from: 0);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: hasNext ? Icons.auto_awesome : Icons.check,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _localizedRarity(TarotCardData card) => switch (_cardRarity(card)) {
    'Legendary' => mysticText(widget.language, 'Legendary', 'Efsanevi'),
    'Epic' => mysticText(widget.language, 'Epic', 'Destansı'),
    'Rare' => mysticText(widget.language, 'Rare', 'Nadir'),
    _ => mysticText(widget.language, 'Common', 'Yaygın'),
  };

  String _cardName(String name) => localizedTarotCardName(
    name,
    languageCode: widget.language.code,
  );
}

String _cardRarity(TarotCardData card) {
  final index = tarotDeck.indexOf(card);
  if (index < 22) return 'Legendary';
  if (card.name.startsWith('Page') ||
      card.name.startsWith('Knight') ||
      card.name.startsWith('Queen') ||
      card.name.startsWith('King'))
    return 'Epic';
  if (card.name.startsWith('Ace')) return 'Rare';
  return 'Common';
}

Color _cardRarityColor(TarotCardData card) {
  switch (_cardRarity(card)) {
    case 'Legendary':
      return MysticColors.gold;
    case 'Epic':
      return const Color(0xFFC48DFF);
    case 'Rare':
      return const Color(0xFF72D6E8);
    default:
      return const Color(0xFFB8B4C7);
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onDone, super.key});
  final void Function(String name, String intention, MysticLanguage language)
  onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int page = 0;
  final name = TextEditingController();
  String intention = 'Clarity';
  MysticLanguage language = MysticLanguage.english;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: MysticBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          children: [
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: i <= page ? MysticColors.gold : Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: SingleChildScrollView(
                    key: ValueKey(page),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: _page(context),
                    ),
                  ),
                ),
              ),
            ),
            GoldButton(
              label: page == 0
                  ? _copy(
                      en: 'Begin my journey',
                      es: 'Comenzar mi viaje',
                      fr: 'Commencer mon voyage',
                      pt: 'Começar minha jornada',
                      tr: 'Yolculuğuma başla',
                      it: 'Inizia il mio viaggio',
                      de: 'Meine Reise beginnen',
                    )
                  : page == 1
                  ? _copy(
                      en: 'Set my intention',
                      es: 'Definir mi intención',
                      fr: 'Définir mon intention',
                      pt: 'Definir minha intenção',
                      tr: 'Niyetimi belirle',
                      it: 'Imposta la mia intenzione',
                      de: 'Meine Absicht festlegen',
                    )
                  : _copy(
                      en: 'Enter Mystic',
                      es: 'Entrar en Mystic',
                      fr: 'Entrer dans Mystic',
                      pt: 'Entrar no Mystic',
                      tr: 'Mystic’e gir',
                      it: 'Entra in Mystic',
                      de: 'Mystic betreten',
                    ),
              icon: page == 2 ? Icons.auto_awesome : Icons.arrow_forward,
              onPressed: page == 1 && name.text.trim().isEmpty
                  ? null
                  : () => page < 2
                        ? setState(() => page++)
                        : widget.onDone(name.text.trim(), intention, language),
            ),
          ],
        ),
      ),
    ),
  );

  String _copy({
    required String en,
    required String es,
    required String fr,
    required String pt,
    required String tr,
    required String it,
    required String de,
  }) => localized(
    language.appLanguage,
    english: en,
    spanish: es,
    french: fr,
    portugueseBrazil: pt,
    turkish: tr,
    italian: it,
    german: de,
  );

  String _intentionLabel(String value) => switch (value) {
    'Clarity' => _copy(
      en: 'Clarity',
      es: 'Claridad',
      fr: 'Clarté',
      pt: 'Clareza',
      tr: 'Netlik',
      it: 'Chiarezza',
      de: 'Klarheit',
    ),
    'Love' => _copy(
      en: 'Love',
      es: 'Amor',
      fr: 'Amour',
      pt: 'Amor',
      tr: 'Aşk',
      it: 'Amore',
      de: 'Liebe',
    ),
    'Purpose' => _copy(
      en: 'Purpose',
      es: 'Propósito',
      fr: 'Mission',
      pt: 'Propósito',
      tr: 'Amaç',
      it: 'Scopo',
      de: 'Bestimmung',
    ),
    'Healing' => _copy(
      en: 'Healing',
      es: 'Sanación',
      fr: 'Guérison',
      pt: 'Cura',
      tr: 'İyileşme',
      it: 'Guarigione',
      de: 'Heilung',
    ),
    _ => value,
  };

  Widget _page(BuildContext context) {
    if (page == 0) {
      return Column(
        key: const ValueKey(0),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'MYSTIC TAROT',
            style: TextStyle(
              fontFamily: 'Arial',
              color: MysticColors.gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.2,
            ),
          ),
          const SizedBox(height: 22),
          const _OnboardingPortal(),
          const SizedBox(height: 25),
          Text(
            _copy(
              en: 'Your patterns are\nalready speaking.',
              es: 'Tus patrones ya\nestán hablando.',
              fr: 'Vos schémas parlent\ndéjà.',
              pt: 'Seus padrões já\nestão falando.',
              tr: 'Örüntülerin\nçoktan konuşuyor.',
              it: 'I tuoi schemi stanno\ngià parlando.',
              de: 'Deine Muster\nsprechen bereits.',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 14),
          Text(
            _copy(
              en: 'Reveal the cards. Track what returns. Turn insight into a private daily ritual that remembers you.',
              es: 'Revela las cartas. Observa lo que vuelve. Convierte la intuición en un ritual diario privado que te recuerda.',
              fr: 'Révélez les cartes. Observez ce qui revient. Transformez l’intuition en un rituel quotidien privé qui se souvient de vous.',
              pt: 'Revele as cartas. Observe o que retorna. Transforme a percepção em um ritual diário privado que se lembra de você.',
              tr: 'Kartları aç. Tekrar edenleri izle. İçgörüyü seni hatırlayan özel bir günlük ritüele dönüştür.',
              it: 'Rivela le carte. Osserva ciò che ritorna. Trasforma l’intuizione in un rituale quotidiano privato che si ricorda di te.',
              de: 'Enthülle die Karten. Beobachte, was wiederkehrt. Verwandle Erkenntnis in ein privates tägliches Ritual, das sich an dich erinnert.',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: [
              _OnboardingProof(
                icon: '✦',
                label: _copy(
                  en: '78 ARCANA',
                  es: '78 ARCANOS',
                  fr: '78 ARCANES',
                  pt: '78 ARCANOS',
                  tr: '78 ARKANA',
                  it: '78 ARCANI',
                  de: '78 ARKANA',
                ),
              ),
              _OnboardingProof(
                icon: '◉',
                label: _copy(
                  en: 'PATTERN MEMORY',
                  es: 'MEMORIA DE PATRONES',
                  fr: 'MÉMOIRE DES SCHÉMAS',
                  pt: 'MEMÓRIA DE PADRÕES',
                  tr: 'ÖRÜNTÜ HAFIZASI',
                  it: 'MEMORIA DEGLI SCHEMI',
                  de: 'MUSTERGEDÄCHTNIS',
                ),
              ),
              _OnboardingProof(
                icon: '☾',
                label: _copy(
                  en: 'PRIVATE JOURNAL',
                  es: 'DIARIO PRIVADO',
                  fr: 'JOURNAL PRIVÉ',
                  pt: 'DIÁRIO PRIVADO',
                  tr: 'ÖZEL GÜNLÜK',
                  it: 'DIARIO PRIVATO',
                  de: 'PRIVATES TAGEBUCH',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: launchLanguages
                .map(
                  (item) => ChoiceChip(
                    label: Text(item.label),
                    selected: language == item,
                    onSelected: (_) => setState(() => language = item),
                    selectedColor: MysticColors.violet,
                  ),
                )
                .toList(),
          ),
        ],
      );
    }
    if (page == 1) {
      return Column(
        key: const ValueKey(1),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _copy(
              en: 'What should we\ncall you?',
              es: '¿Cómo debemos\nllamarte?',
              fr: 'Comment devons-nous\nvous appeler ?',
              pt: 'Como devemos\nchamar você?',
              tr: 'Sana nasıl\nseslenelim?',
              it: 'Come dovremmo\nchiamarti?',
              de: 'Wie dürfen wir\ndich nennen?',
            ),
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Text(
            _copy(
              en: 'Your name helps each reading feel personal.',
              es: 'Tu nombre hace que cada lectura se sienta personal.',
              fr: 'Votre nom rend chaque tirage plus personnel.',
              pt: 'Seu nome torna cada leitura mais pessoal.',
              tr: 'Adın her okumayı sana özel hissettirir.',
              it: 'Il tuo nome rende ogni lettura più personale.',
              de: 'Dein Name lässt jede Lesung persönlicher wirken.',
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          TextField(
            controller: name,
            maxLength: 18,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: _copy(
                en: 'Your first name',
                es: 'Tu nombre',
                fr: 'Votre prénom',
                pt: 'Seu nome',
                tr: 'Adın',
                it: 'Il tuo nome',
                de: 'Dein Vorname',
              ),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
        ],
      );
    }
    const choices = ['Clarity', 'Love', 'Purpose', 'Healing'];
    return Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _copy(
            en: 'Set your first\nintention.',
            es: 'Define tu primera\nintención.',
            fr: 'Définissez votre première\nintention.',
            pt: 'Defina sua primeira\nintenção.',
            tr: 'İlk niyetini\nbelirle.',
            it: 'Imposta la tua prima\nintenzione.',
            de: 'Lege deine erste\nAbsicht fest.',
          ),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 16),
        Text(
          _copy(
            en: 'There is no wrong choice. This simply shapes your starting experience.',
            es: 'No hay una elección incorrecta. Esto solo da forma a tu experiencia inicial.',
            fr: 'Il n’y a pas de mauvais choix. Cela façonne simplement votre expérience de départ.',
            pt: 'Não existe escolha errada. Isso apenas molda sua experiência inicial.',
            tr: 'Yanlış seçim yok. Bu yalnızca başlangıç deneyimini şekillendirir.',
            it: 'Non esiste una scelta sbagliata. Questo modella semplicemente la tua esperienza iniziale.',
            de: 'Es gibt keine falsche Wahl. Sie gestaltet lediglich dein erstes Erlebnis.',
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 25),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: choices
              .map(
                (choice) => ChoiceChip(
                  label: Text(_intentionLabel(choice)),
                  selected: intention == choice,
                  onSelected: (_) => setState(() => intention = choice),
                  selectedColor: MysticColors.violet,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _OnboardingPortal extends StatefulWidget {
  const _OnboardingPortal();

  @override
  State<_OnboardingPortal> createState() => _OnboardingPortalState();
}

class _OnboardingPortalState extends State<_OnboardingPortal>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final pulse = .5 + sin(controller.value * pi * 2) * .5;
      return SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 142,
              height: 142,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MysticColors.violet.withValues(alpha: .34 + pulse * .08),
                    const Color(0xFF171027).withValues(alpha: .25),
                    Colors.transparent,
                  ],
                  stops: const [0, .58, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: MysticColors.violet.withValues(
                      alpha: .18 + pulse * .08,
                    ),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            Transform.rotate(
              angle: controller.value * pi * 2,
              child: Container(
                width: 126,
                height: 126,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: MysticColors.gold.withValues(alpha: .35),
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: -controller.value * pi * 1.4,
              child: const SizedBox(
                width: 105,
                height: 105,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        '✦',
                        style: TextStyle(
                          color: MysticColors.gold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        '✧',
                        style: TextStyle(
                          color: MysticColors.lavender,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '·',
                        style: TextStyle(
                          color: MysticColors.gold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '·',
                        style: TextStyle(
                          color: MysticColors.gold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 82,
              height: 82,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF4C3473), Color(0xFF191128)],
                ),
                border: Border.all(
                  color: MysticColors.gold.withValues(alpha: .52),
                ),
                boxShadow: [
                  BoxShadow(
                    color: MysticColors.gold.withValues(
                      alpha: .12 + pulse * .08,
                    ),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Text(
                '☾',
                style: TextStyle(fontSize: 42, color: MysticColors.gold),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _OnboardingProof extends StatelessWidget {
  const _OnboardingProof({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .045),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
    ),
    child: Text(
      '$icon  $label',
      style: const TextStyle(
        fontFamily: 'Arial',
        color: MysticColors.lavender,
        fontSize: 7.5,
        fontWeight: FontWeight.w900,
        letterSpacing: .55,
      ),
    ),
  );
}

const _standardReadingKinds = <ReadingKind>[
  ReadingKind.love,
  ReadingKind.career,
  ReadingKind.money,
  ReadingKind.decision,
  ReadingKind.spiritual,
  ReadingKind.shadow,
];

const _premiumReadingKinds = <ReadingKind>[
  ReadingKind.compatibility,
  ReadingKind.timeline,
  ReadingKind.celticCross,
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.isPlus,
    required this.userName,
    required this.intention,
    required this.records,
    required this.language,
    required this.completedArcanaDays,
    required this.streak,
    required this.xp,
    required this.dailyReadingDone,
    required this.ritualDone,
    required this.dailyQuestClaimed,
    required this.deckStyle,
    required this.freeReadingsLeft,
    required this.onReading,
    required this.onClaimDailyQuest,
    required this.onPremiumSpread,
    required this.onPremium,
    required this.onOpenDestiny,
    super.key,
  });
  final bool isPlus;
  final String userName;
  final String intention;
  final List<ReadingRecord> records;
  final MysticLanguage language;
  final Set<int> completedArcanaDays;
  final int streak;
  final int xp;
  final bool dailyReadingDone;
  final bool ritualDone;
  final bool dailyQuestClaimed;
  final DeckStyle deckStyle;
  final int freeReadingsLeft;
  final ValueChanged<ReadingKind> onReading;
  final VoidCallback onClaimDailyQuest;
  final ValueChanged<ReadingKind> onPremiumSpread;
  final VoidCallback onPremium;
  final VoidCallback onOpenDestiny;

  @override
  Widget build(BuildContext context) => MysticBackground(
    child: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName.isEmpty
                              ? mysticText(
                                  language,
                                  'Your cards are waiting',
                                  'Kartların seni bekliyor',
                                )
                              : mysticText(
                                  language,
                                  'Your cards are waiting, $userName',
                                  'Kartların seni bekliyor, $userName',
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: onPremium,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: MysticColors.gold.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: MysticColors.gold.withValues(alpha: .4),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            '✦ ',
                            style: TextStyle(color: MysticColors.gold),
                          ),
                          Text(
                            'PLUS',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w800,
                              color: MysticColors.gold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DailyCard(
                streak: streak,
                deckStyle: deckStyle,
                language: language,
                onTap: () => onReading(ReadingKind.daily),
              ),
              const SizedBox(height: 14),
              _DailyQuest(
                readingDone: dailyReadingDone,
                ritualDone: ritualDone,
                claimed: dailyQuestClaimed,
                language: language,
                onClaim: onClaimDailyQuest,
              ),
              const SizedBox(height: 12),
              _MoonBriefing(language: language),
              const SizedBox(height: 12),
              _ReadingAllowance(
                readingsLeft: freeReadingsLeft,
                language: language,
                onUpgrade: onPremium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mysticText(
                        language,
                        'Choose a reading',
                        'Bir okuma seç',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$xp XP',
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: MysticColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 126,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, index) => _featuredReadingCard(
                      context,
                      const [
                        ReadingKind.love,
                        ReadingKind.career,
                        ReadingKind.decision,
                      ][index],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _showAllReadings(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .09),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.grid_view_rounded,
                          size: 18,
                          color: MysticColors.lavender,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            mysticText(
                              language,
                              'Explore every reading',
                              'Tüm okumaları keşfet',
                            ),
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: MysticColors.gold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mysticText(
                          language,
                          'Mystic Plus readings',
                          'Mystic Plus okumaları',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
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
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  mysticText(
                    language,
                    'High-depth spreads built for the questions people return to most.',
                    'En çok geri dönülen sorular için tasarlanmış derin açılımlar.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 166,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _premiumReadingKinds.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, index) => _premiumReadingCard(
                      context,
                      _premiumReadingKinds[index],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  mysticText(
                    language,
                    'Your path remembers',
                    'Yolun seni hatırlıyor',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _PersonalSignal(
                  intention: intention,
                  records: records,
                  language: language,
                ),
                const SizedBox(height: 14),
                DestinyFlagshipCard(
                  records: records,
                  completedDays: completedArcanaDays,
                  language: language,
                  onOpen: onOpenDestiny,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return mysticText(language, 'Good morning', 'Günaydın');
    if (hour < 18) return mysticText(language, 'Good afternoon', 'İyi günler');
    return mysticText(language, 'Good evening', 'İyi akşamlar');
  }

  Widget _premiumReadingCard(BuildContext context, ReadingKind kind) => InkWell(
    onTap: () => onPremiumSpread(kind),
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: 158,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5A3B82), Color(0xFF20152F)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                kind.symbol,
                style: const TextStyle(fontSize: 27, color: MysticColors.gold),
              ),
              const Spacer(),
              Icon(
                isPlus ? Icons.lock_open_rounded : Icons.lock_outline,
                color: MysticColors.gold,
                size: 17,
              ),
            ],
          ),
          const Spacer(),
          Text(
            _readingKindTitle(kind, language),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            mysticText(
              language,
              '${kind.cardCount}-card premium spread',
              '${kind.cardCount} kartlık premium açılım',
            ),
            style: const TextStyle(
              fontFamily: 'Arial',
              color: MysticColors.lavender,
              fontSize: 10,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _featuredReadingCard(
    BuildContext context,
    ReadingKind kind,
  ) => InkWell(
    onTap: () => onReading(kind),
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: 136,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2146), Color(0xFF171321)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MysticColors.lavender.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                kind.symbol,
                style: const TextStyle(fontSize: 25, color: MysticColors.gold),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_outward_rounded,
                color: MysticColors.lavender,
                size: 16,
              ),
            ],
          ),
          const Spacer(),
          Text(
            _readingKindTitle(kind, language),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            mysticText(
              language,
              '${kind.cardCount} cards',
              '${kind.cardCount} kart',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 11),
          ),
        ],
      ),
    ),
  );

  Future<void> _showAllReadings(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF171321),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    mysticText(
                      language,
                      'Reading library',
                      'Okuma kütüphanesi',
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    mysticText(
                      language,
                      'Choose the question that needs your attention now.',
                      'Şimdi ilgini isteyen soruyu seç.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ..._standardReadingKinds.map(
                    (kind) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          onReading(kind);
                        },
                        tileColor: Colors.white.withValues(alpha: .045),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: MysticColors.violet.withValues(alpha: .24),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text(
                            kind.symbol,
                            style: const TextStyle(
                              fontSize: 21,
                              color: MysticColors.gold,
                            ),
                          ),
                        ),
                        title: Text(_readingKindTitle(kind, language)),
                        subtitle: Text(
                          mysticText(
                            language,
                            '${kind.cardCount} card spread',
                            '${kind.cardCount} kartlık açılım',
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: MysticColors.lavender,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _PersonalSignal extends StatelessWidget {
  const _PersonalSignal({
    required this.intention,
    required this.records,
    required this.language,
  });
  final String intention;
  final List<ReadingRecord> records;
  final MysticLanguage language;

  @override
  Widget build(BuildContext context) {
    final recent = records.take(7).toList();
    final cardCounts = <String, int>{};
    final emotionCounts = <EmotionalState, int>{};
    for (final record in recent) {
      emotionCounts.update(
        record.emotion,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      for (final item in record.cards) {
        cardCounts.update(
          item.card.name,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    final recurringCard = cardCounts.entries
        .where((entry) => entry.value > 1)
        .fold<MapEntry<String, int>?>(
          null,
          (best, entry) =>
              best == null || entry.value > best.value ? entry : best,
        );
    final dominantEmotion = emotionCounts.entries
        .fold<MapEntry<EmotionalState, int>?>(
          null,
          (best, entry) =>
              best == null || entry.value > best.value ? entry : best,
        );
    final hasPattern = recent.length >= 2;
    final recurringName = recurringCard == null
        ? null
        : localizedTarotCardName(
            recurringCard.key,
            languageCode: language.code,
          );
    final title = hasPattern
        ? mysticText(
            language,
            'Mystic remembers your pattern',
            'Mystic örüntünü hatırlıyor',
          )
        : mysticText(
            language,
            'Your $intention path is opening',
            '${_intentionTitle(intention, language)} yolun açılıyor',
          );
    final body = recurringCard != null
        ? mysticText(
            language,
            '$recurringName has returned ${recurringCard.value} times. Mystic is watching what this symbol keeps asking you to notice.',
            '$recurringName ${recurringCard.value} kez geri döndü. Mystic bu sembolün senden neyi fark etmeni istediğini izliyor.',
          )
        : dominantEmotion != null && hasPattern
        ? mysticText(
            language,
            'You have entered recent readings feeling ${_emotionLabel(dominantEmotion.key, language).toLowerCase()}. Your next reading will hold that emotional thread in view.',
            'Son okumalarına ${_emotionLabel(dominantEmotion.key, language).toLowerCase()} hissederek girdin. Sonraki okuman bu duygusal izi dikkate alacak.',
          )
        : mysticText(
            language,
            'Save two readings and Mystic will begin connecting recurring cards, emotions, and choices into a private pattern map.',
            'İki okuma kaydet; Mystic tekrar eden kartları, duyguları ve seçimleri özel örüntü haritanda birleştirmeye başlasın.',
          );
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D2348), Color(0xFF171321)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MysticColors.lavender.withValues(alpha: .24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MysticColors.violet.withValues(alpha: .28),
            ),
            child: const Text(
              '◉',
              style: TextStyle(color: MysticColors.gold, fontSize: 21),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _intentionTitle(String value, MysticLanguage selectedLanguage) =>
      switch (value) {
        'Love' => mysticText(selectedLanguage, 'Love', 'Aşk'),
        'Purpose' => mysticText(selectedLanguage, 'Purpose', 'Amaç'),
        'Healing' => mysticText(selectedLanguage, 'Healing', 'İyileşme'),
        _ => mysticText(selectedLanguage, 'Clarity', 'Netlik'),
      };
}

class _ReadingAllowance extends StatelessWidget {
  const _ReadingAllowance({
    required this.readingsLeft,
    required this.language,
    required this.onUpgrade,
  });
  final int readingsLeft;
  final MysticLanguage language;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final plus = readingsLeft < 0;
    final empty = !plus && readingsLeft == 0;
    return InkWell(
      onTap: empty ? onUpgrade : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: empty
              ? MysticColors.gold.withValues(alpha: .1)
              : Colors.white.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: empty
                ? MysticColors.gold.withValues(alpha: .38)
                : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: empty
                    ? MysticColors.gold
                    : MysticColors.violet.withValues(alpha: .28),
              ),
              child: Icon(
                empty ? Icons.lock_outline : Icons.bolt,
                color: empty ? MysticColors.ink : MysticColors.gold,
                size: 18,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plus
                        ? mysticText(
                            language,
                            'Unlimited deep readings active',
                            'Sınırsız derin okumalar etkin',
                          )
                        : empty
                        ? mysticText(
                            language,
                            'Free deep readings used',
                            'Ücretsiz derin okumalar kullanıldı',
                          )
                        : mysticText(
                            language,
                            '$readingsLeft free deep readings left today',
                            'Bugün $readingsLeft ücretsiz derin okuman kaldı',
                          ),
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    plus
                        ? mysticText(
                            language,
                            'Your verified Mystic Plus entitlement is active.',
                            'Doğrulanmış Mystic Plus hakkın etkin.',
                          )
                        : empty
                        ? mysticText(
                            language,
                            'Unlock unlimited readings with Mystic Plus.',
                            'Mystic Plus ile sınırsız okumaları aç.',
                          )
                        : mysticText(
                            language,
                            'Your Daily Guidance remains free every day.',
                            'Günlük Rehberliğin her gün ücretsiz kalır.',
                          ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              plus
                  ? mysticText(language, 'PLUS ACTIVE', 'PLUS ETKİN')
                  : empty
                  ? mysticText(language, 'VIEW PLUS', 'PLUS’I GÖR')
                  : '${3 - readingsLeft}/3',
              style: TextStyle(
                fontFamily: 'Arial',
                color: empty ? MysticColors.gold : MysticColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoonBriefing extends StatelessWidget {
  const _MoonBriefing({required this.language});
  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .045),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: MysticColors.lavender.withValues(alpha: .14)),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFF5DFA6), Color(0xFF8F6FD8)],
            ),
            boxShadow: [
              BoxShadow(
                color: MysticColors.lavender.withValues(alpha: .25),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Text(
            '◐',
            style: TextStyle(color: MysticColors.ink, fontSize: 23),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mysticText(
                  language,
                  'TONIGHT’S MYSTIC PULSE',
                  'BU GECENİN MYSTIC NABZI',
                ),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mysticText(
                  language,
                  'Release urgency. Choose the honest next step.',
                  'Acele hissini bırak. Dürüst olan bir sonraki adımı seç.',
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: MysticColors.mist),
              ),
            ],
          ),
        ),
        Text(
          mysticText(language, '2 MIN', '2 DK'),
          style: const TextStyle(
            fontFamily: 'Arial',
            color: MysticColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class _DailyCard extends StatefulWidget {
  const _DailyCard({
    required this.streak,
    required this.deckStyle,
    required this.language,
    required this.onTap,
  });
  final int streak;
  final DeckStyle deckStyle;
  final MysticLanguage language;
  final VoidCallback onTap;

  @override
  State<_DailyCard> createState() => _DailyCardState();
}

class _DailyCardState extends State<_DailyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, child) => InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        constraints: const BoxConstraints(minHeight: 214),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(
                const Color(0xFF6C45B5),
                const Color(0xFF8356C5),
                controller.value,
              )!,
              const Color(0xFF251944),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: MysticColors.lavender.withValues(
              alpha: .32 + controller.value * .18,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: MysticColors.violet.withValues(
                alpha: .12 + controller.value * .08,
              ),
              blurRadius: 28,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mysticText(
                      widget.language,
                      'YOUR DAILY PORTAL',
                      'GÜNLÜK PORTALIN',
                    ),
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      letterSpacing: 1.5,
                      color: MysticColors.lavender,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    mysticText(
                      widget.language,
                      'Reveal what\nneeds you today',
                      'Bugün senden\nne istendiğini gör',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mysticText(
                      widget.language,
                      '🔥 ${widget.streak} day streak  •  +25 XP',
                      '🔥 ${widget.streak} günlük seri  •  +25 XP',
                    ),
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TarotCardFace(style: widget.deckStyle, width: 82, height: 132),
          ],
        ),
      ),
    ),
  );
}

class _DailyQuest extends StatelessWidget {
  const _DailyQuest({
    required this.readingDone,
    required this.ritualDone,
    required this.claimed,
    required this.language,
    required this.onClaim,
  });
  final bool readingDone;
  final bool ritualDone;
  final bool claimed;
  final MysticLanguage language;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final complete = readingDone && ritualDone;
    final progress = (readingDone ? .5 : 0.0) + (ritualDone ? .5 : 0.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: complete
              ? const [Color(0xFF523771), Color(0xFF21182F)]
              : const [Color(0xFF211A31), Color(0xFF15111F)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: complete
              ? MysticColors.gold.withValues(alpha: .48)
              : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: complete
                      ? MysticColors.gold.withValues(alpha: .16)
                      : Colors.white.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  claimed
                      ? '✦'
                      : complete
                      ? '◇'
                      : '☾',
                  style: const TextStyle(
                    color: MysticColors.gold,
                    fontSize: 25,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mysticText(
                        language,
                        'DAILY SOUL QUEST',
                        'GÜNLÜK RUH GÖREVİ',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: MysticColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      claimed
                          ? mysticText(
                              language,
                              'Today’s relic is yours.',
                              'Bugünün yadigârı senin.',
                            )
                          : complete
                          ? mysticText(
                              language,
                              'Your chest is ready to open.',
                              'Sandığın açılmaya hazır.',
                            )
                          : mysticText(
                              language,
                              'Complete both steps • +40 XP',
                              'İki adımı da tamamla • +40 XP',
                            ),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (complete && !claimed)
                IconButton(
                  onPressed: () => _claim(context),
                  style: IconButton.styleFrom(
                    backgroundColor: MysticColors.gold,
                    foregroundColor: MysticColors.ink,
                  ),
                  icon: const Icon(Icons.lock_open_rounded),
                ),
              if (claimed)
                const Icon(Icons.check_circle, color: MysticColors.gold),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _step(
                context,
                '1',
                mysticText(language, 'Daily card', 'Günlük kart'),
                readingDone,
              ),
              const SizedBox(width: 8),
              _step(
                context,
                '2',
                mysticText(language, 'One ritual', 'Bir ritüel'),
                ritualDone,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: claimed ? 1.0 : progress,
              minHeight: 5,
              backgroundColor: Colors.white10,
              color: MysticColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(BuildContext context, String number, String label, bool done) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: done
                ? MysticColors.gold.withValues(alpha: .1)
                : Colors.white.withValues(alpha: .035),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: done ? MysticColors.gold : Colors.white10,
                child: Text(
                  done ? '✓' : number,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: done ? MysticColors.ink : MysticColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  void _claim(BuildContext context) {
    onClaim();
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: mysticText(language, 'Close reward', 'Ödülü kapat'),
      barrierColor: Colors.black.withValues(alpha: .78),
      transitionDuration: const Duration(milliseconds: 450),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        ),
      ),
      pageBuilder: (_, __, ___) => _QuestRewardDialog(language: language),
    );
  }
}

class _QuestRewardDialog extends StatefulWidget {
  const _QuestRewardDialog({required this.language});
  final MysticLanguage language;

  @override
  State<_QuestRewardDialog> createState() => _QuestRewardDialogState();
}

class _QuestRewardDialogState extends State<_QuestRewardDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..forward();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Material(
      color: Colors.transparent,
      child: Container(
        width: 310,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [Color(0xFF60458F), Color(0xFF191226)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .55)),
          boxShadow: [
            BoxShadow(
              color: MysticColors.violet.withValues(alpha: .35),
              blurRadius: 50,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RewardBurstPainter(controller.value),
                      ),
                    ),
                    Transform.scale(
                      scale:
                          .7 +
                          Curves.elasticOut.transform(controller.value) * .3,
                      child: Transform.rotate(
                        angle:
                            sin(controller.value * pi * 4) *
                            (1 - controller.value) *
                            .08,
                        child: Container(
                          width: 88,
                          height: 88,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF4DB8F), Color(0xFFB88231)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: MysticColors.gold.withValues(alpha: .5),
                                blurRadius: 35,
                              ),
                            ],
                          ),
                          child: Text(
                            controller.value > .55 ? '✦' : '◇',
                            style: const TextStyle(
                              fontSize: 43,
                              color: MysticColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                mysticText(
                  widget.language,
                  'SOUL CHEST OPENED',
                  'RUH SANDIĞI AÇILDI',
                ),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                '+40 XP',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 8),
              Text(
                mysticText(
                  widget.language,
                  'Moon Shard added to your constellation.',
                  'Ay Parçası takımyıldızına eklendi.',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              GoldButton(
                label: mysticText(
                  widget.language,
                  'Continue my path',
                  'Yoluma devam et',
                ),
                onPressed: () => Navigator.pop(context),
                icon: Icons.auto_awesome,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RewardBurstPainter extends CustomPainter {
  const _RewardBurstPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 14; i++) {
      final angle = i * pi * 2 / 14;
      final distance =
          22 + Curves.easeOut.transform(progress) * (42 + (i % 3) * 8);
      final point = center + Offset(cos(angle), sin(angle)) * distance;
      canvas.drawCircle(
        point,
        i.isEven ? 2.2 : 1.4,
        Paint()
          ..color = MysticColors.gold.withValues(
            alpha: (1 - progress * .55).clamp(0.0, 1.0).toDouble(),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RewardBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class ReadingFlow extends StatefulWidget {
  const ReadingFlow({
    required this.kind,
    required this.deckStyle,
    required this.userName,
    required this.intention,
    required this.language,
    required this.isPlus,
    required this.pastRecords,
    required this.onPremium,
    required this.onComplete,
    super.key,
  });
  final ReadingKind kind;
  final DeckStyle deckStyle;
  final String userName;
  final String intention;
  final MysticLanguage language;
  final bool isPlus;
  final List<ReadingRecord> pastRecords;
  final VoidCallback onPremium;
  final ValueChanged<ReadingRecord> onComplete;
  @override
  State<ReadingFlow> createState() => _ReadingFlowState();
}

class _ReadingFlowState extends State<ReadingFlow> {
  final question = TextEditingController();
  final selected = <int>[];
  EmotionalState emotion = EmotionalState.uncertain;
  List<DrawnCard>? drawn;
  bool saved = false;
  bool ritualOpened = false;
  bool revealComplete = false;
  bool allowReversals = true;
  bool oracleQuestionUsed = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted)
        setState(
          () => allowReversals = prefs.getBool('allow_reversals') ?? true,
        );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: MysticBackground(
      child: drawn == null
          ? _selection(context)
          : ritualOpened
          ? _result(context)
          : _RevealRitual(
              kind: widget.kind,
              cardCount: drawn!.length,
              deckStyle: widget.deckStyle,
              question: question.text.trim(),
              emotion: emotion,
              language: widget.language,
              onBack: () => setState(() => drawn = null),
              onReveal: _openRitual,
            ),
    ),
  );

  Widget _selection(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            const Spacer(),
            Text(
              '${selected.length}/${widget.kind.cardCount}',
              style: const TextStyle(
                fontFamily: 'Arial',
                color: MysticColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          _readingKindTitle(widget.kind, widget.language),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          mysticText(
            widget.language,
            'Breathe slowly. Hold your question in mind, then choose the cards that call to you.',
            'Yavaşça nefes al. Sorunu zihninde tut, sonra sana seslenen kartları seç.',
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: MysticColors.mist,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: question,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: mysticText(
              widget.language,
              'Write your question (optional)',
              'Sorunu yaz (isteğe bağlı)',
            ),
            prefixIcon: const Icon(Icons.edit_outlined),
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            mysticText(
              widget.language,
              'HOW DO YOU FEEL RIGHT NOW?',
              'ŞU ANDA NASIL HİSSEDİYORSUN?',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 11, letterSpacing: 1.1),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final item in EmotionalState.values)
                ChoiceChip(
                  label: Text(
                    '${item.symbol} ${_emotionLabel(item, widget.language)}',
                  ),
                  selected: emotion == item,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onSelected: (_) => setState(() => emotion = item),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              mysticText(
                widget.language,
                'CHOOSE YOUR CARDS',
                'KARTLARINI SEÇ',
              ),
              style: const TextStyle(
                fontFamily: 'Arial',
                color: MysticColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.15,
              ),
            ),
            const Spacer(),
            Text(
              mysticText(
                widget.language,
                'Trust the first pull',
                'İlk çekime güven',
              ),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: .62,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
            ),
            itemCount: 12,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _toggle(i),
              child: TarotCardFace(
                style: widget.deckStyle,
                selected: selected.contains(i),
                width: 65,
                height: 110,
              ),
            ),
          ),
        ),
        GoldButton(
          label: selected.length == widget.kind.cardCount
              ? mysticText(
                  widget.language,
                  'Seal my selection',
                  'Seçimimi mühürle',
                )
              : mysticText(
                  widget.language,
                  'Choose ${widget.kind.cardCount - selected.length} more',
                  '${widget.kind.cardCount - selected.length} kart daha seç',
                ),
          onPressed: selected.length == widget.kind.cardCount
              ? _prepareRitual
              : null,
          icon: Icons.auto_awesome,
        ),
      ],
    ),
  );

  void _toggle(int index) {
    HapticFeedback.selectionClick();
    MysticSoundscape.instance.selectCard();
    setState(() {
      if (selected.contains(index)) {
        selected.remove(index);
      } else if (selected.length < widget.kind.cardCount) {
        selected.add(index);
      }
    });
  }

  void _prepareRitual() {
    final random = Random();
    final pool = [...tarotDeck]..shuffle(random);
    HapticFeedback.selectionClick();
    MysticSoundscape.instance.sealSelection();
    setState(() {
      drawn = List.generate(
        widget.kind.cardCount,
        (i) => DrawnCard(pool[i], allowReversals && random.nextInt(4) == 0),
      );
      ritualOpened = false;
      revealComplete = false;
    });
  }

  Future<void> _openRitual() async {
    HapticFeedback.mediumImpact();
    MysticSoundscape.instance.revealCards();
    setState(() => ritualOpened = true);
    await Future<void>.delayed(
      Duration(milliseconds: 850 + widget.kind.cardCount * 520),
    );
    if (mounted) setState(() => revealComplete = true);
  }

  Widget _result(BuildContext context) {
    final record = ReadingRecord(
      kind: widget.kind,
      question: question.text.trim(),
      cards: drawn!,
      createdAt: DateTime.now(),
      emotion: emotion,
      alignedAction: _alignedAction(),
    );
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          title: Text(mysticText(widget.language, 'Your reading', 'Okuman')),
          actions: [
            IconButton(
              onPressed: revealComplete ? () => _openStoryStudio(record) : null,
              tooltip: mysticText(
                widget.language,
                'Share reading',
                'Okumayı paylaş',
              ),
              icon: const Icon(Icons.ios_share_outlined),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                _headline(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                mysticText(
                  widget.language,
                  'Take what resonates. Tarot is a mirror for reflection—not a fixed prediction.',
                  'Sana uyan mesajı al. Tarot kesin bir kehanet değil, düşünmek için bir aynadır.',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 190,
                child: drawn!.length <= 3
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < drawn!.length; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            _RitualRevealCard(
                              card: drawn![i],
                              deckStyle: widget.deckStyle,
                              language: widget.language,
                              delay: Duration(milliseconds: 350 + i * 520),
                            ),
                          ],
                        ],
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemBuilder: (_, i) => _RitualRevealCard(
                          card: drawn![i],
                          deckStyle: widget.deckStyle,
                          language: widget.language,
                          delay: Duration(milliseconds: 350 + i * 520),
                        ),
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemCount: drawn!.length,
                      ),
              ),
              const SizedBox(height: 26),
              if (!revealComplete)
                _ReadingInProgress(
                  cardCount: drawn!.length,
                  language: widget.language,
                ),
              if (revealComplete)
                ...drawn!.asMap().entries.map(
                  (entry) => _interpretation(context, entry.key, entry.value),
                ),
              if (revealComplete)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: MysticColors.gold.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MysticColors.gold.withValues(alpha: .3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mysticText(
                          widget.language,
                          '✦  YOUR GUIDANCE',
                          '✦  REHBERLİĞİN',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          color: MysticColors.gold,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _guidance(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              if (revealComplete && widget.pastRecords.isNotEmpty)
                const SizedBox(height: 14),
              if (revealComplete && widget.pastRecords.isNotEmpty)
                _memoryBridge(context),
              if (revealComplete) const SizedBox(height: 14),
              if (revealComplete) _oracleInvitation(context, record),
              if (revealComplete) const SizedBox(height: 14),
              if (revealComplete)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF34235C), Color(0xFF1B1530)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MysticColors.lavender.withValues(alpha: .28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mysticText(
                          widget.language,
                          'MYSTIC MIRROR • 24H LOOP',
                          'MYSTIC AYNA • 24 SAATLİK DÖNGÜ',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          color: MysticColors.lavender,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        mysticText(
                          widget.language,
                          'Your aligned action',
                          'Sana uygun eylem',
                        ),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _alignedAction(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        mysticText(
                          widget.language,
                          'Tomorrow, Mystic will ask what actually changed. Your answer becomes part of your personal pattern map.',
                          'Mystic yarın gerçekte neyin değiştiğini soracak. Cevabın kişisel örüntü haritanın bir parçası olacak.',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              if (revealComplete) const SizedBox(height: 20),
              if (revealComplete)
                GoldButton(
                  label: saved
                      ? mysticText(
                          widget.language,
                          'Saved to your journal',
                          'Günlüğüne kaydedildi',
                        )
                      : mysticText(
                          widget.language,
                          'Save this reading',
                          'Bu okumayı kaydet',
                        ),
                  icon: saved ? Icons.check : Icons.bookmark_add_outlined,
                  onPressed: saved
                      ? null
                      : () {
                          widget.onComplete(record);
                          setState(() => saved = true);
                        },
                ),
              if (revealComplete) const SizedBox(height: 10),
              if (revealComplete)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    mysticText(
                      widget.language,
                      'Return home',
                      'Ana sayfaya dön',
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _interpretation(BuildContext context, int index, DrawnCard card) {
    final positions = <String>[
      mysticText(
        widget.language,
        'What surrounds you',
        'Seni çevreleyen enerji',
      ),
      mysticText(
        widget.language,
        'What asks for attention',
        'Dikkat isteyen konu',
      ),
      mysticText(
        widget.language,
        'Your next aligned step',
        'Sıradaki uyumlu adım',
      ),
    ];
    final meaning = _localizedCardMeaning(card, widget.language);
    final cardName = localizedTarotCardName(
      card.card.name,
      languageCode: widget.language.code,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index < positions.length
                ? positions[index].toUpperCase()
                : mysticText(widget.language, 'MESSAGE', 'MESAJ'),
            style: const TextStyle(
              fontFamily: 'Arial',
              color: MysticColors.lavender,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$cardName${card.reversed ? mysticText(widget.language, ' — Reversed', ' — Ters') : ''}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(meaning, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  String _headline() {
    final hopeful = drawn!.any(
      (c) => c.card.name == 'The Star' || c.card.name == 'The Sun',
    );
    if (widget.userName.isEmpty) {
      return hopeful
          ? mysticText(
              widget.language,
              'A hopeful path is becoming visible.',
              'Umut veren bir yol görünür oluyor.',
            )
          : mysticText(
              widget.language,
              'The truth arrives when you slow down.',
              'Yavaşladığında gerçek belirginleşiyor.',
            );
    }
    return hopeful
        ? mysticText(
            widget.language,
            '${widget.userName}, a hopeful path is becoming visible.',
            '${widget.userName}, umut veren bir yol görünür oluyor.',
          )
        : mysticText(
            widget.language,
            '${widget.userName}, the truth arrives when you slow down.',
            '${widget.userName}, yavaşladığında gerçek belirginleşiyor.',
          );
  }

  Widget _memoryBridge(BuildContext context) {
    final previous = widget.pastRecords.first;
    final returning = drawn!
        .where(
          (current) =>
              previous.cards.any((old) => old.card.name == current.card.name),
        )
        .map(
          (item) => localizedTarotCardName(
            item.card.name,
            languageCode: widget.language.code,
          ),
        )
        .toList();
    final message = returning.isNotEmpty
        ? mysticText(
            widget.language,
            '${returning.first} also appeared in your last saved reading. Repeating symbols often become useful when you compare what changed between the two moments.',
            '${returning.first} son kaydettiğin okumada da görünmüştü. Tekrarlayan semboller, iki an arasında neyin değiştiğini karşılaştırdığında anlam kazanır.',
          )
        : mysticText(
            widget.language,
            'Your previous reading began from ${localizedEmotionLabel(previous.emotion, languageCode: widget.language.code).toLowerCase()}; today you chose ${localizedEmotionLabel(emotion, languageCode: widget.language.code).toLowerCase()}. Mystic is connecting the emotional shift—not just the cards.',
            'Önceki okuman ${_emotionLabel(previous.emotion, widget.language).toLowerCase()} duygusuyla başlamıştı; bugün ${_emotionLabel(emotion, widget.language).toLowerCase()} seçtin. Mystic yalnızca kartları değil, duygusal değişimi de birbirine bağlıyor.',
          );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF30254A), Color(0xFF181321)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MysticColors.lavender.withValues(alpha: .26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mysticText(
              widget.language,
              '◉  ORACLE MEMORY',
              '◉  ORACLE HAFIZASI',
            ),
            style: const TextStyle(
              fontFamily: 'Arial',
              color: MysticColors.lavender,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 9),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _oracleInvitation(
    BuildContext context,
    ReadingRecord record,
  ) => InkWell(
    onTap: !widget.isPlus && oracleQuestionUsed
        ? widget.onPremium
        : () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OracleDialogueScreen(
                record: record,
                pastRecords: widget.pastRecords,
                userName: widget.userName,
                intention: widget.intention,
                language: widget.language,
                isPlus: widget.isPlus,
                onQuestionUsed: () {
                  if (!widget.isPlus && mounted)
                    setState(() => oracleQuestionUsed = true);
                },
                onPremium: widget.onPremium,
              ),
            ),
          ),
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF55377A), Color(0xFF21162F)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .36)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MysticColors.gold.withValues(alpha: .14),
              boxShadow: [
                BoxShadow(
                  color: MysticColors.gold.withValues(alpha: .16),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Text(
              widget.isPlus
                  ? '∞'
                  : oracleQuestionUsed
                  ? '✦'
                  : '◉',
              style: const TextStyle(fontSize: 25, color: MysticColors.gold),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      mysticText(
                        widget.language,
                        'ASK THE ORACLE',
                        'ORACLE’A SOR',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: MysticColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.isPlus
                          ? mysticText(widget.language, 'UNLIMITED', 'SINIRSIZ')
                          : oracleQuestionUsed
                          ? mysticText(
                              widget.language,
                              'CONTINUE PLUS',
                              'PLUS İLE DEVAM',
                            )
                          : mysticText(widget.language, '1 FREE', '1 ÜCRETSİZ'),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: MysticColors.lavender,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isPlus
                      ? mysticText(
                          widget.language,
                          'Ask unlimited personal follow-ups whenever you return to this reading.',
                          'Bu okumaya her döndüğünde sınırsız kişisel devam sorusu sor.',
                        )
                      : oracleQuestionUsed
                      ? mysticText(
                          widget.language,
                          'Your free answer is complete. Continue the dialogue with Mystic Plus.',
                          'Ücretsiz cevabın tamamlandı. Diyaloğa Mystic Plus ile devam et.',
                        )
                      : mysticText(
                          widget.language,
                          'Go beyond the first interpretation with one personal follow-up question.',
                          'Kişisel bir devam sorusuyla ilk yorumun ötesine geç.',
                        ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: MysticColors.mist),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward, color: MysticColors.gold),
        ],
      ),
    ),
  );

  void _openStoryStudio(ReadingRecord record) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StoryStudioScreen(
        record: record,
        guidance: _guidance(),
        language: widget.language,
      ),
    ),
  );
  String _guidance() => mysticText(
    widget.language,
    '${_localizedCardAdvice(drawn!.last, widget.language)} Hold this beside your intention of ${_localizedIntention(widget.intention, widget.language).toLowerCase()}. Let it be an invitation, not a command, and notice what changes over the next twenty-four hours.',
    '${_localizedCardAdvice(drawn!.last, widget.language)} Bunu seçtiğin niyetin yanında tut. Bir emir değil, davet olarak gör ve önümüzdeki yirmi dört saatte neyin değiştiğini fark et.',
  );
  String _alignedAction() {
    switch (emotion) {
      case EmotionalState.anxious:
        return mysticText(
          widget.language,
          'Delay one fear-based decision. Write down what is known, what is assumed, and what can wait until tomorrow.',
          'Korkuya dayanan bir kararı ertele. Bildiklerini, varsaydıklarını ve yarına kalabilecekleri ayrı ayrı yaz.',
        );
      case EmotionalState.hopeful:
        return mysticText(
          widget.language,
          'Turn hope into evidence: take one small action that your future self can continue tomorrow.',
          'Umudu kanıta dönüştür: yarın da sürdürebileceğin küçük bir adım at.',
        );
      case EmotionalState.grounded:
        return mysticText(
          widget.language,
          'Use today’s steadiness to complete one conversation or task you have been leaving open.',
          'Bugünkü dengeni, açık bıraktığın bir konuşmayı veya işi tamamlamak için kullan.',
        );
      case EmotionalState.curious:
        return mysticText(
          widget.language,
          'Ask one honest question without trying to control the answer.',
          'Cevabı kontrol etmeye çalışmadan dürüst bir soru sor.',
        );
      case EmotionalState.uncertain:
        return mysticText(
          widget.language,
          'Choose the smallest reversible step. Clarity often appears after movement, not before it.',
          'Geri döndürülebilir en küçük adımı seç. Netlik çoğu zaman hareketten önce değil, sonra gelir.',
        );
    }
  }
}

class _RevealRitual extends StatefulWidget {
  const _RevealRitual({
    required this.kind,
    required this.cardCount,
    required this.deckStyle,
    required this.question,
    required this.emotion,
    required this.language,
    required this.onBack,
    required this.onReveal,
  });
  final ReadingKind kind;
  final int cardCount;
  final DeckStyle deckStyle;
  final String question;
  final EmotionalState emotion;
  final MysticLanguage language;
  final VoidCallback onBack;
  final VoidCallback onReveal;

  @override
  State<_RevealRitual> createState() => _RevealRitualState();
}

class _RevealRitualState extends State<_RevealRitual>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);
  bool opening = false;

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (opening) return;
    setState(() => opening = true);
    await Future<void>.delayed(const Duration(milliseconds: 820));
    if (mounted) widget.onReveal();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
    children: [
      Row(
        children: [
          IconButton(
            onPressed: opening ? null : widget.onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          Text(
            mysticText(widget.language, 'REVEAL RITUAL', 'AÇILIŞ RİTÜELİ'),
            style: const TextStyle(
              fontFamily: 'Arial',
              color: MysticColors.gold,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.6,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _ritualStep(
              '01',
              mysticText(widget.language, 'INTENTION', 'NİYET'),
              true,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _ritualStep(
              '02',
              mysticText(widget.language, 'SELECTION', 'SEÇİM'),
              true,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _ritualStep(
              '03',
              mysticText(widget.language, 'REVEAL', 'AÇILIŞ'),
              opening,
            ),
          ),
        ],
      ),
      const SizedBox(height: 28),
      Text(
        mysticText(
          widget.language,
          'Your cards are\nwaiting beneath the veil.',
          'Kartların perdenin\nardında seni bekliyor.',
        ),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 10),
      Text(
        widget.question.isEmpty
            ? mysticText(
                widget.language,
                'Hold your ${localizedReadingKindTitle(widget.kind, languageCode: widget.language.code).toLowerCase()} intention in mind. Exhale once, then open the seal when you feel ready.',
                '${_readingKindTitle(widget.kind, widget.language)} niyetini zihninde tut. Bir kez nefes ver, hazır hissettiğinde mührü aç.',
              )
            : '“${widget.question}”',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 29),
      AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final value = Curves.easeInOut.transform(pulse.value);
          return Center(
            child: SizedBox(
              width: 210,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 170 + value * 18,
                    height: 170 + value * 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: MysticColors.gold.withValues(
                          alpha: .08 + value * .14,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MysticColors.violet.withValues(
                            alpha: .13 + value * .09,
                          ),
                          blurRadius: 46,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  for (var i = min(widget.cardCount, 3) - 1; i >= 0; i--)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOutCubic,
                      transform: Matrix4.identity()
                        ..translateByDouble(
                          opening
                              ? (i - (min(widget.cardCount, 3) - 1) / 2) * 86.0
                              : (i - (min(widget.cardCount, 3) - 1) / 2) * 12.0,
                          opening ? -18.0 : i * 3.0,
                          0,
                          1,
                        ),
                      child: Transform.rotate(
                        angle:
                            (i - (min(widget.cardCount, 3) - 1) / 2) *
                            (opening ? .13 : .035),
                        child: TarotCardFace(
                          style: widget.deckStyle,
                          selected: opening,
                          width: 108,
                          height: 172,
                        ),
                      ),
                    ),
                  AnimatedScale(
                    duration: const Duration(milliseconds: 500),
                    scale: opening ? 1.18 : .94 + value * .06,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: opening ? 0 : 1,
                      child: Container(
                        width: 62,
                        height: 62,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFFFFE6A2), Color(0xFF9D7130)],
                          ),
                          border: Border.all(
                            color: const Color(0xFFFFE5A0),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: MysticColors.gold.withValues(
                                alpha: .32 + value * .18,
                              ),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: const Text(
                          '✦',
                          style: TextStyle(
                            color: MysticColors.ink,
                            fontSize: 27,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            '${widget.emotion.symbol}  ${_emotionLabel(widget.emotion, widget.language).toUpperCase()}  •  ${widget.cardCount} ${mysticText(widget.language, widget.cardCount == 1 ? 'CARD' : 'CARDS', 'KART')}',
            style: const TextStyle(
              fontFamily: 'Arial',
              color: MysticColors.lavender,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .9,
            ),
          ),
        ),
      ),
      const SizedBox(height: 26),
      GoldButton(
        label: opening
            ? mysticText(
                widget.language,
                'Opening the veil…',
                'Perde açılıyor…',
              )
            : mysticText(widget.language, 'Open the seal', 'Mührü aç'),
        icon: opening ? Icons.hourglass_top_rounded : Icons.touch_app_outlined,
        onPressed: opening ? null : _open,
      ),
      const SizedBox(height: 10),
      Text(
        mysticText(
          widget.language,
          'Take what resonates. The cards offer reflection, not certainty.',
          'Sana uyan mesajı al. Kartlar kesinlik değil, düşünme alanı sunar.',
        ),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
      ),
    ],
  );

  Widget _ritualStep(String number, String label, bool active) =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: active
              ? MysticColors.gold.withValues(alpha: .11)
              : Colors.white.withValues(alpha: .035),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? MysticColors.gold.withValues(alpha: .42)
                : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: TextStyle(
                fontFamily: 'Arial',
                color: active ? MysticColors.gold : MysticColors.muted,
                fontWeight: FontWeight.w900,
                fontSize: 8,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: active ? MysticColors.mist : MysticColors.muted,
                  fontWeight: FontWeight.w800,
                  fontSize: 7.5,
                  letterSpacing: .4,
                ),
              ),
            ),
          ],
        ),
      );
}

class OracleDialogueScreen extends StatefulWidget {
  const OracleDialogueScreen({
    required this.record,
    required this.pastRecords,
    required this.userName,
    required this.intention,
    required this.language,
    required this.isPlus,
    required this.onQuestionUsed,
    required this.onPremium,
    super.key,
  });
  final ReadingRecord record;
  final List<ReadingRecord> pastRecords;
  final String userName;
  final String intention;
  final MysticLanguage language;
  final bool isPlus;
  final VoidCallback onQuestionUsed;
  final VoidCallback onPremium;

  @override
  State<OracleDialogueScreen> createState() => _OracleDialogueScreenState();
}

class _OracleDialogueScreenState extends State<OracleDialogueScreen> {
  final controller = TextEditingController();
  String? askedQuestion;
  String? answer;
  bool thinking = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mysticText(widget.language, 'Oracle Dialogue', 'Oracle Diyaloğu'),
        ),
      ),
      body: MysticBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFE6A5), Color(0xFF815923)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MysticColors.gold.withValues(alpha: .25),
                      blurRadius: 34,
                    ),
                  ],
                ),
                child: const Text(
                  '◉',
                  style: TextStyle(fontSize: 35, color: MysticColors.ink),
                ),
              ),
            ),
            const SizedBox(height: 13),
            Text(
              widget.userName.isEmpty
                  ? mysticText(
                      widget.language,
                      'The Oracle is listening.',
                      'Oracle seni dinliyor.',
                    )
                  : mysticText(
                      widget.language,
                      '${widget.userName}, the Oracle is listening.',
                      '${widget.userName}, Oracle seni dinliyor.',
                    ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              mysticText(
                widget.language,
                'Ask one question about the cards you just revealed. The answer will stay grounded in their symbols and your ${_localizedIntention(widget.intention, widget.language).toLowerCase()} path.',
                'Az önce açtığın kartlarla ilgili bir soru sor. Cevap, kartların sembollerine ve seçtiğin yola bağlı kalacak.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (widget.pastRecords.isNotEmpty) const SizedBox(height: 12),
            if (widget.pastRecords.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: MysticColors.lavender.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: MysticColors.lavender.withValues(alpha: .25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.memory,
                      size: 17,
                      color: MysticColors.lavender,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        mysticText(
                          widget.language,
                          'Oracle Memory is connecting ${min(12, widget.pastRecords.length)} previous readings on this device.',
                          'Oracle Hafızası bu cihazdaki ${min(12, widget.pastRecords.length)} önceki okumayı birbirine bağlıyor.',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          color: MysticColors.lavender,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 126,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.record.cards.length,
                separatorBuilder: (_, __) => const SizedBox(width: 9),
                itemBuilder: (_, index) => TarotCardFace(
                  drawn: widget.record.cards[index],
                  displayName: localizedTarotCardName(
                    widget.record.cards[index].card.name,
                    languageCode: widget.language.code,
                  ),
                  reversedLabel: mysticText(
                    widget.language,
                    'Reversed',
                    'Ters',
                  ),
                  width: 76,
                  height: 122,
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (askedQuestion == null) ...[
              Text(
                mysticText(
                  widget.language,
                  'CHOOSE A FOLLOW-UP',
                  'DEVAM SORUSU SEÇ',
                ),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.lavender,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              ...suggestions.map(
                (question) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: InkWell(
                    onTap: () => _ask(question),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .055),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              question,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 13,
                            color: MysticColors.gold,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: controller,
                maxLength: 160,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) _ask(value.trim());
                },
                decoration: InputDecoration(
                  hintText: mysticText(
                    widget.language,
                    'Or ask in your own words…',
                    'Ya da kendi cümlelerinle sor…',
                  ),
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                ),
              ),
              const SizedBox(height: 9),
              GoldButton(
                label: widget.isPlus
                    ? mysticText(
                        widget.language,
                        'Ask the Oracle',
                        'Oracle’a sor',
                      )
                    : mysticText(
                        widget.language,
                        'Ask my free question',
                        'Ücretsiz sorumu sor',
                      ),
                icon: Icons.auto_awesome,
                onPressed: controller.text.trim().isEmpty
                    ? null
                    : () => _ask(controller.text.trim()),
              ),
            ],
            if (askedQuestion != null) ...[
              _messageBubble(context, askedQuestion!, fromOracle: false),
              const SizedBox(height: 12),
              if (thinking)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .045),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MysticColors.gold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        mysticText(
                          widget.language,
                          'The Oracle is connecting your symbols…',
                          'Oracle sembollerini birbirine bağlıyor…',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          color: MysticColors.lavender,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              if (answer != null)
                _messageBubble(context, answer!, fromOracle: true),
              if (answer != null) const SizedBox(height: 18),
              if (answer != null && !widget.isPlus)
                Container(
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF493269), Color(0xFF20162D)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MysticColors.gold.withValues(alpha: .3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 19,
                            color: MysticColors.gold,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              mysticText(
                                widget.language,
                                'Continue the conversation',
                                'Sohbete devam et',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        mysticText(
                          widget.language,
                          'Ask unlimited follow-ups, revisit saved conversations, and unlock every deep spread with Mystic Plus.',
                          'Sınırsız devam sorusu sor, kayıtlı sohbetlere dön ve Mystic Plus ile tüm derin açılımları aç.',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 15),
                      GoldButton(
                        label: mysticText(
                          widget.language,
                          'Unlock Oracle Dialogue',
                          'Oracle Diyaloğunu Aç',
                        ),
                        icon: Icons.lock_open_rounded,
                        onPressed: widget.onPremium,
                      ),
                    ],
                  ),
                ),
              if (answer != null && widget.isPlus) const SizedBox(height: 14),
              if (answer != null && widget.isPlus)
                GoldButton(
                  label: mysticText(
                    widget.language,
                    'Ask another question',
                    'Başka bir soru sor',
                  ),
                  icon: Icons.refresh_rounded,
                  onPressed: _resetConversation,
                ),
              if (answer != null) const SizedBox(height: 9),
              if (answer != null)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    mysticText(
                      widget.language,
                      'Return to my reading',
                      'Okumama dön',
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _resetConversation() {
    controller.clear();
    setState(() {
      askedQuestion = null;
      answer = null;
      thinking = false;
    });
  }

  Widget _messageBubble(
    BuildContext context,
    String text, {
    required bool fromOracle,
  }) => Align(
    alignment: fromOracle ? Alignment.centerLeft : Alignment.centerRight,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 330),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: fromOracle
            ? MysticColors.violet.withValues(alpha: .24)
            : MysticColors.gold.withValues(alpha: .12),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(19),
          topRight: const Radius.circular(19),
          bottomLeft: Radius.circular(fromOracle ? 4 : 19),
          bottomRight: Radius.circular(fromOracle ? 19 : 4),
        ),
        border: Border.all(
          color: fromOracle
              ? MysticColors.lavender.withValues(alpha: .24)
              : MysticColors.gold.withValues(alpha: .25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fromOracle)
            const Text(
              'ORACLE',
              style: TextStyle(
                fontFamily: 'Arial',
                color: MysticColors.gold,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          if (fromOracle) const SizedBox(height: 7),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    ),
  );

  List<String> _suggestions() {
    switch (widget.language) {
      case MysticLanguage.turkish:
        switch (widget.record.kind) {
          case ReadingKind.love:
          case ReadingKind.compatibility:
            return const [
              'Bu bağda görmediğim şey ne?',
              'Hangi sınır veya gerçek dikkatimi istiyor?',
              'Daha sağlıklı bir sonraki adım nasıl görünür?',
            ];
          case ReadingKind.career:
          case ReadingKind.money:
            return const [
              'Bu kartlardaki gerçek fırsat nerede?',
              'Hangi riski küçümsüyorum?',
              'Atabileceğim en küçük faydalı adım ne?',
            ];
          default:
            return const [
              'Henüz görmediğim şey ne?',
              'Şu anda en önemli kart hangisi?',
              'Önümüzdeki 24 saate ne taşımalıyım?',
            ];
        }
      case MysticLanguage.spanish:
        switch (widget.record.kind) {
          case ReadingKind.love:
          case ReadingKind.compatibility:
            return const [
              '¿Qué no estoy viendo en esta conexión?',
              '¿Qué límite o verdad necesita mi atención?',
              '¿Cómo sería un siguiente paso más saludable?',
            ];
          case ReadingKind.career:
          case ReadingKind.money:
            return const [
              '¿Dónde está la verdadera oportunidad en estas cartas?',
              '¿Qué riesgo estoy subestimando?',
              '¿Cuál es el siguiente paso útil más pequeño?',
            ];
          default:
            return const [
              '¿Qué no estoy viendo todavía?',
              '¿Qué carta importa más en este momento?',
              '¿Qué debería llevar conmigo durante las próximas 24 horas?',
            ];
        }
      case MysticLanguage.portugueseBrazil:
        switch (widget.record.kind) {
          case ReadingKind.love:
          case ReadingKind.compatibility:
            return const [
              'O que não estou vendo nesta conexão?',
              'Qual limite ou verdade precisa da minha atenção?',
              'Como seria um próximo passo mais saudável?',
            ];
          case ReadingKind.career:
          case ReadingKind.money:
            return const [
              'Onde está a verdadeira oportunidade nestas cartas?',
              'Que risco estou subestimando?',
              'Qual é o menor próximo passo útil?',
            ];
          default:
            return const [
              'O que ainda não estou vendo?',
              'Qual carta mais importa agora?',
              'O que devo levar para as próximas 24 horas?',
            ];
        }
      default:
        switch (widget.record.kind) {
          case ReadingKind.love:
          case ReadingKind.compatibility:
            return const [
              'What am I not seeing in this connection?',
              'What boundary or truth needs my attention?',
              'What would a healthier next step look like?',
            ];
          case ReadingKind.career:
          case ReadingKind.money:
            return const [
              'Where is the real opportunity in these cards?',
              'What risk am I underestimating?',
              'What is the smallest useful next move?',
            ];
          default:
            return const [
              'What am I not seeing yet?',
              'Which card matters most right now?',
              'What should I carry into the next 24 hours?',
            ];
        }
    }
  }

  Future<void> _ask(String question) async {
    if (askedQuestion != null || question.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    widget.onQuestionUsed();
    setState(() {
      askedQuestion = question.trim();
      thinking = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() {
      thinking = false;
      answer = _composeAnswer(question);
    });
  }

  String _composeAnswer(String question) {
    final first = widget.record.cards.first;
    final last = widget.record.cards.last;
    final firstMeaning = _localizedCardMeaning(first, widget.language);
    final lastMeaning = _localizedCardMeaning(last, widget.language);
    final lastAdvice = _localizedCardAdvice(last, widget.language);
    final firstName = localizedTarotCardName(
      first.card.name,
      languageCode: widget.language.code,
    );
    final lastName = localizedTarotCardName(
      last.card.name,
      languageCode: widget.language.code,
    );
    final emotion = _emotionLabel(widget.record.emotion, widget.language);
    final lower = question.toLowerCase();
    final memory = _oracleMemory();
    final hiddenQuestion = lower.contains('not seeing') ||
        lower.contains('underestimating') ||
        lower.contains('risk') ||
        lower.contains('görm') ||
        lower.contains('riesgo') ||
        lower.contains('viendo') ||
        lower.contains('ocult') ||
        lower.contains('risco') ||
        lower.contains('vendo');
    final keyCardQuestion = lower.contains('which card') ||
        lower.contains('matter') ||
        lower.contains('hangi kart') ||
        lower.contains('önemli') ||
        lower.contains('qué carta') ||
        lower.contains('importa') ||
        lower.contains('qual carta');

    switch (widget.language) {
      case MysticLanguage.turkish:
        if (hiddenQuestion) {
          return '$firstName, görünmeyen kısmın şu olabileceğini söylüyor: '
              '$firstMeaning $lastAdvice ${emotion.toLowerCase()} duygusu bir '
              'ayrıntıyı diğerlerinden daha yüksek gösterebilir. Bildiklerini, '
              'korktuklarını ve umut ettiklerini ayır.$memory';
        }
        if (keyCardQuestion) {
          return '$lastName bu açılımın kapanış ağırlığını taşıyor. '
              '$lastMeaning Pratik daveti şu: $lastAdvice Bunun seçtiğin yolu '
              'nasıl desteklediğine dikkat et.$memory';
        }
        return '$firstName içine girdiğin enerjiyi, $lastName ise verebileceğin '
            'karşılığı gösteriyor. $lastAdvice Sonraki adımı küçük, '
            'gözlemlenebilir ve geri döndürülebilir tut; kartlar emir vermiyor, '
            'farklı bir bakış sunuyor.$memory';
      case MysticLanguage.spanish:
        if (hiddenQuestion) {
          return '$firstName sugiere que la parte oculta puede ser esta: '
              '$firstMeaning $lastAdvice Tu estado ${emotion.toLowerCase()} '
              'puede hacer que un detalle parezca más importante que los demás. '
              'Separa lo que sabes de lo que temes o esperas.$memory';
        }
        if (keyCardQuestion) {
          return '$lastName lleva el peso final de esta tirada. $lastMeaning '
              'Su invitación práctica es: $lastAdvice Observa cómo apoya tu '
              'camino de ${_localizedIntention(widget.intention, widget.language).toLowerCase()}.$memory';
        }
        return '$firstName describe la energía en la que estás entrando, mientras '
            'que $lastName señala la respuesta que tienes disponible. $lastAdvice '
            'Mantén el siguiente paso pequeño, observable y reversible; las '
            'cartas ofrecen una perspectiva, no una orden.$memory';
      case MysticLanguage.portugueseBrazil:
        if (hiddenQuestion) {
          return '$firstName sugere que a parte oculta pode ser esta: '
              '$firstMeaning $lastAdvice Seu estado ${emotion.toLowerCase()} '
              'pode fazer um detalhe parecer mais forte do que os outros. '
              'Separe o que você sabe do que teme ou espera.$memory';
        }
        if (keyCardQuestion) {
          return '$lastName carrega o peso final desta tiragem. $lastMeaning '
              'O convite prático é: $lastAdvice Observe como isso apoia seu '
              'caminho de ${_localizedIntention(widget.intention, widget.language).toLowerCase()}.$memory';
        }
        return '$firstName descreve a energia em que você está entrando, enquanto '
            '$lastName aponta para a resposta disponível. $lastAdvice Mantenha '
            'o próximo passo pequeno, observável e reversível; as cartas oferecem '
            'uma perspectiva, não uma ordem.$memory';
      default:
        if (hiddenQuestion) {
          return '$firstName suggests the hidden part may be this: $firstMeaning '
              '$lastAdvice Your ${emotion.toLowerCase()} state can make one detail '
              'feel louder than the rest, so separate what you know from what you '
              'fear or hope.$memory';
        }
        if (keyCardQuestion) {
          return '$lastName carries the closing weight of this spread. $lastMeaning '
              'Its practical invitation is simple: $lastAdvice Notice how that '
              'supports your ${_localizedIntention(widget.intention, widget.language).toLowerCase()} path.$memory';
        }
        return '$firstName describes the energy you are entering, while $lastName '
            'points toward the response available to you. $lastAdvice Keep the '
            'next step small, observable, and reversible; the cards are offering '
            'a lens, not issuing a command.$memory';
    }
  }

  String _oracleMemory() {
    final recent = widget.pastRecords.take(12).toList();
    if (recent.isEmpty) return '';
    final cardCounts = <String, int>{};
    final emotionCounts = <EmotionalState, int>{};
    for (final record in recent) {
      emotionCounts.update(
        record.emotion,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      for (final item in record.cards) {
        cardCounts.update(
          item.card.name,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    final recurring = cardCounts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final dominant = emotionCounts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final cardName = localizedTarotCardName(
      recurring.key,
      languageCode: widget.language.code,
    );
    final emotion = localizedEmotionLabel(
      dominant.key,
      languageCode: widget.language.code,
    ).toLowerCase();
    return switch (widget.language) {
      MysticLanguage.turkish =>
        ' Hafızandaki ${recent.length} okumada $cardName ${recurring.value} kez '
        'göründü ve baskın başlangıç duygun $emotion oldu. Bu bir kehanet değil; '
        'üzerinde düşünmeye değer tekrar eden bir iz.',
      MysticLanguage.spanish =>
        ' En ${recent.length} lecturas recordadas, $cardName apareció '
        '${recurring.value} veces y $emotion fue tu emoción inicial más común. '
        'No es una predicción, sino un hilo recurrente que merece atención.',
      MysticLanguage.portugueseBrazil =>
        ' Em ${recent.length} leituras lembradas, $cardName apareceu '
        '${recurring.value} vezes e $emotion foi sua emoção inicial mais comum. '
        'Isso não é uma previsão, mas um fio recorrente que merece atenção.',
      _ =>
        ' Across ${recent.length} remembered readings, $cardName appeared '
        '${recurring.value} times and $emotion was your most common starting '
        'emotion. That is not a prediction; it is a recurring thread worth '
        'examining.',
    };
  }

}

class _RitualRevealCard extends StatefulWidget {
  const _RitualRevealCard({
    required this.card,
    required this.deckStyle,
    required this.language,
    required this.delay,
  });
  final DrawnCard card;
  final DeckStyle deckStyle;
  final MysticLanguage language;
  final Duration delay;

  @override
  State<_RitualRevealCard> createState() => _RitualRevealCardState();
}

class _RitualRevealCardState extends State<_RitualRevealCard> {
  bool faceUp = false;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    _revealTimer = Timer(widget.delay, () {
      if (mounted) setState(() => faceUp = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: faceUp ? 1 : 0),
    duration: const Duration(milliseconds: 720),
    curve: Curves.easeInOutCubic,
    builder: (context, value, _) {
      final showFace = value > .5;
      final angle = value * pi;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, .0014)
          ..rotateY(angle),
        child: Transform.flip(
          flipX: showFace,
          child: TarotCardFace(
            drawn: showFace ? widget.card : null,
            displayName: localizedTarotCardName(
              widget.card.card.name,
              languageCode: widget.language.code,
            ),
            reversedLabel: mysticText(widget.language, 'Reversed', 'Ters'),
            style: widget.deckStyle,
          ),
        ),
      );
    },
  );
}

class _ReadingInProgress extends StatelessWidget {
  const _ReadingInProgress({required this.cardCount, required this.language});
  final int cardCount;
  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 10),
      const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: MysticColors.gold,
        ),
      ),
      const SizedBox(height: 15),
      Text(
        cardCount == 1
            ? mysticText(
                language,
                'Your card is finding its voice…',
                'Kartın kendi sesini buluyor…',
              )
            : mysticText(
                language,
                'The cards are forming a pattern…',
                'Kartlar bir örüntü oluşturuyor…',
              ),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 7),
      Text(
        mysticText(
          language,
          'Stay with your first feeling. The full interpretation appears after the final card turns.',
          'İlk hissettiğin şeyle kal. Son kart döndükten sonra yorumun tamamı görünecek.',
        ),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 24),
    ],
  );
}

String _readingKindTitle(ReadingKind kind, MysticLanguage language) {
  return localizedReadingKindTitle(
    kind,
    languageCode: language.code,
  );
}

String _emotionLabel(EmotionalState emotion, MysticLanguage language) {
  return localizedEmotionLabel(
    emotion,
    languageCode: language.code,
  );
}

String _localizedIntention(String value, MysticLanguage language) => switch (value) {
  'Love' => mysticText(language, 'Love', 'Aşk'),
  'Purpose' => mysticText(language, 'Purpose', 'Amaç'),
  'Healing' => mysticText(language, 'Healing', 'İyileşme'),
  _ => mysticText(language, 'Clarity', 'Netlik'),
};

String _localizedCardMeaning(DrawnCard drawn, MysticLanguage language) {
  return localizedTarotCardMeaning(
    drawn,
    languageCode: language.code,
  );
}

String _localizedCardAdvice(DrawnCard drawn, MysticLanguage language) {
  return localizedTarotCardAdvice(
    drawn,
    languageCode: language.code,
  );
}

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({
    required this.streak,
    required this.xp,
    required this.records,
    required this.discoveredCards,
    required this.completedRituals,
    required this.claimedRewards,
    required this.completedArcanaDays,
    required this.language,
    required this.onOpenDestiny,
    required this.onCompleteRitual,
    required this.onClaimReward,
    super.key,
  });
  final int streak;
  final int xp;
  final List<ReadingRecord> records;
  final Set<String> discoveredCards;
  final Set<String> completedRituals;
  final Set<int> claimedRewards;
  final Set<int> completedArcanaDays;
  final MysticLanguage language;
  final VoidCallback onOpenDestiny;
  final ValueChanged<String> onCompleteRitual;
  final ValueChanged<int> onClaimReward;

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController glow = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.xp ~/ 100 + 1;
    final levelProgress = (widget.xp % 100) / 100;
    return MysticBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 34),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mysticText(
                        widget.language,
                        'Your Mystic Path',
                        'Mistik Yolun',
                      ),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      mysticText(
                        widget.language,
                        'Your inner world becomes visible as you practice.',
                        'Pratik yaptıkça iç dünyan görünür hâle gelir.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: MysticColors.gold.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: MysticColors.gold.withValues(alpha: .35),
                  ),
                ),
                child: Text(
                  mysticText(widget.language, 'LEVEL $level', 'SEVİYE $level'),
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: MysticColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DestinyFlagshipCard(
            records: widget.records,
            completedDays: widget.completedArcanaDays,
            language: widget.language,
            onOpen: widget.onOpenDestiny,
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: glow,
            builder: (context, _) => Container(
              height: 245,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0xFF49347D), Color(0xFF171128)],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: MysticColors.lavender.withValues(
                    alpha: .18 + glow.value * .18,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: MysticColors.violet.withValues(
                      alpha: .12 + glow.value * .08,
                    ),
                    blurRadius: 32,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ConstellationPainter(
                        unlocked: widget.discoveredCards.length,
                        pulse: glow.value,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 17,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mysticText(
                            widget.language,
                            'INNER CONSTELLATION',
                            'İÇ TAKIMYILDIZIN',
                          ),
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            color: MysticColors.gold,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mysticText(
                            widget.language,
                            '${widget.discoveredCards.length} of 78 cards awakened',
                            '78 kartın ${widget.discoveredCards.length} tanesi uyandı',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 17,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: widget.discoveredCards.length / 78,
                        minHeight: 5,
                        backgroundColor: Colors.white10,
                        color: MysticColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _WeeklyMirror(records: widget.records, language: widget.language),
          const SizedBox(height: 18),
          _ArcanaVault(
            discoveredCards: widget.discoveredCards,
            language: widget.language,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .045),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: .08)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${widget.xp} XP',
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: MysticColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      mysticText(
                        widget.language,
                        '${(levelProgress * 100).round()}% to Level ${level + 1}',
                        '${level + 1}. seviyeye %${(levelProgress * 100).round()}',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: levelProgress,
                    minHeight: 7,
                    backgroundColor: Colors.white10,
                    color: MysticColors.violet,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Text(
                  mysticText(
                    widget.language,
                    'Today’s rituals',
                    'Bugünün ritüelleri',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${widget.completedRituals.length}/3',
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mysticText(
              widget.language,
              'Small actions turn insight into change. Each ritual grants +15 XP.',
              'Küçük eylemler içgörüyü değişime dönüştürür. Her ritüel +15 XP kazandırır.',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _ritual(
            context,
            'breathe',
            mysticText(
              widget.language,
              '60-second reset',
              '60 saniyelik sıfırlanma',
            ),
            mysticText(
              widget.language,
              'Breathe in for four, out for six.',
              'Dört saniye nefes al, altı saniye ver.',
            ),
            Icons.air,
          ),
          _ritual(
            context,
            'truth',
            mysticText(widget.language, 'Name the truth', 'Gerçeğin adını koy'),
            mysticText(
              widget.language,
              'Write one sentence you have been avoiding.',
              'Kaçındığın tek bir cümleyi yaz.',
            ),
            Icons.edit_note,
          ),
          _ritual(
            context,
            'action',
            mysticText(widget.language, 'Aligned action', 'Uyumlu eylem'),
            mysticText(
              widget.language,
              'Take the smallest reversible next step.',
              'Geri alınabilir en küçük sonraki adımı at.',
            ),
            Icons.bolt,
          ),
          const SizedBox(height: 15),
          Text(
            mysticText(widget.language, 'Mystic rewards', 'Mystic ödülleri'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            mysticText(
              widget.language,
              'Your practice unlocks cosmetic relics—never better answers.',
              'Pratiğin yalnızca kozmetik yadigârlar açar; daha “iyi” cevaplar değil.',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 145,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _reward(
                  context,
                  100,
                  mysticText(widget.language, 'Moon Dust', 'Ay Tozu'),
                  '✦',
                ),
                _reward(
                  context,
                  300,
                  mysticText(widget.language, 'Oracle Flame', 'Oracle Alevi'),
                  '◉',
                ),
                _reward(
                  context,
                  600,
                  mysticText(widget.language, 'Astral Crown', 'Astral Taç'),
                  '♛',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF33245C), Color(0xFF1A142D)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MysticColors.lavender.withValues(alpha: .2),
              ),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mysticText(
                          widget.language,
                          '${widget.streak}-day flame',
                          '${widget.streak} günlük alev',
                        ),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mysticText(
                          widget.language,
                          'Return tomorrow to keep your constellation alive.',
                          'Takımyıldızını canlı tutmak için yarın geri dön.',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reward(
    BuildContext context,
    int milestone,
    String title,
    String symbol,
  ) {
    final unlocked = widget.xp >= milestone;
    final claimed = widget.claimedRewards.contains(milestone);
    return Container(
      width: 132,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: unlocked
              ? const [Color(0xFF4B347E), Color(0xFF211735)]
              : const [Color(0xFF201A2C), Color(0xFF12101A)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: claimed ? MysticColors.gold : Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            claimed
                ? symbol
                : unlocked
                ? '◇'
                : '🔒',
            style: TextStyle(
              fontSize: 31,
              color: unlocked ? MysticColors.gold : MysticColors.muted,
            ),
          ),
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 28,
            child: TextButton(
              onPressed: unlocked && !claimed
                  ? () {
                      widget.onClaimReward(milestone);
                      setState(() {});
                    }
                  : null,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                claimed
                    ? mysticText(widget.language, 'CLAIMED', 'ALINDI')
                    : unlocked
                    ? mysticText(widget.language, 'CLAIM', 'AL')
                    : '$milestone XP',
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ritual(
    BuildContext context,
    String id,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final done = widget.completedRituals.contains(id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: done
            ? null
            : () {
                widget.onCompleteRitual(id);
                setState(() {});
              },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: done
                ? MysticColors.gold.withValues(alpha: .1)
                : Colors.white.withValues(alpha: .045),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: done
                  ? MysticColors.gold.withValues(alpha: .42)
                  : Colors.white.withValues(alpha: .08),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: done
                    ? MysticColors.gold
                    : MysticColors.violet.withValues(alpha: .35),
                child: Icon(
                  done ? Icons.check : icon,
                  color: done ? MysticColors.ink : MysticColors.lavender,
                  size: 20,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      done
                          ? mysticText(
                              widget.language,
                              'Ritual complete • +15 XP',
                              'Ritüel tamamlandı • +15 XP',
                            )
                          : subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (!done)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: MysticColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcanaVault extends StatelessWidget {
  const _ArcanaVault({required this.discoveredCards, required this.language});
  final Set<String> discoveredCards;
  final MysticLanguage language;

  @override
  Widget build(BuildContext context) {
    final unlocked = tarotDeck
        .where((card) => discoveredCards.contains(card.name))
        .toList();
    final locked = tarotDeck
        .where((card) => !discoveredCards.contains(card.name))
        .toList();
    final preview = [...unlocked, ...locked].take(3).toList();
    final nextMilestone = discoveredCards.length >= 78
        ? 78
        : min(78, ((discoveredCards.length ~/ 10) + 1) * 10);
    return InkWell(
      onTap: () => _openVault(context),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF251A3C), Color(0xFF12101C)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  mysticText(language, 'ARCANA VAULT', 'ARKANA KASASI'),
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: MysticColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.35,
                  ),
                ),
                const Spacer(),
                Text(
                  '${discoveredCards.length}/78',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: MysticColors.lavender,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: MysticColors.muted,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              discoveredCards.isEmpty
                  ? mysticText(
                      language,
                      'Every reading can awaken a card.',
                      'Her okuma bir kartı uyandırabilir.',
                    )
                  : discoveredCards.length == 78
                  ? mysticText(
                      language,
                      'The entire deck has answered you.',
                      'Tüm deste sana cevap verdi.',
                    )
                  : mysticText(
                      language,
                      '${nextMilestone - discoveredCards.length} more cards until your next collection milestone.',
                      'Sonraki koleksiyon eşiğine ${nextMilestone - discoveredCards.length} kart kaldı.',
                    ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                for (var i = 0; i < preview.length; i++) ...[
                  if (i > 0) const SizedBox(width: 9),
                  Expanded(
                    child: _previewCard(
                      preview[i],
                      discoveredCards.contains(preview[i].name),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewCard(TarotCardData card, bool unlocked) {
    final color = _cardRarityColor(card);
    return Container(
      height: 112,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        gradient: unlocked
            ? LinearGradient(
                colors: [color.withValues(alpha: .25), const Color(0xFF191323)],
              )
            : const LinearGradient(
                colors: [Color(0xFF1C1824), Color(0xFF100E16)],
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked ? color.withValues(alpha: .55) : Colors.white10,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            unlocked ? card.symbol : '◈',
            style: TextStyle(
              fontSize: 28,
              color: unlocked ? color : Colors.white24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            unlocked
                ? localizedTarotCardName(
                    card.name,
                    languageCode: language.code,
                  )
                : mysticText(language, 'Undiscovered', 'Keşfedilmedi'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Arial',
              color: unlocked ? MysticColors.mist : MysticColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _openVault(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: .92,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF14101F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mysticText(
                                language,
                                'Your Arcana Vault',
                                'Arkana Kasan',
                              ),
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mysticText(
                                language,
                                '${discoveredCards.length} awakened • ${78 - discoveredCards.length} still hidden',
                                '${discoveredCards.length} uyandı • ${78 - discoveredCards.length} hâlâ gizli',
                              ),
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: MysticColors.gold.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${((discoveredCards.length / 78) * 100).round()}%',
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            color: MysticColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: discoveredCards.length / 78,
                      minHeight: 6,
                      backgroundColor: Colors.white10,
                      color: MysticColors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: .69,
                          crossAxisSpacing: 9,
                          mainAxisSpacing: 9,
                        ),
                    itemCount: tarotDeck.length,
                    itemBuilder: (_, index) {
                      final card = tarotDeck[index];
                      final unlocked = discoveredCards.contains(card.name);
                      return _vaultCard(sheetContext, card, unlocked);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _vaultCard(BuildContext context, TarotCardData card, bool unlocked) {
    final color = _cardRarityColor(card);
    return InkWell(
      onTap: unlocked ? () => _showCardDetail(context, card) : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          gradient: unlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: .24),
                    const Color(0xFF181222),
                  ],
                )
              : const LinearGradient(
                  colors: [Color(0xFF1B1722), Color(0xFF0F0D14)],
                ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: unlocked ? color.withValues(alpha: .55) : Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                unlocked ? card.number : '—',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: unlocked ? color : Colors.white24,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              unlocked ? card.symbol : '?',
              style: TextStyle(
                fontSize: 30,
                color: unlocked ? color : Colors.white24,
              ),
            ),
            const Spacer(),
            Text(
              unlocked
                  ? localizedTarotCardName(
                      card.name,
                      languageCode: language.code,
                    )
                  : mysticText(language, 'Locked', 'Kilitli'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Arial',
                color: unlocked ? MysticColors.mist : MysticColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              unlocked
                  ? _localizedRarity(card).toUpperCase()
                  : mysticText(language, 'UNDISCOVERED', 'KEŞFEDİLMEDİ'),
              style: TextStyle(
                fontFamily: 'Arial',
                color: unlocked ? color : Colors.white24,
                fontSize: 7,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDetail(BuildContext context, TarotCardData card) {
    final color = _cardRarityColor(card);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF372451), Color(0xFF17111F)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: color.withValues(alpha: .6)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Container(
                  width: 118,
                  height: 176,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: .35),
                        const Color(0xFF17111F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withValues(alpha: .75)),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: .2),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.number,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        card.symbol,
                        style: TextStyle(fontSize: 48, color: color),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _localizedRarity(card).toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  localizedTarotCardName(
                    card.name,
                    languageCode: language.code,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                _meaningBlock(
                  dialogContext,
                  mysticText(language, 'LIGHT', 'IŞIK'),
                  _localizedCardMeaning(DrawnCard(card, false), language),
                  MysticColors.gold,
                ),
                const SizedBox(height: 10),
                _meaningBlock(
                  dialogContext,
                  mysticText(language, 'SHADOW', 'GÖLGE'),
                  _localizedCardMeaning(DrawnCard(card, true), language),
                  MysticColors.lavender,
                ),
                const SizedBox(height: 10),
                _meaningBlock(
                  dialogContext,
                  mysticText(language, 'ALIGNED ACTION', 'UYUMLU EYLEM'),
                  _localizedCardAdvice(DrawnCard(card, false), language),
                  color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _meaningBlock(
    BuildContext context,
    String label,
    String text,
    Color color,
  ) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .045),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: color.withValues(alpha: .16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Arial',
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: MysticColors.mist),
        ),
      ],
    ),
  );

  String _localizedRarity(TarotCardData card) => switch (_cardRarity(card)) {
    'Legendary' => mysticText(language, 'Legendary', 'Efsanevi'),
    'Epic' => mysticText(language, 'Epic', 'Destansı'),
    'Rare' => mysticText(language, 'Rare', 'Nadir'),
    _ => mysticText(language, 'Common', 'Yaygın'),
  };
}

class _WeeklyMirror extends StatelessWidget {
  const _WeeklyMirror({required this.records, required this.language});
  final List<ReadingRecord> records;
  final MysticLanguage language;

  @override
  Widget build(BuildContext context) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent = records
        .where((record) => record.createdAt.isAfter(weekAgo))
        .toList();
    final emotion = _dominantEmotion(recent);
    final card = _mostFrequentCard(recent);
    return InkWell(
      onTap: () => _showWrapped(context, recent, emotion, card),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7550BA), Color(0xFF2A1D48)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: MysticColors.lavender.withValues(alpha: .3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Text(
                recent.isEmpty ? '☾' : emotion.symbol,
                style: const TextStyle(fontSize: 26, color: MysticColors.gold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mysticText(
                      language,
                      'YOUR WEEKLY MYSTIC WRAPPED',
                      'HAFTALIK MYSTIC ÖZETİN',
                    ),
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: MysticColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recent.isEmpty
                        ? mysticText(
                            language,
                            'Your story is waiting for its first signal.',
                            'Hikâyen ilk sinyalini bekliyor.',
                          )
                        : mysticText(
                            language,
                            '${localizedEmotionLabel(emotion, languageCode: language.code)} led your week • ${recent.length} reflections',
                            '${localizedEmotionLabel(emotion, turkish: true)} haftana yön verdi • ${recent.length} yansıma',
                          ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: MysticColors.mist),
          ],
        ),
      ),
    );
  }

  EmotionalState _dominantEmotion(List<ReadingRecord> recent) {
    if (recent.isEmpty) return EmotionalState.uncertain;
    final counts = <EmotionalState, int>{};
    for (final record in recent) {
      counts.update(record.emotion, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _mostFrequentCard(List<ReadingRecord> recent) {
    final counts = <String, int>{};
    for (final record in recent) {
      for (final card in record.cards) {
        counts.update(card.card.name, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return counts.isEmpty
        ? ''
        : counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  void _showWrapped(
    BuildContext context,
    List<ReadingRecord> recent,
    EmotionalState emotion,
    String card,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF171128),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                mysticText(language, '✦  MYSTIC WRAPPED', '✦  MYSTIC ÖZETİ'),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                recent.isEmpty
                    ? mysticText(
                        language,
                        'Your first pattern begins with one honest reading.',
                        'İlk örüntün dürüst bir okumayla başlar.',
                      )
                    : mysticText(
                        language,
                        '${emotion.symbol} ${localizedEmotionLabel(emotion, languageCode: language.code)} was your dominant inner weather.',
                        '${emotion.symbol} ${localizedEmotionLabel(emotion, turkish: true)} baskın iç havan oldu.',
                      ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  _wrappedStat(
                    context,
                    '${recent.length}',
                    mysticText(language, 'REFLECTIONS', 'YANSIMALAR'),
                  ),
                  const SizedBox(width: 10),
                  _wrappedStat(
                    context,
                    card.isEmpty
                        ? mysticText(language, 'No card yet', 'Henüz kart yok')
                        : localizedTarotCardName(
                            card,
                            languageCode: language.code,
                          ),
                    mysticText(language, 'REPEATING CARD', 'TEKRARLAYAN KART'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                recent.isEmpty
                    ? mysticText(
                        language,
                        'Complete a reading and return here to watch your emotional patterns become visible.',
                        'Bir okuma tamamla; duygusal örüntülerinin görünür oluşunu izlemek için buraya dön.',
                      )
                    : mysticText(
                        language,
                        'Your invitation: notice where ${localizedEmotionLabel(emotion, languageCode: language.code).toLowerCase()} energy protected you—and where it quietly chose for you.',
                        'Davetin: ${localizedEmotionLabel(emotion, turkish: true).toLowerCase()} enerjisinin seni nerede koruduğunu ve nerede sessizce senin yerine seçim yaptığını fark et.',
                      ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              GoldButton(
                label: recent.isEmpty
                    ? mysticText(
                        language,
                        'Begin my first reading',
                        'İlk okumamı başlat',
                      )
                    : mysticText(
                        language,
                        'Keep building my pattern',
                        'Örüntümü geliştirmeyi sürdür',
                      ),
                onPressed: () => Navigator.pop(context),
                icon: Icons.auto_awesome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrappedStat(BuildContext context, String value, String label) =>
      Expanded(
        child: Container(
          height: 104,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter({required this.unlocked, required this.pulse});
  final int unlocked;
  final double pulse;
  static const points = <Offset>[
    Offset(.12, .65),
    Offset(.24, .38),
    Offset(.39, .58),
    Offset(.53, .29),
    Offset(.67, .52),
    Offset(.82, .25),
    Offset(.9, .62),
    Offset(.58, .76),
    Offset(.31, .79),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final active = unlocked.clamp(0, points.length);
    final line = Paint()
      ..color = MysticColors.lavender.withValues(alpha: .18 + pulse * .1)
      ..strokeWidth = 1.2;
    for (var i = 1; i < active; i++) {
      canvas.drawLine(_at(points[i - 1], size), _at(points[i], size), line);
    }
    for (var i = 0; i < points.length; i++) {
      final on = i < active;
      final point = _at(points[i], size);
      if (on) {
        canvas.drawCircle(
          point,
          7 + pulse * 3,
          Paint()..color = MysticColors.gold.withValues(alpha: .08),
        );
      }
      canvas.drawCircle(
        point,
        on ? 2.8 : 1.5,
        Paint()
          ..color = on
              ? MysticColors.gold
              : Colors.white.withValues(alpha: .15),
      );
    }
  }

  Offset _at(Offset value, Size size) =>
      Offset(value.dx * size.width, value.dy * size.height);
  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) =>
      oldDelegate.unlocked != unlocked || oldDelegate.pulse != pulse;
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({required this.records, super.key});
  final List<ReadingRecord> records;
  @override
  Widget build(BuildContext context) => MysticBackground(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your journal',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'A record of the patterns you are learning to see.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          Expanded(
            child: records.isEmpty
                ? const _EmptyJournal()
                : ListView.separated(
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final item = records[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .055),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .08),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: MysticColors.violet.withValues(
                                alpha: .35,
                              ),
                              child: Text(
                                item.emotion.symbol,
                                style: const TextStyle(
                                  color: MysticColors.gold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.kind.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.emotion.label} • 24h Mirror pending',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: MysticColors.muted,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyJournal extends StatelessWidget {
  const _EmptyJournal();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '☾',
          style: TextStyle(fontSize: 58, color: MysticColors.gold),
        ),
        const SizedBox(height: 16),
        Text(
          'Your story begins here',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 7),
        Text(
          'Save a reading and it will appear in your private journal.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.isPlus,
    required this.userName,
    required this.intention,
    required this.streak,
    required this.xp,
    required this.readings,
    required this.discovered,
    required this.relics,
    required this.records,
    required this.completedArcanaDays,
    required this.deckStyle,
    required this.language,
    required this.onSelectLanguage,
    required this.onSelectDeckStyle,
    required this.onUpdateProfile,
    required this.onDeleteData,
    required this.onPremium,
    super.key,
  });
  final bool isPlus;
  final String userName;
  final String intention;
  final int streak;
  final int xp;
  final int readings;
  final int discovered;
  final int relics;
  final List<ReadingRecord> records;
  final int completedArcanaDays;
  final DeckStyle deckStyle;
  final MysticLanguage language;
  final ValueChanged<MysticLanguage> onSelectLanguage;
  final ValueChanged<DeckStyle> onSelectDeckStyle;
  final void Function(String name, String intention) onUpdateProfile;
  final VoidCallback onDeleteData;
  final VoidCallback onPremium;

  @override
  Widget build(BuildContext context) {
    final level = xp ~/ 100 + 1;
    final progress = (xp % 100) / 100;
    final identity = const MysticIdentityEngine().analyze(
      records: records,
      streak: streak,
      completedArcanaDays: completedArcanaDays,
      language: language.appLanguage,
    );
    final badges = <(String, String, bool, String)>[
      (
        mysticText(language, 'First Signal', 'İlk İşaret'),
        '✦',
        readings >= 1,
        mysticText(language, 'Save 1 reading', '1 okuma kaydet'),
      ),
      (
        mysticText(language, 'Flame Keeper', 'Alev Koruyucusu'),
        '🔥',
        streak >= 3,
        mysticText(language, 'Reach a 3-day streak', '3 günlük seriye ulaş'),
      ),
      (
        mysticText(language, 'Arcana Seeker', 'Arkana Arayıcısı'),
        '◈',
        discovered >= 10,
        mysticText(language, 'Awaken 10 cards', '10 kartı uyandır'),
      ),
      (
        mysticText(language, 'Relic Keeper', 'Yadigâr Koruyucusu'),
        '♛',
        relics >= 1,
        mysticText(language, 'Claim an XP relic', 'Bir XP yadigârı kazan'),
      ),
    ];
    final settings = <(String, String)>[
      (
        'Reading preferences',
        mysticText(language, 'Reading preferences', 'Okuma tercihleri'),
      ),
      (
        'Privacy & data',
        mysticText(language, 'Privacy & data', 'Gizlilik ve veriler'),
      ),
      (
        'Help and support',
        mysticText(language, 'Help and support', 'Yardım ve destek'),
      ),
    ];
    return MysticBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        children: [
          Text(
            mysticText(language, 'Your space', 'Senin alanın'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment(0, -.9),
                radius: 1.35,
                colors: [Color(0xFF4B3471), Color(0xFF191326)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: MysticColors.lavender.withValues(alpha: .24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B63D6), Color(0xFF3B285F)],
                    ),
                    border: Border.all(
                      color: MysticColors.gold.withValues(alpha: .55),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MysticColors.violet.withValues(alpha: .3),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: const Text(
                    '☾',
                    style: TextStyle(fontSize: 34, color: MysticColors.gold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName.isEmpty ? _titleForLevel(level) : userName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_titleForLevel(level).toUpperCase()} • ${_intentionLabel(intention).toUpperCase()} • ${mysticText(language, 'LEVEL', 'SEVİYE')} $level',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: MysticColors.gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat(
                      '$streak',
                      mysticText(language, 'day streak', 'günlük seri'),
                    ),
                    _stat(
                      '$readings',
                      mysticText(language, 'readings', 'okuma'),
                    ),
                    _stat(
                      '$discovered',
                      mysticText(language, 'arcana', 'arkana'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      '$xp XP',
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: MysticColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      mysticText(
                        language,
                        '${100 - (xp % 100)} XP to level ${level + 1}',
                        '${level + 1}. seviyeye ${100 - (xp % 100)} XP',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: MysticColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white10,
                    color: MysticColors.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _mysticSoulCard(context, identity),
          const SizedBox(height: 22),
          Row(
            children: [
              Text(
                mysticText(
                  language,
                  'Mystic achievements',
                  'Mystic başarımları',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Text(
                '${badges.where((badge) => badge.$3).length}/${badges.length}',
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mysticText(
              language,
              'Your practice leaves permanent marks on your path.',
              'Pratiğin yolunda kalıcı izler bırakır.',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.48,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: badges
                .map(
                  (badge) =>
                      _badge(context, badge.$1, badge.$2, badge.$3, badge.$4),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text(
            mysticText(language, 'Your tarot deck', 'Tarot desten'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            mysticText(
              language,
              'Choose the visual energy that follows every reading.',
              'Her okumaya eşlik edecek görsel enerjiyi seç.',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 178,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: DeckStyle.values
                  .map((style) => _deckOption(context, style))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onPremium,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6847B7), Color(0xFF312057)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Text(
                    isPlus ? '✓' : '✦',
                    style: const TextStyle(
                      fontSize: 28,
                      color: MysticColors.gold,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPlus
                              ? mysticText(
                                  language,
                                  'Mystic Plus active',
                                  'Mystic Plus etkin',
                                )
                              : mysticText(
                                  language,
                                  'Unlock Mystic Plus',
                                  'Mystic Plus’ı aç',
                                ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPlus
                              ? mysticText(
                                  language,
                                  'View plan and manage subscription',
                                  'Planını gör ve aboneliğini yönet',
                                )
                              : mysticText(
                                  language,
                                  'Go deeper with unlimited readings',
                                  'Sınırsız okumalarla daha derine in',
                                ),
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            color: MysticColors.lavender,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SoulProfileScreen(
                  initialName: userName,
                  initialIntention: intention,
                  language: language,
                  onSave: onUpdateProfile,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: const Icon(Icons.fingerprint, color: MysticColors.gold),
            title: Text(
              mysticText(language, 'Soul profile', 'Ruh profili'),
              style: const TextStyle(fontFamily: 'Arial'),
            ),
            subtitle: Text(
              userName.isEmpty
                  ? _intentionLabel(intention)
                  : '$userName • ${_intentionLabel(intention)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            onTap: () => _chooseLanguage(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: const Icon(Icons.language, color: MysticColors.gold),
            title: Text(
              mysticText(language, 'Language', 'Dil'),
              style: const TextStyle(fontFamily: 'Arial'),
            ),
            subtitle: Text(
              language.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
          ...settings.map(
            (item) => ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MysticSettingsScreen(
                    section: item.$1,
                    title: item.$2,
                    language: language,
                    records: records,
                    onDeleteData: onDeleteData,
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(
                Icons.auto_awesome_outlined,
                color: MysticColors.lavender,
              ),
              title: Text(item.$2, style: const TextStyle(fontFamily: 'Arial')),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mysticSoulCard(
    BuildContext context,
    MysticIdentitySnapshot identity,
  ) {
    final appLanguage = language.appLanguage;
    final title = localized(
      appLanguage,
      english: 'Your Mystic Soul',
      spanish: 'Tu Alma Mística',
      french: 'Votre Âme Mystique',
      portugueseBrazil: 'Sua Alma Mística',
      turkish: 'Mistik Ruhun',
      italian: 'La Tua Anima Mistica',
      german: 'Deine Mystische Seele',
    );
    final action = localized(
      appLanguage,
      english: 'Explore identity',
      spanish: 'Explorar identidad',
      french: 'Explorer l’identité',
      portugueseBrazil: 'Explorar identidade',
      turkish: 'Kimliğini keşfet',
      italian: 'Esplora identità',
      german: 'Identität erkunden',
    );
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MysticIdentityScreen(
            snapshot: identity,
            language: appLanguage,
            onContinueJourney: () => Navigator.pop(context),
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF744CB0), Color(0xFF2A1B43), Color(0xFF15101F)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .4)),
          boxShadow: [
            BoxShadow(
              color: MysticColors.violet.withValues(alpha: .18),
              blurRadius: 28,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: .2),
                border: Border.all(
                  color: MysticColors.gold.withValues(alpha: .55),
                ),
              ),
              child: const Text(
                '◉',
                style: TextStyle(fontSize: 29, color: MysticColors.gold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: MysticColors.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    identity.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    identity.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Text(
                        '$action • ${identity.confidence}%',
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          color: MysticColors.lavender,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: MysticColors.gold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _chooseLanguage(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF171128),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                mysticText(language, 'Choose language', 'Dil seç'),
                style: Theme.of(sheetContext).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                mysticText(
                  language,
                  'Mystic is fully available in English, Turkish, Spanish, French, and Brazilian Portuguese.',
                  'Mystic bu sürümde İngilizce, Türkçe, İspanyolca, Fransızca ve Brezilya Portekizcesi olarak eksiksiz kullanılabilir.',
                ),
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              ...launchLanguages.map(
                (item) => ListTile(
                  onTap: () {
                    onSelectLanguage(item);
                    Navigator.pop(sheetContext);
                  },
                  leading: Icon(
                    item == language
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: item == language
                        ? MysticColors.gold
                        : MysticColors.muted,
                  ),
                  title: Text(item.label),
                  subtitle: Text(item.code),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleForLevel(int level) {
    if (level >= 10) return mysticText(language, 'Astral Sage', 'Astral Bilge');
    if (level >= 6)
      return mysticText(language, 'Mystic Oracle', 'Mystic Kâhin');
    if (level >= 3)
      return mysticText(language, 'Arcana Seeker', 'Arkana Arayıcısı');
    return mysticText(language, 'Mystic Initiate', 'Mystic Yolcusu');
  }

  String _intentionLabel(String value) => switch (value) {
    'Love' => mysticText(language, 'Love path', 'Aşk yolu'),
    'Purpose' => mysticText(language, 'Purpose path', 'Amaç yolu'),
    'Healing' => mysticText(language, 'Healing path', 'İyileşme yolu'),
    _ => mysticText(language, 'Clarity path', 'Netlik yolu'),
  };

  Widget _badge(
    BuildContext context,
    String title,
    String symbol,
    bool unlocked,
    String goal,
  ) => AnimatedContainer(
    duration: const Duration(milliseconds: 350),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      gradient: unlocked
          ? const LinearGradient(colors: [Color(0xFF4A326D), Color(0xFF21172F)])
          : const LinearGradient(
              colors: [Color(0xFF1D1924), Color(0xFF121017)],
            ),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(
        color: unlocked
            ? MysticColors.gold.withValues(alpha: .45)
            : Colors.white10,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: unlocked
                ? MysticColors.gold.withValues(alpha: .14)
                : Colors.white.withValues(alpha: .035),
            shape: BoxShape.circle,
          ),
          child: Text(
            unlocked ? symbol : '🔒',
            style: TextStyle(
              fontSize: unlocked ? 21 : 15,
              color: MysticColors.gold,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: unlocked ? MysticColors.mist : MysticColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unlocked ? mysticText(language, 'UNLOCKED', 'AÇILDI') : goal,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: unlocked ? MysticColors.gold : MysticColors.muted,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: unlocked ? .7 : 0,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _deckOption(BuildContext context, DeckStyle style) {
    final unlocked =
        style == DeckStyle.midnight ||
        (style == DeckStyle.solarGold && discovered >= 10) ||
        (style == DeckStyle.bloodMoon && xp >= 400);
    final active = deckStyle == style;
    final accent = _deckAccent(style);
    return InkWell(
      onTap: unlocked ? () => onSelectDeckStyle(style) : null,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: 132,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: unlocked
                ? _deckColors(style)
                : const [Color(0xFF1C1822), Color(0xFF100E14)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? accent
                : unlocked
                ? accent.withValues(alpha: .35)
                : Colors.white10,
            width: active ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                active
                    ? Icons.check_circle
                    : unlocked
                    ? Icons.radio_button_unchecked
                    : Icons.lock,
                color: active ? accent : MysticColors.muted,
                size: 16,
              ),
            ),
            Text(
              unlocked ? style.symbol : '◈',
              style: TextStyle(
                fontSize: 34,
                color: unlocked ? accent : Colors.white24,
              ),
            ),
            const Spacer(),
            Text(
              _deckLabel(style),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Arial',
                color: unlocked ? MysticColors.mist : MysticColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              active
                  ? mysticText(language, 'ACTIVE DECK', 'AKTİF DESTE')
                  : _deckSubtitle(style),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Arial',
                color: active ? accent : MysticColors.muted,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: active ? .6 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _deckAccent(DeckStyle style) {
    switch (style) {
      case DeckStyle.solarGold:
        return const Color(0xFFFFD76A);
      case DeckStyle.bloodMoon:
        return const Color(0xFFFF8090);
      case DeckStyle.midnight:
        return MysticColors.lavender;
    }
  }

  List<Color> _deckColors(DeckStyle style) {
    switch (style) {
      case DeckStyle.solarGold:
        return const [Color(0xFF5D4215), Color(0xFF191106)];
      case DeckStyle.bloodMoon:
        return const [Color(0xFF581824), Color(0xFF19090D)];
      case DeckStyle.midnight:
        return const [Color(0xFF4A326D), Color(0xFF21172F)];
    }
  }

  String _deckLabel(DeckStyle style) => switch (style) {
    DeckStyle.solarGold => mysticText(language, 'Solar Gold', 'Güneş Altını'),
    DeckStyle.bloodMoon => mysticText(language, 'Blood Moon', 'Kanlı Ay'),
    DeckStyle.midnight => mysticText(language, 'Midnight', 'Gece Yarısı'),
  };

  String _deckSubtitle(DeckStyle style) => switch (style) {
    DeckStyle.solarGold => mysticText(
      language,
      style.subtitle,
      '10 kart keşfederek aç',
    ),
    DeckStyle.bloodMoon => mysticText(
      language,
      style.subtitle,
      '400 XP ile aç',
    ),
    DeckStyle.midnight => mysticText(
      language,
      style.subtitle,
      'Klasik Mystic destesi',
    ),
  };

  Widget _stat(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 20,
          color: MysticColors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'Arial',
          color: MysticColors.muted,
          fontSize: 12,
        ),
      ),
    ],
  );
}

class SoulProfileScreen extends StatefulWidget {
  const SoulProfileScreen({
    required this.initialName,
    required this.initialIntention,
    required this.language,
    required this.onSave,
    super.key,
  });
  final String initialName;
  final String initialIntention;
  final MysticLanguage language;
  final void Function(String name, String intention) onSave;

  @override
  State<SoulProfileScreen> createState() => _SoulProfileScreenState();
}

class _SoulProfileScreenState extends State<SoulProfileScreen> {
  late final TextEditingController name;
  late String intention;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.initialName);
    intention = widget.initialIntention;
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const choices = ['Clarity', 'Love', 'Purpose', 'Healing'];
    return Scaffold(
      appBar: AppBar(
        title: Text(mysticText(widget.language, 'Soul profile', 'Ruh profili')),
      ),
      body: MysticBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
          children: [
            const Center(
              child: Text(
                '◉',
                style: TextStyle(fontSize: 58, color: MysticColors.gold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              mysticText(
                widget.language,
                'Make Mystic yours',
                'Mystic’i kendine göre şekillendir',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              mysticText(
                widget.language,
                'Your name and intention shape the language, memory, and guidance around every reading.',
                'Adın ve niyetin her okumadaki dili, hafızayı ve rehberliği şekillendirir.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: name,
              maxLength: 18,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: mysticText(widget.language, 'Your name', 'Adın'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              mysticText(widget.language, 'YOUR CURRENT PATH', 'ŞU ANKİ YOLUN'),
              style: const TextStyle(
                fontFamily: 'Arial',
                color: MysticColors.lavender,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: choices
                  .map(
                    (choice) => ChoiceChip(
                      label: Text(_choiceLabel(choice)),
                      selected: intention == choice,
                      onSelected: (_) => setState(() => intention = choice),
                      selectedColor: MysticColors.violet,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 30),
            GoldButton(
              label: mysticText(
                widget.language,
                'Save my soul profile',
                'Ruh profilimi kaydet',
              ),
              icon: Icons.auto_awesome,
              onPressed: () {
                widget.onSave(name.text, intention);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            Text(
              mysticText(
                widget.language,
                'Stored privately on this device.',
                'Bu cihazda özel olarak saklanır.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Arial',
                color: MysticColors.muted,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _choiceLabel(String value) => switch (value) {
    'Love' => mysticText(widget.language, 'Love', 'Aşk'),
    'Purpose' => mysticText(widget.language, 'Purpose', 'Amaç'),
    'Healing' => mysticText(widget.language, 'Healing', 'İyileşme'),
    _ => mysticText(widget.language, 'Clarity', 'Netlik'),
  };
}

class MysticSettingsScreen extends StatefulWidget {
  const MysticSettingsScreen({
    required this.section,
    required this.title,
    required this.language,
    required this.records,
    required this.onDeleteData,
    super.key,
  });
  final String section;
  final String title;
  final MysticLanguage language;
  final List<ReadingRecord> records;
  final VoidCallback onDeleteData;

  @override
  State<MysticSettingsScreen> createState() => _MysticSettingsScreenState();
}

class _MysticSettingsScreenState extends State<MysticSettingsScreen> {
  bool allowReversals = true;
  bool soundEffectsEnabled = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(() {
        allowReversals = prefs.getBool('allow_reversals') ?? true;
        soundEffectsEnabled = prefs.getBool('sound_effects') ?? true;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: MysticBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: _content(context),
      ),
    ),
  );

  List<Widget> _content(BuildContext context) {
    if (widget.section == 'Reading preferences') {
      return [
        _intro(
          context,
          t('Shape every reading', 'Her okumayı şekillendir'),
          t(
            'Mystic should adapt to your practice—not ask you to adapt to it.',
            'Mystic senin pratiğine uyum sağlamalı; senden kendisine uymanı istememeli.',
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t('Allow reversed cards', 'Ters kartlara izin ver')),
          subtitle: Text(
            t(
              'Adds shadow meanings to approximately one in four cards.',
              'Yaklaşık her dört karttan birine gölge anlamı ekler.',
            ),
          ),
          value: allowReversals,
          activeThumbColor: MysticColors.gold,
          onChanged: (value) async {
            setState(() => allowReversals = value);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('allow_reversals', value);
          },
        ),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t('Ritual sound effects', 'Ritüel ses efektleri')),
          subtitle: Text(
            t(
              'Soft audio cues for selection, sealing, and reveal.',
              'Seçim, mühürleme ve açılış için yumuşak sesler.',
            ),
          ),
          value: soundEffectsEnabled,
          activeThumbColor: MysticColors.gold,
          onChanged: (value) async {
            setState(() => soundEffectsEnabled = value);
            await MysticSoundscape.instance.setEnabled(value);
          },
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.psychology_alt_outlined,
            color: MysticColors.lavender,
          ),
          title: Text(t('Reflection-first guidance', 'Önce düşünme yaklaşımı')),
          subtitle: Text(
            t(
              'Readings remain grounded invitations—not certainty, diagnosis, or professional advice.',
              'Okumalar kesinlik, teşhis veya profesyonel tavsiye değil; gerçekçi düşünme davetleridir.',
            ),
          ),
        ),
      ];
    }
    if (widget.section == 'Privacy & data') {
      return [
        _intro(
          context,
          t('Your inner world stays yours', 'İç dünyan sana aittir'),
          t(
            'This release keeps your journal and progress locally on this device. No questions are sold to advertisers.',
            'Bu sürüm günlüğünü ve ilerlemeni bu cihazda yerel olarak saklar. Soruların reklamverenlere satılmaz.',
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.download_outlined,
            color: MysticColors.gold,
          ),
          title: Text(t('Export my journal', 'Günlüğümü dışa aktar')),
          subtitle: Text(
            t(
              '${widget.records.length} saved readings',
              '${widget.records.length} kayıtlı okuma',
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _exportJournal,
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.delete_outline, color: Color(0xFFFF8090)),
          title: Text(t('Delete all Mystic data', 'Tüm Mystic verilerini sil')),
          subtitle: Text(
            t(
              'Permanently removes local journal, XP, streak, and settings.',
              'Yerel günlüğü, XP’yi, seriyi ve ayarları kalıcı olarak kaldırır.',
            ),
          ),
          onTap: _confirmDelete,
        ),
        const SizedBox(height: 14),
        _notice(
          t('Entertainment & reflection', 'Eğlence ve öz değerlendirme'),
          t(
            'Mystic Tarot is designed for personal reflection and entertainment. It does not provide medical, legal, financial, or mental-health advice.',
            'Mystic Tarot kişisel düşünme ve eğlence için tasarlanmıştır. Tıbbi, hukuki, finansal veya ruh sağlığı tavsiyesi vermez.',
          ),
        ),
      ];
    }
    return [
      _intro(
        context,
        t('We are here to help', 'Yardım etmek için buradayız'),
        t(
          'Clear answers before you begin your next ritual.',
          'Sonraki ritüeline başlamadan önce net cevaplar.',
        ),
      ),
      _faq(
        t('Does Mystic predict the future?', 'Mystic geleceği tahmin eder mi?'),
        t(
          'No. It uses tarot symbolism as a structured mirror for reflection and possible perspectives.',
          'Hayır. Tarot sembollerini düşünme ve olası bakış açıları için yapılandırılmış bir ayna olarak kullanır.',
        ),
      ),
      _faq(
        t('Can I cancel Mystic Plus?', 'Mystic Plus’ı iptal edebilir miyim?'),
        t(
          'When native subscriptions launch, they can be managed and cancelled through Apple or Google account settings. The web release does not process payments.',
          'Yerel abonelikler başladığında Apple veya Google hesap ayarlarından yönetilip iptal edilebilir. Web sürümü ödeme işlemez.',
        ),
      ),
      _faq(
        t('How do I restore a purchase?', 'Satın almayı nasıl geri yüklerim?'),
        t(
          'Restore becomes available with native Apple and Google subscriptions. The current web release does not process or store purchases.',
          'Geri yükleme, yerel Apple ve Google abonelikleriyle kullanılabilir. Mevcut web sürümü satın alma işlemez veya saklamaz.',
        ),
      ),
      _faq(
        t('Is my journal private?', 'Günlüğüm özel mi?'),
        t(
          'Yes. The current release stores it locally on this device and does not transmit journal content to us. You can export or delete it at any time.',
          'Evet. Mevcut sürüm günlüğünü bu cihazda yerel olarak saklar ve içeriğini bize iletmez. İstediğin zaman dışa aktarabilir veya silebilirsin.',
        ),
      ),
      const SizedBox(height: 10),
      GoldButton(
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
    ];
  }

  String t(String english, String turkish) =>
      mysticText(widget.language, english, turkish);

  Widget _intro(BuildContext context, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(body, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );
  Widget _notice(String title, String body) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .05),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Arial',
            color: MysticColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          body,
          style: const TextStyle(
            fontFamily: 'Arial',
            color: MysticColors.muted,
            height: 1.45,
          ),
        ),
      ],
    ),
  );
  Widget _faq(String question, String answer) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(bottom: 14),
    title: Text(
      question,
      style: const TextStyle(
        fontFamily: 'Arial',
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          answer,
          style: const TextStyle(
            fontFamily: 'Arial',
            color: MysticColors.muted,
            height: 1.45,
          ),
        ),
      ),
    ],
  );

  Future<void> _exportJournal() async {
    final text = widget.records.isEmpty
        ? t(
            'Mystic Tarot Journal\n\nNo saved readings yet.',
            'Mystic Tarot Günlüğü\n\nHenüz kayıtlı okuma yok.',
          )
        : widget.records
              .map(
                (record) =>
                    '${record.createdAt.toLocal()} — ${_readingKindTitle(record.kind, widget.language)}\n${record.cards.map((item) => '${localizedTarotCardName(item.card.name, languageCode: widget.language.code)}${item.reversed ? t(' (Reversed)', ' (Ters)') : ''}').join(', ')}\n${t('Aligned action', 'Uyumlu eylem')}: ${record.alignedAction}',
              )
              .join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t(
              'Your journal was copied for export.',
              'Günlüğün dışa aktarmak için kopyalandı.',
            ),
          ),
        ),
      );
  }

  Future<void> _confirmDelete() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              t('Delete all Mystic data?', 'Tüm Mystic verileri silinsin mi?'),
            ),
            content: Text(
              t(
                'This cannot be undone. Your journal, card collection, streak, XP, and preferences will be removed from this device.',
                'Bu işlem geri alınamaz. Günlüğün, kart koleksiyonun, serin, XP’n ve tercihlerin bu cihazdan kaldırılır.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t('Keep my data', 'Verilerimi koru')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  t('Delete everything', 'Her şeyi sil'),
                  style: const TextStyle(color: Color(0xFFFF8090)),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    Navigator.pop(context);
    widget.onDeleteData();
  }
}

class PremiumReadingPreview extends StatefulWidget {
  const PremiumReadingPreview({
    required this.kind,
    required this.deckStyle,
    required this.language,
    required this.onUnlock,
    super.key,
  });
  final ReadingKind kind;
  final DeckStyle deckStyle;
  final MysticLanguage language;
  final VoidCallback onUnlock;

  @override
  State<PremiumReadingPreview> createState() => _PremiumReadingPreviewState();
}

class _PremiumReadingPreviewState extends State<PremiumReadingPreview> {
  bool revealed = false;
  late final DrawnCard previewCard;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    final seed = DateTime.now().day + widget.kind.index * 13;
    previewCard = DrawnCard(tarotDeck[seed % tarotDeck.length], seed.isOdd);
    _revealTimer = Timer(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => revealed = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: MysticBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: MysticColors.gold.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MysticColors.gold.withValues(alpha: .35),
                    ),
                  ),
                  child: Text(
                    mysticText(
                      widget.language,
                      'PLUS PREVIEW',
                      'PLUS ÖNİZLEME',
                    ),
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: MysticColors.gold,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.kind.symbol,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 38, color: MysticColors.gold),
            ),
            const SizedBox(height: 7),
            Text(
              _readingKindTitle(widget.kind, widget.language),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              mysticText(
                widget.language,
                'One card is yours. The complete ${widget.kind.cardCount}-card story waits behind it.',
                'Bir kart senin. ${widget.kind.cardCount} kartlık hikâyenin tamamı onun arkasında bekliyor.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 650),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: .82, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: child,
                  ),
                ),
                child: TarotCardFace(
                  key: ValueKey(revealed),
                  drawn: revealed ? previewCard : null,
                  displayName: localizedTarotCardName(
                    previewCard.card.name,
                    languageCode: widget.language.code,
                  ),
                  reversedLabel: mysticText(
                    widget.language,
                    'Reversed',
                    'Ters',
                  ),
                  selected: revealed,
                  style: widget.deckStyle,
                  width: 142,
                  height: 222,
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 500),
              crossFadeState: revealed
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: MysticColors.gold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      mysticText(
                        widget.language,
                        'The first signal is forming…',
                        'İlk işaret şekilleniyor…',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: MysticColors.lavender,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B285A), Color(0xFF1B1428)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: MysticColors.gold.withValues(alpha: .25),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      mysticText(
                        widget.language,
                        'YOUR FIRST SIGNAL',
                        'İLK İŞARETİN',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: MysticColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizedTarotCardName(
                        previewCard.card.name,
                        languageCode: widget.language.code,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _localizedCardMeaning(previewCard, widget.language),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      previewCard.reversed
                          ? mysticText(
                              widget.language,
                              'Reversed energy',
                              'Ters enerji',
                            )
                          : mysticText(
                              widget.language,
                              'Upright energy',
                              'Düz enerji',
                            ),
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: MysticColors.lavender,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Text(
                  mysticText(
                    widget.language,
                    'The rest of your spread',
                    'Açılımının geri kalanı',
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Text(
                  mysticText(
                    widget.language,
                    '${widget.kind.cardCount - 1} LOCKED',
                    '${widget.kind.cardCount - 1} KİLİTLİ',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: MysticColors.gold,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.kind.cardCount - 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: .48,
                      child: TarotCardFace(
                        style: widget.deckStyle,
                        width: 64,
                        height: 100,
                      ),
                    ),
                    Container(
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171122).withValues(alpha: .92),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: MysticColors.gold.withValues(alpha: .45),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock,
                        size: 14,
                        color: MysticColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            GoldButton(
              label: mysticText(
                widget.language,
                'Unlock the full ${_readingKindTitle(widget.kind, widget.language)}',
                '${_readingKindTitle(widget.kind, widget.language)} açılımının tamamını aç',
              ),
              onPressed: widget.onUnlock,
              icon: Icons.auto_awesome,
            ),
            const SizedBox(height: 9),
            Text(
              mysticText(
                widget.language,
                'Included with Mystic Plus • Cancel anytime',
                'Mystic Plus’a dâhil • İstediğin zaman iptal et',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Arial',
                color: MysticColors.muted,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
