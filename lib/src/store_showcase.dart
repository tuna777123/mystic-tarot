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

String _l(
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
      home: _ShowcaseScreen(language: language, scene: scene),
    );
  }
}

class _ShowcaseScreen extends StatelessWidget {
  const _ShowcaseScreen({required this.language, required this.scene});

  final MysticLanguage language;
  final StoreScreenshotScene scene;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        const Positioned.fill(child: _Backdrop()),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            child: Column(
              children: [
                _Brand(language: language),
                const SizedBox(height: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 382,
                      height: 760,
                      child: _Scene(language: language, scene: scene),
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

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF080711), Color(0xFF1B1230), Color(0xFF090816)],
      ),
    ),
    child: CustomPaint(painter: _Stars()),
  );
}

class _Stars extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .14);
    for (var index = 0; index < 48; index++) {
      canvas.drawCircle(
        Offset((index * 83) % size.width, (index * index * 17) % size.height),
        index % 8 == 0 ? 1.5 : .75,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Brand extends StatelessWidget {
  const _Brand({required this.language});

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
          ),
        ),
      ),
      _Chip(text: language.code, icon: Icons.language),
    ],
  );
}

class _Scene extends StatelessWidget {
  const _Scene({required this.language, required this.scene});

  final MysticLanguage language;
  final StoreScreenshotScene scene;

  String get _label => switch (scene) {
    StoreScreenshotScene.dailyGuidance => _l(
      language,
      en: 'DAILY GUIDANCE',
      tr: 'GÜNLÜK REHBERLİK',
      es: 'GUÍA DIARIA',
      fr: 'GUIDANCE DU JOUR',
      pt: 'ORIENTAÇÃO DIÁRIA',
    ),
    StoreScreenshotScene.explainableReading => _l(
      language,
      en: 'EXPLAINABLE READINGS',
      tr: 'AÇIKLANABİLİR OKUMALAR',
      es: 'LECTURAS EXPLICABLES',
      fr: 'LECTURES EXPLICABLES',
      pt: 'LEITURAS EXPLICÁVEIS',
    ),
    StoreScreenshotScene.mysticMirror => 'MYSTIC MIRROR',
    StoreScreenshotScene.livingPath => _l(
      language,
      en: 'LIVING FATE MAP',
      tr: 'YAŞAYAN KADER HARİTASI',
      es: 'MAPA VIVO DEL DESTINO',
      fr: 'CARTE VIVANTE DU DESTIN',
      pt: 'MAPA VIVO DO DESTINO',
    ),
    StoreScreenshotScene.mysticPlus => _l(
      language,
      en: 'FREE EXPERIENCE',
      tr: 'ÜCRETSİZ DENEYİM',
      es: 'EXPERIENCIA GRATIS',
      fr: 'EXPÉRIENCE GRATUITE',
      pt: 'EXPERIÊNCIA GRÁTIS',
    ),
  };

  String get _title => switch (scene) {
    StoreScreenshotScene.dailyGuidance => _l(
      language,
      en: 'Your daily guidance, grounded in you.',
      tr: 'Günlük rehberliğin, sana göre şekillenir.',
      es: 'Tu guía diaria, conectada contigo.',
      fr: 'Votre guidance du jour, ancrée en vous.',
      pt: 'Sua orientação diária, conectada a você.',
    ),
    StoreScreenshotScene.explainableReading => _l(
      language,
      en: 'See how every card shaped the reading.',
      tr: 'Her kartın yorumu nasıl şekillendirdiğini gör.',
      es: 'Descubre cómo cada carta dio forma a la lectura.',
      fr: 'Voyez comment chaque carte façonne la lecture.',
      pt: 'Veja como cada carta formou a leitura.',
    ),
    StoreScreenshotScene.mysticMirror => _l(
      language,
      en: 'Return in 24 hours. Compare guidance with reality.',
      tr: '24 saat sonra dön. Rehberliği gerçekle karşılaştır.',
      es: 'Vuelve en 24 horas. Compara la guía con la realidad.',
      fr: 'Revenez dans 24 heures. Comparez au réel.',
      pt: 'Volte em 24 horas. Compare a orientação com a realidade.',
    ),
    StoreScreenshotScene.livingPath => _l(
      language,
      en: 'Your symbols become a living map.',
      tr: 'Sembollerin yaşayan bir haritaya dönüşür.',
      es: 'Tus símbolos se convierten en un mapa vivo.',
      fr: 'Vos symboles deviennent une carte vivante.',
      pt: 'Seus símbolos se tornam um mapa vivo.',
    ),
    StoreScreenshotScene.mysticPlus => _l(
      language,
      en: 'Go deeper without losing trust.',
      tr: 'Güveni kaybetmeden daha derine in.',
      es: 'Profundiza sin perder la confianza.',
      fr: 'Allez plus loin sans perdre confiance.',
      pt: 'Aprofunde-se sem perder a confiança.',
    ),
  };

