import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'tarot_data.dart';
import 'theme.dart';
import 'widgets.dart';

class MysticApp extends StatefulWidget {
  const MysticApp({super.key});

  @override
  State<MysticApp> createState() => _MysticAppState();
}

class _MysticAppState extends State<MysticApp> {
  static const freeDeepReadingLimit = 3;
  final navigatorKey = GlobalKey<NavigatorState>();
  bool ready = false;
  bool onboarded = false;
  int tab = 0;
  int streak = 0;
  int xp = 0;
  int deepReadingsToday = 0;
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

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Mystic Tarot',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: buildMysticTheme(),
        home: !ready ? const _MysticLoadingScreen() : onboarded ? _shell() : OnboardingScreen(onDone: _finishOnboarding),
      );

  Widget _shell() => Scaffold(
        body: IndexedStack(index: tab, children: [
          HomeScreen(
            userName: userName,
            intention: intention,
            records: journal,
            streak: streak,
            xp: xp,
            dailyReadingDone: journal.any((record) => record.kind == ReadingKind.daily && _dayKey(record.createdAt) == _dayKey(DateTime.now())),
            ritualDone: completedRituals.isNotEmpty,
            dailyQuestClaimed: dailyQuestClaimedDay == _dayKey(DateTime.now()),
            deckStyle: deckStyle,
            freeReadingsLeft: max(0, freeDeepReadingLimit - deepReadingsToday),
            onReading: _startReading,
            onClaimDailyQuest: _claimDailyQuest,
            onPremiumSpread: _previewPremiumReading,
            onPremium: _showPremium,
          ),
          JourneyScreen(streak: streak, xp: xp, records: journal, discoveredCards: discoveredCards, completedRituals: completedRituals, claimedRewards: claimedRewards, onCompleteRitual: _completeRitual, onClaimReward: _claimReward),
          JournalScreen(records: journal),
          ProfileScreen(userName: userName, intention: intention, streak: streak, xp: xp, readings: journal.length, discovered: discoveredCards.length, relics: claimedRewards.length, records: journal, deckStyle: deckStyle, onSelectDeckStyle: _selectDeckStyle, onUpdateProfile: _updateProfile, onDeleteData: _deleteAllData, onPremium: _showPremium),
        ]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (value) => setState(() => tab = value),
          backgroundColor: const Color(0xFF100D1E),
          indicatorColor: MysticColors.violet.withValues(alpha: .45),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Read'),
            NavigationDestination(icon: Icon(Icons.hub_outlined), selectedIcon: Icon(Icons.hub), label: 'Path'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Journal'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'You'),
          ],
        ),
      );

  void _startReading(ReadingKind kind) {
    if (_premiumReadingKinds.contains(kind)) {
      _showPremium(source: 'premium_spread');
      return;
    }
    if (kind != ReadingKind.daily && deepReadingsToday >= freeDeepReadingLimit) {
      _showPremium(source: 'daily_limit');
      return;
    }
    navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => ReadingFlow(kind: kind, deckStyle: deckStyle, userName: userName, intention: intention, pastRecords: journal, onComplete: (record) {
      final newlyDiscovered = record.cards.map((item) => item.card).where((card) => !discoveredCards.contains(card.name)).toList();
      setState(() {
        journal.insert(0, record);
        discoveredCards.addAll(record.cards.map((item) => item.card.name));
        xp += 25;
        if (record.kind != ReadingKind.daily) {
          deepReadingsToday++;
          deepReadingsDay = _dayKey(DateTime.now());
        }
        _updateStreak();
      });
      _saveProgress();
      if (newlyDiscovered.isNotEmpty) {
        Future<void>.delayed(const Duration(milliseconds: 280), () => _showCardDiscovery(newlyDiscovered));
      }
    })));
  }

  void _showCardDiscovery(List<TarotCardData> cards) {
    final context = navigatorKey.currentContext;
    if (context == null || !mounted) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close discovery',
      barrierColor: Colors.black.withValues(alpha: .82),
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: ScaleTransition(scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack), child: child)),
      pageBuilder: (_, __, ___) => _CardDiscoveryDialog(cards: cards),
    );
  }

  void _completeRitual(String id) {
    if (completedRituals.contains(id)) return;
    setState(() {
      completedRituals.add(id);
      xp += 15;
    });
    _saveProgress();
  }

  void _claimReward(int milestone) {
    if (xp < milestone || claimedRewards.contains(milestone)) return;
    setState(() => claimedRewards.add(milestone));
    _saveProgress();
  }

  void _claimDailyQuest() {
    final today = _dayKey(DateTime.now());
    final readToday = journal.any((record) => record.kind == ReadingKind.daily && _dayKey(record.createdAt) == today);
    if (!readToday || completedRituals.isEmpty || dailyQuestClaimedDay == today) return;
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
    });
  }

  Future<void> _finishOnboarding(String name, String selectedIntention) async {
    final cleanName = name.trim();
    setState(() {
      onboarded = true;
      userName = cleanName.length > 18 ? cleanName.substring(0, 18) : cleanName;
      intention = selectedIntention;
    });
    await _saveProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
        deepReadingsToday = savedReadingDay == today ? prefs.getInt('deep_readings_today') ?? 0 : 0;
        deckStyle = _deckStyleFromName(prefs.getString('deck_style'));
        discoveredCards.addAll(prefs.getStringList('discovered_cards') ?? const []);
        claimedRewards.addAll((prefs.getStringList('claimed_rewards') ?? const []).map(int.parse));
        for (final encoded in prefs.getStringList('journal_records') ?? const []) {
          final record = _decodeRecord(encoded);
          if (record != null) journal.add(record);
        }
        if (ritualDay == today) completedRituals.addAll(prefs.getStringList('completed_rituals') ?? const []);
        ready = true;
      });
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
        prefs.setStringList('claimed_rewards', claimedRewards.map((item) => '$item').toList()),
        prefs.setStringList('journal_records', journal.take(50).map(_encodeRecord).toList()),
        prefs.setString('ritual_day', _dayKey(DateTime.now())),
        prefs.setString('deep_readings_day', deepReadingsDay ?? _dayKey(DateTime.now())),
        prefs.setString('deck_style', deckStyle.name),
        if (dailyQuestClaimedDay != null) prefs.setString('daily_quest_claimed_day', dailyQuestClaimedDay!),
        if (lastActiveDay != null) prefs.setString('last_active_day', lastActiveDay!),
      ]);
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

  String _dayKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DeckStyle _deckStyleFromName(String? name) {
    for (final style in DeckStyle.values) {
      if (style.name == name) return style;
    }
    return DeckStyle.midnight;
  }

  String _encodeRecord(ReadingRecord record) => jsonEncode({
        'kind': record.kind.name,
        'question': record.question,
        'cards': record.cards.map((item) => {'name': item.card.name, 'reversed': item.reversed}).toList(),
        'createdAt': record.createdAt.toIso8601String(),
        'emotion': record.emotion.name,
        'action': record.alignedAction,
      });

  ReadingRecord? _decodeRecord(String encoded) {
    try {
      final data = jsonDecode(encoded) as Map<String, dynamic>;
      final cards = (data['cards'] as List<dynamic>).map((item) {
        final map = item as Map<String, dynamic>;
        final card = tarotDeck.firstWhere((candidate) => candidate.name == map['name']);
        return DrawnCard(card, map['reversed'] as bool);
      }).toList();
      return ReadingRecord(
        kind: ReadingKind.values.byName(data['kind'] as String),
        question: data['question'] as String,
        cards: cards,
        createdAt: DateTime.parse(data['createdAt'] as String),
        emotion: EmotionalState.values.byName(data['emotion'] as String),
        alignedAction: data['action'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  void _showPremium({String source = 'organic'}) => navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => PremiumScreen(source: source)));

  void _previewPremiumReading(ReadingKind kind) => navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => PremiumReadingPreview(
        kind: kind,
        deckStyle: deckStyle,
        onUnlock: () => _showPremium(source: 'premium_spread'),
      )));
}

class _MysticLoadingScreen extends StatelessWidget {
  const _MysticLoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(body: MysticBackground(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('☾', style: TextStyle(fontSize: 68, color: MysticColors.gold)),
        SizedBox(height: 18),
        SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2, color: MysticColors.gold)),
      ]))));
}

class _CardDiscoveryDialog extends StatefulWidget {
  const _CardDiscoveryDialog({required this.cards});
  final List<TarotCardData> cards;

  @override
  State<_CardDiscoveryDialog> createState() => _CardDiscoveryDialogState();
}

class _CardDiscoveryDialogState extends State<_CardDiscoveryDialog> with SingleTickerProviderStateMixin {
  int index = 0;
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();

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
    return Center(child: Material(color: Colors.transparent, child: Container(width: 330, padding: const EdgeInsets.fromLTRB(20, 22, 20, 20), decoration: BoxDecoration(gradient: const RadialGradient(center: Alignment(0, -.3), radius: 1.2, colors: [Color(0xFF5B3D7D), Color(0xFF17101F)]), borderRadius: BorderRadius.circular(30), border: Border.all(color: color.withValues(alpha: .7)), boxShadow: [BoxShadow(color: color.withValues(alpha: .28), blurRadius: 55)]), child: AnimatedBuilder(animation: controller, builder: (context, _) => Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [const Spacer(), Text('${index + 1}/${widget.cards.length}', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 10, fontWeight: FontWeight.bold)), const Spacer(), InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, size: 20, color: MysticColors.muted))]),
      const SizedBox(height: 5),
      const Text('✦  NEW ARCANA AWAKENED', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.25)),
      const SizedBox(height: 18),
      Transform.scale(scale: .72 + Curves.elasticOut.transform(controller.value) * .28, child: Transform.rotate(angle: sin(controller.value * pi * 3) * (1 - controller.value) * .06, child: Container(width: 132, height: 198, padding: const EdgeInsets.all(9), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: .45), const Color(0xFF17101F)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: color, width: 1.5), boxShadow: [BoxShadow(color: color.withValues(alpha: .32), blurRadius: 35)]), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: .45))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(card.number, style: TextStyle(fontFamily: 'Arial', color: color, fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(height: 23), Text(card.symbol, style: TextStyle(fontSize: 50, color: color)), const SizedBox(height: 23), Text(card.name, maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.bold))]))))),
      const SizedBox(height: 17),
      Text(_cardRarity(card).toUpperCase(), style: TextStyle(fontFamily: 'Arial', color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      const SizedBox(height: 6),
      Text(card.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(card.light, maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MysticColors.mist)),
      const SizedBox(height: 20),
      GoldButton(label: hasNext ? 'Reveal next card' : 'Add to Arcana Vault', onPressed: () {
        if (hasNext) {
          setState(() => index++);
          controller.forward(from: 0);
        } else {
          Navigator.pop(context);
        }
      }, icon: hasNext ? Icons.auto_awesome : Icons.check),
    ])))));
  }
}

