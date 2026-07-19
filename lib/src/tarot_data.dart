import 'models.dart';

final tarotDeck = <TarotCardData>[
  const TarotCardData(name: 'The Fool', number: '0', symbol: '✧', light: 'A new beginning asks for trust, curiosity, and one brave first step.', shadow: 'A leap may be tempting, but freedom without awareness becomes avoidance.', advice: 'Move forward, but take one honest look at where your feet will land.'),
  const TarotCardData(name: 'The Magician', number: 'I', symbol: '∞', light: 'You already hold the tools needed to shape this moment with intention.', shadow: 'Scattered focus or self-doubt is diluting your influence.', advice: 'Choose one outcome and direct your energy toward it without apology.'),
  const TarotCardData(name: 'The High Priestess', number: 'II', symbol: '☾', light: 'The quiet answer beneath the noise is more reliable than outside pressure.', shadow: 'You may be ignoring intuition because its message is inconvenient.', advice: 'Pause before acting and notice what your body already knows.'),
  const TarotCardData(name: 'The Empress', number: 'III', symbol: '❦', light: 'Growth comes through care, pleasure, patience, and creative nourishment.', shadow: 'Giving too much may be leaving your own inner world unfed.', advice: 'Create conditions where both you and your desire can flourish.'),
  const TarotCardData(name: 'The Emperor', number: 'IV', symbol: '♜', light: 'Structure and clear boundaries will turn intention into dependable progress.', shadow: 'Control may be replacing trust, flexibility, or real leadership.', advice: 'Build a firm container without making it a prison.'),
  const TarotCardData(name: 'The Hierophant', number: 'V', symbol: '⚿', light: 'A trusted teaching, ritual, or community can give this moment useful meaning.', shadow: 'Following convention without reflection may silence your own wisdom.', advice: 'Learn the tradition, then choose consciously what deserves to continue.'),
  const TarotCardData(name: 'The Lovers', number: 'VI', symbol: '♡', light: 'Alignment grows when values, desire, and choice point in the same direction.', shadow: 'Attraction alone cannot resolve a conflict in values.', advice: 'Choose what lets you remain connected without abandoning yourself.'),
  const TarotCardData(name: 'The Chariot', number: 'VII', symbol: '➶', light: 'Focused will can carry you through opposing forces and uncertainty.', shadow: 'Speed without emotional direction can create a hollow victory.', advice: 'Name the destination before pushing harder.'),
  const TarotCardData(name: 'Strength', number: 'VIII', symbol: '♌', light: 'Gentle courage and emotional steadiness are stronger than force.', shadow: 'Suppressed fear may be wearing the costume of confidence.', advice: 'Meet the difficult feeling with patience instead of domination.'),
  const TarotCardData(name: 'The Hermit', number: 'IX', symbol: '✦', light: 'Solitude offers the clarity that constant input has concealed.', shadow: 'Withdrawal may be protecting you from a conversation that matters.', advice: 'Step back long enough to hear yourself, then return with the truth.'),
  const TarotCardData(name: 'Wheel of Fortune', number: 'X', symbol: '◉', light: 'A cycle is turning; flexibility lets you recognize the opening.', shadow: 'Trying to freeze what is changing creates unnecessary friction.', advice: 'Work with the movement rather than demanding yesterday back.'),
  const TarotCardData(name: 'Justice', number: 'XI', symbol: '⚖', light: 'Truth, accountability, and proportion restore balance.', shadow: 'A convenient story may be hiding your share of responsibility.', advice: 'Make the decision you would respect even if nobody applauded.'),
  const TarotCardData(name: 'The Hanged Man', number: 'XII', symbol: '▽', light: 'A deliberate pause reveals a perspective that effort alone cannot reach.', shadow: 'Waiting has become avoidance, sacrifice, or attachment to being stuck.', advice: 'Release the need to force movement and look from the opposite angle.'),
  const TarotCardData(name: 'Death', number: 'XIII', symbol: '✢', light: 'An ending is clearing space for a more honest form of life.', shadow: 'Clinging to a completed chapter is delaying renewal.', advice: 'Release the identity that can no longer carry you forward.'),
  const TarotCardData(name: 'Temperance', number: 'XIV', symbol: '⚗', light: 'Patient integration creates a result that extremes cannot.', shadow: 'Impatience is pulling you between all-or-nothing reactions.', advice: 'Make the next adjustment small enough to sustain.'),
  const TarotCardData(name: 'The Devil', number: 'XV', symbol: '♄', light: 'Seeing the attachment clearly is the beginning of freedom.', shadow: 'A familiar desire, fear, or bargain may be choosing for you.', advice: 'Name the cost of the pattern and reclaim one choice today.'),
  const TarotCardData(name: 'The Tower', number: 'XVI', symbol: 'ϟ', light: 'A false structure is breaking so truth can become visible.', shadow: 'Resistance may intensify a change that has already begun.', advice: 'Protect what is real; let what was performative fall away.'),
  const TarotCardData(name: 'The Star', number: 'XVII', symbol: '✶', light: 'Hope returns through authenticity, renewal, and a wider perspective.', shadow: 'Disappointment may be making possibility feel unsafe.', advice: 'Practice one small act of faith that asks nothing from the outcome.'),
  const TarotCardData(name: 'The Moon', number: 'XVIII', symbol: '☽', light: 'Dreams and emotions reveal what logic cannot yet organize.', shadow: 'Fear is filling missing information with convincing illusions.', advice: 'Wait for more light before naming uncertainty as fact.'),
  const TarotCardData(name: 'The Sun', number: 'XIX', symbol: '☼', light: 'Vitality, clarity, and honest joy are available without complication.', shadow: 'Pressure to appear positive may be hiding a genuine need.', advice: 'Let success feel simple, and share warmth without performing it.'),
  const TarotCardData(name: 'Judgement', number: 'XX', symbol: '♬', light: 'A deeper calling asks you to answer with honesty and renewal.', shadow: 'Old shame may be keeping you loyal to a smaller version of yourself.', advice: 'Respond to who you are becoming, not who you had to be.'),
  const TarotCardData(name: 'The World', number: 'XXI', symbol: '◎', light: 'Completion brings integration, confidence, and a wider horizon.', shadow: 'One unfinished detail may be preventing full closure.', advice: 'Honor what is complete before beginning the next cycle.'),
  ..._minorArcana(),
];

