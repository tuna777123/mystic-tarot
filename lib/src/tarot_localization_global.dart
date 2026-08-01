import 'models.dart';

const _majorNamesSpanish = <String, String>{
  'The Fool': 'El Loco',
  'The Magician': 'El Mago',
  'The High Priestess': 'La Sacerdotisa',
  'The Empress': 'La Emperatriz',
  'The Emperor': 'El Emperador',
  'The Hierophant': 'El Hierofante',
  'The Lovers': 'Los Enamorados',
  'The Chariot': 'El Carro',
  'Strength': 'La Fuerza',
  'The Hermit': 'El Ermitaño',
  'Wheel of Fortune': 'La Rueda de la Fortuna',
  'Justice': 'La Justicia',
  'The Hanged Man': 'El Colgado',
  'Death': 'La Muerte',
  'Temperance': 'La Templanza',
  'The Devil': 'El Diablo',
  'The Tower': 'La Torre',
  'The Star': 'La Estrella',
  'The Moon': 'La Luna',
  'The Sun': 'El Sol',
  'Judgement': 'El Juicio',
  'The World': 'El Mundo',
};

const _majorNamesPortuguese = <String, String>{
  'The Fool': 'O Louco',
  'The Magician': 'O Mago',
  'The High Priestess': 'A Sacerdotisa',
  'The Empress': 'A Imperatriz',
  'The Emperor': 'O Imperador',
  'The Hierophant': 'O Hierofante',
  'The Lovers': 'Os Enamorados',
  'The Chariot': 'O Carro',
  'Strength': 'A Força',
  'The Hermit': 'O Eremita',
  'Wheel of Fortune': 'A Roda da Fortuna',
  'Justice': 'A Justiça',
  'The Hanged Man': 'O Enforcado',
  'Death': 'A Morte',
  'Temperance': 'A Temperança',
  'The Devil': 'O Diabo',
  'The Tower': 'A Torre',
  'The Star': 'A Estrela',
  'The Moon': 'A Lua',
  'The Sun': 'O Sol',
  'Judgement': 'O Julgamento',
  'The World': 'O Mundo',
};

const _rankSpanish = <String, String>{
  'Ace': 'As', 'Two': 'Dos', 'Three': 'Tres', 'Four': 'Cuatro',
  'Five': 'Cinco', 'Six': 'Seis', 'Seven': 'Siete', 'Eight': 'Ocho',
  'Nine': 'Nueve', 'Ten': 'Diez', 'Page': 'Sota', 'Knight': 'Caballero',
  'Queen': 'Reina', 'King': 'Rey',
};
const _rankPortuguese = <String, String>{
  'Ace': 'Ás', 'Two': 'Dois', 'Three': 'Três', 'Four': 'Quatro',
  'Five': 'Cinco', 'Six': 'Seis', 'Seven': 'Sete', 'Eight': 'Oito',
  'Nine': 'Nove', 'Ten': 'Dez', 'Page': 'Pajem', 'Knight': 'Cavaleiro',
  'Queen': 'Rainha', 'King': 'Rei',
};
const _suitSpanish = <String, String>{
  'Wands': 'Bastos', 'Cups': 'Copas', 'Swords': 'Espadas', 'Pentacles': 'Oros',
};
const _suitPortuguese = <String, String>{
  'Wands': 'Paus', 'Cups': 'Copas', 'Swords': 'Espadas', 'Pentacles': 'Ouros',
};