  String get _subtitle => switch (scene) {
    StoreScreenshotScene.dailyGuidance => _l(
      language,
      en: 'A focused ritual built around your intention, mood, and chosen deck.',
      tr: 'Niyetin, duygun ve seçtiğin desteye göre odaklanan bir ritüel.',
      es: 'Un ritual enfocado en tu intención, emoción y mazo elegido.',
      fr: 'Un rituel centré sur votre intention, votre émotion et votre jeu.',
      pt: 'Um ritual focado na sua intenção, emoção e baralho escolhido.',
    ),
    StoreScreenshotScene.explainableReading => _l(
      language,
      en: 'Position, orientation, evidence, and next step stay visible.',
      tr: 'Konum, yön, kanıt ve sonraki adım görünür kalır.',
      es: 'La posición, orientación, evidencia y próximo paso son visibles.',
      fr: 'Position, orientation, indices et prochaine étape restent visibles.',
      pt: 'Posição, orientação, evidências e próximo passo ficam visíveis.',
    ),
    StoreScreenshotScene.mysticMirror => _l(
      language,
      en: 'Close the loop instead of collecting endless predictions.',
      tr: 'Sonsuz tahmin biriktirmek yerine döngüyü kapat.',
      es: 'Cierra el ciclo en vez de acumular predicciones.',
      fr: 'Fermez la boucle au lieu d’accumuler des prédictions.',
      pt: 'Feche o ciclo em vez de acumular previsões.',
    ),
    StoreScreenshotScene.livingPath => _l(
      language,
      en: 'Repeated cards, themes, and reflections reveal your private pattern.',
      tr: 'Tekrarlayan kartlar, temalar ve yansımalar özel örüntünü gösterir.',
      es: 'Cartas, temas y reflexiones repetidos revelan tu patrón privado.',
      fr: 'Cartes, thèmes et retours répétés révèlent votre motif privé.',
      pt: 'Cartas, temas e reflexões repetidas revelam seu padrão privado.',
    ),
    StoreScreenshotScene.mysticPlus => _l(
      language,
      en: 'Deep readings and private intelligence, with official store pricing.',
      tr: 'Derin okumalar ve özel içgörüler; resmi mağaza fiyatlarıyla.',
      es: 'Lecturas profundas e inteligencia privada con precio oficial.',
      fr: 'Lectures profondes et intelligence privée, au tarif officiel.',
      pt: 'Leituras profundas e inteligência privada com preço oficial.',
    ),
  };

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Label(_label),
      const SizedBox(height: 10),
      Text(
        _title,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 34,
          height: 1.04,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        _subtitle,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 15,
          height: 1.42,
          color: MysticColors.muted,
        ),
      ),
      const SizedBox(height: 20),
      Expanded(child: _body()),
      const SizedBox(height: 14),
      _Trust(language: language),
    ],
  );

  Widget _body() => switch (scene) {
    StoreScreenshotScene.dailyGuidance => _Daily(language: language),
    StoreScreenshotScene.explainableReading => _Reading(language: language),
    StoreScreenshotScene.mysticMirror => _Mirror(language: language),
    StoreScreenshotScene.livingPath => _Path(language: language),
    StoreScreenshotScene.mysticPlus => _Plus(language: language),
  };
}

