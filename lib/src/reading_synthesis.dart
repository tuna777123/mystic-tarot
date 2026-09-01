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
      es: 'No había cartas disponibles para sintetizar.',
      fr: 'Aucune carte n’était disponible pour la synthèse.',
      pt: 'Não havia cartas disponíveis para sintetizar.',
      tr: 'Bütünsel yorum için kullanılabilir kart bulunamadı.',
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
      en: '$context ${card.name} appears in ${card.position.toLowerCase()}. ${_sentence(card.meaning)} Try this grounded action: ${_sentence(card.advice)} Record what actually changes over the next twenty-four hours. This is a reflective invitation, not a prediction or certainty.',
      es: '$context ${card.name} aparece en ${card.position.toLowerCase()}. ${_sentence(card.meaning)} Prueba esta acción concreta: ${_sentence(card.advice)} Registra qué cambia realmente durante las próximas veinticuatro horas. Es una invitación a reflexionar, no una predicción ni una certeza.',
      fr: '$context ${card.name} apparaît dans ${card.position.toLowerCase()}. ${_sentence(card.meaning)} Essayez cette action concrète : ${_sentence(card.advice)} Notez ce qui change réellement pendant les prochaines vingt-quatre heures. C’est une invitation à réfléchir, pas une prédiction ni une certitude.',
      pt: '$context ${card.name} aparece em ${card.position.toLowerCase()}. ${_sentence(card.meaning)} Experimente esta ação concreta: ${_sentence(card.advice)} Registre o que realmente muda nas próximas vinte e quatro horas. É um convite à reflexão, não uma previsão nem uma certeza.',
      tr: '$context ${card.name}, ${card.position.toLowerCase()} konumunda beliriyor. ${_sentence(card.meaning)} Şu somut eylemi dene: ${_sentence(card.advice)} Önümüzdeki yirmi dört saatte gerçekte neyin değiştiğini kaydet. Bu, düşünmeye yönelik bir davettir; kehanet veya kesinlik değildir.',
    );
  }

  if (lenses.length == 2) {
    final first = lenses[0];
    final second = lenses[1];
    return _copy(
      language,
      en: '$context ${first.name} frames ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${second.name} frames ${second.position.toLowerCase()}: ${_sentence(second.meaning)} Read together, the cards compare two emphases rather than naming a predetermined winner. Try this grounded action: ${_sentence(second.advice)} Record what actually changes after twenty-four hours instead of treating either path as certainty.',
      es: '$context ${first.name} enmarca ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${second.name} enmarca ${second.position.toLowerCase()}: ${_sentence(second.meaning)} Leídas juntas, las cartas comparan dos énfasis en lugar de declarar un resultado predeterminado. Prueba esta acción concreta: ${_sentence(second.advice)} Registra qué cambia realmente después de veinticuatro horas sin tratar ninguno de los caminos como certeza.',
      fr: '$context ${first.name} éclaire ${first.position.toLowerCase()} : ${_sentence(first.meaning)} ${second.name} éclaire ${second.position.toLowerCase()} : ${_sentence(second.meaning)} Ensemble, les cartes comparent deux accents sans désigner un résultat prédéterminé. Essayez cette action concrète : ${_sentence(second.advice)} Notez ce qui change réellement après vingt-quatre heures sans traiter l’une des voies comme une certitude.',
      pt: '$context ${first.name} enquadra ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${second.name} enquadra ${second.position.toLowerCase()}: ${_sentence(second.meaning)} Juntas, as cartas comparam duas ênfases em vez de declarar um resultado predeterminado. Experimente esta ação concreta: ${_sentence(second.advice)} Registre o que realmente muda após vinte e quatro horas sem tratar nenhum caminho como certeza.',
      tr: '$context ${first.name}, ${first.position.toLowerCase()} konumunu çerçeveliyor: ${_sentence(first.meaning)} ${second.name}, ${second.position.toLowerCase()} konumunu çerçeveliyor: ${_sentence(second.meaning)} Birlikte okunduğunda kartlar önceden belirlenmiş bir kazanan söylemek yerine iki vurguyu karşılaştırıyor. Şu somut eylemi dene: ${_sentence(second.advice)} İki yoldan birini kesinlik saymak yerine yirmi dört saat sonra gerçekte neyin değiştiğini kaydet.',
    );
  }

  final relationship = _relationshipInsight(lenses, language);

  if (kind == ReadingKind.compatibility && lenses.length >= 5) {
    return _compatibilitySynthesis(lenses, context, relationship, language);
  }
  if (kind == ReadingKind.timeline && lenses.length >= 6) {
    return _timelineSynthesis(lenses, context, relationship, language);
  }
  if (kind == ReadingKind.celticCross && lenses.length >= 10) {
    return _celticCrossSynthesis(lenses, context, relationship, language);
  }

  final first = lenses.first;
  final bridge = lenses[lenses.length ~/ 2];
  final last = lenses.last;
  return _copy(
    language,
    en: '$context ${first.name} opens the reading through ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${bridge.name} holds the central tension through ${bridge.position.toLowerCase()}: ${_sentence(bridge.meaning)} ${last.name} gives the direction of travel through ${last.position.toLowerCase()}: ${_sentence(last.meaning)} $relationship Taken together, the spread moves from the opening condition, through the central pressure, toward one testable direction. Use this grounded experiment: ${_sentence(last.advice)} Then record what actually changed after twenty-four hours rather than treating the cards as certainty.',
    es: '$context ${first.name} abre la lectura desde ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${bridge.name} sostiene la tensión central desde ${bridge.position.toLowerCase()}: ${_sentence(bridge.meaning)} ${last.name} marca la dirección desde ${last.position.toLowerCase()}: ${_sentence(last.meaning)} $relationship En conjunto, la tirada avanza desde la condición inicial, atraviesa la presión central y llega a una dirección que puedes probar. Usa este experimento concreto: ${_sentence(last.advice)} Después registra qué cambió realmente tras veinticuatro horas sin tratar las cartas como certeza.',
    fr: '$context ${first.name} ouvre le tirage à travers ${first.position.toLowerCase()} : ${_sentence(first.meaning)} ${bridge.name} porte la tension centrale à travers ${bridge.position.toLowerCase()} : ${_sentence(bridge.meaning)} ${last.name} indique la direction à travers ${last.position.toLowerCase()} : ${_sentence(last.meaning)} $relationship Ensemble, les cartes vont de la condition initiale, traversent la pression centrale et aboutissent à une direction que vous pouvez tester. Utilisez cette expérience concrète : ${_sentence(last.advice)} Notez ensuite ce qui a réellement changé après vingt-quatre heures sans traiter les cartes comme une certitude.',
    pt: '$context ${first.name} abre a leitura por ${first.position.toLowerCase()}: ${_sentence(first.meaning)} ${bridge.name} sustenta a tensão central por ${bridge.position.toLowerCase()}: ${_sentence(bridge.meaning)} ${last.name} aponta a direção por ${last.position.toLowerCase()}: ${_sentence(last.meaning)} $relationship Em conjunto, a tiragem parte da condição inicial, atravessa a pressão central e chega a uma direção que você pode testar. Use este experimento concreto: ${_sentence(last.advice)} Depois registre o que realmente mudou após vinte e quatro horas sem tratar as cartas como certeza.',
    tr: '$context ${first.name}, ${first.position.toLowerCase()} üzerinden okumayı açıyor: ${_sentence(first.meaning)} ${bridge.name}, ${bridge.position.toLowerCase()} üzerinden merkezdeki gerilimi taşıyor: ${_sentence(bridge.meaning)} ${last.name}, ${last.position.toLowerCase()} üzerinden yönü gösteriyor: ${_sentence(last.meaning)} $relationship Birlikte okunduğunda açılım başlangıç koşulundan merkezdeki baskıya, oradan da deneyebileceğin bir yöne ilerliyor. Şu somut deneyi uygula: ${_sentence(last.advice)} Ardından kartları kesinlik saymak yerine yirmi dört saat sonra gerçekte neyin değiştiğini kaydet.',
  );
}

