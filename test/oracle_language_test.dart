import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/oracle_language.dart';

void main() {
  test('detects hidden-risk questions in every launch language', () {
    const samples = <MysticLanguage, String>{
      MysticLanguage.english: 'What am I not seeing here?',
      MysticLanguage.turkish: 'Burada neyi gözden kaçırıyorum?',
      MysticLanguage.spanish: '¿Qué riesgo no estoy viendo?',
      MysticLanguage.french: 'Quel risque est-ce que je ne vois pas ?',
      MysticLanguage.portugueseBrazil: 'Que risco eu não estou vendo?',
    };

    for (final entry in samples.entries) {
      expect(
        detectOracleQuestionIntent(entry.value, entry.key),
        OracleQuestionIntent.hidden,
      );
    }
  });

  test('detects key-card questions with accents and punctuation', () {
    const samples = <MysticLanguage, String>{
      MysticLanguage.english: 'Which card matters most?',
      MysticLanguage.turkish: 'En önemli kart hangisi?',
      MysticLanguage.spanish: '¿Cuál carta es la más importante?',
      MysticLanguage.french: 'Quelle est la carte la plus importante ?',
      MysticLanguage.portugueseBrazil: 'Qual carta é a mais importante?',
    };

    for (final entry in samples.entries) {
      expect(
        detectOracleQuestionIntent(entry.value, entry.key),
        OracleQuestionIntent.keyCard,
      );
    }
  });

  test('ordinary follow-ups stay general', () {
    for (final language in <MysticLanguage>[
      MysticLanguage.english,
      MysticLanguage.turkish,
      MysticLanguage.spanish,
      MysticLanguage.french,
      MysticLanguage.portugueseBrazil,
    ]) {
      expect(
        detectOracleQuestionIntent('What should I do next?', language),
        OracleQuestionIntent.general,
      );
    }
  });
}
