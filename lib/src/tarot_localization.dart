import 'models.dart';

const _majorArcanaTurkish = <String, String>{
  'The Fool': 'Deli',
  'The Magician': 'Büyücü',
  'The High Priestess': 'Başrahibe',
  'The Empress': 'İmparatoriçe',
  'The Emperor': 'İmparator',
  'The Hierophant': 'Aziz',
  'The Lovers': 'Âşıklar',
  'The Chariot': 'Savaş Arabası',
  'Strength': 'Güç',
  'The Hermit': 'Ermiş',
  'Wheel of Fortune': 'Kader Çarkı',
  'Justice': 'Adalet',
  'The Hanged Man': 'Asılan Adam',
  'Death': 'Ölüm',
  'Temperance': 'Denge',
  'The Devil': 'Şeytan',
  'The Tower': 'Kule',
  'The Star': 'Yıldız',
  'The Moon': 'Ay',
  'The Sun': 'Güneş',
  'Judgement': 'Mahkeme',
  'The World': 'Dünya',
};

const _rankTurkish = <String, String>{
  'Ace': 'Ası',
  'Two': 'İkilisi',
  'Three': 'Üçlüsü',
  'Four': 'Dörtlüsü',
  'Five': 'Beşlisi',
  'Six': 'Altılısı',
  'Seven': 'Yedilisi',
  'Eight': 'Sekizlisi',
  'Nine': 'Dokuzlusu',
  'Ten': 'Onlusu',
  'Page': 'Prensi',
  'Knight': 'Şövalyesi',
  'Queen': 'Kraliçesi',
  'King': 'Kralı',
};

const _suitTurkish = <String, String>{
  'Wands': 'Değnek',
  'Cups': 'Kupa',
  'Swords': 'Kılıç',
  'Pentacles': 'Tılsım',
};

