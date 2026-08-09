import 'flagship.dart';

const mysticPublicUrl = 'https://tuna777123.github.io/mystic-tarot/';

String mysticMirrorShareSubject(MysticLanguage language) => switch (language) {
  MysticLanguage.turkish => '24 saatlik Mystic Ayna döngüm',
  MysticLanguage.spanish => 'Mi ciclo de 24 horas de Mystic Mirror',
  MysticLanguage.french => 'Ma boucle Mystic Mirror de 24 h',
  MysticLanguage.portugueseBrazil => 'Meu ciclo de 24 horas do Mystic Mirror',
  _ => 'My 24-hour Mystic Mirror loop',
};

/// Generic growth copy that deliberately excludes private reading content.
///
/// Never add a question, card name, emotion, outcome, note, user name,
/// intention, journal text or other private Mystic state to this payload.
String mysticMirrorShareText(MysticLanguage language) => switch (language) {
  MysticLanguage.turkish =>
    '24 saatlik Mystic Ayna döngümü tamamladım — kartların ne söylediğinden çok, gerçekte ne olduğunu soran özel bir tarot düşünme ritüeli. Mystic Tarot: $mysticPublicUrl',
  MysticLanguage.spanish =>
    'Acabo de cerrar un ciclo de 24 horas de Mystic Mirror: un ritual privado de reflexión con tarot que pregunta qué ocurrió de verdad, no solo qué dijeron las cartas. Mystic Tarot: $mysticPublicUrl',
  MysticLanguage.french =>
    'Je viens de boucler un Mystic Mirror de 24 h : un rituel privé de réflexion avec le tarot qui demande ce qui s’est réellement passé, pas seulement ce que les cartes ont dit. Mystic Tarot : $mysticPublicUrl',
  MysticLanguage.portugueseBrazil =>
    'Acabei de fechar um ciclo de 24 horas do Mystic Mirror — um ritual privado de reflexão com tarô que pergunta o que realmente aconteceu, não apenas o que as cartas disseram. Mystic Tarot: $mysticPublicUrl',
  _ =>
    'I just closed a 24-hour Mystic Mirror loop — a private tarot reflection ritual that asks what actually happened, not just what the cards said. Mystic Tarot: $mysticPublicUrl',
};
