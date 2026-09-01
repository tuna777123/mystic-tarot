import 'flagship.dart';
import 'models.dart';
import 'reading_position.dart';
import 'tarot_localization.dart';

String buildReadingSynthesis({
  required ReadingKind kind,
  required List<DrawnCard> cards,
  required EmotionalState emotion,
  required String intention,
  required MysticLanguage language,
}) {
  if (cards.isEmpty) {
    return _copy(
      language,
      en: 'No cards were available to synthesize.',
      tr: 'Bütünsel yorum için kullanılabilir kart bulunamadı.',
      es: 'No había cartas disponibles para sintetizar.',
      fr: 'Aucune carte n’était disponible pour la synthèse.',
      pt: 'Não havia cartas disponíveis para sintetizar.',
    );
  }

  final lenses = <_ReadingLens>[
    for (var index = 0; index < cards.length; index++)
      _lens(kind, cards[index], index, language),
  ];
  final context = _context(
    language,
    emotion: localizedEmotionLabel(emotion, languageCode: language.code),
    intention: _localizedIntention(intention, language),
  );

  if (lenses.length == 1) {
    final card = lenses.single;
    return _copy(
      language,
      en: _cleanJoin([
        context,
        '${card.name} appears in ${card.position.toLowerCase()}.',
        _sentence(card.meaning),
        _sentence(card.contextMeaning),
        'Try this grounded action: ${_sentence(card.advice)}',
        _sentence(card.contextAction),
        'Record what actually changes over the next twenty-four hours. This is a reflective invitation, not a prediction or certainty.',
      ]),
      tr: _cleanJoin([
        context,
        '${card.name}, ${card.position.toLowerCase()} konumunda beliriyor.',
        _sentence(card.meaning),
        _sentence(card.contextMeaning),
        'Şu somut eylemi dene: ${_sentence(card.advice)}',
        _sentence(card.contextAction),
        'Önümüzdeki yirmi dört saatte gerçekte neyin değiştiğini kaydet. Bu, düşünmeye yönelik bir davettir; kehanet veya kesinlik değildir.',
      ]),
      es: _cleanJoin([
        context,
        '${card.name} aparece en ${card.position.toLowerCase()}.',
        _sentence(card.meaning),
        _sentence(card.contextMeaning),
        'Prueba esta acción concreta: ${_sentence(card.advice)}',
        _sentence(card.contextAction),
        'Registra qué cambia realmente durante las próximas veinticuatro horas. Es una invitación a reflexionar, no una predicción ni una certeza.',
      ]),
      fr: _cleanJoin([
        context,
        '${card.name} apparaît dans ${card.position.toLowerCase()}.',
        _sentence(card.meaning),
        _sentence(card.contextMeaning),
        'Essayez cette action concrète : ${_sentence(card.advice)}',
        _sentence(card.contextAction),
        'Notez ce qui change réellement pendant les prochaines vingt-quatre heures. C’est une invitation à réfléchir, pas une prédiction ni une certitude.',
      ]),
      pt: _cleanJoin([
        context,
        '${card.name} aparece em ${card.position.toLowerCase()}.',
        _sentence(card.meaning),
        _sentence(card.contextMeaning),
        'Experimente esta ação concreta: ${_sentence(card.advice)}',
        _sentence(card.contextAction),
        'Registre o que realmente muda nas próximas vinte e quatro horas. É um convite à reflexão, não uma previsão nem uma certeza.',
      ]),
    );
  }

  if (lenses.length == 2) {
    final first = lenses[0];
    final second = lenses[1];
    return _copy(
      language,
      en: _cleanJoin([
        context,
        '${first.name} frames ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${_sentence(first.contextMeaning)}',
        '${second.name} frames ${second.position.toLowerCase()}: ${_sentence(second.meaning)} ${_sentence(second.contextMeaning)}',
        'Read together, the cards compare two emphases rather than naming a predetermined winner.',
        'Try this grounded action: ${_sentence(second.advice)} ${_sentence(second.contextAction)}',
        'Record what actually changes after twenty-four hours instead of treating either path as certainty.',
      ]),
      tr: _cleanJoin([
        context,
        '${first.name}, ${first.position.toLowerCase()} konumunu çerçeveliyor: ${_sentence(first.meaning)} ${_sentence(first.contextMeaning)}',
        '${second.name}, ${second.position.toLowerCase()} konumunu çerçeveliyor: ${_sentence(second.meaning)} ${_sentence(second.contextMeaning)}',
        'Birlikte okunduğunda kartlar önceden belirlenmiş bir kazanan söylemek yerine iki vurguyu karşılaştırıyor.',
        'Şu somut eylemi dene: ${_sentence(second.advice)} ${_sentence(second.contextAction)}',
        'İki yoldan birini kesinlik saymak yerine yirmi dört saat sonra gerçekte neyin değiştiğini kaydet.',
      ]),
      es: _cleanJoin([
        context,
        '${first.name} enmarca ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${_sentence(first.contextMeaning)}',
        '${second.name} enmarca ${second.position.toLowerCase()}: ${_sentence(second.meaning)} ${_sentence(second.contextMeaning)}',
        'Leídas juntas, las cartas comparan dos énfasis en lugar de declarar un resultado predeterminado.',
        'Prueba esta acción concreta: ${_sentence(second.advice)} ${_sentence(second.contextAction)}',
        'Registra qué cambia realmente después de veinticuatro horas sin tratar ninguno de los caminos como certeza.',
      ]),
      fr: _cleanJoin([
        context,
        '${first.name} éclaire ${first.position.toLowerCase()} : ${_sentence(first.meaning)} ${_sentence(first.contextMeaning)}',
        '${second.name} éclaire ${second.position.toLowerCase()} : ${_sentence(second.meaning)} ${_sentence(second.contextMeaning)}',
        'Ensemble, les cartes comparent deux accents sans désigner un résultat prédéterminé.',
        'Essayez cette action concrète : ${_sentence(second.advice)} ${_sentence(second.contextAction)}',
        'Notez ce qui change réellement après vingt-quatre heures sans traiter l’une des voies comme une certitude.',
      ]),
      pt: _cleanJoin([
        context,
        '${first.name} enquadra ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${_sentence(first.contextMeaning)}',
        '${second.name} enquadra ${second.position.toLowerCase()}: ${_sentence(second.meaning)} ${_sentence(second.contextMeaning)}',
        'Juntas, as cartas comparam duas ênfases em vez de declarar um resultado predeterminado.',
        'Experimente esta ação concreta: ${_sentence(second.advice)} ${_sentence(second.contextAction)}',
        'Registre o que realmente muda após vinte e quatro horas sem tratar nenhum caminho como certeza.',
      ]),
    );
  }

  final relationship = _relationshipInsight(lenses, language);

  if (kind == ReadingKind.compatibility && lenses.length >= 5) {
    return _deepSpreadSynthesis(
      lenses: lenses,
      context: context,
      relationship: relationship,
      language: language,
      closing: _copy(
        language,
        en: 'The relationship is not reduced to a compatibility score. Use the final position as a grounded experiment, then observe what changes in the next twenty-four hours.',
        tr: 'Bağ tek bir uyum puanına indirgenmiyor. Son konumu somut bir deney olarak kullan ve ardından önümüzdeki yirmi dört saatte gerçekte neyin değiştiğini gözlemle.',
        es: 'La relación no se reduce a una puntuación de compatibilidad. Usa la posición final como un experimento concreto y observa qué cambia realmente durante las próximas veinticuatro horas.',
        fr: 'La relation n’est pas réduite à un score de compatibilité. Utilisez la dernière position comme une expérience concrète, puis observez ce qui change réellement pendant les prochaines vingt-quatre heures.',
        pt: 'A relação não é reduzida a uma pontuação de compatibilidade. Use a posição final como um experimento concreto e observe o que realmente muda nas próximas vinte e quatro horas.',
      ),
    );
  }

  if (kind == ReadingKind.timeline && lenses.length >= 6) {
    return _deepSpreadSynthesis(
      lenses: lenses,
      context: context,
      relationship: relationship,
      language: language,
      closing: _copy(
        language,
        en: 'This is a conditional trajectory, not a fixed future. Use the final position to change one controllable condition and record what actually shifted after twenty-four hours.',
        tr: 'Bu sabit bir gelecek değil, koşullu bir gidişattır. Son konumu kullanarak kontrol edebildiğin tek bir koşulu değiştir ve yirmi dört saat sonra gerçekte neyin farklılaştığını kaydet.',
        es: 'Es una trayectoria condicional, no un futuro fijo. Usa la posición final para cambiar una condición controlable y registra qué cambió realmente después de veinticuatro horas.',
        fr: 'Il s’agit d’une trajectoire conditionnelle, pas d’un avenir figé. Utilisez la dernière position pour modifier une condition contrôlable et notez ce qui a réellement changé après vingt-quatre heures.',
        pt: 'Esta é uma trajetória condicional, não um futuro fixo. Use a posição final para mudar uma condição controlável e registre o que realmente mudou após vinte e quatro horas.',
      ),
    );
  }

  if (kind == ReadingKind.celticCross && lenses.length >= 10) {
    return _deepSpreadSynthesis(
      lenses: lenses,
      context: context,
      relationship: relationship,
      language: language,
      closing: _copy(
        language,
        en: 'Treat the Celtic Cross as a map of interacting conditions, not a verdict. Choose one reversible action from the final position and compare the reading with reality after twenty-four hours.',
        tr: 'Kelt Haçı’nı bir hüküm değil, etkileşen koşulların haritası olarak kullan. Son konumdan geri döndürülebilir tek bir eylem seç ve yirmi dört saat sonra okumayı gerçeklikle karşılaştır.',
        es: 'Trata la Cruz Celta como un mapa de condiciones que interactúan, no como un veredicto. Elige una acción reversible desde la posición final y compara la lectura con la realidad después de veinticuatro horas.',
        fr: 'Traitez la Croix celtique comme une carte de conditions en interaction, pas comme un verdict. Choisissez une action réversible depuis la dernière position et comparez le tirage à la réalité après vingt-quatre heures.',
        pt: 'Trate a Cruz Celta como um mapa de condições que interagem, não como um veredito. Escolha uma ação reversível a partir da posição final e compare a leitura com a realidade após vinte e quatro horas.',
      ),
    );
  }

  final first = lenses.first;
  final bridge = lenses[lenses.length ~/ 2];
  final last = lenses.last;
  return _copy(
    language,
    en: _cleanJoin([
      context,
      '${first.name} opens the reading through ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${_sentence(first.contextMeaning)}',
      '${bridge.name} holds the central pressure through ${bridge.position.toLowerCase()}: ${_sentence(bridge.meaning)} ${_sentence(bridge.contextMeaning)}',
      '${last.name} gives the direction of travel through ${last.position.toLowerCase()}: ${_sentence(last.meaning)} ${_sentence(last.contextMeaning)}',
      relationship,
      'Taken together, the spread moves from the opening condition through the central pressure toward one testable direction.',
      'Use this grounded experiment: ${_sentence(last.advice)} ${_sentence(last.contextAction)}',
      'Then record what actually changed after twenty-four hours rather than treating the cards as certainty.',
    ]),
    tr: _cleanJoin([
      context,
      '${first.name}, ${first.position.toLowerCase()} üzerinden okumayı açıyor: ${_sentence(first.meaning)} ${_sentence(first.contextMeaning)}',
      '${bridge.name}, ${bridge.position.toLowerCase()} üzerinden merkezdeki baskıyı taşıyor: ${_sentence(bridge.meaning)} ${_sentence(bridge.contextMeaning)}',
      '${last.name}, ${last.position.toLowerCase()} üzerinden yönü gösteriyor: ${_sentence(last.meaning)} ${_sentence(last.contextMeaning)}',
      relationship,
      'Birlikte okunduğunda açılım başlangıç koşulundan merkezdeki baskıya, oradan da deneyebileceğin tek bir yöne ilerliyor.',
      'Şu somut deneyi uygula: ${_sentence(last.advice)} ${_sentence(last.contextAction)}',
      'Ardından kartları kesinlik saymak yerine yirmi dört saat sonra gerçekte neyin değiştiğini kaydet.',
    ]),
    es: _cleanJoin([
      context,
      '${first.name} abre la lectura desde ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${_sentence(first.contextMeaning)}',
      '${bridge.name} sostiene la presión central desde ${bridge.position.toLowerCase()}: ${_sentence(bridge.meaning)} ${_sentence(bridge.contextMeaning)}',
      '${last.name} marca la dirección desde ${last.position.toLowerCase()}: ${_sentence(last.meaning)} ${_sentence(last.contextMeaning)}',
      relationship,
      'En conjunto, la tirada avanza desde la condición inicial, atraviesa la presión central y llega a una dirección que puedes probar.',
      'Usa este experimento concreto: ${_sentence(last.advice)} ${_sentence(last.contextAction)}',
      'Después registra qué cambió realmente tras veinticuatro horas sin tratar las cartas como certeza.',
    ]),
    fr: _cleanJoin([
      context,
      '${first.name} ouvre le tirage à travers ${first.position.toLowerCase()} : ${_sentence(first.meaning)} ${_sentence(first.contextMeaning)}',
      '${bridge.name} porte la pression centrale à travers ${bridge.position.toLowerCase()} : ${_sentence(bridge.meaning)} ${_sentence(bridge.contextMeaning)}',
      '${last.name} indique la direction à travers ${last.position.toLowerCase()} : ${_sentence(last.meaning)} ${_sentence(last.contextMeaning)}',
      relationship,
      'Ensemble, les cartes vont de la condition initiale, traversent la pression centrale et aboutissent à une direction que vous pouvez tester.',
      'Utilisez cette expérience concrète : ${_sentence(last.advice)} ${_sentence(last.contextAction)}',
      'Notez ensuite ce qui a réellement changé après vingt-quatre heures sans traiter les cartes comme une certitude.',
    ]),
    pt: _cleanJoin([
      context,
      '${first.name} abre a leitura por ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${_sentence(first.contextMeaning)}',
      '${bridge.name} sustenta a pressão central por ${bridge.position.toLowerCase()}: ${_sentence(bridge.meaning)} ${_sentence(bridge.contextMeaning)}',
      '${last.name} aponta a direção por ${last.position.toLowerCase()}: ${_sentence(last.meaning)} ${_sentence(last.contextMeaning)}',
      relationship,
      'Em conjunto, a tiragem parte da condição inicial, atravessa a pressão central e chega a uma direção que você pode testar.',
      'Use este experimento concreto: ${_sentence(last.advice)} ${_sentence(last.contextAction)}',
      'Depois registre o que realmente mudou após vinte e quatro horas sem tratar as cartas como certeza.',
    ]),
  );
}

