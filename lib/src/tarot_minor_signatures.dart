/// Card-specific Minor Arcana motifs used to keep readings from collapsing into
/// rank + suit templates. These are reflective archetypal cues, not predictions.
const minorArcanaCardNames = <String>[
  'Ace of Wands',
  'Two of Wands',
  'Three of Wands',
  'Four of Wands',
  'Five of Wands',
  'Six of Wands',
  'Seven of Wands',
  'Eight of Wands',
  'Nine of Wands',
  'Ten of Wands',
  'Page of Wands',
  'Knight of Wands',
  'Queen of Wands',
  'King of Wands',
  'Ace of Cups',
  'Two of Cups',
  'Three of Cups',
  'Four of Cups',
  'Five of Cups',
  'Six of Cups',
  'Seven of Cups',
  'Eight of Cups',
  'Nine of Cups',
  'Ten of Cups',
  'Page of Cups',
  'Knight of Cups',
  'Queen of Cups',
  'King of Cups',
  'Ace of Swords',
  'Two of Swords',
  'Three of Swords',
  'Four of Swords',
  'Five of Swords',
  'Six of Swords',
  'Seven of Swords',
  'Eight of Swords',
  'Nine of Swords',
  'Ten of Swords',
  'Page of Swords',
  'Knight of Swords',
  'Queen of Swords',
  'King of Swords',
  'Ace of Pentacles',
  'Two of Pentacles',
  'Three of Pentacles',
  'Four of Pentacles',
  'Five of Pentacles',
  'Six of Pentacles',
  'Seven of Pentacles',
  'Eight of Pentacles',
  'Nine of Pentacles',
  'Ten of Pentacles',
  'Page of Pentacles',
  'Knight of Pentacles',
  'Queen of Pentacles',
  'King of Pentacles',
];

