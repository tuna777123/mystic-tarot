import 'package:flutter/material.dart';

import 'flagship.dart';
import 'growth_engine.dart';
import 'launch_differentiation.dart';
import 'theme.dart';

class MysticNextStepCard extends StatelessWidget {
  const MysticNextStepCard({
    required this.snapshot,
    required this.language,
    required this.streak,
    required this.mirrorDueCount,
    required this.completedArcanaDays,
    required this.freeReadingsLeft,
    required this.onTap,
    super.key,
  });

  final MysticGrowthSnapshot snapshot;
  final MysticLanguage language;
  final int streak;
  final int mirrorDueCount;
  final int completedArcanaDays;

  /// Compatibility field retained because HomeScreen still passes the former
  /// free allowance. The current ad-supported product does not visually gate
  /// this card or describe any action as a paid unlock.
  final int freeReadingsLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final action = _actionContent(
      language,
      snapshot.nextAction.type,
      streak: streak,
      mirrorDueCount: mirrorDueCount,
      completedArcanaDays: completedArcanaDays,
    );
    final continuity = _returnMessage(language, snapshot.returnState, streak);
    final maturity = snapshot.premiumValueScore.clamp(0, 100);
    final isMirror =
        snapshot.nextAction.type == MysticNextActionType.mirrorCheckIn;