String _deepSpreadSynthesis({
  required List<_ReadingLens> lenses,
  required String context,
  required String relationship,
  required MysticLanguage language,
  required String closing,
}) {
  final details = <String>[];
  for (final lens in lenses) {
    details.add(
      _copy(
        language,
        en: '${lens.name} in ${lens.position.toLowerCase()}: ${_sentence(lens.meaning)} ${_sentence(lens.contextMeaning)}',
        tr: '${lens.name}, ${lens.position.toLowerCase()} konumunda: ${_sentence(lens.meaning)} ${_sentence(lens.contextMeaning)}',
        es: '${lens.name} en ${lens.position.toLowerCase()}: ${_sentence(lens.meaning)} ${_sentence(lens.contextMeaning)}',
        fr: '${lens.name} dans ${lens.position.toLowerCase()} : ${_sentence(lens.meaning)} ${_sentence(lens.contextMeaning)}',
        pt: '${lens.name} em ${lens.position.toLowerCase()}: ${_sentence(lens.meaning)} ${_sentence(lens.contextMeaning)}',
      ),
    );
  }
  final action = lenses.last;
  return _cleanJoin([
    context,
    ...details,
    relationship,
    _copy(
      language,
      en: 'Ground the spread with this action: ${_sentence(action.advice)} ${_sentence(action.contextAction)}',
      tr: 'Açılımı şu eylemle somutlaştır: ${_sentence(action.advice)} ${_sentence(action.contextAction)}',
      es: 'Aterriza la tirada con esta acción: ${_sentence(action.advice)} ${_sentence(action.contextAction)}',
      fr: 'Ancrez le tirage avec cette action : ${_sentence(action.advice)} ${_sentence(action.contextAction)}',
      pt: 'Aterre a tiragem com esta ação: ${_sentence(action.advice)} ${_sentence(action.contextAction)}',
    ),
    closing,
  ]);
}

