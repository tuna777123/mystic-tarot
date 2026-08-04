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
  final int freeReadingsLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = _actionContent(
      language,
      snapshot.nextAction.type,
      streak: streak,
      mirrorDueCount: mirrorDueCount,
      completedArcanaDays: completedArcanaDays,
      freeReadingsLeft: freeReadingsLeft,
    );
    final continuity = _returnMessage(language, snapshot.returnState, streak);

    return Semantics(
      button: true,
      label: '${content.title}. ${content.cta}',
      child: Container(
        key: const ValueKey('mystic-next-step-card'),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF30234A), Color(0xFF171221)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: MysticColors.lavender.withValues(alpha: .28),
          ),
          boxShadow: [
            BoxShadow(
              color: MysticColors.violet.withValues(alpha: .10),
              blurRadius: 24,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: MysticColors.gold.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          content.icon,
                          color: MysticColors.gold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _copy(
                                language,
                                en: 'YOUR NEXT STEP',
                                es: 'TU SIGUIENTE PASO',
                                fr: 'VOTRE PROCHAINE ÉTAPE',
                                pt: 'SEU PRÓXIMO PASSO',
                                tr: 'SIRADAKİ ADIMIN',
                              ),
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                color: MysticColors.gold,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _stageLabel(language, snapshot.stage),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_outward_rounded,
                        color: MysticColors.lavender,
                        size: 19,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    continuity,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MysticColors.lavender,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    content.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 19,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    content.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MysticColors.mist,
                      height: 1.35,
                    ),
                  ),
                  if (snapshot.stage == MysticGrowthStage.activated) ...[
                    const SizedBox(height: 14),
                    LaunchContinuityTimeline(language: language, compact: true),
                    const SizedBox(height: 11),
                    PrivateByDesignCard(language: language, compact: true),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: MysticColors.gold.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: MysticColors.gold.withValues(alpha: .25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            content.cta,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              color: MysticColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
  required int freeReadingsLeft,
}) => switch (type) {
  MysticNextActionType.firstReading => _NextStepContent(
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
      en: 'Begin with one focused question. Your private history becomes more useful with every return.',
      es: 'Empieza con una pregunta concreta. Tu historial privado se vuelve más útil con cada regreso.',
      fr: 'Commencez par une question précise. Votre historique privé devient plus utile à chaque retour.',
      pt: 'Comece com uma pergunta focada. Seu histórico privado fica mais útil a cada retorno.',
      tr: 'Tek ve net bir soruyla başla. Özel geçmişin her dönüşünde daha anlamlı hale gelir.',
    ),
    cta: _copy(
      language,
      en: 'START MY FIRST READING',
      es: 'INICIAR MI PRIMERA LECTURA',
      fr: 'COMMENCER MA PREMIÈRE LECTURE',
      pt: 'INICIAR MINHA PRIMEIRA LEITURA',
      tr: 'İLK OKUMAMI BAŞLAT',
    ),
  ),
  MysticNextActionType.dailyReading => _NextStepContent(
    icon: Icons.wb_twilight_rounded,
    title: streak > 0
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
          ),
    body: _copy(
      language,
      en: 'A short daily return keeps your pattern map alive without turning reflection into work.',
      es: 'Un regreso breve mantiene vivo tu mapa de patrones sin convertir la reflexión en una tarea.',
      fr: 'Un bref retour quotidien garde votre carte de tendances vivante sans transformer la réflexion en corvée.',
      pt: 'Um retorno breve mantém seu mapa de padrões vivo sem transformar a reflexão em obrigação.',
      tr: 'Kısa bir günlük dönüş, düşünmeyi işe çevirmeden örüntü haritanı canlı tutar.',
    ),
    cta: _copy(
      language,
      en: 'REVEAL TODAY’S CARD',
      es: 'REVELAR LA CARTA DE HOY',
      fr: 'RÉVÉLER LA CARTE DU JOUR',
      pt: 'REVELAR A CARTA DE HOJE',
      tr: 'BUGÜNÜN KARTINI AÇ',
    ),
  ),
  MysticNextActionType.mirrorCheckIn => _NextStepContent(
    icon: Icons.compare_arrows_rounded,
    title: _copy(
      language,
      en: mirrorDueCount == 1
          ? 'One reading is ready for reality'
          : '$mirrorDueCount readings are ready for reality',
      es: mirrorDueCount == 1
          ? 'Una lectura está lista para contrastarse'
          : '$mirrorDueCount lecturas están listas para contrastarse',
      fr: mirrorDueCount == 1
          ? 'Une lecture est prête à être confrontée au réel'
          : '$mirrorDueCount lectures sont prêtes à être confrontées au réel',
      pt: mirrorDueCount == 1
          ? 'Uma leitura está pronta para a realidade'
          : '$mirrorDueCount leituras estão prontas para a realidade',
      tr: mirrorDueCount == 1
          ? 'Bir okuma gerçekle karşılaşmaya hazır'
          : '$mirrorDueCount okuma gerçekle karşılaşmaya hazır',
    ),
    body: _copy(
      language,
      en: 'Close the loop after 24 hours and record what actually changed, without scoring your future.',
      es: 'Cierra el ciclo después de 24 horas y registra qué cambió realmente, sin puntuar tu futuro.',
      fr: 'Bouclez la réflexion après 24 heures et notez ce qui a réellement changé, sans noter votre avenir.',
      pt: 'Feche o ciclo após 24 horas e registre o que realmente mudou, sem dar nota ao seu futuro.',
      tr: '24 saat sonra döngüyü kapat ve geleceğine puan vermeden gerçekte neyin değiştiğini kaydet.',
    ),
    cta: _copy(
      language,
      en: 'COMPLETE MY MIRROR',
      es: 'COMPLETAR MI ESPEJO',
      fr: 'COMPLÉTER MON MIROIR',
      pt: 'COMPLETAR MEU ESPELHO',
      tr: 'MIRROR KONTROLÜNÜ TAMAMLA',
    ),
  ),
  MysticNextActionType.continueJourney => _NextStepContent(
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
      en: '${22 - completedArcanaDays} chapters remain in your personal path. Continue only when today has room for it.',
      es: 'Quedan ${22 - completedArcanaDays} capítulos en tu camino personal. Continúa solo si hoy tienes espacio.',
      fr: 'Il reste ${22 - completedArcanaDays} chapitres sur votre parcours personnel. Continuez seulement si vous avez de la place aujourd’hui.',
      pt: 'Restam ${22 - completedArcanaDays} capítulos no seu caminho pessoal. Continue apenas se houver espaço hoje.',
      tr: 'Kişisel yolunda ${22 - completedArcanaDays} bölüm kaldı. Yalnızca bugün gerçekten yer varsa devam et.',
    ),
    cta: _copy(
      language,
      en: 'CONTINUE MY PATH',
      es: 'CONTINUAR MI CAMINO',
      fr: 'CONTINUER MON PARCOURS',
      pt: 'CONTINUAR MEU CAMINHO',
      tr: 'YOLUMA DEVAM ET',
    ),
  ),
  MysticNextActionType.reviewPattern => _NextStepContent(
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
      en: 'Compare the symbols, emotions, and choices that keep returning across your private history.',
      es: 'Compara los símbolos, emociones y decisiones que se repiten en tu historial privado.',
      fr: 'Comparez les symboles, émotions et choix qui reviennent dans votre historique privé.',
      pt: 'Compare símbolos, emoções e escolhas que continuam voltando no seu histórico privado.',
      tr: 'Özel geçmişinde tekrar tekrar dönen sembolleri, duyguları ve seçimleri karşılaştır.',
    ),
    cta: _copy(
      language,
      en: 'VIEW MY PATTERN',
      es: 'VER MI PATRÓN',
      fr: 'VOIR MA TENDANCE',
      pt: 'VER MEU PADRÃO',
      tr: 'ÖRÜNTÜMÜ GÖR',
    ),
  ),
  MysticNextActionType.explorePremiumSpread => _NextStepContent(
    icon: freeReadingsLeft == 0
        ? Icons.workspace_premium_rounded
        : Icons.grid_view_rounded,
    title: freeReadingsLeft == 0
        ? _copy(
            language,
            en: 'Go deeper when the simple answer is not enough',
            es: 'Profundiza cuando una respuesta simple no sea suficiente',
            fr: 'Allez plus loin quand une réponse simple ne suffit pas',
            pt: 'Aprofunde quando uma resposta simples não for suficiente',
            tr: 'Basit cevap yetmediğinde daha derine in',
          )
        : _copy(
            language,
            en: 'Ask the question beneath the question',
            es: 'Haz la pregunta que está debajo de la pregunta',
            fr: 'Posez la question derrière la question',
            pt: 'Faça a pergunta por trás da pergunta',
            tr: 'Sorunun altındaki soruyu sor',
          ),
    body: freeReadingsLeft == 0
        ? _copy(
            language,
            en: 'Your free deep readings are complete today. Mystic Plus can continue the same private story.',
            es: 'Tus lecturas profundas gratuitas de hoy terminaron. Mystic Plus puede continuar la misma historia privada.',
            fr: 'Vos lectures approfondies gratuites sont terminées pour aujourd’hui. Mystic Plus peut poursuivre la même histoire privée.',
            pt: 'Suas leituras profundas gratuitas terminaram hoje. O Mystic Plus pode continuar a mesma história privada.',
            tr: 'Bugünkü ücretsiz derin okumaların tamamlandı. Mystic Plus aynı özel hikâyeyi sürdürebilir.',
          )
        : _copy(
            language,
            en: 'Choose a deeper spread when one card cannot hold the full shape of the decision.',
            es: 'Elige una tirada más profunda cuando una carta no pueda contener toda la decisión.',
            fr: 'Choisissez un tirage plus approfondi lorsqu’une carte ne suffit pas à contenir toute la décision.',
            pt: 'Escolha uma abertura mais profunda quando uma carta não comportar toda a decisão.',
            tr: 'Tek kart kararın tamamını taşıyamadığında daha derin bir açılım seç.',
          ),
    cta: freeReadingsLeft == 0
        ? _copy(
            language,
            en: 'EXPLORE MYSTIC PLUS',
            es: 'EXPLORAR MYSTIC PLUS',
            fr: 'DÉCOUVRIR MYSTIC PLUS',
            pt: 'EXPLORAR MYSTIC PLUS',
            tr: 'MYSTIC PLUS’I KEŞFET',
          )
        : _copy(
            language,
            en: 'EXPLORE DEEP READINGS',
            es: 'EXPLORAR LECTURAS PROFUNDAS',
            fr: 'EXPLORER LES TIRAGES APPROFONDIS',
            pt: 'EXPLORAR LEITURAS PROFUNDAS',
            tr: 'DERİN OKUMALARI KEŞFET',
          ),
  ),
};