const _english = <String, String>{
  'Ace of Wands':
      'A raw creative spark is asking to become a real first move.',
  'Two of Wands':
      'The horizon is wider than the familiar plan, and choice now means committing to a direction.',
  'Three of Wands':
      'Early effort is becoming visible progress; distance and feedback now matter.',
  'Four of Wands':
      'A shared milestone needs to be received, celebrated, and made into belonging.',
  'Five of Wands':
      'Competing wills are testing whether friction becomes learning or needless battle.',
  'Six of Wands':
      'Recognition is arriving, but being seen also creates responsibility for what comes next.',
  'Seven of Wands':
      'Your position is worth defending only if it still reflects your actual values.',
  'Eight of Wands':
      'Momentum is real and timing matters; clear messages can move things quickly.',
  'Nine of Wands':
      'Experience has made you watchful; resilience now needs boundaries without permanent armor.',
  'Ten of Wands':
      'Responsibility has become heavy enough to test which burdens are truly yours.',
  'Page of Wands':
      'Curiosity is carrying a fresh creative message before experience has shaped it.',
  'Knight of Wands':
      'Desire wants immediate movement; courage is useful only when speed has direction.',
  'Queen of Wands':
      'Warm confidence makes creativity magnetic when it does not need to prove itself.',
  'King of Wands':
      'Vision becomes leadership when inspiration is organized around a larger purpose.',
  'Ace of Cups':
      'Emotional openness is beginning before you know exactly what it will become.',
  'Two of Cups':
      'Mutuality matters more than intensity; connection strengthens through reciprocal choice.',
  'Three of Cups':
      'Joy grows through friendship, witness, and letting good news be shared.',
  'Four of Cups':
      'Emotional withdrawal may protect you, but it can also hide an offer worth reconsidering.',
  'Five of Cups':
      'Grief deserves attention, yet loss is not the whole emotional landscape.',
  'Six of Cups':
      'Memory is offering tenderness; nostalgia helps only when the past is not asked to become the present.',
  'Seven of Cups':
      'Many attractive possibilities are competing with discernment and reality.',
  'Eight of Cups':
      'Something once meaningful no longer nourishes enough to justify staying unchanged.',
  'Nine of Cups':
      'Satisfaction is close enough to feel; gratitude can reveal whether the wish is actually yours.',
  'Ten of Cups':
      'Emotional abundance becomes durable through belonging, repair, and shared values.',
  'Page of Cups':
      'A tender message or feeling is emerging before it has adult certainty.',
  'Knight of Cups':
      'The heart wants to pursue an ideal; romance needs reality to stay trustworthy.',
  'Queen of Cups':
      'Deep empathy is powerful when sensitivity includes boundaries.',
  'King of Cups':
      'Emotional maturity holds feeling without being ruled by it.',
  'Ace of Swords':
      'A clean truth can cut through confusion if clarity is used without cruelty.',
  'Two of Swords':
      'Stalemate is preserving temporary peace at the cost of a necessary decision.',
  'Three of Swords':
      'Pain is becoming undeniable; naming the wound is part of moving through it.',
  'Four of Swords':
      'Recovery needs deliberate quiet, not another problem to solve.',
  'Five of Swords':
      'Winning the argument may cost more than the conflict itself.',
  'Six of Swords':
      'Transition is underway even if the new shore does not yet feel like home.',
  'Seven of Swords':
      'Strategy can protect what matters, but secrecy quickly becomes self-deception.',
  'Eight of Swords':
      'The restriction feels absolute, yet part of the prison may be maintained by the story around it.',
  'Nine of Swords':
      'The mind is rehearsing danger after the day has ended; fear needs evidence, not more fuel.',
  'Ten of Swords':
      'A painful ending has reached the point where acceptance creates the first honest exit.',
  'Page of Swords':
      'Alert curiosity is gathering facts; questions are useful before conclusions harden.',
  'Knight of Swords':
      'Thought is moving faster than context; decisive speech needs a brake before impact.',
  'Queen of Swords':
      'Discernment is sharpest when truth and boundaries do not become emotional exile.',
  'King of Swords':
      'Reason becomes trustworthy when authority answers to ethics as well as logic.',
  'Ace of Pentacles':
      'A practical opening has appeared; value grows only when the opportunity is given form.',
  'Two of Pentacles':
      'Adaptability is keeping multiple demands moving, but rhythm matters more than frantic juggling.',
  'Three of Pentacles':
      'Skill becomes visible through collaboration, standards, and work that can be inspected.',
  'Four of Pentacles':
      'Security is useful until holding tightly becomes the thing that creates scarcity.',
  'Five of Pentacles':
      'Material strain can isolate you; receiving help is also a practical skill.',
  'Six of Pentacles':
      'Giving and receiving are revealing the power balance inside an exchange.',
  'Seven of Pentacles':
      'Patience is asking for an honest review of what the current investment is actually producing.',
  'Eight of Pentacles':
      'Repetition is turning effort into craft; quality now depends on deliberate practice.',
  'Nine of Pentacles':
      'Earned independence can be enjoyed without turning self-sufficiency into isolation.',
  'Ten of Pentacles':
      'Stability is becoming a system, legacy, or shared structure larger than one moment.',
  'Page of Pentacles':
      'A practical opportunity is asking to be studied, tested, and learned from.',
  'Knight of Pentacles':
      'Consistency is the strength here; reliable progress is more valuable than dramatic speed.',
  'Queen of Pentacles':
      'Grounded care turns resources into safety without losing practical intelligence.',
  'King of Pentacles':
      'Material mastery is measured by stewardship, not possession alone.',
};