String _compatibilitySynthesis(
  List<_ReadingLens> lenses,
  String context,
  String relationship,
  MysticLanguage language,
) {
  final you = lenses[0];
  final other = lenses[1];
  final dynamic = lenses[2];
  final growth = lenses[3];
  final step = lenses[4];
  return _copy(
    language,
    en: '$context ${you.name} describes ${you.position.toLowerCase()}; ${other.name} describes ${other.position.toLowerCase()}. ${dynamic.name} names the shared dynamic: ${_sentence(dynamic.meaning)} ${growth.name} marks ${growth.position.toLowerCase()}, while ${step.name} turns the reading toward ${step.position.toLowerCase()}. $relationship The relationship is not reduced to a compatibility score. Use this grounded experiment: ${_sentence(step.advice)} Then observe what changes in the next twenty-four hours without treating the cards as certainty.',
    es: '$context ${you.name} describe ${you.position.toLowerCase()}; ${other.name} describe ${other.position.toLowerCase()}. ${dynamic.name} nombra la dinámica compartida: ${_sentence(dynamic.meaning)} ${growth.name} señala ${growth.position.toLowerCase()}, mientras ${step.name} orienta la lectura hacia ${step.position.toLowerCase()}. $relationship La relación no se reduce a una puntuación de compatibilidad. Usa este experimento concreto: ${_sentence(step.advice)} Después observa qué cambia durante las próximas veinticuatro horas sin tratar las cartas como certeza.',
    fr: '$context ${you.name} décrit ${you.position.toLowerCase()} ; ${other.name} décrit ${other.position.toLowerCase()}. ${dynamic.name} nomme la dynamique commune : ${_sentence(dynamic.meaning)} ${growth.name} indique ${growth.position.toLowerCase()}, tandis que ${step.name} oriente le tirage vers ${step.position.toLowerCase()}. $relationship La relation n’est pas réduite à un score de compatibilité. Utilisez cette expérience concrète : ${_sentence(step.advice)} Observez ensuite ce qui change pendant les prochaines vingt-quatre heures sans traiter les cartes comme une certitude.',
    pt: '$context ${you.name} descreve ${you.position.toLowerCase()}; ${other.name} descreve ${other.position.toLowerCase()}. ${dynamic.name} nomeia a dinâmica compartilhada: ${_sentence(dynamic.meaning)} ${growth.name} marca ${growth.position.toLowerCase()}, enquanto ${step.name} direciona a leitura para ${step.position.toLowerCase()}. $relationship A relação não é reduzida a uma pontuação de compatibilidade. Use este experimento concreto: ${_sentence(step.advice)} Depois observe o que muda nas próximas vinte e quatro horas sem tratar as cartas como certeza.',
    tr: '$context ${you.name}, ${you.position.toLowerCase()} konumunu; ${other.name}, ${other.position.toLowerCase()} konumunu anlatıyor. ${dynamic.name} ortak dinamiği adlandırıyor: ${_sentence(dynamic.meaning)} ${growth.name}, ${growth.position.toLowerCase()} alanını işaret ederken ${step.name} okumayı ${step.position.toLowerCase()} yönüne taşıyor. $relationship Bağ tek bir uyum puanına indirgenmiyor. Şu somut deneyi uygula: ${_sentence(step.advice)} Ardından kartları kesinlik saymadan önümüzdeki yirmi dört saatte neyin değiştiğini gözlemle.',
  );
}