const _majorMeaningSpanish = <String, List<String>>{
  'The Fool': [
    'Un nuevo comienzo te pide confianza, curiosidad y un primer paso valiente.',
    'Dar el salto puede ser tentador, pero la libertad sin conciencia puede convertirse en evasión.',
    'Avanza, pero mira con sinceridad dónde van a caer tus pies.',
  ],
  'The Magician': [
    'Ya tienes las herramientas necesarias para dar forma a este momento con intención.',
    'La dispersión o la duda están debilitando tu capacidad de influir.',
    'Elige un resultado y dirige tu energía hacia él sin disculparte.',
  ],
  'The High Priestess': [
    'La respuesta silenciosa bajo el ruido es más fiable que la presión exterior.',
    'Tal vez estés ignorando tu intuición porque su mensaje resulta incómodo.',
    'Haz una pausa antes de actuar y observa lo que tu cuerpo ya sabe.',
  ],
  'The Empress': [
    'El crecimiento llega mediante el cuidado, el placer, la paciencia y la nutrición creativa.',
    'Dar demasiado puede estar dejando desatendido tu propio mundo interior.',
    'Crea condiciones en las que tú y tu deseo puedan florecer.',
  ],
  'The Emperor': [
    'La estructura y los límites claros convertirán la intención en progreso estable.',
    'El control puede estar sustituyendo a la confianza, la flexibilidad o el liderazgo real.',
    'Construye un marco firme sin convertirlo en una prisión.',
  ],
  'The Hierophant': [
    'Una enseñanza, un ritual o una comunidad de confianza puede dar sentido útil a este momento.',
    'Seguir la tradición sin reflexionar puede silenciar tu propia sabiduría.',
    'Aprende la tradición y decide conscientemente qué merece continuar.',
  ],
  'The Lovers': [
    'La armonía crece cuando valores, deseo y elección apuntan en la misma dirección.',
    'La atracción por sí sola no puede resolver un conflicto de valores.',
    'Elige lo que te permita seguir conectado sin abandonarte.',
  ],
  'The Chariot': [
    'Una voluntad enfocada puede llevarte a través de fuerzas opuestas y de la incertidumbre.',
    'La velocidad sin dirección emocional puede producir una victoria vacía.',
    'Nombra el destino antes de esforzarte más.',
  ],
  'Strength': [
    'El valor sereno y la estabilidad emocional son más fuertes que la imposición.',
    'Un miedo reprimido puede estar disfrazándose de confianza.',
    'Encuéntrate con la emoción difícil con paciencia, no con dominio.',
  ],
  'The Hermit': [
    'La soledad ofrece la claridad que el exceso de estímulos había ocultado.',
    'Retirarte puede estar protegiéndote de una conversación importante.',
    'Aléjate el tiempo suficiente para escucharte y luego vuelve con la verdad.',
  ],
  'Wheel of Fortune': [
    'Un ciclo está girando; la flexibilidad te permite reconocer la oportunidad.',
    'Intentar congelar lo que cambia crea una fricción innecesaria.',
    'Trabaja con el movimiento en lugar de exigir que regrese el ayer.',
  ],
  'Justice': [
    'La verdad, la responsabilidad y la proporción restauran el equilibrio.',
    'Una historia conveniente puede estar ocultando tu parte de responsabilidad.',
    'Toma la decisión que respetarías aunque nadie aplaudiera.',
  ],
  'The Hanged Man': [
    'Una pausa deliberada revela una perspectiva que el esfuerzo por sí solo no alcanza.',
    'La espera puede haberse convertido en evasión, sacrificio o apego al estancamiento.',
    'Suelta la necesidad de forzar el movimiento y mira desde el ángulo opuesto.',
  ],
  'Death': [
    'Un final está despejando espacio para una forma de vida más sincera.',
    'Aferrarte a un capítulo terminado está retrasando la renovación.',
    'Suelta la identidad que ya no puede llevarte hacia adelante.',
  ],
  'Temperance': [
    'La integración paciente crea un resultado que los extremos no pueden ofrecer.',
    'La impaciencia te arrastra entre reacciones de todo o nada.',
    'Haz que el próximo ajuste sea lo bastante pequeño como para sostenerlo.',
  ],
  'The Devil': [
    'Ver el apego con claridad es el comienzo de la libertad.',
    'Un deseo, miedo o acuerdo conocido puede estar eligiendo por ti.',
    'Nombra el coste del patrón y recupera hoy una elección.',
  ],
  'The Tower': [
    'Una estructura falsa se rompe para que la verdad pueda hacerse visible.',
    'La resistencia puede intensificar un cambio que ya ha comenzado.',
    'Protege lo real y deja caer lo que solo era apariencia.',
  ],
  'The Star': [
    'La esperanza regresa mediante la autenticidad, la renovación y una perspectiva más amplia.',
    'La decepción puede estar haciendo que la posibilidad parezca insegura.',
    'Practica un pequeño acto de fe sin exigirle nada al resultado.',
  ],
  'The Moon': [
    'Los sueños y las emociones revelan lo que la lógica aún no puede ordenar.',
    'El miedo está llenando la información que falta con ilusiones convincentes.',
    'Espera más luz antes de llamar hecho a la incertidumbre.',
  ],
  'The Sun': [
    'La vitalidad, la claridad y la alegría sincera están disponibles sin complicación.',
    'La presión por parecer positivo puede estar ocultando una necesidad real.',
    'Deja que el éxito sea sencillo y comparte calidez sin convertirla en actuación.',
  ],
  'Judgement': [
    'Una llamada más profunda te pide responder con sinceridad y renovación.',
    'La vieja vergüenza puede mantenerte leal a una versión más pequeña de ti.',
    'Responde a quien estás llegando a ser, no a quien tuviste que ser.',
  ],
  'The World': [
    'La culminación trae integración, confianza y un horizonte más amplio.',
    'Un detalle sin terminar puede estar impidiendo un cierre completo.',
    'Honra lo que está completo antes de comenzar el siguiente ciclo.',
  ],
};

