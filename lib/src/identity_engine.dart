import 'app_language.dart';
import 'models.dart';

enum MysticArchetype { seeker, alchemist, sage, guardian, visionary }

class MysticIdentitySnapshot {
  const MysticIdentitySnapshot({
    required this.primary,
    required this.secondary,
    required this.confidence,
    required this.title,
    required this.summary,
    required this.nextEvolution,
    required this.progressToEvolution,
    required this.signals,
  });

  final MysticArchetype primary;
  final MysticArchetype secondary;
  final int confidence;
  final String title;
  final String summary;
  final String nextEvolution;
  final double progressToEvolution;
  final List<String> signals;
}

class MysticIdentityEngine {
  const MysticIdentityEngine();

  MysticIdentitySnapshot analyze({
    required List<ReadingRecord> records,
    required int streak,
    required int completedArcanaDays,
    AppLanguage language = AppLanguage.english,
  }) {
    final scores = <MysticArchetype, int>{
      for (final archetype in MysticArchetype.values) archetype: 0,
    };

    void add(MysticArchetype archetype, int value) {
      scores[archetype] = scores[archetype]! + value;
    }

    for (final record in records) {
      add(_kindArchetype(record.kind), _kindWeight(record.kind));
      add(_emotionArchetype(record.emotion), 2);
      if (record.cards.any((card) => card.reversed)) {
        add(MysticArchetype.alchemist, 2);
      }
      if (record.alignedAction.trim().length >= 18) {
        add(MysticArchetype.guardian, 1);
      }
    }

    add(MysticArchetype.sage, completedArcanaDays * 2);
    add(MysticArchetype.guardian, streak);
    if (records.length >= 8) add(MysticArchetype.alchemist, 4);

    final ranked = scores.entries.toList()
      ..sort((a, b) {
        final byScore = b.value.compareTo(a.value);
        return byScore != 0 ? byScore : a.key.index.compareTo(b.key.index);
      });
    final primary = ranked.first.key;
    final secondary = ranked[1].key;
    final total = scores.values.fold<int>(0, (sum, value) => sum + value);
    final confidence = total == 0
        ? 0
        : ((ranked.first.value / total) * 100).round().clamp(0, 100);

    return MysticIdentitySnapshot(
      primary: primary,
      secondary: secondary,
      confidence: confidence,
      title: _title(primary, language),
      summary: _summary(primary, language),
      nextEvolution: _title(_nextEvolution(primary), language),
      progressToEvolution:
          (records.length * 4 + streak * 5 + completedArcanaDays * 3)
                  .clamp(0, 100) /
              100,
      signals: _signals(
        primary: primary,
        records: records.length,
        streak: streak,
        completedArcanaDays: completedArcanaDays,
        language: language,
      ),
    );
  }

  MysticArchetype _kindArchetype(ReadingKind kind) => switch (kind) {
        ReadingKind.daily || ReadingKind.decision => MysticArchetype.seeker,
        ReadingKind.shadow || ReadingKind.spiritual =>
          MysticArchetype.alchemist,
        ReadingKind.career || ReadingKind.money => MysticArchetype.guardian,
        ReadingKind.love || ReadingKind.compatibility =>
          MysticArchetype.visionary,
        ReadingKind.timeline || ReadingKind.celticCross => MysticArchetype.sage,
      };

  int _kindWeight(ReadingKind kind) => switch (kind) {
        ReadingKind.timeline || ReadingKind.celticCross => 4,
        ReadingKind.shadow ||
        ReadingKind.spiritual ||
        ReadingKind.career ||
        ReadingKind.money ||
        ReadingKind.love ||
        ReadingKind.compatibility =>
          3,
        ReadingKind.daily || ReadingKind.decision => 2,
      };

  MysticArchetype _emotionArchetype(EmotionalState emotion) => switch (emotion) {
        EmotionalState.uncertain || EmotionalState.curious =>
          MysticArchetype.seeker,
        EmotionalState.anxious => MysticArchetype.alchemist,
        EmotionalState.grounded => MysticArchetype.guardian,
        EmotionalState.hopeful => MysticArchetype.visionary,
      };

  MysticArchetype _nextEvolution(MysticArchetype current) => switch (current) {
        MysticArchetype.seeker => MysticArchetype.alchemist,
        MysticArchetype.alchemist => MysticArchetype.sage,
        MysticArchetype.sage => MysticArchetype.visionary,
        MysticArchetype.guardian => MysticArchetype.sage,
        MysticArchetype.visionary => MysticArchetype.guardian,
      };