String _returnMessage(
  MysticLanguage language,
  MysticReturnState state,
  int streak,
) => switch (state) {
  MysticReturnState.firstVisit => _copy(
    language,
    en: 'Your path begins with one honest question.',
    es: 'Tu camino comienza con una pregunta honesta.',
    fr: 'Votre parcours commence par une question sincère.',
    pt: 'Seu caminho começa com uma pergunta honesta.',
    tr: 'Yolun dürüst bir soruyla başlıyor.',
  ),
  MysticReturnState.activeToday => _copy(
    language,
    en: 'Today’s signal is already part of your story.',
    es: 'La señal de hoy ya forma parte de tu historia.',
    fr: 'Le signal du jour fait déjà partie de votre histoire.',
    pt: 'O sinal de hoje já faz parte da sua história.',
    tr: 'Bugünün işareti artık hikâyenin bir parçası.',
  ),
  MysticReturnState.returnedNextDay => _copy(
    language,
    en: 'You returned before yesterday’s insight went quiet.',
    es: 'Volviste antes de que la reflexión de ayer se apagara.',
    fr: 'Vous êtes revenu avant que l’éclairage d’hier ne s’efface.',
    pt: 'Você voltou antes que a percepção de ontem se apagasse.',
    tr: 'Dünün içgörüsü sessizleşmeden geri döndün.',
  ),
  MysticReturnState.continuingStreak => _copy(
    language,
    en: 'Your $streak-day practice is building real continuity.',
    es: 'Tu práctica de $streak días está creando continuidad real.',
    fr: 'Votre pratique de $streak jours crée une vraie continuité.',
    pt: 'Sua prática de $streak dias está criando continuidade real.',
    tr: '$streak günlük pratiğin gerçek bir devamlılık kuruyor.',
  ),
  MysticReturnState.resumedPath => _copy(
    language,
    en: 'Your path kept its place. Continue from where you left it.',
    es: 'Tu camino guardó tu lugar. Continúa desde donde lo dejaste.',
    fr: 'Votre parcours a gardé votre place. Reprenez là où vous vous êtes arrêté.',
    pt: 'Seu caminho guardou seu lugar. Continue de onde parou.',
    tr: 'Yolun yerini korudu. Bıraktığın yerden devam et.',
  ),
};