String _timelineSynthesis(
  List<_ReadingLens> lenses,
  String context,
  String relationship,
  MysticLanguage language,
) {
  final past = lenses[0];
  final present = lenses[1];
  final near = lenses[2];
  final chapter = lenses[3];
  final horizon = lenses[4];
  final agency = lenses[5];
  return _copy(
    language,
    en: '$context ${past.name} shows the past influence still active, while ${present.name} marks the present threshold. ${near.name} and ${chapter.name} describe the nearest movement and following chapter; ${horizon.name} extends the view toward ${horizon.position.toLowerCase()}. ${agency.name} restores agency through ${agency.position.toLowerCase()}: ${_sentence(agency.meaning)} $relationship This is a conditional trajectory, not a fixed future. Use this grounded experiment: ${_sentence(agency.advice)} Revisit the reading after twenty-four hours and record which condition actually shifted.',
    es: '$context ${past.name} muestra la influencia pasada aún activa, mientras ${present.name} marca el umbral presente. ${near.name} y ${chapter.name} describen el movimiento más cercano y el capítulo siguiente; ${horizon.name} amplía la mirada hacia ${horizon.position.toLowerCase()}. ${agency.name} devuelve capacidad de acción desde ${agency.position.toLowerCase()}: ${_sentence(agency.meaning)} $relationship Es una trayectoria condicional, no un futuro fijo. Usa este experimento concreto: ${_sentence(agency.advice)} Revisa la lectura después de veinticuatro horas y registra qué condición cambió realmente.',
    fr: '$context ${past.name} montre l’influence passée encore active, tandis que ${present.name} marque le seuil présent. ${near.name} et ${chapter.name} décrivent le mouvement le plus proche et le chapitre suivant ; ${horizon.name} élargit la vue vers ${horizon.position.toLowerCase()}. ${agency.name} rend une marge d’action à travers ${agency.position.toLowerCase()} : ${_sentence(agency.meaning)} $relationship Il s’agit d’une trajectoire conditionnelle, pas d’un avenir figé. Utilisez cette expérience concrète : ${_sentence(agency.advice)} Revenez au tirage après vingt-quatre heures et notez quelle condition a réellement changé.',
    pt: '$context ${past.name} mostra a influência passada ainda ativa, enquanto ${present.name} marca o limiar presente. ${near.name} e ${chapter.name} descrevem o movimento mais próximo e o capítulo seguinte; ${horizon.name} amplia a visão para ${horizon.position.toLowerCase()}. ${agency.name} devolve capacidade de ação por ${agency.position.toLowerCase()}: ${_sentence(agency.meaning)} $relationship Esta é uma trajetória condicional, não um futuro fixo. Use este experimento concreto: ${_sentence(agency.advice)} Reveja a leitura após vinte e quatro horas e registre qual condição realmente mudou.',
    tr: '$context ${past.name} hâlâ etkin olan geçmiş etkisini, ${present.name} ise şimdiki eşiği gösteriyor. ${near.name} ve ${chapter.name} en yakın hareketle sonraki bölümü anlatırken ${horizon.name} bakışı ${horizon.position.toLowerCase()} alanına uzatıyor. ${agency.name}, ${agency.position.toLowerCase()} üzerinden seçim gücünü geri getiriyor: ${_sentence(agency.meaning)} $relationship Bu sabit bir gelecek değil, koşullu bir gidişattır. Şu somut deneyi uygula: ${_sentence(agency.advice)} Okumaya yirmi dört saat sonra dön ve hangi koşulun gerçekten değiştiğini kaydet.',
  );
}

