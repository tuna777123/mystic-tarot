import 'flagship.dart';
import 'models.dart';
import 'mystic_mirror.dart';
import 'oracle_conversation.dart';
import 'tarot_localization.dart';

String buildMysticJournalExport({
  required Iterable<ReadingRecord> records,
  required Map<String, MysticMirrorReflection> mirrors,
  Map<String, List<OracleConversationTurn>> oracleConversations =
      const <String, List<OracleConversationTurn>>{},
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

  final recordList = records.toList(growable: false);
  final title = copy(
    en: 'Mystic Tarot — Private Journal Export',
    tr: 'Mystic Tarot — Özel Günlük Dışa Aktarımı',
    es: 'Mystic Tarot — Exportación del diario privado',
    fr: 'Mystic Tarot — Export du journal privé',
    pt: 'Mystic Tarot — Exportação do diário privado',
  );
  final privacy = copy(
    en: 'Created locally on your device. Review before sharing.',
    tr: 'Cihazında yerel olarak oluşturuldu. Paylaşmadan önce kontrol et.',
    es: 'Creado localmente en tu dispositivo. Revísalo antes de compartirlo.',
    fr: 'Créé localement sur votre appareil. Relisez-le avant de le partager.',
    pt: 'Criado localmente no seu dispositivo. Revise antes de compartilhar.',
  );

  if (recordList.isEmpty) {
    return '$title\n\n$privacy\n\n${copy(
      en: 'No saved readings yet.',
      tr: 'Henüz kayıtlı okuma yok.',
      es: 'Aún no hay lecturas guardadas.',
      fr: 'Aucun tirage enregistré pour le moment.',
      pt: 'Ainda não há leituras salvas.',
    )}';
  }

  final blocks = <String>[];
  for (var index = 0; index < recordList.length; index++) {
    final record = recordList[index];
    final mirror = mirrors[mysticMirrorRecordId(record)];
    final oracleTurns =
        oracleConversations[oracleConversationRecordId(record)] ??
            const <OracleConversationTurn>[];
    final lines = <String>[
      '${index + 1}. ${localizedReadingKindTitle(record.kind, languageCode: language.code)}',
      '${copy(en: 'Date', tr: 'Tarih', es: 'Fecha', fr: 'Date', pt: 'Data')}: ${_formatExportDate(record.createdAt)}',
      '${copy(en: 'Starting emotion', tr: 'Başlangıç duygusu', es: 'Emoción inicial', fr: 'Émotion de départ', pt: 'Emoção inicial')}: ${localizedEmotionLabel(record.emotion, languageCode: language.code)}',
    ];

    if (record.question.trim().isNotEmpty) {
      lines.add(
        '${copy(en: 'Question', tr: 'Soru', es: 'Pregunta', fr: 'Question', pt: 'Pergunta')}: ${record.question.trim()}',
      );
    }

    lines.add(
      '${copy(en: 'Cards', tr: 'Kartlar', es: 'Cartas', fr: 'Cartes', pt: 'Cartas')}: ${record.cards.map((item) {
        final orientation = item.reversed
            ? copy(
                en: 'reversed',
                tr: 'ters',
                es: 'invertida',
                fr: 'renversée',
                pt: 'invertida',
              )
            : copy(
                en: 'upright',
                tr: 'düz',
                es: 'al derecho',
                fr: 'à l’endroit',
                pt: 'normal',
              );
        return '${localizedTarotCardName(item.card.name, languageCode: language.code)} ($orientation)';
      }).join(', ')}',
    );
    lines.add(
      '${copy(en: 'Aligned action', tr: 'Uyumlu eylem', es: 'Acción alineada', fr: 'Action alignée', pt: 'Ação alinhada')}: ${record.alignedAction}',
    );

    if (mirror != null) {
      lines.add('');
      lines.add(
        copy(
          en: 'Mystic Mirror — 24-hour reflection',
          tr: 'Mystic Ayna — 24 saatlik yansıma',
          es: 'Mystic Mirror — reflexión de 24 horas',
          fr: 'Mystic Mirror — réflexion après 24 heures',
          pt: 'Mystic Mirror — reflexão de 24 horas',
        ),
      );
      lines.add(
        '${copy(en: 'Completed', tr: 'Tamamlanma', es: 'Completado', fr: 'Terminé', pt: 'Concluído')}: ${_formatExportDate(mirror.completedAt)}',
      );
      lines.add(
        '${copy(en: 'Outcome', tr: 'Sonuç', es: 'Resultado', fr: 'Résultat', pt: 'Resultado')}: ${localizedMysticMirrorOutcome(mirror.outcome, language)}',
      );
      lines.add(
        '${copy(en: 'Emotion after 24 hours', tr: '24 saat sonraki duygu', es: 'Emoción después de 24 horas', fr: 'Émotion après 24 heures', pt: 'Emoção após 24 horas')}: ${localizedEmotionLabel(mirror.emotion, languageCode: language.code)}',
      );
      if (mirror.note.trim().isNotEmpty) {
        lines.add(
          '${copy(en: 'Reflection note', tr: 'Yansıma notu', es: 'Nota de reflexión', fr: 'Note de réflexion', pt: 'Nota de reflexão')}: ${mirror.note.trim()}',
        );
      }
    }

    if (oracleTurns.isNotEmpty) {
      lines.add('');
      lines.add(
        copy(
          en: 'Oracle Dialogue — saved on this device',
          tr: 'Oracle Diyaloğu — bu cihazda kayıtlı',
          es: 'Diálogo del Oráculo — guardado en este dispositivo',
          fr: 'Dialogue de l’Oracle — enregistré sur cet appareil',
          pt: 'Diálogo do Oráculo — salvo neste dispositivo',
        ),
      );
      for (var turnIndex = 0; turnIndex < oracleTurns.length; turnIndex++) {
        final turn = oracleTurns[turnIndex];
        lines.add('');
        lines.add(
          '${turnIndex + 1}. ${copy(en: 'Question', tr: 'Soru', es: 'Pregunta', fr: 'Question', pt: 'Pergunta')}: ${turn.question}',
        );
        lines.add(
          '${copy(en: 'Oracle answer', tr: 'Oracle cevabı', es: 'Respuesta del Oráculo', fr: 'Réponse de l’Oracle', pt: 'Resposta do Oráculo')}: ${turn.answer}',
        );
        lines.add(
          '${copy(en: 'Saved', tr: 'Kaydedilme', es: 'Guardado', fr: 'Enregistré', pt: 'Salvo')}: ${_formatExportDate(turn.createdAt)}',
        );
      }
    }

    blocks.add(lines.join('\n'));
  }

  return '$title\n\n$privacy\n\n${blocks.join('\n\n————————————\n\n')}';
}