    return Semantics(
      button: true,
      label: '${action.title}. ${action.cta}',
      child: Container(
        key: const ValueKey('mystic-next-step-card'),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isMirror
                ? const [
                    Color(0xFF51366F),
                    Color(0xFF251A38),
                    Color(0xFF15101E),
                  ]
                : const [
                    Color(0xFF30234A),
                    Color(0xFF1A1428),
                    Color(0xFF11101A),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isMirror
                ? MysticColors.gold.withValues(alpha: .48)
                : MysticColors.lavender.withValues(alpha: .24),
          ),
          boxShadow: [
            BoxShadow(
              color: (isMirror ? MysticColors.gold : MysticColors.violet)
                  .withValues(alpha: .10),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NextStepHeader(
                    language: language,
                    stage: snapshot.stage,
                    isMirror: isMirror,
                    icon: action.icon,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    continuity,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MysticColors.lavender,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    action.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    action.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MysticColors.mist,
                      height: 1.38,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _EvidenceMaturity(
                    language: language,
                    maturity: maturity,
                    hasVisiblePattern: snapshot.hasVisiblePattern,
                    mirrorDueCount: mirrorDueCount,
                  ),
                  if (snapshot.stage == MysticGrowthStage.activated) ...[
                    const SizedBox(height: 14),
                    LaunchContinuityTimeline(
                      language: language,
                      compact: true,
                      showTitle: false,
                    ),
                  ],
                  const SizedBox(height: 14),
                  _ActionButtonLabel(label: action.cta),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextStepHeader extends StatelessWidget {
  const _NextStepHeader({
    required this.language,
    required this.stage,
    required this.isMirror,
    required this.icon,
  });

  final MysticLanguage language;
  final MysticGrowthStage stage;
  final bool isMirror;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final eyebrow = _copy(
      language,
      en: isMirror ? 'REALITY CHECK READY' : 'YOUR NEXT STEP',
      es: isMirror ? 'COMPROBACIÓN LISTA' : 'TU SIGUIENTE PASO',
      fr: isMirror ? 'BILAN RÉEL PRÊT' : 'VOTRE PROCHAINE ÉTAPE',
      pt: isMirror ? 'CHECK-IN REAL PRONTO' : 'SEU PRÓXIMO PASSO',
      tr: isMirror ? 'GERÇEKLİK KONTROLÜ HAZIR' : 'SIRADAKİ ADIMIN',
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MysticColors.gold.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: MysticColors.gold.withValues(alpha: .17)),
          ),
          child: Icon(icon, color: MysticColors.gold, size: 22),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _stageLabel(language, stage),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MysticColors.lavender,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_outward_rounded,
          color: MysticColors.lavender,
          size: 19,
        ),
      ],
    );
  }
}

class _ActionButtonLabel extends StatelessWidget {
  const _ActionButtonLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: MysticColors.gold.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Arial',
                color: MysticColors.goldSoft,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: .15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_rounded,
            color: MysticColors.gold,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _EvidenceMaturity extends StatelessWidget {
  const _EvidenceMaturity({
    required this.language,
    required this.maturity,
    required this.hasVisiblePattern,
    required this.mirrorDueCount,
  });

  final MysticLanguage language;
  final int maturity;
  final bool hasVisiblePattern;
  final int mirrorDueCount;

  @override
  Widget build(BuildContext context) {
    final status = _status();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: .065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _copy(
                    language,
                    en: 'PRIVATE EVIDENCE MEMORY',
                    es: 'MEMORIA DE EVIDENCIA PRIVADA',
                    fr: 'MÉMOIRE D’INDICES PRIVÉS',
                    pt: 'MEMÓRIA DE EVIDÊNCIA PRIVADA',
                    tr: 'ÖZEL KANIT HAFIZASI',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: MysticColors.muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .85,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: MysticColors.gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: maturity / 100,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: .07),
              valueColor: const AlwaysStoppedAnimation<Color>(
                MysticColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _status() {
    if (mirrorDueCount > 0) {
      return _copy(
        language,
        en: mirrorDueCount == 1
            ? '1 check-in ready'
            : '$mirrorDueCount check-ins ready',
        es: mirrorDueCount == 1
            ? '1 revisión lista'
            : '$mirrorDueCount revisiones listas',
        fr: mirrorDueCount == 1
            ? '1 bilan prêt'
            : '$mirrorDueCount bilans prêts',
        pt: mirrorDueCount == 1
            ? '1 check-in pronto'
            : '$mirrorDueCount check-ins prontos',
        tr: '$mirrorDueCount kontrol hazır',
      );
    }
    if (hasVisiblePattern) {
      return _copy(
        language,
        en: 'Pattern visible',
        es: 'Patrón visible',
        fr: 'Tendance visible',
        pt: 'Padrão visível',
        tr: 'Örüntü görünür',
      );
    }
    return _copy(
      language,
      en: 'Evidence is building',
      es: 'La evidencia crece',
      fr: 'Les indices s’accumulent',
      pt: 'As evidências crescem',
      tr: 'Kanıt birikiyor',
    );
  }
}

class _NextStepContent {
  const _NextStepContent({
    required this.icon,
    required this.title,
    required this.body,
    required this.cta,
  });

  final IconData icon;
  final String title;
  final String body;
  final String cta;
}

_NextStepContent _actionContent(
  MysticLanguage language,
  MysticNextActionType type, {
  required int streak,
  required int mirrorDueCount,
  required int completedArcanaDays,
}) {
  switch (type) {
    case MysticNextActionType.firstReading:
      return _NextStepContent(
        icon: Icons.auto_awesome_rounded,
        title: _copy(
          language,
          en: 'Your first signal is waiting',
          es: 'Tu primera señal está esperando',
          fr: 'Votre premier signal vous attend',
          pt: 'Seu primeiro sinal está esperando',
          tr: 'İlk işaretin seni bekliyor',
        ),
        body: _copy(
          language,
          en: 'Start with one focused question. The useful part is not a fortune score — it is what you can compare with real life tomorrow.',
          es: 'Empieza con una pregunta concreta. Lo útil no es una puntuación de destino, sino lo que mañana podrás comparar con la vida real.',
          fr: 'Commencez par une question précise. L’utile n’est pas un score de destin, mais ce que vous pourrez comparer au réel demain.',
          pt: 'Comece com uma pergunta focada. O valor não está em uma nota do destino, mas no que você poderá comparar com a vida real amanhã.',
          tr: 'Tek ve net bir soruyla başla. Değer kehanet puanında değil; yarın gerçek hayatla karşılaştırabileceğin şeyde.',
        ),
        cta: _copy(
          language,
          en: 'START MY FIRST READING',
          es: 'INICIAR MI PRIMERA LECTURA',
          fr: 'COMMENCER MON PREMIER TIRAGE',
          pt: 'INICIAR MINHA PRIMEIRA LEITURA',
          tr: 'İLK OKUMAMI BAŞLAT',
        ),
      );
    case MysticNextActionType.dailyReading:
      final title = streak > 0
          ? _copy(
              language,
              en: 'Protect your $streak-day rhythm',
              es: 'Protege tu ritmo de $streak días',
              fr: 'Protégez votre rythme de $streak jours',
              pt: 'Proteja seu ritmo de $streak dias',
              tr: '$streak günlük ritmini koru',
            )
          : _copy(
              language,
              en: 'Open today’s guidance',
              es: 'Abre la guía de hoy',
              fr: 'Ouvrez la guidance du jour',
              pt: 'Abra a orientação de hoje',
              tr: 'Bugünün rehberliğini aç',
            );
      return _NextStepContent(
        icon: Icons.wb_twilight_rounded,
        title: title,
        body: _copy(
          language,
          en: 'A short daily return keeps your private pattern history alive without turning reflection into another task.',
          es: 'Un regreso breve mantiene vivo tu historial privado de patrones sin convertir la reflexión en otra tarea.',
          fr: 'Un bref retour quotidien garde votre historique privé vivant sans transformer la réflexion en corvée.',
          pt: 'Um retorno breve mantém seu histórico privado de padrões vivo sem transformar a reflexão em obrigação.',
          tr: 'Kısa bir günlük dönüş, düşünmeyi işe çevirmeden özel örüntü geçmişini canlı tutar.',
        ),
        cta: _copy(
          language,
          en: 'REVEAL TODAY’S CARD',
          es: 'REVELAR LA CARTA DE HOY',
          fr: 'RÉVÉLER LA CARTE DU JOUR',
          pt: 'REVELAR A CARTA DE HOJE',
          tr: 'BUGÜNÜN KARTINI AÇ',
        ),
      );
    case MysticNextActionType.mirrorCheckIn:
      return _NextStepContent(
        icon: Icons.compare_arrows_rounded,
        title: _mirrorTitle(language, mirrorDueCount),
        body: _copy(
          language,
          en: 'Close the 24-hour loop before adding more input. Record what actually changed — not whether tarot was “right.”',
          es: 'Cierra el ciclo de 24 horas antes de añadir más señales. Registra qué cambió de verdad, no si el tarot “acertó”.',
          fr: 'Fermez la boucle de 24 heures avant d’ajouter un nouveau signal. Notez ce qui a réellement changé, pas si le tarot avait « raison ».',
          pt: 'Feche o ciclo de 24 horas antes de adicionar mais sinais. Registre o que realmente mudou, não se o tarô “acertou”.',
          tr: 'Yeni bir işaret eklemeden önce 24 saatlik döngüyü kapat. Tarotun “doğru çıkmasını” değil, gerçekte neyin değiştiğini kaydet.',
        ),
        cta: _copy(
          language,
          en: 'COMPLETE MY MYSTIC MIRROR',
          es: 'COMPLETAR MI MYSTIC MIRROR',
          fr: 'COMPLÉTER MON MYSTIC MIRROR',
          pt: 'COMPLETAR MEU MYSTIC MIRROR',
          tr: 'MYSTIC MIRROR KONTROLÜNÜ TAMAMLA',
        ),
      );
    case MysticNextActionType.continueJourney:
      final remaining = 22 - completedArcanaDays;
      return _NextStepContent(
        icon: Icons.route_rounded,
        title: _copy(
          language,
          en: 'Your next Arcana chapter is ready',
          es: 'Tu próximo capítulo de Arcanos está listo',
          fr: 'Votre prochain chapitre des Arcanes est prêt',
          pt: 'Seu próximo capítulo dos Arcanos está pronto',
          tr: 'Sıradaki Arkana bölümün hazır',
        ),
        body: _copy(
          language,
          en: '$remaining chapters remain. Continue when today has room for another reflection, not just because it is available.',
          es: 'Quedan $remaining capítulos. Continúa cuando hoy tengas espacio para otra reflexión, no solo porque esté disponible.',
          fr: 'Il reste $remaining chapitres. Continuez lorsque vous avez vraiment de la place pour une nouvelle réflexion.',
          pt: 'Restam $remaining capítulos. Continue quando houver espaço real para outra reflexão.',
          tr: '$remaining bölüm kaldı. Sadece açık olduğu için değil, bugün gerçekten yer varsa devam et.',
        ),
        cta: _copy(
          language,
          en: 'CONTINUE MY PATH',
          es: 'CONTINUAR MI CAMINO',
          fr: 'CONTINUER MON PARCOURS',
          pt: 'CONTINUAR MEU CAMINHO',
          tr: 'YOLUMA DEVAM ET',
        ),
      );
    case MysticNextActionType.reviewPattern:
      return _NextStepContent(
        icon: Icons.insights_rounded,
        title: _copy(
          language,
          en: 'A repeating pattern is becoming visible',
          es: 'Un patrón repetido empieza a hacerse visible',
          fr: 'Une tendance récurrente devient visible',
          pt: 'Um padrão recorrente está ficando visível',
          tr: 'Tekrarlanan bir örüntü görünür oluyor',
        ),
        body: _copy(
          language,
          en: 'This is earned insight from your own history. Compare the cards, emotions, and choices that keep returning.',
          es: 'Esta información nace de tu propio historial. Compara las cartas, emociones y decisiones que siguen volviendo.',
          fr: 'Cet aperçu vient de votre propre historique. Comparez les cartes, émotions et choix qui reviennent.',
          pt: 'Esse insight vem do seu próprio histórico. Compare as cartas, emoções e escolhas que continuam voltando.',
          tr: 'Bu, kendi geçmişinden kazanılmış bir içgörü. Tekrar dönen kartları, duyguları ve seçimleri karşılaştır.',
        ),
        cta: _copy(
          language,
          en: 'VIEW MY PATTERN',
          es: 'VER MI PATRÓN',
          fr: 'VOIR MA TENDANCE',
          pt: 'VER MEU PADRÃO',
          tr: 'ÖRÜNTÜMÜ GÖR',
        ),
      );
    case MysticNextActionType.explorePremiumSpread:
      return _NextStepContent(
        icon: Icons.grid_view_rounded,
        title: _copy(
          language,
          en: 'Go deeper only when the question needs it',
          es: 'Profundiza solo cuando la pregunta lo necesite',
          fr: 'Allez plus loin seulement si la question le demande',
          pt: 'Aprofunde só quando a pergunta pedir',
          tr: 'Soru gerçekten gerektiriyorsa daha derine in',
        ),
        body: _copy(
          language,
          en: 'Use a larger spread for context, not because the app needs another tap. Every reading remains part of the same private evidence loop.',
          es: 'Usa una tirada mayor para ganar contexto, no porque la app necesite otro toque. Cada lectura sigue formando parte del mismo ciclo privado.',
          fr: 'Utilisez un tirage plus large pour le contexte, pas pour multiplier les interactions. Chaque tirage reste dans la même boucle privée.',
          pt: 'Use uma abertura maior por contexto, não porque o app precise de outro toque. Toda leitura continua no mesmo ciclo privado.',
          tr: 'Daha geniş açılımı sadece bağlam gerektiğinde kullan. Her okuma aynı özel kanıt döngüsünün parçası olarak kalır.',
        ),
        cta: _copy(
          language,
          en: 'EXPLORE DEEP READINGS',
          es: 'EXPLORAR LECTURAS PROFUNDAS',
          fr: 'EXPLORER LES TIRAGES PROFONDS',
          pt: 'EXPLORAR LEITURAS PROFUNDAS',
          tr: 'DERİN OKUMALARI KEŞFET',
        ),
      );
  }
}

String _mirrorTitle(MysticLanguage language, int mirrorDueCount) {
  final multiple = mirrorDueCount > 1;
  return _copy(
    language,
    en: multiple
        ? '$mirrorDueCount readings are ready for reality'
        : 'Yesterday is ready for reality',
    es: multiple
        ? '$mirrorDueCount lecturas están listas para contrastarse'
        : 'Ayer está listo para contrastarse',
    fr: multiple
        ? '$mirrorDueCount tirages sont prêts à être confrontés au réel'
        : 'Hier est prêt à être confronté au réel',
    pt: multiple
        ? '$mirrorDueCount leituras estão prontas para a realidade'
        : 'Ontem está pronto para a realidade',
    tr: multiple
        ? '$mirrorDueCount okuma gerçekle karşılaşmaya hazır'
        : 'Dünün okuması gerçekle karşılaşmaya hazır',
  );
}

String _stageLabel(MysticLanguage language, MysticGrowthStage stage) {
  switch (stage) {
    case MysticGrowthStage.newUser:
      return _copy(
        language,
        en: 'Start with one honest signal',
        es: 'Empieza con una señal honesta',
        fr: 'Commencez par un signal honnête',
        pt: 'Comece com um sinal honesto',
        tr: 'Tek bir dürüst işaretle başla',
      );
    case MysticGrowthStage.activated:
      return _copy(
        language,
        en: 'Your first evidence loop is forming',
        es: 'Tu primer ciclo de evidencia se está formando',
        fr: 'Votre première boucle d’indices se forme',
        pt: 'Seu primeiro ciclo de evidências está se formando',
        tr: 'İlk kanıt döngün oluşuyor',
      );
    case MysticGrowthStage.engaged:
      return _copy(
        language,
        en: 'Your private history is gaining context',
        es: 'Tu historial privado está ganando contexto',
        fr: 'Votre historique privé gagne en contexte',
        pt: 'Seu histórico privado está ganhando contexto',
        tr: 'Özel geçmişin bağlam kazanıyor',
      );
    case MysticGrowthStage.habit:
      return _copy(
        language,
        en: 'Your pattern memory is getting stronger',
        es: 'Tu memoria de patrones se fortalece',
        fr: 'Votre mémoire de tendances se renforce',
        pt: 'Sua memória de padrões está ficando mais forte',
        tr: 'Örüntü hafızan güçleniyor',
      );
    case MysticGrowthStage.powerUser:
      return _copy(
        language,
        en: 'Your evidence trail has real depth now',
        es: 'Tu historial de evidencia ya tiene profundidad',
        fr: 'Votre trace d’indices a maintenant de la profondeur',
        pt: 'Seu histórico de evidências já tem profundidade',
        tr: 'Kanıt geçmişin artık gerçek bir derinliğe sahip',
      );
  }
}

String _returnMessage(
  MysticLanguage language,
  MysticReturnState state,
  int streak,
) {
  switch (state) {
    case MysticReturnState.firstVisit:
      return _copy(
        language,
        en: 'One honest question is enough to begin.',
        es: 'Una pregunta honesta basta para empezar.',
        fr: 'Une question honnête suffit pour commencer.',
        pt: 'Uma pergunta honesta basta para começar.',
        tr: 'Başlamak için tek bir dürüst soru yeter.',
      );
    case MysticReturnState.activeToday:
      return _copy(
        language,
        en: 'Today is already in your private evidence trail.',
        es: 'Hoy ya forma parte de tu historial privado.',
        fr: 'Aujourd’hui fait déjà partie de votre trace privée.',
        pt: 'Hoje já faz parte do seu histórico privado.',
        tr: 'Bugün özel kanıt geçmişine çoktan eklendi.',
      );
    case MysticReturnState.returnedNextDay:
      return _copy(
        language,
        en: 'Perfect timing: yesterday can now meet reality.',
        es: 'Buen momento: ayer ya puede compararse con la realidad.',
        fr: 'Bon moment : hier peut maintenant rencontrer le réel.',
        pt: 'Boa hora: ontem já pode encontrar a realidade.',
        tr: 'Tam zamanı: dün artık gerçekle karşılaşabilir.',
      );
    case MysticReturnState.continuingStreak:
      return _copy(
        language,
        en: 'Your $streak-day rhythm is building continuity, not just a streak.',
        es: 'Tu ritmo de $streak días construye continuidad, no solo una racha.',
        fr: 'Votre rythme de $streak jours construit une continuité, pas seulement une série.',
        pt: 'Seu ritmo de $streak dias constrói continuidade, não só uma sequência.',
        tr: '$streak günlük ritmin sadece seri değil, süreklilik oluşturuyor.',
      );
    case MysticReturnState.resumedPath:
      return _copy(
        language,
        en: 'Nothing was lost. Your private history kept your place.',
        es: 'No se perdió nada. Tu historial privado guardó tu lugar.',
        fr: 'Rien n’est perdu. Votre historique privé a gardé votre place.',
        pt: 'Nada se perdeu. Seu histórico privado guardou seu lugar.',
        tr: 'Hiçbir şey kaybolmadı. Özel geçmişin yerini korudu.',
      );
  }
}

String _copy(
  MysticLanguage language, {
  required String en,
  required String es,
  required String fr,
  required String pt,
  required String tr,
}) {
  switch (language) {
    case MysticLanguage.turkish:
      return tr;
    case MysticLanguage.spanish:
      return es;
    case MysticLanguage.french:
      return fr;
    case MysticLanguage.portugueseBrazil:
      return pt;
    default:
      return en;
  }
}
