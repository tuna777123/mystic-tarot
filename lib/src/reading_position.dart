import 'flagship.dart';
import 'models.dart';

String localizedReadingPosition({
  required ReadingKind kind,
  required int index,
  required MysticLanguage language,
}) {
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

  List<String> positionsFor(ReadingKind value) => switch (value) {
        ReadingKind.daily => <String>[
            copy(
              en: 'Today’s central focus',
              tr: 'Bugünün merkezindeki konu',
              es: 'El enfoque central de hoy',
              fr: 'Le thème central du jour',
              pt: 'O foco central de hoje',
            ),
          ],
        ReadingKind.love => <String>[
            copy(
              en: 'Your heart',
              tr: 'Senin kalbin',
              es: 'Tu corazón',
              fr: 'Votre cœur',
              pt: 'Seu coração',
            ),
            copy(
              en: 'What shapes the connection',
              tr: 'Bağı şekillendiren etki',
              es: 'Lo que da forma al vínculo',
              fr: 'Ce qui façonne le lien',
              pt: 'O que molda a conexão',
            ),
            copy(
              en: 'The next honest step',
              tr: 'Sıradaki dürüst adım',
              es: 'El siguiente paso honesto',
              fr: 'La prochaine étape honnête',
              pt: 'O próximo passo honesto',
            ),
          ],
        ReadingKind.career => <String>[
            copy(
              en: 'Your current professional position',
              tr: 'Mevcut profesyonel konumun',
              es: 'Tu posición profesional actual',
              fr: 'Votre position professionnelle actuelle',
              pt: 'Sua posição profissional atual',
            ),
            copy(
              en: 'The opportunity or pressure emerging',
              tr: 'Ortaya çıkan fırsat veya baskı',
              es: 'La oportunidad o presión que aparece',
              fr: 'L’opportunité ou la pression qui émerge',
              pt: 'A oportunidade ou pressão que surge',
            ),
            copy(
              en: 'Your next useful move',
              tr: 'Sıradaki faydalı hamlen',
              es: 'Tu siguiente movimiento útil',
              fr: 'Votre prochaine action utile',
              pt: 'Seu próximo movimento útil',
            ),
          ],
        ReadingKind.money => <String>[
            copy(
              en: 'Your current money pattern',
              tr: 'Mevcut para örüntün',
              es: 'Tu patrón financiero actual',
              fr: 'Votre schéma financier actuel',
              pt: 'Seu padrão financeiro atual',
            ),
            copy(
              en: 'The hidden cost or resource',
              tr: 'Gizli maliyet veya kaynak',
              es: 'El coste o recurso oculto',
              fr: 'Le coût ou la ressource cachée',
              pt: 'O custo ou recurso oculto',
            ),
            copy(
              en: 'The grounded financial action',
              tr: 'Somut mali eylem',
              es: 'La acción financiera concreta',
              fr: 'L’action financière concrète',
              pt: 'A ação financeira concreta',
            ),
          ],
        ReadingKind.decision => <String>[
            copy(
              en: 'What the first path emphasizes',
              tr: 'İlk yolun öne çıkardığı şey',
              es: 'Lo que destaca el primer camino',
              fr: 'Ce que souligne la première voie',
              pt: 'O que o primeiro caminho destaca',
            ),
            copy(
              en: 'What the second path emphasizes',
              tr: 'İkinci yolun öne çıkardığı şey',
              es: 'Lo que destaca el segundo camino',
              fr: 'Ce que souligne la seconde voie',
              pt: 'O que o segundo caminho destaca',
            ),
            copy(
              en: 'The value that should guide the choice',
              tr: 'Seçime yön vermesi gereken değer',
              es: 'El valor que debe guiar la elección',
              fr: 'La valeur qui doit guider le choix',
              pt: 'O valor que deve guiar a escolha',
            ),
          ],
        ReadingKind.spiritual => <String>[
            copy(
              en: 'The lesson present now',
              tr: 'Şu anki ders',
              es: 'La lección presente ahora',
              fr: 'La leçon présente maintenant',
              pt: 'A lição presente agora',
            ),
            copy(
              en: 'What your inner voice is protecting',
              tr: 'İç sesinin koruduğu şey',
              es: 'Lo que protege tu voz interior',
              fr: 'Ce que protège votre voix intérieure',
              pt: 'O que sua voz interior protege',
            ),
            copy(
              en: 'The practice that can embody it',
              tr: 'Bunu somutlaştıracak pratik',
              es: 'La práctica que puede encarnarla',
              fr: 'La pratique qui peut l’incarner',
              pt: 'A prática que pode incorporá-la',
            ),
          ],
        ReadingKind.shadow => <String>[
            copy(
              en: 'The visible pattern',
              tr: 'Görünen örüntü',
              es: 'El patrón visible',
              fr: 'Le schéma visible',
              pt: 'O padrão visível',
            ),
            copy(
              en: 'The hidden root',
              tr: 'Gizli kök',
              es: 'La raíz oculta',
              fr: 'La racine cachée',
              pt: 'A raiz oculta',
            ),
            copy(
              en: 'A safer way to integrate it',
              tr: 'Bunu bütünleştirmenin daha güvenli yolu',
              es: 'Una forma más segura de integrarlo',
              fr: 'Une manière plus sûre de l’intégrer',
              pt: 'Uma forma mais segura de integrar isso',
            ),
          ],
        ReadingKind.compatibility => <String>[
            copy(
              en: 'Your energy in the connection',
              tr: 'Bağdaki senin enerjin',
              es: 'Tu energía en la conexión',
              fr: 'Votre énergie dans le lien',
              pt: 'Sua energia na conexão',
            ),
            copy(
              en: 'The other person’s energy',
              tr: 'Diğer kişinin enerjisi',
              es: 'La energía de la otra persona',
              fr: 'L’énergie de l’autre personne',
              pt: 'A energia da outra pessoa',
            ),
            copy(
              en: 'The dynamic between you',
              tr: 'Aranızdaki dinamik',
              es: 'La dinámica entre ustedes',
              fr: 'La dynamique entre vous',
              pt: 'A dinâmica entre vocês',
            ),
          ],
        ReadingKind.timeline => <String>[
            copy(
              en: 'The past influence still active',
              tr: 'Hâlâ etkin olan geçmiş etkisi',
              es: 'La influencia pasada aún activa',
              fr: 'L’influence passée encore active',
              pt: 'A influência passada ainda ativa',
            ),
            copy(
              en: 'The present threshold',
              tr: 'Şimdiki eşik',
              es: 'El umbral presente',
              fr: 'Le seuil présent',
              pt: 'O limiar presente',
            ),
            copy(
              en: 'The nearest possibility',
              tr: 'En yakın ihtimal',
              es: 'La posibilidad más cercana',
              fr: 'La possibilité la plus proche',
              pt: 'A possibilidade mais próxima',
            ),
            copy(
              en: 'The following chapter',
              tr: 'Sonraki bölüm',
              es: 'El capítulo siguiente',
              fr: 'Le chapitre suivant',
              pt: 'O capítulo seguinte',
            ),
            copy(
              en: 'The longer horizon if the pattern continues',
              tr: 'Örüntü sürerse daha uzun vade',
              es: 'El horizonte más lejano si continúa el patrón',
              fr: 'L’horizon plus lointain si le schéma continue',
              pt: 'O horizonte mais longo se o padrão continuar',
            ),
          ],
        ReadingKind.celticCross => <String>[
            copy(en: 'Present situation', tr: 'Mevcut durum', es: 'Situación presente', fr: 'Situation présente', pt: 'Situação presente'),
            copy(en: 'Immediate challenge', tr: 'Yakın meydan okuma', es: 'Desafío inmediato', fr: 'Défi immédiat', pt: 'Desafio imediato'),
            copy(en: 'Foundation beneath the issue', tr: 'Konunun altındaki temel', es: 'Base del asunto', fr: 'Fondation du sujet', pt: 'Base da questão'),
            copy(en: 'Recent past influence', tr: 'Yakın geçmiş etkisi', es: 'Influencia del pasado reciente', fr: 'Influence du passé récent', pt: 'Influência do passado recente'),
            copy(en: 'Conscious possibility', tr: 'Bilinçli ihtimal', es: 'Posibilidad consciente', fr: 'Possibilité consciente', pt: 'Possibilidade consciente'),
            copy(en: 'Near-future movement', tr: 'Yakın gelecek hareketi', es: 'Movimiento del futuro cercano', fr: 'Mouvement du futur proche', pt: 'Movimento do futuro próximo'),
            copy(en: 'Your inner stance', tr: 'İç tutumun', es: 'Tu postura interior', fr: 'Votre posture intérieure', pt: 'Sua postura interior'),
            copy(en: 'External environment', tr: 'Dış çevre', es: 'Entorno externo', fr: 'Environnement extérieur', pt: 'Ambiente externo'),
            copy(en: 'Hopes and fears', tr: 'Umutlar ve korkular', es: 'Esperanzas y temores', fr: 'Espoirs et craintes', pt: 'Esperanças e medos'),
            copy(en: 'Direction if the pattern continues', tr: 'Örüntü sürerse yön', es: 'Dirección si continúa el patrón', fr: 'Direction si le schéma continue', pt: 'Direção se o padrão continuar'),
          ],
      };

  final positions = positionsFor(kind);
  if (index >= 0 && index < positions.length) return positions[index];
  return copy(
    en: 'Supporting message ${index + 1}',
    tr: 'Destekleyici mesaj ${index + 1}',
    es: 'Mensaje de apoyo ${index + 1}',
    fr: 'Message complémentaire ${index + 1}',
    pt: 'Mensagem de apoio ${index + 1}',
  );
}
