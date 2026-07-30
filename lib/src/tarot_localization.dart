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
