import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_locale.dart';
import 'flagship.dart';
import 'store_screenshot_manifest.dart';
import 'tarot_data.dart';
import 'theme.dart';

MysticLanguage storeScreenshotLanguage(String locale) => switch (locale) {
  'tr' => MysticLanguage.turkish,
  'es' => MysticLanguage.spanish,
  'fr' => MysticLanguage.french,
  'pt-BR' => MysticLanguage.portugueseBrazil,
  _ => MysticLanguage.english,
};

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

class StoreShowcaseApp extends StatelessWidget {
  const StoreShowcaseApp({
    required this.locale,
    required this.scene,
    super.key,
  });

  final String locale;
  final StoreScreenshotScene scene;

  @override
  Widget build(BuildContext context) {
    final language = storeScreenshotLanguage(locale);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: mysticLocale(language),
      supportedLocales: mysticSupportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildMysticTheme(),
      home: StoreShowcaseScreen(language: language, scene: scene),
    );
  }
}

class StoreShowcaseScreen extends StatelessWidget {
  const StoreShowcaseScreen({
    required this.language,
    required this.scene,
    super.key,
  });

  final MysticLanguage language;
  final StoreScreenshotScene scene;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        const Positioned.fill(child: _MysticBackdrop()),
        Positioned(
          left: -90,
          top: 80,
          child: _Aura(size: 240, color: MysticColors.violet),
        ),
        Positioned(
          right: -110,
          bottom: 40,
          child: _Aura(size: 270, color: MysticColors.gold),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            child: Column(
              children: [
                _BrandBar(language: language),
                const SizedBox(height: 14),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 382,
                        height: 760,
                        child: _SceneCanvas(
                          language: language,
                          scene: scene,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _MysticBackdrop extends StatelessWidget {
  const _MysticBackdrop();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF080711), Color(0xFF17102C), Color(0xFF090816)],
        stops: [0, .48, 1],
      ),
    ),
    child: CustomPaint(painter: _StarFieldPainter()),
  );
}

class _StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .16);
    for (var index = 0; index < 56; index++) {
      final x = (index * 83.0) % size.width;
      final y = (index * index * 17.0 + 41) % size.height;
      final radius = index % 7 == 0 ? 1.6 : .8;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Aura extends StatelessWidget {
  const _Aura({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .16),
            blurRadius: 95,
            spreadRadius: 24,
          ),
        ],
      ),
    ),
  );
}

class _BrandBar extends StatelessWidget {
  const _BrandBar({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: const LinearGradient(
            colors: [MysticColors.violet, Color(0xFF3A285E)],
          ),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .5)),
        ),
        child: const Text(
          '✦',
          style: TextStyle(color: MysticColors.gold, fontSize: 20),
        ),
      ),
      const SizedBox(width: 11),
      const Expanded(
        child: Text(
          'MYSTIC TAROT',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.1,
            color: MysticColors.mist,
          ),
        ),
      ),
      _Pill(label: language.code, icon: Icons.language_rounded),
    ],
  );
}

class _SceneCanvas extends StatelessWidget {
  const _SceneCanvas({required this.language, required this.scene});

  final MysticLanguage language;
  final StoreScreenshotScene scene;

