import 'package:flutter/material.dart';

import 'identity_engine.dart';
import 'theme.dart';
import 'widgets.dart';

class MysticIdentityScreen extends StatelessWidget {
  const MysticIdentityScreen({
    required this.snapshot,
    required this.isTurkish,
    required this.onContinueJourney,
    super.key,
  });

  final MysticIdentitySnapshot snapshot;
  final bool isTurkish;
  final VoidCallback onContinueJourney;

  String t(String english, String turkish) => isTurkish ? turkish : english;

  @override
  Widget build(BuildContext context) {
    final progress = snapshot.progressToEvolution.clamp(0.0, 1.0);
    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Text(
                t('YOUR MYSTIC SOUL', 'MİSTİK RUHUN'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 14),
              _IdentityHero(snapshot: snapshot, isTurkish: isTurkish),
              const SizedBox(height: 18),
              _section(
                context,
                title: t('Why Mystic sees this in you', 'Mystic bunu sende neden görüyor'),
                child: Column(
                  children: snapshot.signals
                      .map(
                        (signal) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Icon(Icons.auto_awesome, size: 15, color: MysticColors.gold),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(signal, style: Theme.of(context).textTheme.bodyLarge)),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: 16),
              _section(
                context,
                title: t('Your next evolution', 'Bir sonraki dönüşümün'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            snapshot.nextEvolution,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            color: MysticColors.gold,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: .08),
                        valueColor: const AlwaysStoppedAnimation(MysticColors.gold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t(
                        'Read, reflect, and complete Arcana chapters to evolve this identity naturally.',
                        'Bu kimliği doğal biçimde geliştirmek için oku, düşün ve Arkana bölümlerini tamamla.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GoldButton(
                label: t('Continue my journey', 'Yolculuğuma devam et'),
                icon: Icons.hub_outlined,
                onPressed: onContinueJourney,
              ),
              const SizedBox(height: 10),
              Text(
                t(
                  'Calculated privately on this device from your reading patterns and progress.',
                  'Okuma örüntülerin ve ilerlemen kullanılarak yalnızca bu cihazda hesaplanır.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 9, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, {required String title, required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .045),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: .09)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

class _IdentityHero extends StatelessWidget {
  const _IdentityHero({required this.snapshot, required this.isTurkish});

  final MysticIdentitySnapshot snapshot;
  final bool isTurkish;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7047A8), Color(0xFF2B1941), Color(0xFF130D1D)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .42)),
          boxShadow: [BoxShadow(color: MysticColors.violet.withValues(alpha: .22), blurRadius: 38)],
        ),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF100A18).withValues(alpha: .72),
                border: Border.all(color: MysticColors.gold.withValues(alpha: .6)),
                boxShadow: [BoxShadow(color: MysticColors.gold.withValues(alpha: .13), blurRadius: 28)],
              ),
              child: Text(_symbol(snapshot.primary), style: const TextStyle(fontSize: 42, color: MysticColors.gold)),
            ),
            const SizedBox(height: 16),
            Text(snapshot.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(snapshot.summary, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: .1)),
              ),
              child: Text(
                isTurkish ? '%${snapshot.confidence} kimlik güveni' : '${snapshot.confidence}% identity confidence',
                style: const TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );

  static String _symbol(MysticArchetype archetype) => switch (archetype) {
        MysticArchetype.seeker => '☾',
        MysticArchetype.alchemist => '✦',
        MysticArchetype.sage => '◉',
        MysticArchetype.guardian => '♜',
        MysticArchetype.visionary => '☀',
      };
}
