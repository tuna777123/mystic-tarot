import 'dart:math';

import 'package:flutter/material.dart';

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
  final navigatorKey = GlobalKey<NavigatorState>();
  bool onboarded = false;
  int tab = 0;
  int streak = 3;
  int xp = 140;
  final List<ReadingRecord> journal = [];
  final Set<String> discoveredCards = {};
  final Set<String> completedRituals = {};

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Mystic Tarot',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: buildMysticTheme(),
        home: onboarded ? _shell() : OnboardingScreen(onDone: () => setState(() => onboarded = true)),
      );

  Widget _shell() => Scaffold(
        body: IndexedStack(index: tab, children: [
          HomeScreen(streak: streak, xp: xp, onReading: _startReading, onPremium: _showPremium),
          JourneyScreen(streak: streak, xp: xp, discoveredCards: discoveredCards, completedRituals: completedRituals, onCompleteRitual: _completeRitual),
          JournalScreen(records: journal),
          ProfileScreen(streak: streak, xp: xp, readings: journal.length, onPremium: _showPremium),
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
    navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => ReadingFlow(kind: kind, onComplete: (record) {
      setState(() {
        journal.insert(0, record);
        discoveredCards.addAll(record.cards.map((item) => item.card.name));
        xp += 25;
        streak = max(streak, 4);
      });
    })));
  }

  void _completeRitual(String id) {
    if (completedRituals.contains(id)) return;
    setState(() {
      completedRituals.add(id);
      xp += 15;
    });
  }

  void _showPremium() => navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => const PremiumScreen()));
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onDone, super.key});
  final VoidCallback onDone;

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
          GoldButton(label: page == 2 ? 'Enter Mystic' : 'Continue', onPressed: () => page < 2 ? setState(() => page++) : widget.onDone()),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.streak, required this.xp, required this.onReading, required this.onPremium, super.key});
  final int streak;
  final int xp;
  final ValueChanged<ReadingKind> onReading;
  final VoidCallback onPremium;

  @override
  Widget build(BuildContext context) => MysticBackground(child: CustomScrollView(slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 10), sliver: SliverList(delegate: SliverChildListDelegate([
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good evening', style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 4), Text('Your cards are waiting', style: Theme.of(context).textTheme.titleLarge)]),
            InkWell(onTap: onPremium, borderRadius: BorderRadius.circular(30), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: MysticColors.gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(30), border: Border.all(color: MysticColors.gold.withValues(alpha: .4))), child: const Row(children: [Text('✦ ', style: TextStyle(color: MysticColors.gold)), Text('PLUS', style: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.w800, color: MysticColors.gold, fontSize: 12))]))),
          ]),
          const SizedBox(height: 18),
          const _MoonBriefing(),
          const SizedBox(height: 14),
          _DailyCard(streak: streak, onTap: () => onReading(ReadingKind.daily)),
          const SizedBox(height: 26),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Choose a reading', style: Theme.of(context).textTheme.titleLarge), Text('$xp XP', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
        ]))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28), sliver: SliverGrid(delegate: SliverChildBuilderDelegate((context, index) {
          final kind = ReadingKind.values.skip(1).elementAt(index);
          return InkWell(onTap: () => onReading(kind), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .055), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: .08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(kind.symbol, style: const TextStyle(fontSize: 27, color: MysticColors.gold)), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(kind.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 5), Text('${kind.cardCount} cards', style: Theme.of(context).textTheme.bodyMedium)])])));
        }, childCount: ReadingKind.values.length - 1), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.12, crossAxisSpacing: 12, mainAxisSpacing: 12))),
      ]));
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
  const _DailyCard({required this.streak, required this.onTap});
  final int streak;
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
  Widget build(BuildContext context) => AnimatedBuilder(animation: controller, builder: (context, child) => InkWell(onTap: widget.onTap, borderRadius: BorderRadius.circular(24), child: Container(height: 196, padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.lerp(const Color(0xFF6C45B5), const Color(0xFF8356C5), controller.value)!, const Color(0xFF251944)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: MysticColors.lavender.withValues(alpha: .32 + controller.value * .18)), boxShadow: [BoxShadow(color: MysticColors.violet.withValues(alpha: .12 + controller.value * .08), blurRadius: 28, spreadRadius: 1)]), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('YOUR DAILY PORTAL', style: TextStyle(fontFamily: 'Arial', letterSpacing: 1.8, color: MysticColors.lavender, fontSize: 11, fontWeight: FontWeight.bold)), const Spacer(), Text('Reveal what\nneeds you today', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), Text('🔥 ${widget.streak} day streak  •  +25 XP', style: Theme.of(context).textTheme.bodyMedium)])), const TarotCardFace(width: 90, height: 142)]))));
}