const _turkish = <String, String>{
  'Ace of Wands':
      'Ham bir yaratıcı kıvılcım, gerçek bir ilk adıma dönüşmek istiyor.',
  'Two of Wands':
      'Ufuk tanıdık plandan daha geniş; seçim artık bir yöne gerçekten bağlanmayı gerektiriyor.',
  'Three of Wands':
      'İlk emek görünür ilerlemeye dönüşüyor; mesafe ve geri bildirim artık önemli.',
  'Four of Wands':
      'Paylaşılan bir dönüm noktası kabul edilmeyi, kutlanmayı ve aidiyete dönüşmeyi istiyor.',
  'Five of Wands':
      'Çatışan iradeler, sürtüşmenin öğrenmeye mi yoksa gereksiz mücadeleye mi dönüşeceğini sınıyor.',
  'Six of Wands':
      'Takdir geliyor; görünür olmak, bundan sonra ne yapacağın konusunda da sorumluluk getiriyor.',
  'Seven of Wands':
      'Konumun ancak hâlâ gerçek değerlerini yansıtıyorsa savunulmaya değer.',
  'Eight of Wands':
      'İvme gerçek ve zamanlama önemli; açık mesajlar işleri hızla hareket ettirebilir.',
  'Nine of Wands':
      'Deneyim seni tetikte tuttu; dayanıklılık şimdi kalıcı zırh yerine sağlıklı sınırlar istiyor.',
  'Ten of Wands':
      'Sorumluluk, hangi yüklerin gerçekten sana ait olduğunu sorgulatacak kadar ağırlaştı.',
  'Page of Wands':
      'Merak, deneyim henüz biçim vermeden önce taze bir yaratıcı mesaj taşıyor.',
  'Knight of Wands':
      'Arzu hemen harekete geçmek istiyor; cesaret ancak hızın bir yönü olduğunda işe yarar.',
  'Queen of Wands':
      'Sıcak bir özgüven, kendini kanıtlama ihtiyacı duymadığında yaratıcılığı çekici kılar.',
  'King of Wands':
      'İlham daha büyük bir amaç etrafında örgütlendiğinde vizyon liderliğe dönüşür.',
  'Ace of Cups':
      'Duygusal açıklık, neye dönüşeceğini tam bilmeden önce filizleniyor.',
  'Two of Cups':
      'Yoğunluktan çok karşılıklılık önemli; bağ, iki tarafın da seçim yapmasıyla güçlenir.',
  'Three of Cups':
      'Sevinç; dostluk, tanıklık ve güzel haberin paylaşılmasına izin vermekle büyür.',
  'Four of Cups':
      'Duygusal geri çekilme seni koruyor olabilir; ama yeniden düşünmeye değer bir fırsatı da saklayabilir.',
  'Five of Cups':
      'Keder ilgiyi hak ediyor; yine de kayıp, duygusal manzaranın tamamı değil.',
  'Six of Cups':
      'Hafıza şefkat sunuyor; nostalji ancak geçmişten bugünün yerine geçmesi istenmediğinde yardımcı olur.',
  'Seven of Cups':
      'Birçok çekici olasılık, ayırt etme gücü ve gerçekle yarışıyor.',
  'Eight of Cups':
      'Bir zamanlar anlamlı olan bir şey artık aynı yerde kalmayı haklı çıkaracak kadar beslemiyor.',
  'Nine of Cups':
      'Tatmin hissedilecek kadar yakın; şükran, dileğin gerçekten sana ait olup olmadığını gösterebilir.',
  'Ten of Cups':
      'Duygusal bolluk; aidiyet, onarım ve ortak değerlerle kalıcı hale gelir.',
  'Page of Cups':
      'Hassas bir mesaj ya da duygu, henüz yetişkin kesinliğine ulaşmadan ortaya çıkıyor.',
  'Knight of Cups':
      'Kalp bir idealin peşinden gitmek istiyor; romantizmin güvenilir kalması için gerçeğe ihtiyacı var.',
  'Queen of Cups':
      'Derin empati, hassasiyet sağlıklı sınırları da içerdiğinde güçlenir.',
  'King of Cups':
      'Duygusal olgunluk, duyguyu bastırmadan onun tarafından yönetilmemeyi sağlar.',
  'Ace of Swords':
      'Net bir gerçek, açıklık acımasızlığa dönüşmediğinde karmaşayı kesip geçebilir.',
  'Two of Swords':
      'Çıkmaz, gerekli bir kararın bedeli karşılığında geçici huzuru koruyor.',
  'Three of Swords':
      'Acı inkâr edilemez hale geliyor; yarayı adlandırmak içinden geçmenin bir parçası.',
  'Four of Swords':
      'Toparlanmanın başka bir problem çözmeye değil, bilinçli bir sessizliğe ihtiyacı var.',
  'Five of Swords':
      'Tartışmayı kazanmanın bedeli, çatışmanın kendisinden daha yüksek olabilir.',
  'Six of Swords':
      'Yeni kıyı henüz ev gibi hissettirmese de geçiş çoktan başladı.',
  'Seven of Swords':
      'Strateji önemli olanı koruyabilir; fakat gizlilik hızla kendini kandırmaya dönüşebilir.',
  'Eight of Swords':
      'Kısıtlama mutlak görünüyor; yine de hapishanenin bir kısmını onu anlatma biçimin sürdürüyor olabilir.',
  'Nine of Swords':
      'Zihin gün bittikten sonra tehlikeyi prova ediyor; korkunun daha fazla yakıta değil kanıta ihtiyacı var.',
  'Ten of Swords':
      'Acı veren bir son, kabullenmenin ilk dürüst çıkışı yaratacağı noktaya ulaştı.',
  'Page of Swords':
      'Uyanık merak gerçekleri topluyor; sonuçlar katılaşmadan önce soru sormak faydalı.',
  'Knight of Swords':
      'Düşünce bağlamdan daha hızlı ilerliyor; kesin sözlerin çarpışmadan önce frene ihtiyacı var.',
  'Queen of Swords':
      'Ayırt etme gücü, gerçek ve sınırlar duygusal sürgüne dönüşmediğinde en keskindir.',
  'King of Swords':
      'Akıl, otorite yalnız mantığa değil etiğe de hesap verdiğinde güvenilir olur.',
  'Ace of Pentacles':
      'Somut bir fırsat belirdi; değer ancak fırsata gerçek bir biçim verildiğinde büyür.',
  'Two of Pentacles':
      'Uyum sağlama gücü birçok talebi hareket halinde tutuyor; ritim, telaşlı dengelemeden daha önemli.',
  'Three of Pentacles':
      'Beceri; işbirliği, standartlar ve incelenebilir emek sayesinde görünür hale geliyor.',
  'Four of Pentacles':
      'Güvenlik faydalıdır; ta ki sıkıca tutunmak kıtlığın kendisini üretmeye başlayana kadar.',
  'Five of Pentacles':
      'Maddi sıkışıklık seni yalnızlaştırabilir; yardım kabul etmek de pratik bir beceridir.',
  'Six of Pentacles':
      'Vermek ve almak, bir alışverişin içindeki güç dengesini görünür kılıyor.',
  'Seven of Pentacles':
      'Sabır, mevcut yatırımın gerçekte ne ürettiğine dürüstçe bakmanı istiyor.',
  'Eight of Pentacles':
      'Tekrar emeği ustalığa çeviriyor; kalite artık bilinçli pratiğe bağlı.',
  'Nine of Pentacles':
      'Kazanılmış bağımsızlık, kendi kendine yeterliliği yalnızlığa çevirmeden yaşanabilir.',
  'Ten of Pentacles':
      'İstikrar tek bir anı aşan bir sisteme, mirasa ya da ortak yapıya dönüşüyor.',
  'Page of Pentacles':
      'Somut bir fırsat incelenmek, denenmek ve ondan öğrenilmek istiyor.',
  'Knight of Pentacles':
      'Buradaki güç tutarlılık; güvenilir ilerleme gösterişli hızdan daha değerli.',
  'Queen of Pentacles':
      'Ayakları yere basan bakım, pratik zekâyı kaybetmeden kaynakları güvenliğe dönüştürür.',
  'King of Pentacles':
      'Maddi ustalık yalnız sahip olmakla değil, elindekine iyi bakmakla ölçülür.',
};

