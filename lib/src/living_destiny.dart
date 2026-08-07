import 'package:flutter/material.dart';

import 'growth_engine.dart';
import 'models.dart';
import 'theme.dart';

class LivingDestinyExperience extends StatelessWidget {
  const LivingDestinyExperience({
    required this.records,
    required this.streak,
    required this.completedArcanaDays,
    required this.freeReadingsLeft,
    required this.onStartDailyReading,
    required this.onOpenJourney,
    required this.onOpenPatterns,
    required this.onOpenPremium,
    super.key,
  });

  final List<ReadingRecord> records;
  final int streak;
  final int completedArcanaDays;
  final int freeReadingsLeft;
  final VoidCallback onStartDailyReading;
  final VoidCallback onOpenJourney;
  final VoidCallback onOpenPatterns;
  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context) {
    final snapshot = const MysticGrowthEngine().analyze(
      records: records,
      streak: streak,
      completedArcanaDays: completedArcanaDays,
      freeReadingsLeft: freeReadingsLeft,
    );
    final action = snapshot.nextAction;

    return Semantics(
      container: true,
      label: 'Living Destiny',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B1F45), Color(0xFF151020)],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .28)),
          boxShadow: [
            BoxShadow(
              color: MysticColors.violet.withValues(alpha: .16),
              blurRadius: 28,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: MysticColors.gold.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: MysticColors.gold,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LIVING DESTINY',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          color: MysticColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _stageLabel(snapshot.stage),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                _ValueRing(value: snapshot.premiumValueScore),
              ],
            ),
            const SizedBox(height: 17),
            Text(
              snapshot.returnMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: MysticColors.mist),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .045),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: .07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    action.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _callbackFor(action.type),
                      icon: Icon(_actionIcon(action.type), size: 18),
                      label: Text(action.cta),
                    ),
                  ),
                ],
              ),
            ),
            if (snapshot.hasVisiblePattern) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: onOpenPatterns,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insights,
                        size: 18,
                        color: MysticColors.lavender,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'A personal pattern is ready to explore',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 13),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  VoidCallback _callbackFor(MysticNextActionType type) => switch (type) {
    MysticNextActionType.firstReading ||
    MysticNextActionType.dailyReading => onStartDailyReading,
    MysticNextActionType.mirrorCheckIn ||
    MysticNextActionType.reviewPattern => onOpenPatterns,
    MysticNextActionType.continueJourney => onOpenJourney,
    MysticNextActionType.explorePremiumSpread => onOpenPremium,
  };

  static String _stageLabel(MysticGrowthStage stage) => switch (stage) {
    MysticGrowthStage.newUser => 'Your story begins here',
    MysticGrowthStage.activated => 'Your first signals are forming',
    MysticGrowthStage.engaged => 'Your path is becoming visible',
    MysticGrowthStage.habit => 'Your ritual has momentum',
    MysticGrowthStage.powerUser => 'Your living pattern is awake',
  };

  static IconData _actionIcon(MysticNextActionType type) => switch (type) {
    MysticNextActionType.firstReading ||
    MysticNextActionType.dailyReading => Icons.style,
    MysticNextActionType.mirrorCheckIn => Icons.self_improvement,
    MysticNextActionType.continueJourney => Icons.route,
    MysticNextActionType.explorePremiumSpread => Icons.workspace_premium,
    MysticNextActionType.reviewPattern => Icons.insights,
  };
}

class _ValueRing extends StatelessWidget {
  const _ValueRing({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 45,
    height: 45,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: value / 100,
          strokeWidth: 3,
          backgroundColor: Colors.white10,
          color: MysticColors.gold,
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: MysticColors.gold,
          ),
        ),
      ],
    ),
  );
}