String _cardRarity(TarotCardData card) {
  final index = tarotDeck.indexOf(card);
  if (index < 22) return 'Legendary';
  if (card.name.startsWith('Page') || card.name.startsWith('Knight') || card.name.startsWith('Queen') || card.name.startsWith('King')) return 'Epic';
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
  final void Function(String name, String intention) onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int page = 0;
  final name = TextEditingController();
  String intention = 'Clarity';

  @override
  Widget build(BuildContext context) => Scaffold(body: MysticBackground(child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(children: [
          Row(children: List.generate(3, (i) => Expanded(child: Container(height: 3, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: i <= page ? MysticColors.gold : Colors.white12, borderRadius: BorderRadius.circular(8)))))),
          Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 350), child: _page(context))),
          GoldButton(label: page == 2 ? 'Enter Mystic' : 'Continue', onPressed: () => page < 2 ? setState(() => page++) : widget.onDone(name.text.trim(), intention)),
        ]),
      )));

  Widget _page(BuildContext context) {
    if (page == 0) {
      return Column(key: const ValueKey(0), mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('☾', style: TextStyle(fontSize: 82, color: MysticColors.gold)),
      const SizedBox(height: 24),
      Text('Your inner world\nhas a language.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 18),
      Text('Mystic helps you hear it through reflective tarot, personal rituals, and a journal that grows with you.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
      ]);
    }
    if (page == 1) {
      return Column(key: const ValueKey(1), mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('What should we\ncall you?', style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 16),
      Text('Your name helps each reading feel personal.', style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 28),
      TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Your first name', prefixIcon: Icon(Icons.person_outline))),
      ]);
    }
    const choices = ['Clarity', 'Love', 'Purpose', 'Healing'];
    return Column(key: const ValueKey(2), mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Set your first\nintention.', style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 16),
      Text('There is no wrong choice. This simply shapes your starting experience.', style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 25),
      Wrap(spacing: 10, runSpacing: 10, children: choices.map((choice) => ChoiceChip(label: Text(choice), selected: intention == choice, onSelected: (_) => setState(() => intention = choice), selectedColor: MysticColors.violet)).toList()),
    ]);
  }
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
  const HomeScreen({required this.userName, required this.intention, required this.records, required this.streak, required this.xp, required this.dailyReadingDone, required this.ritualDone, required this.dailyQuestClaimed, required this.deckStyle, required this.freeReadingsLeft, required this.onReading, required this.onClaimDailyQuest, required this.onPremiumSpread, required this.onPremium, super.key});
  final String userName;
  final String intention;
  final List<ReadingRecord> records;
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

  @override
  Widget build(BuildContext context) => MysticBackground(child: CustomScrollView(slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 10), sliver: SliverList(delegate: SliverChildListDelegate([
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_greeting(), style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 4), Text(userName.isEmpty ? 'Your cards are waiting' : 'Your cards are waiting, $userName', maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge)])),
            const SizedBox(width: 10),
            InkWell(onTap: onPremium, borderRadius: BorderRadius.circular(30), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: MysticColors.gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(30), border: Border.all(color: MysticColors.gold.withValues(alpha: .4))), child: const Row(children: [Text('✦ ', style: TextStyle(color: MysticColors.gold)), Text('PLUS', style: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.w800, color: MysticColors.gold, fontSize: 12))]))),
          ]),
          const SizedBox(height: 18),
          const _MoonBriefing(),
          const SizedBox(height: 14),
          _PersonalSignal(intention: intention, records: records),
          const SizedBox(height: 14),
          _DailyCard(streak: streak, deckStyle: deckStyle, onTap: () => onReading(ReadingKind.daily)),
          const SizedBox(height: 14),
          _DailyQuest(
            readingDone: dailyReadingDone,
            ritualDone: ritualDone,
            claimed: dailyQuestClaimed,
            onClaim: onClaimDailyQuest,
          ),
          const SizedBox(height: 12),
          _ReadingAllowance(readingsLeft: freeReadingsLeft, onUpgrade: onPremium),
          const SizedBox(height: 26),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Choose a reading', style: Theme.of(context).textTheme.titleLarge), Text('$xp XP', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
        ]))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28), sliver: SliverGrid(delegate: SliverChildBuilderDelegate((context, index) {
          final kind = _standardReadingKinds[index];
          return InkWell(onTap: () => onReading(kind), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .055), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: .08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(kind.symbol, style: const TextStyle(fontSize: 27, color: MysticColors.gold)), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(kind.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 5), Text('${kind.cardCount} cards', style: Theme.of(context).textTheme.bodyMedium)])])));
        }, childCount: _standardReadingKinds.length), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.12, crossAxisSpacing: 12, mainAxisSpacing: 12))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 32), sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text('Mystic Plus readings', style: Theme.of(context).textTheme.titleLarge), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: MysticColors.gold, borderRadius: BorderRadius.circular(12)), child: const Text('PLUS', style: TextStyle(fontFamily: 'Arial', color: MysticColors.ink, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .7)))]),
          const SizedBox(height: 6),
          Text('High-depth spreads built for the questions people return to most.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          SizedBox(height: 166, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _premiumReadingKinds.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, index) => _premiumReadingCard(context, _premiumReadingKinds[index]))),
        ]))),
      ]));

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _premiumReadingCard(BuildContext context, ReadingKind kind) => InkWell(onTap: () => onPremiumSpread(kind), borderRadius: BorderRadius.circular(20), child: Container(width: 158, padding: const EdgeInsets.all(15), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5A3B82), Color(0xFF20152F)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: MysticColors.gold.withValues(alpha: .35))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Text(kind.symbol, style: const TextStyle(fontSize: 27, color: MysticColors.gold)), const Spacer(), const Icon(Icons.lock_outline, color: MysticColors.gold, size: 17)]),
    const Spacer(),
    Text(kind.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
    const SizedBox(height: 5),
    Text('${kind.cardCount}-card premium spread', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 10)),
  ])));
}

class _PersonalSignal extends StatelessWidget {
  const _PersonalSignal({required this.intention, required this.records});
  final String intention;
  final List<ReadingRecord> records;

  @override
  Widget build(BuildContext context) {
    final recent = records.take(7).toList();
    final cardCounts = <String, int>{};
    final emotionCounts = <EmotionalState, int>{};
    for (final record in recent) {
      emotionCounts.update(record.emotion, (value) => value + 1, ifAbsent: () => 1);
      for (final item in record.cards) {
        cardCounts.update(item.card.name, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    final recurringCard = cardCounts.entries.where((entry) => entry.value > 1).fold<MapEntry<String, int>?>(null, (best, entry) => best == null || entry.value > best.value ? entry : best);
    final dominantEmotion = emotionCounts.entries.fold<MapEntry<EmotionalState, int>?>(null, (best, entry) => best == null || entry.value > best.value ? entry : best);
    final hasPattern = recent.length >= 2;
    final title = hasPattern ? 'Mystic remembers your pattern' : 'Your $intention path is opening';
    final body = recurringCard != null
        ? '${recurringCard.key} has returned ${recurringCard.value} times. Mystic is watching what this symbol keeps asking you to notice.'
        : dominantEmotion != null && hasPattern
            ? 'You have entered recent readings feeling ${dominantEmotion.key.label.toLowerCase()}. Your next reading will hold that emotional thread in view.'
            : 'Save two readings and Mystic will begin connecting recurring cards, emotions, and choices into a private pattern map.';
    return Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2D2348), Color(0xFF171321)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: MysticColors.lavender.withValues(alpha: .24))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: MysticColors.violet.withValues(alpha: .28)), child: const Text('◉', style: TextStyle(color: MysticColors.gold, fontSize: 21))), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.w800, fontSize: 12)), const SizedBox(height: 5), Text(body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, height: 1.4))]))]));
  }
}

class _ReadingAllowance extends StatelessWidget {
  const _ReadingAllowance({required this.readingsLeft, required this.onUpgrade});
  final int readingsLeft;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final empty = readingsLeft == 0;
    return InkWell(
      onTap: empty ? onUpgrade : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: empty ? MysticColors.gold.withValues(alpha: .1) : Colors.white.withValues(alpha: .04), borderRadius: BorderRadius.circular(16), border: Border.all(color: empty ? MysticColors.gold.withValues(alpha: .38) : Colors.white10)), child: Row(children: [
        Container(width: 35, height: 35, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: empty ? MysticColors.gold : MysticColors.violet.withValues(alpha: .28)), child: Icon(empty ? Icons.lock_outline : Icons.bolt, color: empty ? MysticColors.ink : MysticColors.gold, size: 18)),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(empty ? 'Free deep readings used' : '$readingsLeft free deep readings left today', style: const TextStyle(fontFamily: 'Arial', fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(empty ? 'Unlock unlimited readings with Mystic Plus.' : 'Your Daily Guidance remains free every day.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11))])),
        Text(empty ? 'VIEW PLUS' : '${3 - readingsLeft}/3', style: TextStyle(fontFamily: 'Arial', color: empty ? MysticColors.gold : MysticColors.muted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .6)),
      ])),
    );
  }
}

class _MoonBriefing extends StatelessWidget {
  const _MoonBriefing();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .045),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: MysticColors.lavender.withValues(alpha: .14)),
        ),
        child: Row(children: [
          Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFF5DFA6), Color(0xFF8F6FD8)]), boxShadow: [BoxShadow(color: MysticColors.lavender.withValues(alpha: .25), blurRadius: 18)]), child: const Text('◐', style: TextStyle(color: MysticColors.ink, fontSize: 23))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TONIGHT’S MYSTIC PULSE', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.25)),
            const SizedBox(height: 4),
            Text('Release urgency. Choose the honest next step.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MysticColors.mist)),
          ])),
          const Text('2 MIN', style: TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 10, fontWeight: FontWeight.bold)),
        ]),
      );
}