String _celticCrossSynthesis(
  List<_ReadingLens> lenses,
  String context,
  String relationship,
  MysticLanguage language,
) {
  final present = lenses[0];
  final challenge = lenses[1];
  final nearFuture = lenses[5];
  final direction = lenses[9];
  return _copy(
    language,
    en: '$context ${present.name} anchors the present situation: ${_sentence(present.meaning)} ${challenge.name} names the immediate challenge: ${_sentence(challenge.meaning)} The foundation, recent past, conscious possibility, inner stance, environment, and hopes or fears remain supporting evidence rather than separate predictions. ${nearFuture.name} describes the near-future movement, and ${direction.name} shows the direction if the current pattern continues: ${_sentence(direction.meaning)} $relationship The outcome is conditional, not fixed. Use this grounded experiment: ${_sentence(direction.advice)} Return after twenty-four hours and record which part of the pattern actually moved.',
    es: '$context ${present.name} ancla la situación presente: ${_sentence(present.meaning)} ${challenge.name} nombra el desafío inmediato: ${_sentence(challenge.meaning)} La base, el pasado reciente, la posibilidad consciente, la postura interior, el entorno y las esperanzas o temores permanecen como evidencia de apoyo, no como predicciones separadas. ${nearFuture.name} describe el movimiento del futuro cercano y ${direction.name} muestra la dirección si continúa el patrón actual: ${_sentence(direction.meaning)} $relationship El resultado es condicional, no fijo. Usa este experimento concreto: ${_sentence(direction.advice)} Vuelve después de veinticuatro horas y registra qué parte del patrón se movió realmente.',
    fr: '$context ${present.name} ancre la situation présente : ${_sentence(present.meaning)} ${challenge.name} nomme le défi immédiat : ${_sentence(challenge.meaning)} La fondation, le passé récent, la possibilité consciente, la posture intérieure, l’environnement et les espoirs ou craintes restent des indices de soutien, pas des prédictions séparées. ${nearFuture.name} décrit le mouvement du futur proche et ${direction.name} montre la direction si le schéma actuel continue : ${_sentence(direction.meaning)} $relationship L’issue est conditionnelle, pas figée. Utilisez cette expérience concrète : ${_sentence(direction.advice)} Revenez après vingt-quatre heures et notez quelle partie du schéma a réellement bougé.',
    pt: '$context ${present.name} ancora a situação presente: ${_sentence(present.meaning)} ${challenge.name} nomeia o desafio imediato: ${_sentence(challenge.meaning)} A base, o passado recente, a possibilidade consciente, a postura interior, o ambiente e as esperanças ou medos permanecem como evidências de apoio, não como previsões separadas. ${nearFuture.name} descreve o movimento do futuro próximo e ${direction.name} mostra a direção se o padrão atual continuar: ${_sentence(direction.meaning)} $relationship O resultado é condicional, não fixo. Use este experimento concreto: ${_sentence(direction.advice)} Volte após vinte e quatro horas e registre qual parte do padrão realmente se moveu.',
    tr: '$context ${present.name} mevcut durumu sabitliyor: ${_sentence(present.meaning)} ${challenge.name} yakın meydan okumayı adlandırıyor: ${_sentence(challenge.meaning)} Temel, yakın geçmiş, bilinçli ihtimal, iç tutum, dış çevre ve umutlarla korkular ayrı kehanetler değil; ana yorumu destekleyen kanıtlardır. ${nearFuture.name} yakın gelecek hareketini, ${direction.name} ise mevcut örüntü sürerse oluşabilecek yönü gösteriyor: ${_sentence(direction.meaning)} $relationship Sonuç sabit değil, koşulludur. Şu somut deneyi uygula: ${_sentence(direction.advice)} Yirmi dört saat sonra dön ve örüntünün hangi parçasının gerçekten hareket ettiğini kaydet.',
  );
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
      en: '${first.name} in ${first.position.toLowerCase()} and ${second.name} in ${second.position.toLowerCase()} repeat the $theme thread, but they arrive in opposite orientations. That makes the theme a live tension rather than a simple confirmation: notice where it flows cleanly and where it gets blocked.',
      es: '${first.name} en ${first.position.toLowerCase()} y ${second.name} en ${second.position.toLowerCase()} repiten el hilo de $theme, pero llegan con orientaciones opuestas. Eso convierte el tema en una tensión activa, no en una confirmación simple: observa dónde fluye y dónde se bloquea.',
      fr: '${first.name} dans ${first.position.toLowerCase()} et ${second.name} dans ${second.position.toLowerCase()} répètent le fil de $theme, mais avec des orientations opposées. Le thème devient donc une tension active plutôt qu’une simple confirmation : observez où il circule et où il se bloque.',
      pt: '${first.name} em ${first.position.toLowerCase()} e ${second.name} em ${second.position.toLowerCase()} repetem o fio de $theme, mas chegam em orientações opostas. Isso transforma o tema em uma tensão ativa, não em uma simples confirmação: observe onde ele flui e onde fica bloqueado.',
      tr: '${first.name}, ${first.position.toLowerCase()} alanında; ${second.name} ise ${second.position.toLowerCase()} alanında aynı $theme temasını tekrar ediyor, fakat zıt yönlerde geliyor. Bu nedenle tema basit bir onay değil, canlı bir gerilim: nerede rahat aktığını ve nerede tıkandığını gözlemle.',
    );
  }

  if (sameFamily) {
    final theme = _familyTheme(first.family, language);
    return _copy(
      language,
      en: '${first.name} in ${first.position.toLowerCase()} and ${second.name} in ${second.position.toLowerCase()} reinforce the $theme thread across two positions. Because both the theme and orientation repeat, this pattern carries more weight than either card by itself.',
      es: '${first.name} en ${first.position.toLowerCase()} y ${second.name} en ${second.position.toLowerCase()} refuerzan el hilo de $theme en dos posiciones. Como se repiten tanto el tema como la orientación, este patrón pesa más que cualquiera de las cartas por separado.',
      fr: '${first.name} dans ${first.position.toLowerCase()} et ${second.name} dans ${second.position.toLowerCase()} renforcent le fil de $theme à deux positions. Puisque le thème et l’orientation se répètent, ce motif compte davantage que chacune des cartes prise isolément.',
      pt: '${first.name} em ${first.position.toLowerCase()} e ${second.name} em ${second.position.toLowerCase()} reforçam o fio de $theme em duas posições. Como tema e orientação se repetem, esse padrão tem mais peso do que qualquer uma das cartas isoladamente.',
      tr: '${first.name}, ${first.position.toLowerCase()} alanında; ${second.name} ise ${second.position.toLowerCase()} alanında $theme temasını iki ayrı konumda güçlendiriyor. Hem tema hem yön tekrarlandığı için bu örüntü, kartlardan herhangi birinin tek başına taşıdığından daha fazla ağırlık kazanıyor.',
    );
  }

  final firstTheme = _familyTheme(first.family, language);
  final secondTheme = _familyTheme(second.family, language);

  if (!sameOrientation) {
    return _copy(
      language,
      en: '${first.name} in ${first.position.toLowerCase()} and ${second.name} in ${second.position.toLowerCase()} form the clearest contrast: $firstTheme meets $secondTheme, and their orientations pull in different directions. Read that as an interaction to test, not a verdict about which card is right.',
      es: '${first.name} en ${first.position.toLowerCase()} y ${second.name} en ${second.position.toLowerCase()} forman el contraste más claro: $firstTheme se encuentra con $secondTheme y sus orientaciones tiran en direcciones distintas. Léelo como una interacción que puedes poner a prueba, no como un veredicto sobre qué carta tiene razón.',
      fr: '${first.name} dans ${first.position.toLowerCase()} et ${second.name} dans ${second.position.toLowerCase()} forment le contraste le plus net : $firstTheme rencontre $secondTheme et leurs orientations tirent dans des directions différentes. Lisez cela comme une interaction à tester, pas comme un verdict sur la carte qui aurait raison.',
      pt: '${first.name} em ${first.position.toLowerCase()} e ${second.name} em ${second.position.toLowerCase()} formam o contraste mais claro: $firstTheme encontra $secondTheme e suas orientações puxam em direções diferentes. Leia isso como uma interação a ser testada, não como um veredito sobre qual carta está certa.',
      tr: '${first.name}, ${first.position.toLowerCase()} alanında; ${second.name} ise ${second.position.toLowerCase()} alanında en belirgin karşıtlığı kuruyor: $firstTheme ile $secondTheme buluşuyor ve kartların yönleri farklı taraflara çekiyor. Bunu hangi kartın haklı olduğuna dair bir hüküm değil, test edilecek bir etkileşim olarak oku.',
    );
  }

  return _copy(
    language,
    en: '${first.name} in ${first.position.toLowerCase()} and ${second.name} in ${second.position.toLowerCase()} connect two different layers: $firstTheme and $secondTheme. Their orientations agree, so the spread reads more like coordination between these pressures than a fight between them.',
    es: '${first.name} en ${first.position.toLowerCase()} y ${second.name} en ${second.position.toLowerCase()} conectan dos capas distintas: $firstTheme y $secondTheme. Sus orientaciones coinciden, así que la tirada se lee más como coordinación entre esas presiones que como una pelea entre ellas.',
    fr: '${first.name} dans ${first.position.toLowerCase()} et ${second.name} dans ${second.position.toLowerCase()} relient deux niveaux différents : $firstTheme et $secondTheme. Leurs orientations concordent, de sorte que le tirage parle davantage de coordination entre ces pressions que de conflit.',
    pt: '${first.name} em ${first.position.toLowerCase()} e ${second.name} em ${second.position.toLowerCase()} conectam duas camadas diferentes: $firstTheme e $secondTheme. As orientações concordam, então a tiragem fala mais de coordenação entre essas pressões do que de conflito.',
    tr: '${first.name}, ${first.position.toLowerCase()} alanında; ${second.name} ise ${second.position.toLowerCase()} alanında iki farklı katmanı birbirine bağlıyor: $firstTheme ve $secondTheme. Yönleri aynı olduğu için açılım bu baskılar arasında çatışmadan çok koordinasyon gösteriyor.',
  );
}