String _relationshipInsight(
  List<_ReadingLens> lenses,
  MysticLanguage language,
) {
  final pair = _relationshipPair(lenses);
  final first = pair.$1;
  final second = pair.$2;
  final sameFamily = first.family == second.family;
  final sameOrientation = first.reversed == second.reversed;

  if (sameFamily && !sameOrientation) {
    final theme = _familyTheme(first.family, language);
    return _copy(
      language,
      en: '${first.name} in ${first.position.toLowerCase()} and ${second.name} in ${second.position.toLowerCase()} carry the same $theme theme in opposite orientations. That makes the repeated theme a live tension to investigate rather than a contradiction to resolve.',
      tr: '${first.name}, ${first.position.toLowerCase()} alanında; ${second.name} ise ${second.position.toLowerCase()} alanında aynı $theme temasını zıt yönlerde taşıyor. Bu tekrar, çözülmesi gereken bir çelişkiden çok gözlemlemen gereken canlı bir gerilim oluşturuyor.',
      es: '${first.name} en ${first.position.toLowerCase()} y ${second.name} en ${second.position.toLowerCase()} llevan el mismo tema de $theme en orientaciones opuestas. La repetición se convierte así en una tensión viva que conviene investigar, no en una contradicción que debas resolver.',
      fr: '${first.name} dans ${first.position.toLowerCase()} et ${second.name} dans ${second.position.toLowerCase()} portent le même thème de $theme dans des orientations opposées. La répétition devient ainsi une tension vivante à examiner, pas une contradiction à résoudre.',
      pt: '${first.name} em ${first.position.toLowerCase()} e ${second.name} em ${second.position.toLowerCase()} carregam o mesmo tema de $theme em orientações opostas. A repetição se torna uma tensão viva a investigar, não uma contradição que precise ser resolvida.',
    );
  }

  if (sameFamily && sameOrientation) {
    final theme = _familyTheme(first.family, language);
    return _copy(
      language,
      en: '${first.name} in ${first.position.toLowerCase()} and ${second.name} in ${second.position.toLowerCase()} reinforce the $theme thread across two positions. Because both the theme and orientation repeat, this pattern carries more weight than either card by itself.',
      tr: '${first.name}, ${first.position.toLowerCase()} alanında; ${second.name} ise ${second.position.toLowerCase()} alanında $theme temasını iki ayrı konumda güçlendiriyor. Hem tema hem yön tekrarlandığı için bu örüntü, kartlardan herhangi birinin tek başına taşıdığından daha fazla ağırlık kazanıyor.',
      es: '${first.name} en ${first.position.toLowerCase()} y ${second.name} en ${second.position.toLowerCase()} refuerzan el hilo de $theme en dos posiciones. Como se repiten tanto el tema como la orientación, este patrón pesa más que cualquiera de las cartas por separado.',
      fr: '${first.name} dans ${first.position.toLowerCase()} et ${second.name} dans ${second.position.toLowerCase()} renforcent le fil de $theme à deux positions. Puisque le thème et l’orientation se répètent, ce motif compte davantage que chacune des cartes prise isolément.',
      pt: '${first.name} em ${first.position.toLowerCase()} e ${second.name} em ${second.position.toLowerCase()} reforçam o fio de $theme em duas posições. Como tema e orientação se repetem, esse padrão tem mais peso do que qualquer uma das cartas isoladamente.',
    );
  }

  final firstTheme = _familyTheme(first.family, language);
  final secondTheme = _familyTheme(second.family, language);
  if (!sameOrientation) {
    return _copy(
      language,
      en: '${first.name} in ${first.position.toLowerCase()} and ${second.name} in ${second.position.toLowerCase()} form the clearest contrast: $firstTheme meets $secondTheme, and their orientations pull in different directions. Read that as an interaction to test, not a verdict about which card is right.',
      tr: '${first.name}, ${first.position.toLowerCase()} alanında; ${second.name} ise ${second.position.toLowerCase()} alanında en belirgin karşıtlığı kuruyor: $firstTheme ile $secondTheme buluşuyor ve kartların yönleri farklı taraflara çekiyor. Bunu hangi kartın haklı olduğuna dair bir hüküm değil, test edilecek bir etkileşim olarak oku.',
      es: '${first.name} en ${first.position.toLowerCase()} y ${second.name} en ${second.position.toLowerCase()} forman el contraste más claro: $firstTheme se encuentra con $secondTheme y sus orientaciones tiran en direcciones distintas. Léelo como una interacción que puedes poner a prueba, no como un veredicto sobre qué carta tiene razón.',
      fr: '${first.name} dans ${first.position.toLowerCase()} et ${second.name} dans ${second.position.toLowerCase()} forment le contraste le plus net : $firstTheme rencontre $secondTheme et leurs orientations tirent dans des directions différentes. Lisez cela comme une interaction à tester, pas comme un verdict sur la carte qui aurait raison.',
      pt: '${first.name} em ${first.position.toLowerCase()} e ${second.name} em ${second.position.toLowerCase()} formam o contraste mais claro: $firstTheme encontra $secondTheme e suas orientações puxam em direções diferentes. Leia isso como uma interação a ser testada, não como um veredito sobre qual carta está certa.',
    );
  }

  return _copy(
    language,
    en: '${first.name} in ${first.position.toLowerCase()} and ${second.name} in ${second.position.toLowerCase()} connect two different layers: $firstTheme and $secondTheme. Their orientations agree, so the spread reads more like coordination between these pressures than a fight between them.',
    tr: '${first.name}, ${first.position.toLowerCase()} alanında; ${second.name} ise ${second.position.toLowerCase()} alanında iki farklı katmanı birbirine bağlıyor: $firstTheme ve $secondTheme. Yönleri aynı olduğu için açılım bu baskılar arasında çatışmadan çok koordinasyon gösteriyor.',
    es: '${first.name} en ${first.position.toLowerCase()} y ${second.name} en ${second.position.toLowerCase()} conectan dos capas distintas: $firstTheme y $secondTheme. Sus orientaciones coinciden, así que la tirada se lee más como coordinación entre esas presiones que como una pelea entre ellas.',
    fr: '${first.name} dans ${first.position.toLowerCase()} et ${second.name} dans ${second.position.toLowerCase()} relient deux niveaux différents : $firstTheme et $secondTheme. Leurs orientations concordent, de sorte que le tirage parle davantage de coordination entre ces pressions que de conflit.',
    pt: '${first.name} em ${first.position.toLowerCase()} e ${second.name} em ${second.position.toLowerCase()} conectam duas camadas diferentes: $firstTheme e $secondTheme. As orientações concordam, então a tiragem fala mais de coordenação entre essas pressões do que de conflito.',
  );
}

