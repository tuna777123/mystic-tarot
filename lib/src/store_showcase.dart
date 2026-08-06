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

const _copy = <String, Map<MysticLanguage, String>>{
  'dailyLabel': {
    MysticLanguage.english: 'DAILY GUIDANCE',
    MysticLanguage.turkish: 'GÜNLÜK REHBERLİK',
    MysticLanguage.spanish: 'GUÍA DIARIA',
    MysticLanguage.french: 'GUIDANCE DU JOUR',
    MysticLanguage.portugueseBrazil: 'ORIENTAÇÃO DIÁRIA',
  },
  'dailyTitle': {
    MysticLanguage.english: 'Your daily guidance, grounded in you.',
    MysticLanguage.turkish: 'Günlük rehberliğin, sana göre şekillenir.',
    MysticLanguage.spanish: 'Tu guía diaria, conectada contigo.',
    MysticLanguage.french: 'Votre guidance du jour, ancrée en vous.',
    MysticLanguage.portugueseBrazil:
        'Sua orientação diária, conectada a você.',
  },
  'dailySubtitle': {
    MysticLanguage.english:
        'A focused ritual built around your intention, mood, and chosen deck.',
    MysticLanguage.turkish:
        'Niyetin, duygun ve seçtiğin desteye göre odaklanan bir ritüel.',
    MysticLanguage.spanish:
        'Un ritual enfocado en tu intención, emoción y mazo elegido.',
    MysticLanguage.french:
        'Un rituel centré sur votre intention, votre émotion et votre jeu.',
    MysticLanguage.portugueseBrazil:
        'Um ritual focado na sua intenção, emoção e baralho escolhido.',
  },
  'dailyAdvice': {
    MysticLanguage.english:
        'Pause before naming uncertainty as fact.',
    MysticLanguage.turkish:
        'Belirsizliğe gerçek demeden önce dur.',
    MysticLanguage.spanish:
        'Pausa antes de llamar hecho a la incertidumbre.',
    MysticLanguage.french:
        'Faites une pause avant de nommer l’incertain comme un fait.',
    MysticLanguage.portugueseBrazil:
        'Pause antes de chamar a incerteza de fato.',
  },
  'readingLabel': {
    MysticLanguage.english: 'EXPLAINABLE READINGS',
    MysticLanguage.turkish: 'AÇIKLANABİLİR OKUMALAR',
    MysticLanguage.spanish: 'LECTURAS EXPLICABLES',
    MysticLanguage.french: 'LECTURES EXPLICABLES',
    MysticLanguage.portugueseBrazil: 'LEITURAS EXPLICÁVEIS',
  },
  'readingTitle': {
    MysticLanguage.english: 'See how every card shaped the reading.',
    MysticLanguage.turkish:
        'Her kartın yorumu nasıl şekillendirdiğini gör.',
    MysticLanguage.spanish:
        'Descubre cómo cada carta dio forma a la lectura.',
    MysticLanguage.french:
        'Voyez comment chaque carte façonne la lecture.',
    MysticLanguage.portugueseBrazil:
        'Veja como cada carta formou a leitura.',
  },
  'readingSubtitle': {
    MysticLanguage.english:
        'Position, orientation, evidence, and next step stay visible.',
    MysticLanguage.turkish:
        'Konum, yön, kanıt ve sonraki adım görünür kalır.',
    MysticLanguage.spanish:
        'La posición, orientación, evidencia y próximo paso son visibles.',
    MysticLanguage.french:
        'Position, orientation, indices et prochaine étape restent visibles.',
    MysticLanguage.portugueseBrazil:
        'Posição, orientação, evidências e próximo passo ficam visíveis.',
  },
  'coreMessage': {
    MysticLanguage.english: 'Core message',
    MysticLanguage.turkish: 'Ana mesaj',
    MysticLanguage.spanish: 'Mensaje central',
    MysticLanguage.french: 'Message central',
    MysticLanguage.portugueseBrazil: 'Mensagem central',
  },
  'coreBody': {
    MysticLanguage.english:
        'Hope becomes useful when it is paired with a named direction.',
    MysticLanguage.turkish:
        'Umut, adı konmuş bir yönle birleştiğinde işe yarar.',
    MysticLanguage.spanish:
        'La esperanza sirve cuando se une a una dirección clara.',
    MysticLanguage.french:
        'L’espoir devient utile lorsqu’il rejoint une direction claire.',
    MysticLanguage.portugueseBrazil:
        'A esperança se torna útil quando encontra uma direção clara.',
  },
  'whyCards': {
    MysticLanguage.english: 'Why these cards',
    MysticLanguage.turkish: 'Neden bu kartlar',
    MysticLanguage.spanish: 'Por qué estas cartas',
    MysticLanguage.french: 'Pourquoi ces cartes',
    MysticLanguage.portugueseBrazil: 'Por que estas cartas',
  },
  'whyBody': {
    MysticLanguage.english:
        'The present card softens the pause; the next card turns it into movement.',
    MysticLanguage.turkish:
        'Şimdiki kart duraklamayı yumuşatır; sonraki kart onu harekete çevirir.',
    MysticLanguage.spanish:
        'La carta presente suaviza la pausa; la siguiente la convierte en movimiento.',
    MysticLanguage.french:
        'La carte présente adoucit la pause; la suivante la transforme en mouvement.',
    MysticLanguage.portugueseBrazil:
        'A carta presente suaviza a pausa; a próxima a transforma em movimento.',
  },
  'nextStep': {
    MysticLanguage.english: 'Grounded next step',
    MysticLanguage.turkish: 'Somut sonraki adım',
    MysticLanguage.spanish: 'Próximo paso concreto',
    MysticLanguage.french: 'Prochaine étape concrète',
    MysticLanguage.portugueseBrazil: 'Próximo passo concreto',
  },
  'nextBody': {
    MysticLanguage.english:
        'Write one destination before increasing your speed.',
    MysticLanguage.turkish:
        'Hızını artırmadan önce tek bir varış noktası yaz.',
    MysticLanguage.spanish:
        'Escribe un destino antes de aumentar la velocidad.',
    MysticLanguage.french:
        'Écrivez une destination avant d’accélérer.',
    MysticLanguage.portugueseBrazil:
        'Escreva um destino antes de aumentar a velocidade.',
  },
  'mirrorTitle': {
    MysticLanguage.english:
        'Return in 24 hours. Compare guidance with reality.',
    MysticLanguage.turkish:
        '24 saat sonra dön. Rehberliği gerçekle karşılaştır.',
    MysticLanguage.spanish:
        'Vuelve en 24 horas. Compara la guía con la realidad.',
    MysticLanguage.french:
        'Revenez dans 24 heures. Comparez au réel.',
    MysticLanguage.portugueseBrazil:
        'Volte em 24 horas. Compare a orientação com a realidade.',
  },
  'mirrorSubtitle': {
    MysticLanguage.english:
        'Close the loop instead of collecting endless predictions.',
    MysticLanguage.turkish:
        'Sonsuz tahmin biriktirmek yerine döngüyü kapat.',
    MysticLanguage.spanish:
        'Cierra el ciclo en vez de acumular predicciones.',
    MysticLanguage.french:
        'Fermez la boucle au lieu d’accumuler des prédictions.',
    MysticLanguage.portugueseBrazil:
        'Feche o ciclo em vez de acumular previsões.',
  },
  'yesterday': {
    MysticLanguage.english: 'YESTERDAY’S GUIDANCE',
    MysticLanguage.turkish: 'DÜNÜN REHBERLİĞİ',
    MysticLanguage.spanish: 'GUÍA DE AYER',
    MysticLanguage.french: 'GUIDANCE D’HIER',
    MysticLanguage.portugueseBrazil: 'ORIENTAÇÃO DE ONTEM',
  },
  'yesterdayBody': {
    MysticLanguage.english: 'Listen beneath the noise before choosing.',
    MysticLanguage.turkish: 'Seçmeden önce gürültünün altını dinle.',
    MysticLanguage.spanish: 'Escucha bajo el ruido antes de elegir.',
    MysticLanguage.french: 'Écoutez sous le bruit avant de choisir.',
    MysticLanguage.portugueseBrazil:
        'Escute por baixo do ruído antes de escolher.',
  },
  'whatHappened': {
    MysticLanguage.english: 'What actually happened?',
    MysticLanguage.turkish: 'Gerçekte ne oldu?',
    MysticLanguage.spanish: '¿Qué ocurrió realmente?',
    MysticLanguage.french: 'Que s’est-il vraiment passé ?',
    MysticLanguage.portugueseBrazil: 'O que realmente aconteceu?',
  },
  'matchedReality': {
    MysticLanguage.english: 'It matched reality',
    MysticLanguage.turkish: 'Gerçekle örtüştü',
    MysticLanguage.spanish: 'Coincidió con la realidad',
    MysticLanguage.french: 'Cela correspondait au réel',
    MysticLanguage.portugueseBrazil: 'Combinou com a realidade',
  },
  'changedMeaning': {
    MysticLanguage.english: 'Reality changed the meaning',
    MysticLanguage.turkish: 'Gerçek anlamı değiştirdi',
    MysticLanguage.spanish: 'La realidad cambió el significado',
    MysticLanguage.french: 'Le réel a changé le sens',
    MysticLanguage.portugueseBrazil: 'A realidade mudou o significado',
  },
  'stillUnfolding': {
    MysticLanguage.english: 'Still unfolding',
    MysticLanguage.turkish: 'Hâlâ gelişiyor',
    MysticLanguage.spanish: 'Aún se está desarrollando',
    MysticLanguage.french: 'Toujours en évolution',
    MysticLanguage.portugueseBrazil: 'Ainda se desenvolvendo',
  },
  'pathLabel': {
    MysticLanguage.english: 'LIVING FATE MAP',
    MysticLanguage.turkish: 'YAŞAYAN KADER HARİTASI',
    MysticLanguage.spanish: 'MAPA VIVO DEL DESTINO',
    MysticLanguage.french: 'CARTE VIVANTE DU DESTIN',
    MysticLanguage.portugueseBrazil: 'MAPA VIVO DO DESTINO',
  },
  'pathTitle': {
    MysticLanguage.english: 'Your symbols become a living map.',
    MysticLanguage.turkish:
        'Sembollerin yaşayan bir haritaya dönüşür.',
    MysticLanguage.spanish:
        'Tus símbolos se convierten en un mapa vivo.',
    MysticLanguage.french:
        'Vos symboles deviennent une carte vivante.',
    MysticLanguage.portugueseBrazil:
        'Seus símbolos se tornam um mapa vivo.',
  },
  'pathSubtitle': {
    MysticLanguage.english:
        'Repeated cards, themes, and reflections reveal your private pattern.',
    MysticLanguage.turkish:
        'Tekrarlayan kartlar, temalar ve yansımalar özel örüntünü gösterir.',
    MysticLanguage.spanish:
        'Cartas, temas y reflexiones repetidos revelan tu patrón privado.',
    MysticLanguage.french:
        'Cartes, thèmes et retours répétés révèlent votre motif privé.',
    MysticLanguage.portugueseBrazil:
        'Cartas, temas e reflexões repetidas revelam seu padrão privado.',
  },
  'pattern': {
    MysticLanguage.english: 'RECURRING PATTERN',
    MysticLanguage.turkish: 'TEKRARLAYAN ÖRÜNTÜ',
    MysticLanguage.spanish: 'PATRÓN RECURRENTE',
    MysticLanguage.french: 'MOTIF RÉCURRENT',
    MysticLanguage.portugueseBrazil: 'PADRÃO RECORRENTE',
  },
  'patternBody': {
    MysticLanguage.english:
        'Intuition appears before decisive movement.',
    MysticLanguage.turkish:
        'Sezgi, kararlı hareketten önce beliriyor.',
    MysticLanguage.spanish:
        'La intuición aparece antes del movimiento decisivo.',
    MysticLanguage.french:
        'L’intuition apparaît avant le mouvement décisif.',
    MysticLanguage.portugueseBrazil:
        'A intuição aparece antes do movimento decisivo.',
  },
  'plusTitle': {
    MysticLanguage.english: 'Go deeper without losing trust.',
    MysticLanguage.turkish: 'Güveni kaybetmeden daha derine in.',
    MysticLanguage.spanish: 'Profundiza sin perder la confianza.',
    MysticLanguage.french: 'Allez plus loin sans perdre confiance.',
    MysticLanguage.portugueseBrazil:
        'Aprofunde-se sem perder a confiança.',
  },
  'plusSubtitle': {
    MysticLanguage.english:
        'Deep readings and private intelligence, with official store pricing.',
    MysticLanguage.turkish:
        'Derin okumalar ve özel içgörüler; resmi mağaza fiyatlarıyla.',
    MysticLanguage.spanish:
        'Lecturas profundas e inteligencia privada con precio oficial.',
    MysticLanguage.french:
        'Lectures profondes et intelligence privée, au tarif officiel.',
    MysticLanguage.portugueseBrazil:
        'Leituras profundas e inteligência privada com preço oficial.',
  },
  'monthly': {
    MysticLanguage.english: 'MONTHLY',
    MysticLanguage.turkish: 'AYLIK',
    MysticLanguage.spanish: 'MENSUAL',
    MysticLanguage.french: 'MENSUEL',
    MysticLanguage.portugueseBrazil: 'MENSAL',
  },
  'yearly': {
    MysticLanguage.english: 'YEARLY',
    MysticLanguage.turkish: 'YILLIK',
    MysticLanguage.spanish: 'ANUAL',
    MysticLanguage.french: 'ANNUEL',
    MysticLanguage.portugueseBrazil: 'ANUAL',
  },
  'officialPrice': {
    MysticLanguage.english: 'Official price shown by your store',
    MysticLanguage.turkish: 'Resmi fiyat mağazan tarafından gösterilir',
    MysticLanguage.spanish: 'Tu tienda muestra el precio oficial',
    MysticLanguage.french:
        'Le prix officiel est affiché par votre boutique',
    MysticLanguage.portugueseBrazil:
        'O preço oficial é exibido pela sua loja',
  },
  'deepSpreads': {
    MysticLanguage.english: 'All deep spreads',
    MysticLanguage.turkish: 'Tüm derin açılımlar',
    MysticLanguage.spanish: 'Todas las tiradas profundas',
    MysticLanguage.french: 'Tous les tirages approfondis',
    MysticLanguage.portugueseBrazil: 'Todas as tiragens profundas',
  },
  'weeklyIntel': {
    MysticLanguage.english: 'Private weekly intelligence',
    MysticLanguage.turkish: 'Özel haftalık içgörü',
    MysticLanguage.spanish: 'Inteligencia semanal privada',
    MysticLanguage.french: 'Intelligence hebdomadaire privée',
    MysticLanguage.portugueseBrazil: 'Inteligência semanal privada',
  },
  'restoreManage': {
    MysticLanguage.english: 'Restore and manage anytime',
    MysticLanguage.turkish: 'İstediğin zaman geri yükle ve yönet',
    MysticLanguage.spanish: 'Restaura y gestiona cuando quieras',
    MysticLanguage.french: 'Restaurez et gérez à tout moment',
    MysticLanguage.portugueseBrazil:
        'Restaure e gerencie quando quiser',
  },
  'continueYearly': {
    MysticLanguage.english: 'CONTINUE WITH YEARLY',
    MysticLanguage.turkish: 'YILLIK İLE DEVAM ET',
    MysticLanguage.spanish: 'CONTINUAR CON ANUAL',
    MysticLanguage.french: 'CONTINUER EN ANNUEL',
    MysticLanguage.portugueseBrazil: 'CONTINUAR COM ANUAL',
  },
  'trust': {
    MysticLanguage.english: 'PRIVATE • LOCAL-FIRST • FOR REFLECTION',
    MysticLanguage.turkish: 'ÖZEL • YEREL ÖNCELİKLİ • YANSIMA İÇİN',
    MysticLanguage.spanish:
        'PRIVADO • LOCAL PRIMERO • PARA REFLEXIONAR',
    MysticLanguage.french:
        'PRIVÉ • LOCAL D’ABORD • POUR RÉFLÉCHIR',
    MysticLanguage.portugueseBrazil:
        'PRIVADO • LOCAL PRIMEIRO • PARA REFLEXÃO',
  },
};