const _majorMeaningTurkish = <String, List<String>>{
  'The Fool': [
    'Yeni bir başlangıç senden bütün cevaplara sahip olmanı değil, merakını ve cesaretini korumanı istiyor. Önündeki yol henüz kesinleşmemiş olsa da ilk dürüst adım hareketi başlatabilir.',
    'Özgürlük isteği hazırlıksız bir sıçrayışa veya sorumluluktan kaçışa dönüşebilir. Heyecanla hareket etmeden önce görmezden geldiğin riski fark et.',
    'İlerle; fakat ayağının nereye basacağını bir kez dürüstçe kontrol et.',
  ],
  'The Magician': [
    'Bu anı şekillendirmek için gereken araçların çoğu zaten sende. Niyetini tek bir noktaya topladığında düşünceyi somut bir harekete çevirebilirsin.',
    'Dağınık odak, kendinden şüphe veya başkalarını etkileme arzusu gücünü seyreltiyor olabilir. Yapabileceklerinle kanıtlamaya çalıştıklarını birbirinden ayır.',
    'Tek bir sonuç seç ve enerjini dağılmadan ona yönelt.',
  ],
  'The High Priestess': [
    'Gürültünün altındaki sessiz bilgi, dışarıdan gelen baskıdan daha güvenilir olabilir. Henüz açıklayamadığın sezgiyi hemen reddetmek zorunda değilsin.',
    'Sezginin mesajı rahatsız edici olduğu için onu görmezden geliyor veya belirsizliği gerçekmiş gibi yorumluyor olabilirsin.',
    'Harekete geçmeden önce dur ve bedeninin zaten ne bildiğini fark et.',
  ],
  'The Empress': [
    'Büyüme; bakım, sabır, haz ve yaratıcı beslenme yoluyla geliyor. Zorlayarak değil, doğru koşulları kurarak daha kalıcı bir sonuç elde edebilirsin.',
    'Başkalarına çok fazla verirken kendi iç dünyanı ihmal ediyor olabilirsin. Bakım vermek ile kendini tüketmek aynı şey değildir.',
    'Hem seni hem de arzunu besleyecek koşulları oluştur.',
  ],
  'The Emperor': [
    'Net sınırlar ve güvenilir bir yapı, niyetini sürdürülebilir ilerlemeye çevirebilir. Liderlik burada sertlikten çok tutarlılık istiyor.',
    'Kontrol ihtiyacı esnekliğin, güvenin veya gerçek sorumluluğun yerini almış olabilir. Düzen kurarken yaşam alanını daraltma.',
    'Sağlam bir çerçeve kur; fakat onu hapishaneye dönüştürme.',
  ],
  'The Hierophant': [
    'Güvenilir bir öğreti, ritüel veya topluluk bu ana anlam kazandırabilir. Daha önce denenmiş bir yöntem sana ihtiyaç duyduğun zemini sunuyor.',
    'Geleneği sorgulamadan izlemek kendi bilgeliğini susturabilir. Onay görmek uğruna sana uymayan bir kuralı taşıyor olabilirsin.',
    'Önce geleneği öğren, sonra neyin devam etmeyi hak ettiğini bilinçli seç.',
  ],
  'The Lovers': [
    'Değerlerin, arzun ve seçimin aynı yöne baktığında gerçek uyum oluşur. Bu kart yalnızca romantizmi değil, kendine sadık kalacağın bir kararı anlatır.',
    'Çekim güçlü olsa da değer çatışmasını tek başına çözemeyebilir. Yakınlık uğruna kendi sınırlarından vazgeçme riski var.',
    'Bağını korurken kendini terk etmeyeceğin seçimi yap.',
  ],
  'The Chariot': [
    'Odaklanmış irade, karşıt güçlerin ve belirsizliğin içinden seni taşıyabilir. Hız değil, yön duygusu zaferi anlamlı kılacak.',
    'Duygusal yönü olmayan hız, dışarıdan başarı gibi görünen boş bir sonuca götürebilir. Daha fazla zorlamadan önce nereye gittiğini netleştir.',
    'Daha hızlı ilerlemeden önce varmak istediğin yeri adlandır.',
  ],
  'Strength': [
    'Sakin cesaret ve duygusal denge, kaba kuvvetten daha güçlü çalışıyor. Zor olanı bastırmadan yanında kalabilmen gerçek gücün.',
    'Bastırılmış korku, özgüven kılığına girmiş olabilir. Kendini kanıtlama çabası altında incinmiş bir parça dikkat istiyor.',
    'Zor duyguyu yönetmeye değil, sabırla karşılamaya çalış.',
  ],
  'The Hermit': [
    'Yalnızlık ve içe dönüş, sürekli gürültünün örttüğü netliği geri getirebilir. Başkalarının cevaplarından uzaklaşınca kendi ışığını daha iyi göreceksin.',
    'Geri çekilmek, önemli bir konuşmadan veya yakınlıktan korunmanın yolu olmuş olabilir. Sessizlik iyileştirirken izolasyona dönüşmesin.',
    'Kendini duyacak kadar geri çekil, sonra gerçeğinle yeniden dön.',
  ],
  'Wheel of Fortune': [
    'Bir döngü değişiyor ve esneklik sana yeni açılan kapıyı gösterebilir. Her şeyi kontrol etmek yerine zamanlamayla birlikte hareket et.',
    'Değişeni dondurmaya çalışmak gereksiz bir direnç yaratıyor olabilir. Eski düzeni geri istemek yeni ihtimali görmeni engelliyor.',
    'Dünden vazgeçmeden bugünkü hareketle nasıl iş birliği yapabileceğini bul.',
  ],
  'Justice': [
    'Dürüstlük, sorumluluk ve orantılı bir karar dengeyi yeniden kurabilir. Sonuç ne olursa olsun gerçeklerle aynı tarafta kalman gerekiyor.',
    'İşine gelen bir hikâye kendi payını görmeni engelliyor olabilir. Haklı çıkma isteğini adil olma sorumluluğundan ayır.',
    'Kimse alkışlamasa bile saygı duyacağın kararı ver.',
  ],
  'The Hanged Man': [
    'Bilinçli bir duraklama, daha fazla çabayla göremeyeceğin farklı bir açı sunuyor. Şimdilik hareket etmemek de anlamlı bir seçim olabilir.',
    'Beklemek kaçınmaya, gereksiz fedakârlığa veya sıkışmışlığa bağlanmaya dönüşmüş olabilir. Duraklamanın hâlâ sana hizmet edip etmediğini sor.',
    'Hareketi zorlamayı bırak ve konuyu ters açıdan incele.',
  ],
  'Death': [
    'Bir son, daha dürüst bir yaşam biçimi için alan açıyor. Bu kart fiziksel ölümü değil, tamamlanmış bir kimliği veya dönemi bırakmayı anlatır.',
    'Biten bir bölüme tutunmak yenilenmeyi geciktiriyor olabilir. Kaybın acısını kabul etmeden yeni olana gerçekten yer açılamaz.',
    'Seni artık taşıyamayan kimliği veya alışkanlığı serbest bırak.',
  ],
  'Temperance': [
    'Sabırlı bütünleşme, aşırı uçların veremeyeceği sürdürülebilir bir denge yaratıyor. Küçük ayarlamalar büyük kopuşlardan daha etkili olabilir.',
    'Sabırsızlık seni ya hep ya hiç tepkileri arasında savuruyor olabilir. Hızlı sonuç uğruna kurduğun dengeyi bozma.',
    'Bir sonraki ayarlamayı sürdürebileceğin kadar küçük yap.',
  ],
  'The Devil': [
    'Bağı veya alışkanlığı açıkça görmek özgürlüğün başlangıcıdır. Zincirin sandığından daha gevşek olabilir; seçim gücünü yeniden fark et.',
    'Tanıdık bir arzu, korku veya gizli pazarlık senin yerine karar veriyor olabilir. Kısa vadeli rahatlığın uzun vadeli bedelini gör.',
    'Bu örüntünün bedelini adlandır ve bugün tek bir seçimi geri al.',
  ],
  'The Tower': [
    'Yanlış veya dayanıksız bir yapı çözülürken gerçek görünür hâle geliyor. Sarsıntı, daha dürüst bir temelin önünü açabilir.',
    'Zaten başlayan değişime direnmek yaşanan gerilimi büyütebilir. Görüntüyü korumak uğruna gerçeği feda etme.',
    'Gerçek olanı koru; yalnızca gösteriden ibaret olanın düşmesine izin ver.',
  ],
  'The Star': [
    'Umut; dürüstlük, yenilenme ve daha geniş bir bakışla geri dönüyor. İyileşme bir anda tamamlanmak zorunda değil; yönünü bulması yeterli.',
    'Hayal kırıklığı ihtimale güvenmeyi tehlikeli hissettiriyor olabilir. Umutsuzluk bazen yeniden incinmemek için kurulmuş bir zırhtır.',
    'Sonucu zorlamadan küçük bir inanç eylemi gerçekleştir.',
  ],
  'The Moon': [
    'Rüyalar, duygular ve sezgiler mantığın henüz düzenleyemediği bilgiyi taşıyor. Belirsizlikte ilerlerken yavaşlık sana yardımcı olur.',
    'Korku, eksik bilgilerin boşluğunu ikna edici senaryolarla dolduruyor olabilir. Hissettiğin şey gerçek olsa da vardığın sonuç kesin olmayabilir.',
    'Belirsizliği gerçek ilan etmeden önce daha fazla ışık bekle.',
  ],
  'The Sun': [
    'Canlılık, açıklık ve dürüst sevinç şu anda gereksiz karmaşıklık olmadan ulaşılabilir. Başarının görünür olmasına izin ver.',
    'Olumlu görünme baskısı gerçek bir ihtiyacını gizliyor olabilir. Işığın içinde kalmak, gölgeyi inkâr etmek anlamına gelmez.',
    'Başarının basit hissettirmesine izin ver ve sıcaklığını performansa çevirmeden paylaş.',
  ],
  'Judgement': [
    'Daha derin bir çağrı senden dürüstlükle cevap vermeni istiyor. Geçmişi inkâr etmeden daha geniş bir kimliğe uyanabilirsin.',
    'Eski utanç, seni daha küçük bir versiyonuna sadık tutuyor olabilir. Kendini sonsuza kadar geçmiş kararlarınla cezalandırma.',
    'Olmak zorunda kaldığın kişiye değil, dönüştüğün kişiye cevap ver.',
  ],
  'The World': [
    'Tamamlanma; bütünlük, güven ve daha geniş bir ufuk getiriyor. Bir döngünün derslerini sahiplenmek yeni başlangıcı sağlamlaştırır.',
    'Bitmemiş tek bir ayrıntı kapanışı tam olarak hissetmeni engelliyor olabilir. Yeniye koşmadan önce açık kalan halkayı tamamla.',
    'Yeni döngüye başlamadan önce tamamlanan şeyi onurlandır.',
  ],
};