  @override
  Widget build(BuildContext context) {
    final title = switch (scene) {
      StoreScreenshotScene.dailyGuidance => _copy(
        language,
        en: 'Your daily guidance, grounded in you.',
        tr: 'Günlük rehberliğin, sana göre şekillenir.',
        es: 'Tu guía diaria, conectada contigo.',
        fr: 'Votre guidance du jour, ancrée en vous.',
        pt: 'Sua orientação diária, conectada a você.',
      ),
      StoreScreenshotScene.explainableReading => _copy(
        language,
        en: 'See how every card shaped the reading.',
        tr: 'Her kartın yorumu nasıl şekillendirdiğini gör.',
        es: 'Descubre cómo cada carta dio forma a la lectura.',
        fr: 'Voyez comment chaque carte façonne la lecture.',
        pt: 'Veja como cada carta formou a leitura.',
      ),
      StoreScreenshotScene.mysticMirror => _copy(
        language,
        en: 'Return in 24 hours. Compare guidance with reality.',
        tr: '24 saat sonra dön. Rehberliği gerçekle karşılaştır.',
        es: 'Vuelve en 24 horas. Compara la guía con la realidad.',
        fr: 'Revenez dans 24 heures. Comparez au réel.',
        pt: 'Volte em 24 horas. Compare a orientação com a realidade.',
      ),
      StoreScreenshotScene.livingPath => _copy(
        language,
        en: 'Your symbols become a living map.',
        tr: 'Sembollerin yaşayan bir haritaya dönüşür.',
        es: 'Tus símbolos se convierten en un mapa vivo.',
        fr: 'Vos symboles deviennent une carte vivante.',
        pt: 'Seus símbolos se tornam um mapa vivo.',
      ),
      StoreScreenshotScene.mysticPlus => _copy(
        language,
        en: 'Go deeper without losing trust.',
        tr: 'Güveni kaybetmeden daha derine in.',
        es: 'Profundiza sin perder la confianza.',
        fr: 'Allez plus loin sans perdre confiance.',
        pt: 'Aprofunde-se sem perder a confiança.',
      ),
    };
    final subtitle = switch (scene) {
      StoreScreenshotScene.dailyGuidance => _copy(
        language,
        en: 'A focused ritual built around your intention, mood, and chosen deck.',
        tr: 'Niyetin, duygun ve seçtiğin desteye göre odaklanan bir ritüel.',
        es: 'Un ritual enfocado en tu intención, emoción y mazo elegido.',
        fr: 'Un rituel centré sur votre intention, votre émotion et votre jeu.',
        pt: 'Um ritual focado na sua intenção, emoção e baralho escolhido.',
      ),
      StoreScreenshotScene.explainableReading => _copy(
        language,
        en: 'Position, orientation, evidence, and next step stay visible.',
        tr: 'Konum, yön, kanıt ve sonraki adım görünür kalır.',
        es: 'La posición, orientación, evidencia y próximo paso son visibles.',
        fr: 'Position, orientation, indices et prochaine étape restent visibles.',
        pt: 'Posição, orientação, evidências e próximo passo ficam visíveis.',
      ),
      StoreScreenshotScene.mysticMirror => _copy(
        language,
        en: 'Close the loop instead of collecting endless predictions.',
        tr: 'Sonsuz tahmin biriktirmek yerine döngüyü kapat.',
        es: 'Cierra el ciclo en vez de acumular predicciones.',
        fr: 'Fermez la boucle au lieu d’accumuler des prédictions.',
        pt: 'Feche o ciclo em vez de acumular previsões.',
      ),
      StoreScreenshotScene.livingPath => _copy(
        language,
        en: 'Repeated cards, themes, and reflections reveal your private pattern.',
        tr: 'Tekrarlayan kartlar, temalar ve yansımalar özel örüntünü gösterir.',
        es: 'Cartas, temas y reflexiones repetidos revelan tu patrón privado.',
        fr: 'Cartes, thèmes et retours répétés révèlent votre motif privé.',
        pt: 'Cartas, temas e reflexões repetidas revelam seu padrão privado.',
      ),
      StoreScreenshotScene.mysticPlus => _copy(
        language,
        en: 'Deep readings and private intelligence, with official store pricing.',
        tr: 'Derin okumalar ve özel içgörüler; resmi mağaza fiyatlarıyla.',
        es: 'Lecturas profundas e inteligencia privada con precio oficial.',
        fr: 'Lectures profondes et intelligence privée, au tarif officiel.',
        pt: 'Leituras profundas e inteligência privada com preço oficial.',
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: _sceneLabel(language, scene)),
        const SizedBox(height: 10),
        Text(
          title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 34,
            height: 1.04,
            fontWeight: FontWeight.w700,
            color: MysticColors.mist,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 15,
            height: 1.42,
            color: MysticColors.muted,
          ),
        ),
        const SizedBox(height: 22),
        Expanded(child: _sceneBody()),
        const SizedBox(height: 15),
        _TrustFooter(language: language),
      ],
    );
  }

  Widget _sceneBody() => switch (scene) {
    StoreScreenshotScene.dailyGuidance => _DailyGuidanceScene(language: language),
    StoreScreenshotScene.explainableReading =>
      _ExplainableReadingScene(language: language),
    StoreScreenshotScene.mysticMirror => _MysticMirrorScene(language: language),
    StoreScreenshotScene.livingPath => _LivingPathScene(language: language),
    StoreScreenshotScene.mysticPlus => _MysticPlusScene(language: language),
  };
}

