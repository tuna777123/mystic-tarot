import 'package:flutter/material.dart';

import 'flagship.dart';
import 'models.dart';
import 'tarot_localization.dart';
import 'theme.dart';

class ReadingExplanation {
  const ReadingExplanation({
    required this.title,
    required this.positionLabel,
    required this.orientationLabel,
    required this.symbolicBasis,
    required this.practicalBridge,
    required this.contextLabel,
    required this.boundary,
  });

  final String title;
  final String positionLabel;
  final String orientationLabel;
  final String symbolicBasis;
  final String practicalBridge;
  final String contextLabel;
  final String boundary;
}

ReadingExplanation buildReadingExplanation({
  required DrawnCard card,
  required int positionIndex,
  required EmotionalState emotion,
  required String intention,
  required MysticLanguage language,
}) {
  final code = language.code;
  final cardName = localizedTarotCardName(card.card.name, languageCode: code);
  final meaning = localizedTarotCardMeaning(card, languageCode: code);
  final advice = localizedTarotCardAdvice(card, languageCode: code);
  final emotionLabel = localizedEmotionLabel(emotion, languageCode: code);

  String copy({
    required String en,
    required String tr,
    required String es,
    required String fr,
    required String pt,
  }) =>
      switch (language) {
        MysticLanguage.turkish => tr,
        MysticLanguage.spanish => es,
        MysticLanguage.french => fr,
        MysticLanguage.portugueseBrazil => pt,
        _ => en,
      };

  final positions = <String>[
    copy(
      en: 'What surrounds you',
      tr: 'Seni çevreleyen enerji',
      es: 'Lo que te rodea',
      fr: 'Ce qui vous entoure',
      pt: 'O que está ao seu redor',
    ),
    copy(
      en: 'What asks for attention',
      tr: 'Dikkat isteyen konu',
      es: 'Lo que necesita atención',
      fr: 'Ce qui demande votre attention',
      pt: 'O que pede atenção',
    ),
    copy(
      en: 'Your next aligned step',
      tr: 'Sıradaki uyumlu adım',
      es: 'Tu siguiente paso alineado',
      fr: 'Votre prochaine étape alignée',
      pt: 'Seu próximo passo alinhado',
    ),
  ];
  final position = positionIndex < positions.length
      ? positions[positionIndex]
      : copy(
          en: 'Supporting message ${positionIndex + 1}',
          tr: 'Destekleyici mesaj ${positionIndex + 1}',
          es: 'Mensaje de apoyo ${positionIndex + 1}',
          fr: 'Message complémentaire ${positionIndex + 1}',
          pt: 'Mensagem de apoio ${positionIndex + 1}',
        );

  final orientation = card.reversed
      ? copy(
          en: '$cardName is reversed, so Mystic reads its blocked, internal, delayed, or overextended expression.',
          tr: '$cardName ters geldiği için Mystic kartın engellenmiş, içe dönmüş, gecikmiş veya aşırıya kaçmış ifadesini okur.',
          es: '$cardName está invertida, por lo que Mystic observa una expresión bloqueada, interna, retrasada o excesiva.',
          fr: '$cardName est renversée : Mystic observe donc une expression bloquée, intérieure, retardée ou excessive.',
          pt: '$cardName está invertida, então Mystic observa uma expressão bloqueada, interna, atrasada ou excessiva.',
        )
      : copy(
          en: '$cardName is upright, so Mystic begins with its direct, available, or outward expression.',
          tr: '$cardName düz geldiği için Mystic kartın doğrudan, erişilebilir veya dışa dönük ifadesinden başlar.',
          es: '$cardName está al derecho, por lo que Mystic parte de su expresión directa, disponible o exterior.',
          fr: '$cardName est à l’endroit : Mystic part donc de son expression directe, disponible ou extérieure.',
          pt: '$cardName está na posição normal, então Mystic parte de sua expressão direta, disponível ou externa.',
        );

  final cleanIntention = intention.trim().isEmpty
      ? copy(
          en: 'your chosen path',
          tr: 'seçtiğin yol',
          es: 'tu camino elegido',
          fr: 'votre chemin choisi',
          pt: 'seu caminho escolhido',
        )
      : intention.trim();

  return ReadingExplanation(
    title: copy(
      en: 'Why this interpretation?',
      tr: 'Bu yorum neden çıktı?',
      es: '¿Por qué esta interpretación?',
      fr: 'Pourquoi cette interprétation ?',
      pt: 'Por que esta interpretação?',
    ),
    positionLabel: copy(
      en: 'Position lens: $position. The same card can carry a different emphasis in another position.',
      tr: 'Konum merceği: $position. Aynı kart başka bir konumda farklı bir vurgu taşıyabilir.',
      es: 'Enfoque de la posición: $position. La misma carta puede tener otro énfasis en una posición diferente.',
      fr: 'Angle de la position : $position. Une même carte peut porter un autre accent ailleurs dans le tirage.',
      pt: 'Lente da posição: $position. A mesma carta pode ter outra ênfase em uma posição diferente.',
    ),
    orientationLabel: orientation,
    symbolicBasis: copy(
      en: 'Symbolic basis: $meaning',
      tr: 'Sembolik temel: $meaning',
      es: 'Base simbólica: $meaning',
      fr: 'Base symbolique : $meaning',
      pt: 'Base simbólica: $meaning',
    ),
    practicalBridge: copy(
      en: 'Practical bridge: $advice',
      tr: 'Pratik köprü: $advice',
      es: 'Puente práctico: $advice',
      fr: 'Passage à l’action : $advice',
      pt: 'Ponte prática: $advice',
    ),
    contextLabel: copy(
      en: 'Context used: you began feeling ${emotionLabel.toLowerCase()} and selected “$cleanIntention.” Mystic uses that context to frame the card; it does not alter the card’s stored meaning.',
      tr: 'Kullanılan bağlam: okumaya ${emotionLabel.toLowerCase()} hissederek başladın ve “$cleanIntention” yolunu seçtin. Mystic bu bağlamı kartı çerçevelemek için kullanır; kartın kayıtlı anlamını değiştirmez.',
      es: 'Contexto utilizado: comenzaste sintiéndote ${emotionLabel.toLowerCase()} y elegiste “$cleanIntention”. Mystic usa ese contexto para enmarcar la carta; no modifica su significado guardado.',
      fr: 'Contexte utilisé : vous avez commencé en vous sentant ${emotionLabel.toLowerCase()} et choisi « $cleanIntention ». Mystic utilise ce contexte pour cadrer la carte sans modifier son sens enregistré.',
      pt: 'Contexto usado: você começou se sentindo ${emotionLabel.toLowerCase()} e escolheu “$cleanIntention”. Mystic usa esse contexto para enquadrar a carta; ele não altera seu significado registrado.',
    ),
    boundary: copy(
      en: 'This is a transparent symbolic explanation, not proof, diagnosis, certainty, or a prediction score.',
      tr: 'Bu, şeffaf bir sembolik açıklamadır; kanıt, teşhis, kesinlik veya kehanet puanı değildir.',
      es: 'Es una explicación simbólica transparente, no una prueba, un diagnóstico, una certeza ni una puntuación predictiva.',
      fr: 'Il s’agit d’une explication symbolique transparente, pas d’une preuve, d’un diagnostic, d’une certitude ni d’un score prédictif.',
      pt: 'Esta é uma explicação simbólica transparente, não uma prova, diagnóstico, certeza ou pontuação de previsão.',
    ),
  );
}