const _minorRankMeaningTurkish = <String, List<String>>{
  'Ace': [
    'Saf bir başlangıç ve henüz biçim almamış güçlü bir potansiyel ortaya çıkıyor.',
    'Başlama arzusu var; fakat enerji kararsızlık, acele veya yanlış bir hedef yüzünden akamıyor.',
    'Potansiyeli küçük ve somut bir başlangıca dönüştür.',
  ],
  'Two': [
    'İki ihtimal arasında bilinçli bir denge ve yön seçimi gerekiyor.',
    'Karar vermeyi ertelemek veya iki zıt seçeneği aynı anda tutmak enerjini bölüyor.',
    'Her seçeneğin bedelini gör ve değerlerinle uyumlu olanı seç.',
  ],
  'Three': [
    'İfade, iş birliği ve ilk sonuçlar büyümenin başladığını gösteriyor.',
    'Dağınık katkılar, zayıf iletişim veya dış onay ihtiyacı ilerlemeyi yavaşlatabilir.',
    'Gelişimi görünür kıl ve doğru insanlarla paylaş.',
  ],
  'Four': [
    'Güven, dinlenme ve sağlam bir temel kurma ihtiyacı öne çıkıyor.',
    'Koruma isteği katılığa, kapanmaya veya değişime direnmeye dönüşmüş olabilir.',
    'Değerli olanı korurken akış için küçük bir alan bırak.',
  ],
  'Five': [
    'Sürtüşme ve eksiklik hissi gerçekten neyin önemli olduğunu görünür kılıyor.',
    'Çatışmaya, kıyaslamaya veya kayıp duygusuna saplanmak mevcut kaynaklarını görmeni engelliyor.',
    'Mücadeleyi kimliğin yapmadan öğrenebileceğin tek dersi seç.',
  ],
  'Six': [
    'Dengeye dönüş, karşılıklılık ve görülme ihtimali belirginleşiyor.',
    'Verme ile alma arasındaki dengesizlik veya onaya bağımlılık ilişkiyi bozabilir.',
    'Yardımı kabul et ve karşılıklılığın adil olup olmadığını kontrol et.',
  ],
  'Seven': [
    'Sabır, değerlendirme ve inandığın şeyi koruma sınavındasın.',
    'Şüphe, savunma veya sonuçları zorlamak emeğinin değerini görmeni engelliyor olabilir.',
    'Devam etmeden önce neyin gerçekten karşılık verdiğini değerlendir.',
  ],
  'Eight': [
    'Odak, tekrar ve becerinin gelişmesi hızlı bir ilerleme yaratabilir.',
    'Aşırı hız, mükemmeliyetçilik veya otomatik davranmak yaptığın şeyin anlamını kaybettirebilir.',
    'Bir beceriyi bilinçli tekrar yoluyla güçlendir.',
  ],
  'Nine': [
    'Tamamlanmaya yaklaşırken dayanıklılık, öz güven ve kişisel sınırlar güçleniyor.',
    'Yorgunluk, kuşku veya her şeyi tek başına taşıma çabası son adımı ağırlaştırıyor.',
    'Sınırlarını koru ve bitişe kadar gereken enerjiyi sakla.',
  ],
  'Ten': [
    'Bir döngünün bütün ağırlığı, sonucu ve ödülü artık görünür durumda.',
    'Başarıyla birlikte aşırı yük, sorumluluk veya bırakılması gereken bir fazlalık oluşmuş olabilir.',
    'Tamamlananı kabul et ve artık taşımaman gereken yükü indir.',
  ],
  'Page': [
    'Meraklı bir mesaj, öğrenme fırsatı veya taze bir bakış açısı yaklaşıyor.',
    'Tecrübesizlik, dağınık merak veya yalnızca konuşup harekete geçmemek gelişimi sınırlayabilir.',
    'Yeni başlayan zihnini koru ve öğrendiğin şeyi küçük bir deneyle test et.',
  ],
  'Knight': [
    'Adanmışlık hızla eyleme dönüşüyor ve güçlü bir ilerleme isteği taşıyor.',
    'Acelecilik, tek yönlü bakış veya sonuç uğruna çevreni görmezden gelmek sorun yaratabilir.',
    'İlerle; fakat hızını niyetin ve etkilerinle birlikte kontrol et.',
  ],
  'Queen': [
    'Olgun bir iç otorite, sezgi ve kabul gücü bu durumu taşıyabilir.',
    'Kendini unutacak kadar vermek veya duygusal gücü kontrol için kullanmak dengeyi bozabilir.',
    'İhtiyacın olan niteliği önce kendi içinde somutlaştır.',
  ],
  'King': [
    'Deneyim, sorumluluk ve yön verme gücü liderlik etmeye hazır.',
    'Katılık, egoya dayalı kontrol veya her şeyi bildiğini sanmak gerçek ustalığı gölgeleyebilir.',
    'Gücünü baskı kurmak için değil, güvenilir bir yön oluşturmak için kullan.',
  ],
};