class _DailyCard extends StatefulWidget {
  const _DailyCard({required this.streak, required this.deckStyle, required this.onTap});
  final int streak;
  final DeckStyle deckStyle;
  final VoidCallback onTap;

  @override
  State<_DailyCard> createState() => _DailyCardState();
}

class _DailyCardState extends State<_DailyCard> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (context, child) => InkWell(onTap: widget.onTap, borderRadius: BorderRadius.circular(24), child: Container(height: 196, padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.lerp(const Color(0xFF6C45B5), const Color(0xFF8356C5), controller.value)!, const Color(0xFF251944)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: MysticColors.lavender.withValues(alpha: .32 + controller.value * .18)), boxShadow: [BoxShadow(color: MysticColors.violet.withValues(alpha: .12 + controller.value * .08), blurRadius: 28, spreadRadius: 1)]), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('YOUR DAILY PORTAL', style: TextStyle(fontFamily: 'Arial', letterSpacing: 1.8, color: MysticColors.lavender, fontSize: 11, fontWeight: FontWeight.bold)), const Spacer(), Text('Reveal what\nneeds you today', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), Text('🔥 ${widget.streak} day streak  •  +25 XP', style: Theme.of(context).textTheme.bodyMedium)])), TarotCardFace(style: widget.deckStyle, width: 90, height: 142)]))));
}

class _DailyQuest extends StatelessWidget {
  const _DailyQuest({required this.readingDone, required this.ritualDone, required this.claimed, required this.onClaim});
  final bool readingDone;
  final bool ritualDone;
  final bool claimed;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final complete = readingDone && ritualDone;
    final progress = (readingDone ? .5 : 0.0) + (ritualDone ? .5 : 0.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: complete ? const [Color(0xFF523771), Color(0xFF21182F)] : const [Color(0xFF211A31), Color(0xFF15111F)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: complete ? MysticColors.gold.withValues(alpha: .48) : Colors.white10),
      ),
      child: Column(children: [
        Row(children: [
          Container(width: 45, height: 45, alignment: Alignment.center, decoration: BoxDecoration(color: complete ? MysticColors.gold.withValues(alpha: .16) : Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(14)), child: Text(claimed ? '✦' : complete ? '◇' : '☾', style: const TextStyle(color: MysticColors.gold, fontSize: 25))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('DAILY SOUL QUEST', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.25)),
            const SizedBox(height: 4),
            Text(claimed ? 'Today’s relic is yours.' : complete ? 'Your chest is ready to open.' : 'Complete both steps • +40 XP', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14)),
          ])),
          if (complete && !claimed) IconButton(onPressed: () => _claim(context), style: IconButton.styleFrom(backgroundColor: MysticColors.gold, foregroundColor: MysticColors.ink), icon: const Icon(Icons.lock_open_rounded)),
          if (claimed) const Icon(Icons.check_circle, color: MysticColors.gold),
        ]),
        const SizedBox(height: 13),
        Row(children: [_step(context, '1', 'Daily card', readingDone), const SizedBox(width: 8), _step(context, '2', 'One ritual', ritualDone)]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: claimed ? 1.0 : progress, minHeight: 5, backgroundColor: Colors.white10, color: MysticColors.gold)),
      ]),
    );
  }

  Widget _step(BuildContext context, String number, String label, bool done) => Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9), decoration: BoxDecoration(color: done ? MysticColors.gold.withValues(alpha: .1) : Colors.white.withValues(alpha: .035), borderRadius: BorderRadius.circular(12)), child: Row(children: [CircleAvatar(radius: 10, backgroundColor: done ? MysticColors.gold : Colors.white10, child: Text(done ? '✓' : number, style: TextStyle(fontFamily: 'Arial', color: done ? MysticColors.ink : MysticColors.muted, fontSize: 10, fontWeight: FontWeight.bold))), const SizedBox(width: 7), Expanded(child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.w600)))])));

  void _claim(BuildContext context) {
    onClaim();
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close reward',
      barrierColor: Colors.black.withValues(alpha: .78),
      transitionDuration: const Duration(milliseconds: 450),
      transitionBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: ScaleTransition(scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack), child: child)),
      pageBuilder: (_, __, ___) => const _QuestRewardDialog(),
    );
  }
}

class _QuestRewardDialog extends StatefulWidget {
  const _QuestRewardDialog();

  @override
  State<_QuestRewardDialog> createState() => _QuestRewardDialogState();
}

class _QuestRewardDialogState extends State<_QuestRewardDialog> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))..forward();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(child: Material(color: Colors.transparent, child: Container(width: 310, padding: const EdgeInsets.fromLTRB(22, 26, 22, 22), decoration: BoxDecoration(gradient: const RadialGradient(colors: [Color(0xFF60458F), Color(0xFF191226)]), borderRadius: BorderRadius.circular(28), border: Border.all(color: MysticColors.gold.withValues(alpha: .55)), boxShadow: [BoxShadow(color: MysticColors.violet.withValues(alpha: .35), blurRadius: 50)]), child: AnimatedBuilder(animation: controller, builder: (context, _) => Column(mainAxisSize: MainAxisSize.min, children: [
    SizedBox(height: 150, child: Stack(alignment: Alignment.center, children: [
      Positioned.fill(child: CustomPaint(painter: _RewardBurstPainter(controller.value))),
      Transform.scale(scale: .7 + Curves.elasticOut.transform(controller.value) * .3, child: Transform.rotate(angle: sin(controller.value * pi * 4) * (1 - controller.value) * .08, child: Container(width: 88, height: 88, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFF4DB8F), Color(0xFFB88231)]), boxShadow: [BoxShadow(color: MysticColors.gold.withValues(alpha: .5), blurRadius: 35)]), child: Text(controller.value > .55 ? '✦' : '◇', style: const TextStyle(fontSize: 43, color: MysticColors.ink))))),
    ])),
    const Text('SOUL CHEST OPENED', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    const SizedBox(height: 9),
    Text('+40 XP', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 34)),
    const SizedBox(height: 8),
    Text('Moon Shard added to your constellation.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
    const SizedBox(height: 20),
    GoldButton(label: 'Continue my path', onPressed: () => Navigator.pop(context), icon: Icons.auto_awesome),
  ])))));
}

class _RewardBurstPainter extends CustomPainter {
  const _RewardBurstPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 14; i++) {
      final angle = i * pi * 2 / 14;
      final distance = 22 + Curves.easeOut.transform(progress) * (42 + (i % 3) * 8);
      final point = center + Offset(cos(angle), sin(angle)) * distance;
      canvas.drawCircle(point, i.isEven ? 2.2 : 1.4, Paint()..color = MysticColors.gold.withValues(alpha: (1 - progress * .55).clamp(0.0, 1.0).toDouble()));
    }
  }

  @override
  bool shouldRepaint(covariant _RewardBurstPainter oldDelegate) => oldDelegate.progress != progress;
}