(_ReadingLens, _ReadingLens) _relationshipPair(List<_ReadingLens> lenses) {
  for (var distance = lenses.length - 1; distance >= 1; distance--) {
    for (var start = 0; start + distance < lenses.length; start++) {
      final first = lenses[start];
      final second = lenses[start + distance];
      if (first.family == second.family) {
        return (first, second);
      }
    }
  }

  for (var index = 0; index < lenses.length - 1; index++) {
    final first = lenses[index];
    final second = lenses[index + 1];
    if (first.reversed != second.reversed) {
      return (first, second);
    }
  }

  return (lenses.first, lenses.last);
}

String _familyTheme(_CardFamily family, MysticLanguage language) =>
    switch (family) {
      _CardFamily.major => _copy(
        language,
        en: 'identity and transition',
        es: 'identidad y transición',
        fr: 'identité et transition',
        pt: 'identidade e transição',
        tr: 'kimlik ve dönüşüm',
      ),
      _CardFamily.wands => _copy(
        language,
        en: 'agency and momentum',
        es: 'iniciativa y movimiento',
        fr: 'élan et capacité d’agir',
        pt: 'iniciativa e movimento',
        tr: 'eylem gücü ve ivme',
      ),
      _CardFamily.cups => _copy(
        language,
        en: 'emotion and connection',
        es: 'emoción y vínculo',
        fr: 'émotion et lien',
        pt: 'emoção e conexão',
        tr: 'duygu ve bağ',
      ),
      _CardFamily.swords => _copy(
        language,
        en: 'thought and truth',
        es: 'pensamiento y verdad',
        fr: 'pensée et vérité',
        pt: 'pensamento e verdade',
        tr: 'düşünce ve gerçeklik',
      ),
      _CardFamily.pentacles => _copy(
        language,
        en: 'resources and stability',
        es: 'recursos y estabilidad',
        fr: 'ressources et stabilité',
        pt: 'recursos e estabilidade',
        tr: 'kaynaklar ve istikrar',
      ),
    };