class ReadingExplanationPanel extends StatelessWidget {
  const ReadingExplanationPanel({
    required this.explanation,
    super.key,
  });

  final ReadingExplanation explanation;

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
          leading: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MysticColors.violet.withValues(alpha: .22),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 18,
              color: MysticColors.gold,
            ),
          ),
          title: Text(
            explanation.title,
            style: const TextStyle(
              color: MysticColors.lavender,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExplanationRow(
                    icon: Icons.filter_1_outlined,
                    text: explanation.positionLabel,
                  ),
                  _ExplanationRow(
                    icon: Icons.screen_rotation_alt_outlined,
                    text: explanation.orientationLabel,
                  ),
                  _ExplanationRow(
                    icon: Icons.auto_stories_outlined,
                    text: explanation.symbolicBasis,
                  ),
                  _ExplanationRow(
                    icon: Icons.directions_walk_outlined,
                    text: explanation.practicalBridge,
                  ),
                  _ExplanationRow(
                    icon: Icons.tune_rounded,
                    text: explanation.contextLabel,
                  ),
                  const Divider(height: 20, color: Colors.white10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: MysticColors.gold,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          explanation.boundary,
                          style: const TextStyle(
                            color: MysticColors.muted,
                            fontSize: 10,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ExplanationRow extends StatelessWidget {
  const _ExplanationRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: MysticColors.lavender),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: MysticColors.mist,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      );
}
