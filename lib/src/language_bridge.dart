import 'app_language.dart';
import 'flagship.dart';

/// Compatibility bridge used while legacy screens are migrated from the
/// original English/Turkish enum to the seven-language app model.
extension AppLanguageLegacyBridge on AppLanguage {
  MysticLanguage get legacyLanguage =>
      this == AppLanguage.turkish ? MysticLanguage.turkish : MysticLanguage.english;
}

extension MysticLanguageAppBridge on MysticLanguage {
  AppLanguage get appLanguage =>
      this == MysticLanguage.turkish ? AppLanguage.turkish : AppLanguage.english;
}

/// Returns the selected seven-language value while allowing legacy screens to
/// keep rendering English copy until their translation catalog is migrated.
class LanguageSelectionState {
  const LanguageSelectionState(this.appLanguage);

  final AppLanguage appLanguage;

  MysticLanguage get legacyLanguage => appLanguage.legacyLanguage;
  String get storageValue => appLanguage.storageValue;

  LanguageSelectionState select(AppLanguage value) => LanguageSelectionState(value);
}