const _spanish = <String, String>{
  'Ace of Wands':
      'Una chispa creativa en bruto pide convertirse en un primer movimiento real.',
  'Two of Wands':
      'El horizonte es más amplio que el plan conocido; elegir ahora implica comprometerse con una dirección.',
  'Three of Wands':
      'El esfuerzo inicial se vuelve progreso visible; ahora importan la distancia y la respuesta.',
  'Four of Wands':
      'Un hito compartido necesita ser recibido, celebrado y convertido en pertenencia.',
  'Five of Wands':
      'Voluntades en competencia ponen a prueba si la fricción se vuelve aprendizaje o lucha innecesaria.',
  'Six of Wands':
      'Llega el reconocimiento, pero ser visto también trae responsabilidad por lo que sigue.',
  'Seven of Wands':
      'Tu posición merece defensa solo si todavía refleja tus valores reales.',
  'Eight of Wands':
      'El impulso es real y el momento importa; los mensajes claros pueden acelerar las cosas.',
  'Nine of Wands':
      'La experiencia te ha vuelto vigilante; la resistencia necesita límites sin una armadura permanente.',
  'Ten of Wands':
      'La responsabilidad pesa lo suficiente para preguntar qué cargas son realmente tuyas.',
  'Page of Wands':
      'La curiosidad trae un mensaje creativo nuevo antes de que la experiencia le dé forma.',
  'Knight of Wands':
      'El deseo quiere moverse ya; el valor solo ayuda cuando la velocidad tiene dirección.',
  'Queen of Wands':
      'La confianza cálida vuelve magnética la creatividad cuando no necesita demostrar nada.',
  'King of Wands':
      'La visión se convierte en liderazgo cuando la inspiración sirve a un propósito mayor.',
  'Ace of Cups':
      'La apertura emocional comienza antes de que sepas exactamente en qué se convertirá.',
  'Two of Cups':
      'La reciprocidad importa más que la intensidad; la conexión crece mediante una elección mutua.',
  'Three of Cups':
      'La alegría crece con la amistad, el acompañamiento y la disposición a compartir buenas noticias.',
  'Four of Cups':
      'Retirarte emocionalmente puede protegerte, pero también ocultar una oferta que merece otra mirada.',
  'Five of Cups':
      'El duelo merece atención, pero la pérdida no es todo el paisaje emocional.',
  'Six of Cups':
      'La memoria ofrece ternura; la nostalgia ayuda solo si el pasado no sustituye al presente.',
  'Seven of Cups':
      'Muchas posibilidades atractivas compiten con el discernimiento y la realidad.',
  'Eight of Cups':
      'Algo que antes tenía sentido ya no nutre lo suficiente como para justificar seguir igual.',
  'Nine of Cups':
      'La satisfacción está cerca; la gratitud puede mostrar si el deseo es realmente tuyo.',
  'Ten of Cups':
      'La abundancia emocional se vuelve duradera mediante pertenencia, reparación y valores compartidos.',
  'Page of Cups':
      'Surge un mensaje o sentimiento tierno antes de tener la certeza de la madurez.',
  'Knight of Cups':
      'El corazón quiere perseguir un ideal; el romance necesita realidad para seguir siendo fiable.',
  'Queen of Cups':
      'La empatía profunda es poderosa cuando la sensibilidad también incluye límites.',
  'King of Cups':
      'La madurez emocional sostiene lo que siente sin quedar gobernada por ello.',
  'Ace of Swords':
      'Una verdad limpia puede atravesar la confusión si la claridad no se vuelve crueldad.',
  'Two of Swords':
      'El estancamiento conserva una paz temporal a costa de una decisión necesaria.',
  'Three of Swords':
      'El dolor se vuelve innegable; nombrar la herida forma parte de atravesarla.',
  'Four of Swords':
      'La recuperación necesita silencio deliberado, no otro problema que resolver.',
  'Five of Swords':
      'Ganar la discusión puede costar más que el propio conflicto.',
  'Six of Swords':
      'La transición ya está en marcha aunque la nueva orilla todavía no se sienta como hogar.',
  'Seven of Swords':
      'La estrategia puede proteger lo importante, pero el secreto se convierte rápido en autoengaño.',
  'Eight of Swords':
      'La restricción parece absoluta, aunque parte de la prisión puede mantenerse por la historia que la rodea.',
  'Nine of Swords':
      'La mente ensaya el peligro cuando el día terminó; el miedo necesita evidencia, no más combustible.',
  'Ten of Swords':
      'Un final doloroso llegó al punto donde aceptar crea la primera salida honesta.',
  'Page of Swords':
      'La curiosidad alerta reúne hechos; preguntar sirve antes de que las conclusiones se endurezcan.',
  'Knight of Swords':
      'El pensamiento corre más rápido que el contexto; la palabra decisiva necesita freno antes del impacto.',
  'Queen of Swords':
      'El discernimiento es más preciso cuando la verdad y los límites no se vuelven exilio emocional.',
  'King of Swords':
      'La razón se vuelve fiable cuando la autoridad responde tanto a la ética como a la lógica.',
  'Ace of Pentacles':
      'Ha aparecido una oportunidad práctica; el valor crece cuando la posibilidad recibe una forma real.',
  'Two of Pentacles':
      'La adaptabilidad mantiene varias demandas en movimiento, pero el ritmo importa más que el malabarismo frenético.',
  'Three of Pentacles':
      'La habilidad se hace visible mediante colaboración, estándares y trabajo que puede revisarse.',
  'Four of Pentacles':
      'La seguridad ayuda hasta que aferrarse demasiado empieza a crear la propia escasez.',
  'Five of Pentacles':
      'La presión material puede aislarte; recibir ayuda también es una habilidad práctica.',
  'Six of Pentacles':
      'Dar y recibir están revelando el equilibrio de poder dentro del intercambio.',
  'Seven of Pentacles':
      'La paciencia pide revisar con honestidad qué está produciendo realmente tu inversión actual.',
  'Eight of Pentacles':
      'La repetición convierte esfuerzo en oficio; la calidad depende ahora de la práctica deliberada.',
  'Nine of Pentacles':
      'La independencia ganada puede disfrutarse sin convertir la autosuficiencia en aislamiento.',
  'Ten of Pentacles':
      'La estabilidad se convierte en sistema, legado o estructura compartida mayor que este momento.',
  'Page of Pentacles':
      'Una oportunidad práctica pide ser estudiada, probada y convertida en aprendizaje.',
  'Knight of Pentacles':
      'La constancia es la fuerza aquí; el progreso fiable vale más que una velocidad espectacular.',
  'Queen of Pentacles':
      'El cuidado con los pies en la tierra convierte recursos en seguridad sin perder inteligencia práctica.',
  'King of Pentacles':
      'La maestría material se mide por la buena administración, no solo por la posesión.',
};