List<TarotCardData> _minorArcana() {
  const suits = <(String, String, String, String)>[
    ('Wands', '♢', 'courage, desire, and creative momentum', 'direct your fire'),
    ('Cups', '◡', 'emotion, intimacy, and intuitive connection', 'honor what you feel'),
    ('Swords', '†', 'truth, thought, and decisive communication', 'choose the clearest truth'),
    ('Pentacles', '⬟', 'work, resources, body, and lasting value', 'build what can endure'),
  ];
  const ranks = <(String, String, String)>[
    ('Ace', 'a seed of pure potential', 'begin'),
    ('Two', 'a choice between competing energies', 'balance'),
    ('Three', 'growth through expression and collaboration', 'expand'),
    ('Four', 'stability that may become stillness', 'protect'),
    ('Five', 'friction that exposes what matters', 'adapt'),
    ('Six', 'movement toward harmony and recognition', 'receive'),
    ('Seven', 'a test of conviction and discernment', 'evaluate'),
    ('Eight', 'focused momentum and skill', 'practice'),
    ('Nine', 'resilience near the edge of completion', 'persist'),
    ('Ten', 'the full weight and reward of a cycle', 'complete'),
    ('Page', 'a curious message and fresh perspective', 'explore'),
    ('Knight', 'devotion moving rapidly into action', 'advance'),
    ('Queen', 'mature inner authority and receptivity', 'embody'),
    ('King', 'mastery expressed through leadership', 'lead'),
  ];

  return [
    for (final suit in suits)
      for (var i = 0; i < ranks.length; i++)
        TarotCardData(
          name: '${ranks[i].$1} of ${suit.$1}',
          number: '${i + 1}',
          symbol: suit.$2,
          light: 'This card carries ${ranks[i].$2} through ${suit.$3}.',
          shadow: 'The same energy may be blocked, exaggerated, or seeking approval instead of alignment.',
          advice: '${_capitalize(ranks[i].$3)} with intention: ${suit.$4} without abandoning your wider needs.',
        ),
  ];
}

String _capitalize(String value) => '${value[0].toUpperCase()}${value.substring(1)}';
