import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:mystic_tarot/src/tarot_data.dart';
import 'package:mystic_tarot/src/tarot_localization.dart';
import 'package:mystic_tarot/src/widgets.dart';

void main() {
  test('all 78 tarot cards have a Turkish display name', () {
    expect(tarotDeck, hasLength(78));
    for (final card in tarotDeck) {
      expect(
        localizedTarotCardName(card.name, turkish: true),
        isNot(card.name),
        reason: '${card.name} must not fall back to English.',
      );
    }
  });

  test('major and minor arcana use familiar Turkish names', () {
    expect(
      localizedTarotCardName('The High Priestess', turkish: true),
      'Başrahibe',
    );
    expect(
      localizedTarotCardName('Queen of Cups', turkish: true),
      'Kupa Kraliçesi',
    );
    expect(
      localizedTarotCardName('The Sun', turkish: false),
      'The Sun',
    );
  });

  testWidgets('card artwork can render the localized display name',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotCardFace(
            drawn: DrawnCard(tarotDeck.first, false),
            displayName: 'Deli',
          ),
        ),
      ),
    );

    expect(find.text('Deli'), findsOneWidget);
    expect(find.text('THE FOOL'), findsNothing);
  });
}