const _french = <String, String>{
  'Ace of Wands':
      'Une étincelle créative brute demande à devenir un véritable premier geste.',
  'Two of Wands':
      'L’horizon dépasse le plan familier ; choisir signifie maintenant s’engager dans une direction.',
  'Three of Wands':
      'Les premiers efforts deviennent des progrès visibles ; la distance et les retours comptent désormais.',
  'Four of Wands':
      'Une étape partagée demande à être accueillie, célébrée et transformée en appartenance.',
  'Five of Wands':
      'Des volontés concurrentes testent si la friction devient apprentissage ou lutte inutile.',
  'Six of Wands':
      'La reconnaissance arrive, mais être vu crée aussi une responsabilité pour la suite.',
  'Seven of Wands':
      'Votre position mérite d’être défendue seulement si elle reflète encore vos valeurs réelles.',
  'Eight of Wands':
      'L’élan est réel et le timing compte ; des messages clairs peuvent accélérer le mouvement.',
  'Nine of Wands':
      'L’expérience vous a rendu vigilant ; la résilience demande des limites sans armure permanente.',
  'Ten of Wands':
      'La responsabilité est devenue assez lourde pour demander quelles charges vous appartiennent vraiment.',
  'Page of Wands':
      'La curiosité porte un message créatif neuf avant que l’expérience ne lui donne forme.',
  'Knight of Wands':
      'Le désir veut bouger immédiatement ; le courage n’aide que si la vitesse a une direction.',
  'Queen of Wands':
      'Une confiance chaleureuse rend la créativité magnétique lorsqu’elle n’a rien à prouver.',
  'King of Wands':
      'La vision devient leadership quand l’inspiration s’organise autour d’un objectif plus vaste.',
  'Ace of Cups':
      'L’ouverture émotionnelle commence avant que vous sachiez exactement ce qu’elle deviendra.',
  'Two of Cups':
      'La réciprocité compte plus que l’intensité ; le lien grandit par un choix mutuel.',
  'Three of Cups':
      'La joie grandit avec l’amitié, le partage et la possibilité de célébrer ensemble.',
  'Four of Cups':
      'Le retrait émotionnel peut vous protéger, mais aussi cacher une offre à reconsidérer.',
  'Five of Cups':
      'Le chagrin mérite de l’attention, mais la perte n’est pas tout le paysage émotionnel.',
  'Six of Cups':
      'La mémoire offre de la tendresse ; la nostalgie aide seulement si le passé ne remplace pas le présent.',
  'Seven of Cups':
      'De nombreuses possibilités séduisantes rivalisent avec le discernement et la réalité.',
  'Eight of Cups':
      'Quelque chose autrefois important ne nourrit plus assez pour justifier de rester inchangé.',
  'Nine of Cups':
      'La satisfaction est assez proche pour être ressentie ; la gratitude révèle si le souhait est vraiment le vôtre.',
  'Ten of Cups':
      'L’abondance émotionnelle devient durable grâce à l’appartenance, la réparation et des valeurs partagées.',
  'Page of Cups':
      'Un message ou un sentiment tendre émerge avant d’avoir la certitude de la maturité.',
  'Knight of Cups':
      'Le cœur veut poursuivre un idéal ; le romantisme a besoin de réalité pour rester fiable.',
  'Queen of Cups':
      'L’empathie profonde devient une force lorsque la sensibilité comprend aussi des limites.',
  'King of Cups':
      'La maturité émotionnelle accueille le sentiment sans se laisser gouverner par lui.',
  'Ace of Swords':
      'Une vérité nette peut traverser la confusion si la clarté ne devient pas cruauté.',
  'Two of Swords':
      'L’impasse préserve une paix temporaire au prix d’une décision nécessaire.',
  'Three of Swords':
      'La douleur devient indéniable ; nommer la blessure fait partie de la traversée.',
  'Four of Swords':
      'La récupération demande un silence volontaire, pas un autre problème à résoudre.',
  'Five of Swords':
      'Gagner l’argument peut coûter plus cher que le conflit lui-même.',
  'Six of Swords':
      'La transition est engagée même si la nouvelle rive ne ressemble pas encore à un foyer.',
  'Seven of Swords':
      'La stratégie peut protéger l’essentiel, mais le secret devient vite auto-illusion.',
  'Eight of Swords':
      'La restriction semble absolue, pourtant une partie de la prison peut être entretenue par le récit qui l’entoure.',
  'Nine of Swords':
      'L’esprit répète le danger après la fin du jour ; la peur a besoin de preuves, pas de carburant.',
  'Ten of Swords':
      'Une fin douloureuse a atteint le point où l’acceptation crée la première sortie honnête.',
  'Page of Swords':
      'Une curiosité vigilante rassemble les faits ; les questions sont utiles avant que les conclusions ne se figent.',
  'Knight of Swords':
      'La pensée va plus vite que le contexte ; la parole décisive a besoin d’un frein avant l’impact.',
  'Queen of Swords':
      'Le discernement est plus juste lorsque vérité et limites ne deviennent pas exil émotionnel.',
  'King of Swords':
      'La raison devient fiable lorsque l’autorité répond autant à l’éthique qu’à la logique.',
  'Ace of Pentacles':
      'Une ouverture concrète apparaît ; la valeur grandit lorsque la possibilité reçoit une forme réelle.',
  'Two of Pentacles':
      'L’adaptabilité maintient plusieurs demandes en mouvement, mais le rythme compte plus que la jonglerie fébrile.',
  'Three of Pentacles':
      'Le savoir-faire devient visible grâce à la collaboration, aux standards et à un travail vérifiable.',
  'Four of Pentacles':
      'La sécurité aide jusqu’à ce que s’accrocher trop fort crée sa propre pénurie.',
  'Five of Pentacles':
      'La pression matérielle peut isoler ; recevoir de l’aide est aussi une compétence pratique.',
  'Six of Pentacles':
      'Donner et recevoir révèlent l’équilibre du pouvoir au cœur de l’échange.',
  'Seven of Pentacles':
      'La patience demande d’examiner honnêtement ce que votre investissement produit réellement.',
  'Eight of Pentacles':
      'La répétition transforme l’effort en métier ; la qualité dépend maintenant d’une pratique délibérée.',
  'Nine of Pentacles':
      'L’indépendance acquise peut être savourée sans transformer l’autonomie en isolement.',
  'Ten of Pentacles':
      'La stabilité devient un système, un héritage ou une structure partagée plus vaste que l’instant.',
  'Page of Pentacles':
      'Une possibilité concrète demande à être étudiée, testée et transformée en apprentissage.',
  'Knight of Pentacles':
      'La constance est la force ici ; un progrès fiable vaut plus qu’une vitesse spectaculaire.',
  'Queen of Pentacles':
      'Un soin ancré transforme les ressources en sécurité sans perdre l’intelligence pratique.',
  'King of Pentacles':
      'La maîtrise matérielle se mesure à la gestion responsable, pas seulement à la possession.',
};

