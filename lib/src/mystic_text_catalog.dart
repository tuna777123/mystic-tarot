import 'mystic_text_catalog_full.dart' as full;

/// Public localization facade.
///
/// The complete translation catalog remains in [full.MysticTextCatalog].
/// A small set of French labels use compact, natural wording so narrow phone
/// layouts stay readable without shrinking the rest of the interface.
class MysticTextCatalog {
  MysticTextCatalog._();

  static const Set<String> launchLanguageCodes = <String>{'ES', 'FR', 'PT-BR'};

  static bool hasTranslation(String languageCode, String english) =>
      full.MysticTextCatalog.hasTranslation(languageCode, english);

  static int exactTranslationCount(String languageCode) =>
      full.MysticTextCatalog.exactTranslationCount(languageCode);

  static int templateTranslationCount(String languageCode) =>
      full.MysticTextCatalog.templateTranslationCount(languageCode);

  static String translate(String languageCode, String english) {
    if (languageCode == 'FR') {
      final compact = _compactFrench[english];
      if (compact != null) return compact;
      if (english.endsWith(' LOCKED')) {
        return '${english.substring(0, english.length - 7)} CARTES';
      }
      if (english.startsWith('Unlock the full ')) {
        return 'Tout débloquer';
      }
    }
    return full.MysticTextCatalog.translate(languageCode, english);
  }

  static const Map<String, String> _compactFrench = <String, String>{
    'PLUS PREVIEW': 'PLUS',
    'CHOOSE YOUR CARDS': 'VOS CARTES',
    'Trust the first pull': 'Suivez l’élan',
    'The first signal is forming…': 'Chargement…',
    'The rest of your spread': 'Suite',
  };
}