String _t(MysticLanguage language, String key) =>
    _copy[key]?[language] ?? _copy[key]![MysticLanguage.english]!;

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

  @override
  Widget build(BuildContext context) {
    final label = switch (scene) {
      StoreScreenshotScene.dailyGuidance => _t(language, 'dailyLabel'),
      StoreScreenshotScene.explainableReading => _t(language, 'readingLabel'),
      StoreScreenshotScene.mysticMirror => 'MYSTIC MIRROR',
      StoreScreenshotScene.livingPath => _t(language, 'pathLabel'),
      StoreScreenshotScene.mysticPlus => 'MYSTIC PLUS',
    };
    final title = switch (scene) {
      StoreScreenshotScene.dailyGuidance => _t(language, 'dailyTitle'),
      StoreScreenshotScene.explainableReading => _t(language, 'readingTitle'),
      StoreScreenshotScene.mysticMirror => _t(language, 'mirrorTitle'),
      StoreScreenshotScene.livingPath => _t(language, 'pathTitle'),
      StoreScreenshotScene.mysticPlus => _t(language, 'plusTitle'),
    };
    final subtitle = switch (scene) {
      StoreScreenshotScene.dailyGuidance => _t(language, 'dailySubtitle'),
      StoreScreenshotScene.explainableReading =>
        _t(language, 'readingSubtitle'),
      StoreScreenshotScene.mysticMirror => _t(language, 'mirrorSubtitle'),
      StoreScreenshotScene.livingPath => _t(language, 'pathSubtitle'),
      StoreScreenshotScene.mysticPlus => _t(language, 'plusSubtitle'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 10),
        Text(
          title,
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
        const SizedBox(height: 20),
        Expanded(child: _body()),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 14, color: MysticColors.muted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _t(language, 'trust'),
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
        ),
      ],
    );
  }

  Widget _body() => switch (scene) {
    StoreScreenshotScene.dailyGuidance => _daily(),
    StoreScreenshotScene.explainableReading => _reading(),
    StoreScreenshotScene.mysticMirror => _mirror(),
    StoreScreenshotScene.livingPath => _path(),
    StoreScreenshotScene.mysticPlus => _plus(),
  };

  Widget _daily() => Column(
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
                  name: 'The Star',
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
                  name: 'Strength',
                  compact: true,
                ),
              ),
            ),
            _Tarot(
              symbol: tarotDeck[18].symbol,
              number: tarotDeck[18].number,
              name: 'The Moon',
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: const [
          Expanded(child: _Metric(value: 'Clarity', label: 'INTENTION')),
          SizedBox(width: 10),
          Expanded(child: _Metric(value: 'Reflective', label: 'MOOD')),
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
                _t(language, 'dailyAdvice'),
                style: const TextStyle(fontSize: 16, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _reading() => Column(
    children: [
      Row(
        children: [
          Expanded(child: _Position('PAST', tarotDeck[12].symbol, 'New view')),
          const SizedBox(width: 8),
          Expanded(child: _Position('PRESENT', tarotDeck[17].symbol, 'Renewal')),
          const SizedBox(width: 8),
          Expanded(child: _Position('NEXT', tarotDeck[7].symbol, 'Direction')),
        ],
      ),
      const SizedBox(height: 14),
      Expanded(
        child: _Panel(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _Insight('01', _t(language, 'coreMessage'), _t(language, 'coreBody')),
              const Divider(height: 24),
              _Insight('02', _t(language, 'whyCards'), _t(language, 'whyBody')),
              const Divider(height: 24),
              _Insight('03', _t(language, 'nextStep'), _t(language, 'nextBody')),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _mirror() => Column(
    children: [
      _Panel(
        child: Row(
          children: [
            _Tarot(
              symbol: tarotDeck[2].symbol,
              number: tarotDeck[2].number,
              name: '',
              tiny: true,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(_t(language, 'yesterday')),
                  const SizedBox(height: 7),
                  Text(
                    _t(language, 'yesterdayBody'),
                    style: const TextStyle(fontSize: 17, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Expanded(
        child: _Panel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Chip(text: '24 HOURS LATER', icon: Icons.schedule),
              const SizedBox(height: 17),
              Text(
                _t(language, 'whatHappened'),
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your reflection becomes evidence for future readings and stays private on this device.',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  height: 1.45,
                  color: MysticColors.muted,
                ),
              ),
              const Spacer(),
              _Choice(_t(language, 'matchedReality'), selected: true),
              const SizedBox(height: 9),
              _Choice(_t(language, 'changedMeaning')),
              const SizedBox(height: 9),
              _Choice(_t(language, 'stillUnfolding')),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _path() => Column(
    children: [
      Expanded(
        child: _Panel(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(child: _Metric(value: '12', label: 'READINGS')),
                  SizedBox(width: 8),
                  Expanded(child: _Metric(value: '4', label: 'MIRRORS')),
                  SizedBox(width: 8),
                  Expanded(child: _Metric(value: '7', label: 'DAY STREAK')),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    const Positioned.fill(child: CustomPaint(painter: _PathLines())),
                    Positioned(left: 20, top: 20, child: _Node(tarotDeck[17].symbol, '4×')),
                    Positioned(right: 20, top: 72, child: _Node(tarotDeck[2].symbol, '3×')),
                    Positioned(
                      left: 116,
                      top: 126,
                      child: _Node(tarotDeck[18].symbol, '5×', primary: true),
                    ),
                    Positioned(left: 24, bottom: 22, child: _Node(tarotDeck[8].symbol, '2×')),
                    Positioned(right: 32, bottom: 10, child: _Node(tarotDeck[21].symbol, '2×')),
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
                  _Label(_t(language, 'pattern')),
                  const SizedBox(height: 6),
                  Text(
                    _t(language, 'patternBody'),
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

  Widget _plus() => Column(
    children: [
      Row(
        children: [
          Expanded(child: _Plan(_t(language, 'monthly'))),
          const SizedBox(width: 10),
          Expanded(child: _Plan(_t(language, 'yearly'), selected: true)),
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
                      Icons.workspace_premium,
                      color: Color(0xFF18101F),
                    ),
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
                          _t(language, 'officialPrice'),
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
              _Feature(_t(language, 'deepSpreads')),
              const SizedBox(height: 16),
              _Feature(_t(language, 'weeklyIntel')),
              const SizedBox(height: 16),
              _Feature(_t(language, 'restoreManage')),
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
                  _t(language, 'continueYearly'),
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
    final width = tiny ? 62.0 : compact ? 112.0 : 164.0;
    final height = tiny ? 82.0 : compact ? 178.0 : 252.0;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(tiny ? 8 : compact ? 12 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF33224F), Color(0xFF171125), Color(0xFF0E0C18)],
        ),
        borderRadius: BorderRadius.circular(tiny ? 16 : compact ? 18 : 24),
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
              fontSize: tiny ? 34 : compact ? 44 : 68,
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
  const _Position(this.position, this.symbol, this.name);

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
        Text(symbol, style: const TextStyle(fontSize: 30, color: MysticColors.gold)),
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
  const _Insight(this.index, this.title, this.body);

  final String index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        radius: 17,
        backgroundColor: MysticColors.violet.withValues(alpha: .25),
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

class _Choice extends StatelessWidget {
  const _Choice(this.text, {this.selected = false});

  final String text;
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
        Icon(
          selected ? Icons.check_circle_outline : Icons.circle_outlined,
          size: 20,
          color: selected ? MysticColors.lavender : MysticColors.muted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 13,
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
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
            letterSpacing: .7,
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

class _Plan extends StatelessWidget {
  const _Plan(this.text, {this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      color: selected
          ? MysticColors.violet.withValues(alpha: .26)
          : const Color(0xFF171329),
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
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ),
      ],
    ),
  );
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
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
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
