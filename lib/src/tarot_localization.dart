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