const _majorMeaningPortuguese = <String, List<String>>{
  'The Fool': [
    'Um novo começo pede confiança, curiosidade e um primeiro passo corajoso.',
    'Dar o salto pode ser tentador, mas liberdade sem consciência pode virar fuga.',
    'Siga em frente, mas olhe com sinceridade para onde seus pés vão pousar.',
  ],
  'The Magician': [
    'Você já tem as ferramentas necessárias para moldar este momento com intenção.',
    'Foco disperso ou dúvida estão diminuindo sua influência.',
    'Escolha um resultado e direcione sua energia a ele sem pedir desculpas.',
  ],
  'The High Priestess': [
    'A resposta silenciosa sob o ruído é mais confiável do que a pressão externa.',
    'Talvez você esteja ignorando a intuição porque a mensagem dela é inconveniente.',
    'Faça uma pausa antes de agir e observe o que seu corpo já sabe.',
  ],
  'The Empress': [
    'O crescimento vem por meio de cuidado, prazer, paciência e nutrição criativa.',
    'Dar demais pode estar deixando seu próprio mundo interior sem alimento.',
    'Crie condições para que você e seu desejo possam florescer.',
  ],
  'The Emperor': [
    'Estrutura e limites claros transformarão intenção em progresso confiável.',
    'O controle pode estar substituindo confiança, flexibilidade ou liderança real.',
    'Construa uma estrutura firme sem transformá-la em prisão.',
  ],
  'The Hierophant': [
    'Um ensinamento, ritual ou comunidade de confiança pode dar sentido útil a este momento.',
    'Seguir a tradição sem refletir pode silenciar sua própria sabedoria.',
    'Aprenda a tradição e escolha conscientemente o que merece continuar.',
  ],
  'The Lovers': [
    'O alinhamento cresce quando valores, desejo e escolha apontam na mesma direção.',
    'A atração sozinha não resolve um conflito de valores.',
    'Escolha o que permite continuar conectado sem se abandonar.',
  ],
  'The Chariot': [
    'Uma vontade focada pode levar você por forças opostas e pela incerteza.',
    'Velocidade sem direção emocional pode criar uma vitória vazia.',
    'Dê nome ao destino antes de forçar mais.',
  ],
  'Strength': [
    'Coragem gentil e estabilidade emocional são mais fortes do que imposição.',
    'Um medo reprimido pode estar vestido de confiança.',
    'Encontre a emoção difícil com paciência, não com dominação.',
  ],
  'The Hermit': [
    'A solitude oferece a clareza que o excesso de estímulos escondeu.',
    'O afastamento pode estar protegendo você de uma conversa importante.',
    'Afaste-se o bastante para se ouvir e depois retorne com a verdade.',
  ],
  'Wheel of Fortune': [
    'Um ciclo está girando; a flexibilidade permite reconhecer a abertura.',
    'Tentar congelar o que está mudando cria atrito desnecessário.',
    'Trabalhe com o movimento em vez de exigir o ontem de volta.',
  ],
  'Justice': [
    'Verdade, responsabilidade e proporção restauram o equilíbrio.',
    'Uma história conveniente pode estar escondendo sua parte da responsabilidade.',
    'Tome a decisão que você respeitaria mesmo que ninguém aplaudisse.',
  ],
  'The Hanged Man': [
    'Uma pausa deliberada revela uma perspectiva que o esforço sozinho não alcança.',
    'Esperar pode ter virado fuga, sacrifício ou apego à estagnação.',
    'Solte a necessidade de forçar o movimento e olhe pelo ângulo oposto.',
  ],
  'Death': [
    'Um fim está abrindo espaço para uma forma de vida mais sincera.',
    'Apegar-se a um capítulo concluído está atrasando a renovação.',
    'Solte a identidade que já não consegue levar você adiante.',
  ],
  'Temperance': [
    'A integração paciente cria um resultado que os extremos não conseguem.',
    'A impaciência está puxando você entre reações de tudo ou nada.',
    'Faça o próximo ajuste pequeno o bastante para sustentá-lo.',
  ],
  'The Devil': [
    'Ver o apego com clareza é o começo da liberdade.',
    'Um desejo, medo ou acordo conhecido pode estar escolhendo por você.',
    'Dê nome ao custo do padrão e recupere uma escolha hoje.',
  ],
  'The Tower': [
    'Uma estrutura falsa está se quebrando para que a verdade fique visível.',
    'A resistência pode intensificar uma mudança que já começou.',
    'Proteja o que é real e deixe cair o que era apenas aparência.',
  ],
  'The Star': [
    'A esperança retorna por autenticidade, renovação e uma perspectiva mais ampla.',
    'A decepção pode estar fazendo a possibilidade parecer insegura.',
    'Pratique um pequeno ato de fé que não exija nada do resultado.',
  ],
  'The Moon': [
    'Sonhos e emoções revelam o que a lógica ainda não consegue organizar.',
    'O medo está preenchendo informações ausentes com ilusões convincentes.',
    'Espere por mais luz antes de chamar a incerteza de fato.',
  ],
  'The Sun': [
    'Vitalidade, clareza e alegria sincera estão disponíveis sem complicação.',
    'A pressão para parecer positivo pode estar escondendo uma necessidade real.',
    'Deixe o sucesso ser simples e compartilhe calor sem transformá-lo em atuação.',
  ],
  'Judgement': [
    'Um chamado mais profundo pede que você responda com sinceridade e renovação.',
    'A antiga vergonha pode manter você leal a uma versão menor de si.',
    'Responda a quem você está se tornando, não a quem precisou ser.',
  ],
  'The World': [
    'A conclusão traz integração, confiança e um horizonte mais amplo.',
    'Um detalhe inacabado pode estar impedindo um encerramento completo.',
    'Honre o que está completo antes de iniciar o próximo ciclo.',
  ],
};