  String _title(MysticArchetype archetype, AppLanguage language) => switch (archetype) {
        MysticArchetype.seeker => localized(language,
            english: 'The Seeker', spanish: 'El Buscador', french: 'Le Chercheur', portugueseBrazil: 'O Buscador', turkish: 'Arayışçı', italian: 'Il Cercatore', german: 'Der Suchende'),
        MysticArchetype.alchemist => localized(language,
            english: 'The Alchemist', spanish: 'El Alquimista', french: 'L’Alchimiste', portugueseBrazil: 'O Alquimista', turkish: 'Simyacı', italian: 'L’Alchimista', german: 'Der Alchemist'),
        MysticArchetype.sage => localized(language,
            english: 'The Sage', spanish: 'El Sabio', french: 'Le Sage', portugueseBrazil: 'O Sábio', turkish: 'Bilge', italian: 'Il Saggio', german: 'Der Weise'),
        MysticArchetype.guardian => localized(language,
            english: 'The Guardian', spanish: 'El Guardián', french: 'Le Gardien', portugueseBrazil: 'O Guardião', turkish: 'Koruyucu', italian: 'Il Guardiano', german: 'Der Hüter'),
        MysticArchetype.visionary => localized(language,
            english: 'The Visionary', spanish: 'El Visionario', french: 'Le Visionnaire', portugueseBrazil: 'O Visionário', turkish: 'Vizyoner', italian: 'Il Visionario', german: 'Der Visionär'),
      };

  String _summary(MysticArchetype archetype, AppLanguage language) => switch (archetype) {
        MysticArchetype.seeker => localized(language,
            english: 'You grow by asking honest questions and following what keeps returning.', spanish: 'Creces al hacer preguntas honestas y seguir aquello que vuelve una y otra vez.', french: 'Vous évoluez en posant des questions sincères et en suivant ce qui revient.', portugueseBrazil: 'Você cresce ao fazer perguntas honestas e acompanhar o que continua voltando.', turkish: 'Dürüst sorular sorarak ve tekrar tekrar karşına çıkanı izleyerek gelişiyorsun.', italian: 'Cresci ponendo domande sincere e seguendo ciò che continua a tornare.', german: 'Du wächst, indem du ehrliche Fragen stellst und dem folgst, was immer wiederkehrt.'),
        MysticArchetype.alchemist => localized(language,
            english: 'You transform uncertainty into action by facing difficult patterns directly.', spanish: 'Transformas la incertidumbre en acción al afrontar directamente los patrones difíciles.', french: 'Vous transformez l’incertitude en action en affrontant directement les schémas difficiles.', portugueseBrazil: 'Você transforma incerteza em ação ao encarar padrões difíceis de frente.', turkish: 'Zor örüntülerle doğrudan yüzleşerek belirsizliği eyleme dönüştürüyorsun.', italian: 'Trasformi l’incertezza in azione affrontando direttamente gli schemi difficili.', german: 'Du verwandelst Unsicherheit in Handlung, indem du schwierigen Mustern direkt begegnest.'),
        MysticArchetype.sage => localized(language,
            english: 'You seek meaning across time and turn repeated experience into perspective.', spanish: 'Buscas significado a través del tiempo y conviertes la experiencia repetida en perspectiva.', french: 'Vous cherchez du sens dans le temps et transformez les expériences répétées en perspective.', portugueseBrazil: 'Você busca significado ao longo do tempo e transforma experiências repetidas em perspectiva.', turkish: 'Zaman içindeki anlamı arıyor ve tekrarlanan deneyimleri bakış açısına dönüştürüyorsun.', italian: 'Cerchi significato nel tempo e trasformi le esperienze ripetute in prospettiva.', german: 'Du suchst über die Zeit hinweg nach Bedeutung und verwandelst wiederholte Erfahrungen in Perspektive.'),
        MysticArchetype.guardian => localized(language,
            english: 'You value stability, responsibility, and choices that protect your future.', spanish: 'Valoras la estabilidad, la responsabilidad y las decisiones que protegen tu futuro.', french: 'Vous accordez de l’importance à la stabilité, à la responsabilité et aux choix qui protègent votre avenir.', portugueseBrazil: 'Você valoriza estabilidade, responsabilidade e escolhas que protegem seu futuro.', turkish: 'İstikrara, sorumluluğa ve geleceğini koruyan seçimlere değer veriyorsun.', italian: 'Dai valore alla stabilità, alla responsabilità e alle scelte che proteggono il tuo futuro.', german: 'Du schätzt Stabilität, Verantwortung und Entscheidungen, die deine Zukunft schützen.'),
        MysticArchetype.visionary => localized(language,
            english: 'You are guided by possibility, connection, and the future you can imagine.', spanish: 'Te guían la posibilidad, la conexión y el futuro que puedes imaginar.', french: 'Vous êtes guidé par les possibles, les liens et l’avenir que vous pouvez imaginer.', portugueseBrazil: 'Você é guiado por possibilidades, conexão e pelo futuro que consegue imaginar.', turkish: 'Sana ihtimaller, bağ kurma ve hayal edebildiğin gelecek yön veriyor.', italian: 'Sei guidato dalle possibilità, dalla connessione e dal futuro che riesci a immaginare.', german: 'Dich leiten Möglichkeiten, Verbundenheit und die Zukunft, die du dir vorstellen kannst.'),
      };