const _portugueseBrazil = <String, String>{
  'Ace of Wands':
      'Uma faísca criativa ainda bruta pede para virar um primeiro movimento real.',
  'Two of Wands':
      'O horizonte é maior que o plano conhecido; escolher agora significa assumir uma direção.',
  'Three of Wands':
      'O esforço inicial está virando progresso visível; distância e retorno agora importam.',
  'Four of Wands':
      'Um marco compartilhado precisa ser recebido, celebrado e transformado em pertencimento.',
  'Five of Wands':
      'Vontades concorrentes testam se o atrito vira aprendizado ou batalha desnecessária.',
  'Six of Wands':
      'O reconhecimento está chegando, mas ser visto também traz responsabilidade pelo próximo passo.',
  'Seven of Wands':
      'Sua posição só merece ser defendida se ainda refletir seus valores reais.',
  'Eight of Wands':
      'O impulso é real e o timing importa; mensagens claras podem acelerar o movimento.',
  'Nine of Wands':
      'A experiência deixou você vigilante; a resiliência precisa de limites sem armadura permanente.',
  'Ten of Wands':
      'A responsabilidade ficou pesada o bastante para perguntar quais cargas são realmente suas.',
  'Page of Wands':
      'A curiosidade carrega uma mensagem criativa nova antes que a experiência lhe dê forma.',
  'Knight of Wands':
      'O desejo quer movimento imediato; coragem só ajuda quando a velocidade tem direção.',
  'Queen of Wands':
      'Confiança calorosa torna a criatividade magnética quando não precisa provar nada.',
  'King of Wands':
      'Visão vira liderança quando a inspiração se organiza em torno de um propósito maior.',
  'Ace of Cups':
      'A abertura emocional começa antes de você saber exatamente no que ela vai se tornar.',
  'Two of Cups':
      'Reciprocidade importa mais que intensidade; a conexão cresce por uma escolha mútua.',
  'Three of Cups':
      'A alegria cresce com amizade, testemunho e espaço para compartilhar boas notícias.',
  'Four of Cups':
      'O afastamento emocional pode proteger você, mas também esconder uma oferta que merece outra olhada.',
  'Five of Cups':
      'O luto merece atenção, mas a perda não é toda a paisagem emocional.',
  'Six of Cups':
      'A memória oferece ternura; a nostalgia ajuda apenas quando o passado não substitui o presente.',
  'Seven of Cups':
      'Muitas possibilidades atraentes estão competindo com discernimento e realidade.',
  'Eight of Cups':
      'Algo que já foi significativo não nutre mais o bastante para justificar ficar igual.',
  'Nine of Cups':
      'A satisfação está perto o bastante para ser sentida; gratidão pode revelar se o desejo é mesmo seu.',
  'Ten of Cups':
      'A abundância emocional se torna duradoura por pertencimento, reparo e valores compartilhados.',
  'Page of Cups':
      'Uma mensagem ou sentimento delicado surge antes de ter a certeza da maturidade.',
  'Knight of Cups':
      'O coração quer perseguir um ideal; o romance precisa de realidade para continuar confiável.',
  'Queen of Cups':
      'Empatia profunda é poderosa quando a sensibilidade também inclui limites.',
  'King of Cups':
      'Maturidade emocional acolhe o sentimento sem ser governada por ele.',
  'Ace of Swords':
      'Uma verdade limpa pode cortar a confusão se a clareza não virar crueldade.',
  'Two of Swords':
      'O impasse preserva uma paz temporária ao custo de uma decisão necessária.',
  'Three of Swords':
      'A dor está ficando inegável; nomear a ferida faz parte de atravessá-la.',
  'Four of Swords':
      'A recuperação precisa de silêncio deliberado, não de outro problema para resolver.',
  'Five of Swords':
      'Vencer a discussão pode custar mais do que o próprio conflito.',
  'Six of Swords':
      'A transição já começou, mesmo que a nova margem ainda não pareça casa.',
  'Seven of Swords':
      'Estratégia pode proteger o que importa, mas segredo rapidamente vira autoengano.',
  'Eight of Swords':
      'A restrição parece absoluta, mas parte da prisão pode ser mantida pela história construída ao redor dela.',
  'Nine of Swords':
      'A mente ensaia perigo depois que o dia termina; o medo precisa de evidência, não de mais combustível.',
  'Ten of Swords':
      'Um fim doloroso chegou ao ponto em que aceitar cria a primeira saída honesta.',
  'Page of Swords':
      'Curiosidade alerta está reunindo fatos; perguntas ajudam antes que as conclusões endureçam.',
  'Knight of Swords':
      'O pensamento corre mais rápido que o contexto; a fala decisiva precisa frear antes do impacto.',
  'Queen of Swords':
      'O discernimento é mais afiado quando verdade e limites não viram exílio emocional.',
  'King of Swords':
      'A razão se torna confiável quando a autoridade responde à ética tanto quanto à lógica.',
  'Ace of Pentacles':
      'Uma abertura prática apareceu; o valor cresce quando a oportunidade recebe forma real.',
  'Two of Pentacles':
      'A adaptabilidade mantém várias demandas em movimento, mas ritmo importa mais que malabarismo frenético.',
  'Three of Pentacles':
      'A habilidade fica visível por colaboração, padrões e trabalho que pode ser avaliado.',
  'Four of Pentacles':
      'Segurança ajuda até o ponto em que segurar com força começa a criar a própria escassez.',
  'Five of Pentacles':
      'Pressão material pode isolar você; receber ajuda também é uma habilidade prática.',
  'Six of Pentacles':
      'Dar e receber estão revelando o equilíbrio de poder dentro da troca.',
  'Seven of Pentacles':
      'A paciência pede uma revisão honesta do que seu investimento atual está realmente produzindo.',
  'Eight of Pentacles':
      'A repetição transforma esforço em ofício; a qualidade agora depende de prática deliberada.',
  'Nine of Pentacles':
      'A independência conquistada pode ser aproveitada sem transformar autonomia em isolamento.',
  'Ten of Pentacles':
      'A estabilidade está virando sistema, legado ou estrutura compartilhada maior que este momento.',
  'Page of Pentacles':
      'Uma oportunidade prática pede para ser estudada, testada e transformada em aprendizado.',
  'Knight of Pentacles':
      'Consistência é a força aqui; progresso confiável vale mais que velocidade dramática.',
  'Queen of Pentacles':
      'Cuidado com os pés no chão transforma recursos em segurança sem perder inteligência prática.',
  'King of Pentacles':
      'Maestria material é medida por boa administração, não apenas por posse.',
};

String? minorArcanaSignature(String cardName, String languageCode) {
  final source = switch (languageCode) {
    'TR' => _turkish,
    'ES' => _spanish,
    'FR' => _french,
    'PT-BR' => _portugueseBrazil,
    'EN' => _english,
    _ => null,
  };
  return source?[cardName];
}