const _minorSuitMeaningTurkish = <String, List<String>>{
  'Wands': [
    'Bu enerji motivasyon, yaratıcılık, cesaret ve girişim alanında çalışıyor.',
    'Ateşini tek bir anlamlı yöne ver; heyecan uğruna diğer ihtiyaçlarını terk etme.',
  ],
  'Cups': [
    'Bu enerji duygular, ilişkiler, yakınlık ve sezgisel bağ alanında çalışıyor.',
    'Ne hissettiğini dürüstçe kabul et; fakat duyguyu tek gerçek sanma.',
  ],
  'Swords': [
    'Bu enerji düşünceler, iletişim, gerçek ve karar alanında çalışıyor.',
    'En keskin sözü değil, durumu gerçekten netleştirecek doğru sözü seç.',
  ],
  'Pentacles': [
    'Bu enerji para, emek, beden, güven ve kalıcı değer alanında çalışıyor.',
    'Bugün ölçülebilir ve sürdürülebilir bir adımla kalıcı olanı inşa et.',
  ],
};

String localizedTarotCardName(String name, {required bool turkish}) {
  if (!turkish) return name;
  final major = _majorArcanaTurkish[name];
  if (major != null) return major;

  final parts = name.split(' of ');
  if (parts.length != 2) return name;
  final rank = _rankTurkish[parts.first];
  final suit = _suitTurkish[parts.last];
  if (rank == null || suit == null) return name;
  return '$suit $rank';
}

