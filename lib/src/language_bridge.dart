import 'app_language.dart';
import 'flagship.dart';

extension AppLanguageLegacyBridge on AppLanguage {
  MysticLanguage get legacyLanguage => switch (this) {
    AppLanguage.english => MysticLanguage.english,
    AppLanguage.spanish => MysticLanguage.spanish,
    AppLanguage.french => MysticLanguage.french,
    AppLanguage.portugueseBrazil => MysticLanguage.portugueseBrazil,
    AppLanguage.turkish => MysticLanguage.turkish,
    AppLanguage.italian => MysticLanguage.italian,
    AppLanguage.german => MysticLanguage.german,
  };
}

extension MysticLanguageAppBridge on MysticLanguage {
  AppLanguage get appLanguage => switch (this) {
    MysticLanguage.english => AppLanguage.english,
    MysticLanguage.spanish => AppLanguage.spanish,
    MysticLanguage.french => AppLanguage.french,
    MysticLanguage.portugueseBrazil => AppLanguage.portugueseBrazil,
    MysticLanguage.turkish => AppLanguage.turkish,
    MysticLanguage.italian => AppLanguage.italian,
    MysticLanguage.german => AppLanguage.german,
  };
}

class LanguageSelectionState {
  const LanguageSelectionState(this.appLanguage);

  final AppLanguage appLanguage;

  MysticLanguage get legacyLanguage => appLanguage.legacyLanguage;
  String get storageValue => appLanguage.localeTag;

  LanguageSelectionState select(AppLanguage value) =>
      LanguageSelectionState(value);
}