String _stageLabel(MysticLanguage language, MysticGrowthStage stage) =>
    switch (stage) {
      MysticGrowthStage.newUser => _copy(
        language,
        en: 'A private beginning',
        es: 'Un comienzo privado',
        fr: 'Un début privé',
        pt: 'Um começo privado',
        tr: 'Özel bir başlangıç',
      ),
      MysticGrowthStage.activated => _copy(
        language,
        en: 'Your history is taking shape',
        es: 'Tu historial está tomando forma',
        fr: 'Votre historique prend forme',
        pt: 'Seu histórico está tomando forma',
        tr: 'Geçmişin şekilleniyor',
      ),
      MysticGrowthStage.engaged => _copy(
        language,
        en: 'Your signals are connecting',
        es: 'Tus señales se están conectando',
        fr: 'Vos signaux se relient',
        pt: 'Seus sinais estão se conectando',
        tr: 'İşaretlerin birbirine bağlanıyor',
      ),
      MysticGrowthStage.habit => _copy(
        language,
        en: 'A reflective rhythm is forming',
        es: 'Se está formando un ritmo de reflexión',
        fr: 'Un rythme de réflexion se forme',
        pt: 'Um ritmo de reflexão está se formando',
        tr: 'Düşünsel bir ritim oluşuyor',
      ),
      MysticGrowthStage.powerUser => _copy(
        language,
        en: 'Your living map is mature',
        es: 'Tu mapa vivo está maduro',
        fr: 'Votre carte vivante a mûri',
        pt: 'Seu mapa vivo amadureceu',
        tr: 'Yaşayan haritan olgunlaştı',
      ),
    };

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