(_ReadingLens, _ReadingLens) _relationshipPair(List<_ReadingLens> lenses) {
  for (var distance = lenses.length - 1; distance >= 1; distance--) {
    for (var start = 0; start + distance < lenses.length; start++) {
      final first = lenses[start];
      final second = lenses[start + distance];
      if (first.family == second.family) return (first, second);
    }
  }
  for (var index = 0; index < lenses.length - 1; index++) {
    final first = lenses[index];
    final second = lenses[index + 1];
    if (first.reversed != second.reversed) return (first, second);
  }
  return (lenses.first, lenses.last);
}

_ReadingLens _lens(
  ReadingKind kind,
  DrawnCard card,
  int index,
  MysticLanguage language,
) {
  final family = _cardFamily(card.card.name);
  return _ReadingLens(
    name: localizedTarotCardName(card.card.name, languageCode: language.code),
    position: localizedReadingPosition(
      kind: kind,
      index: index,
      language: language,
    ),
    meaning: localizedTarotCardMeaning(card, languageCode: language.code),
    advice: localizedTarotCardAdvice(card, languageCode: language.code),
    contextMeaning: _contextualMeaning(
      kind: kind,
      family: family,
      reversed: card.reversed,
      language: language,
    ),
    contextAction: _contextualAction(
      kind: kind,
      family: family,
      language: language,
    ),
    family: family,
    reversed: card.reversed,
  );
}

