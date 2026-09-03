import 'dart:io';

void main() => materializeFirstSaveContinuity();

/// Keeps the first saved reading focused on Mystic's strongest retention loop.
///
/// A first-session save should end with a clear grounded action -> 24h Mirror
/// handoff instead of promoting story-card creation as the next step. Later
/// readings retain the existing private story-card action.
void materializeFirstSaveContinuity() {
  final app = File('lib/src/app.dart');
  if (!app.existsSync()) {
    throw StateError('Mystic Tarot app source is missing.');
  }

  final transformed = materializeFirstSaveContinuitySource(
    app.readAsStringSync(),
  );
  app.writeAsStringSync(transformed);

  if (!transformed.contains('YOUR NEXT STEP IS TOMORROW') ||
      !transformed.contains('widget.pastRecords.isEmpty') ||
      !transformed.contains('Create a private story card')) {
    throw StateError('First-save continuity verification failed.');
  }

  stdout.writeln(
    'First-save continuity materialized: first reading closes on the grounded '
    'action -> 24h Mystic Mirror loop; later readings retain story-card sharing.',
  );
}

String materializeFirstSaveContinuitySource(String source) {
  const oldValue = '''              if (revealComplete && saved) const SizedBox(height: 10),
              if (revealComplete && saved)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openStoryStudio(record),
                    icon: const Icon(Icons.ios_share_outlined),
                    label: Text(
                      localized(
                        widget.language.appLanguage,
                        english: 'Create a private story card',
                        turkish: 'Özel hikâye kartı oluştur',
                        spanish: 'Crear una tarjeta privada para historias',
                        french: 'Créer une carte privée pour story',
                        portugueseBrazil: 'Criar um card privado para stories',
                      ),
                    ),
                  ),
                ),''';

  const newValue = '''              if (revealComplete && saved) const SizedBox(height: 10),
              if (revealComplete &&
                  saved &&
                  widget.pastRecords.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MysticColors.lavender.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: MysticColors.lavender.withValues(alpha: .24),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: MysticColors.lavender,
                        size: 21,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localized(
                                widget.language.appLanguage,
                                english: 'YOUR NEXT STEP IS TOMORROW',
                                turkish: 'SIRADAKİ ADIMIN YARIN',
                                spanish: 'TU SIGUIENTE PASO ES MAÑANA',
                                french: 'VOTRE PROCHAINE ÉTAPE EST DEMAIN',
                                portugueseBrazil: 'SEU PRÓXIMO PASSO É AMANHÃ',
                              ),
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                color: MysticColors.lavender,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.05,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              localized(
                                widget.language.appLanguage,
                                english: 'Your first reading is saved. Live the aligned action, then return in 24 hours to record what actually changed.',
                                turkish: 'İlk okuman kaydedildi. Sana uygun eylemi uygula; 24 saat sonra gerçekte neyin değiştiğini kaydetmek için geri dön.',
                                spanish: 'Tu primera lectura está guardada. Pon en práctica la acción elegida y vuelve en 24 horas para registrar qué cambió realmente.',
                                french: 'Votre premier tirage est enregistré. Mettez l’action choisie en pratique, puis revenez dans 24 heures pour noter ce qui a réellement changé.',
                                portugueseBrazil: 'Sua primeira leitura foi salva. Coloque a ação escolhida em prática e volte em 24 horas para registrar o que realmente mudou.',
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else if (revealComplete && saved)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openStoryStudio(record),
                    icon: const Icon(Icons.ios_share_outlined),
                    label: Text(
                      localized(
                        widget.language.appLanguage,
                        english: 'Create a private story card',
                        turkish: 'Özel hikâye kartı oluştur',
                        spanish: 'Crear una tarjeta privada para historias',
                        french: 'Créer une carte privée pour story',
                        portugueseBrazil: 'Criar um card privado para stories',
                      ),
                    ),
                  ),
                ),''';

  if (source.contains(newValue)) return source;
  final count = oldValue.allMatches(source).length;
  if (count != 1) {
    throw StateError(
      'Unable to materialize first-save continuity: expected exactly one '
      'source anchor, found $count.',
    );
  }
  return source.replaceFirst(oldValue, newValue);
}
