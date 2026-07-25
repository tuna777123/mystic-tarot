import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/mystic_journey.dart';
import 'package:mystic_tarot/src/mystic_journey_dashboard.dart';

void main() {
  testWidgets('shows an intentional empty state', (tester) async {
    var created = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MysticJourneyDashboard(
          journeys: const [],
          onCreateJourney: () => created = true,
          onOpenJourney: (_) {},
        ),
      ),
    );

    expect(find.text('Begin a meaningful journey'), findsOneWidget);
    await tester.tap(find.text('Create first journey'));
    expect(created, isTrue);
  });

  testWidgets('shows active journey metrics and opens the journey', (tester) async {
    final journey = MysticJourney(
      id: 'career',
      title: 'Career Change',
      area: JourneyArea.career,
      createdAt: DateTime(2026, 7, 20),
      intention: 'Move with clarity',
      entries: [
        JourneyEntry(
          id: 'one',
          createdAt: DateTime(2026, 7, 21),
          title: 'First reflection',
          reflection: 'I want to understand the next step.',
          tags: const {'clarity'},
        ),
        JourneyEntry(
          id: 'two',
          createdAt: DateTime(2026, 7, 22),
          title: 'Second reflection',
          tags: const {'clarity', 'work'},
        ),
      ],
    );
    MysticJourney? opened;

    await tester.pumpWidget(
      MaterialApp(
        home: MysticJourneyDashboard(
          journeys: [journey],
          onCreateJourney: () {},
          onOpenJourney: (value) => opened = value,
        ),
      ),
    );

    expect(find.text('Career Change'), findsOneWidget);
    expect(find.text('2'), findsNWidgets(2));
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('clarity'), findsOneWidget);

    await tester.tap(find.text('Career Change'));
    expect(opened?.id, 'career');
  });

  testWidgets('does not show completed journeys in the active dashboard', (tester) async {
    final completed = MysticJourney(
      id: 'done',
      title: 'Completed Path',
      area: JourneyArea.custom,
      createdAt: DateTime(2026, 7, 20),
      status: JourneyStatus.completed,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MysticJourneyDashboard(
          journeys: [completed],
          onCreateJourney: () {},
          onOpenJourney: (_) {},
        ),
      ),
    );

    expect(find.text('Completed Path'), findsNothing);
    expect(find.text('Begin a meaningful journey'), findsOneWidget);
  });
}
