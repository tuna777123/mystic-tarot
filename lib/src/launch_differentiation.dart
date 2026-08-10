import 'package:flutter/material.dart';

import 'flagship.dart';
import 'theme.dart';

class LaunchContinuityTimeline extends StatelessWidget {
  const LaunchContinuityTimeline({
    required this.language,
    this.compact = false,
    this.showTitle = true,
    super.key,
  });

  final MysticLanguage language;
  final bool compact;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final steps = <_ContinuityStep>[
      _ContinuityStep(
        icon: Icons.auto_awesome_rounded,
        label: _copy(
          language,
          en: 'NOW',
          es: 'AHORA',
          fr: 'MAINTENANT',
          pt: 'AGORA',
          tr: 'ŞİMDİ',
        ),
        body: _copy(
          language,
          en: 'Read, choose one aligned action, and keep the moment privately.',
          es: 'Lee, elige una acción alineada y guarda el momento en privado.',
          fr: 'Lisez, choisissez une action alignée et gardez ce moment en privé.',
          pt: 'Leia, escolha uma ação alinhada e guarde o momento em privado.',
          tr: 'Oku, tek bir uyumlu eylem seç ve bu anı özel olarak sakla.',
        ),
      ),
      _ContinuityStep(
        icon: Icons.compare_arrows_rounded,
        label: _copy(
          language,
          en: 'TOMORROW',
          es: 'MAÑANA',
          fr: 'DEMAIN',
          pt: 'AMANHÃ',
          tr: 'YARIN',
        ),
        body: _copy(
          language,
          en: 'Mystic Mirror asks what actually happened — not whether tarot was “right.”',
          es: 'Mystic Mirror pregunta qué ocurrió de verdad, no si el tarot “acertó”.',
          fr: 'Mystic Mirror demande ce qui s’est vraiment passé, pas si le tarot avait « raison ».',
          pt: 'O Mystic Mirror pergunta o que realmente aconteceu — não se o tarô “acertou”.',
          tr: 'Mystic Mirror tarotun “doğru çıkıp çıkmadığını” değil, gerçekte ne olduğunu sorar.',
        ),
      ),
      _ContinuityStep(
        icon: Icons.insights_rounded,
        label: _copy(
          language,
          en: 'WITH EVIDENCE',
          es: 'CON EVIDENCIA',
          fr: 'AVEC DES INDICES',
          pt: 'COM EVIDÊNCIAS',
          tr: 'KANIT BİRİKTİKÇE',
        ),
        body: _copy(
          language,
          en: 'Repeated check-ins reveal the cards, emotions, and choices that keep returning.',
          es: 'Las revisiones repetidas revelan las cartas, emociones y decisiones que vuelven.',
          fr: 'Les bilans répétés révèlent les cartes, émotions et choix qui reviennent.',
          pt: 'Check-ins repetidos revelam as cartas, emoções e escolhas que continuam voltando.',
          tr: 'Tekrarlanan kontroller geri dönen kartları, duyguları ve seçimleri görünür kılar.',
        ),
      ),
    ];