class ReadingFlow extends StatefulWidget {
  const ReadingFlow({required this.kind, required this.deckStyle, required this.userName, required this.intention, required this.pastRecords, required this.onComplete, super.key});
  final ReadingKind kind;
  final DeckStyle deckStyle;
  final String userName;
  final String intention;
  final List<ReadingRecord> pastRecords;
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
  bool revealComplete = false;
  bool allowReversals = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) setState(() => allowReversals = prefs.getBool('allow_reversals') ?? true);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: MysticBackground(child: drawn == null ? _selection(context) : _result(context)));

  Widget _selection(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 24), child: Column(children: [
        Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)), const Spacer(), Text('${selected.length}/${widget.kind.cardCount}', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.bold))]),
        Text(widget.kind.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Breathe slowly. Hold your question in mind, then choose the cards that call to you.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        TextField(controller: question, maxLines: 2, decoration: const InputDecoration(hintText: 'Write your question (optional)', prefixIcon: Icon(Icons.edit_outlined))),
        const SizedBox(height: 14),
        Align(alignment: Alignment.centerLeft, child: Text('HOW DO YOU FEEL RIGHT NOW?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, letterSpacing: 1.1))),
        const SizedBox(height: 8),
        SizedBox(height: 38, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: EmotionalState.values.length, separatorBuilder: (_, __) => const SizedBox(width: 7), itemBuilder: (_, i) {
          final item = EmotionalState.values[i];
          return ChoiceChip(label: Text('${item.symbol} ${item.label}'), selected: emotion == item, onSelected: (_) => setState(() => emotion = item));
        })),
        const SizedBox(height: 18),
        Expanded(child: GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 18), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: .62, crossAxisSpacing: 8, mainAxisSpacing: 10), itemCount: 12, itemBuilder: (_, i) => GestureDetector(onTap: () => _toggle(i), child: TarotCardFace(style: widget.deckStyle, selected: selected.contains(i), width: 65, height: 110)))),
        GoldButton(label: selected.length == widget.kind.cardCount ? 'Reveal my reading' : 'Choose ${widget.kind.cardCount - selected.length} more', onPressed: selected.length == widget.kind.cardCount ? _reveal : null, icon: Icons.auto_awesome),
      ]));

  void _toggle(int index) => setState(() {
        if (selected.contains(index)) {
          selected.remove(index);
        } else if (selected.length < widget.kind.cardCount) {
          selected.add(index);
        }
      });

  Future<void> _reveal() async {
    final random = Random();
    final pool = [...tarotDeck]..shuffle(random);
    setState(() {
      drawn = List.generate(widget.kind.cardCount, (i) => DrawnCard(pool[i], allowReversals && random.nextInt(4) == 0));
      revealComplete = false;
    });
    await Future<void>.delayed(Duration(milliseconds: 850 + widget.kind.cardCount * 520));
    if (mounted) setState(() => revealComplete = true);
  }

  Widget _result(BuildContext context) {
    final record = ReadingRecord(kind: widget.kind, question: question.text.trim(), cards: drawn!, createdAt: DateTime.now(), emotion: emotion, alignedAction: _alignedAction());
    return CustomScrollView(slivers: [
      SliverAppBar(backgroundColor: Colors.transparent, title: const Text('Your reading'), actions: [IconButton(onPressed: revealComplete ? () => _shareReading(record) : null, tooltip: 'Share reading', icon: const Icon(Icons.ios_share_outlined))]),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 36), sliver: SliverList(delegate: SliverChildListDelegate([
        Text(_headline(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 10),
        Text('Take what resonates. Tarot is a mirror for reflection—not a fixed prediction.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        SizedBox(height: 190, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 4), itemBuilder: (_, i) => _RitualRevealCard(card: drawn![i], deckStyle: widget.deckStyle, delay: Duration(milliseconds: 350 + i * 520)), separatorBuilder: (_, __) => const SizedBox(width: 12), itemCount: drawn!.length)),
        const SizedBox(height: 26),
        if (!revealComplete) _ReadingInProgress(cardCount: drawn!.length),
        if (revealComplete) ...drawn!.asMap().entries.map((entry) => _interpretation(context, entry.key, entry.value)),
        if (revealComplete) Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: MysticColors.gold.withValues(alpha: .09), borderRadius: BorderRadius.circular(20), border: Border.all(color: MysticColors.gold.withValues(alpha: .3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('✦  YOUR GUIDANCE', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 12), Text(_guidance(), style: Theme.of(context).textTheme.bodyLarge)])),
        if (revealComplete && widget.pastRecords.isNotEmpty) const SizedBox(height: 14),
        if (revealComplete && widget.pastRecords.isNotEmpty) _memoryBridge(context),
        if (revealComplete) const SizedBox(height: 14),
        if (revealComplete) Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF34235C), Color(0xFF1B1530)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: MysticColors.lavender.withValues(alpha: .28))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MYSTIC MIRROR • 24H LOOP', style: TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
          const SizedBox(height: 10),
          Text('Your aligned action', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(_alignedAction(), style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 10),
          Text('Tomorrow, Mystic will ask what actually changed. Your answer becomes part of your personal pattern map.', style: Theme.of(context).textTheme.bodyMedium),
        ])),
        if (revealComplete) const SizedBox(height: 20),
        if (revealComplete) GoldButton(label: saved ? 'Saved to your journal' : 'Save this reading', icon: saved ? Icons.check : Icons.bookmark_add_outlined, onPressed: saved ? null : () { widget.onComplete(record); setState(() => saved = true); }),
        if (revealComplete) const SizedBox(height: 10),
        if (revealComplete) TextButton(onPressed: () => Navigator.pop(context), child: const Text('Return home')),
      ]))),
    ]);
  }

  Widget _interpretation(BuildContext context, int index, DrawnCard card) {
    const positions = ['What surrounds you', 'What asks for attention', 'Your next aligned step'];
    final meaning = card.reversed ? card.card.shadow : card.card.light;
    return Padding(padding: const EdgeInsets.only(bottom: 22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(index < positions.length ? positions[index].toUpperCase() : 'MESSAGE', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)), const SizedBox(height: 6), Text('${card.card.name}${card.reversed ? ' — Reversed' : ''}', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(meaning, style: Theme.of(context).textTheme.bodyLarge)]));
  }

  String _headline() {
    final hopeful = drawn!.any((c) => c.card.name == 'The Star' || c.card.name == 'The Sun');
    if (widget.userName.isEmpty) return hopeful ? 'A hopeful path is becoming visible.' : 'The truth arrives when you slow down.';
    return hopeful ? '${widget.userName}, a hopeful path is becoming visible.' : '${widget.userName}, the truth arrives when you slow down.';
  }

  Widget _memoryBridge(BuildContext context) {
    final previous = widget.pastRecords.first;
    final returning = drawn!.where((current) => previous.cards.any((old) => old.card.name == current.card.name)).map((item) => item.card.name).toList();
    final message = returning.isNotEmpty
        ? '${returning.first} also appeared in your last saved reading. Repeating symbols often become useful when you compare what changed between the two moments.'
        : 'Your previous reading began from ${previous.emotion.label.toLowerCase()}; today you chose ${emotion.label.toLowerCase()}. Mystic is connecting the emotional shift—not just the cards.';
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF30254A), Color(0xFF181321)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: MysticColors.lavender.withValues(alpha: .26))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('◉  ORACLE MEMORY', style: TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)), const SizedBox(height: 9), Text(message, style: Theme.of(context).textTheme.bodyLarge)]));
  }

  Future<void> _shareReading(ReadingRecord record) async {
    final cards = record.cards.map((item) => '${item.card.name}${item.reversed ? ' (Reversed)' : ''}').join(' • ');
    final text = '✦ My ${record.kind.title} — Mystic Tarot\n\n$cards\n\n${_guidance()}\n\nA reflection, not a fixed prediction.\nTry your own reading: https://tuna777123.github.io/mystic-tarot/';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showModalBottomSheet<void>(context: context, backgroundColor: const Color(0xFF171128), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 16, 22, 28), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8))), const SizedBox(height: 22), const Icon(Icons.auto_awesome, color: MysticColors.gold, size: 38), const SizedBox(height: 12), Text('Your shareable reading is ready', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text('The cards, guidance, and Mystic link were copied. Paste them into Instagram, TikTok, WhatsApp, or anywhere your story continues.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 18), GoldButton(label: 'Done', onPressed: () => Navigator.pop(context), icon: Icons.check)]))));
  }
  String _guidance() => '${drawn!.last.card.advice} Hold this beside your intention of ${widget.intention.toLowerCase()}. Let it be an invitation, not a command, and notice what changes over the next twenty-four hours.';
  String _alignedAction() {
    switch (emotion) {
      case EmotionalState.anxious:
        return 'Delay one fear-based decision. Write down what is known, what is assumed, and what can wait until tomorrow.';
      case EmotionalState.hopeful:
        return 'Turn hope into evidence: take one small action that your future self can continue tomorrow.';
      case EmotionalState.grounded:
        return 'Use today’s steadiness to complete one conversation or task you have been leaving open.';
      case EmotionalState.curious:
        return 'Ask one honest question without trying to control the answer.';
      case EmotionalState.uncertain:
        return 'Choose the smallest reversible step. Clarity often appears after movement, not before it.';
    }
  }
}

class _RitualRevealCard extends StatefulWidget {
  const _RitualRevealCard({required this.card, required this.deckStyle, required this.delay});
  final DrawnCard card;
  final DeckStyle deckStyle;
  final Duration delay;

  @override
  State<_RitualRevealCard> createState() => _RitualRevealCardState();
}

class _RitualRevealCardState extends State<_RitualRevealCard> {
  bool faceUp = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => faceUp = true);
    });
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
            transform: Matrix4.identity()..setEntry(3, 2, .0014)..rotateY(angle),
            child: Transform.flip(
              flipX: showFace,
              child: TarotCardFace(drawn: showFace ? widget.card : null, style: widget.deckStyle),
            ),
          );
        },
      );
}

class _ReadingInProgress extends StatelessWidget {
  const _ReadingInProgress({required this.cardCount});
  final int cardCount;

