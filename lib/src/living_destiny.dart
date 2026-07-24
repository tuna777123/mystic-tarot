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
          border: Border.all(
            color: MysticColors.gold.withValues(alpha: .28),
          ),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MysticColors.mist,
                  ),
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
                    snapshot.nextAction.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    snapshot.nextAction.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _execute(snapshot.nextAction.type),
                      icon: Icon(_actionIcon(snapshot.nextAction.type), size: 18),
                      label: Text(snapshot.nextAction.cta),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: const Row(
                    children: [
                      Icon(Icons.insights, size: 18, color: MysticColors.lavender),
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

  void _execute(MysticNextActionType type) {
    switch (type) {
      case MysticNextActionType.firstReading:
      case MysticNextActionType.dailyReading:
        onStartDailyReading();
        return;
      case MysticNextActionType.mirrorCheckIn:
      case MysticNextActionType.reviewPattern:
        onOpenPatterns();
        return;
      case MysticNextActionType.continueJourney:
        onOpenJourney();
        return;
      case MysticNextActionType.explorePremiumSpread:
        onOpenPremium();
        return;
    }
  }

  static String _stageLabel(MysticGrowthStage stage) {
    switch (stage) {
      case MysticGrowthStage.newUser:
        return 'Your story begins here';
      case MysticGrowthStage.activated:
        return 'Your first signals are forming';
      case MysticGrowthStage.engaged:
        return 'Your path is becoming visible';
      case MysticGrowthStage.habit:
        return 'Your ritual has momentum';
      case MysticGrowthStage.powerUser:
        return 'Your living pattern is awake';
    }
  }

  static IconData _actionIcon(MysticNextActionType type) {
    switch (type) {
      case MysticNextActionType.firstReading:
      case MysticNextActionType.dailyReading:
        return Icons.style;
      case MysticNextActionType.mirrorCheckIn:
        return Icons.self_improvement;
      case MysticNextActionType.continueJourney:
        return Icons.route;
      case MysticNextActionType.explorePremiumSpread:
        return Icons.workspace_premium;
      case MysticNextActionType.reviewPattern:
        return Icons.insights;
    }
  }
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
