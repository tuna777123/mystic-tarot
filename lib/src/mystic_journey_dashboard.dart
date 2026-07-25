import 'package:flutter/material.dart';

import 'mystic_journey.dart';
import 'theme.dart';

class MysticJourneyDashboard extends StatelessWidget {
  const MysticJourneyDashboard({
    super.key,
    required this.journeys,
    required this.onCreateJourney,
    required this.onOpenJourney,
  });

  final List<MysticJourney> journeys;
  final VoidCallback onCreateJourney;
  final ValueChanged<MysticJourney> onOpenJourney;

  @override
  Widget build(BuildContext context) {
    final active = journeys
        .where((journey) => journey.status == JourneyStatus.active)
        .toList(growable: false)
      ..sort((a, b) {
        final aDate = a.lastActivityAt ?? a.createdAt;
        final bDate = b.lastActivityAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });

    return Scaffold(
      backgroundColor: const Color(0xFF080711),
      appBar: AppBar(
        title: const Text('Mystic Journeys'),
        actions: [
          IconButton(
            tooltip: 'Create journey',
            onPressed: onCreateJourney,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: active.isEmpty
            ? _EmptyJourneyState(onCreateJourney: onCreateJourney)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                children: [
                  const Text(
                    'Your reflection paths',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Continue a path and see how your reflections evolve over time.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .62),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  for (final journey in active) ...[
                    _JourneyCard(
                      journey: journey,
                      onTap: () => onOpenJourney(journey),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
      ),
      floatingActionButton: active.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: onCreateJourney,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('New journey'),
            ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.journey, required this.onTap});

  final MysticJourney journey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final snapshot = JourneyInsights.summarize(
      journey,
      generatedAt: DateTime.now(),
    );
    final accent = _areaColor(journey.area);

    return Semantics(
      button: true,
      label: '${journey.title}, ${snapshot.entryCount} entries',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: .22),
                const Color(0xFF151126),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: accent.withValues(alpha: .35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(_areaIcon(journey.area), color: accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journey.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (journey.intention?.trim().isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          Text(
                            journey.intention!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .56),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: .48),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _Metric(label: 'Entries', value: '${snapshot.entryCount}'),
                  _Metric(label: 'Active days', value: '${snapshot.activeDays}'),
                  _Metric(
                    label: 'Reflected',
                    value: '${(snapshot.reflectionRate * 100).round()}%',
                  ),
                ],
              ),
              if (snapshot.topTags.isNotEmpty) ...[
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: snapshot.topTags
                      .map(
                        (tag) => Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(tag),
                          side: BorderSide(color: accent.withValues(alpha: .32)),
                          backgroundColor: accent.withValues(alpha: .12),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .52),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
}

class _EmptyJourneyState extends StatelessWidget {
  const _EmptyJourneyState({required this.onCreateJourney});

  final VoidCallback onCreateJourney;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MysticColors.violet.withValues(alpha: .18),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  size: 42,
                  color: MysticColors.lavender,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Begin a meaningful journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Follow one life theme through readings and reflections, without pressure or predictions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .62),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 26),
              FilledButton.icon(
                onPressed: onCreateJourney,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Create first journey'),
              ),
            ],
          ),
        ),
      );
}

Color _areaColor(JourneyArea area) => switch (area) {
      JourneyArea.relationship => const Color(0xFFFF7AA8),
      JourneyArea.career => const Color(0xFF8DB9FF),
      JourneyArea.wellbeing => const Color(0xFF77D9B4),
      JourneyArea.education => const Color(0xFFFFC66D),
      JourneyArea.creativity => const Color(0xFFD89CFF),
      JourneyArea.confidence => const Color(0xFFFF9878),
      JourneyArea.custom => MysticColors.lavender,
    };

IconData _areaIcon(JourneyArea area) => switch (area) {
      JourneyArea.relationship => Icons.favorite_rounded,
      JourneyArea.career => Icons.work_rounded,
      JourneyArea.wellbeing => Icons.spa_rounded,
      JourneyArea.education => Icons.school_rounded,
      JourneyArea.creativity => Icons.palette_rounded,
      JourneyArea.confidence => Icons.bolt_rounded,
      JourneyArea.custom => Icons.auto_awesome_rounded,
    };