String localizedTarotCardMeaning(
  DrawnCard drawn, {
  required bool turkish,
}) {
  if (!turkish) return drawn.reversed ? drawn.card.shadow : drawn.card.light;

  final major = _majorMeaningTurkish[drawn.card.name];
  if (major != null) return major[drawn.reversed ? 1 : 0];

  final parts = drawn.card.name.split(' of ');
  if (parts.length != 2) {
    return drawn.reversed
        ? 'Bu kartın enerjisi şu anda gecikme, aşırılık veya içsel direnç olarak görünebilir.'
        : 'Bu kart, içinde bulunduğun ana farklı ve daha bilinçli bir açıdan bakmanı istiyor.';
  }
  final rank = _minorRankMeaningTurkish[parts.first];
  final suit = _minorSuitMeaningTurkish[parts.last];
  if (rank == null || suit == null) {
    return drawn.reversed ? drawn.card.shadow : drawn.card.light;
  }
  return '${rank[drawn.reversed ? 1 : 0]} ${suit[0]}';
}

String localizedTarotCardAdvice(
  DrawnCard drawn, {
  required bool turkish,
}) {
  if (!turkish) return drawn.card.advice;

  final major = _majorMeaningTurkish[drawn.card.name];
  if (major != null) return major[2];

  final parts = drawn.card.name.split(' of ');
  if (parts.length != 2) {
    return 'Bugün tamamlayabileceğin küçük, dürüst ve geri döndürülebilir bir adım seç.';
  }
  final rank = _minorRankMeaningTurkish[parts.first];
  final suit = _minorSuitMeaningTurkish[parts.last];
  if (rank == null || suit == null) {
    return 'Bugün tamamlayabileceğin küçük, dürüst ve geri döndürülebilir bir adım seç.';
  }
  return '${rank[2]} ${suit[1]}';
}