const _minorRankSpanish = <String, List<String>>{
  'Ace': ['Aparece una semilla de potencial puro y un comienzo todavía sin forma.', 'El impulso de empezar está bloqueado por la duda, la prisa o un objetivo equivocado.', 'Convierte el potencial en un comienzo pequeño y concreto.'],
  'Two': ['Hace falta equilibrar dos energías y elegir una dirección consciente.', 'Posponer la decisión o sostener dos opciones opuestas está dividiendo tu energía.', 'Observa el coste de cada opción y elige la que esté alineada con tus valores.'],
  'Three': ['La expresión, la colaboración y los primeros resultados muestran que el crecimiento ha comenzado.', 'Las contribuciones dispersas, la comunicación débil o la necesidad de aprobación pueden frenar el avance.', 'Haz visible el progreso y compártelo con las personas adecuadas.'],
  'Four': ['Destacan la estabilidad, el descanso y la necesidad de una base firme.', 'El deseo de proteger puede haberse convertido en rigidez, cierre o resistencia al cambio.', 'Protege lo valioso dejando un pequeño espacio para el movimiento.'],
  'Five': ['La fricción y la sensación de carencia revelan lo que de verdad importa.', 'Quedarte atrapado en el conflicto, la comparación o la pérdida impide ver los recursos disponibles.', 'Elige una lección que puedas aprender sin convertir la lucha en tu identidad.'],
  'Six': ['Se hace visible un regreso al equilibrio, la reciprocidad y el reconocimiento.', 'Un desequilibrio entre dar y recibir o la dependencia de aprobación puede distorsionar la relación.', 'Acepta ayuda y comprueba si el intercambio es justo.'],
  'Seven': ['Estás ante una prueba de paciencia, evaluación y convicción.', 'La duda, la defensa o forzar los resultados pueden impedirte reconocer el valor de tu esfuerzo.', 'Evalúa qué está respondiendo de verdad antes de continuar.'],
  'Eight': ['El enfoque, la repetición y el desarrollo de habilidad pueden generar un avance rápido.', 'La prisa, el perfeccionismo o actuar en automático pueden vaciar de sentido lo que haces.', 'Fortalece una habilidad mediante una repetición consciente.'],
  'Nine': ['La resistencia, la confianza y los límites personales se fortalecen cerca de la culminación.', 'El cansancio, la duda o cargar con todo a solas hacen más pesado el último tramo.', 'Protege tus límites y reserva energía para terminar.'],
  'Ten': ['Todo el peso, el resultado y la recompensa de un ciclo están ahora visibles.', 'El éxito puede haber traído sobrecarga, responsabilidad excesiva o algo que ya debe soltarse.', 'Reconoce lo completado y deja la carga que ya no necesitas llevar.'],
  'Page': ['Se acerca un mensaje curioso, una oportunidad de aprender o una mirada nueva.', 'La inexperiencia, la curiosidad dispersa o hablar sin actuar pueden limitar el crecimiento.', 'Conserva la mente de principiante y prueba lo aprendido con un pequeño experimento.'],
  'Knight': ['La dedicación se convierte rápidamente en acción y trae un fuerte impulso de avance.', 'La precipitación, una mirada unilateral o ignorar el entorno por el resultado pueden crear problemas.', 'Avanza, pero revisa tu velocidad junto con tu intención y su impacto.'],
  'Queen': ['Una autoridad interior madura, la intuición y la receptividad pueden sostener esta situación.', 'Dar hasta olvidarte de ti o usar el poder emocional para controlar puede romper el equilibrio.', 'Encierra primero en ti la cualidad que necesitas.'],
  'King': ['La experiencia, la responsabilidad y la capacidad de orientar están listas para liderar.', 'La rigidez, el control basado en el ego o creer que ya lo sabes todo pueden ocultar la verdadera maestría.', 'Usa tu poder para ofrecer una dirección fiable, no para imponer.'],
};