String _context(
  MysticLanguage language, {
  required String emotion,
  required String intention,
}) => _copy(
  language,
  en: 'You began this reading feeling ${emotion.toLowerCase()} and holding ${intention.toLowerCase()} as your intention.',
  es: 'Comenzaste esta lectura sintiéndote ${emotion.toLowerCase()} y sosteniendo ${intention.toLowerCase()} como intención.',
  fr: 'Vous avez commencé ce tirage avec un ressenti ${emotion.toLowerCase()} et l’intention ${intention.toLowerCase()}.',
  pt: 'Você começou esta leitura se sentindo ${emotion.toLowerCase()} e mantendo ${intention.toLowerCase()} como intenção.',
  tr: 'Bu okumaya ${emotion.toLowerCase()} hissederek ve ${intention.toLowerCase()} niyetini taşıyarak başladın.',
);

_ReadingLens _lens(
  ReadingKind kind,
  DrawnCard card,
  int index,
  MysticLanguage language,
) => _ReadingLens(
  name: localizedTarotCardName(card.card.name, languageCode: language.code),
  position: localizedReadingPosition(
    kind: kind,
    index: index,
    language: language,
  ),
  meaning: localizedTarotCardMeaning(card, languageCode: language.code),
  advice: localizedTarotCardAdvice(card, languageCode: language.code),
  family: _cardFamily(card.card.name),
  reversed: card.reversed,
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
    required this.family,
    required this.reversed,
  });

  final String name;
  final String position;
  final String meaning;
  final String advice;
  final _CardFamily family;
  final bool reversed;
}

String _localizedIntention(String intention, MysticLanguage language) {
  final normalized = intention.trim();
  if (normalized.isEmpty) {
    return _copy(
      language,
      en: 'your chosen path',
      es: 'tu camino elegido',
      fr: 'votre chemin choisi',
      pt: 'seu caminho escolhido',
      tr: 'seçtiğin yol',
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

String _copy(
  MysticLanguage language, {
  required String en,
  required String es,
  required String fr,
  required String pt,
  required String tr,
}) => switch (language) {
  MysticLanguage.turkish => tr,
  MysticLanguage.spanish => es,
  MysticLanguage.french => fr,
  MysticLanguage.portugueseBrazil => pt,
  _ => en,
};