String _contextualMeaning({
  required ReadingKind kind,
  required _CardFamily family,
  required bool reversed,
  required MysticLanguage language,
}) {
  final theme = _familyTheme(family, language);
  final frame = switch (kind) {
    ReadingKind.daily => _copy(
      language,
      en: 'For today, notice how $theme is showing up before you react automatically.',
      tr: 'Bugün $theme temasının otomatik tepki vermeden önce nasıl ortaya çıktığını fark et.',
      es: 'Para hoy, observa cómo aparece $theme antes de reaccionar en automático.',
      fr: 'Pour aujourd’hui, observez comment $theme se manifeste avant de réagir automatiquement.',
      pt: 'Para hoje, observe como $theme aparece antes de reagir no automático.',
    ),
    ReadingKind.love => _copy(
      language,
      en: 'In a relationship context, test how $theme affects reciprocity, boundaries, and what is actually being communicated.',
      tr: 'İlişki bağlamında $theme temasının karşılıklılığı, sınırları ve gerçekten neyin iletişim kurulduğunu nasıl etkilediğini test et.',
      es: 'En un contexto relacional, prueba cómo $theme afecta la reciprocidad, los límites y lo que realmente se está comunicando.',
      fr: 'Dans un contexte relationnel, observez comment $theme agit sur la réciprocité, les limites et ce qui est réellement communiqué.',
      pt: 'Em um contexto de relacionamento, teste como $theme afeta reciprocidade, limites e o que está sendo realmente comunicado.',
    ),
    ReadingKind.career => _copy(
      language,
      en: 'In a career context, test how $theme affects responsibility, leverage, skill, and the next move you can control.',
      tr: 'Kariyer bağlamında $theme temasının sorumluluğu, hareket alanını, beceriyi ve kontrol edebileceğin sıradaki hamleyi nasıl etkilediğini test et.',
      es: 'En un contexto profesional, prueba cómo $theme afecta la responsabilidad, tu margen de acción, la habilidad y el siguiente movimiento que puedes controlar.',
      fr: 'Dans un contexte professionnel, observez comment $theme agit sur la responsabilité, votre marge de manœuvre, la compétence et la prochaine action contrôlable.',
      pt: 'Em um contexto profissional, teste como $theme afeta responsabilidade, margem de ação, habilidade e o próximo movimento que você controla.',
    ),
    ReadingKind.money => _copy(
      language,
      en: 'In a money context, test how $theme affects cash, risk, time, and the resources you can sustain.',
      tr: 'Para bağlamında $theme temasının nakdi, riski, zamanı ve sürdürebildiğin kaynakları nasıl etkilediğini test et.',
      es: 'En un contexto financiero, prueba cómo $theme afecta el dinero disponible, el riesgo, el tiempo y los recursos que puedes sostener.',
      fr: 'Dans un contexte financier, observez comment $theme agit sur la trésorerie, le risque, le temps et les ressources que vous pouvez soutenir.',
      pt: 'Em um contexto financeiro, teste como $theme afeta caixa, risco, tempo e os recursos que você consegue sustentar.',
    ),
    ReadingKind.decision => _copy(
      language,
      en: 'For this decision, use $theme to compare trade-offs instead of searching for a yes-or-no command.',
      tr: 'Bu kararda evet-hayır emri aramak yerine $theme temasını seçeneklerin bedellerini karşılaştırmak için kullan.',
      es: 'Para esta decisión, usa $theme para comparar costes y beneficios en vez de buscar una orden de sí o no.',
      fr: 'Pour cette décision, utilisez $theme pour comparer les compromis au lieu de chercher une réponse oui ou non.',
      pt: 'Para esta decisão, use $theme para comparar trocas e custos em vez de procurar uma ordem de sim ou não.',
    ),
    ReadingKind.spiritual => _copy(
      language,
      en: 'For spiritual growth, notice how $theme appears in practice rather than treating symbolism as proof.',
      tr: 'Ruhsal gelişimde sembolizmi kanıt saymak yerine $theme temasının günlük pratikte nasıl göründüğünü fark et.',
      es: 'Para el crecimiento espiritual, observa cómo $theme aparece en la práctica en lugar de tratar el simbolismo como prueba.',
      fr: 'Pour la croissance spirituelle, observez comment $theme apparaît dans la pratique au lieu de traiter le symbole comme une preuve.',
      pt: 'Para o crescimento espiritual, observe como $theme aparece na prática em vez de tratar simbolismo como prova.',
    ),
    ReadingKind.shadow => _copy(
      language,
      en: 'For shadow work, look for observable behavior around $theme, especially what you avoid, over-control, or repeat.',
      tr: 'Gölge çalışmasında $theme çevresindeki gözlemlenebilir davranışlara, özellikle kaçındığın, aşırı kontrol ettiğin veya tekrarladığın şeylere bak.',
      es: 'Para el trabajo de sombra, busca conductas observables alrededor de $theme, sobre todo lo que evitas, controlas en exceso o repites.',
      fr: 'Pour le travail de l’ombre, cherchez les comportements observables autour de $theme, surtout ce que vous évitez, surcontrôlez ou répétez.',
      pt: 'No trabalho de sombra, procure comportamentos observáveis em torno de $theme, especialmente o que você evita, controla demais ou repete.',
    ),
    ReadingKind.compatibility => _copy(
      language,
      en: 'For compatibility, read $theme as a relational dynamic to observe between two people, not as a score.',
      tr: 'Uyum açılımında $theme temasını bir puan değil, iki kişi arasında gözlemlenecek ilişkisel bir dinamik olarak oku.',
      es: 'Para la compatibilidad, lee $theme como una dinámica relacional que observar entre dos personas, no como una puntuación.',
      fr: 'Pour la compatibilité, lisez $theme comme une dynamique relationnelle à observer entre deux personnes, pas comme un score.',
      pt: 'Na compatibilidade, leia $theme como uma dinâmica relacional a observar entre duas pessoas, não como uma pontuação.',
    ),
    ReadingKind.timeline => _copy(
      language,
      en: 'On a timeline, $theme describes a condition that can change with choices; it does not name a fixed event.',
      tr: 'Zaman çizgisinde $theme, seçimlerle değişebilecek bir koşulu anlatır; sabit bir olayı ilan etmez.',
      es: 'En una línea de tiempo, $theme describe una condición que puede cambiar con las decisiones; no anuncia un hecho fijo.',
      fr: 'Sur une chronologie, $theme décrit une condition qui peut changer avec les choix ; il n’annonce pas un événement figé.',
      pt: 'Em uma linha do tempo, $theme descreve uma condição que pode mudar com escolhas; não anuncia um evento fixo.',
    ),
    ReadingKind.celticCross => _copy(
      language,
      en: 'Within the wider Celtic Cross, read $theme in relation to the surrounding positions rather than in isolation.',
      tr: 'Geniş Kelt Haçı içinde $theme temasını tek başına değil, çevresindeki konumlarla ilişkili olarak oku.',
      es: 'Dentro de la Cruz Celta, lee $theme en relación con las posiciones que la rodean, no de forma aislada.',
      fr: 'Dans la Croix celtique, lisez $theme en relation avec les positions voisines plutôt que de manière isolée.',
      pt: 'Na Cruz Celta, leia $theme em relação às posições ao redor, não de forma isolada.',
    ),
  };
  final orientation = reversed
      ? _copy(
          language,
          en: 'Because the card is reversed, look first for delay, excess, avoidance, or inward pressure around this theme.',
          tr: 'Kart ters olduğu için önce bu tema çevresinde gecikme, aşırılık, kaçınma veya içe dönük baskı olup olmadığına bak.',
          es: 'Como la carta está invertida, busca primero retraso, exceso, evitación o presión interna alrededor de este tema.',
          fr: 'Comme la carte est renversée, cherchez d’abord retard, excès, évitement ou pression intérieure autour de ce thème.',
          pt: 'Como a carta está invertida, procure primeiro atraso, excesso, evitação ou pressão interna em torno desse tema.',
        )
      : _copy(
          language,
          en: 'Because the card is upright, start with the most usable and outwardly available expression of this theme.',
          tr: 'Kart düz olduğu için önce bu temanın kullanılabilir ve dışarıdan gözlemlenebilir ifadesine bak.',
          es: 'Como la carta está derecha, empieza por la expresión más utilizable y visible de este tema.',
          fr: 'Comme la carte est à l’endroit, commencez par l’expression la plus utilisable et visible de ce thème.',
          pt: 'Como a carta está na posição normal, comece pela expressão mais utilizável e visível desse tema.',
        );
  return '$frame $orientation';
}