const _minorRankPortuguese = <String, List<String>>{
  'Ace': ['Surge uma semente de potencial puro e um começo ainda sem forma.', 'A vontade de começar está bloqueada por dúvida, pressa ou um objetivo errado.', 'Transforme o potencial em um começo pequeno e concreto.'],
  'Two': ['É preciso equilibrar duas energias e escolher uma direção consciente.', 'Adiar a decisão ou sustentar opções opostas está dividindo sua energia.', 'Veja o custo de cada opção e escolha a que combina com seus valores.'],
  'Three': ['Expressão, colaboração e primeiros resultados mostram que o crescimento começou.', 'Contribuições dispersas, comunicação fraca ou necessidade de aprovação podem desacelerar o avanço.', 'Torne o progresso visível e compartilhe com as pessoas certas.'],
  'Four': ['Estabilidade, descanso e a necessidade de uma base firme ganham destaque.', 'O desejo de proteger pode ter virado rigidez, fechamento ou resistência à mudança.', 'Proteja o que é valioso deixando um pequeno espaço para o movimento.'],
  'Five': ['Atrito e sensação de falta revelam o que realmente importa.', 'Ficar preso ao conflito, à comparação ou à perda impede você de ver os recursos disponíveis.', 'Escolha uma lição que possa aprender sem fazer da luta sua identidade.'],
  'Six': ['Um retorno ao equilíbrio, à reciprocidade e ao reconhecimento se torna visível.', 'Um desequilíbrio entre dar e receber ou dependência de aprovação pode distorcer a relação.', 'Aceite ajuda e verifique se a troca é justa.'],
  'Seven': ['Você está diante de um teste de paciência, avaliação e convicção.', 'Dúvida, defesa ou tentar forçar resultados podem impedir você de reconhecer o valor do esforço.', 'Avalie o que está realmente respondendo antes de continuar.'],
  'Eight': ['Foco, repetição e desenvolvimento de habilidade podem criar avanço rápido.', 'Pressa, perfeccionismo ou agir no automático podem tirar o sentido do que você faz.', 'Fortaleça uma habilidade por meio de repetição consciente.'],
  'Nine': ['Resistência, confiança e limites pessoais se fortalecem perto da conclusão.', 'Cansaço, dúvida ou carregar tudo sozinho tornam a etapa final mais pesada.', 'Proteja seus limites e guarde energia para terminar.'],
  'Ten': ['Todo o peso, o resultado e a recompensa de um ciclo estão agora visíveis.', 'O sucesso pode ter trazido sobrecarga, responsabilidade excessiva ou algo que precisa ser solto.', 'Reconheça o que foi concluído e deixe a carga que já não precisa levar.'],
  'Page': ['Uma mensagem curiosa, uma oportunidade de aprender ou uma nova perspectiva se aproxima.', 'Inexperiência, curiosidade dispersa ou falar sem agir podem limitar o crescimento.', 'Mantenha a mente de iniciante e teste o aprendizado com um pequeno experimento.'],
  'Knight': ['A dedicação rapidamente vira ação e traz um forte impulso para avançar.', 'Pressa, visão unilateral ou ignorar o entorno pelo resultado podem criar problemas.', 'Avance, mas revise sua velocidade junto com a intenção e o impacto.'],
  'Queen': ['Autoridade interior madura, intuição e receptividade podem sustentar esta situação.', 'Dar até se esquecer ou usar poder emocional para controlar pode romper o equilíbrio.', 'Incorpore primeiro em você a qualidade de que precisa.'],
  'King': ['Experiência, responsabilidade e capacidade de orientar estão prontas para liderar.', 'Rigidez, controle baseado no ego ou achar que já sabe tudo podem esconder a verdadeira maestria.', 'Use seu poder para oferecer uma direção confiável, não para impor.'],
};

