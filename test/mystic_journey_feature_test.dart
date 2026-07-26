import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/mystic_journey.dart';
import 'package:mystic_tarot/src/mystic_journey_feature.dart';
import 'package:mystic_tarot/src/mystic_journey_store.dart';
import 'package:mystic_tarot/src/theme.dart';

void main() {
  testWidgets('creates and persists a journey from the empty state',
      (tester) async {
    final store = _MemoryJourneyStore();
    final now = DateTime(2026, 7, 26, 12);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: MysticJourneysFeature(
          language: MysticLanguage.english,
          store: store,
          clock: () => now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Begin a meaningful journey'), findsOneWidget);
    await tester.tap(find.text('Create first journey'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Journey name'),
      'Career clarity',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Intention'),
      'Choose my next step calmly',
    );
    await tester.tap(find.text('Career'));
    await tester.tap(find.text('Begin journey'));
    await tester.pumpAndSettle();

    expect(find.text('Career clarity'), findsOneWidget);
    expect(store.saved.single.title, 'Career clarity');
    expect(store.saved.single.area, JourneyArea.career);
  });

  testWidgets('opens a journey and adds a reflection', (tester) async {
    final initial = MysticJourney(
      id: 'career',
      title: 'Career clarity',
      area: JourneyArea.career,
      createdAt: DateTime(2026, 7, 20),
    );
    final store = _MemoryJourneyStore(initial: [initial]);
    final now = DateTime(2026, 7, 26, 12);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: MysticJourneysFeature(
          language: MysticLanguage.english,
          store: store,
          clock: () => now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Career clarity'));
    await tester.pumpAndSettle();
    expect(find.text('Your first reflection will begin this timeline.'),
        findsOneWidget);

    await tester.tap(find.text('Add reflection'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'What did you notice?'),
      'I need a clearer weekly plan.',
    );
    await tester.tap(find.text('Save reflection'));
    await tester.pumpAndSettle();

    expect(find.text('I need a clearer weekly plan.'), findsOneWidget);
    expect(store.saved.single.entries.single.reflection,
        'I need a clearer weekly plan.');
  });

  testWidgets('renders the Turkish empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: MysticJourneysFeature(
          language: MysticLanguage.turkish,
          store: _MemoryJourneyStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Anlamlı bir yolculuk başlat'), findsOneWidget);
    expect(find.text('İlk yolculuğu oluştur'), findsOneWidget);
  });

  testWidgets('surfaces backup recovery without blocking the user',
      (tester) async {
    final store = _MemoryJourneyStore(
      initial: [
        MysticJourney(
          id: 'safe',
          title: 'Recovered path',
          area: JourneyArea.custom,
          createdAt: DateTime(2026, 7, 20),
        ),
      ],
      recoveredFromBackup: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildMysticTheme(),
        home: MysticJourneysFeature(
          language: MysticLanguage.english,
          store: store,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recovered path'), findsOneWidget);
    expect(
      find.text('Mystic restored your last safe journey backup.'),
      findsOneWidget,
    );
  });
}

class _MemoryJourneyStore implements MysticJourneyStore {
  _MemoryJourneyStore({
    List<MysticJourney> initial = const [],
    this.recoveredFromBackup = false,
  }) : saved = List.of(initial);

  List<MysticJourney> saved;
  final bool recoveredFromBackup;

  @override
  Future<void> clear() async => saved = [];

  @override
  Future<JourneyLoadResult> load() async => JourneyLoadResult(
        journeys: List.unmodifiable(saved),
        recoveredFromBackup: recoveredFromBackup,
        rejectedItems: 0,
      );

  @override
  Future<void> save(Iterable<MysticJourney> journeys) async {
    saved = journeys.toList(growable: false);
  }
}