  List<String> _signals({
    required MysticArchetype primary,
    required int records,
    required int streak,
    required int completedArcanaDays,
    required AppLanguage language,
  }) {
    if (records == 0) {
      return [localized(language,
          english: 'Your identity begins with your first reading.', spanish: 'Tu identidad comienza con tu primera lectura.', french: 'Votre identité commence avec votre première lecture.', portugueseBrazil: 'Sua identidade começa com a primeira leitura.', turkish: 'Kimliğin ilk okumanla başlıyor.', italian: 'La tua identità comincia con la prima lettura.', german: 'Deine Identität beginnt mit deiner ersten Legung.')];
    }
    final result = <String>[
      localized(language,
          english: '$records readings are shaping this identity.', spanish: '$records lecturas están dando forma a esta identidad.', french: '$records lectures façonnent cette identité.', portugueseBrazil: '$records leituras estão moldando esta identidade.', turkish: '$records okuma bu kimliği şekillendiriyor.', italian: '$records letture stanno plasmando questa identità.', german: '$records Legungen formen diese Identität.')
    ];
    if (streak >= 3) {
      result.add(localized(language,
          english: 'A $streak-day rhythm shows sustained intention.', spanish: 'Un ritmo de $streak días muestra una intención constante.', french: 'Un rythme de $streak jours montre une intention durable.', portugueseBrazil: 'Um ritmo de $streak dias mostra intenção consistente.', turkish: '$streak günlük ritim sürdürülen bir niyeti gösteriyor.', italian: 'Un ritmo di $streak giorni mostra un’intenzione costante.', german: 'Ein Rhythmus von $streak Tagen zeigt beständige Absicht.'));
    }
    if (completedArcanaDays >= 3) {
      result.add(localized(language,
          english: '$completedArcanaDays Arcana chapters deepen your profile.', spanish: '$completedArcanaDays capítulos de los Arcanos profundizan tu perfil.', french: '$completedArcanaDays chapitres des Arcanes approfondissent votre profil.', portugueseBrazil: '$completedArcanaDays capítulos dos Arcanos aprofundam seu perfil.', turkish: '$completedArcanaDays Arkana bölümü profilini derinleştiriyor.', italian: '$completedArcanaDays capitoli degli Arcani approfondiscono il tuo profilo.', german: '$completedArcanaDays Arkana-Kapitel vertiefen dein Profil.'));
    }
    result.add(switch (primary) {
      MysticArchetype.seeker => localized(language, english: 'Curiosity is your strongest recurring signal.', spanish: 'La curiosidad es tu señal recurrente más fuerte.', french: 'La curiosité est votre signal récurrent le plus fort.', portugueseBrazil: 'A curiosidade é seu sinal recorrente mais forte.', turkish: 'Merak, tekrar eden en güçlü sinyalin.', italian: 'La curiosità è il tuo segnale ricorrente più forte.', german: 'Neugier ist dein stärkstes wiederkehrendes Signal.'),
      MysticArchetype.alchemist => localized(language, english: 'Transformation themes repeat in your choices.', spanish: 'Los temas de transformación se repiten en tus decisiones.', french: 'Les thèmes de transformation reviennent dans vos choix.', portugueseBrazil: 'Temas de transformação se repetem nas suas escolhas.', turkish: 'Dönüşüm temaları seçimlerinde tekrar ediyor.', italian: 'I temi di trasformazione si ripetono nelle tue scelte.', german: 'Themen der Veränderung wiederholen sich in deinen Entscheidungen.'),
      MysticArchetype.sage => localized(language, english: 'Long-range reflection is central to your path.', spanish: 'La reflexión a largo plazo es central en tu camino.', french: 'La réflexion à long terme est au cœur de votre chemin.', portugueseBrazil: 'A reflexão de longo prazo é central no seu caminho.', turkish: 'Uzun vadeli düşünme yolunun merkezinde.', italian: 'La riflessione a lungo termine è centrale nel tuo percorso.', german: 'Langfristige Reflexion steht im Zentrum deines Weges.'),
      MysticArchetype.guardian => localized(language, english: 'Grounded action defines your current chapter.', spanish: 'La acción con los pies en la tierra define tu capítulo actual.', french: 'L’action concrète définit votre chapitre actuel.', portugueseBrazil: 'A ação prática define seu capítulo atual.', turkish: 'Ayakları yere basan eylem şu anki bölümünü tanımlıyor.', italian: 'L’azione concreta definisce il tuo capitolo attuale.', german: 'Bodenständiges Handeln prägt dein aktuelles Kapitel.'),
      MysticArchetype.visionary => localized(language, english: 'Hope and connection shape your direction.', spanish: 'La esperanza y la conexión dan forma a tu dirección.', french: 'L’espoir et les liens façonnent votre direction.', portugueseBrazil: 'Esperança e conexão moldam sua direção.', turkish: 'Umut ve bağ kurma yönünü şekillendiriyor.', italian: 'Speranza e connessione plasmano la tua direzione.', german: 'Hoffnung und Verbundenheit formen deine Richtung.'),
    });
    return result.take(3).toList(growable: false);
  }
}