String _sceneLabel(MysticLanguage language, StoreScreenshotScene scene) =>
    switch (scene) {
      StoreScreenshotScene.dailyGuidance => _copy(
        language,
        en: 'DAILY GUIDANCE',
        tr: 'GÜNLÜK REHBERLİK',
        es: 'GUÍA DIARIA',
        fr: 'GUIDANCE DU JOUR',
        pt: 'ORIENTAÇÃO DIÁRIA',
      ),
      StoreScreenshotScene.explainableReading => _copy(
        language,
        en: 'EXPLAINABLE READINGS',
        tr: 'AÇIKLANABİLİR OKUMALAR',
        es: 'LECTURAS EXPLICABLES',
        fr: 'LECTURES EXPLICABLES',
        pt: 'LEITURAS EXPLICÁVEIS',
      ),
      StoreScreenshotScene.mysticMirror => 'MYSTIC MIRROR',
      StoreScreenshotScene.livingPath => _copy(
        language,
        en: 'LIVING FATE MAP',
        tr: 'YAŞAYAN KADER HARİTASI',
        es: 'MAPA VIVO DEL DESTINO',
        fr: 'CARTE VIVANTE DU DESTIN',
        pt: 'MAPA VIVO DO DESTINO',
      ),
      StoreScreenshotScene.mysticPlus => 'MYSTIC PLUS',
    };