String _contextualAction({
  required ReadingKind kind,
  required _CardFamily family,
  required MysticLanguage language,
}) {
  final theme = _familyTheme(family, language);
  return switch (kind) {
    ReadingKind.daily => _copy(
      language,
      en: 'Make the experiment small enough to complete today and note one observable sign around $theme.',
      tr: 'Deneyi bugün tamamlayabileceğin kadar küçük tut ve $theme çevresinde tek bir gözlemlenebilir işaret not et.',
      es: 'Haz el experimento lo bastante pequeño para terminarlo hoy y anota una señal observable alrededor de $theme.',
      fr: 'Gardez l’expérience assez petite pour la terminer aujourd’hui et notez un signe observable autour de $theme.',
      pt: 'Mantenha o experimento pequeno o bastante para concluir hoje e anote um sinal observável em torno de $theme.',
    ),
    ReadingKind.love || ReadingKind.compatibility => _copy(
      language,
      en: 'Prefer one respectful conversation or boundary you can observe in real behavior around $theme.',
      tr: '$theme çevresinde gerçek davranışta gözlemleyebileceğin tek bir saygılı konuşma veya sınır seç.',
      es: 'Elige una conversación respetuosa o un límite que puedas observar en la conducta real alrededor de $theme.',
      fr: 'Choisissez une conversation respectueuse ou une limite que vous pouvez observer dans le comportement réel autour de $theme.',
      pt: 'Escolha uma conversa respeitosa ou um limite que você possa observar no comportamento real em torno de $theme.',
    ),
    ReadingKind.career => _copy(
      language,
      en: 'Turn $theme into one controllable professional move: a message, decision, draft, boundary, or fifteen minutes of focused work.',
      tr: '$theme temasını kontrol edebileceğin tek bir profesyonel hamleye çevir: bir mesaj, karar, taslak, sınır veya on beş dakikalık odaklı çalışma.',
      es: 'Convierte $theme en un movimiento profesional controlable: un mensaje, una decisión, un borrador, un límite o quince minutos de trabajo enfocado.',
      fr: 'Transformez $theme en une action professionnelle contrôlable : un message, une décision, un brouillon, une limite ou quinze minutes de travail concentré.',
      pt: 'Transforme $theme em um movimento profissional controlável: uma mensagem, decisão, rascunho, limite ou quinze minutos de trabalho focado.',
    ),
    ReadingKind.money => _copy(
      language,
      en: 'Translate $theme into one measurable financial check such as a balance, price, deadline, budget line, or risk limit.',
      tr: '$theme temasını bakiye, fiyat, son tarih, bütçe kalemi veya risk sınırı gibi ölçülebilir tek bir mali kontrole çevir.',
      es: 'Traduce $theme en una comprobación financiera medible, como saldo, precio, fecha límite, partida presupuestaria o límite de riesgo.',
      fr: 'Traduisez $theme en une vérification financière mesurable : solde, prix, échéance, ligne budgétaire ou limite de risque.',
      pt: 'Traduza $theme em uma verificação financeira mensurável, como saldo, preço, prazo, linha de orçamento ou limite de risco.',
    ),
    ReadingKind.decision => _copy(
      language,
      en: 'Write one trade-off linked to $theme for each option and choose the next reversible test rather than the final answer.',
      tr: 'Her seçenek için $theme ile bağlantılı tek bir bedel yaz ve nihai cevap yerine geri döndürülebilir sıradaki testi seç.',
      es: 'Escribe un coste o beneficio ligado a $theme para cada opción y elige la siguiente prueba reversible en vez de una respuesta final.',
      fr: 'Écrivez un compromis lié à $theme pour chaque option et choisissez le prochain test réversible plutôt qu’une réponse définitive.',
      pt: 'Escreva uma troca ligada a $theme para cada opção e escolha o próximo teste reversível em vez de uma resposta final.',
    ),
    ReadingKind.spiritual => _copy(
      language,
      en: 'Choose one practice around $theme that produces an observable behavior rather than relying on a symbolic feeling alone.',
      tr: '$theme çevresinde yalnızca sembolik bir hisse değil, gözlemlenebilir bir davranışa dönüşen tek bir pratik seç.',
      es: 'Elige una práctica alrededor de $theme que produzca una conducta observable en lugar de depender solo de una sensación simbólica.',
      fr: 'Choisissez autour de $theme une pratique qui produit un comportement observable plutôt que de reposer uniquement sur un ressenti symbolique.',
      pt: 'Escolha uma prática em torno de $theme que produza um comportamento observável em vez de depender apenas de uma sensação simbólica.',
    ),
    ReadingKind.shadow => _copy(
      language,
      en: 'Name one repeated behavior around $theme and interrupt it with a safer, reversible alternative once today.',
      tr: '$theme çevresinde tekrarlanan tek bir davranışı adlandır ve bugün bir kez daha güvenli, geri döndürülebilir bir alternatifle kesintiye uğrat.',
      es: 'Nombra una conducta repetida alrededor de $theme e interrúmpela hoy una vez con una alternativa más segura y reversible.',
      fr: 'Nommez un comportement répété autour de $theme et interrompez-le aujourd’hui une fois avec une alternative plus sûre et réversible.',
      pt: 'Nomeie um comportamento repetido em torno de $theme e interrompa-o hoje uma vez com uma alternativa mais segura e reversível.',
    ),
    ReadingKind.timeline => _copy(
      language,
      en: 'Change one condition around $theme that is actually under your control, then compare tomorrow’s evidence with today’s assumption.',
      tr: '$theme çevresinde gerçekten kontrolünde olan tek bir koşulu değiştir; yarınki kanıtı bugünkü varsayımınla karşılaştır.',
      es: 'Cambia una condición alrededor de $theme que realmente controles y compara mañana la evidencia con la suposición de hoy.',
      fr: 'Modifiez une condition autour de $theme qui dépend réellement de vous, puis comparez demain les faits à l’hypothèse d’aujourd’hui.',
      pt: 'Mude uma condição em torno de $theme que esteja realmente sob seu controle e compare amanhã a evidência com a suposição de hoje.',
    ),
    ReadingKind.celticCross => _copy(
      language,
      en: 'Use $theme to choose one action that reduces uncertainty in the real situation without trying to solve the whole spread at once.',
      tr: '$theme temasını tüm açılımı bir anda çözmeye çalışmadan gerçek durumdaki belirsizliği azaltan tek bir eylem seçmek için kullan.',
      es: 'Usa $theme para elegir una acción que reduzca la incertidumbre de la situación real sin intentar resolver toda la tirada de una vez.',
      fr: 'Utilisez $theme pour choisir une action qui réduit l’incertitude de la situation réelle sans chercher à résoudre tout le tirage d’un coup.',
      pt: 'Use $theme para escolher uma ação que reduza a incerteza da situação real sem tentar resolver toda a tiragem de uma vez.',
    ),
  };
}