const _minorSuitSpanish = <String, List<String>>{
  'Wands': ['Esta energía actúa en la motivación, la creatividad, el valor y la iniciativa.', 'Dirige tu fuego hacia algo significativo sin abandonar otras necesidades por entusiasmo.'],
  'Cups': ['Esta energía actúa en las emociones, las relaciones, la intimidad y la conexión intuitiva.', 'Reconoce con sinceridad lo que sientes sin tratar la emoción como la única verdad.'],
  'Swords': ['Esta energía actúa en los pensamientos, la comunicación, la verdad y las decisiones.', 'No elijas la frase más cortante, sino la que realmente aporte claridad.'],
  'Pentacles': ['Esta energía actúa en el dinero, el trabajo, el cuerpo, la seguridad y el valor duradero.', 'Construye hoy algo estable mediante un paso medible y sostenible.'],
};

const _minorSuitPortuguese = <String, List<String>>{
  'Wands': ['Esta energia atua na motivação, criatividade, coragem e iniciativa.', 'Direcione seu fogo para algo significativo sem abandonar outras necessidades pelo entusiasmo.'],
  'Cups': ['Esta energia atua nas emoções, relações, intimidade e conexão intuitiva.', 'Reconheça com sinceridade o que sente sem tratar a emoção como a única verdade.'],
  'Swords': ['Esta energia atua nos pensamentos, comunicação, verdade e decisões.', 'Não escolha a frase mais cortante, mas a que realmente traz clareza.'],
  'Pentacles': ['Esta energia atua em dinheiro, trabalho, corpo, segurança e valor duradouro.', 'Construa hoje algo estável com um passo mensurável e sustentável.'],
};

