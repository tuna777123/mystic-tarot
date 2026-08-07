import 'flagship.dart';
import 'reading_journal_store.dart';

String? localizedJournalRecoveryNotice(
  ReadingJournalLoadResult result,
  MysticLanguage language,
) {
  if (!result.recoveredFromBackup &&
      !result.migratedFromLegacy &&
      result.rejectedItems == 0) {
    return null;
  }

  String copy({
    required String en,
    required String tr,
    required String es,
    required String fr,
    required String pt,
  }) => switch (language) {
    MysticLanguage.turkish => tr,
    MysticLanguage.spanish => es,
    MysticLanguage.french => fr,
    MysticLanguage.portugueseBrazil => pt,
    _ => en,
  };

  final rejected = result.rejectedItems;
  if (result.recoveredFromBackup) {
    if (rejected > 0) {
      return copy(
        en: 'Your journal was recovered from its last valid backup. $rejected damaged ${rejected == 1 ? 'entry was' : 'entries were'} skipped.',
        tr: 'Günlüğün son sağlam yedekten kurtarıldı. $rejected bozuk kayıt atlandı.',
        es: 'Tu diario se recuperó desde la última copia válida. Se ${rejected == 1 ? 'omitió 1 entrada dañada' : 'omitieron $rejected entradas dañadas'}.',
        fr: 'Votre journal a été restauré depuis sa dernière sauvegarde valide. ${rejected == 1 ? '1 entrée endommagée a été ignorée' : '$rejected entrées endommagées ont été ignorées'}.',
        pt: 'Seu diário foi recuperado do último backup válido. ${rejected == 1 ? '1 registro danificado foi ignorado' : '$rejected registros danificados foram ignorados'}.',
      );
    }
    return copy(
      en: 'Your journal was recovered from its last valid local backup.',
      tr: 'Günlüğün son sağlam yerel yedekten kurtarıldı.',
      es: 'Tu diario se recuperó desde la última copia local válida.',
      fr: 'Votre journal a été restauré depuis sa dernière sauvegarde locale valide.',
      pt: 'Seu diário foi recuperado do último backup local válido.',
    );
  }

  if (result.migratedFromLegacy) {
    if (rejected > 0) {
      return copy(
        en: 'Your earlier journal was upgraded safely. $rejected damaged ${rejected == 1 ? 'entry was' : 'entries were'} skipped.',
        tr: 'Eski günlüğün güvenle yükseltildi. $rejected bozuk kayıt atlandı.',
        es: 'Tu diario anterior se actualizó de forma segura. Se ${rejected == 1 ? 'omitió 1 entrada dañada' : 'omitieron $rejected entradas dañadas'}.',
        fr: 'Votre ancien journal a été mis à niveau en toute sécurité. ${rejected == 1 ? '1 entrée endommagée a été ignorée' : '$rejected entrées endommagées ont été ignorées'}.',
        pt: 'Seu diário anterior foi atualizado com segurança. ${rejected == 1 ? '1 registro danificado foi ignorado' : '$rejected registros danificados foram ignorados'}.',
      );
    }
    return copy(
      en: 'Your earlier journal was upgraded to the safer local format.',
      tr: 'Eski günlüğün daha güvenli yerel biçime yükseltildi.',
      es: 'Tu diario anterior se actualizó al formato local más seguro.',
      fr: 'Votre ancien journal a été mis à niveau vers le format local plus sûr.',
      pt: 'Seu diário anterior foi atualizado para o formato local mais seguro.',
    );
  }

  return copy(
    en: '$rejected damaged ${rejected == 1 ? 'entry was' : 'entries were'} skipped. The rest of your journal is safe.',
    tr: '$rejected bozuk kayıt atlandı. Günlüğünün geri kalanı güvende.',
    es: 'Se ${rejected == 1 ? 'omitió 1 entrada dañada' : 'omitieron $rejected entradas dañadas'}. El resto de tu diario está a salvo.',
    fr: '${rejected == 1 ? '1 entrée endommagée a été ignorée' : '$rejected entrées endommagées ont été ignorées'}. Le reste de votre journal est intact.',
    pt: '${rejected == 1 ? '1 registro danificado foi ignorado' : '$rejected registros danificados foram ignorados'}. O restante do seu diário está seguro.',
  );
}