class _DailyGuidanceScene extends StatelessWidget {
  const _DailyGuidanceScene({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) {
    final moon = tarotDeck[18];
    final star = tarotDeck[17];
    final strength = tarotDeck[8];
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(-108, 26),
                child: Transform.rotate(
                  angle: -.12,
                  child: _TarotCard(
                    symbol: star.symbol,
                    number: star.number,
                    label: _copy(
                      language,
                      en: 'The Star',
                      tr: 'Yıldız',
                      es: 'La Estrella',
                      fr: 'L’Étoile',
                      pt: 'A Estrela',
                    ),
                    compact: true,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(108, 26),
                child: Transform.rotate(
                  angle: .12,
                  child: _TarotCard(
                    symbol: strength.symbol,
                    number: strength.number,
                    label: _copy(
                      language,
                      en: 'Strength',
                      tr: 'Güç',
                      es: 'La Fuerza',
                      fr: 'La Force',
                      pt: 'A Força',
                    ),
                    compact: true,
                  ),
                ),
              ),
              _TarotCard(
                symbol: moon.symbol,
                number: moon.number,
                label: _copy(
                  language,
                  en: 'The Moon',
                  tr: 'Ay',
                  es: 'La Luna',
                  fr: 'La Lune',
                  pt: 'A Lua',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Metric(
                value: _copy(
                  language,
                  en: 'Clarity',
                  tr: 'Netlik',
                  es: 'Claridad',
                  fr: 'Clarté',
                  pt: 'Clareza',
                ),
                label: _copy(
                  language,
                  en: 'INTENTION',
                  tr: 'NİYET',
                  es: 'INTENCIÓN',
                  fr: 'INTENTION',
                  pt: 'INTENÇÃO',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                value: _copy(
                  language,
                  en: 'Reflective',
                  tr: 'Düşünceli',
                  es: 'Reflexivo',
                  fr: 'Réflexif',
                  pt: 'Reflexivo',
                ),
                label: _copy(
                  language,
                  en: 'MOOD',
                  tr: 'DUYGU',
                  es: 'ÁNIMO',
                  fr: 'HUMEUR',
                  pt: 'HUMOR',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _GlassPanel(
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: MysticColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _copy(
                    language,
                    en: 'Pause before naming uncertainty as fact.',
                    tr: 'Belirsizliğe gerçek demeden önce dur.',
                    es: 'Pausa antes de llamar hecho a la incertidumbre.',
                    fr: 'Faites une pause avant de nommer l’incertain comme un fait.',
                    pt: 'Pause antes de chamar a incerteza de fato.',
                  ),
                  style: const TextStyle(fontSize: 16, height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExplainableReadingScene extends StatelessWidget {
  const _ExplainableReadingScene({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _PositionCard(
              position: _copy(
                language,
                en: 'PAST',
                tr: 'GEÇMİŞ',
                es: 'PASADO',
                fr: 'PASSÉ',
                pt: 'PASSADO',
              ),
              symbol: tarotDeck[12].symbol,
              name: _copy(
                language,
                en: 'New view',
                tr: 'Yeni bakış',
                es: 'Nueva visión',
                fr: 'Nouveau regard',
                pt: 'Nova visão',
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _PositionCard(
              position: _copy(
                language,
                en: 'PRESENT',
                tr: 'ŞİMDİ',
                es: 'PRESENTE',
                fr: 'PRÉSENT',
                pt: 'PRESENTE',
              ),
              symbol: tarotDeck[17].symbol,
              name: _copy(
                language,
                en: 'Renewal',
                tr: 'Yenilenme',
                es: 'Renovación',
                fr: 'Renouveau',
                pt: 'Renovação',
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _PositionCard(
              position: _copy(
                language,
                en: 'NEXT',
                tr: 'SONRAKİ',
                es: 'SIGUIENTE',
                fr: 'ENSUITE',
                pt: 'PRÓXIMO',
              ),
              symbol: tarotDeck[7].symbol,
              name: _copy(
                language,
                en: 'Direction',
                tr: 'Yön',
                es: 'Dirección',
                fr: 'Direction',
                pt: 'Direção',
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Expanded(
        child: _GlassPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InsightRow(
                index: '01',
                title: _copy(
                  language,
                  en: 'Core message',
                  tr: 'Ana mesaj',
                  es: 'Mensaje central',
                  fr: 'Message central',
                  pt: 'Mensagem central',
                ),
                body: _copy(
                  language,
                  en: 'Hope becomes useful when it is paired with a named direction.',
                  tr: 'Umut, adı konmuş bir yönle birleştiğinde işe yarar.',
                  es: 'La esperanza sirve cuando se une a una dirección clara.',
                  fr: 'L’espoir devient utile lorsqu’il rejoint une direction claire.',
                  pt: 'A esperança se torna útil quando encontra uma direção clara.',
                ),
              ),
              const Divider(height: 24),
              _InsightRow(
                index: '02',
                title: _copy(
                  language,
                  en: 'Why these cards',
                  tr: 'Neden bu kartlar',
                  es: 'Por qué estas cartas',
                  fr: 'Pourquoi ces cartes',
                  pt: 'Por que estas cartas',
                ),
                body: _copy(
                  language,
                  en: 'The present card softens the pause; the next card turns it into movement.',
                  tr: 'Şimdiki kart duraklamayı yumuşatır; sonraki kart onu harekete çevirir.',
                  es: 'La carta presente suaviza la pausa; la siguiente la convierte en movimiento.',
                  fr: 'La carte présente adoucit la pause; la suivante la transforme en mouvement.',
                  pt: 'A carta presente suaviza a pausa; a próxima a transforma em movimento.',
                ),
              ),
              const Divider(height: 24),
              _InsightRow(
                index: '03',
                title: _copy(
                  language,
                  en: 'Grounded next step',
                  tr: 'Somut sonraki adım',
                  es: 'Próximo paso concreto',
                  fr: 'Prochaine étape concrète',
                  pt: 'Próximo passo concreto',
                ),
                body: _copy(
                  language,
                  en: 'Write one destination before increasing your speed.',
                  tr: 'Hızını artırmadan önce tek bir varış noktası yaz.',
                  es: 'Escribe un destino antes de aumentar la velocidad.',
                  fr: 'Écrivez une destination avant d’accélérer.',
                  pt: 'Escreva um destino antes de aumentar a velocidade.',
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _MysticMirrorScene extends StatelessWidget {
  const _MysticMirrorScene({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _GlassPanel(
        child: Row(
          children: [
            Container(
              width: 62,
              height: 82,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MysticColors.ink.withValues(alpha: .75),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: MysticColors.gold.withValues(alpha: .45),
                ),
              ),
              child: Text(
                tarotDeck[2].symbol,
                style: const TextStyle(fontSize: 34, color: MysticColors.gold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                    text: _copy(
                      language,
                      en: 'YESTERDAY’S GUIDANCE',
                      tr: 'DÜNÜN REHBERLİĞİ',
                      es: 'GUÍA DE AYER',
                      fr: 'GUIDANCE D’HIER',
                      pt: 'ORIENTAÇÃO DE ONTEM',
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _copy(
                      language,
                      en: 'Listen beneath the noise before choosing.',
                      tr: 'Seçmeden önce gürültünün altını dinle.',
                      es: 'Escucha bajo el ruido antes de elegir.',
                      fr: 'Écoutez sous le bruit avant de choisir.',
                      pt: 'Escute por baixo do ruído antes de escolher.',
                    ),
                    style: const TextStyle(fontSize: 17, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 15),
      Expanded(
        child: _GlassPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, color: MysticColors.lavender),
                  const SizedBox(width: 9),
                  Text(
                    _copy(
                      language,
                      en: '24 HOURS LATER',
                      tr: '24 SAAT SONRA',
                      es: '24 HORAS DESPUÉS',
                      fr: '24 HEURES PLUS TARD',
                      pt: '24 HORAS DEPOIS',
                    ),
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: MysticColors.lavender,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                _copy(
                  language,
                  en: 'What actually happened?',
                  tr: 'Gerçekte ne oldu?',
                  es: '¿Qué ocurrió realmente?',
                  fr: 'Que s’est-il vraiment passé ?',
                  pt: 'O que realmente aconteceu?',
                ),
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                _copy(
                  language,
                  en: 'Your reflection becomes evidence for future readings — stored privately on this device.',
                  tr: 'Yansıman gelecekteki okumalar için kanıta dönüşür — bu cihazda özel olarak saklanır.',
                  es: 'Tu reflexión se convierte en evidencia para futuras lecturas y queda privada en este dispositivo.',
                  fr: 'Votre retour devient un indice pour les prochaines lectures, conservé sur cet appareil.',
                  pt: 'Sua reflexão vira evidência para leituras futuras e fica privada neste dispositivo.',
                ),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  height: 1.45,
                  color: MysticColors.muted,
                ),
              ),
              const Spacer(),
              _OutcomeChoice(
                icon: Icons.check_circle_outline,
                label: _copy(
                  language,
                  en: 'It matched reality',
                  tr: 'Gerçekle örtüştü',
                  es: 'Coincidió con la realidad',
                  fr: 'Cela correspondait au réel',
                  pt: 'Combinou com a realidade',
                ),
                selected: true,
              ),
              const SizedBox(height: 9),
              _OutcomeChoice(
                icon: Icons.change_circle_outlined,
                label: _copy(
                  language,
                  en: 'Reality changed the meaning',
                  tr: 'Gerçek anlamı değiştirdi',
                  es: 'La realidad cambió el significado',
                  fr: 'Le réel a changé le sens',
                  pt: 'A realidade mudou o significado',
                ),
              ),
              const SizedBox(height: 9),
              _OutcomeChoice(
                icon: Icons.help_outline,
                label: _copy(
                  language,
                  en: 'Still unfolding',
                  tr: 'Hâlâ gelişiyor',
                  es: 'Aún se está desarrollando',
                  fr: 'Toujours en évolution',
                  pt: 'Ainda se desenvolvendo',
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _LivingPathScene extends StatelessWidget {
  const _LivingPathScene({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: _GlassPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      value: '12',
                      label: _copy(
                        language,
                        en: 'READINGS',
                        tr: 'OKUMA',
                        es: 'LECTURAS',
                        fr: 'LECTURES',
                        pt: 'LEITURAS',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Metric(
                      value: '4',
                      label: _copy(
                        language,
                        en: 'MIRRORS',
                        tr: 'AYNA',
                        es: 'ESPEJOS',
                        fr: 'MIROIRS',
                        pt: 'ESPELHOS',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Metric(
                      value: '7',
                      label: _copy(
                        language,
                        en: 'DAY STREAK',
                        tr: 'GÜNLÜK SERİ',
                        es: 'DÍAS',
                        fr: 'JOURS',
                        pt: 'DIAS',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Stack(
                  children: [
                    const Positioned.fill(child: _PathLines()),
                    Positioned(
                      left: 18,
                      top: 18,
                      child: _PathNode(symbol: tarotDeck[17].symbol, count: '4×'),
                    ),
                    Positioned(
                      right: 18,
                      top: 70,
                      child: _PathNode(symbol: tarotDeck[2].symbol, count: '3×'),
                    ),
                    Positioned(
                      left: 116,
                      top: 126,
                      child: _PathNode(
                        symbol: tarotDeck[18].symbol,
                        count: '5×',
                        primary: true,
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 22,
                      child: _PathNode(symbol: tarotDeck[8].symbol, count: '2×'),
                    ),
                    Positioned(
                      right: 34,
                      bottom: 10,
                      child: _PathNode(symbol: tarotDeck[21].symbol, count: '2×'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 13),
      _GlassPanel(
        child: Row(
          children: [
            const Icon(Icons.insights, color: MysticColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                    text: _copy(
                      language,
                      en: 'RECURRING PATTERN',
                      tr: 'TEKRARLAYAN ÖRÜNTÜ',
                      es: 'PATRÓN RECURRENTE',
                      fr: 'MOTIF RÉCURRENT',
                      pt: 'PADRÃO RECORRENTE',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _copy(
                      language,
                      en: 'Intuition appears before decisive movement.',
                      tr: 'Sezgi, kararlı hareketten önce beliriyor.',
                      es: 'La intuición aparece antes del movimiento decisivo.',
                      fr: 'L’intuition apparaît avant le mouvement décisif.',
                      pt: 'A intuição aparece antes do movimento decisivo.',
                    ),
                    style: const TextStyle(fontSize: 16, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _MysticPlusScene extends StatelessWidget {
  const _MysticPlusScene({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _PlanChip(
              label: _copy(
                language,
                en: 'MONTHLY',
                tr: 'AYLIK',
                es: 'MENSUAL',
                fr: 'MENSUEL',
                pt: 'MENSAL',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PlanChip(
              label: _copy(
                language,
                en: 'YEARLY',
                tr: 'YILLIK',
                es: 'ANUAL',
                fr: 'ANNUEL',
                pt: 'ANUAL',
              ),
              selected: true,
              badge: _copy(
                language,
                en: 'BEST VALUE',
                tr: 'EN İYİ DEĞER',
                es: 'MEJOR VALOR',
                fr: 'MEILLEUR CHOIX',
                pt: 'MELHOR VALOR',
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 13),
      Expanded(
        child: _GlassPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [MysticColors.gold, Color(0xFF8A6A2D)],
                      ),
                    ),
                    child: const Icon(Icons.workspace_premium, color: Color(0xFF18101F)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MYSTIC PLUS',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          _copy(
                            language,
                            en: 'Official price shown by your store',
                            tr: 'Resmi fiyat mağazan tarafından gösterilir',
                            es: 'Tu tienda muestra el precio oficial',
                            fr: 'Le prix officiel est affiché par votre boutique',
                            pt: 'O preço oficial é exibido pela sua loja',
                          ),
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            color: MysticColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _PremiumFeature(
                title: _copy(
                  language,
                  en: 'All deep spreads',
                  tr: 'Tüm derin açılımlar',
                  es: 'Todas las tiradas profundas',
                  fr: 'Tous les tirages approfondis',
                  pt: 'Todas as tiragens profundas',
                ),
                body: _copy(
                  language,
                  en: 'Decision, compatibility, timeline, shadow, and Celtic Cross.',
                  tr: 'Karar, uyum, zaman çizgisi, gölge ve Kelt Haçı.',
                  es: 'Decisión, compatibilidad, línea temporal, sombra y Cruz Celta.',
                  fr: 'Décision, compatibilité, chronologie, ombre et Croix Celtique.',
                  pt: 'Decisão, compatibilidade, linha do tempo, sombra e Cruz Celta.',
                ),
              ),
              const SizedBox(height: 15),
              _PremiumFeature(
                title: _copy(
                  language,
                  en: 'Private weekly intelligence',
                  tr: 'Özel haftalık içgörü',
                  es: 'Inteligencia semanal privada',
                  fr: 'Intelligence hebdomadaire privée',
                  pt: 'Inteligência semanal privada',
                ),
                body: _copy(
                  language,
                  en: 'Patterns, completed reality loops, and emotional movement.',
                  tr: 'Örüntüler, kapanan gerçeklik döngüleri ve duygusal hareket.',
                  es: 'Patrones, ciclos de realidad completados y movimiento emocional.',
                  fr: 'Motifs, boucles de réalité closes et évolution émotionnelle.',
                  pt: 'Padrões, ciclos de realidade concluídos e movimento emocional.',
                ),
              ),
              const SizedBox(height: 15),
              _PremiumFeature(
                title: _copy(
                  language,
                  en: 'Restore and manage anytime',
                  tr: 'İstediğin zaman geri yükle ve yönet',
                  es: 'Restaura y gestiona cuando quieras',
                  fr: 'Restaurez et gérez à tout moment',
                  pt: 'Restaure e gerencie quando quiser',
                ),
                body: _copy(
                  language,
                  en: 'Store-managed subscription with live entitlement checks.',
                  tr: 'Canlı hak doğrulamalı, mağaza tarafından yönetilen abonelik.',
                  es: 'Suscripción gestionada por la tienda con verificación activa.',
                  fr: 'Abonnement géré par la boutique avec vérification active.',
                  pt: 'Assinatura gerenciada pela loja com verificação ativa.',
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  gradient: const LinearGradient(
                    colors: [MysticColors.gold, Color(0xFFB78D3D)],
                  ),
                ),
                child: Text(
                  _copy(
                    language,
                    en: 'CONTINUE WITH YEARLY',
                    tr: 'YILLIK İLE DEVAM ET',
                    es: 'CONTINUAR CON ANUAL',
                    fr: 'CONTINUER EN ANNUEL',
                    pt: 'CONTINUAR COM ANUAL',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                    color: Color(0xFF17101D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: const Color(0xFF171329).withValues(alpha: .88),
      borderRadius: BorderRadius.circular(23),
      border: Border.all(color: Colors.white.withValues(alpha: .09)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .25),
          blurRadius: 26,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: child,
  );
}

class _TarotCard extends StatelessWidget {
  const _TarotCard({
    required this.symbol,
    required this.number,
    required this.label,
    this.compact = false,
  });

  final String symbol;
  final String number;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 112.0 : 164.0;
    final height = compact ? 178.0 : 252.0;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF33224F), Color(0xFF171125), Color(0xFF0E0C18)],
        ),
        borderRadius: BorderRadius.circular(compact ? 18 : 24),
        border: Border.all(
          color: MysticColors.gold.withValues(alpha: compact ? .35 : .72),
          width: compact ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: MysticColors.violet.withValues(alpha: compact ? .14 : .28),
            blurRadius: compact ? 18 : 32,
            spreadRadius: compact ? 1 : 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: compact ? 8 : 10,
              fontWeight: FontWeight.w800,
              color: MysticColors.gold,
            ),
          ),
          const Spacer(),
          Text(
            symbol,
            style: TextStyle(
              fontSize: compact ? 44 : 68,
              color: MysticColors.gold,
              shadows: [
                Shadow(
                  color: MysticColors.gold.withValues(alpha: .35),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 11 : 15,
              fontWeight: FontWeight.w700,
              color: MysticColors.mist,
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({
    required this.position,
    required this.symbol,
    required this.name,
  });

  final String position;
  final String symbol;
  final String name;

  @override
  Widget build(BuildContext context) => _GlassPanel(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
    child: Column(
      children: [
        _SectionLabel(text: position),
        const SizedBox(height: 9),
        Text(symbol, style: const TextStyle(fontSize: 32, color: MysticColors.gold)),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.index, required this.title, required this.body});

  final String index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MysticColors.violet.withValues(alpha: .25),
          border: Border.all(color: MysticColors.lavender.withValues(alpha: .35)),
        ),
        child: Text(
          index,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: MysticColors.lavender,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(
              body,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 13,
                height: 1.4,
                color: MysticColors.muted,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _OutcomeChoice extends StatelessWidget {
  const _OutcomeChoice({required this.icon, required this.label, this.selected = false});

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: selected
          ? MysticColors.violet.withValues(alpha: .24)
          : Colors.white.withValues(alpha: .035),
      border: Border.all(
        color: selected
            ? MysticColors.lavender.withValues(alpha: .55)
            : Colors.white.withValues(alpha: .08),
      ),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: selected ? MysticColors.lavender : MysticColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Arial', fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        if (selected) const Icon(Icons.check, size: 18, color: MysticColors.gold),
      ],
    ),
  );
}

class _PathLines extends StatelessWidget {
  const _PathLines();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _PathLinePainter());
}

class _PathLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MysticColors.lavender.withValues(alpha: .22)
      ..strokeWidth = 1.4;
    final points = <Offset>[
      const Offset(52, 55),
      Offset(size.width - 50, 106),
      Offset(size.width * .5, size.height * .52),
      Offset(58, size.height - 56),
      Offset(size.width - 66, size.height - 44),
    ];
    for (var index = 0; index < points.length - 1; index++) {
      canvas.drawLine(points[index], points[index + 1], paint);
    }
    canvas.drawLine(points.first, points[2], paint);
    canvas.drawLine(points[1], points.last, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PathNode extends StatelessWidget {
  const _PathNode({required this.symbol, required this.count, this.primary = false});

  final String symbol;
  final String count;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final size = primary ? 96.0 : 72.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: primary
              ? [MysticColors.violet, const Color(0xFF2E1C48)]
              : [const Color(0xFF2A203F), const Color(0xFF151020)],
        ),
        border: Border.all(
          color: MysticColors.gold.withValues(alpha: primary ? .75 : .35),
          width: primary ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MysticColors.violet.withValues(alpha: primary ? .35 : .13),
            blurRadius: primary ? 32 : 16,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            symbol,
            style: TextStyle(
              fontSize: primary ? 40 : 30,
              color: MysticColors.gold,
            ),
          ),
          Positioned(
            right: primary ? 4 : 1,
            top: primary ? 5 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: const BoxDecoration(
                color: MysticColors.gold,
                shape: BoxShape.circle,
              ),
              child: Text(
                count,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF17101D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label, this.selected = false, this.badge});

  final String label;
  final bool selected;
  final String? badge;

  @override
  Widget build(BuildContext context) => Container(
    height: 74,
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      color: selected
          ? MysticColors.violet.withValues(alpha: .26)
          : const Color(0xFF171329).withValues(alpha: .84),
      border: Border.all(
        color: selected
            ? MysticColors.gold.withValues(alpha: .68)
            : Colors.white.withValues(alpha: .08),
      ),
    ),
    child: Row(
      children: [
        Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? MysticColors.gold : MysticColors.muted,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(height: 3),
                Text(
                  badge!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: MysticColors.gold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _PremiumFeature extends StatelessWidget {
  const _PremiumFeature({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 27,
        height: 27,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: MysticColors.gold.withValues(alpha: .16),
        ),
        child: const Icon(Icons.check, size: 16, color: MysticColors.gold),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              body,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                height: 1.35,
                color: MysticColors.muted,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white.withValues(alpha: .045),
      border: Border.all(color: Colors.white.withValues(alpha: .07)),
    ),
    child: Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
            color: MysticColors.muted,
          ),
        ),
      ],
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      color: Colors.white.withValues(alpha: .055),
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: MysticColors.lavender),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontFamily: 'Arial',
      fontSize: 10,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.25,
      color: MysticColors.gold,
    ),
  );
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.lock_outline, size: 14, color: MysticColors.muted),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          _copy(
            language,
            en: 'PRIVATE • LOCAL-FIRST • FOR REFLECTION',
            tr: 'ÖZEL • YEREL ÖNCELİKLİ • YANSIMA İÇİN',
            es: 'PRIVADO • LOCAL PRIMERO • PARA REFLEXIONAR',
            fr: 'PRIVÉ • LOCAL D’ABORD • POUR RÉFLÉCHIR',
            pt: 'PRIVADO • LOCAL PRIMEIRO • PARA REFLEXÃO',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: .75,
            color: MysticColors.muted,
          ),
        ),
      ),
    ],
  );
}