String? globalTarotCardName(String name, String languageCode) {
  final major = switch (languageCode) {
    'ES' => _majorNamesSpanish[name],
    'PT-BR' => _majorNamesPortuguese[name],
    _ => null,
  };
  if (major != null) return major;
  final parts = name.split(' of ');
  if (parts.length != 2) return null;
  final rank = switch (languageCode) {
    'ES' => _rankSpanish[parts.first],
    'PT-BR' => _rankPortuguese[parts.first],
    _ => null,
  };
  final suit = switch (languageCode) {
    'ES' => _suitSpanish[parts.last],
    'PT-BR' => _suitPortuguese[parts.last],
    _ => null,
  };
  if (rank == null || suit == null) return null;
  return '$rank de $suit';
}

String? globalTarotCardMeaning(DrawnCard drawn, String languageCode) {
  final major = switch (languageCode) {
    'ES' => _majorMeaningSpanish[drawn.card.name],
    'PT-BR' => _majorMeaningPortuguese[drawn.card.name],
    _ => null,
  };
  if (major != null) return major[drawn.reversed ? 1 : 0];
  final parts = drawn.card.name.split(' of ');
  if (parts.length != 2) return null;
  final rank = switch (languageCode) {
    'ES' => _minorRankSpanish[parts.first],
    'PT-BR' => _minorRankPortuguese[parts.first],
    _ => null,
  };
  final suit = switch (languageCode) {
    'ES' => _minorSuitSpanish[parts.last],
    'PT-BR' => _minorSuitPortuguese[parts.last],
    _ => null,
  };
  if (rank == null || suit == null) return null;
  return '${rank[drawn.reversed ? 1 : 0]} ${suit[0]}';
}

String? globalTarotCardAdvice(DrawnCard drawn, String languageCode) {
  final major = switch (languageCode) {
    'ES' => _majorMeaningSpanish[drawn.card.name],
    'PT-BR' => _majorMeaningPortuguese[drawn.card.name],
    _ => null,
  };
  if (major != null) return major[2];
  final parts = drawn.card.name.split(' of ');
  if (parts.length != 2) return null;
  final rank = switch (languageCode) {
    'ES' => _minorRankSpanish[parts.first],
    'PT-BR' => _minorRankPortuguese[parts.first],
    _ => null,
  };
  final suit = switch (languageCode) {
    'ES' => _minorSuitSpanish[parts.last],
    'PT-BR' => _minorSuitPortuguese[parts.last],
    _ => null,
  };
  if (rank == null || suit == null) return null;
  return '${rank[2]} ${suit[1]}';
}