class ReadingFlow extends StatefulWidget {
  const ReadingFlow({required this.kind, required this.onComplete, super.key});
  final ReadingKind kind;
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
        Expanded(child: GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 18), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: .62, crossAxisSpacing: 8, mainAxisSpacing: 10), itemCount: 12, itemBuilder: (_, i) => GestureDetector(onTap: () => _toggle(i), child: TarotCardFace(selected: selected.contains(i), width: 65, height: 110)))),
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
      drawn = List.generate(widget.kind.cardCount, (i) => DrawnCard(pool[i], random.nextInt(4) == 0));
      revealComplete = false;
    });
    await Future<void>.delayed(Duration(milliseconds: 850 + widget.kind.cardCount * 520));
    if (mounted) setState(() => revealComplete = true);
  }

  Widget _result(BuildContext context) {
    final record = ReadingRecord(kind: widget.kind, question: question.text.trim(), cards: drawn!, createdAt: DateTime.now(), emotion: emotion, alignedAction: _alignedAction());
    return CustomScrollView(slivers: [
      SliverAppBar(backgroundColor: Colors.transparent, title: const Text('Your reading'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share_outlined))]),
      SliverPadding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 36), sliver: SliverList(delegate: SliverChildListDelegate([
        Text(_headline(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 10),
        Text('Take what resonates. Tarot is a mirror for reflection—not a fixed prediction.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        SizedBox(height: 190, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 4), itemBuilder: (_, i) => _RitualRevealCard(card: drawn![i], delay: Duration(milliseconds: 350 + i * 520)), separatorBuilder: (_, __) => const SizedBox(width: 12), itemCount: drawn!.length)),
        const SizedBox(height: 26),
        if (!revealComplete) _ReadingInProgress(cardCount: drawn!.length),
        if (revealComplete) ...drawn!.asMap().entries.map((entry) => _interpretation(context, entry.key, entry.value)),
        if (revealComplete) Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: MysticColors.gold.withValues(alpha: .09), borderRadius: BorderRadius.circular(20), border: Border.all(color: MysticColors.gold.withValues(alpha: .3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('✦  YOUR GUIDANCE', style: TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.bold, letterSpacing: 1)), const SizedBox(height: 12), Text(_guidance(), style: Theme.of(context).textTheme.bodyLarge)])),
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

  String _headline() => drawn!.any((c) => c.card.name == 'The Star' || c.card.name == 'The Sun') ? 'A hopeful path is becoming visible.' : 'The truth arrives when you slow down.';
  String _guidance() => '${drawn!.last.card.advice} Let this be an invitation, not a command. Notice what changes when you carry this question through the next twenty-four hours.';
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
  const _RitualRevealCard({required this.card, required this.delay});
  final DrawnCard card;
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
              child: TarotCardFace(drawn: showFace ? widget.card : null),
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
  const JourneyScreen({required this.streak, required this.xp, required this.discoveredCards, required this.completedRituals, required this.onCompleteRitual, super.key});
  final int streak;
  final int xp;
  final Set<String> discoveredCards;
  final Set<String> completedRituals;
  final ValueChanged<String> onCompleteRitual;

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
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF33245C), Color(0xFF1A142D)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: MysticColors.lavender.withValues(alpha: .2))), child: Row(children: [const Text('🔥', style: TextStyle(fontSize: 30)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${widget.streak}-day flame', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 4), Text('Return tomorrow to keep your constellation alive.', style: Theme.of(context).textTheme.bodyMedium)]))])),
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

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter({required this.unlocked, required this.pulse});
  final int unlocked;
  final double pulse;
  static const points = <Offset>[Offset(.12, .65), Offset(.24, .38), Offset(.39, .58), Offset(.53, .29), Offset(.67, .52), Offset(.82, .25), Offset(.9, .62), Offset(.58, .76), Offset(.31, .79)];

  @override
  void paint(Canvas canvas, Size size) {
    final active = unlocked.clamp(0, points.length);
    final line = Paint()..color = MysticColors.lavender.withValues(alpha: .18 + pulse * .1)..strokeWidth = 1.2;
    for (var i = 1; i < active; i++) canvas.drawLine(_at(points[i - 1], size), _at(points[i], size), line);
    for (var i = 0; i < points.length; i++) {
      final on = i < active;
      final point = _at(points[i], size);
      if (on) canvas.drawCircle(point, 7 + pulse * 3, Paint()..color = MysticColors.gold.withValues(alpha: .08));
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
  const ProfileScreen({required this.streak, required this.xp, required this.readings, required this.onPremium, super.key});
  final int streak;
  final int xp;
  final int readings;
  final VoidCallback onPremium;
  @override
  Widget build(BuildContext context) => MysticBackground(child: ListView(padding: const EdgeInsets.fromLTRB(20, 28, 20, 28), children: [
        Text('Your space', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 22),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .055), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: .08))), child: Column(children: [const CircleAvatar(radius: 35, backgroundColor: MysticColors.violet, child: Text('☾', style: TextStyle(fontSize: 30, color: MysticColors.gold))), const SizedBox(height: 12), Text('Mystic Explorer', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 18), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_stat('$streak', 'day streak'), _stat('$readings', 'readings'), _stat('$xp', 'XP')])])),
        const SizedBox(height: 14),
        InkWell(onTap: onPremium, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6847B7), Color(0xFF312057)]), borderRadius: BorderRadius.circular(22)), child: const Row(children: [Text('✦', style: TextStyle(fontSize: 28, color: MysticColors.gold)), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Unlock Mystic Plus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Go deeper with unlimited readings', style: TextStyle(fontFamily: 'Arial', color: MysticColors.lavender))])), Icon(Icons.arrow_forward)]))),
        const SizedBox(height: 18),
        ...['Reading preferences', 'Daily reminder', 'Privacy & data', 'Help and support'].map((label) => ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 4), leading: const Icon(Icons.auto_awesome_outlined, color: MysticColors.lavender), title: Text(label, style: const TextStyle(fontFamily: 'Arial')), trailing: const Icon(Icons.chevron_right))),
      ]));
  Widget _stat(String value, String label) => Column(children: [Text(value, style: const TextStyle(fontFamily: 'Arial', fontSize: 20, color: MysticColors.gold, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 12))]);
}

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool yearly = true;
  @override
  Widget build(BuildContext context) => Scaffold(body: MysticBackground(child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 30), children: [
        Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))),
        const Text('✦', textAlign: TextAlign.center, style: TextStyle(fontSize: 48, color: MysticColors.gold)),
        const SizedBox(height: 8),
        Text('Make space for\ndeeper insight.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 12),
        Text('Unlimited reflective readings, richer patterns, and a private spiritual practice built around you.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        ...['Unlimited personalized readings', 'Love compatibility & future timeline', 'Dream reflection and weekly energy', 'Premium card themes', 'No ads, ever'].map((item) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [const CircleAvatar(radius: 12, backgroundColor: MysticColors.gold, child: Icon(Icons.check, size: 15, color: MysticColors.ink)), const SizedBox(width: 12), Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyLarge))]))),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: _plan(false, 'Monthly', r'$8.99', 'per month')), const SizedBox(width: 10), Expanded(child: _plan(true, 'Yearly', r'$39.99', r'only $3.33/month'))]),
        const SizedBox(height: 18),
        GoldButton(label: 'Start 7-day free trial', onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payments connect in the production milestone.')))),
        const SizedBox(height: 10),
        Text('Cancel anytime. No charge today.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
      ])));
  Widget _plan(bool isYearly, String title, String price, String subtitle) {
    final active = yearly == isYearly;
    return InkWell(onTap: () => setState(() => yearly = isYearly), borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: active ? MysticColors.violet.withValues(alpha: .35) : Colors.white.withValues(alpha: .04), borderRadius: BorderRadius.circular(18), border: Border.all(color: active ? MysticColors.gold : Colors.white12, width: active ? 2 : 1)), child: Column(children: [Text(title, style: const TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.bold)), const SizedBox(height: 7), Text(price, style: const TextStyle(fontFamily: 'Arial', fontSize: 22, fontWeight: FontWeight.bold, color: MysticColors.gold)), const SizedBox(height: 3), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: MysticColors.muted))])));
  }
}
