import 'flagship.dart';

const mysticPublicUrl = 'https://tuna777123.github.io/mystic-tarot/';

String mysticMirrorShareSubject(MysticLanguage language) => switch (language) {
      MysticLanguage.turkish => 'Bugün oku, yarın gerçeği kontrol et',
      MysticLanguage.spanish => 'Lee hoy, comprueba la realidad mañana',
      MysticLanguage.french => 'Lisez aujourd’hui, vérifiez la réalité demain',
      MysticLanguage.portugueseBrazil => 'Leia hoje, confira a realidade amanhã',
      _ => 'Read today, check reality tomorrow',
    };

/// Generic growth copy that deliberately excludes private reading content.
///
/// Never add a question, card name, emotion, outcome, note, user name,
/// intention, journal text or other private Mystic state to this payload.
String mysticMirrorShareText(MysticLanguage language) => switch (language) {
      MysticLanguage.turkish =>
        'Bugün oku. Yarın gerçeği kontrol et. 24 saatlik Mystic Mirror döngümü tamamladım: kehanete puan vermek yerine gerçekte neyin değiştiğini kaydeden özel bir tarot düşünme ritüeli. Mystic Tarot: $mysticPublicUrl',
      MysticLanguage.spanish =>
        'Lee hoy. Comprueba la realidad mañana. Cerré mi ciclo de 24 horas de Mystic Mirror: un ritual privado de reflexión con tarot que registra qué cambió de verdad en vez de puntuar una predicción. Mystic Tarot: $mysticPublicUrl',
      MysticLanguage.french =>
        'Lisez aujourd’hui. Vérifiez la réalité demain. J’ai bouclé mon Mystic Mirror de 24 h : un rituel privé de réflexion qui note ce qui a réellement changé au lieu de noter une prédiction. Mystic Tarot : $mysticPublicUrl',
      MysticLanguage.portugueseBrazil =>
        'Leia hoje. Confira a realidade amanhã. Fechei meu ciclo de 24 horas do Mystic Mirror: um ritual privado de reflexão com tarô que registra o que realmente mudou em vez de dar nota a uma previsão. Mystic Tarot: $mysticPublicUrl',
      _ =>
        'Read today. Check reality tomorrow. I closed my 24-hour Mystic Mirror loop: a private tarot reflection ritual that records what actually changed instead of scoring a prediction. Mystic Tarot: $mysticPublicUrl',
    };
