export 'flagship.dart' show MysticLanguage;

enum AppLanguage {
  english('English', 'EN', 'en'),
  spanish('Español', 'ES', 'es'),
  french('Français', 'FR', 'fr'),
  portugueseBrazil('Português (Brasil)', 'PT-BR', 'pt_BR'),
  turkish('Türkçe', 'TR', 'tr'),
  italian('Italiano', 'IT', 'it'),
  german('Deutsch', 'DE', 'de');

  const AppLanguage(this.label, this.code, this.localeTag);

  final String label;
  final String code;
  final String localeTag;

  static AppLanguage fromName(String? value) {
    for (final language in values) {
      if (language.name == value) return language;
    }
    return AppLanguage.english;
  }
}

class LocalizedText {
  const LocalizedText({
    required this.english,
    this.spanish,
    this.french,
    this.portugueseBrazil,
    this.turkish,
    this.italian,
    this.german,
  });

  final String english;
  final String? spanish;
  final String? french;
  final String? portugueseBrazil;
  final String? turkish;
  final String? italian;
  final String? german;

  String resolve(AppLanguage language) => switch (language) {
        AppLanguage.english => english,
        AppLanguage.spanish => spanish ?? english,
        AppLanguage.french => french ?? english,
        AppLanguage.portugueseBrazil => portugueseBrazil ?? english,
        AppLanguage.turkish => turkish ?? english,
        AppLanguage.italian => italian ?? english,
        AppLanguage.german => german ?? english,
      };
}

String localized(
  AppLanguage language, {
  required String english,
  String? spanish,
  String? french,
  String? portugueseBrazil,
  String? turkish,
  String? italian,
  String? german,
}) =>
    LocalizedText(
      english: english,
      spanish: spanish,
      french: french,
      portugueseBrazil: portugueseBrazil,
      turkish: turkish,
      italian: italian,
      german: german,
    ).resolve(language);
