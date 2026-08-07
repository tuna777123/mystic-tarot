class MysticTextCatalog {
  MysticTextCatalog._();

  static const Set<String> launchLanguageCodes = <String>{'ES', 'FR', 'PT-BR'};

  static bool hasTranslation(String languageCode, String english) {
    final exact = switch (languageCode) {
      'ES' => _spanish.containsKey(english),
      'FR' => _french.containsKey(english),
      'PT-BR' => _portugueseBrazil.containsKey(english),
      _ => false,
    };
    if (exact) return true;
    final templates = switch (languageCode) {
      'ES' => _spanishTemplates,
      'FR' => _frenchTemplates,
      'PT-BR' => _portugueseBrazilTemplates,
      _ => const <_MysticTemplate>[],
    };
    return templates.any((item) => item.source == english);
  }

  static int exactTranslationCount(String languageCode) =>
      switch (languageCode) {
        'ES' => _spanish.length,
        'FR' => _french.length,
        'PT-BR' => _portugueseBrazil.length,
        _ => 0,
      };

  static int templateTranslationCount(String languageCode) =>
      switch (languageCode) {
        'ES' => _spanishTemplates.length,
        'FR' => _frenchTemplates.length,
        'PT-BR' => _portugueseBrazilTemplates.length,
        _ => 0,
      };

  static String translate(String languageCode, String english) {
    final exact = switch (languageCode) {
      'ES' => _spanish[english],
      'FR' => _french[english],
      'PT-BR' => _portugueseBrazil[english],
      _ => null,
    };
    if (exact != null) return exact;
    final templates = switch (languageCode) {
      'ES' => _spanishTemplates,
      'FR' => _frenchTemplates,
      'PT-BR' => _portugueseBrazilTemplates,
      _ => const <_MysticTemplate>[],
    };
    for (final template in templates) {
      final translated = template.apply(english, languageCode);
      if (translated != null) return translated;
    }
    return english;
  }

  static String _translateCaptured(String languageCode, String value) {
    final direct = switch (languageCode) {
      'ES' => _spanish[value],
      'FR' => _french[value],
      'PT-BR' => _portugueseBrazil[value],
      _ => null,
    };
    return direct ?? value;
  }

  static const Map<String, String> _spanish = <String, String>{
    'LIVING JOURNAL': 'DIARIO VIVO',
    'Your story remembers.': 'Tu historia te recuerda.',
    'Timeline': 'Cronología',
    'Insights': 'Perspectivas',
    'Map': 'Mapa',
    'Search': 'Buscar',
    'reversed': 'invertida',
    'upright': 'derecha',
    'Total readings': 'Lecturas totales',
    'Last 30 days': 'Últimos 30 días',
    'Cards returning to you': 'Cartas que vuelven a ti',
    'Emotional weather': 'Clima emocional',
    'Unlock your full pattern map': 'Desbloquea tu mapa completo de patrones',
    'Explore Premium': 'Explorar Premium',
    'Anxious': 'Ansioso',
    'Hopeful': 'Esperanzado',
    'Grounded': 'Centrado',
    'Curious': 'Curioso',
    'Uncertain': 'Incierto',
    'Your journal is waiting.': 'Tu diario te espera.',
    'Your reading timeline': 'Tu cronología de lecturas',
    'Every saved reading, in context': 'Cada lectura guardada, en su contexto',
    'Recurring patterns': 'Patrones recurrentes',
    'Cards and emotions that return': 'Cartas y emociones que regresan',
    'Private memory map': 'Mapa privado de recuerdos',
    'Connections only you can see': 'Conexiones que solo tú puedes ver',
    'Create my first memory': 'Crear mi primer recuerdo',
    'Try again': 'Intentar de nuevo',
    'Journeys': 'Viajes',
    'Destiny path': 'Camino del destino',
    'Create journey': 'Crear viaje',
    'New journey': 'Nuevo viaje',
    'Entries': 'Entradas',
    'Days': 'Días',
    'Reflected': 'Reflexionado',
    'Create a journey': 'Crear un viaje',
    'Journey name': 'Nombre del viaje',
    'A name is required.': 'Se necesita un nombre.',
    'Intention': 'Intención',
    'Life area': 'Área de vida',
    'Begin journey': 'Comenzar viaje',
    'Resume': 'Continuar',
    'Pause': 'Pausar',
    'Complete': 'Completar',
    'Archive': 'Archivar',
    'Active days': 'Días activos',
    'Start a reading': 'Iniciar una lectura',
    'Add reflection': 'Añadir reflexión',
    'Reflection': 'Reflexión',
    'Add a reflection': 'Añadir una reflexión',
    'Mood (optional)': 'Estado de ánimo (opcional)',
    'Save reflection': 'Guardar reflexión',
    'Name what matters': 'Nombra lo que importa',
    'Love, work, healing or your own path':
        'Amor, trabajo, sanación o tu propio camino',
    'Connect your readings': 'Conecta tus lecturas',
    'Watch one question evolve over time':
        'Observa cómo evoluciona una pregunta con el tiempo',
    'See your turning points': 'Descubre tus puntos de inflexión',
    'Mystic reveals the pattern behind your choices':
        'Mystic revela el patrón detrás de tus decisiones',
    'Create first journey': 'Crear el primer viaje',
    'Relationship': 'Relación',
    'Career': 'Carrera',
    'Wellbeing': 'Bienestar',
    'Education': 'Educación',
    'Creativity': 'Creatividad',
    'Confidence': 'Confianza',
    'Personal': 'Personal',
    'Active': 'Activo',
    'Paused': 'En pausa',
    'Completed': 'Completado',
    'Archived': 'Archivado',
    'LIVING FATE MAP': 'MAPA VIVO DEL DESTINO',
    'Your story changes with every return.':
        'Tu historia cambia cada vez que regresas.',
    'ENTER MY PATH': 'ENTRAR EN MI CAMINO',
    'My Living Path': 'Mi camino vivo',
    'Fate Map': 'Mapa del destino',
    '22 Days': '22 días',
    'YOUR LIVING SIGNALS': 'TUS SEÑALES VIVAS',
    'Your map is built from patterns—not predictions.':
        'Tu mapa se construye con patrones, no con predicciones.',
    'Two saved readings awaken your first connection.':
        'Dos lecturas guardadas despiertan tu primera conexión.',
    'What your path is saying': 'Lo que dice tu camino',
    'RECURRING SYMBOL': 'SÍMBOLO RECURRENTE',
    'No repeated card yet': 'Aún no hay ninguna carta repetida',
    'INNER WEATHER': 'CLIMA INTERIOR',
    'Waiting for your first reading': 'Esperando tu primera lectura',
    'ACTIVE LIFE AREA': 'ÁREA DE VIDA ACTIVA',
    'Begin with one honest reading. Mystic will connect the cards, emotions, and actions that return.':
        'Empieza con una lectura sincera. Mystic conectará las cartas, emociones y acciones que regresen.',
    'Create my first signal': 'Crear mi primera señal',
    'The Major Arcana Journey': 'El viaje de los Arcanos Mayores',
    'One chapter a day. No punishment for missing a day.':
        'Un capítulo al día. No hay castigo por perder un día.',
    'TODAY’S FOCUS': 'ENFOQUE DE HOY',
    'REAL-WORLD RITUAL': 'RITUAL EN LA VIDA REAL',
    'REFLECTION': 'REFLEXIÓN',
    'Write one honest sentence…': 'Escribe una frase sincera…',
    'Today’s chapter is sealed': 'El capítulo de hoy está sellado',
    'Return tomorrow. Integration matters more than speed.':
        'Vuelve mañana. Integrar importa más que avanzar rápido.',
    'Your sealed chapters': 'Tus capítulos sellados',
    'The first cycle is complete.': 'El primer ciclo está completo.',
    'Your 22 reflections now live inside your Fate Map. The next cycle will compare who you were with who you are becoming.':
        'Tus 22 reflexiones ahora viven dentro de tu Mapa del Destino. El próximo ciclo comparará quién eras con quien estás llegando a ser.',
    'CYCLE COMPLETE': 'CICLO COMPLETO',
    'Mystic Story Studio': 'Mystic Story Studio',
    'A cinematic story card, ready to share.':
        'Una tarjeta de historia cinematográfica, lista para compartir.',
    'Midnight': 'Medianoche',
    'Solar': 'Solar',
    'Blood Moon': 'Luna de Sangre',
    'Preparing…': 'Preparando…',
    'Share my story card': 'Compartir mi tarjeta de historia',
    'Exports a private image. Your question and journal notes are never included.':
        'Exporta una imagen privada. Tu pregunta y las notas de tu diario nunca se incluyen.',
    'Sharing was unavailable, so your reading was copied.':
        'No se pudo compartir, así que tu lectura se copió.',
    'A REFLECTION, NOT A FIXED PREDICTION':
        'UNA REFLEXIÓN, NO UNA PREDICCIÓN FIJA',
    'Clarity': 'Claridad',
    'Read': 'Leer',
    'Path': 'Camino',
    'Journal': 'Diario',
    'You': 'Tú',
    'Close discovery': 'Cerrar descubrimiento',
    '✦  NEW ARCANA AWAKENED': '✦  NUEVO ARCANO DESPERTADO',
    'Reveal next card': 'Revelar la siguiente carta',
    'Add to Arcana Vault': 'Añadir a la Bóveda de Arcanos',
    'Legendary': 'Legendaria',
    'Epic': 'Épica',
    'Rare': 'Rara',
    'Common': 'Común',
    'Your cards are waiting': 'Tus cartas te esperan',
    'Choose a reading': 'Elige una lectura',
    'Explore every reading': 'Explorar todas las lecturas',
    'Mystic Plus readings': 'Lecturas de Mystic Plus',
    'High-depth spreads built for the questions people return to most.':
        'Tiradas profundas creadas para las preguntas a las que más volvemos.',
    'Your path remembers': 'Tu camino recuerda',
    'Good morning': 'Buenos días',
    'Good afternoon': 'Buenas tardes',
    'Good evening': 'Buenas noches',
    'Reading library': 'Biblioteca de lecturas',
    'Choose the question that needs your attention now.':
        'Elige la pregunta que necesita tu atención ahora.',
    'Mystic remembers your pattern': 'Mystic recuerda tu patrón',
    'Save two readings and Mystic will begin connecting recurring cards, emotions, and choices into a private pattern map.':
        'Guarda dos lecturas y Mystic empezará a conectar cartas, emociones y decisiones recurrentes en un mapa privado de patrones.',
    'Love': 'Amor',
    'Purpose': 'Propósito',
    'Healing': 'Sanación',
    'Unlimited deep readings active': 'Lecturas profundas ilimitadas activas',
    'Free deep readings used': 'Lecturas profundas gratuitas agotadas',
    'Your verified Mystic Plus entitlement is active.':
        'Tu acceso verificado a Mystic Plus está activo.',
    'Unlock unlimited readings with Mystic Plus.':
        'Desbloquea lecturas ilimitadas con Mystic Plus.',
    'Your Daily Guidance remains free every day.':
        'Tu Guía Diaria seguirá siendo gratuita cada día.',
    'PLUS ACTIVE': 'PLUS ACTIVO',
    'VIEW PLUS': 'VER PLUS',
    'TONIGHT’S MYSTIC PULSE': 'PULSO MYSTIC DE ESTA NOCHE',
    'Release urgency. Choose the honest next step.':
        'Suelta la urgencia. Elige el siguiente paso más honesto.',
    '2 MIN': '2 MIN',
    'YOUR DAILY PORTAL': 'TU PORTAL DIARIO',
    'Reveal what\nneeds you today': 'Descubre qué\\nte necesita hoy',
    'DAILY SOUL QUEST': 'MISIÓN DIARIA DEL ALMA',
    'Today’s relic is yours.': 'La reliquia de hoy es tuya.',
    'Your chest is ready to open.': 'Tu cofre está listo para abrirse.',
    'Complete both steps • +40 XP': 'Completa ambos pasos • +40 XP',
    'Daily card': 'Carta diaria',
    'One ritual': 'Un ritual',
    'Close reward': 'Cerrar recompensa',
    'SOUL CHEST OPENED': 'COFRE DEL ALMA ABIERTO',
    'Moon Shard added to your constellation.':
        'Fragmento Lunar añadido a tu constelación.',
    'Continue my path': 'Continuar mi camino',
    'Breathe slowly. Hold your question in mind, then choose the cards that call to you.':
        'Respira despacio. Mantén tu pregunta en mente y elige las cartas que te llamen.',
    'Write your question (optional)': 'Escribe tu pregunta (opcional)',
    'HOW DO YOU FEEL RIGHT NOW?': '¿CÓMO TE SIENTES AHORA?',
    'CHOOSE YOUR CARDS': 'ELIGE TUS CARTAS',
    'Trust the first pull': 'Confía en la primera elección',
    'Seal my selection': 'Sellar mi selección',
    'Your reading': 'Tu lectura',
    'Share reading': 'Compartir lectura',
    'Take what resonates. Tarot is a mirror for reflection—not a fixed prediction.':
        'Quédate con lo que resuene. El tarot es un espejo para reflexionar, no una predicción fija.',
    '✦  YOUR GUIDANCE': '✦  TU GUÍA',
    'MYSTIC MIRROR • 24H LOOP': 'ESPEJO MYSTIC • CICLO DE 24 H',
    'Your aligned action': 'Tu acción alineada',
    'Tomorrow, Mystic will ask what actually changed. Your answer becomes part of your personal pattern map.':
        'Mañana Mystic te preguntará qué cambió de verdad. Tu respuesta pasará a formar parte de tu mapa personal de patrones.',
    'Saved to your journal': 'Guardado en tu diario',
    'Save this reading': 'Guardar esta lectura',
    'Return home': 'Volver al inicio',
    'MESSAGE': 'MENSAJE',
    'What surrounds you': 'Lo que te rodea',
    'What asks for attention': 'Lo que pide atención',
    'Your next aligned step': 'Tu siguiente paso alineado',
    ' — Reversed': ' — Invertida',
    'A hopeful path is becoming visible.':
        'Empieza a hacerse visible un camino esperanzador.',
    'The truth arrives when you slow down.':
        'La verdad llega cuando bajas el ritmo.',
    '◉  ORACLE MEMORY': '◉  MEMORIA DEL ORÁCULO',
    'ASK THE ORACLE': 'PREGUNTAR AL ORÁCULO',
    'UNLIMITED': 'ILIMITADO',
    'CONTINUE PLUS': 'CONTINUAR CON PLUS',
    '1 FREE': '1 GRATIS',
    'Ask unlimited personal follow-ups whenever you return to this reading.':
        'Haz preguntas personales ilimitadas cada vez que vuelvas a esta lectura.',
    'Your free answer is complete. Continue the dialogue with Mystic Plus.':
        'Tu respuesta gratuita está completa. Continúa el diálogo con Mystic Plus.',
    'Go beyond the first interpretation with one personal follow-up question.':
        'Ve más allá de la primera interpretación con una pregunta personal de seguimiento.',
    'Delay one fear-based decision. Write down what is known, what is assumed, and what can wait until tomorrow.':
        'Pospón una decisión basada en el miedo. Anota qué sabes, qué supones y qué puede esperar hasta mañana.',
    'Turn hope into evidence: take one small action that your future self can continue tomorrow.':
        'Convierte la esperanza en evidencia: da un pequeño paso que tu yo futuro pueda continuar mañana.',
    'Use today’s steadiness to complete one conversation or task you have been leaving open.':
        'Usa la estabilidad de hoy para completar una conversación o tarea que hayas dejado abierta.',
    'Ask one honest question without trying to control the answer.':
        'Haz una pregunta sincera sin intentar controlar la respuesta.',
    'Choose the smallest reversible step. Clarity often appears after movement, not before it.':
        'Elige el paso reversible más pequeño. La claridad suele aparecer después de moverte, no antes.',
    'REVEAL RITUAL': 'RITUAL DE REVELACIÓN',
    'INTENTION': 'INTENCIÓN',
    'SELECTION': 'SELECCIÓN',
    'REVEAL': 'REVELACIÓN',
    'Your cards are\nwaiting beneath the veil.':
        'Tus cartas te esperan\\nbajo el velo.',
    'Opening the veil…': 'Abriendo el velo…',
    'Open the seal': 'Abrir el sello',
    'Take what resonates. The cards offer reflection, not certainty.':
        'Quédate con lo que resuene. Las cartas ofrecen reflexión, no certeza.',
    'Oracle Dialogue': 'Diálogo con el Oráculo',
    'The Oracle is listening.': 'El Oráculo está escuchando.',
    'Reversed': 'Invertida',
    'CHOOSE A FOLLOW-UP': 'ELIGE UNA PREGUNTA DE SEGUIMIENTO',
    'Or ask in your own words…': 'O pregunta con tus propias palabras…',
    'Ask the Oracle': 'Preguntar al Oráculo',
    'Ask my free question': 'Hacer mi pregunta gratuita',
    'The Oracle is connecting your symbols…':
        'El Oráculo está conectando tus símbolos…',
    'Continue the conversation': 'Continuar la conversación',
    'Ask unlimited follow-ups, revisit saved conversations, and unlock every deep spread with Mystic Plus.':
        'Haz preguntas ilimitadas, vuelve a conversaciones guardadas y desbloquea todas las tiradas profundas con Mystic Plus.',
    'Unlock Oracle Dialogue': 'Desbloquear el Diálogo con el Oráculo',
    'Ask another question': 'Hacer otra pregunta',
    'Return to my reading': 'Volver a mi lectura',
    'Your card is finding its voice…': 'Tu carta está encontrando su voz…',
    'The cards are forming a pattern…': 'Las cartas están formando un patrón…',
    'Stay with your first feeling. The full interpretation appears after the final card turns.':
        'Quédate con tu primera sensación. La interpretación completa aparecerá después de que gire la última carta.',
    'Your Mystic Path': 'Tu Camino Mystic',
    'Your inner world becomes visible as you practice.':
        'Tu mundo interior se hace visible con la práctica.',
    'INNER CONSTELLATION': 'CONSTELACIÓN INTERIOR',
    'Today’s rituals': 'Rituales de hoy',
    'Small actions turn insight into change. Each ritual grants +15 XP.':
        'Las pequeñas acciones convierten la comprensión en cambio. Cada ritual otorga +15 XP.',
    '60-second reset': 'Reinicio de 60 segundos',
    'Breathe in for four, out for six.':
        'Inhala durante cuatro y exhala durante seis.',
    'Name the truth': 'Nombra la verdad',
    'Write one sentence you have been avoiding.':
        'Escribe una frase que hayas estado evitando.',
    'Aligned action': 'Acción alineada',
    'Take the smallest reversible next step.':
        'Da el siguiente paso reversible más pequeño.',
    'Mystic rewards': 'Recompensas Mystic',
    'Your practice unlocks cosmetic relics—never better answers.':
        'Tu práctica desbloquea reliquias cosméticas, nunca respuestas “mejores”.',
    'Moon Dust': 'Polvo Lunar',
    'Oracle Flame': 'Llama del Oráculo',
    'Astral Crown': 'Corona Astral',
    'Return tomorrow to keep your constellation alive.':
        'Vuelve mañana para mantener viva tu constelación.',
    'CLAIMED': 'RECLAMADO',
    'CLAIM': 'RECLAMAR',
    'Ritual complete • +15 XP': 'Ritual completado • +15 XP',
    'ARCANA VAULT': 'BÓVEDA DE ARCANOS',
    'Every reading can awaken a card.':
        'Cada lectura puede despertar una carta.',
    'The entire deck has answered you.': 'Toda la baraja te ha respondido.',
    'Undiscovered': 'Sin descubrir',
    'Your Arcana Vault': 'Tu Bóveda de Arcanos',
    'Locked': 'Bloqueada',
    'UNDISCOVERED': 'SIN DESCUBRIR',
    'LIGHT': 'LUZ',
    'SHADOW': 'SOMBRA',
    'ALIGNED ACTION': 'ACCIÓN ALINEADA',
    'YOUR WEEKLY MYSTIC WRAPPED': 'TU RESUMEN MYSTIC SEMANAL',
    'Your story is waiting for its first signal.':
        'Tu historia espera su primera señal.',
    '✦  MYSTIC WRAPPED': '✦  RESUMEN MYSTIC',
    'Your first pattern begins with one honest reading.':
        'Tu primer patrón comienza con una lectura sincera.',
    'REFLECTIONS': 'REFLEXIONES',
    'No card yet': 'Aún no hay ninguna carta',
    'REPEATING CARD': 'CARTA RECURRENTE',
    'Complete a reading and return here to watch your emotional patterns become visible.':
        'Completa una lectura y vuelve aquí para ver cómo se hacen visibles tus patrones emocionales.',
    'Begin my first reading': 'Comenzar mi primera lectura',
    'Keep building my pattern': 'Seguir construyendo mi patrón',
    'First Signal': 'Primera Señal',
    'Save 1 reading': 'Guardar 1 lectura',
    'Flame Keeper': 'Guardián de la Llama',
    'Reach a 3-day streak': 'Alcanza una racha de 3 días',
    'Arcana Seeker': 'Buscador de Arcanos',
    'Awaken 10 cards': 'Despierta 10 cartas',
    'Relic Keeper': 'Guardián de Reliquias',
    'Claim an XP relic': 'Reclama una reliquia de XP',
    'Reading preferences': 'Preferencias de lectura',
    'Privacy & data': 'Privacidad y datos',
    'Help and support': 'Ayuda y soporte',
    'Your space': 'Tu espacio',
    'LEVEL': 'NIVEL',
    'day streak': 'días de racha',
    'readings': 'lecturas',
    'arcana': 'arcanos',
    'Mystic achievements': 'Logros Mystic',
    'Your practice leaves permanent marks on your path.':
        'Tu práctica deja huellas permanentes en tu camino.',
    'Your tarot deck': 'Tu baraja de tarot',
    'Choose the visual energy that follows every reading.':
        'Elige la energía visual que acompañará cada lectura.',
    'Mystic Plus active': 'Mystic Plus activo',
    'Unlock Mystic Plus': 'Desbloquear Mystic Plus',
    'View plan and manage subscription':
        'Ver el plan y gestionar la suscripción',
    'Go deeper with unlimited readings': 'Profundiza con lecturas ilimitadas',
    'Soul profile': 'Perfil del alma',
    'Language': 'Idioma',
    'Choose language': 'Elegir idioma',
    'Mystic is fully available in English, Turkish, Spanish, French, and Brazilian Portuguese.':
        'Mystic está disponible por completo en inglés, turco, español, francés y portugués de Brasil.',
    'Astral Sage': 'Sabio Astral',
    'Mystic Oracle': 'Oráculo Mystic',
    'Mystic Initiate': 'Iniciado Mystic',
    'Love path': 'Camino del amor',
    'Purpose path': 'Camino del propósito',
    'Healing path': 'Camino de sanación',
    'Clarity path': 'Camino de claridad',
    'UNLOCKED': 'DESBLOQUEADO',
    'ACTIVE DECK': 'BARAJA ACTIVA',
    'Solar Gold': 'Oro Solar',
    'Make Mystic yours': 'Haz que Mystic sea tuyo',
    'Your name and intention shape the language, memory, and guidance around every reading.':
        'Tu nombre y tu intención dan forma al lenguaje, la memoria y la guía de cada lectura.',
    'Your name': 'Tu nombre',
    'YOUR CURRENT PATH': 'TU CAMINO ACTUAL',
    'Save my soul profile': 'Guardar mi perfil del alma',
    'Stored privately on this device.':
        'Guardado de forma privada en este dispositivo.',
    'PLUS PREVIEW': 'VISTA PREVIA DE PLUS',
    'The first signal is forming…': 'La primera señal se está formando…',
    'YOUR FIRST SIGNAL': 'TU PRIMERA SEÑAL',
    'Reversed energy': 'Energía invertida',
    'Upright energy': 'Energía al derecho',
    'The rest of your spread': 'El resto de tu tirada',
    'Included with Mystic Plus • Cancel anytime':
        'Incluido con Mystic Plus • Cancela cuando quieras',
    'Shape every reading': 'Da forma a cada lectura',
    'Allow reversed cards': 'Permitir cartas invertidas',
    'Ritual sound effects': 'Efectos de sonido del ritual',
    'Reflection-first guidance': 'Guía centrada en la reflexión',
    'Your inner world stays yours': 'Tu mundo interior sigue siendo tuyo',
    'Export my journal': 'Exportar mi diario',
    'Delete all Mystic data': 'Eliminar todos los datos de Mystic',
    'Entertainment & reflection': 'Entretenimiento y reflexión',
    'We are here to help': 'Estamos aquí para ayudarte',
    'Does Mystic predict the future?': '¿Mystic predice el futuro?',
    'Can I cancel Mystic Plus?': '¿Puedo cancelar Mystic Plus?',
    'How do I restore a purchase?': '¿Cómo restauro una compra?',
    'Is my journal private?': '¿Mi diario es privado?',
    'Copy support link': 'Copiar enlace de soporte',
    'Support link copied.': 'Enlace de soporte copiado.',
    ' (Reversed)': ' (Invertida)',
    'Delete all Mystic data?': '¿Eliminar todos los datos de Mystic?',
    'Keep my data': 'Conservar mis datos',
    'Delete everything': 'Eliminar todo',
    'Your memory map is waiting.': 'Tu mapa de recuerdos te espera.',
    'Your patterns, connected.': 'Tus patrones, conectados.',
    'Memory Map': 'Mapa de Recuerdos',
    'Strongest connection': 'Conexión más fuerte',
    'Search by meaning': 'Buscar por significado',
    'No connected memory found yet.':
        'Aún no se ha encontrado ningún recuerdo conectado.',
    'Daily': 'Diaria',
    'Money': 'Dinero',
    'Decision': 'Decisión',
    'Spirit': 'Espíritu',
    'Shadow': 'Sombra',
    'Future': 'Futuro',
    'Begin before certainty arrives': 'Empieza antes de que llegue la certeza',
    'Take one small step you can reverse.':
        'Da un pequeño paso que puedas deshacer.',
    'What would I try if I did not need to look ready?':
        '¿Qué intentaría si no necesitara parecer preparado?',
    'Direct your available power': 'Dirige el poder que ya tienes',
    'Choose one tool and use it for fifteen focused minutes.':
        'Elige una herramienta y úsala durante quince minutos de concentración.',
    'Where am I waiting for a resource I already have?':
        '¿Dónde estoy esperando un recurso que ya tengo?',
    'Listen beneath the noise': 'Escucha debajo del ruido',
    'Sit without input for three quiet minutes.':
        'Permanece tres minutos en silencio, sin estímulos.',
    'What does my body know before my mind explains it?':
        '¿Qué sabe mi cuerpo antes de que mi mente lo explique?',
    'Nourish what should grow': 'Nutre lo que debe crecer',
    'Improve one condition around your creative work.':
        'Mejora una condición alrededor de tu trabajo creativo.',
    'What becomes possible when I stop starving my own needs?':
        '¿Qué se vuelve posible cuando dejo de privarme de mis propias necesidades?',
    'Build a kind structure': 'Construye una estructura amable',
    'Create one boundary that makes tomorrow easier.':
        'Crea un límite que haga mañana más fácil.',
    'Which rule protects me, and which one only controls me?':
        '¿Qué regla me protege y cuál solo me controla?',
    'Choose your living tradition': 'Elige tu tradición viva',
    'Keep one useful teaching and question one inherited rule.':
        'Conserva una enseñanza útil y cuestiona una regla heredada.',
    'What deserves my respect rather than blind obedience?':
        '¿Qué merece mi respeto en lugar de una obediencia ciega?',
    'Align desire with values': 'Alinea el deseo con tus valores',
    'Name the value beneath one important choice.':
        'Nombra el valor que hay debajo de una decisión importante.',
    'What choice lets me stay connected without leaving myself?':
        '¿Qué elección me permite seguir conectado sin abandonarme?',
    'Move with a named direction': 'Avanza con una dirección definida',
    'Write your destination before increasing your speed.':
        'Escribe tu destino antes de aumentar la velocidad.',
    'Am I moving toward something or merely escaping?':
        '¿Me estoy acercando a algo o solo estoy escapando?',
    'Practice gentle courage': 'Practica un valor sereno',
    'Meet one difficult feeling without trying to defeat it.':
        'Encuéntrate con una emoción difícil sin intentar vencerla.',
    'What changes when strength no longer means force?':
        '¿Qué cambia cuando la fuerza deja de significar imposición?',
    'Return with your own light': 'Regresa con tu propia luz',
    'Step away from input, then write one honest sentence.':
        'Aléjate de los estímulos y después escribe una frase sincera.',
    'Which answer can only be heard in solitude?':
        '¿Qué respuesta solo puede escucharse en soledad?',
    'Work with the turning cycle': 'Trabaja con el ciclo que gira',
    'Release one expectation that belongs to yesterday.':
        'Suelta una expectativa que pertenece a ayer.',
    'What opening appears when I stop demanding the old shape?':
        '¿Qué oportunidad aparece cuando dejo de exigir la forma antigua?',
    'Restore honest proportion': 'Recupera una proporción honesta',
    'Name your part without taking all the blame.':
        'Reconoce tu parte sin cargar con toda la culpa.',
    'What decision would I respect if nobody applauded?':
        '¿Qué decisión respetaría aunque nadie aplaudiera?',
    'See from the opposite angle': 'Mira desde el ángulo opuesto',
    'Argue sincerely for the view you resist.':
        'Defiende con sinceridad el punto de vista al que te resistes.',
    'What becomes visible when progress pauses?':
        '¿Qué se hace visible cuando el progreso se detiene?',
    'Release the completed form': 'Suelta la forma que ya terminó',
    'Remove one object, task, or promise that is already over.':
        'Retira un objeto, una tarea o una promesa que ya haya terminado.',
    'Which identity can no longer carry me forward?':
        '¿Qué identidad ya no puede llevarme hacia adelante?',
    'Integrate instead of swinging': 'Integra en lugar de oscilar',
    'Make the next adjustment small enough to sustain.':
        'Haz que el próximo ajuste sea lo bastante pequeño como para sostenerlo.',
    'Where would five percent be wiser than all or nothing?':
        '¿Dónde sería más sabio un cinco por ciento que todo o nada?',
    'Name the hidden bargain': 'Nombra el trato oculto',
    'Write the real cost of one familiar attachment.':
        'Escribe el coste real de un apego conocido.',
    'What keeps choosing for me when I stop paying attention?':
        '¿Qué sigue eligiendo por mí cuando dejo de prestar atención?',
    'Protect truth through change': 'Protege la verdad durante el cambio',
    'Separate what is falling from what is genuinely valuable.':
        'Separa lo que se está cayendo de lo que realmente tiene valor.',
    'What false structure am I exhausted from maintaining?':
        '¿Qué estructura falsa estoy agotado de mantener?',
    'Practice evidence of hope': 'Practica pruebas de esperanza',
    'Do one hopeful act that asks nothing from the outcome.':
        'Haz un acto esperanzador que no le exija nada al resultado.',
    'What small act would make possibility feel safe again?':
        '¿Qué pequeño acto haría que la posibilidad volviera a sentirse segura?',
    'Wait for more light': 'Espera más luz',
    'Divide one fear into facts, assumptions, and unknowns.':
        'Divide un miedo entre hechos, suposiciones y desconocidos.',
    'Where has uncertainty been disguised as certainty?':
        '¿Dónde se ha disfrazado la incertidumbre de certeza?',
    'Let joy be uncomplicated': 'Deja que la alegría sea sencilla',
    'Share one warm moment without performing it.':
        'Comparte un momento cálido sin convertirlo en una actuación.',
    'What goodness am I making harder than it needs to be?':
        '¿Qué cosa buena estoy haciendo más difícil de lo necesario?',
    'Answer the deeper call': 'Responde a la llamada más profunda',
    'Write what the next version of you refuses to postpone.':
        'Escribe lo que tu próxima versión se niega a seguir posponiendo.',
    'Who am I becoming when old shame is not in charge?':
        '¿En quién me estoy convirtiendo cuando la vieja vergüenza ya no manda?',
    'Honor completion': 'Honra lo que se completa',
    'Close one open loop and name what it taught you.':
        'Cierra un ciclo abierto y nombra lo que te enseñó.',
    'What must be celebrated before the next chapter begins?':
        '¿Qué debe celebrarse antes de que empiece el siguiente capítulo?',
    'Mystic should adapt to your practice—not ask you to adapt to it.':
        'Mystic debe adaptarse a tu práctica, no pedirte que te adaptes a él.',
    'Adds shadow meanings to approximately one in four cards.':
        'Añade significados de sombra aproximadamente a una de cada cuatro cartas.',
    'Soft audio cues for selection, sealing, and reveal.':
        'Señales de audio suaves para la selección, el sellado y la revelación.',
    'Readings remain grounded invitations—not certainty, diagnosis, or professional advice.':
        'Las lecturas siguen siendo invitaciones realistas a reflexionar, no certezas, diagnósticos ni asesoramiento profesional.',
    'This release keeps your journal and progress locally on this device. No questions are sold to advertisers.':
        'Esta versión guarda tu diario y tu progreso localmente en este dispositivo. Tus preguntas no se venden a anunciantes.',
    'Permanently removes local journal, XP, streak, and settings.':
        'Elimina permanentemente el diario local, los XP, la racha y los ajustes.',
    'Mystic Tarot is designed for personal reflection and entertainment. It does not provide medical, legal, financial, or mental-health advice.':
        'Mystic Tarot está diseñado para la reflexión personal y el entretenimiento. No ofrece asesoramiento médico, legal, financiero ni de salud mental.',
    'Clear answers before you begin your next ritual.':
        'Respuestas claras antes de comenzar tu próximo ritual.',
    'No. It uses tarot symbolism as a structured mirror for reflection and possible perspectives.':
        'No. Utiliza el simbolismo del tarot como un espejo estructurado para la reflexión y las posibles perspectivas.',
    'When native subscriptions launch, they can be managed and cancelled through Apple or Google account settings. The web release does not process payments.':
        'Cuando se lancen las suscripciones nativas, podrán gestionarse y cancelarse desde los ajustes de la cuenta de Apple o Google. La versión web no procesa pagos.',
    'Restore becomes available with native Apple and Google subscriptions. The current web release does not process or store purchases.':
        'La restauración estará disponible con las suscripciones nativas de Apple y Google. La versión web actual no procesa ni almacena compras.',
    'Yes. The current release stores it locally on this device and does not transmit journal content to us. You can export or delete it at any time.':
        'Sí. La versión actual lo guarda localmente en este dispositivo y no nos transmite el contenido del diario. Puedes exportarlo o eliminarlo en cualquier momento.',
    'Mystic Tarot Journal\n\nNo saved readings yet.':
        'Diario de Mystic Tarot\n\nAún no hay lecturas guardadas.',
    'Your journal was copied for export.':
        'Tu diario se copió para exportarlo.',
    'This cannot be undone. Your journal, card collection, streak, XP, and preferences will be removed from this device.':
        'Esta acción no se puede deshacer. Tu diario, colección de cartas, racha, XP y preferencias se eliminarán de este dispositivo.',
  };

  static const Map<String, String> _french = <String, String>{
    'LIVING JOURNAL': 'JOURNAL VIVANT',
    'Your story remembers.': 'Votre histoire se souvient.',
    'Timeline': 'Chronologie',
    'Insights': 'Éclairages',
    'Map': 'Carte',
    'Search': 'Rechercher',
    'reversed': 'renversée',
    'upright': 'à l’endroit',
    'Total readings': 'Tirages au total',
    'Last 30 days': '30 derniers jours',
    'Cards returning to you': 'Cartes qui reviennent vers vous',
    'Emotional weather': 'Climat émotionnel',
    'Unlock your full pattern map':
        'Débloquer votre carte complète des schémas',
    'Explore Premium': 'Découvrir Premium',
    'Anxious': 'Anxieux',
    'Hopeful': 'Plein d’espoir',
    'Grounded': 'Ancré',
    'Curious': 'Curieux',
    'Uncertain': 'Incertain',
    'Your journal is waiting.': 'Votre journal vous attend.',
    'Your reading timeline': 'La chronologie de vos tirages',
    'Every saved reading, in context':
        'Chaque tirage enregistré, remis dans son contexte',
    'Recurring patterns': 'Schémas récurrents',
    'Cards and emotions that return': 'Cartes et émotions qui reviennent',
    'Private memory map': 'Carte privée de vos souvenirs',
    'Connections only you can see': 'Des liens que vous seul pouvez voir',
    'Create my first memory': 'Créer mon premier souvenir',
    'Try again': 'Réessayer',
    'Journeys': 'Parcours',
    'Destiny path': 'Chemin du destin',
    'Create journey': 'Créer un parcours',
    'New journey': 'Nouveau parcours',
    'Entries': 'Entrées',
    'Days': 'Jours',
    'Reflected': 'Réflexions',
    'Create a journey': 'Créer un parcours',
    'Journey name': 'Nom du parcours',
    'A name is required.': 'Un nom est requis.',
    'Intention': 'Intention',
    'Life area': 'Domaine de vie',
    'Begin journey': 'Commencer le parcours',
    'Resume': 'Reprendre',
    'Pause': 'Mettre en pause',
    'Complete': 'Terminer',
    'Archive': 'Archiver',
    'Active days': 'Jours actifs',
    'Start a reading': 'Commencer un tirage',
    'Add reflection': 'Ajouter une réflexion',
    'Reflection': 'Réflexion',
    'Add a reflection': 'Ajouter une réflexion',
    'Mood (optional)': 'Humeur (facultatif)',
    'Save reflection': 'Enregistrer la réflexion',
    'Name what matters': 'Nommez ce qui compte',
    'Love, work, healing or your own path':
        'Amour, travail, guérison ou votre propre chemin',
    'Connect your readings': 'Reliez vos tirages',
    'Watch one question evolve over time':
        'Suivez l’évolution d’une question au fil du temps',
    'See your turning points': 'Repérez vos tournants',
    'Mystic reveals the pattern behind your choices':
        'Mystic révèle le schéma derrière vos choix',
    'Create first journey': 'Créer mon premier parcours',
    'Relationship': 'Relation',
    'Career': 'Carrière',
    'Wellbeing': 'Bien-être',
    'Education': 'Études',
    'Creativity': 'Créativité',
    'Confidence': 'Confiance',
    'Personal': 'Personnel',
    'Active': 'Actif',
    'Paused': 'En pause',
    'Completed': 'Terminé',
    'Archived': 'Archivé',
    'LIVING FATE MAP': 'CARTE VIVANTE DU DESTIN',
    'Your story changes with every return.':
        'Votre histoire change à chaque retour.',
    'ENTER MY PATH': 'ENTRER DANS MON CHEMIN',
    'My Living Path': 'Mon chemin vivant',
    'Fate Map': 'Carte du destin',
    '22 Days': '22 jours',
    'YOUR LIVING SIGNALS': 'VOS SIGNES VIVANTS',
    'Your map is built from patterns—not predictions.':
        'Votre carte se construit à partir de schémas, pas de prédictions.',
    'Two saved readings awaken your first connection.':
        'Deux tirages enregistrés éveillent votre premier lien.',
    'What your path is saying': 'Ce que votre chemin vous dit',
    'RECURRING SYMBOL': 'SYMBOLE RÉCURRENT',
    'No repeated card yet': 'Aucune carte répétée pour le moment',
    'INNER WEATHER': 'CLIMAT INTÉRIEUR',
    'Waiting for your first reading': 'En attente de votre premier tirage',
    'ACTIVE LIFE AREA': 'DOMAINE DE VIE ACTIF',
    'Begin with one honest reading. Mystic will connect the cards, emotions, and actions that return.':
        'Commencez par un tirage sincère. Mystic reliera les cartes, les émotions et les actions qui reviennent.',
    'Create my first signal': 'Créer mon premier signe',
    'The Major Arcana Journey': 'Le parcours des Arcanes majeurs',
    'One chapter a day. No punishment for missing a day.':
        'Un chapitre par jour. Aucune pénalité si vous manquez une journée.',
    'TODAY’S FOCUS': 'FOCUS DU JOUR',
    'REAL-WORLD RITUAL': 'RITUEL DANS LA VIE RÉELLE',
    'REFLECTION': 'RÉFLEXION',
    'Write one honest sentence…': 'Écrivez une phrase sincère…',
    'Today’s chapter is sealed': 'Le chapitre du jour est scellé',
    'Return tomorrow. Integration matters more than speed.':
        'Revenez demain. L’intégration compte plus que la vitesse.',
    'Your sealed chapters': 'Vos chapitres scellés',
    'The first cycle is complete.': 'Le premier cycle est terminé.',
    'Your 22 reflections now live inside your Fate Map. The next cycle will compare who you were with who you are becoming.':
        'Vos 22 réflexions vivent désormais dans votre Carte du destin. Le prochain cycle comparera la personne que vous étiez à celle que vous devenez.',
    'CYCLE COMPLETE': 'CYCLE TERMINÉ',
    'Mystic Story Studio': 'Mystic Story Studio',
    'A cinematic story card, ready to share.':
        'Une carte narrative cinématographique, prête à être partagée.',
    'Midnight': 'Minuit',
    'Solar': 'Solaire',
    'Blood Moon': 'Lune de sang',
    'Preparing…': 'Préparation…',
    'Share my story card': 'Partager ma carte narrative',
    'Exports a private image. Your question and journal notes are never included.':
        'Exporte une image privée. Votre question et vos notes de journal ne sont jamais incluses.',
    'Sharing was unavailable, so your reading was copied.':
        'Le partage était indisponible, votre tirage a donc été copié.',
    'A REFLECTION, NOT A FIXED PREDICTION':
        'UNE RÉFLEXION, PAS UNE PRÉDICTION FIGÉE',
    'Clarity': 'Clarté',
    'Read': 'Tirages',
    'Path': 'Chemin',
    'Journal': 'Journal',
    'You': 'Vous',
    'Close discovery': 'Fermer la découverte',
    '✦  NEW ARCANA AWAKENED': '✦  NOUVEL ARCANE ÉVEILLÉ',
    'Reveal next card': 'Révéler la carte suivante',
    'Add to Arcana Vault': 'Ajouter à la Bibliothèque des Arcanes',
    'Legendary': 'Légendaire',
    'Epic': 'Épique',
    'Rare': 'Rare',
    'Common': 'Commune',
    'Your cards are waiting': 'Vos cartes vous attendent',
    'Choose a reading': 'Choisir un tirage',
    'Explore every reading': 'Explorer tous les tirages',
    'Mystic Plus readings': 'Tirages Mystic Plus',
    'High-depth spreads built for the questions people return to most.':
        'Des tirages approfondis conçus pour les questions auxquelles on revient le plus.',
    'Your path remembers': 'Votre chemin se souvient',
    'Good morning': 'Bonjour',
    'Good afternoon': 'Bon après-midi',
    'Good evening': 'Bonsoir',
    'Reading library': 'Bibliothèque des tirages',
    'Choose the question that needs your attention now.':
        'Choisissez la question qui demande votre attention maintenant.',
    'Mystic remembers your pattern': 'Mystic se souvient de votre schéma',
    'Save two readings and Mystic will begin connecting recurring cards, emotions, and choices into a private pattern map.':
        'Enregistrez deux tirages et Mystic commencera à relier les cartes, les émotions et les choix récurrents dans une carte privée de vos schémas.',
    'Love': 'Amour',
    'Purpose': 'Mission',
    'Healing': 'Guérison',
    'Unlimited deep readings active': 'Tirages approfondis illimités actifs',
    'Free deep readings used': 'Tirages approfondis gratuits utilisés',
    'Your verified Mystic Plus entitlement is active.':
        'Votre accès Mystic Plus vérifié est actif.',
    'Unlock unlimited readings with Mystic Plus.':
        'Débloquez les tirages illimités avec Mystic Plus.',
    'Your Daily Guidance remains free every day.':
        'Votre Guide du jour reste gratuit chaque jour.',
    'PLUS ACTIVE': 'PLUS ACTIF',
    'VIEW PLUS': 'VOIR PLUS',
    'TONIGHT’S MYSTIC PULSE': 'IMPULSION MYSTIQUE DE CE SOIR',
    'Release urgency. Choose the honest next step.':
        'Relâchez l’urgence. Choisissez la prochaine étape la plus sincère.',
    '2 MIN': '2 MIN',
    'YOUR DAILY PORTAL': 'VOTRE PORTAIL QUOTIDIEN',
    'Reveal what\\nneeds you today':
        'Révélez ce qui\\na besoin de vous aujourd’hui',
    'DAILY SOUL QUEST': 'QUÊTE QUOTIDIENNE DE L’ÂME',
    'Today’s relic is yours.': 'La relique du jour est à vous.',
    'Your chest is ready to open.': 'Votre coffre est prêt à s’ouvrir.',
    'Complete both steps • +40 XP': 'Terminez les deux étapes • +40 XP',
    'Daily card': 'Carte du jour',
    'One ritual': 'Un rituel',
    'Close reward': 'Fermer la récompense',
    'SOUL CHEST OPENED': 'COFFRE DE L’ÂME OUVERT',
    'Moon Shard added to your constellation.':
        'Éclat de Lune ajouté à votre constellation.',
    'Continue my path': 'Continuer mon chemin',
    'Breathe slowly. Hold your question in mind, then choose the cards that call to you.':
        'Respirez lentement. Gardez votre question à l’esprit, puis choisissez les cartes qui vous appellent.',
    'Write your question (optional)': 'Écrivez votre question (facultatif)',
    'HOW DO YOU FEEL RIGHT NOW?': 'COMMENT VOUS SENTEZ-VOUS MAINTENANT ?',
    'CHOOSE YOUR CARDS': 'CHOISISSEZ VOS CARTES',
    'Trust the first pull': 'Faites confiance au premier élan',
    'Seal my selection': 'Sceller ma sélection',
    'Your reading': 'Votre tirage',
    'Share reading': 'Partager le tirage',
    'Take what resonates. Tarot is a mirror for reflection—not a fixed prediction.':
        'Gardez ce qui résonne. Le tarot est un miroir de réflexion, pas une prédiction figée.',
    '✦  YOUR GUIDANCE': '✦  VOTRE ORIENTATION',
    'MYSTIC MIRROR • 24H LOOP': 'MIROIR MYSTIQUE • BOUCLE DE 24 H',
    'Your aligned action': 'Votre action alignée',
    'Tomorrow, Mystic will ask what actually changed. Your answer becomes part of your personal pattern map.':
        'Demain, Mystic vous demandera ce qui a réellement changé. Votre réponse intégrera votre carte personnelle des schémas.',
    'Saved to your journal': 'Enregistré dans votre journal',
    'Save this reading': 'Enregistrer ce tirage',
    'Return home': 'Retour à l’accueil',
    'MESSAGE': 'MESSAGE',
    'What surrounds you': 'Ce qui vous entoure',
    'What asks for attention': 'Ce qui demande votre attention',
    'Your next aligned step': 'Votre prochaine étape alignée',
    ' — Reversed': ' — Renversée',
    'A hopeful path is becoming visible.':
        'Un chemin porteur d’espoir commence à apparaître.',
    'The truth arrives when you slow down.':
        'La vérité arrive lorsque vous ralentissez.',
    '◉  ORACLE MEMORY': '◉  MÉMOIRE DE L’ORACLE',
    'ASK THE ORACLE': 'INTERROGER L’ORACLE',
    'UNLIMITED': 'ILLIMITÉ',
    'CONTINUE PLUS': 'CONTINUER AVEC PLUS',
    '1 FREE': '1 GRATUITE',
    'Ask unlimited personal follow-ups whenever you return to this reading.':
        'Posez autant de questions personnelles de suivi que vous le souhaitez lorsque vous revenez à ce tirage.',
    'Your free answer is complete. Continue the dialogue with Mystic Plus.':
        'Votre réponse gratuite est terminée. Poursuivez le dialogue avec Mystic Plus.',
    'Go beyond the first interpretation with one personal follow-up question.':
        'Allez au-delà de la première interprétation avec une question personnelle de suivi.',
    'Delay one fear-based decision. Write down what is known, what is assumed, and what can wait until tomorrow.':
        'Repoussez une décision motivée par la peur. Notez ce qui est certain, ce qui est supposé et ce qui peut attendre demain.',
    'Turn hope into evidence: take one small action that your future self can continue tomorrow.':
        'Transformez l’espoir en preuve : faites une petite action que votre futur vous pourra poursuivre demain.',
    'Use today’s steadiness to complete one conversation or task you have been leaving open.':
        'Profitez de la stabilité d’aujourd’hui pour terminer une conversation ou une tâche laissée en suspens.',
    'Ask one honest question without trying to control the answer.':
        'Posez une question sincère sans chercher à contrôler la réponse.',
    'Choose the smallest reversible step. Clarity often appears after movement, not before it.':
        'Choisissez la plus petite étape réversible. La clarté apparaît souvent après le mouvement, pas avant.',
    'REVEAL RITUAL': 'RITUEL DE RÉVÉLATION',
    'INTENTION': 'INTENTION',
    'SELECTION': 'SÉLECTION',
    'REVEAL': 'RÉVÉLATION',
    'Your cards are\\nwaiting beneath the veil.':
        'Vos cartes vous\\nattendent sous le voile.',
    'Opening the veil…': 'Ouverture du voile…',
    'Open the seal': 'Ouvrir le sceau',
    'Take what resonates. The cards offer reflection, not certainty.':
        'Gardez ce qui résonne. Les cartes offrent une réflexion, pas une certitude.',
    'Oracle Dialogue': 'Dialogue avec l’Oracle',
    'The Oracle is listening.': 'L’Oracle vous écoute.',
    'Reversed': 'Renversée',
    'CHOOSE A FOLLOW-UP': 'CHOISISSEZ UNE QUESTION DE SUIVI',
    'Or ask in your own words…':
        'Ou posez votre question avec vos propres mots…',
    'Ask the Oracle': 'Interroger l’Oracle',
    'Ask my free question': 'Poser ma question gratuite',
    'The Oracle is connecting your symbols…': 'L’Oracle relie vos symboles…',
    'Continue the conversation': 'Poursuivre la conversation',
    'Ask unlimited follow-ups, revisit saved conversations, and unlock every deep spread with Mystic Plus.':
        'Posez des questions de suivi illimitées, retrouvez les conversations enregistrées et débloquez tous les tirages approfondis avec Mystic Plus.',
    'Unlock Oracle Dialogue': 'Débloquer le Dialogue avec l’Oracle',
    'Ask another question': 'Poser une autre question',
    'Return to my reading': 'Revenir à mon tirage',
    'Your card is finding its voice…': 'Votre carte trouve sa voix…',
    'The cards are forming a pattern…': 'Les cartes forment un schéma…',
    'Stay with your first feeling. The full interpretation appears after the final card turns.':
        'Restez avec votre première impression. L’interprétation complète apparaît lorsque la dernière carte se retourne.',
    'Your Mystic Path': 'Votre Chemin mystique',
    'Your inner world becomes visible as you practice.':
        'Votre monde intérieur devient visible à mesure que vous pratiquez.',
    'INNER CONSTELLATION': 'CONSTELLATION INTÉRIEURE',
    'Today’s rituals': 'Rituels du jour',
    'Small actions turn insight into change. Each ritual grants +15 XP.':
        'De petites actions transforment la compréhension en changement. Chaque rituel rapporte +15 XP.',
    '60-second reset': 'Réinitialisation de 60 secondes',
    'Breathe in for four, out for six.':
        'Inspirez pendant quatre temps, expirez pendant six.',
    'Name the truth': 'Nommez la vérité',
    'Write one sentence you have been avoiding.':
        'Écrivez une phrase que vous évitez.',
    'Aligned action': 'Action alignée',
    'Take the smallest reversible next step.':
        'Faites la plus petite prochaine étape réversible.',
    'Mystic rewards': 'Récompenses Mystic',
    'Your practice unlocks cosmetic relics—never better answers.':
        'Votre pratique débloque des reliques esthétiques, jamais de meilleures réponses.',
    'Moon Dust': 'Poussière de Lune',
    'Oracle Flame': 'Flamme de l’Oracle',
    'Astral Crown': 'Couronne astrale',
    'Return tomorrow to keep your constellation alive.':
        'Revenez demain pour garder votre constellation vivante.',
    'CLAIMED': 'RÉCUPÉRÉ',
    'CLAIM': 'RÉCUPÉRER',
    'Ritual complete • +15 XP': 'Rituel terminé • +15 XP',
    'ARCANA VAULT': 'BIBLIOTHÈQUE DES ARCANES',
    'Every reading can awaken a card.':
        'Chaque tirage peut éveiller une carte.',
    'The entire deck has answered you.': 'Le jeu entier vous a répondu.',
    'Undiscovered': 'Non découverte',
    'Your Arcana Vault': 'Votre Bibliothèque des Arcanes',
    'Locked': 'Verrouillée',
    'UNDISCOVERED': 'NON DÉCOUVERTE',
    'LIGHT': 'LUMIÈRE',
    'SHADOW': 'OMBRE',
    'ALIGNED ACTION': 'ACTION ALIGNÉE',
    'YOUR WEEKLY MYSTIC WRAPPED': 'VOTRE BILAN MYSTIQUE HEBDOMADAIRE',
    'Your story is waiting for its first signal.':
        'Votre histoire attend son premier signe.',
    '✦  MYSTIC WRAPPED': '✦  BILAN MYSTIQUE',
    'Your first pattern begins with one honest reading.':
        'Votre premier schéma commence par un tirage sincère.',
    'REFLECTIONS': 'RÉFLEXIONS',
    'No card yet': 'Aucune carte pour le moment',
    'REPEATING CARD': 'CARTE RÉCURRENTE',
    'Complete a reading and return here to watch your emotional patterns become visible.':
        'Terminez un tirage puis revenez ici pour voir apparaître vos schémas émotionnels.',
    'Begin my first reading': 'Commencer mon premier tirage',
    'Keep building my pattern': 'Continuer à construire mon schéma',
    'First Signal': 'Premier signe',
    'Save 1 reading': 'Enregistrer 1 tirage',
    'Flame Keeper': 'Gardien de la flamme',
    'Reach a 3-day streak': 'Atteindre une série de 3 jours',
    'Arcana Seeker': 'Chercheur des Arcanes',
    'Awaken 10 cards': 'Éveiller 10 cartes',
    'Relic Keeper': 'Gardien des reliques',
    'Claim an XP relic': 'Récupérer une relique d’XP',
    'Reading preferences': 'Préférences de tirage',
    'Privacy & data': 'Confidentialité et données',
    'Help and support': 'Aide et assistance',
    'Your space': 'Votre espace',
    'LEVEL': 'NIVEAU',
    'day streak': 'jours consécutifs',
    'readings': 'tirages',
    'arcana': 'arcanes',
    'Mystic achievements': 'Accomplissements Mystic',
    'Your practice leaves permanent marks on your path.':
        'Votre pratique laisse des traces durables sur votre chemin.',
    'Your tarot deck': 'Votre jeu de tarot',
    'Choose the visual energy that follows every reading.':
        'Choisissez l’énergie visuelle qui accompagne chaque tirage.',
    'Mystic Plus active': 'Mystic Plus actif',
    'Unlock Mystic Plus': 'Débloquer Mystic Plus',
    'View plan and manage subscription': 'Voir l’offre et gérer l’abonnement',
    'Go deeper with unlimited readings':
        'Allez plus loin avec des tirages illimités',
    'Soul profile': 'Profil de l’âme',
    'Language': 'Langue',
    'Choose language': 'Choisir la langue',
    'Mystic is fully available in English, Turkish, Spanish, French, and Brazilian Portuguese.':
        'Mystic est entièrement disponible en anglais, turc, espagnol, français et portugais brésilien.',
    'Astral Sage': 'Sage astral',
    'Mystic Oracle': 'Oracle mystique',
    'Mystic Initiate': 'Initié mystique',
    'Love path': 'Chemin de l’amour',
    'Purpose path': 'Chemin de la mission',
    'Healing path': 'Chemin de la guérison',
    'Clarity path': 'Chemin de la clarté',
    'UNLOCKED': 'DÉBLOQUÉ',
    'ACTIVE DECK': 'JEU ACTIF',
    'Solar Gold': 'Or solaire',
    'Make Mystic yours': 'Faites de Mystic votre espace',
    'Your name and intention shape the language, memory, and guidance around every reading.':
        'Votre nom et votre intention façonnent le langage, la mémoire et l’orientation de chaque tirage.',
    'Your name': 'Votre nom',
    'YOUR CURRENT PATH': 'VOTRE CHEMIN ACTUEL',
    'Save my soul profile': 'Enregistrer mon profil de l’âme',
    'Stored privately on this device.':
        'Enregistré de façon privée sur cet appareil.',
    'PLUS PREVIEW': 'APERÇU PLUS',
    'The first signal is forming…': 'Le premier signe se dessine…',
    'YOUR FIRST SIGNAL': 'VOTRE PREMIER SIGNE',
    'Reversed energy': 'Énergie renversée',
    'Upright energy': 'Énergie à l’endroit',
    'The rest of your spread': 'La suite de votre tirage',
    'Included with Mystic Plus • Cancel anytime':
        'Inclus avec Mystic Plus • Résiliable à tout moment',
    'Shape every reading': 'Personnalisez chaque tirage',
    'Allow reversed cards': 'Autoriser les cartes renversées',
    'Ritual sound effects': 'Effets sonores des rituels',
    'Reflection-first guidance': 'Orientation centrée sur la réflexion',
    'Your inner world stays yours': 'Votre monde intérieur reste le vôtre',
    'Export my journal': 'Exporter mon journal',
    'Delete all Mystic data': 'Supprimer toutes les données Mystic',
    'Entertainment & reflection': 'Divertissement et réflexion',
    'We are here to help': 'Nous sommes là pour vous aider',
    'Does Mystic predict the future?': 'Mystic prédit-il l’avenir ?',
    'Can I cancel Mystic Plus?': 'Puis-je résilier Mystic Plus ?',
    'How do I restore a purchase?': 'Comment restaurer un achat ?',
    'Is my journal private?': 'Mon journal est-il privé ?',
    'Copy support link': 'Copier le lien d’assistance',
    'Support link copied.': 'Lien d’assistance copié.',
    ' (Reversed)': ' (Renversée)',
    'Delete all Mystic data?': 'Supprimer toutes les données Mystic ?',
    'Keep my data': 'Conserver mes données',
    'Delete everything': 'Tout supprimer',
    'Your memory map is waiting.': 'Votre carte des souvenirs vous attend.',
    'Your patterns, connected.': 'Vos schémas, reliés.',
    'Memory Map': 'Carte des souvenirs',
    'Strongest connection': 'Lien le plus fort',
    'Search by meaning': 'Rechercher par signification',
    'No connected memory found yet.': 'Aucun souvenir relié pour le moment.',
    'Daily': 'Quotidien',
    'Money': 'Argent',
    'Decision': 'Décision',
    'Spirit': 'Esprit',
    'Shadow': 'Ombre',
    'Future': 'Avenir',
    'Begin before certainty arrives':
        'Commencez avant que la certitude n’arrive',
    'Take one small step you can reverse.':
        'Faites un petit pas que vous pourrez annuler.',
    'What would I try if I did not need to look ready?':
        'Qu’essaierais-je si je n’avais pas besoin de paraître prêt ?',
    'Direct your available power': 'Dirigez le pouvoir dont vous disposez',
    'Choose one tool and use it for fifteen focused minutes.':
        'Choisissez un outil et utilisez-le pendant quinze minutes de concentration.',
    'Where am I waiting for a resource I already have?':
        'Où suis-je en train d’attendre une ressource que je possède déjà ?',
    'Listen beneath the noise': 'Écoutez sous le bruit',
    'Sit without input for three quiet minutes.':
        'Restez trois minutes au calme, sans stimulation.',
    'What does my body know before my mind explains it?':
        'Que sait mon corps avant que mon esprit ne l’explique ?',
    'Nourish what should grow': 'Nourrissez ce qui doit grandir',
    'Improve one condition around your creative work.':
        'Améliorez une condition autour de votre travail créatif.',
    'What becomes possible when I stop starving my own needs?':
        'Qu’est-ce qui devient possible lorsque je cesse de priver mes propres besoins ?',
    'Build a kind structure': 'Construisez une structure bienveillante',
    'Create one boundary that makes tomorrow easier.':
        'Créez une limite qui rendra demain plus simple.',
    'Which rule protects me, and which one only controls me?':
        'Quelle règle me protège, et laquelle ne fait que me contrôler ?',
    'Choose your living tradition': 'Choisissez votre tradition vivante',
    'Keep one useful teaching and question one inherited rule.':
        'Conservez un enseignement utile et remettez en question une règle héritée.',
    'What deserves my respect rather than blind obedience?':
        'Qu’est-ce qui mérite mon respect plutôt qu’une obéissance aveugle ?',
    'Align desire with values': 'Alignez le désir sur vos valeurs',
    'Name the value beneath one important choice.':
        'Nommez la valeur qui se trouve sous un choix important.',
    'What choice lets me stay connected without leaving myself?':
        'Quel choix me permet de rester lié sans m’abandonner ?',
    'Move with a named direction':
        'Avancez dans une direction clairement nommée',
    'Write your destination before increasing your speed.':
        'Écrivez votre destination avant d’augmenter votre vitesse.',
    'Am I moving toward something or merely escaping?':
        'Est-ce que j’avance vers quelque chose ou est-ce que je fuis simplement ?',
    'Practice gentle courage': 'Pratiquez un courage doux',
    'Meet one difficult feeling without trying to defeat it.':
        'Accueillez une émotion difficile sans chercher à la vaincre.',
    'What changes when strength no longer means force?':
        'Qu’est-ce qui change lorsque la force ne signifie plus contrainte ?',
    'Return with your own light': 'Revenez avec votre propre lumière',
    'Step away from input, then write one honest sentence.':
        'Éloignez-vous des stimulations, puis écrivez une phrase sincère.',
    'Which answer can only be heard in solitude?':
        'Quelle réponse ne peut être entendue que dans la solitude ?',
    'Work with the turning cycle': 'Travaillez avec le cycle en mouvement',
    'Release one expectation that belongs to yesterday.':
        'Libérez une attente qui appartient à hier.',
    'What opening appears when I stop demanding the old shape?':
        'Quelle ouverture apparaît lorsque je cesse d’exiger l’ancienne forme ?',
    'Restore honest proportion': 'Rétablissez une juste proportion',
    'Name your part without taking all the blame.':
        'Reconnaissez votre part sans porter toute la faute.',
    'What decision would I respect if nobody applauded?':
        'Quelle décision respecterais-je même si personne ne m’applaudissait ?',
    'See from the opposite angle': 'Regardez depuis l’angle opposé',
    'Argue sincerely for the view you resist.':
        'Défendez sincèrement le point de vue auquel vous résistez.',
    'What becomes visible when progress pauses?':
        'Qu’est-ce qui devient visible lorsque le progrès marque une pause ?',
    'Release the completed form': 'Libérez la forme qui a terminé son cycle',
    'Remove one object, task, or promise that is already over.':
        'Retirez un objet, une tâche ou une promesse qui est déjà terminé.',
    'Which identity can no longer carry me forward?':
        'Quelle identité ne peut plus me porter vers l’avant ?',
    'Integrate instead of swinging': 'Intégrez au lieu d’osciller',
    'Make the next adjustment small enough to sustain.':
        'Faites en sorte que le prochain ajustement soit assez petit pour durer.',
    'Where would five percent be wiser than all or nothing?':
        'Où cinq pour cent serait-il plus sage que tout ou rien ?',
    'Name the hidden bargain': 'Nommez le marché caché',
    'Write the real cost of one familiar attachment.':
        'Écrivez le coût réel d’un attachement familier.',
    'What keeps choosing for me when I stop paying attention?':
        'Qu’est-ce qui continue de choisir à ma place lorsque je cesse d’être attentif ?',
    'Protect truth through change':
        'Protégez la vérité à travers le changement',
    'Separate what is falling from what is genuinely valuable.':
        'Séparez ce qui s’effondre de ce qui a une valeur réelle.',
    'What false structure am I exhausted from maintaining?':
        'Quelle structure illusoire suis-je épuisé de maintenir ?',
    'Practice evidence of hope': 'Mettez l’espoir en pratique par des preuves',
    'Do one hopeful act that asks nothing from the outcome.':
        'Faites un geste d’espoir qui n’attend rien du résultat.',
    'What small act would make possibility feel safe again?':
        'Quel petit geste rendrait de nouveau la possibilité rassurante ?',
    'Wait for more light': 'Attendez davantage de lumière',
    'Divide one fear into facts, assumptions, and unknowns.':
        'Répartissez une peur entre faits, suppositions et inconnues.',
    'Where has uncertainty been disguised as certainty?':
        'Où l’incertitude s’est-elle déguisée en certitude ?',
    'Let joy be uncomplicated': 'Laissez la joie rester simple',
    'Share one warm moment without performing it.':
        'Partagez un moment chaleureux sans le mettre en scène.',
    'What goodness am I making harder than it needs to be?':
        'Quelle chose positive suis-je en train de rendre plus difficile que nécessaire ?',
    'Answer the deeper call': 'Répondez à l’appel le plus profond',
    'Write what the next version of you refuses to postpone.':
        'Écrivez ce que votre prochaine version refuse de reporter.',
    'Who am I becoming when old shame is not in charge?':
        'Qui suis-je en train de devenir lorsque l’ancienne honte ne dirige plus ?',
    'Honor completion': 'Honorez l’accomplissement',
    'Close one open loop and name what it taught you.':
        'Fermez une boucle restée ouverte et nommez ce qu’elle vous a appris.',
    'What must be celebrated before the next chapter begins?':
        'Que faut-il célébrer avant que le prochain chapitre ne commence ?',
    'Mystic should adapt to your practice—not ask you to adapt to it.':
        'Mystic doit s’adapter à votre pratique, pas vous demander de vous adapter à lui.',
    'Adds shadow meanings to approximately one in four cards.':
        'Ajoute les significations d’ombre à environ une carte sur quatre.',
    'Soft audio cues for selection, sealing, and reveal.':
        'De légers repères sonores accompagnent la sélection, le scellement et la révélation.',
    'Readings remain grounded invitations—not certainty, diagnosis, or professional advice.':
        'Les tirages restent des invitations ancrées à la réflexion, pas des certitudes, des diagnostics ou des conseils professionnels.',
    'This release keeps your journal and progress locally on this device. No questions are sold to advertisers.':
        'Cette version conserve votre journal et votre progression localement sur cet appareil. Vos questions ne sont pas vendues à des annonceurs.',
    'Permanently removes local journal, XP, streak, and settings.':
        'Supprime définitivement le journal local, les XP, la série et les réglages.',
    'Mystic Tarot is designed for personal reflection and entertainment. It does not provide medical, legal, financial, or mental-health advice.':
        'Mystic Tarot est conçu pour la réflexion personnelle et le divertissement. Il ne fournit aucun conseil médical, juridique, financier ou de santé mentale.',
    'Clear answers before you begin your next ritual.':
        'Des réponses claires avant de commencer votre prochain rituel.',
    'No. It uses tarot symbolism as a structured mirror for reflection and possible perspectives.':
        'Non. Il utilise les symboles du tarot comme un miroir structuré pour la réflexion et les perspectives possibles.',
    'When native subscriptions launch, they can be managed and cancelled through Apple or Google account settings. The web release does not process payments.':
        'Lorsque les abonnements natifs seront disponibles, ils pourront être gérés et résiliés dans les réglages du compte Apple ou Google. La version web ne traite aucun paiement.',
    'Restore becomes available with native Apple and Google subscriptions. The current web release does not process or store purchases.':
        'La restauration sera disponible avec les abonnements natifs Apple et Google. La version web actuelle ne traite ni ne conserve les achats.',
    'Yes. The current release stores it locally on this device and does not transmit journal content to us. You can export or delete it at any time.':
        'Oui. La version actuelle le conserve localement sur cet appareil et ne nous transmet pas le contenu du journal. Vous pouvez l’exporter ou le supprimer à tout moment.',
    'Mystic Tarot Journal\n\nNo saved readings yet.':
        'Journal Mystic Tarot\n\nAucun tirage enregistré pour le moment.',
    'Your journal was copied for export.':
        'Votre journal a été copié pour l’exportation.',
    'This cannot be undone. Your journal, card collection, streak, XP, and preferences will be removed from this device.':
        'Cette action est irréversible. Votre journal, votre collection de cartes, votre série, vos XP et vos préférences seront supprimés de cet appareil.',
  };

  static const Map<String, String> _portugueseBrazil = <String, String>{
    'LIVING JOURNAL': 'DIÁRIO VIVO',
    'Your story remembers.': 'Sua história se lembra de você.',
    'Timeline': 'Linha do tempo',
    'Insights': 'Percepções',
    'Map': 'Mapa',
    'Search': 'Buscar',
    'reversed': 'invertida',
    'upright': 'em pé',
    'Total readings': 'Total de leituras',
    'Last 30 days': 'Últimos 30 dias',
    'Cards returning to you': 'Cartas que voltam para você',
    'Emotional weather': 'Clima emocional',
    'Unlock your full pattern map': 'Desbloqueie seu mapa completo de padrões',
    'Explore Premium': 'Explorar Premium',
    'Anxious': 'Ansioso',
    'Hopeful': 'Esperançoso',
    'Grounded': 'Centrado',
    'Curious': 'Curioso',
    'Uncertain': 'Incerto',
    'Your journal is waiting.': 'Seu diário está esperando.',
    'Your reading timeline': 'Sua linha do tempo de leituras',
    'Every saved reading, in context': 'Cada leitura salva, em seu contexto',
    'Recurring patterns': 'Padrões recorrentes',
    'Cards and emotions that return': 'Cartas e emoções que retornam',
    'Private memory map': 'Mapa privado de memórias',
    'Connections only you can see': 'Conexões que só você pode ver',
    'Create my first memory': 'Criar minha primeira memória',
    'Try again': 'Tentar novamente',
    'Journeys': 'Jornadas',
    'Destiny path': 'Caminho do destino',
    'Create journey': 'Criar jornada',
    'New journey': 'Nova jornada',
    'Entries': 'Registros',
    'Days': 'Dias',
    'Reflected': 'Refletido',
    'Create a journey': 'Criar uma jornada',
    'Journey name': 'Nome da jornada',
    'A name is required.': 'É necessário informar um nome.',
    'Intention': 'Intenção',
    'Life area': 'Área da vida',
    'Begin journey': 'Iniciar jornada',
    'Resume': 'Continuar',
    'Pause': 'Pausar',
    'Complete': 'Concluir',
    'Archive': 'Arquivar',
    'Active days': 'Dias ativos',
    'Start a reading': 'Iniciar uma leitura',
    'Add reflection': 'Adicionar reflexão',
    'Reflection': 'Reflexão',
    'Add a reflection': 'Adicionar uma reflexão',
    'Mood (optional)': 'Humor (opcional)',
    'Save reflection': 'Salvar reflexão',
    'Name what matters': 'Dê nome ao que importa',
    'Love, work, healing or your own path':
        'Amor, trabalho, cura ou seu próprio caminho',
    'Connect your readings': 'Conecte suas leituras',
    'Watch one question evolve over time':
        'Observe uma pergunta evoluir com o tempo',
    'See your turning points': 'Veja seus pontos de virada',
    'Mystic reveals the pattern behind your choices':
        'Mystic revela o padrão por trás das suas escolhas',
    'Create first journey': 'Criar a primeira jornada',
    'Relationship': 'Relacionamento',
    'Career': 'Carreira',
    'Wellbeing': 'Bem-estar',
    'Education': 'Educação',
    'Creativity': 'Criatividade',
    'Confidence': 'Confiança',
    'Personal': 'Pessoal',
    'Active': 'Ativa',
    'Paused': 'Pausada',
    'Completed': 'Concluída',
    'Archived': 'Arquivada',
    'LIVING FATE MAP': 'MAPA VIVO DO DESTINO',
    'Your story changes with every return.':
        'Sua história muda a cada retorno.',
    'ENTER MY PATH': 'ENTRAR NO MEU CAMINHO',
    'My Living Path': 'Meu Caminho Vivo',
    'Fate Map': 'Mapa do Destino',
    '22 Days': '22 dias',
    'YOUR LIVING SIGNALS': 'SEUS SINAIS VIVOS',
    'Your map is built from patterns—not predictions.':
        'Seu mapa é construído com padrões, não previsões.',
    'Two saved readings awaken your first connection.':
        'Duas leituras salvas despertam sua primeira conexão.',
    'What your path is saying': 'O que seu caminho está dizendo',
    'RECURRING SYMBOL': 'SÍMBOLO RECORRENTE',
    'No repeated card yet': 'Ainda não há nenhuma carta repetida',
    'INNER WEATHER': 'CLIMA INTERIOR',
    'Waiting for your first reading': 'Aguardando sua primeira leitura',
    'ACTIVE LIFE AREA': 'ÁREA DA VIDA ATIVA',
    'Begin with one honest reading. Mystic will connect the cards, emotions, and actions that return.':
        'Comece com uma leitura sincera. Mystic conectará as cartas, emoções e ações que retornarem.',
    'Create my first signal': 'Criar meu primeiro sinal',
    'The Major Arcana Journey': 'A Jornada dos Arcanos Maiores',
    'One chapter a day. No punishment for missing a day.':
        'Um capítulo por dia. Sem punição por perder um dia.',
    'TODAY’S FOCUS': 'FOCO DE HOJE',
    'REAL-WORLD RITUAL': 'RITUAL NA VIDA REAL',
    'REFLECTION': 'REFLEXÃO',
    'Write one honest sentence…': 'Escreva uma frase sincera…',
    'Today’s chapter is sealed': 'O capítulo de hoje está selado',
    'Return tomorrow. Integration matters more than speed.':
        'Volte amanhã. Integrar importa mais do que avançar rápido.',
    'Your sealed chapters': 'Seus capítulos selados',
    'The first cycle is complete.': 'O primeiro ciclo está completo.',
    'Your 22 reflections now live inside your Fate Map. The next cycle will compare who you were with who you are becoming.':
        'Suas 22 reflexões agora vivem dentro do seu Mapa do Destino. O próximo ciclo comparará quem você era com quem está se tornando.',
    'CYCLE COMPLETE': 'CICLO COMPLETO',
    'Mystic Story Studio': 'Mystic Story Studio',
    'A cinematic story card, ready to share.':
        'Um cartão de história cinematográfico, pronto para compartilhar.',
    'Midnight': 'Meia-noite',
    'Solar': 'Solar',
    'Blood Moon': 'Lua de Sangue',
    'Preparing…': 'Preparando…',
    'Share my story card': 'Compartilhar meu cartão de história',
    'Exports a private image. Your question and journal notes are never included.':
        'Exporta uma imagem privada. Sua pergunta e as anotações do diário nunca são incluídas.',
    'Sharing was unavailable, so your reading was copied.':
        'Não foi possível compartilhar, então sua leitura foi copiada.',
    'A REFLECTION, NOT A FIXED PREDICTION':
        'UMA REFLEXÃO, NÃO UMA PREVISÃO FIXA',
    'Clarity': 'Clareza',
    'Read': 'Ler',
    'Path': 'Caminho',
    'Journal': 'Diário',
    'You': 'Você',
    'Close discovery': 'Fechar descoberta',
    '✦  NEW ARCANA AWAKENED': '✦  NOVO ARCANO DESPERTO',
    'Reveal next card': 'Revelar a próxima carta',
    'Add to Arcana Vault': 'Adicionar ao Cofre dos Arcanos',
    'Legendary': 'Lendária',
    'Epic': 'Épica',
    'Rare': 'Rara',
    'Common': 'Comum',
    'Your cards are waiting': 'Suas cartas estão esperando',
    'Choose a reading': 'Escolha uma leitura',
    'Explore every reading': 'Explorar todas as leituras',
    'Mystic Plus readings': 'Leituras do Mystic Plus',
    'High-depth spreads built for the questions people return to most.':
        'Tiragens profundas criadas para as perguntas às quais as pessoas mais retornam.',
    'Your path remembers': 'Seu caminho se lembra',
    'Good morning': 'Bom dia',
    'Good afternoon': 'Boa tarde',
    'Good evening': 'Boa noite',
    'Reading library': 'Biblioteca de leituras',
    'Choose the question that needs your attention now.':
        'Escolha a pergunta que precisa da sua atenção agora.',
    'Mystic remembers your pattern': 'Mystic se lembra do seu padrão',
    'Save two readings and Mystic will begin connecting recurring cards, emotions, and choices into a private pattern map.':
        'Salve duas leituras e Mystic começará a conectar cartas, emoções e escolhas recorrentes em um mapa privado de padrões.',
    'Love': 'Amor',
    'Purpose': 'Propósito',
    'Healing': 'Cura',
    'Unlimited deep readings active': 'Leituras profundas ilimitadas ativas',
    'Free deep readings used': 'Leituras profundas gratuitas esgotadas',
    'Your verified Mystic Plus entitlement is active.':
        'Seu acesso verificado ao Mystic Plus está ativo.',
    'Unlock unlimited readings with Mystic Plus.':
        'Desbloqueie leituras ilimitadas com o Mystic Plus.',
    'Your Daily Guidance remains free every day.':
        'Sua Orientação Diária continuará gratuita todos os dias.',
    'PLUS ACTIVE': 'PLUS ATIVO',
    'VIEW PLUS': 'VER PLUS',
    'TONIGHT’S MYSTIC PULSE': 'PULSO MYSTIC DESTA NOITE',
    'Release urgency. Choose the honest next step.':
        'Solte a urgência. Escolha o próximo passo mais sincero.',
    '2 MIN': '2 MIN',
    'YOUR DAILY PORTAL': 'SEU PORTAL DIÁRIO',
    'Reveal what\nneeds you today': 'Descubra o que\\nprecisa de você hoje',
    'DAILY SOUL QUEST': 'MISSÃO DIÁRIA DA ALMA',
    'Today’s relic is yours.': 'A relíquia de hoje é sua.',
    'Your chest is ready to open.': 'Seu baú está pronto para ser aberto.',
    'Complete both steps • +40 XP': 'Conclua as duas etapas • +40 XP',
    'Daily card': 'Carta diária',
    'One ritual': 'Um ritual',
    'Close reward': 'Fechar recompensa',
    'SOUL CHEST OPENED': 'BAÚ DA ALMA ABERTO',
    'Moon Shard added to your constellation.':
        'Fragmento Lunar adicionado à sua constelação.',
    'Continue my path': 'Continuar meu caminho',
    'Breathe slowly. Hold your question in mind, then choose the cards that call to you.':
        'Respire devagar. Mantenha sua pergunta em mente e escolha as cartas que chamarem você.',
    'Write your question (optional)': 'Escreva sua pergunta (opcional)',
    'HOW DO YOU FEEL RIGHT NOW?': 'COMO VOCÊ SE SENTE AGORA?',
    'CHOOSE YOUR CARDS': 'ESCOLHA SUAS CARTAS',
    'Trust the first pull': 'Confie na primeira escolha',
    'Seal my selection': 'Selar minha seleção',
    'Your reading': 'Sua leitura',
    'Share reading': 'Compartilhar leitura',
    'Take what resonates. Tarot is a mirror for reflection—not a fixed prediction.':
        'Leve o que fizer sentido. O tarô é um espelho para reflexão, não uma previsão fixa.',
    '✦  YOUR GUIDANCE': '✦  SUA ORIENTAÇÃO',
    'MYSTIC MIRROR • 24H LOOP': 'ESPELHO MYSTIC • CICLO DE 24 H',
    'Your aligned action': 'Sua ação alinhada',
    'Tomorrow, Mystic will ask what actually changed. Your answer becomes part of your personal pattern map.':
        'Amanhã, Mystic perguntará o que realmente mudou. Sua resposta passará a fazer parte do seu mapa pessoal de padrões.',
    'Saved to your journal': 'Salvo no seu diário',
    'Save this reading': 'Salvar esta leitura',
    'Return home': 'Voltar ao início',
    'MESSAGE': 'MENSAGEM',
    'What surrounds you': 'O que está ao seu redor',
    'What asks for attention': 'O que pede atenção',
    'Your next aligned step': 'Seu próximo passo alinhado',
    ' — Reversed': ' — Invertida',
    'A hopeful path is becoming visible.':
        'Um caminho esperançoso começa a ficar visível.',
    'The truth arrives when you slow down.':
        'A verdade chega quando você desacelera.',
    '◉  ORACLE MEMORY': '◉  MEMÓRIA DO ORÁCULO',
    'ASK THE ORACLE': 'PERGUNTAR AO ORÁCULO',
    'UNLIMITED': 'ILIMITADO',
    'CONTINUE PLUS': 'CONTINUAR COM PLUS',
    '1 FREE': '1 GRÁTIS',
    'Ask unlimited personal follow-ups whenever you return to this reading.':
        'Faça perguntas pessoais ilimitadas sempre que voltar a esta leitura.',
    'Your free answer is complete. Continue the dialogue with Mystic Plus.':
        'Sua resposta gratuita está completa. Continue o diálogo com o Mystic Plus.',
    'Go beyond the first interpretation with one personal follow-up question.':
        'Vá além da primeira interpretação com uma pergunta pessoal de acompanhamento.',
    'Delay one fear-based decision. Write down what is known, what is assumed, and what can wait until tomorrow.':
        'Adie uma decisão baseada no medo. Anote o que é conhecido, o que é presumido e o que pode esperar até amanhã.',
    'Turn hope into evidence: take one small action that your future self can continue tomorrow.':
        'Transforme esperança em evidência: dê um pequeno passo que seu eu do futuro possa continuar amanhã.',
    'Use today’s steadiness to complete one conversation or task you have been leaving open.':
        'Use a estabilidade de hoje para concluir uma conversa ou tarefa que você deixou em aberto.',
    'Ask one honest question without trying to control the answer.':
        'Faça uma pergunta sincera sem tentar controlar a resposta.',
    'Choose the smallest reversible step. Clarity often appears after movement, not before it.':
        'Escolha o menor passo reversível. A clareza costuma aparecer depois do movimento, não antes.',
    'REVEAL RITUAL': 'RITUAL DE REVELAÇÃO',
    'INTENTION': 'INTENÇÃO',
    'SELECTION': 'SELEÇÃO',
    'REVEAL': 'REVELAÇÃO',
    'Your cards are\nwaiting beneath the veil.':
        'Suas cartas estão esperando\\nsob o véu.',
    'Opening the veil…': 'Abrindo o véu…',
    'Open the seal': 'Abrir o selo',
    'Take what resonates. The cards offer reflection, not certainty.':
        'Leve o que fizer sentido. As cartas oferecem reflexão, não certeza.',
    'Oracle Dialogue': 'Diálogo com o Oráculo',
    'The Oracle is listening.': 'O Oráculo está ouvindo.',
    'Reversed': 'Invertida',
    'CHOOSE A FOLLOW-UP': 'ESCOLHA UMA PERGUNTA DE ACOMPANHAMENTO',
    'Or ask in your own words…': 'Ou pergunte com suas próprias palavras…',
    'Ask the Oracle': 'Perguntar ao Oráculo',
    'Ask my free question': 'Fazer minha pergunta gratuita',
    'The Oracle is connecting your symbols…':
        'O Oráculo está conectando seus símbolos…',
    'Continue the conversation': 'Continuar a conversa',
    'Ask unlimited follow-ups, revisit saved conversations, and unlock every deep spread with Mystic Plus.':
        'Faça perguntas ilimitadas, retorne a conversas salvas e desbloqueie todas as tiragens profundas com o Mystic Plus.',
    'Unlock Oracle Dialogue': 'Desbloquear o Diálogo com o Oráculo',
    'Ask another question': 'Fazer outra pergunta',
    'Return to my reading': 'Voltar à minha leitura',
    'Your card is finding its voice…': 'Sua carta está encontrando sua voz…',
    'The cards are forming a pattern…': 'As cartas estão formando um padrão…',
    'Stay with your first feeling. The full interpretation appears after the final card turns.':
        'Fique com sua primeira sensação. A interpretação completa aparecerá depois que a última carta virar.',
    'Your Mystic Path': 'Seu Caminho Mystic',
    'Your inner world becomes visible as you practice.':
        'Seu mundo interior se torna visível com a prática.',
    'INNER CONSTELLATION': 'CONSTELAÇÃO INTERIOR',
    'Today’s rituals': 'Rituais de hoje',
    'Small actions turn insight into change. Each ritual grants +15 XP.':
        'Pequenas ações transformam percepção em mudança. Cada ritual concede +15 XP.',
    '60-second reset': 'Reinício de 60 segundos',
    'Breathe in for four, out for six.':
        'Inspire por quatro e expire por seis.',
    'Name the truth': 'Dê nome à verdade',
    'Write one sentence you have been avoiding.':
        'Escreva uma frase que você vem evitando.',
    'Aligned action': 'Ação alinhada',
    'Take the smallest reversible next step.':
        'Dê o menor próximo passo reversível.',
    'Mystic rewards': 'Recompensas Mystic',
    'Your practice unlocks cosmetic relics—never better answers.':
        'Sua prática desbloqueia relíquias cosméticas, nunca respostas “melhores”.',
    'Moon Dust': 'Poeira Lunar',
    'Oracle Flame': 'Chama do Oráculo',
    'Astral Crown': 'Coroa Astral',
    'Return tomorrow to keep your constellation alive.':
        'Volte amanhã para manter sua constelação viva.',
    'CLAIMED': 'RESGATADO',
    'CLAIM': 'RESGATAR',
    'Ritual complete • +15 XP': 'Ritual concluído • +15 XP',
    'ARCANA VAULT': 'COFRE DOS ARCANOS',
    'Every reading can awaken a card.':
        'Cada leitura pode despertar uma carta.',
    'The entire deck has answered you.': 'Todo o baralho respondeu a você.',
    'Undiscovered': 'Não descoberta',
    'Your Arcana Vault': 'Seu Cofre dos Arcanos',
    'Locked': 'Bloqueada',
    'UNDISCOVERED': 'NÃO DESCOBERTA',
    'LIGHT': 'LUZ',
    'SHADOW': 'SOMBRA',
    'ALIGNED ACTION': 'AÇÃO ALINHADA',
    'YOUR WEEKLY MYSTIC WRAPPED': 'SEU RESUMO MYSTIC SEMANAL',
    'Your story is waiting for its first signal.':
        'Sua história está esperando pelo primeiro sinal.',
    '✦  MYSTIC WRAPPED': '✦  RESUMO MYSTIC',
    'Your first pattern begins with one honest reading.':
        'Seu primeiro padrão começa com uma leitura sincera.',
    'REFLECTIONS': 'REFLEXÕES',
    'No card yet': 'Ainda não há nenhuma carta',
    'REPEATING CARD': 'CARTA RECORRENTE',
    'Complete a reading and return here to watch your emotional patterns become visible.':
        'Conclua uma leitura e volte aqui para ver seus padrões emocionais se tornarem visíveis.',
    'Begin my first reading': 'Começar minha primeira leitura',
    'Keep building my pattern': 'Continuar construindo meu padrão',
    'First Signal': 'Primeiro Sinal',
    'Save 1 reading': 'Salvar 1 leitura',
    'Flame Keeper': 'Guardião da Chama',
    'Reach a 3-day streak': 'Alcance uma sequência de 3 dias',
    'Arcana Seeker': 'Buscador de Arcanos',
    'Awaken 10 cards': 'Desperte 10 cartas',
    'Relic Keeper': 'Guardião de Relíquias',
    'Claim an XP relic': 'Resgate uma relíquia de XP',
    'Reading preferences': 'Preferências de leitura',
    'Privacy & data': 'Privacidade e dados',
    'Help and support': 'Ajuda e suporte',
    'Your space': 'Seu espaço',
    'LEVEL': 'NÍVEL',
    'day streak': 'dias de sequência',
    'readings': 'leituras',
    'arcana': 'arcanos',
    'Mystic achievements': 'Conquistas Mystic',
    'Your practice leaves permanent marks on your path.':
        'Sua prática deixa marcas permanentes no seu caminho.',
    'Your tarot deck': 'Seu baralho de tarô',
    'Choose the visual energy that follows every reading.':
        'Escolha a energia visual que acompanhará cada leitura.',
    'Mystic Plus active': 'Mystic Plus ativo',
    'Unlock Mystic Plus': 'Desbloquear Mystic Plus',
    'View plan and manage subscription': 'Ver plano e gerenciar assinatura',
    'Go deeper with unlimited readings': 'Aprofunde-se com leituras ilimitadas',
    'Soul profile': 'Perfil da alma',
    'Language': 'Idioma',
    'Choose language': 'Escolher idioma',
    'Mystic is fully available in English, Turkish, Spanish, French, and Brazilian Portuguese.':
        'Mystic está totalmente disponível em inglês, turco, espanhol, francês e português do Brasil.',
    'Astral Sage': 'Sábio Astral',
    'Mystic Oracle': 'Oráculo Mystic',
    'Mystic Initiate': 'Iniciado Mystic',
    'Love path': 'Caminho do amor',
    'Purpose path': 'Caminho do propósito',
    'Healing path': 'Caminho da cura',
    'Clarity path': 'Caminho da clareza',
    'UNLOCKED': 'DESBLOQUEADO',
    'ACTIVE DECK': 'BARALHO ATIVO',
    'Solar Gold': 'Ouro Solar',
    'Make Mystic yours': 'Deixe Mystic com a sua cara',
    'Your name and intention shape the language, memory, and guidance around every reading.':
        'Seu nome e sua intenção moldam a linguagem, a memória e a orientação de cada leitura.',
    'Your name': 'Seu nome',
    'YOUR CURRENT PATH': 'SEU CAMINHO ATUAL',
    'Save my soul profile': 'Salvar meu perfil da alma',
    'Stored privately on this device.':
        'Armazenado de forma privada neste dispositivo.',
    'PLUS PREVIEW': 'PRÉVIA DO PLUS',
    'The first signal is forming…': 'O primeiro sinal está se formando…',
    'YOUR FIRST SIGNAL': 'SEU PRIMEIRO SINAL',
    'Reversed energy': 'Energia invertida',
    'Upright energy': 'Energia em pé',
    'The rest of your spread': 'O restante da sua tiragem',
    'Included with Mystic Plus • Cancel anytime':
        'Incluído no Mystic Plus • Cancele quando quiser',
    'Shape every reading': 'Molde cada leitura',
    'Allow reversed cards': 'Permitir cartas invertidas',
    'Ritual sound effects': 'Efeitos sonoros do ritual',
    'Reflection-first guidance': 'Orientação centrada na reflexão',
    'Your inner world stays yours': 'Seu mundo interior continua sendo seu',
    'Export my journal': 'Exportar meu diário',
    'Delete all Mystic data': 'Excluir todos os dados do Mystic',
    'Entertainment & reflection': 'Entretenimento e reflexão',
    'We are here to help': 'Estamos aqui para ajudar',
    'Does Mystic predict the future?': 'Mystic prevê o futuro?',
    'Can I cancel Mystic Plus?': 'Posso cancelar o Mystic Plus?',
    'How do I restore a purchase?': 'Como restauro uma compra?',
    'Is my journal private?': 'Meu diário é privado?',
    'Copy support link': 'Copiar link de suporte',
    'Support link copied.': 'Link de suporte copiado.',
    ' (Reversed)': ' (Invertida)',
    'Delete all Mystic data?': 'Excluir todos os dados do Mystic?',
    'Keep my data': 'Manter meus dados',
    'Delete everything': 'Excluir tudo',
    'Your memory map is waiting.': 'Seu mapa de memórias está esperando.',
    'Your patterns, connected.': 'Seus padrões, conectados.',
    'Memory Map': 'Mapa de Memórias',
    'Strongest connection': 'Conexão mais forte',
    'Search by meaning': 'Buscar por significado',
    'No connected memory found yet.':
        'Ainda não foi encontrada nenhuma memória conectada.',
    'Daily': 'Diária',
    'Money': 'Dinheiro',
    'Decision': 'Decisão',
    'Spirit': 'Espírito',
    'Shadow': 'Sombra',
    'Future': 'Futuro',
    'Begin before certainty arrives': 'Comece antes que a certeza chegue',
    'Take one small step you can reverse.':
        'Dê um pequeno passo que você possa desfazer.',
    'What would I try if I did not need to look ready?':
        'O que eu tentaria se não precisasse parecer pronto?',
    'Direct your available power': 'Direcione o poder que você já tem',
    'Choose one tool and use it for fifteen focused minutes.':
        'Escolha uma ferramenta e use-a por quinze minutos de foco.',
    'Where am I waiting for a resource I already have?':
        'Onde estou esperando por um recurso que já tenho?',
    'Listen beneath the noise': 'Escute por baixo do ruído',
    'Sit without input for three quiet minutes.':
        'Fique três minutos em silêncio, sem estímulos.',
    'What does my body know before my mind explains it?':
        'O que meu corpo sabe antes que minha mente explique?',
    'Nourish what should grow': 'Nutra o que deve crescer',
    'Improve one condition around your creative work.':
        'Melhore uma condição ao redor do seu trabalho criativo.',
    'What becomes possible when I stop starving my own needs?':
        'O que se torna possível quando paro de privar minhas próprias necessidades?',
    'Build a kind structure': 'Construa uma estrutura gentil',
    'Create one boundary that makes tomorrow easier.':
        'Crie um limite que torne o amanhã mais fácil.',
    'Which rule protects me, and which one only controls me?':
        'Qual regra me protege e qual apenas me controla?',
    'Choose your living tradition': 'Escolha sua tradição viva',
    'Keep one useful teaching and question one inherited rule.':
        'Mantenha um ensinamento útil e questione uma regra herdada.',
    'What deserves my respect rather than blind obedience?':
        'O que merece meu respeito em vez de obediência cega?',
    'Align desire with values': 'Alinhe o desejo aos seus valores',
    'Name the value beneath one important choice.':
        'Dê nome ao valor por trás de uma escolha importante.',
    'What choice lets me stay connected without leaving myself?':
        'Qual escolha me permite continuar conectado sem me abandonar?',
    'Move with a named direction': 'Avance com uma direção definida',
    'Write your destination before increasing your speed.':
        'Escreva seu destino antes de aumentar a velocidade.',
    'Am I moving toward something or merely escaping?':
        'Estou indo em direção a algo ou apenas fugindo?',
    'Practice gentle courage': 'Pratique uma coragem gentil',
    'Meet one difficult feeling without trying to defeat it.':
        'Encontre uma emoção difícil sem tentar derrotá-la.',
    'What changes when strength no longer means force?':
        'O que muda quando força deixa de significar imposição?',
    'Return with your own light': 'Retorne com sua própria luz',
    'Step away from input, then write one honest sentence.':
        'Afaste-se dos estímulos e depois escreva uma frase sincera.',
    'Which answer can only be heard in solitude?':
        'Qual resposta só pode ser ouvida na solidão?',
    'Work with the turning cycle': 'Trabalhe com o ciclo em movimento',
    'Release one expectation that belongs to yesterday.':
        'Solte uma expectativa que pertence a ontem.',
    'What opening appears when I stop demanding the old shape?':
        'Qual abertura aparece quando paro de exigir a forma antiga?',
    'Restore honest proportion': 'Restaure uma proporção honesta',
    'Name your part without taking all the blame.':
        'Reconheça sua parte sem assumir toda a culpa.',
    'What decision would I respect if nobody applauded?':
        'Qual decisão eu respeitaria mesmo que ninguém aplaudisse?',
    'See from the opposite angle': 'Veja pelo ângulo oposto',
    'Argue sincerely for the view you resist.':
        'Defenda com sinceridade o ponto de vista ao qual você resiste.',
    'What becomes visible when progress pauses?':
        'O que se torna visível quando o progresso faz uma pausa?',
    'Release the completed form': 'Solte a forma que já terminou',
    'Remove one object, task, or promise that is already over.':
        'Retire um objeto, uma tarefa ou uma promessa que já terminou.',
    'Which identity can no longer carry me forward?':
        'Qual identidade já não consegue me levar adiante?',
    'Integrate instead of swinging': 'Integre em vez de oscilar',
    'Make the next adjustment small enough to sustain.':
        'Faça o próximo ajuste pequeno o bastante para ser sustentado.',
    'Where would five percent be wiser than all or nothing?':
        'Onde cinco por cento seria mais sábio do que tudo ou nada?',
    'Name the hidden bargain': 'Dê nome ao acordo oculto',
    'Write the real cost of one familiar attachment.':
        'Escreva o custo real de um apego conhecido.',
    'What keeps choosing for me when I stop paying attention?':
        'O que continua escolhendo por mim quando deixo de prestar atenção?',
    'Protect truth through change': 'Proteja a verdade durante a mudança',
    'Separate what is falling from what is genuinely valuable.':
        'Separe o que está caindo do que é realmente valioso.',
    'What false structure am I exhausted from maintaining?':
        'Qual estrutura falsa estou cansado de manter?',
    'Practice evidence of hope': 'Pratique evidências de esperança',
    'Do one hopeful act that asks nothing from the outcome.':
        'Faça um gesto de esperança que não exija nada do resultado.',
    'What small act would make possibility feel safe again?':
        'Qual pequeno gesto faria a possibilidade voltar a parecer segura?',
    'Wait for more light': 'Espere por mais luz',
    'Divide one fear into facts, assumptions, and unknowns.':
        'Divida um medo entre fatos, suposições e desconhecidos.',
    'Where has uncertainty been disguised as certainty?':
        'Onde a incerteza se disfarçou de certeza?',
    'Let joy be uncomplicated': 'Deixe a alegria ser simples',
    'Share one warm moment without performing it.':
        'Compartilhe um momento caloroso sem transformá-lo em atuação.',
    'What goodness am I making harder than it needs to be?':
        'Que coisa boa estou tornando mais difícil do que precisa ser?',
    'Answer the deeper call': 'Responda ao chamado mais profundo',
    'Write what the next version of you refuses to postpone.':
        'Escreva o que sua próxima versão se recusa a continuar adiando.',
    'Who am I becoming when old shame is not in charge?':
        'Quem estou me tornando quando a antiga vergonha já não está no comando?',
    'Honor completion': 'Honre o que se completa',
    'Close one open loop and name what it taught you.':
        'Feche um ciclo em aberto e diga o que ele ensinou a você.',
    'What must be celebrated before the next chapter begins?':
        'O que precisa ser celebrado antes que o próximo capítulo comece?',
    'Mystic should adapt to your practice—not ask you to adapt to it.':
        'O Mystic deve se adaptar à sua prática, não pedir que você se adapte a ele.',
    'Adds shadow meanings to approximately one in four cards.':
        'Adiciona significados de sombra a aproximadamente uma em cada quatro cartas.',
    'Soft audio cues for selection, sealing, and reveal.':
        'Sinais sonoros suaves para seleção, selamento e revelação.',
    'Readings remain grounded invitations—not certainty, diagnosis, or professional advice.':
        'As leituras continuam sendo convites realistas à reflexão, não certezas, diagnósticos ou orientação profissional.',
    'This release keeps your journal and progress locally on this device. No questions are sold to advertisers.':
        'Esta versão mantém seu diário e progresso localmente neste dispositivo. Suas perguntas não são vendidas a anunciantes.',
    'Permanently removes local journal, XP, streak, and settings.':
        'Remove permanentemente o diário local, XP, sequência e configurações.',
    'Mystic Tarot is designed for personal reflection and entertainment. It does not provide medical, legal, financial, or mental-health advice.':
        'Mystic Tarot foi criado para reflexão pessoal e entretenimento. Não oferece orientação médica, jurídica, financeira ou de saúde mental.',
    'Clear answers before you begin your next ritual.':
        'Respostas claras antes de começar seu próximo ritual.',
    'No. It uses tarot symbolism as a structured mirror for reflection and possible perspectives.':
        'Não. Ele usa o simbolismo do tarô como um espelho estruturado para reflexão e possíveis perspectivas.',
    'When native subscriptions launch, they can be managed and cancelled through Apple or Google account settings. The web release does not process payments.':
        'Quando as assinaturas nativas forem lançadas, poderão ser gerenciadas e canceladas nas configurações da conta Apple ou Google. A versão web não processa pagamentos.',
    'Restore becomes available with native Apple and Google subscriptions. The current web release does not process or store purchases.':
        'A restauração estará disponível com assinaturas nativas da Apple e do Google. A versão web atual não processa nem armazena compras.',
    'Yes. The current release stores it locally on this device and does not transmit journal content to us. You can export or delete it at any time.':
        'Sim. A versão atual mantém o diário localmente neste dispositivo e não transmite seu conteúdo para nós. Você pode exportá-lo ou excluí-lo quando quiser.',
    'Mystic Tarot Journal\n\nNo saved readings yet.':
        'Diário do Mystic Tarot\n\nAinda não há leituras salvas.',
    'Your journal was copied for export.':
        'Seu diário foi copiado para exportação.',
    'This cannot be undone. Your journal, card collection, streak, XP, and preferences will be removed from this device.':
        'Esta ação não pode ser desfeita. Seu diário, coleção de cartas, sequência, XP e preferências serão removidos deste dispositivo.',
  };

  static final List<_MysticTemplate> _spanishTemplates = <_MysticTemplate>[
    _MysticTemplate(
      '{{p0}} readings connected • Day {{p1}} of 22',
      '{{p0}} lecturas conectadas • Día {{p1}} de 22',
    ),
    _MysticTemplate('CURRENT CHAPTER • {{p0}}', 'CAPÍTULO ACTUAL • {{p0}}'),
    _MysticTemplate(
      'Your recent {{p0}} questions have carried {{p1}} energy. This chapter asks you to {{p2}}',
      'Tus preguntas recientes sobre {{p0}} han llevado una energía {{p1}}. Este capítulo te invita a {{p2}}',
    ),
    _MysticTemplate('Seal day {{p0}}', 'Sellar el día {{p0}}'),
    _MysticTemplate('DAY {{p0}} OF 22', 'DÍA {{p0}} DE 22'),
    _MysticTemplate(
      'Your cards are waiting, {{p0}}',
      'Tus cartas te esperan, {{p0}}',
    ),
    _MysticTemplate(
      '{{p0}}-card premium spread',
      'Tirada premium de {{p0}} cartas',
    ),
    _MysticTemplate('{{p0}} cards', '{{p0}} cartas'),
    _MysticTemplate('{{p0}} card spread', 'Tirada de {{p0}} cartas'),
    _MysticTemplate(
      'Your {{p0}} path is opening',
      'Tu camino de {{p0}} se está abriendo',
    ),
    _MysticTemplate(
      '{{p0}} has returned {{p1}} times. Mystic is watching what this symbol keeps asking you to notice.',
      '{{p0}} ha regresado {{p1}} veces. Mystic observa qué sigue pidiéndote que notes este símbolo.',
    ),
    _MysticTemplate(
      'You have entered recent readings feeling {{p0}}. Your next reading will hold that emotional thread in view.',
      'Has llegado a tus lecturas recientes sintiéndote {{p0}}. Tu próxima lectura tendrá presente ese hilo emocional.',
    ),
    _MysticTemplate(
      '{{p0}} free deep readings left today',
      'Te quedan {{p0}} lecturas profundas gratuitas hoy',
    ),
    _MysticTemplate(
      '🔥 {{p0}} day streak  •  +25 XP',
      '🔥 Racha de {{p0}} días  •  +25 XP',
    ),
    _MysticTemplate('Choose {{p0}} more', 'Elige {{p0}} más'),
    _MysticTemplate(
      '{{p0}}, a hopeful path is becoming visible.',
      '{{p0}}, empieza a hacerse visible un camino esperanzador.',
    ),
    _MysticTemplate(
      '{{p0}}, the truth arrives when you slow down.',
      '{{p0}}, la verdad llega cuando bajas el ritmo.',
    ),
    _MysticTemplate(
      '{{p0}} also appeared in your last saved reading. Repeating symbols often become useful when you compare what changed between the two moments.',
      '{{p0}} también apareció en tu última lectura guardada. Los símbolos repetidos suelen ser útiles cuando comparas qué cambió entre ambos momentos.',
    ),
    _MysticTemplate(
      'Your previous reading began from {{p0}}; today you chose {{p1}}. Mystic is connecting the emotional shift—not just the cards.',
      'Tu lectura anterior comenzó desde {{p0}}; hoy elegiste {{p1}}. Mystic está conectando el cambio emocional, no solo las cartas.',
    ),
    _MysticTemplate(
      '{{p0}} Hold this beside your intention of {{p1}}. Let it be an invitation, not a command, and notice what changes over the next twenty-four hours.',
      '{{p0}} Mantenlo junto a tu intención de {{p1}}. Tómalo como una invitación, no como una orden, y observa qué cambia durante las próximas veinticuatro horas.',
    ),
    _MysticTemplate(
      'Hold your {{p0}} intention in mind. Exhale once, then open the seal when you feel ready.',
      'Mantén en mente tu intención de {{p0}}. Exhala una vez y abre el sello cuando te sientas preparado.',
    ),
    _MysticTemplate(
      '{{p0}}, the Oracle is listening.',
      '{{p0}}, el Oráculo está escuchando.',
    ),
    _MysticTemplate(
      'Ask one question about the cards you just revealed. The answer will stay grounded in their symbols and your {{p0}} path.',
      'Haz una pregunta sobre las cartas que acabas de revelar. La respuesta se mantendrá anclada en sus símbolos y en tu camino de {{p0}}.',
    ),
    _MysticTemplate(
      'Oracle Memory is connecting {{p0}} previous readings on this device.',
      'La Memoria del Oráculo está conectando {{p0}} lecturas anteriores de este dispositivo.',
    ),
    _MysticTemplate('LEVEL {{p0}}', 'NIVEL {{p0}}'),
    _MysticTemplate(
      '{{p0}} of 78 cards awakened',
      '{{p0}} de 78 cartas despertadas',
    ),
    _MysticTemplate(
      '{{p0}}% to Level {{p1}}',
      '{{p0}} % para alcanzar el nivel {{p1}}',
    ),
    _MysticTemplate('{{p0}}-day flame', 'Llama de {{p0}} días'),
    _MysticTemplate(
      '{{p0}} more cards until your next collection milestone.',
      'Faltan {{p0}} cartas para tu próximo hito de colección.',
    ),
    _MysticTemplate(
      '{{p0}} awakened • {{p1}} still hidden',
      '{{p0}} despertadas • {{p1}} aún ocultas',
    ),
    _MysticTemplate(
      '{{p0}} led your week • {{p1}} reflections',
      '{{p0}} guio tu semana • {{p1}} reflexiones',
    ),
    _MysticTemplate(
      '{{p0}} {{p1}} was your dominant inner weather.',
      '{{p0}} {{p1}} fue tu clima interior dominante.',
    ),
    _MysticTemplate(
      'Your invitation: notice where {{p0}} energy protected you—and where it quietly chose for you.',
      'Tu invitación: observa dónde te protegió la energía {{p0}} y dónde eligió silenciosamente por ti.',
    ),
    _MysticTemplate(
      '{{p0}} XP to level {{p1}}',
      '{{p0}} XP para alcanzar el nivel {{p1}}',
    ),
    _MysticTemplate(
      'One card is yours. The complete {{p0}}-card story waits behind it.',
      'Una carta es tuya. La historia completa de {{p0}} cartas te espera detrás de ella.',
    ),
    _MysticTemplate('{{p0}} LOCKED', '{{p0}} BLOQUEADAS'),
    _MysticTemplate(
      'Unlock the full {{p0}}',
      'Desbloquear la lectura completa de {{p0}}',
    ),
    _MysticTemplate('{{p0}} themes', '{{p0}} temas'),
    _MysticTemplate('{{p0}} readings', '{{p0}} lecturas'),
    _MysticTemplate('{{p0}} saved readings', '{{p0}} lecturas guardadas'),
  ];

  static final List<_MysticTemplate> _frenchTemplates = <_MysticTemplate>[
    _MysticTemplate(
      '{{p0}} readings connected • Day {{p1}} of 22',
      '{{p0}} tirages reliés • Jour {{p1}} sur 22',
    ),
    _MysticTemplate('CURRENT CHAPTER • {{p0}}', 'CHAPITRE ACTUEL • {{p0}}'),
    _MysticTemplate(
      'Your recent {{p0}} questions have carried {{p1}} energy. This chapter asks you to {{p2}}',
      'Vos questions récentes sur {{p0}} portaient une énergie {{p1}}. Ce chapitre vous invite à {{p2}}',
    ),
    _MysticTemplate('Seal day {{p0}}', 'Sceller le jour {{p0}}'),
    _MysticTemplate('DAY {{p0}} OF 22', 'JOUR {{p0}} SUR 22'),
    _MysticTemplate(
      'Your cards are waiting, {{p0}}',
      'Vos cartes vous attendent, {{p0}}',
    ),
    _MysticTemplate(
      '{{p0}}-card premium spread',
      'Tirage premium de {{p0}} cartes',
    ),
    _MysticTemplate('{{p0}} cards', '{{p0}} cartes'),
    _MysticTemplate('{{p0}} card spread', 'Tirage de {{p0}} cartes'),
    _MysticTemplate(
      'Your {{p0}} path is opening',
      'Votre chemin de {{p0}} s’ouvre',
    ),
    _MysticTemplate(
      '{{p0}} has returned {{p1}} times. Mystic is watching what this symbol keeps asking you to notice.',
      '{{p0}} est revenue {{p1}} fois. Mystic observe ce que ce symbole continue de vous inviter à remarquer.',
    ),
    _MysticTemplate(
      'You have entered recent readings feeling {{p0}}. Your next reading will hold that emotional thread in view.',
      'Vous avez abordé vos tirages récents en vous sentant {{p0}}. Votre prochain tirage gardera ce fil émotionnel en vue.',
    ),
    _MysticTemplate(
      '{{p0}} free deep readings left today',
      'Il vous reste {{p0}} tirages approfondis gratuits aujourd’hui',
    ),
    _MysticTemplate(
      '🔥 {{p0}} day streak  •  +25 XP',
      '🔥 Série de {{p0}} jours  •  +25 XP',
    ),
    _MysticTemplate('Choose {{p0}} more', 'Choisissez-en encore {{p0}}'),
    _MysticTemplate(
      '{{p0}}, a hopeful path is becoming visible.',
      '{{p0}}, un chemin porteur d’espoir commence à apparaître.',
    ),
    _MysticTemplate(
      '{{p0}}, the truth arrives when you slow down.',
      '{{p0}}, la vérité arrive lorsque vous ralentissez.',
    ),
    _MysticTemplate(
      '{{p0}} also appeared in your last saved reading. Repeating symbols often become useful when you compare what changed between the two moments.',
      '{{p0}} est également apparue dans votre dernier tirage enregistré. Les symboles récurrents deviennent souvent utiles lorsque vous comparez ce qui a changé entre les deux moments.',
    ),
    _MysticTemplate(
      'Your previous reading began from {{p0}}; today you chose {{p1}}. Mystic is connecting the emotional shift—not just the cards.',
      'Votre précédent tirage a commencé dans un état {{p0}} ; aujourd’hui, vous avez choisi {{p1}}. Mystic relie l’évolution émotionnelle, pas seulement les cartes.',
    ),
    _MysticTemplate(
      '{{p0}} Hold this beside your intention of {{p1}}. Let it be an invitation, not a command, and notice what changes over the next twenty-four hours.',
      '{{p0}} Gardez ceci près de votre intention de {{p1}}. Recevez-le comme une invitation, pas comme un ordre, et observez ce qui change au cours des prochaines vingt-quatre heures.',
    ),
    _MysticTemplate(
      'Hold your {{p0}} intention in mind. Exhale once, then open the seal when you feel ready.',
      'Gardez votre intention de {{p0}} à l’esprit. Expirez une fois, puis ouvrez le sceau lorsque vous vous sentez prêt.',
    ),
    _MysticTemplate(
      '{{p0}}, the Oracle is listening.',
      '{{p0}}, l’Oracle vous écoute.',
    ),
    _MysticTemplate(
      'Ask one question about the cards you just revealed. The answer will stay grounded in their symbols and your {{p0}} path.',
      'Posez une question sur les cartes que vous venez de révéler. La réponse restera ancrée dans leurs symboles et dans votre chemin de {{p0}}.',
    ),
    _MysticTemplate(
      'Oracle Memory is connecting {{p0}} previous readings on this device.',
      'La Mémoire de l’Oracle relie {{p0}} tirages précédents sur cet appareil.',
    ),
    _MysticTemplate('LEVEL {{p0}}', 'NIVEAU {{p0}}'),
    _MysticTemplate(
      '{{p0}} of 78 cards awakened',
      '{{p0}} cartes éveillées sur 78',
    ),
    _MysticTemplate(
      '{{p0}}% to Level {{p1}}',
      '{{p0}} % avant le niveau {{p1}}',
    ),
    _MysticTemplate('{{p0}}-day flame', 'Flamme de {{p0}} jours'),
    _MysticTemplate(
      '{{p0}} more cards until your next collection milestone.',
      'Encore {{p0}} cartes avant le prochain palier de votre collection.',
    ),
    _MysticTemplate(
      '{{p0}} awakened • {{p1}} still hidden',
      '{{p0}} éveillées • {{p1}} encore cachées',
    ),
    _MysticTemplate(
      '{{p0}} led your week • {{p1}} reflections',
      '{{p0}} a guidé votre semaine • {{p1}} réflexions',
    ),
    _MysticTemplate(
      '{{p0}} {{p1}} was your dominant inner weather.',
      '{{p0}} {{p1}} était votre climat intérieur dominant.',
    ),
    _MysticTemplate(
      'Your invitation: notice where {{p0}} energy protected you—and where it quietly chose for you.',
      'Votre invitation : remarquez où l’énergie {{p0}} vous a protégé, et où elle a discrètement choisi à votre place.',
    ),
    _MysticTemplate(
      '{{p0}} XP to level {{p1}}',
      '{{p0}} XP avant le niveau {{p1}}',
    ),
    _MysticTemplate(
      'One card is yours. The complete {{p0}}-card story waits behind it.',
      'Une carte est à vous. L’histoire complète en {{p0}} cartes vous attend derrière elle.',
    ),
    _MysticTemplate('{{p0}} LOCKED', '{{p0}} VERROUILLÉES'),
    _MysticTemplate(
      'Unlock the full {{p0}}',
      'Débloquer le tirage complet de {{p0}}',
    ),
    _MysticTemplate('{{p0}} themes', '{{p0}} thèmes'),
    _MysticTemplate('{{p0}} readings', '{{p0}} tirages'),
    _MysticTemplate('{{p0}} saved readings', '{{p0}} tirages enregistrés'),
  ];

  static final List<_MysticTemplate>
  _portugueseBrazilTemplates = <_MysticTemplate>[
    _MysticTemplate(
      '{{p0}} readings connected • Day {{p1}} of 22',
      '{{p0}} leituras conectadas • Dia {{p1}} de 22',
    ),
    _MysticTemplate('CURRENT CHAPTER • {{p0}}', 'CAPÍTULO ATUAL • {{p0}}'),
    _MysticTemplate(
      'Your recent {{p0}} questions have carried {{p1}} energy. This chapter asks you to {{p2}}',
      'Suas perguntas recentes sobre {{p0}} carregaram uma energia {{p1}}. Este capítulo convida você a {{p2}}',
    ),
    _MysticTemplate('Seal day {{p0}}', 'Selar o dia {{p0}}'),
    _MysticTemplate('DAY {{p0}} OF 22', 'DIA {{p0}} DE 22'),
    _MysticTemplate(
      'Your cards are waiting, {{p0}}',
      'Suas cartas estão esperando, {{p0}}',
    ),
    _MysticTemplate(
      '{{p0}}-card premium spread',
      'Tiragem premium de {{p0}} cartas',
    ),
    _MysticTemplate('{{p0}} cards', '{{p0}} cartas'),
    _MysticTemplate('{{p0}} card spread', 'Tiragem de {{p0}} cartas'),
    _MysticTemplate(
      'Your {{p0}} path is opening',
      'Seu caminho de {{p0}} está se abrindo',
    ),
    _MysticTemplate(
      '{{p0}} has returned {{p1}} times. Mystic is watching what this symbol keeps asking you to notice.',
      '{{p0}} retornou {{p1}} vezes. Mystic observa o que esse símbolo continua pedindo para você notar.',
    ),
    _MysticTemplate(
      'You have entered recent readings feeling {{p0}}. Your next reading will hold that emotional thread in view.',
      'Você entrou nas leituras recentes sentindo-se {{p0}}. Sua próxima leitura manterá esse fio emocional em vista.',
    ),
    _MysticTemplate(
      '{{p0}} free deep readings left today',
      'Você ainda tem {{p0}} leituras profundas gratuitas hoje',
    ),
    _MysticTemplate(
      '🔥 {{p0}} day streak  •  +25 XP',
      '🔥 Sequência de {{p0}} dias  •  +25 XP',
    ),
    _MysticTemplate('Choose {{p0}} more', 'Escolha mais {{p0}}'),
    _MysticTemplate(
      '{{p0}}, a hopeful path is becoming visible.',
      '{{p0}}, um caminho esperançoso começa a ficar visível.',
    ),
    _MysticTemplate(
      '{{p0}}, the truth arrives when you slow down.',
      '{{p0}}, a verdade chega quando você desacelera.',
    ),
    _MysticTemplate(
      '{{p0}} also appeared in your last saved reading. Repeating symbols often become useful when you compare what changed between the two moments.',
      '{{p0}} também apareceu na sua última leitura salva. Símbolos repetidos costumam se tornar úteis quando você compara o que mudou entre os dois momentos.',
    ),
    _MysticTemplate(
      'Your previous reading began from {{p0}}; today you chose {{p1}}. Mystic is connecting the emotional shift—not just the cards.',
      'Sua leitura anterior começou em {{p0}}; hoje você escolheu {{p1}}. Mystic está conectando a mudança emocional, não apenas as cartas.',
    ),
    _MysticTemplate(
      '{{p0}} Hold this beside your intention of {{p1}}. Let it be an invitation, not a command, and notice what changes over the next twenty-four hours.',
      '{{p0}} Mantenha isso ao lado da sua intenção de {{p1}}. Encare como um convite, não como uma ordem, e observe o que muda nas próximas vinte e quatro horas.',
    ),
    _MysticTemplate(
      'Hold your {{p0}} intention in mind. Exhale once, then open the seal when you feel ready.',
      'Mantenha em mente sua intenção de {{p0}}. Expire uma vez e abra o selo quando se sentir pronto.',
    ),
    _MysticTemplate(
      '{{p0}}, the Oracle is listening.',
      '{{p0}}, o Oráculo está ouvindo.',
    ),
    _MysticTemplate(
      'Ask one question about the cards you just revealed. The answer will stay grounded in their symbols and your {{p0}} path.',
      'Faça uma pergunta sobre as cartas que você acabou de revelar. A resposta permanecerá ancorada nos símbolos delas e no seu caminho de {{p0}}.',
    ),
    _MysticTemplate(
      'Oracle Memory is connecting {{p0}} previous readings on this device.',
      'A Memória do Oráculo está conectando {{p0}} leituras anteriores neste dispositivo.',
    ),
    _MysticTemplate('LEVEL {{p0}}', 'NÍVEL {{p0}}'),
    _MysticTemplate(
      '{{p0}} of 78 cards awakened',
      '{{p0}} de 78 cartas despertas',
    ),
    _MysticTemplate(
      '{{p0}}% to Level {{p1}}',
      '{{p0}}% para alcançar o nível {{p1}}',
    ),
    _MysticTemplate('{{p0}}-day flame', 'Chama de {{p0}} dias'),
    _MysticTemplate(
      '{{p0}} more cards until your next collection milestone.',
      'Faltam {{p0}} cartas para o próximo marco da sua coleção.',
    ),
    _MysticTemplate(
      '{{p0}} awakened • {{p1}} still hidden',
      '{{p0}} despertas • {{p1}} ainda ocultas',
    ),
    _MysticTemplate(
      '{{p0}} led your week • {{p1}} reflections',
      '{{p0}} guiou sua semana • {{p1}} reflexões',
    ),
    _MysticTemplate(
      '{{p0}} {{p1}} was your dominant inner weather.',
      '{{p0}} {{p1}} foi seu clima interior dominante.',
    ),
    _MysticTemplate(
      'Your invitation: notice where {{p0}} energy protected you—and where it quietly chose for you.',
      'Seu convite: observe onde a energia {{p0}} protegeu você e onde escolheu silenciosamente por você.',
    ),
    _MysticTemplate(
      '{{p0}} XP to level {{p1}}',
      '{{p0}} XP para alcançar o nível {{p1}}',
    ),
    _MysticTemplate(
      'One card is yours. The complete {{p0}}-card story waits behind it.',
      'Uma carta é sua. A história completa de {{p0}} cartas espera atrás dela.',
    ),
    _MysticTemplate('{{p0}} LOCKED', '{{p0}} BLOQUEADAS'),
    _MysticTemplate(
      'Unlock the full {{p0}}',
      'Desbloquear a leitura completa de {{p0}}',
    ),
    _MysticTemplate('{{p0}} themes', '{{p0}} temas'),
    _MysticTemplate('{{p0}} readings', '{{p0}} leituras'),
    _MysticTemplate('{{p0}} saved readings', '{{p0}} leituras salvas'),
  ];
}

class _MysticTemplate {
  _MysticTemplate(this.source, this.target)
    : _pattern = RegExp('^${_sourcePattern(source)}\$', dotAll: true);

  final String source;
  final String target;
  final RegExp _pattern;

  String? apply(String input, String languageCode) {
    final match = _pattern.firstMatch(input);
    if (match == null) return null;
    var result = target;
    for (var index = 1; index <= match.groupCount; index++) {
      final captured = match.group(index) ?? '';
      result = result.replaceAll(
        '{{p${index - 1}}}',
        MysticTextCatalog._translateCaptured(languageCode, captured),
      );
    }
    return result;
  }

  static String _sourcePattern(String source) {
    final placeholder = RegExp(r'\{\{p\d+\}\}');
    final buffer = StringBuffer();
    var cursor = 0;
    for (final match in placeholder.allMatches(source)) {
      buffer.write(RegExp.escape(source.substring(cursor, match.start)));
      buffer.write('(.+?)');
      cursor = match.end;
    }
    buffer.write(RegExp.escape(source.substring(cursor)));
    return buffer.toString();
  }
}