    return Semantics(
      container: true,
      label: _copy(
        language,
        en: 'Read today. Check reality tomorrow. Build private evidence over time.',
        es: 'Lee hoy. Comprueba la realidad mañana. Construye evidencia privada con el tiempo.',
        fr: 'Lisez aujourd’hui. Vérifiez la réalité demain. Construisez des indices privés dans le temps.',
        pt: 'Leia hoje. Confira a realidade amanhã. Construa evidências privadas ao longo do tempo.',
        tr: 'Bugün oku. Yarın gerçeği kontrol et. Zamanla özel kanıtını oluştur.',
      ),
      child: Container(
        key: const ValueKey('launch-continuity-timeline'),
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF24183E), Color(0xFF120F1D)],
          ),
          borderRadius: BorderRadius.circular(compact ? 18 : 22),
          border: Border.all(
            color: MysticColors.gold.withValues(alpha: .24),
          ),
          boxShadow: [
            BoxShadow(
              color: MysticColors.violet.withValues(alpha: .12),
              blurRadius: compact ? 18 : 26,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: MysticColors.gold.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: MysticColors.gold.withValues(alpha: .2),
                    ),
                  ),
                  child: Text(
                    _copy(
                      language,
                      en: 'PRIVATE EVIDENCE LOOP',
                      es: 'CICLO DE EVIDENCIA PRIVADA',
                      fr: 'BOUCLE D’INDICES PRIVÉE',
                      pt: 'CICLO DE EVIDÊNCIA PRIVADA',
                      tr: 'ÖZEL KANIT DÖNGÜSÜ',
                    ),
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: MysticColors.gold,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .9,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.lock_outline_rounded,
                  color: MysticColors.lavender,
                  size: 16,
                ),
              ],
            ),
            SizedBox(height: compact ? 9 : 11),
            Text(
              _copy(
                language,
                en: 'Read today. Check reality tomorrow.',
                es: 'Lee hoy. Comprueba la realidad mañana.',
                fr: 'Lisez aujourd’hui. Vérifiez la réalité demain.',
                pt: 'Leia hoje. Confira a realidade amanhã.',
                tr: 'Bugün oku. Yarın gerçeği kontrol et.',
              ),
              style: TextStyle(
                color: MysticColors.mist,
                fontSize: compact ? 15 : 18,
                height: 1.12,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (showTitle) ...[
              const SizedBox(height: 5),
              Text(
                _copy(
                  language,
                  en: 'ONE READING BECOMES A CONTINUING STORY.',
                  es: 'UNA LECTURA SE CONVIERTE EN UNA HISTORIA CONTINUA.',
                  fr: 'UN TIRAGE DEVIENT UNE HISTOIRE QUI CONTINUE.',
                  pt: 'UMA LEITURA VIRA UMA HISTÓRIA CONTÍNUA.',
                  tr: 'TEK OKUMA DEVAM EDEN BİR HİKÂYEYE DÖNÜŞÜR.',
                ),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.lavender,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .75,
                ),
              ),
            ],
            SizedBox(height: compact ? 12 : 15),
            for (var index = 0; index < steps.length; index++) ...[
              _TimelineStepRow(step: steps[index], compact: compact),
              if (index != steps.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: compact ? 13 : 15),
                  child: Container(
                    width: 1,
                    height: compact ? 8 : 11,
                    color: MysticColors.gold.withValues(alpha: .2),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class PrivateByDesignCard extends StatelessWidget {
  const PrivateByDesignCard({
    required this.language,
    this.compact = false,
    super.key,
  });

  final MysticLanguage language;
  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: _copy(
      language,
      en: 'Private by design',
      es: 'Privado por diseño',
      fr: 'Privé dès la conception',
      pt: 'Privado desde a concepção',
      tr: 'Tasarımı gereği özel',
    ),
    child: Container(
      key: const ValueKey('private-by-design-card'),
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1830), Color(0xFF12101B)],
        ),
        borderRadius: BorderRadius.circular(compact ? 15 : 19),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 34 : 40,
            height: compact ? 34 : 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MysticColors.gold.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: compact ? 18 : 21,
              color: MysticColors.gold,
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
                    en: 'Private by design',
                    es: 'Privado por diseño',
                    fr: 'Privé dès la conception',
                    pt: 'Privado desde a concepção',
                    tr: 'Tasarımı gereği özel',
                  ),
                  style: TextStyle(
                    color: MysticColors.gold,
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _copy(
                    language,
                    en: 'No account or cloud journal. Your private history stays on this device. Native ads follow the advertising privacy choices available to you; the public web edition is ad-free. You can also protect the whole app with an optional six-digit PIN and biometrics on supported devices.',
                    es: 'Sin cuenta ni diario en la nube. Tu historial privado permanece en este dispositivo. Los anuncios nativos respetan las opciones de privacidad publicitaria disponibles; la versión web pública no tiene anuncios. También puedes proteger toda la app con un PIN opcional de seis dígitos y biometría en dispositivos compatibles.',
                    fr: 'Aucun compte ni journal cloud. Votre historique privé reste sur cet appareil. Les publicités natives respectent les choix de confidentialité publicitaire disponibles ; la version web publique reste sans publicité. Vous pouvez aussi protéger toute l’app avec un code PIN facultatif à six chiffres et la biométrie sur les appareils compatibles.',
                    pt: 'Sem conta ou diário na nuvem. Seu histórico privado fica neste dispositivo. Os anúncios nativos seguem as opções de privacidade de publicidade disponíveis; a versão web pública permanece sem anúncios. Você também pode proteger todo o app com PIN opcional de seis dígitos e biometria em dispositivos compatíveis.',
                    tr: 'Hesap veya bulut günlüğü yok. Özel geçmişin bu cihazda kalır. Native reklamlar sana sunulan reklam gizlilik tercihlerini izler; herkese açık web sürümü reklamsızdır. İstersen tüm uygulamayı altı haneli PIN ve desteklenen cihazlarda biyometriyle de koruyabilirsin.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MysticColors.mist,
                    fontSize: compact ? 10 : 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ContinuityStep {
  const _ContinuityStep({
    required this.icon,
    required this.label,
    required this.body,
  });

  final IconData icon;
  final String label;
  final String body;
}

class _TimelineStepRow extends StatelessWidget {
  const _TimelineStepRow({required this.step, required this.compact});

  final _ContinuityStep step;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: compact ? 27 : 31,
        height: compact ? 27 : 31,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MysticColors.gold.withValues(alpha: .1),
          shape: BoxShape.circle,
          border: Border.all(
            color: MysticColors.gold.withValues(alpha: .22),
          ),
        ),
        child: Icon(
          step.icon,
          color: MysticColors.gold,
          size: compact ? 15 : 17,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.label,
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontSize: compact ? 8 : 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                step.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MysticColors.mist,
                  fontSize: compact ? 10 : 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
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