String _familyTheme(_CardFamily family, MysticLanguage language) =>
    switch (family) {
      _CardFamily.major => _copy(
        language,
        en: 'identity and transition',
        tr: 'kimlik ve dönüşüm',
        es: 'identidad y transición',
        fr: 'identité et transition',
        pt: 'identidade e transição',
      ),
      _CardFamily.wands => _copy(
        language,
        en: 'agency and momentum',
        tr: 'eylem gücü ve ivme',
        es: 'iniciativa y movimiento',
        fr: 'élan et capacité d’agir',
        pt: 'iniciativa e movimento',
      ),
      _CardFamily.cups => _copy(
        language,
        en: 'emotion and connection',
        tr: 'duygu ve bağ',
        es: 'emoción y vínculo',
        fr: 'émotion et lien',
        pt: 'emoção e conexão',
      ),
      _CardFamily.swords => _copy(
        language,
        en: 'thought and truth',
        tr: 'düşünce ve gerçeklik',
        es: 'pensamiento y verdad',
        fr: 'pensée et vérité',
        pt: 'pensamento e verdade',
      ),
      _CardFamily.pentacles => _copy(
        language,
        en: 'resources and stability',
        tr: 'kaynaklar ve istikrar',
        es: 'recursos y estabilidad',
        fr: 'ressources et stabilité',
        pt: 'recursos e estabilidade',
      ),
    };