  @override
  Widget build(BuildContext context) => Column(children: [
        const SizedBox(height: 10),
        const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2, color: MysticColors.gold)),
        const SizedBox(height: 15),
        Text(cardCount == 1 ? 'Your card is finding its voice…' : 'The cards are forming a pattern…', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 7),
        Text('Stay with your first feeling. The full interpretation appears after the final card turns.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
      ]);
}

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({required this.streak, required this.xp, required this.records, required this.discoveredCards, required this.completedRituals, required this.claimedRewards, required this.onCompleteRitual, required this.onClaimReward, super.key});
  final int streak;
  final int xp;
  final List<ReadingRecord> records;
  final Set<String> discoveredCards;
  final Set<String> completedRituals;
  final Set<int> claimedRewards;
  final ValueChanged<String> onCompleteRitual;
  final ValueChanged<int> onClaimReward;

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> with SingleTickerProviderStateMixin {
  late final AnimationController glow = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

  @override
  void dispose() {
    glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.xp ~/ 100 + 1;
    final levelProgress = (widget.xp % 100) / 100;
    return MysticBackground(child: ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 34), children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your Mystic Path', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 5), Text('Your inner world becomes visible as you practice.', style: Theme.of(context).textTheme.bodyMedium)])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: MysticColors.gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(18), border: Border.all(color: MysticColors.gold.withValues(alpha: .35))), child: Text('LEVEL $level', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1))),
      ]),
      const SizedBox(height: 20),
      AnimatedBuilder(animation: glow, builder: (context, _) => Container(
        height: 245,
        decoration: BoxDecoration(gradient: const RadialGradient(colors: [Color(0xFF49347D), Color(0xFF171128)]), borderRadius: BorderRadius.circular(26), border: Border.all(color: MysticColors.lavender.withValues(alpha: .18 + glow.value * .18)), boxShadow: [BoxShadow(color: MysticColors.violet.withValues(alpha: .12 + glow.value * .08), blurRadius: 32)]),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _ConstellationPainter(unlocked: widget.discoveredCards.length, pulse: glow.value))),
          Positioned(left: 18, top: 17, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('INNER CONSTELLATION', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.3)), const SizedBox(height: 4), Text('${widget.discoveredCards.length} of 78 cards awakened', style: Theme.of(context).textTheme.bodyMedium)])),
          Positioned(left: 18, right: 18, bottom: 17, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: widget.discoveredCards.length / 78, minHeight: 5, backgroundColor: Colors.white10, color: MysticColors.gold))),
        ]),
      )),
      const SizedBox(height: 18),
      _WeeklyMirror(records: widget.records),
      const SizedBox(height: 18),
      _ArcanaVault(discoveredCards: widget.discoveredCards),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .045), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: .08))), child: Column(children: [
        Row(children: [Text('${widget.xp} XP', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.bold)), const Spacer(), Text('${(levelProgress * 100).round()}% to Level ${level + 1}', style: Theme.of(context).textTheme.bodyMedium)]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: levelProgress, minHeight: 7, backgroundColor: Colors.white10, color: MysticColors.violet)),
      ])),
      const SizedBox(height: 25),
      Row(children: [Text('Today’s rituals', style: Theme.of(context).textTheme.titleLarge), const Spacer(), Text('${widget.completedRituals.length}/3', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 6),
      Text('Small actions turn insight into change. Each ritual grants +15 XP.', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 12),
      _ritual(context, 'breathe', '60-second reset', 'Breathe in for four, out for six.', Icons.air),
      _ritual(context, 'truth', 'Name the truth', 'Write one sentence you have been avoiding.', Icons.edit_note),
      _ritual(context, 'action', 'Aligned action', 'Take the smallest reversible next step.', Icons.bolt),
      const SizedBox(height: 15),
      Text('Mystic rewards', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      Text('Your practice unlocks cosmetic relics—never better answers.', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 12),
      SizedBox(height: 145, child: ListView(scrollDirection: Axis.horizontal, children: [
        _reward(context, 100, 'Moon Dust', '✦'),
        _reward(context, 300, 'Oracle Flame', '◉'),
        _reward(context, 600, 'Astral Crown', '♛'),
      ])),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF33245C), Color(0xFF1A142D)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: MysticColors.lavender.withValues(alpha: .2))), child: Row(children: [const Text('🔥', style: TextStyle(fontSize: 30)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${widget.streak}-day flame', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 4), Text('Return tomorrow to keep your constellation alive.', style: Theme.of(context).textTheme.bodyMedium)]))])),
    ]));
  }

  Widget _reward(BuildContext context, int milestone, String title, String symbol) {
    final unlocked = widget.xp >= milestone;
    final claimed = widget.claimedRewards.contains(milestone);
    return Container(width: 132, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(13), decoration: BoxDecoration(gradient: LinearGradient(colors: unlocked ? const [Color(0xFF4B347E), Color(0xFF211735)] : const [Color(0xFF201A2C), Color(0xFF12101A)]), borderRadius: BorderRadius.circular(18), border: Border.all(color: claimed ? MysticColors.gold : Colors.white12)), child: Column(children: [
      Text(claimed ? symbol : unlocked ? '◇' : '🔒', style: TextStyle(fontSize: 31, color: unlocked ? MysticColors.gold : MysticColors.muted)),
      const Spacer(),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.bold, fontSize: 12)),
      const SizedBox(height: 5),
      SizedBox(height: 28, child: TextButton(onPressed: unlocked && !claimed ? () { widget.onClaimReward(milestone); setState(() {}); } : null, style: TextButton.styleFrom(padding: EdgeInsets.zero), child: Text(claimed ? 'CLAIMED' : unlocked ? 'CLAIM' : '$milestone XP', style: const TextStyle(fontFamily: 'Arial', fontSize: 10, fontWeight: FontWeight.w800)))),
    ]));
  }

  Widget _ritual(BuildContext context, String id, String title, String subtitle, IconData icon) {
    final done = widget.completedRituals.contains(id);
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(
      onTap: done ? null : () { widget.onCompleteRitual(id); setState(() {}); },
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(duration: const Duration(milliseconds: 320), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: done ? MysticColors.gold.withValues(alpha: .1) : Colors.white.withValues(alpha: .045), borderRadius: BorderRadius.circular(18), border: Border.all(color: done ? MysticColors.gold.withValues(alpha: .42) : Colors.white.withValues(alpha: .08))), child: Row(children: [
        CircleAvatar(backgroundColor: done ? MysticColors.gold : MysticColors.violet.withValues(alpha: .35), child: Icon(done ? Icons.check : icon, color: done ? MysticColors.ink : MysticColors.lavender, size: 20)),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(done ? 'Ritual complete • +15 XP' : subtitle, style: Theme.of(context).textTheme.bodyMedium)])),
        if (!done) const Icon(Icons.arrow_forward_ios, size: 14, color: MysticColors.muted),
      ])),
    ));
  }
}

class _ArcanaVault extends StatelessWidget {
  const _ArcanaVault({required this.discoveredCards});
  final Set<String> discoveredCards;

  @override
  Widget build(BuildContext context) {
    final unlocked = tarotDeck.where((card) => discoveredCards.contains(card.name)).toList();
    final locked = tarotDeck.where((card) => !discoveredCards.contains(card.name)).toList();
    final preview = [...unlocked, ...locked].take(3).toList();
    final nextMilestone = discoveredCards.length >= 78 ? 78 : min(78, ((discoveredCards.length ~/ 10) + 1) * 10);
    return InkWell(
      onTap: () => _openVault(context),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF251A3C), Color(0xFF12101C)]), borderRadius: BorderRadius.circular(22), border: Border.all(color: MysticColors.gold.withValues(alpha: .24))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('ARCANA VAULT', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.35)),
            const Spacer(),
            Text('${discoveredCards.length}/78', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_forward_ios, size: 12, color: MysticColors.muted),
          ]),
          const SizedBox(height: 6),
          Text(discoveredCards.isEmpty ? 'Every reading can awaken a card.' : discoveredCards.length == 78 ? 'The entire deck has answered you.' : '${nextMilestone - discoveredCards.length} more cards until your next collection milestone.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 15),
          Row(children: [for (var i = 0; i < preview.length; i++) ...[if (i > 0) const SizedBox(width: 9), Expanded(child: _previewCard(preview[i], discoveredCards.contains(preview[i].name)))]]),
        ]),
      ),
    );
  }

  Widget _previewCard(TarotCardData card, bool unlocked) {
    final color = _cardRarityColor(card);
    return Container(height: 112, padding: const EdgeInsets.all(9), decoration: BoxDecoration(gradient: unlocked ? LinearGradient(colors: [color.withValues(alpha: .25), const Color(0xFF191323)]) : const LinearGradient(colors: [Color(0xFF1C1824), Color(0xFF100E16)]), borderRadius: BorderRadius.circular(14), border: Border.all(color: unlocked ? color.withValues(alpha: .55) : Colors.white10)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(unlocked ? card.symbol : '◈', style: TextStyle(fontSize: 28, color: unlocked ? color : Colors.white24)),
      const SizedBox(height: 8),
      Text(unlocked ? card.name : 'Undiscovered', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arial', color: unlocked ? MysticColors.mist : MysticColors.muted, fontSize: 10, fontWeight: FontWeight.w700)),
    ]));
  }

  void _openVault(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: .92,
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFF14101F), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: SafeArea(top: false, child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8))),
            Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 12), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your Arcana Vault', style: Theme.of(sheetContext).textTheme.headlineMedium), const SizedBox(height: 4), Text('${discoveredCards.length} awakened • ${78 - discoveredCards.length} still hidden', style: Theme.of(sheetContext).textTheme.bodyMedium)])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), decoration: BoxDecoration(color: MysticColors.gold.withValues(alpha: .1), borderRadius: BorderRadius.circular(16)), child: Text('${((discoveredCards.length / 78) * 100).round()}%', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.bold))),
            ])),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: discoveredCards.length / 78, minHeight: 6, backgroundColor: Colors.white10, color: MysticColors.gold))),
            const SizedBox(height: 14),
            Expanded(child: GridView.builder(padding: const EdgeInsets.fromLTRB(16, 4, 16, 28), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: .69, crossAxisSpacing: 9, mainAxisSpacing: 9), itemCount: tarotDeck.length, itemBuilder: (_, index) {
              final card = tarotDeck[index];
              final unlocked = discoveredCards.contains(card.name);
              return _vaultCard(sheetContext, card, unlocked);
            })),
          ])),
        ),
      ),
    );
  }

  Widget _vaultCard(BuildContext context, TarotCardData card, bool unlocked) {
    final color = _cardRarityColor(card);
    return InkWell(
      onTap: unlocked ? () => _showCardDetail(context, card) : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(gradient: unlocked ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: .24), const Color(0xFF181222)]) : const LinearGradient(colors: [Color(0xFF1B1722), Color(0xFF0F0D14)]), borderRadius: BorderRadius.circular(15), border: Border.all(color: unlocked ? color.withValues(alpha: .55) : Colors.white10)), child: Column(children: [
        Align(alignment: Alignment.topRight, child: Text(unlocked ? card.number : '—', style: TextStyle(fontFamily: 'Arial', color: unlocked ? color : Colors.white24, fontSize: 9, fontWeight: FontWeight.bold))),
        const Spacer(),
        Text(unlocked ? card.symbol : '?', style: TextStyle(fontSize: 30, color: unlocked ? color : Colors.white24)),
        const Spacer(),
        Text(unlocked ? card.name : 'Locked', maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arial', color: unlocked ? MysticColors.mist : MysticColors.muted, fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(unlocked ? _cardRarity(card).toUpperCase() : 'UNDISCOVERED', style: TextStyle(fontFamily: 'Arial', color: unlocked ? color : Colors.white24, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: .7)),
      ])),
    );
  }

  void _showCardDetail(BuildContext context, TarotCardData card) {
    final color = _cardRarityColor(card);
    showDialog<void>(context: context, builder: (dialogContext) => Dialog(backgroundColor: Colors.transparent, insetPadding: const EdgeInsets.all(20), child: Container(padding: const EdgeInsets.fromLTRB(20, 22, 20, 20), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF372451), Color(0xFF17111F)]), borderRadius: BorderRadius.circular(26), border: Border.all(color: color.withValues(alpha: .6))), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Align(alignment: Alignment.centerRight, child: IconButton(onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close))),
      Container(width: 118, height: 176, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withValues(alpha: .35), const Color(0xFF17111F)]), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: .75)), boxShadow: [BoxShadow(color: color.withValues(alpha: .2), blurRadius: 28)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(card.number, style: TextStyle(fontFamily: 'Arial', color: color, fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(height: 18), Text(card.symbol, style: TextStyle(fontSize: 48, color: color))])),
      const SizedBox(height: 18),
      Text(_cardRarity(card).toUpperCase(), style: TextStyle(fontFamily: 'Arial', color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
      const SizedBox(height: 6),
      Text(card.name, textAlign: TextAlign.center, style: Theme.of(dialogContext).textTheme.headlineMedium),
      const SizedBox(height: 20),
      _meaningBlock(dialogContext, 'LIGHT', card.light, MysticColors.gold),
      const SizedBox(height: 10),
      _meaningBlock(dialogContext, 'SHADOW', card.shadow, MysticColors.lavender),
      const SizedBox(height: 10),
      _meaningBlock(dialogContext, 'ALIGNED ACTION', card.advice, color),
    ])))));
  }

  Widget _meaningBlock(BuildContext context, String label, String text, Color color) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .045), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withValues(alpha: .16))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontFamily: 'Arial', color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.1)), const SizedBox(height: 6), Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MysticColors.mist))]));

}