String localizedReadingKindTitle(
  ReadingKind kind, {
  required bool turkish,
}) {
  if (!turkish) return kind.title;
  return switch (kind) {
    ReadingKind.daily => 'Günlük Rehberlik',
    ReadingKind.love => 'Aşk ve Bağ',
    ReadingKind.career => 'Kariyer Yolu',
    ReadingKind.money => 'Para Enerjisi',
    ReadingKind.decision => 'Karar',
    ReadingKind.spiritual => 'Ruhsal Gelişim',
    ReadingKind.shadow => 'Gölge Çalışması',
    ReadingKind.compatibility => 'Aşk Uyumu',
    ReadingKind.timeline => 'Gelecek Zaman Çizgisi',
    ReadingKind.celticCross => 'Kelt Haçı',
  };
}

String localizedReadingKindSubtitle(
  ReadingKind kind, {
  required bool turkish,
}) {
  if (!turkish) return kind.subtitle;
  return switch (kind) {
    ReadingKind.daily => 'Bugün için tek ve net bir mesaj',
    ReadingKind.love => 'Kalbinin çevresindeki enerjiyi gör',
    ReadingKind.career => 'Bir sonraki profesyonel adımını netleştir',
    ReadingKind.money => 'Maddi yönünü daha iyi anla',
    ReadingKind.decision => 'Her yolun taşıdığı ihtimali gör',
    ReadingKind.spiritual => 'İç sesinin neye ihtiyaç duyduğunu dinle',
    ReadingKind.shadow => 'İyileşmek isteyen yanınla buluş',
    ReadingKind.compatibility => 'İki kalp arasındaki dinamiği oku',
    ReadingKind.timeline => 'Geçmiş, şimdi ve üç olası bölüm',
    ReadingKind.celticCross => 'On kartlık kapsamlı bir derin okuma',
  };
}

String localizedEmotionLabel(
  EmotionalState emotion, {
  required bool turkish,
}) {
  if (!turkish) return emotion.label;
  return switch (emotion) {
    EmotionalState.uncertain => 'Kararsız',
    EmotionalState.hopeful => 'Umutlu',
    EmotionalState.anxious => 'Kaygılı',
    EmotionalState.grounded => 'Dengeli',
    EmotionalState.curious => 'Meraklı',
  };
}

String localizedDeckStyleLabel(
  DeckStyle style, {
  required bool turkish,
}) {
  if (!turkish) return style.label;
  return switch (style) {
    DeckStyle.midnight => 'Gece Örtüsü',
    DeckStyle.solarGold => 'Güneş Altını',
    DeckStyle.bloodMoon => 'Kanlı Ay',
  };
}