class _Daily extends StatelessWidget {
  const _Daily({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: const Offset(-105, 25),
              child: Transform.rotate(
                angle: -.12,
                child: _Tarot(
                  symbol: tarotDeck[17].symbol,
                  number: tarotDeck[17].number,
                  name: _l(
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
              offset: const Offset(105, 25),
              child: Transform.rotate(
                angle: .12,
                child: _Tarot(
                  symbol: tarotDeck[8].symbol,
                  number: tarotDeck[8].number,
                  name: _l(
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
            _Tarot(
              symbol: tarotDeck[18].symbol,
              number: tarotDeck[18].number,
              name: _l(
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
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: _Metric(
              value: _l(
                language,
                en: 'Clarity',
                tr: 'Netlik',
                es: 'Claridad',
                fr: 'Clarté',
                pt: 'Clareza',
              ),
              label: _l(
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
              value: _l(
                language,
                en: 'Reflective',
                tr: 'Düşünceli',
                es: 'Reflexivo',
                fr: 'Réflexif',
                pt: 'Reflexivo',
              ),
              label: _l(
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
      _Panel(
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: MysticColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _l(
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

class _Reading extends StatelessWidget {
  const _Reading({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _Position(
              position: _l(
                language,
                en: 'PAST',
                tr: 'GEÇMİŞ',
                es: 'PASADO',
                fr: 'PASSÉ',
                pt: 'PASSADO',
              ),
              symbol: tarotDeck[12].symbol,
              name: _l(
                language,
                en: 'New view',
                tr: 'Yeni bakış',
                es: 'Nueva visión',
                fr: 'Nouveau regard',
                pt: 'Nova visão',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Position(
              position: _l(
                language,
                en: 'PRESENT',
                tr: 'ŞİMDİ',
                es: 'PRESENTE',
                fr: 'PRÉSENT',
                pt: 'PRESENTE',
              ),
              symbol: tarotDeck[17].symbol,
              name: _l(
                language,
                en: 'Renewal',
                tr: 'Yenilenme',
                es: 'Renovación',
                fr: 'Renouveau',
                pt: 'Renovação',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Position(
              position: _l(
                language,
                en: 'NEXT',
                tr: 'SONRAKİ',
                es: 'SIGUIENTE',
                fr: 'ENSUITE',
                pt: 'PRÓXIMO',
              ),
              symbol: tarotDeck[7].symbol,
              name: _l(
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
        child: _Panel(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Insight(
                index: '01',
                title: _l(
                  language,
                  en: 'Core message',
                  tr: 'Ana mesaj',
                  es: 'Mensaje central',
                  fr: 'Message central',
                  pt: 'Mensagem central',
                ),
                body: _l(
                  language,
                  en: 'Hope becomes useful when it is paired with a named direction.',
                  tr: 'Umut, adı konmuş bir yönle birleştiğinde işe yarar.',
                  es: 'La esperanza sirve cuando se une a una dirección clara.',
                  fr: 'L’espoir devient utile lorsqu’il rejoint une direction claire.',
                  pt: 'A esperança se torna útil quando encontra uma direção clara.',
                ),
              ),
              const Divider(height: 8),
              _Insight(
                index: '02',
                title: _l(
                  language,
                  en: 'Why these cards',
                  tr: 'Neden bu kartlar',
                  es: 'Por qué estas cartas',
                  fr: 'Pourquoi ces cartes',
                  pt: 'Por que estas cartas',
                ),
                body: _l(
                  language,
                  en: 'The present card softens the pause; the next card turns it into movement.',
                  tr: 'Şimdiki kart duraklamayı yumuşatır; sonraki kart onu harekete çevirir.',
                  es: 'La carta presente suaviza la pausa; la siguiente la convierte en movimiento.',
                  fr: 'La carte présente adoucit la pause; la suivante la transforme en mouvement.',
                  pt: 'A carta presente suaviza a pausa; a próxima a transforma em movimento.',
                ),
              ),
              const Divider(height: 8),
              _Insight(
                index: '03',
                title: _l(
                  language,
                  en: 'Grounded next step',
                  tr: 'Somut sonraki adım',
                  es: 'Próximo paso concreto',
                  fr: 'Prochaine étape concrète',
                  pt: 'Próximo passo concreto',
                ),
                body: _l(
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

class _Mirror extends StatelessWidget {
  const _Mirror({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Panel(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            _Tarot(
              symbol: tarotDeck[2].symbol,
              number: tarotDeck[2].number,
              name: '',
              tiny: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(
                    _l(
                      language,
                      en: 'YESTERDAY’S GUIDANCE',
                      tr: 'DÜNÜN REHBERLİĞİ',
                      es: 'GUÍA DE AYER',
                      fr: 'GUIDANCE D’HIER',
                      pt: 'ORIENTAÇÃO DE ONTEM',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _l(
                      language,
                      en: 'Listen beneath the noise before choosing.',
                      tr: 'Seçmeden önce gürültünün altını dinle.',
                      es: 'Escucha bajo el ruido antes de elegir.',
                      fr: 'Écoutez sous le bruit avant de choisir.',
                      pt: 'Escute por baixo do ruído antes de escolher.',
                    ),
                    style: const TextStyle(fontSize: 15, height: 1.25),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: _Panel(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Chip(
                text: _l(
                  language,
                  en: '24 HOURS LATER',
                  tr: '24 SAAT SONRA',
                  es: '24 HORAS DESPUÉS',
                  fr: '24 HEURES PLUS TARD',
                  pt: '24 HORAS DEPOIS',
                ),
                icon: Icons.schedule,
              ),
              const SizedBox(height: 8),
              Text(
                _l(
                  language,
                  en: 'What actually happened?',
                  tr: 'Gerçekte ne oldu?',
                  es: '¿Qué ocurrió realmente?',
                  fr: 'Que s’est-il vraiment passé ?',
                  pt: 'O que realmente aconteceu?',
                ),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _l(
                  language,
                  en: 'Your reflection becomes evidence for future readings and stays private on this device.',
                  tr: 'Yansıman gelecekteki okumalar için kanıta dönüşür ve bu cihazda özel kalır.',
                  es: 'Tu reflexión se convierte en evidencia para futuras lecturas y queda privada en este dispositivo.',
                  fr: 'Votre retour devient un indice pour les prochaines lectures et reste privé sur cet appareil.',
                  pt: 'Sua reflexão vira evidência para leituras futuras e fica privada neste dispositivo.',
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 11,
                  height: 1.25,
                  color: MysticColors.muted,
                ),
              ),
              const Spacer(),
              _Choice(
                _l(
                  language,
                  en: 'It matched reality',
                  tr: 'Gerçekle örtüştü',
                  es: 'Coincidió con la realidad',
                  fr: 'Cela correspondait au réel',
                  pt: 'Combinou com a realidade',
                ),
                selected: true,
              ),
              const SizedBox(height: 4),
              _Choice(
                _l(
                  language,
                  en: 'Reality changed the meaning',
                  tr: 'Gerçek anlamı değiştirdi',
                  es: 'La realidad cambió el significado',
                  fr: 'Le réel a changé le sens',
                  pt: 'A realidade mudou o significado',
                ),
              ),
              const SizedBox(height: 4),
              _Choice(
                _l(
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

class _Path extends StatelessWidget {
  const _Path({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: _Panel(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      value: '12',
                      label: _l(
                        language,
                        en: 'READINGS',
                        tr: 'OKUMALAR',
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
                      label: _l(
                        language,
                        en: 'MIRRORS',
                        tr: 'AYNALAR',
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
                      label: _l(
                        language,
                        en: 'DAY STREAK',
                        tr: 'GÜNLÜK SERİ',
                        es: 'RACHA DIARIA',
                        fr: 'SÉRIE QUOTIDIENNE',
                        pt: 'SEQUÊNCIA DIÁRIA',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: CustomPaint(painter: _PathLines()),
                    ),
                    Positioned(
                      left: 20,
                      top: 20,
                      child: _Node(tarotDeck[17].symbol, '4×'),
                    ),
                    Positioned(
                      right: 20,
                      top: 72,
                      child: _Node(tarotDeck[2].symbol, '3×'),
                    ),
                    Positioned(
                      left: 116,
                      top: 126,
                      child: _Node(tarotDeck[18].symbol, '5×', primary: true),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 22,
                      child: _Node(tarotDeck[8].symbol, '2×'),
                    ),
                    Positioned(
                      right: 32,
                      bottom: 10,
                      child: _Node(tarotDeck[21].symbol, '2×'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 13),
      _Panel(
        child: Row(
          children: [
            const Icon(Icons.insights, color: MysticColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(
                    _l(
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
                    _l(
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

class _Plus extends StatelessWidget {
  const _Plus({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _Metric(
              value: _l(
                language,
                en: 'FREE',
                tr: 'ÜCRETSİZ',
                es: 'GRATIS',
                fr: 'GRATUIT',
                pt: 'GRÁTIS',
              ),
              label: _l(
                language,
                en: 'ALL FEATURES',
                tr: 'TÜM ÖZELLİKLER',
                es: 'TODAS LAS FUNCIONES',
                fr: 'TOUTES LES FONCTIONS',
                pt: 'TODOS OS RECURSOS',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Metric(
              value: _l(
                language,
                en: 'NO PAYWALL',
                tr: 'ÖDEME YOK',
                es: 'SIN PAGO',
                fr: 'SANS PÉAGE',
                pt: 'SEM PAYWALL',
              ),
              label: _l(
                language,
                en: 'NATIVE AD-SUPPORTED',
                tr: 'MOBİL REKLAM DESTEKLİ',
                es: 'APP CON PUBLICIDAD',
                fr: 'APP AVEC PUBLICITÉ',
                pt: 'APP COM ANÚNCIOS',
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 13),
      Expanded(
        child: _Panel(
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
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF18101F),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _l(
                            language,
                            en: 'COMPLETE MYSTIC EXPERIENCE',
                            tr: 'TAM MYSTIC DENEYİMİ',
                            es: 'EXPERIENCIA MYSTIC COMPLETA',
                            fr: 'EXPÉRIENCE MYSTIC COMPLÈTE',
                            pt: 'EXPERIÊNCIA MYSTIC COMPLETA',
                          ),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          _l(
                            language,
                            en: 'Core access never depends on watching an ad',
                            tr: 'Temel erişim reklam izlemeye bağlı değildir',
                            es: 'El acceso principal no depende de ver un anuncio',
                            fr: 'L’accès essentiel ne dépend pas du visionnage d’une pub',
                            pt: 'O acesso principal não depende de assistir anúncio',
                          ),
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 11,
                            color: MysticColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _Feature(
                _l(
                  language,
                  en: 'All readings and deep spreads',
                  tr: 'Tüm okumalar ve derin açılımlar',
                  es: 'Todas las lecturas y tiradas profundas',
                  fr: 'Tous les tirages et lectures approfondies',
                  pt: 'Todas as leituras e tiragens profundas',
                ),
              ),
              const SizedBox(height: 16),
              _Feature(
                _l(
                  language,
                  en: 'Mystic Mirror and private patterns',
                  tr: 'Mystic Ayna ve özel örüntüler',
                  es: 'Mystic Mirror y patrones privados',
                  fr: 'Mystic Mirror et motifs privés',
                  pt: 'Mystic Mirror e padrões privados',
                ),
              ),
              const SizedBox(height: 16),
              _Feature(
                _l(
                  language,
                  en: 'Living Journal, Oracle, Path and Arcana',
                  tr: 'Yaşayan Günlük, Oracle, Yol ve Arkana',
                  es: 'Diario, Oracle, Path y Arcana',
                  fr: 'Journal, Oracle, Path et Arcanes',
                  pt: 'Diário, Oracle, Path e Arcanos',
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
                  _l(
                    language,
                    en: 'CONTINUE FREE',
                    tr: 'ÜCRETSİZ DEVAM ET',
                    es: 'CONTINUAR GRATIS',
                    fr: 'CONTINUER GRATUITEMENT',
                    pt: 'CONTINUAR GRÁTIS',
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

class _Trust extends StatelessWidget {
  const _Trust({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.lock_outline, size: 14, color: MysticColors.muted),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          _l(
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
            letterSpacing: .7,
            color: MysticColors.muted,
          ),
        ),
      ),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: const Color(0xFF171329).withValues(alpha: .9),
      borderRadius: BorderRadius.circular(23),
      border: Border.all(color: Colors.white.withValues(alpha: .09)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .24),
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: child,
  );
}

class _Tarot extends StatelessWidget {
  const _Tarot({
    required this.symbol,
    required this.number,
    required this.name,
    this.compact = false,
    this.tiny = false,
  });

  final String symbol;
  final String number;
  final String name;
  final bool compact;
  final bool tiny;

  @override
  Widget build(BuildContext context) {
    final width = tiny
        ? 62.0
        : compact
        ? 112.0
        : 164.0;
    final height = tiny
        ? 82.0
        : compact
        ? 178.0
        : 252.0;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(
        tiny
            ? 8
            : compact
            ? 12
            : 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF33224F), Color(0xFF171125), Color(0xFF0E0C18)],
        ),
        borderRadius: BorderRadius.circular(
          tiny
              ? 16
              : compact
              ? 18
              : 24,
        ),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .55)),
      ),
      child: Column(
        children: [
          if (!tiny)
            Text(
              number,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: MysticColors.gold,
              ),
            ),
          const Spacer(),
          Text(
            symbol,
            style: TextStyle(
              fontSize: tiny
                  ? 34
                  : compact
                  ? 44
                  : 68,
              color: MysticColors.gold,
            ),
          ),
          const Spacer(),
          if (!tiny)
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11 : 15,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _Position extends StatelessWidget {
  const _Position({
    required this.position,
    required this.symbol,
    required this.name,
  });

  final String position;
  final String symbol;
  final String name;

  @override
  Widget build(BuildContext context) => _Panel(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
    child: Column(
      children: [
        _Label(position),
        const SizedBox(height: 8),
        Text(
          symbol,
          style: const TextStyle(fontSize: 30, color: MysticColors.gold),
        ),
        const SizedBox(height: 7),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _Insight extends StatelessWidget {
  const _Insight({
    required this.index,
    required this.title,
    required this.body,
  });

  final String index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        radius: 15,
        backgroundColor: MysticColors.violet.withValues(alpha: .25),
        child: Text(
          index,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: MysticColors.lavender,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 11,
                height: 1.25,
                color: MysticColors.muted,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Choice extends StatelessWidget {
  const _Choice(this.text, {this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(13),
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
        Icon(
          selected ? Icons.check_circle_outline : Icons.circle_outlined,
          size: 18,
          color: selected ? MysticColors.lavender : MysticColors.muted,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 7,
            fontWeight: FontWeight.w900,
            letterSpacing: .55,
            color: MysticColors.muted,
          ),
        ),
      ],
    ),
  );
}

class _Node extends StatelessWidget {
  const _Node(this.symbol, this.count, {this.primary = false});

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
        border: Border.all(color: MysticColors.gold.withValues(alpha: .5)),
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
            right: 2,
            top: 2,
            child: CircleAvatar(
              radius: 11,
              backgroundColor: MysticColors.gold,
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

class _PathLines extends CustomPainter {
  const _PathLines();

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

class _Feature extends StatelessWidget {
  const _Feature(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 14,
        backgroundColor: MysticColors.gold.withValues(alpha: .16),
        child: const Icon(Icons.check, size: 16, color: MysticColors.gold),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.icon});

  final String text;
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
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

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
      letterSpacing: 1.2,
      color: MysticColors.gold,
    ),
  );
}