class _WeeklyMirror extends StatelessWidget {
  const _WeeklyMirror({required this.records});
  final List<ReadingRecord> records;

  @override
  Widget build(BuildContext context) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent = records.where((record) => record.createdAt.isAfter(weekAgo)).toList();
    final emotion = _dominantEmotion(recent);
    final card = _mostFrequentCard(recent);
    return InkWell(
      onTap: () => _showWrapped(context, recent, emotion, card),
      borderRadius: BorderRadius.circular(22),
      child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7550BA), Color(0xFF2A1D48)]), borderRadius: BorderRadius.circular(22), border: Border.all(color: MysticColors.lavender.withValues(alpha: .3))), child: Row(children: [
        Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), shape: BoxShape.circle), child: Text(recent.isEmpty ? '☾' : emotion.symbol, style: const TextStyle(fontSize: 26, color: MysticColors.gold))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('YOUR WEEKLY MYSTIC WRAPPED', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)), const SizedBox(height: 6), Text(recent.isEmpty ? 'Your story is waiting for its first signal.' : '${emotion.label} led your week • ${recent.length} reflections', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14))])),
        const Icon(Icons.arrow_forward, color: MysticColors.mist),
      ])),
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
    return counts.isEmpty ? 'No card yet' : counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  void _showWrapped(BuildContext context, List<ReadingRecord> recent, EmotionalState emotion, String card) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF171128), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))), builder: (context) => Padding(padding: const EdgeInsets.fromLTRB(22, 14, 22, 32), child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8))),
      const SizedBox(height: 25),
      const Text('✦  MYSTIC WRAPPED', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
      const SizedBox(height: 18),
      Text(recent.isEmpty ? 'Your first pattern begins with one honest reading.' : '${emotion.symbol} ${emotion.label} was your dominant inner weather.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 22),
      Row(children: [_wrappedStat(context, '${recent.length}', 'REFLECTIONS'), const SizedBox(width: 10), _wrappedStat(context, card, 'REPEATING CARD')]),
      const SizedBox(height: 16),
      Text(recent.isEmpty ? 'Complete a reading and return here to watch your emotional patterns become visible.' : 'Your invitation: notice where ${emotion.label.toLowerCase()} energy protected you—and where it quietly chose for you.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 24),
      GoldButton(label: recent.isEmpty ? 'Begin my first reading' : 'Keep building my pattern', onPressed: () => Navigator.pop(context), icon: Icons.auto_awesome),
    ]))));
  }

  Widget _wrappedStat(BuildContext context, String value, String label) => Expanded(child: Container(height: 104, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.white10)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 7), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: .8))])));
}

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter({required this.unlocked, required this.pulse});
  final int unlocked;
  final double pulse;
  static const points = <Offset>[Offset(.12, .65), Offset(.24, .38), Offset(.39, .58), Offset(.53, .29), Offset(.67, .52), Offset(.82, .25), Offset(.9, .62), Offset(.58, .76), Offset(.31, .79)];

  @override
  void paint(Canvas canvas, Size size) {
    final active = unlocked.clamp(0, points.length);
    final line = Paint()..color = MysticColors.lavender.withValues(alpha: .18 + pulse * .1)..strokeWidth = 1.2;
    for (var i = 1; i < active; i++) {
      canvas.drawLine(_at(points[i - 1], size), _at(points[i], size), line);
    }
    for (var i = 0; i < points.length; i++) {
      final on = i < active;
      final point = _at(points[i], size);
      if (on) {
        canvas.drawCircle(point, 7 + pulse * 3, Paint()..color = MysticColors.gold.withValues(alpha: .08));
      }
      canvas.drawCircle(point, on ? 2.8 : 1.5, Paint()..color = on ? MysticColors.gold : Colors.white.withValues(alpha: .15));
    }
  }

  Offset _at(Offset value, Size size) => Offset(value.dx * size.width, value.dy * size.height);
  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) => oldDelegate.unlocked != unlocked || oldDelegate.pulse != pulse;
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({required this.records, super.key});
  final List<ReadingRecord> records;
  @override
  Widget build(BuildContext context) => MysticBackground(child: Padding(padding: const EdgeInsets.fromLTRB(20, 28, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your journal', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('A record of the patterns you are learning to see.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 22),
        Expanded(child: records.isEmpty ? const _EmptyJournal() : ListView.separated(itemCount: records.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) {
          final item = records[i];
          return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .055), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: .08))), child: Row(children: [CircleAvatar(backgroundColor: MysticColors.violet.withValues(alpha: .35), child: Text(item.emotion.symbol, style: const TextStyle(color: MysticColors.gold))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.kind.title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 4), Text('${item.emotion.label} • 24h Mirror pending', maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)])), const Icon(Icons.chevron_right, color: MysticColors.muted)]));
        }))
      ])));
}

class _EmptyJournal extends StatelessWidget {
  const _EmptyJournal();
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('☾', style: TextStyle(fontSize: 58, color: MysticColors.gold)), const SizedBox(height: 16), Text('Your story begins here', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 7), Text('Save a reading and it will appear in your private journal.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium)]));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.userName, required this.intention, required this.streak, required this.xp, required this.readings, required this.discovered, required this.relics, required this.records, required this.deckStyle, required this.onSelectDeckStyle, required this.onUpdateProfile, required this.onDeleteData, required this.onPremium, super.key});
  final String userName;
  final String intention;
  final int streak;
  final int xp;
  final int readings;
  final int discovered;
  final int relics;
  final List<ReadingRecord> records;
  final DeckStyle deckStyle;
  final ValueChanged<DeckStyle> onSelectDeckStyle;
  final void Function(String name, String intention) onUpdateProfile;
  final VoidCallback onDeleteData;
  final VoidCallback onPremium;

  @override
  Widget build(BuildContext context) {
    final level = xp ~/ 100 + 1;
    final progress = (xp % 100) / 100;
    final badges = <(String, String, bool, String)>[
      ('First Signal', '✦', readings >= 1, 'Save 1 reading'),
      ('Flame Keeper', '🔥', streak >= 3, 'Reach a 3-day streak'),
      ('Arcana Seeker', '◈', discovered >= 10, 'Awaken 10 cards'),
      ('Relic Keeper', '♛', relics >= 1, 'Claim an XP relic'),
    ];
    return MysticBackground(child: ListView(padding: const EdgeInsets.fromLTRB(20, 28, 20, 28), children: [
        Text('Your space', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 22),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const RadialGradient(center: Alignment(0, -.9), radius: 1.35, colors: [Color(0xFF4B3471), Color(0xFF191326)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: MysticColors.lavender.withValues(alpha: .24))), child: Column(children: [
          Container(width: 78, height: 78, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF8B63D6), Color(0xFF3B285F)]), border: Border.all(color: MysticColors.gold.withValues(alpha: .55), width: 2), boxShadow: [BoxShadow(color: MysticColors.violet.withValues(alpha: .3), blurRadius: 28)]), child: const Text('☾', style: TextStyle(fontSize: 34, color: MysticColors.gold))),
          const SizedBox(height: 12),
          Text(userName.isEmpty ? _titleForLevel(level) : userName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${_titleForLevel(level).toUpperCase()} • $intention PATH • LEVEL $level', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .8)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_stat('$streak', 'day streak'), _stat('$readings', 'readings'), _stat('$discovered', 'arcana')]),
          const SizedBox(height: 18),
          Row(children: [Text('$xp XP', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 11, fontWeight: FontWeight.bold)), const Spacer(), Text('${100 - (xp % 100)} XP to level ${level + 1}', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 10))]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: Colors.white10, color: MysticColors.gold)),
        ])),
        const SizedBox(height: 22),
        Row(children: [Text('Mystic achievements', style: Theme.of(context).textTheme.titleLarge), const Spacer(), Text('${badges.where((badge) => badge.$3).length}/${badges.length}', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 6),
        Text('Your practice leaves permanent marks on your path.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, childAspectRatio: 1.48, crossAxisSpacing: 10, mainAxisSpacing: 10, children: badges.map((badge) => _badge(context, badge.$1, badge.$2, badge.$3, badge.$4)).toList()),
        const SizedBox(height: 24),
        Text('Your tarot deck', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('Choose the visual energy that follows every reading.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        SizedBox(height: 178, child: ListView(scrollDirection: Axis.horizontal, children: DeckStyle.values.map((style) => _deckOption(context, style)).toList())),
        const SizedBox(height: 14),
        InkWell(onTap: onPremium, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6847B7), Color(0xFF312057)]), borderRadius: BorderRadius.circular(22)), child: const Row(children: [Text('✦', style: TextStyle(fontSize: 28, color: MysticColors.gold)), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Unlock Mystic Plus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Go deeper with unlimited readings', style: TextStyle(fontFamily: 'Arial', color: MysticColors.lavender))])), Icon(Icons.arrow_forward)]))),
        const SizedBox(height: 18),
        ListTile(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SoulProfileScreen(initialName: userName, initialIntention: intention, onSave: onUpdateProfile))), contentPadding: const EdgeInsets.symmetric(horizontal: 4), leading: const Icon(Icons.fingerprint, color: MysticColors.gold), title: const Text('Soul profile', style: TextStyle(fontFamily: 'Arial')), subtitle: Text(userName.isEmpty ? '$intention path' : '$userName • $intention path', style: Theme.of(context).textTheme.bodyMedium), trailing: const Icon(Icons.chevron_right)),
        ...['Reading preferences', 'Daily reminder', 'Privacy & data', 'Help and support'].map((label) => ListTile(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MysticSettingsScreen(section: label, records: records, onDeleteData: onDeleteData))), contentPadding: const EdgeInsets.symmetric(horizontal: 4), leading: const Icon(Icons.auto_awesome_outlined, color: MysticColors.lavender), title: Text(label, style: const TextStyle(fontFamily: 'Arial')), trailing: const Icon(Icons.chevron_right))),
      ]));
  }

  String _titleForLevel(int level) {
    if (level >= 10) return 'Astral Sage';
    if (level >= 6) return 'Mystic Oracle';
    if (level >= 3) return 'Arcana Seeker';
    return 'Mystic Initiate';
  }

  Widget _badge(BuildContext context, String title, String symbol, bool unlocked, String goal) => AnimatedContainer(duration: const Duration(milliseconds: 350), padding: const EdgeInsets.all(13), decoration: BoxDecoration(gradient: unlocked ? const LinearGradient(colors: [Color(0xFF4A326D), Color(0xFF21172F)]) : const LinearGradient(colors: [Color(0xFF1D1924), Color(0xFF121017)]), borderRadius: BorderRadius.circular(17), border: Border.all(color: unlocked ? MysticColors.gold.withValues(alpha: .45) : Colors.white10)), child: Row(children: [
    Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: unlocked ? MysticColors.gold.withValues(alpha: .14) : Colors.white.withValues(alpha: .035), shape: BoxShape.circle), child: Text(unlocked ? symbol : '🔒', style: TextStyle(fontSize: unlocked ? 21 : 15, color: MysticColors.gold))),
    const SizedBox(width: 9),
    Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Arial', color: unlocked ? MysticColors.mist : MysticColors.muted, fontSize: 11, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(unlocked ? 'UNLOCKED' : goal, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Arial', color: unlocked ? MysticColors.gold : MysticColors.muted, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: unlocked ? .7 : 0))]))
  ]));

  Widget _deckOption(BuildContext context, DeckStyle style) {
    final unlocked = style == DeckStyle.midnight || (style == DeckStyle.solarGold && discovered >= 10) || (style == DeckStyle.bloodMoon && xp >= 400);
    final active = deckStyle == style;
    final accent = _deckAccent(style);
    return InkWell(
      onTap: unlocked ? () => onSelectDeckStyle(style) : null,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(duration: const Duration(milliseconds: 350), width: 132, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: unlocked ? _deckColors(style) : const [Color(0xFF1C1822), Color(0xFF100E14)]), borderRadius: BorderRadius.circular(18), border: Border.all(color: active ? accent : unlocked ? accent.withValues(alpha: .35) : Colors.white10, width: active ? 2 : 1)), child: Column(children: [
        Align(alignment: Alignment.topRight, child: Icon(active ? Icons.check_circle : unlocked ? Icons.radio_button_unchecked : Icons.lock, color: active ? accent : MysticColors.muted, size: 16)),
        Text(unlocked ? style.symbol : '◈', style: TextStyle(fontSize: 34, color: unlocked ? accent : Colors.white24)),
        const Spacer(),
        Text(style.label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arial', color: unlocked ? MysticColors.mist : MysticColors.muted, fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(active ? 'ACTIVE DECK' : style.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arial', color: active ? accent : MysticColors.muted, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: active ? .6 : 0)),
      ])),
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

  Widget _stat(String value, String label) => Column(children: [Text(value, style: const TextStyle(fontFamily: 'Arial', fontSize: 20, color: MysticColors.gold, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 12))]);
}

