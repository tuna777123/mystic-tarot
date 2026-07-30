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

  test('reading, emotion, and deck labels remain Turkish', () {
    for (final kind in ReadingKind.values) {
      expect(
        localizedReadingKindTitle(kind, turkish: true),
        isNot(kind.title),
        reason: '${kind.name} title must not fall back to English.',
      );
      expect(
        localizedReadingKindSubtitle(kind, turkish: true),
        isNot(kind.subtitle),
        reason: '${kind.name} subtitle must not fall back to English.',
      );
    }
    for (final emotion in EmotionalState.values) {
      expect(
        localizedEmotionLabel(emotion, turkish: true),
        isNot(emotion.label),
        reason: '${emotion.name} must not fall back to English.',
      );
    }
    for (final style in DeckStyle.values) {
      expect(
        localizedDeckStyleLabel(style, turkish: true),
        isNot(style.label),
        reason: '${style.name} must not fall back to English.',
      );
    }
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

  test('all 78 cards have distinct Turkish upright and reversed guidance', () {
    final uprightMeanings = <String>{};
    final reversedMeanings = <String>{};
    final advice = <String>{};

    for (final card in tarotDeck) {
      uprightMeanings.add(
        localizedTarotCardMeaning(
          DrawnCard(card, false),
          turkish: true,
        ),
      );
      reversedMeanings.add(
        localizedTarotCardMeaning(
          DrawnCard(card, true),
          turkish: true,
        ),
      );
      advice.add(
        localizedTarotCardAdvice(
          DrawnCard(card, false),
          turkish: true,
        ),
      );
    }

    expect(uprightMeanings, hasLength(78));
    expect(reversedMeanings, hasLength(78));
    expect(advice, hasLength(78));
    expect(uprightMeanings.every((text) => text.length > 80), isTrue);
    expect(reversedMeanings.every((text) => text.length > 80), isTrue);
  });
}
