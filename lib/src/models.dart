enum ReadingKind {
  daily('Daily Guidance', 'One clear message for today', 1, '☀'),
  love('Love & Connection', 'See the energy around your heart', 3, '♥'),
  career('Career Path', 'Clarify your next professional move', 3, '✦'),
  money('Money Energy', 'Understand your financial direction', 3, '◆'),
  decision('Decision', 'Reveal what each path may hold', 2, '⇄'),
  spiritual('Spiritual Growth', 'Hear what your inner self needs', 3, '☾'),
  shadow('Shadow Work', 'Meet what is asking to be healed', 3, '◐');

  const ReadingKind(this.title, this.subtitle, this.cardCount, this.symbol);
  final String title;
  final String subtitle;
  final int cardCount;
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
  });

  final ReadingKind kind;
  final String question;
  final List<DrawnCard> cards;
  final DateTime createdAt;
}