class SoulProfileScreen extends StatefulWidget {
  const SoulProfileScreen({required this.initialName, required this.initialIntention, required this.onSave, super.key});
  final String initialName;
  final String initialIntention;
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
    return Scaffold(appBar: AppBar(title: const Text('Soul profile')), body: MysticBackground(child: ListView(padding: const EdgeInsets.fromLTRB(22, 24, 22, 30), children: [
      const Center(child: Text('◉', style: TextStyle(fontSize: 58, color: MysticColors.gold))),
      const SizedBox(height: 12),
      Text('Make Mystic yours', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text('Your name and intention shape the language, memory, and guidance around every reading.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 28),
      TextField(controller: name, maxLength: 18, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Your name', prefixIcon: Icon(Icons.person_outline))),
      const SizedBox(height: 18),
      const Text('YOUR CURRENT PATH', style: TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
      const SizedBox(height: 10),
      Wrap(spacing: 9, runSpacing: 9, children: choices.map((choice) => ChoiceChip(label: Text(choice), selected: intention == choice, onSelected: (_) => setState(() => intention = choice), selectedColor: MysticColors.violet)).toList()),
      const SizedBox(height: 30),
      GoldButton(label: 'Save my soul profile', icon: Icons.auto_awesome, onPressed: () { widget.onSave(name.text, intention); Navigator.pop(context); }),
      const SizedBox(height: 10),
      const Text('Stored privately on this device.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 9)),
    ])));
  }
}

class MysticSettingsScreen extends StatefulWidget {
  const MysticSettingsScreen({required this.section, required this.records, required this.onDeleteData, super.key});
  final String section;
  final List<ReadingRecord> records;
  final VoidCallback onDeleteData;

  @override
  State<MysticSettingsScreen> createState() => _MysticSettingsScreenState();
}

class _MysticSettingsScreenState extends State<MysticSettingsScreen> {
  bool allowReversals = true;
  bool reminderEnabled = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(() {
        allowReversals = prefs.getBool('allow_reversals') ?? true;
        reminderEnabled = prefs.getBool('daily_reminder') ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.section)), body: MysticBackground(child: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 30), children: _content(context))));

  List<Widget> _content(BuildContext context) {
    if (widget.section == 'Reading preferences') {
      return [
        _intro(context, 'Shape every reading', 'Mystic should adapt to your practice—not ask you to adapt to it.'),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Allow reversed cards'), subtitle: const Text('Adds shadow meanings to approximately one in four cards.'), value: allowReversals, activeThumbColor: MysticColors.gold, onChanged: (value) async { setState(() => allowReversals = value); final prefs = await SharedPreferences.getInstance(); await prefs.setBool('allow_reversals', value); }),
        const Divider(),
        const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.psychology_alt_outlined, color: MysticColors.lavender), title: Text('Reflection-first guidance'), subtitle: Text('Readings remain grounded invitations—not certainty, diagnosis, or professional advice.')),
      ];
    }
    if (widget.section == 'Daily reminder') {
      return [
        _intro(context, 'Protect your daily ritual', 'A gentle return works better than endless notifications.'),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Daily Guidance reminder'), subtitle: Text(reminderEnabled ? 'Scheduled for 9:00 AM on supported mobile devices.' : 'Off'), value: reminderEnabled, activeThumbColor: MysticColors.gold, onChanged: (value) async { setState(() => reminderEnabled = value); final prefs = await SharedPreferences.getInstance(); await prefs.setBool('daily_reminder', value); }),
        const SizedBox(height: 12),
        _notice('Web preview note', 'Notification permission and system scheduling activate in the native iOS/Android release.'),
      ];
    }
    if (widget.section == 'Privacy & data') {
      return [
        _intro(context, 'Your inner world stays yours', 'This preview keeps your journal and progress locally on this device. No questions are sold to advertisers.'),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.download_outlined, color: MysticColors.gold), title: const Text('Export my journal'), subtitle: Text('${widget.records.length} saved readings'), trailing: const Icon(Icons.chevron_right), onTap: _exportJournal),
        const Divider(),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.delete_outline, color: Color(0xFFFF8090)), title: const Text('Delete all Mystic data'), subtitle: const Text('Permanently removes local journal, XP, streak, and settings.'), onTap: _confirmDelete),
        const SizedBox(height: 14),
        _notice('Entertainment & reflection', 'Mystic Tarot is designed for personal reflection and entertainment. It does not provide medical, legal, financial, or mental-health advice.'),
      ];
    }
    return [
      _intro(context, 'We are here to help', 'Clear answers before you begin your next ritual.'),
      _faq('Does Mystic predict the future?', 'No. It uses tarot symbolism as a structured mirror for reflection and possible perspectives.'),
      _faq('Can I cancel Mystic Plus?', 'Yes. Subscriptions can be managed and cancelled through Apple or Google account settings.'),
      _faq('How do I restore a purchase?', 'Open Mystic Plus and choose Restore. It will reconnect purchases made with the same store account.'),
      _faq('Is my journal private?', 'In this preview it is stored locally on your device. Before cloud accounts launch, the privacy policy will identify every processor and retention period.'),
      const SizedBox(height: 10),
      GoldButton(label: 'Copy support link', icon: Icons.support_agent, onPressed: () async { await Clipboard.setData(const ClipboardData(text: 'https://github.com/tuna777123/mystic-tarot/issues')); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support link copied.'))); }),
    ];
  }

  Widget _intro(BuildContext context, String title, String body) => Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), Text(body, style: Theme.of(context).textTheme.bodyLarge)]));
  Widget _notice(String title, String body) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .05), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.bold)), const SizedBox(height: 7), Text(body, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.muted, height: 1.45))]));
  Widget _faq(String question, String answer) => ExpansionTile(tilePadding: EdgeInsets.zero, childrenPadding: const EdgeInsets.only(bottom: 14), title: Text(question, style: const TextStyle(fontFamily: 'Arial', fontSize: 14, fontWeight: FontWeight.bold)), children: [Align(alignment: Alignment.centerLeft, child: Text(answer, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.muted, height: 1.45)))]);

  Future<void> _exportJournal() async {
    final text = widget.records.isEmpty ? 'Mystic Tarot Journal\n\nNo saved readings yet.' : widget.records.map((record) => '${record.createdAt.toLocal()} — ${record.kind.title}\n${record.cards.map((item) => '${item.card.name}${item.reversed ? ' (Reversed)' : ''}').join(', ')}\nAligned action: ${record.alignedAction}').join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your journal was copied for export.')));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Delete all Mystic data?'), content: const Text('This cannot be undone. Your journal, card collection, streak, XP, and preferences will be removed from this device.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep my data')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete everything', style: TextStyle(color: Color(0xFFFF8090))))])) ?? false;
    if (!confirmed || !mounted) return;
    Navigator.pop(context);
    widget.onDeleteData();
  }
}

class PremiumReadingPreview extends StatefulWidget {
  const PremiumReadingPreview({required this.kind, required this.deckStyle, required this.onUnlock, super.key});
  final ReadingKind kind;
  final DeckStyle deckStyle;
  final VoidCallback onUnlock;