String localizedMysticMirrorOutcome(
  MysticMirrorOutcome outcome,
  MysticLanguage language,
) =>
    switch ((language, outcome)) {
      (MysticLanguage.turkish, MysticMirrorOutcome.shifted) =>
        'Bir şey değişti',
      (MysticLanguage.turkish, MysticMirrorOutcome.partlyShifted) =>
        'Kısmen değişti',
      (MysticLanguage.turkish, MysticMirrorOutcome.unchanged) =>
        'Henüz değişmedi',
      (MysticLanguage.turkish, MysticMirrorOutcome.unclear) =>
        'Hâlâ belirsiz',
      (MysticLanguage.spanish, MysticMirrorOutcome.shifted) => 'Algo cambió',
      (MysticLanguage.spanish, MysticMirrorOutcome.partlyShifted) =>
        'Cambió en parte',
      (MysticLanguage.spanish, MysticMirrorOutcome.unchanged) =>
        'Aún no cambió',
      (MysticLanguage.spanish, MysticMirrorOutcome.unclear) =>
        'Sigue sin estar claro',
      (MysticLanguage.french, MysticMirrorOutcome.shifted) =>
        'Quelque chose a changé',
      (MysticLanguage.french, MysticMirrorOutcome.partlyShifted) =>
        'Partiellement changé',
      (MysticLanguage.french, MysticMirrorOutcome.unchanged) =>
        'Rien n’a encore changé',
      (MysticLanguage.french, MysticMirrorOutcome.unclear) =>
        'Toujours incertain',
      (MysticLanguage.portugueseBrazil, MysticMirrorOutcome.shifted) =>
        'Algo mudou',
      (
        MysticLanguage.portugueseBrazil,
        MysticMirrorOutcome.partlyShifted,
      ) =>
        'Mudou em parte',
      (MysticLanguage.portugueseBrazil, MysticMirrorOutcome.unchanged) =>
        'Ainda não mudou',
      (MysticLanguage.portugueseBrazil, MysticMirrorOutcome.unclear) =>
        'Ainda não está claro',
      (_, MysticMirrorOutcome.shifted) => 'Something shifted',
      (_, MysticMirrorOutcome.partlyShifted) => 'Partly changed',
      (_, MysticMirrorOutcome.unchanged) => 'Nothing changed yet',
      (_, MysticMirrorOutcome.unclear) => 'Still unclear',
    };

String _formatExportDate(DateTime value) => value.toLocal().toIso8601String();
