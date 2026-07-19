enum ReadingKind {
  daily('Daily Guidance', 'One clear message for today', 1, '☀'),
  love('Love & Connection', 'See the energy around your heart', 3, '♥'),
  career('Career Path', 'Clarify your next professional move', 3, '✦'),
  money('Money Energy', 'Understand your financial direction', 3, '◆'),
  decision('Decision', 'Reveal what each path may hold', 2, '⇄'),
  spiritual('Spiritual Growth', 'Hear what your inner self needs', 3, '☾'),
  shadow('Shadow Work', 'Meet what is asking to be healed', 3, '◐'),
  compatibility('Love Compatibility', 'Read the dynamic between two hearts', 5, '∞'),
  timeline('Future Timeline', 'Past, present, and three possible chapters', 6, '⌛'),
  celticCross('Celtic Cross', 'A complete ten-card deep dive', 10, '✣');

  const ReadingKind(this.title, this.subtitle, this.cardCount, this.symbol);
  final String title;
  final String subtitle;
  final int cardCount;
  final String symbol;
}

enum EmotionalState {
  uncertain('Uncertain', '◌'),
  hopeful('Hopeful', '✦'),
  anxious('Anxious', '≈'),
  grounded('Grounded', '●'),
  curious('Curious', '?');

  const EmotionalState(this.label, this.symbol);
  final String label;
  final String symbol;
}

enum DeckStyle {
  midnight('Midnight Veil', 'The original violet deck', '☾'),
  solarGold('Solar Gold', 'Awaken 10 Arcana', '☀'),
  bloodMoon('Blood Moon', 'Reach Mystic Level 5', '◉');

  const DeckStyle(this.label, this.subtitle, this.symbol);
  final String label;
  final String subtitle;
  final String symbol;
}

class TarotCardData {
  const TarotCardData({
    required this.name,
    required this.number,
    required this.symbol,
    required this.light,
    required this.shadow,
    required this.advice,
  });

  final String name;
  final String number;
  final String symbol;
  final String light;
  final String shadow;
  final String advice;
}

class DrawnCard {
  const DrawnCard(this.card, this.reversed);
  final TarotCardData card;
  final bool reversed;
}

class ReadingRecord {
  const ReadingRecord({
    required this.kind,
    required this.question,
    required this.cards,
    required this.createdAt,
    required this.emotion,
    required this.alignedAction,
  });

  final ReadingKind kind;
  final String question;
  final List<DrawnCard> cards;
  final DateTime createdAt;
  final EmotionalState emotion;
  final String alignedAction;

  DateTime get mirrorCheckInAt => createdAt.add(const Duration(hours: 24));
}