String? globalReadingKindTitle(ReadingKind kind, String languageCode) {
  if (languageCode == 'ES') {
    return switch (kind) {
      ReadingKind.daily => 'Guía Diaria',
      ReadingKind.love => 'Amor y Conexión',
      ReadingKind.career => 'Camino Profesional',
      ReadingKind.money => 'Energía del Dinero',
      ReadingKind.decision => 'Decisión',
      ReadingKind.spiritual => 'Crecimiento Espiritual',
      ReadingKind.shadow => 'Trabajo de Sombra',
      ReadingKind.compatibility => 'Compatibilidad Amorosa',
      ReadingKind.timeline => 'Línea de Tiempo Futura',
      ReadingKind.celticCross => 'Cruz Celta',
    };
  }
  if (languageCode == 'PT-BR') {
    return switch (kind) {
      ReadingKind.daily => 'Orientação Diária',
      ReadingKind.love => 'Amor e Conexão',
      ReadingKind.career => 'Caminho Profissional',
      ReadingKind.money => 'Energia do Dinheiro',
      ReadingKind.decision => 'Decisão',
      ReadingKind.spiritual => 'Crescimento Espiritual',
      ReadingKind.shadow => 'Trabalho de Sombra',
      ReadingKind.compatibility => 'Compatibilidade Amorosa',
      ReadingKind.timeline => 'Linha do Tempo Futura',
      ReadingKind.celticCross => 'Cruz Celta',
    };
  }
  return null;
}

String? globalReadingKindSubtitle(ReadingKind kind, String languageCode) {
  if (languageCode == 'ES') {
    return switch (kind) {
      ReadingKind.daily => 'Un mensaje claro para hoy',
      ReadingKind.love => 'Observa la energía alrededor de tu corazón',
      ReadingKind.career => 'Aclara tu siguiente paso profesional',
      ReadingKind.money => 'Comprende tu dirección económica',
      ReadingKind.decision => 'Descubre lo que puede contener cada camino',
      ReadingKind.spiritual => 'Escucha lo que necesita tu interior',
      ReadingKind.shadow => 'Encuéntrate con lo que pide sanar',
      ReadingKind.compatibility => 'Lee la dinámica entre dos corazones',
      ReadingKind.timeline => 'Pasado, presente y tres capítulos posibles',
      ReadingKind.celticCross => 'Una lectura profunda y completa de diez cartas',
    };
  }
  if (languageCode == 'PT-BR') {
    return switch (kind) {
      ReadingKind.daily => 'Uma mensagem clara para hoje',
      ReadingKind.love => 'Veja a energia ao redor do seu coração',
      ReadingKind.career => 'Esclareça seu próximo passo profissional',
      ReadingKind.money => 'Entenda sua direção financeira',
      ReadingKind.decision => 'Revele o que cada caminho pode conter',
      ReadingKind.spiritual => 'Ouça o que seu interior precisa',
      ReadingKind.shadow => 'Encontre o que está pedindo cura',
      ReadingKind.compatibility => 'Leia a dinâmica entre dois corações',
      ReadingKind.timeline => 'Passado, presente e três capítulos possíveis',
      ReadingKind.celticCross => 'Uma leitura profunda e completa de dez cartas',
    };
  }
  return null;
}

String? globalEmotionLabel(EmotionalState emotion, String languageCode) {
  if (languageCode == 'ES') {
    return switch (emotion) {
      EmotionalState.uncertain => 'Incierto',
      EmotionalState.hopeful => 'Esperanzado',
      EmotionalState.anxious => 'Ansioso',
      EmotionalState.grounded => 'Centrado',
      EmotionalState.curious => 'Curioso',
    };
  }
  if (languageCode == 'PT-BR') {
    return switch (emotion) {
      EmotionalState.uncertain => 'Incerto',
      EmotionalState.hopeful => 'Esperançoso',
      EmotionalState.anxious => 'Ansioso',
      EmotionalState.grounded => 'Centrado',
      EmotionalState.curious => 'Curioso',
    };
  }
  return null;
}

String? globalDeckStyleLabel(DeckStyle style, String languageCode) {
  if (languageCode == 'ES') {
    return switch (style) {
      DeckStyle.midnight => 'Velo de Medianoche',
      DeckStyle.solarGold => 'Oro Solar',
      DeckStyle.bloodMoon => 'Luna de Sangre',
    };
  }
  if (languageCode == 'PT-BR') {
    return switch (style) {
      DeckStyle.midnight => 'Véu da Meia-noite',
      DeckStyle.solarGold => 'Ouro Solar',
      DeckStyle.bloodMoon => 'Lua de Sangue',
    };
  }
  return null;
}