  @override
  State<PremiumReadingPreview> createState() => _PremiumReadingPreviewState();
}

class _PremiumReadingPreviewState extends State<PremiumReadingPreview> {
  bool revealed = false;
  late final DrawnCard previewCard;

  @override
  void initState() {
    super.initState();
    final seed = DateTime.now().day + widget.kind.index * 13;
    previewCard = DrawnCard(tarotDeck[seed % tarotDeck.length], seed.isOdd);
    Future<void>.delayed(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => revealed = true);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: MysticBackground(child: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 30), children: [
        Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: MysticColors.gold.withValues(alpha: .13), borderRadius: BorderRadius.circular(20), border: Border.all(color: MysticColors.gold.withValues(alpha: .35))), child: const Text('PLUS PREVIEW', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)))]),
        const SizedBox(height: 12),
        Text(widget.kind.symbol, textAlign: TextAlign.center, style: const TextStyle(fontSize: 38, color: MysticColors.gold)),
        const SizedBox(height: 7),
        Text(widget.kind.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('One card is yours. The complete ${widget.kind.cardCount}-card story waits behind it.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        Center(child: AnimatedSwitcher(duration: const Duration(milliseconds: 650), transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: Tween(begin: .82, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)), child: child)), child: TarotCardFace(key: ValueKey(revealed), drawn: revealed ? previewCard : null, selected: revealed, style: widget.deckStyle, width: 142, height: 222))),
        const SizedBox(height: 20),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 500),
          crossFadeState: revealed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: MysticColors.gold)), SizedBox(width: 10), Text('The first signal is forming…', style: TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 11))])),
          secondChild: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B285A), Color(0xFF1B1428)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: MysticColors.gold.withValues(alpha: .25))), child: Column(children: [const Text('YOUR FIRST SIGNAL', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.25)), const SizedBox(height: 8), Text(previewCard.card.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 7), Text(previewCard.reversed ? previewCard.card.shadow : previewCard.card.light, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge), const SizedBox(height: 8), Text(previewCard.reversed ? 'Reversed energy' : 'Upright energy', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 9, fontWeight: FontWeight.bold))])),
        ),
        const SizedBox(height: 22),
        Row(children: [Text('The rest of your spread', style: Theme.of(context).textTheme.titleLarge), const Spacer(), Text('${widget.kind.cardCount - 1} LOCKED', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .8))]),
        const SizedBox(height: 12),
        SizedBox(height: 104, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: widget.kind.cardCount - 1, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, index) => Stack(alignment: Alignment.center, children: [Opacity(opacity: .48, child: TarotCardFace(style: widget.deckStyle, width: 64, height: 100)), Container(width: 29, height: 29, decoration: BoxDecoration(color: const Color(0xFF171122).withValues(alpha: .92), shape: BoxShape.circle, border: Border.all(color: MysticColors.gold.withValues(alpha: .45))), child: const Icon(Icons.lock, size: 14, color: MysticColors.gold))]))),
        const SizedBox(height: 22),
        GoldButton(label: 'Unlock the full ${widget.kind.title}', onPressed: widget.onUnlock, icon: Icons.auto_awesome),
        const SizedBox(height: 9),
        const Text('Included with Mystic Plus • Cancel anytime', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 9)),
      ]))));
}

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({required this.source, super.key});
  final String source;

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int plan = 2;

  @override
  Widget build(BuildContext context) => Scaffold(body: MysticBackground(child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 30), children: [
        Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)), const Spacer(), TextButton(onPressed: _restore, child: const Text('Restore'))]),
        Container(width: 74, height: 74, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFFFFE5A3), Color(0xFF9D6D26)]), boxShadow: [BoxShadow(color: MysticColors.gold.withValues(alpha: .32), blurRadius: 32)]), child: const Text('✦', style: TextStyle(fontSize: 39, color: MysticColors.ink))),
        const SizedBox(height: 8),
        if (widget.source == 'premium_spread') const Text('PREMIUM SPREAD COLLECTION', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
        if (widget.source == 'premium_spread') const SizedBox(height: 7),
        Text(widget.source == 'daily_limit' ? 'Your insight does not\nhave to stop here.' : widget.source == 'premium_spread' ? 'Some questions need\na deeper spread.' : 'Make space for\ndeeper insight.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 12),
        Text(widget.source == 'daily_limit' ? 'You used today’s three free deep readings. Daily Guidance stays free—or unlock every spread without limits.' : widget.source == 'premium_spread' ? 'Unlock Love Compatibility, Future Timeline, Celtic Cross, and every premium reading in one membership.' : 'Turn occasional readings into a private practice that grows more useful every day.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        ...['Unlimited readings and every spread', 'Complete journal and weekly pattern history', 'All premium tarot deck themes', 'Future Plus features included', 'No ads—ever'].map((item) => Padding(padding: const EdgeInsets.only(bottom: 11), child: Row(children: [const CircleAvatar(radius: 11, backgroundColor: MysticColors.gold, child: Icon(Icons.check, size: 14, color: MysticColors.ink)), const SizedBox(width: 11), Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyLarge))]))),
        const SizedBox(height: 12),
        SizedBox(height: 128, child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _plan(0, 'Weekly', r'$4.99', 'per week')),
          const SizedBox(width: 8),
          Expanded(child: _plan(1, 'Monthly', r'$9.99', 'per month')),
          const SizedBox(width: 8),
          Expanded(child: _plan(2, 'Yearly', r'$39.99', r'$3.33/month', badge: 'SAVE 67%')),
        ])),
        const SizedBox(height: 18),
        GoldButton(label: plan == 2 ? 'Start my 7-day free trial' : 'Continue with ${plan == 0 ? 'weekly' : 'monthly'}', onPressed: _beginPurchase, icon: Icons.lock_open_rounded),
        const SizedBox(height: 10),
        Text(plan == 2 ? r'No charge today. Then $39.99/year unless cancelled.' : 'Cancel anytime in your App Store or Google Play settings.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 10),
        const Text('Subscription purchases use the official Apple or Google checkout.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 9, height: 1.4)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [TextButton(onPressed: () => _openLegal('Terms of Use'), child: const Text('Terms')), const Text('•', style: TextStyle(color: MysticColors.muted)), TextButton(onPressed: () => _openLegal('Privacy Policy'), child: const Text('Privacy'))]),
      ])));

  Widget _plan(int index, String title, String price, String subtitle, {String? badge}) {
    final active = plan == index;
    return InkWell(onTap: () => setState(() => plan = index), borderRadius: BorderRadius.circular(18), child: Stack(clipBehavior: Clip.none, children: [Container(padding: const EdgeInsets.fromLTRB(8, 17, 8, 12), decoration: BoxDecoration(color: active ? MysticColors.violet.withValues(alpha: .35) : Colors.white.withValues(alpha: .04), borderRadius: BorderRadius.circular(18), border: Border.all(color: active ? MysticColors.gold : Colors.white12, width: active ? 2 : 1)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.bold, fontSize: 11)), const SizedBox(height: 7), Text(price, style: TextStyle(fontFamily: 'Arial', fontSize: index == 2 ? 18 : 16, fontWeight: FontWeight.bold, color: MysticColors.gold)), const SizedBox(height: 3), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', fontSize: 9, color: MysticColors.muted))])), if (badge != null) Positioned(top: -7, left: 7, right: 7, child: Container(padding: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: MysticColors.gold, borderRadius: BorderRadius.circular(12)), child: Text(badge, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.ink, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: .6))))]));
  }

  void _beginPurchase() {
    showModalBottomSheet<void>(context: context, backgroundColor: const Color(0xFF171128), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(22, 16, 22, 28), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8))), const SizedBox(height: 22), const Icon(Icons.verified_user_outlined, color: MysticColors.gold, size: 40), const SizedBox(height: 12), Text('Store checkout is the final launch connection.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 9), Text('This web preview cannot charge you. Apple/Google billing will activate after the store products and merchant accounts are connected.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 18), GoldButton(label: 'Understood', onPressed: () => Navigator.pop(context))]))));
  }

  void _restore() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore Purchases activates with the native store billing connection.')));
  }

  void _openLegal(String title) => Navigator.push(context, MaterialPageRoute(builder: (_) => LegalDocumentScreen(title: title)));
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    final privacy = title == 'Privacy Policy';
    return Scaffold(appBar: AppBar(title: Text(title)), body: MysticBackground(child: ListView(padding: const EdgeInsets.all(22), children: [
      Text(privacy ? 'Privacy, in plain language' : 'A fair mystical space', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 12),
      Text(privacy ? 'Mystic Tarot currently stores onboarding choices, journal entries, progress, and preferences locally on your device. The web preview does not create an account, sell personal data, or process real payments. You can export or delete your local data from Privacy & data.' : 'Mystic Tarot is a self-reflection and entertainment product. Readings are symbolic prompts, not factual predictions or substitutes for medical, mental-health, legal, or financial advice. Premium access will renew according to the plan shown at checkout and can be cancelled through the store account used to subscribe.', style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 20),
      _legalSection(context, privacy ? 'When services are connected' : 'Subscriptions', privacy ? 'Before accounts, analytics, notifications, AI services, or cloud sync are activated, this policy will identify each provider, purpose, retention period, and deletion method. Store checkout data is handled by Apple, Google, and the configured subscription processor under their own policies.' : 'The exact localized price, renewal period, trial eligibility, and billing date shown by Apple or Google at confirmation control the purchase. Restore Purchases reconnects eligible access on the same store account.'),
      _legalSection(context, privacy ? 'Your control' : 'Acceptable use', privacy ? 'You may export your journal and permanently delete all local Mystic data at any time from the profile. Deleting browser storage or uninstalling the preview may also remove local records.' : 'Do not rely on a reading for emergencies or high-stakes decisions. You remain responsible for your choices and should consult a qualified professional where appropriate.'),
      const SizedBox(height: 12),
      const Text('Preview policy • Last updated July 19, 2026', style: TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 10)),
    ])));
  }

  static Widget _legalSection(BuildContext context, String title, String body) => Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 7), Text(body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55))]));
}