String _context(
  MysticLanguage language, {
  required String emotion,
  required String intention,
}) => _copy(
  language,
  en: 'You began this reading feeling ${emotion.toLowerCase()} and holding ${intention.toLowerCase()} as your intention.',
  tr: 'Bu okumaya ${emotion.toLowerCase()} hissederek ve ${intention.toLowerCase()} niyetini taşıyarak başladın.',
  es: 'Comenzaste esta lectura sintiéndote ${emotion.toLowerCase()} y sosteniendo ${intention.toLowerCase()} como intención.',
  fr: 'Vous avez commencé ce tirage avec un ressenti ${emotion.toLowerCase()} et l’intention ${intention.toLowerCase()}.',
  pt: 'Você começou esta leitura se sentindo ${emotion.toLowerCase()} e mantendo ${intention.toLowerCase()} como intenção.',
);

enum _CardFamily { major, wands, cups, swords, pentacles }

_CardFamily _cardFamily(String cardName) {
  if (cardName.endsWith(' of Wands')) return _CardFamily.wands;
  if (cardName.endsWith(' of Cups')) return _CardFamily.cups;
  if (cardName.endsWith(' of Swords')) return _CardFamily.swords;
  if (cardName.endsWith(' of Pentacles')) return _CardFamily.pentacles;
  return _CardFamily.major;
}

class _ReadingLens {
  const _ReadingLens({
    required this.name,
    required this.position,
    required this.meaning,
    required this.advice,
    required this.contextMeaning,
    required this.contextAction,
    required this.family,
    required this.reversed,
  });

  final String name;
  final String position;
  final String meaning;
  final String advice;
  final String contextMeaning;
  final String contextAction;
  final _CardFamily family;
  final bool reversed;
}

String _localizedIntention(String intention, MysticLanguage language) {
  final normalized = intention.trim();
  if (normalized.isEmpty) {
    return _copy(
      language,
      en: 'your chosen path',
      tr: 'seçtiğin yol',
      es: 'tu camino elegido',
      fr: 'votre chemin choisi',
      pt: 'seu caminho escolhido',
    );
  }
  return switch ((language, normalized)) {
    (MysticLanguage.turkish, 'Love') => 'Aşk',
    (MysticLanguage.turkish, 'Purpose') => 'Amaç',
    (MysticLanguage.turkish, 'Healing') => 'İyileşme',
    (MysticLanguage.turkish, 'Clarity') => 'Netlik',
    (MysticLanguage.spanish, 'Love') => 'Amor',
    (MysticLanguage.spanish, 'Purpose') => 'Propósito',
    (MysticLanguage.spanish, 'Healing') => 'Sanación',
    (MysticLanguage.spanish, 'Clarity') => 'Claridad',
    (MysticLanguage.french, 'Love') => 'Amour',
    (MysticLanguage.french, 'Purpose') => 'Mission',
    (MysticLanguage.french, 'Healing') => 'Guérison',
    (MysticLanguage.french, 'Clarity') => 'Clarté',
    (MysticLanguage.portugueseBrazil, 'Love') => 'Amor',
    (MysticLanguage.portugueseBrazil, 'Purpose') => 'Propósito',
    (MysticLanguage.portugueseBrazil, 'Healing') => 'Cura',
    (MysticLanguage.portugueseBrazil, 'Clarity') => 'Clareza',
    _ => normalized,
  };
}

String _sentence(String value) {
  final text = value.trim();
  if (text.isEmpty) return text;
  if (RegExp(r'[.!?…]$').hasMatch(text)) return text;
  return '$text.';
}

String _cleanJoin(Iterable<String> parts) => parts
    .map((part) => part.trim())
    .where((part) => part.isNotEmpty)
    .join(' ')
    .replaceAll(RegExp(r' {2,}'), ' ');

String _copy(
  MysticLanguage language, {
  required String en,
  required String tr,
  required String es,
  required String fr,
  required String pt,
}) => switch (language) {
  MysticLanguage.turkish => tr,
  MysticLanguage.spanish => es,
  MysticLanguage.french => fr,
  MysticLanguage.portugueseBrazil => pt,
  _ => en,
};
