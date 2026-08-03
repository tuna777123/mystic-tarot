import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'flagship.dart';
import 'models.dart';
import 'private_journal_transfer.dart';
import 'theme.dart';
import 'widgets.dart';

class PrivateJournalTransferScreen extends StatefulWidget {
  const PrivateJournalTransferScreen({
    required this.records,
    required this.language,
    required this.onRestored,
    super.key,
  });

  final List<ReadingRecord> records;
  final MysticLanguage language;
  final ValueChanged<List<ReadingRecord>> onRestored;

  @override
  State<PrivateJournalTransferScreen> createState() =>
      _PrivateJournalTransferScreenState();
}

class _PrivateJournalTransferScreenState
    extends State<PrivateJournalTransferScreen> {
  final _controller = TextEditingController();
  final _service = PrivateJournalTransferService();
  PrivateJournalTransferPreview? _preview;
  String? _error;
  String? _success;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(_copy(
          en: 'Private journal transfer',
          tr: 'Özel günlük taşıma',
          es: 'Transferencia del diario privado',
          fr: 'Transfert du journal privé',
          pt: 'Transferência do diário privado',
        ))),
        body: MysticBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _privacyCard(context),
              const SizedBox(height: 18),
              Text(
                _copy(
                  en: 'Move your complete reflection history',
                  tr: 'Tüm düşünme geçmişini taşı',
                  es: 'Mueve todo tu historial de reflexión',
                  fr: 'Transférez tout votre historique de réflexion',
                  pt: 'Mova todo o seu histórico de reflexão',
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _copy(
                  en: 'The transfer code includes saved readings, Mystic Mirror reflections, and Oracle conversations. It does not include purchases, XP, reminders, or account data.',
                  tr: 'Taşıma kodu kayıtlı okumaları, Mystic Mirror yansımalarını ve Oracle konuşmalarını içerir. Satın alımları, XP’yi, hatırlatıcıları veya hesap verilerini içermez.',
                  es: 'El código incluye lecturas, reflexiones de Mystic Mirror y conversaciones de Oracle. No incluye compras, XP, recordatorios ni datos de cuenta.',
                  fr: 'Le code inclut les tirages, les réflexions Mystic Mirror et les conversations Oracle. Il n’inclut pas les achats, l’XP, les rappels ni les données de compte.',
                  pt: 'O código inclui leituras, reflexões do Mystic Mirror e conversas do Oracle. Não inclui compras, XP, lembretes nem dados da conta.',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _busy || widget.records.isEmpty ? null : _shareCode,
                icon: const Icon(Icons.ios_share_outlined),
                label: Text(_copy(
                  en: 'Create private transfer code',
                  tr: 'Özel taşıma kodu oluştur',
                  es: 'Crear código privado',
                  fr: 'Créer un code privé',
                  pt: 'Criar código privado',
                )),
              ),
              if (widget.records.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _copy(
                    en: 'Save at least one reading before creating a transfer code.',
                    tr: 'Taşıma kodu oluşturmadan önce en az bir okuma kaydet.',
                    es: 'Guarda al menos una lectura antes de crear un código.',
                    fr: 'Enregistrez au moins un tirage avant de créer un code.',
                    pt: 'Salve pelo menos uma leitura antes de criar um código.',
                  ),
                  style: const TextStyle(color: MysticColors.muted),
                ),
              ],
              const SizedBox(height: 26),
              Text(
                _copy(
                  en: 'Restore from a code',
                  tr: 'Koddan geri yükle',
                  es: 'Restaurar desde un código',
                  fr: 'Restaurer depuis un code',
                  pt: 'Restaurar por um código',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 7),
              Text(
                _copy(
                  en: 'Paste a code from another device. Mystic validates everything before showing what would change.',
                  tr: 'Başka bir cihazdaki kodu yapıştır. Mystic neyin değişeceğini göstermeden önce her şeyi doğrular.',
                  es: 'Pega un código de otro dispositivo. Mystic valida todo antes de mostrar los cambios.',
                  fr: 'Collez un code provenant d’un autre appareil. Mystic valide tout avant d’afficher les changements.',
                  pt: 'Cole um código de outro dispositivo. O Mystic valida tudo antes de mostrar as mudanças.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 4,
                maxLines: 8,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (_) => setState(() {
                  _preview = null;
                  _error = null;
                  _success = null;
                }),
                decoration: InputDecoration(
                  hintText: 'MYSTIC-TAROT-JOURNAL-V1…',
                  alignLabelWithHint: true,
                  suffixIcon: IconButton(
                    tooltip: _copy(
                      en: 'Paste from clipboard',
                      tr: 'Panodan yapıştır',
                      es: 'Pegar del portapapeles',
                      fr: 'Coller depuis le presse-papiers',
                      pt: 'Colar da área de transferência',
                    ),
                    onPressed: _busy ? null : _paste,
                    icon: const Icon(Icons.content_paste_go_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy ? null : _validate,
                icon: const Icon(Icons.verified_user_outlined),
                label: Text(_copy(
                  en: 'Validate transfer',
                  tr: 'Taşımayı doğrula',
                  es: 'Validar transferencia',
                  fr: 'Valider le transfert',
                  pt: 'Validar transferência',
                )),
              ),
              if (_busy) ...[
                const SizedBox(height: 14),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_error != null) ...[
                const SizedBox(height: 14),
                _messageCard(
                  icon: Icons.error_outline,
                  text: _error!,
                  accent: const Color(0xFFFF8090),
                ),
              ],
              if (_success != null) ...[
                const SizedBox(height: 14),
                _messageCard(
                  icon: Icons.check_circle_outline,
                  text: _success!,
                  accent: const Color(0xFF8FE3B0),
                ),
              ],
              if (_preview != null) ...[
                const SizedBox(height: 16),
                _previewCard(context, _preview!),
              ],
            ],
          ),
        ),
      );

  Widget _privacyCard(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: MysticColors.violet.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: MysticColors.lavender.withValues(alpha: .3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline, color: MysticColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _copy(
                  en: 'The code is created and restored on your devices. Mystic does not upload it. Anyone who receives the code can read the private content inside it, so share it only with yourself.',
                  tr: 'Kod cihazlarında oluşturulur ve geri yüklenir. Mystic kodu yüklemez. Kodu alan herkes içindeki özel içeriği okuyabilir; yalnızca kendinle paylaş.',
                  es: 'El código se crea y restaura en tus dispositivos. Mystic no lo sube. Quien reciba el código podrá leer su contenido privado; compártelo solo contigo.',
                  fr: 'Le code est créé et restauré sur vos appareils. Mystic ne le téléverse pas. Toute personne qui le reçoit peut lire son contenu privé ; partagez-le uniquement avec vous-même.',
                  pt: 'O código é criado e restaurado nos seus dispositivos. O Mystic não o envia. Quem receber o código poderá ler o conteúdo privado; compartilhe apenas com você.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );

  Widget _previewCard(
    BuildContext context,
    PrivateJournalTransferPreview preview,
  ) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _copy(
                en: 'Verified transfer',
                tr: 'Doğrulanmış taşıma',
                es: 'Transferencia verificada',
                fr: 'Transfert vérifié',
                pt: 'Transferência verificada',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _countRow(
              Icons.menu_book_outlined,
              _copy(
                en: '${preview.importedReadings} readings • ${preview.addedReadings} new',
                tr: '${preview.importedReadings} okuma • ${preview.addedReadings} yeni',
                es: '${preview.importedReadings} lecturas • ${preview.addedReadings} nuevas',
                fr: '${preview.importedReadings} tirages • ${preview.addedReadings} nouveaux',
                pt: '${preview.importedReadings} leituras • ${preview.addedReadings} novas',
              ),
            ),
            _countRow(
              Icons.compare_arrows,
              _copy(
                en: '${preview.importedReflections} Mirror reflections • ${preview.changedReflections} new or newer',
                tr: '${preview.importedReflections} Mirror yansıması • ${preview.changedReflections} yeni veya daha güncel',
                es: '${preview.importedReflections} reflexiones Mirror • ${preview.changedReflections} nuevas o más recientes',
                fr: '${preview.importedReflections} réflexions Mirror • ${preview.changedReflections} nouvelles ou plus récentes',
                pt: '${preview.importedReflections} reflexões Mirror • ${preview.changedReflections} novas ou mais recentes',
              ),
            ),
            _countRow(
              Icons.forum_outlined,
              _copy(
                en: '${preview.importedOracleTurns} Oracle messages • ${preview.addedOracleTurns} new',
                tr: '${preview.importedOracleTurns} Oracle mesajı • ${preview.addedOracleTurns} yeni',
                es: '${preview.importedOracleTurns} mensajes Oracle • ${preview.addedOracleTurns} nuevos',
                fr: '${preview.importedOracleTurns} messages Oracle • ${preview.addedOracleTurns} nouveaux',
                pt: '${preview.importedOracleTurns} mensagens Oracle • ${preview.addedOracleTurns} novas',
              ),
            ),
            if (preview.rejectedItems > 0)
              _countRow(
                Icons.shield_outlined,
                _copy(
                  en: '${preview.rejectedItems} damaged or unrelated items will be ignored',
                  tr: '${preview.rejectedItems} bozuk veya ilgisiz öğe yok sayılacak',
                  es: 'Se ignorarán ${preview.rejectedItems} elementos dañados o ajenos',
                  fr: '${preview.rejectedItems} éléments endommagés ou sans rapport seront ignorés',
                  pt: '${preview.rejectedItems} itens danificados ou não relacionados serão ignorados',
                ),
              ),
            const SizedBox(height: 12),
            Text(
              _copy(
                en: 'Existing local readings are preserved. Duplicates are not added. A newer Mirror reflection may replace an older one for the same reading.',
                tr: 'Mevcut yerel okumalar korunur. Kopyalar eklenmez. Aynı okuma için daha yeni bir Mirror yansıması eskisinin yerini alabilir.',
                es: 'Las lecturas locales se conservan. No se añaden duplicados. Una reflexión Mirror más reciente puede sustituir a una anterior.',
                fr: 'Les tirages locaux sont conservés. Aucun doublon n’est ajouté. Une réflexion Mirror plus récente peut remplacer une ancienne.',
                pt: 'As leituras locais são preservadas. Duplicatas não são adicionadas. Uma reflexão Mirror mais recente pode substituir uma antiga.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            GoldButton(
              label: preview.totalChanges == 0
                  ? _copy(
                      en: 'Everything is already here',
                      tr: 'Her şey zaten burada',
                      es: 'Todo ya está aquí',
                      fr: 'Tout est déjà présent',
                      pt: 'Tudo já está aqui',
                    )
                  : _copy(
                      en: 'Merge verified history',
                      tr: 'Doğrulanmış geçmişi birleştir',
                      es: 'Combinar historial verificado',
                      fr: 'Fusionner l’historique vérifié',
                      pt: 'Mesclar histórico verificado',
                    ),
              icon: preview.totalChanges == 0
                  ? Icons.done_all
                  : Icons.merge_type,
              onPressed: preview.totalChanges == 0 ? () {} : _confirmAndCommit,
            ),
          ],
        ),
      );

  Widget _countRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: MysticColors.gold),
            const SizedBox(width: 9),
            Expanded(child: Text(text)),
          ],
        ),
      );

  Widget _messageCard({
    required IconData icon,
    required String text,
    required Color accent,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: .45)),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      );

  Future<void> _shareCode() async {
    setState(() {
      _busy = true;
      _error = null;
      _success = null;
    });
    try {
      final code = await _service.createCode(widget.records);
      await SharePlus.instance.share(
        ShareParams(
          text: code,
          title: _copy(
            en: 'Mystic Tarot private journal transfer',
            tr: 'Mystic Tarot özel günlük taşıması',
            es: 'Transferencia del diario privado de Mystic Tarot',
            fr: 'Transfert du journal privé Mystic Tarot',
            pt: 'Transferência do diário privado Mystic Tarot',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = _copy(
            en: 'The private transfer code could not be created.',
            tr: 'Özel taşıma kodu oluşturulamadı.',
            es: 'No se pudo crear el código privado.',
            fr: 'Impossible de créer le code privé.',
            pt: 'Não foi possível criar o código privado.',
          ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      setState(() => _error = _copy(
            en: 'The clipboard does not contain a transfer code.',
            tr: 'Panoda bir taşıma kodu yok.',
            es: 'El portapapeles no contiene un código.',
            fr: 'Le presse-papiers ne contient aucun code.',
            pt: 'A área de transferência não contém um código.',
          ));
      return;
    }
    _controller.text = text;
    setState(() {
      _preview = null;
      _error = null;
      _success = null;
    });
  }

  Future<void> _validate() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _error = _copy(
            en: 'Paste a transfer code first.',
            tr: 'Önce bir taşıma kodu yapıştır.',
            es: 'Pega primero un código.',
            fr: 'Collez d’abord un code.',
            pt: 'Cole um código primeiro.',
          ));
      return;
    }
    setState(() {
      _busy = true;
      _preview = null;
      _error = null;
      _success = null;
    });
    try {
      final preview = await _service.preview(
        code: code,
        currentRecords: widget.records,
      );
      if (!mounted) return;
      setState(() => _preview = preview);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = _copy(
            en: 'This is not a valid or supported Mystic Tarot transfer code. Nothing was changed.',
            tr: 'Bu geçerli veya desteklenen bir Mystic Tarot taşıma kodu değil. Hiçbir şey değiştirilmedi.',
            es: 'No es un código válido o compatible. No se cambió nada.',
            fr: 'Ce code Mystic Tarot est invalide ou non pris en charge. Rien n’a été modifié.',
            pt: 'Este código não é válido ou compatível. Nada foi alterado.',
          ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmAndCommit() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_copy(
          en: 'Merge private history?',
          tr: 'Özel geçmiş birleştirilsin mi?',
          es: '¿Combinar el historial privado?',
          fr: 'Fusionner l’historique privé ?',
          pt: 'Mesclar o histórico privado?',
        )),
        content: Text(_copy(
          en: 'Mystic will preserve your current readings, add missing history, and keep a rollback snapshot while saving. This cannot restore purchases or account settings.',
          tr: 'Mystic mevcut okumalarını koruyacak, eksik geçmişi ekleyecek ve kaydederken geri dönüş anlık görüntüsü tutacak. Satın alımları veya hesap ayarlarını geri yüklemez.',
          es: 'Mystic conservará tus lecturas, añadirá el historial faltante y guardará una copia de reversión. No restaura compras ni ajustes de cuenta.',
          fr: 'Mystic conservera vos tirages, ajoutera l’historique manquant et gardera un instantané de retour. Les achats et réglages de compte ne sont pas restaurés.',
          pt: 'O Mystic preservará suas leituras, adicionará o histórico ausente e manterá um instantâneo de reversão. Compras e configurações da conta não são restauradas.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_copy(
              en: 'Cancel',
              tr: 'Vazgeç',
              es: 'Cancelar',
              fr: 'Annuler',
              pt: 'Cancelar',
            )),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_copy(
              en: 'Merge',
              tr: 'Birleştir',
              es: 'Combinar',
              fr: 'Fusionner',
              pt: 'Mesclar',
            )),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;

    setState(() {
      _busy = true;
      _error = null;
      _success = null;
    });
    try {
      final result = await _service.commit(
        code: _controller.text.trim(),
        currentRecords: widget.records,
      );
      widget.onRestored(result.mergedRecords);
      if (!mounted) return;
      setState(() {
        _preview = null;
        _success = _copy(
          en: '${result.addedReadings} readings, ${result.changedReflections} Mirror reflections, and ${result.addedOracleTurns} Oracle messages were safely merged.',
          tr: '${result.addedReadings} okuma, ${result.changedReflections} Mirror yansıması ve ${result.addedOracleTurns} Oracle mesajı güvenle birleştirildi.',
          es: 'Se combinaron de forma segura ${result.addedReadings} lecturas, ${result.changedReflections} reflexiones Mirror y ${result.addedOracleTurns} mensajes Oracle.',
          fr: '${result.addedReadings} tirages, ${result.changedReflections} réflexions Mirror et ${result.addedOracleTurns} messages Oracle ont été fusionnés en toute sécurité.',
          pt: '${result.addedReadings} leituras, ${result.changedReflections} reflexões Mirror e ${result.addedOracleTurns} mensagens Oracle foram mescladas com segurança.',
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = _copy(
            en: 'The restore could not be committed. Your previous local data was kept.',
            tr: 'Geri yükleme kaydedilemedi. Önceki yerel verilerin korundu.',
            es: 'No se pudo guardar la restauración. Tus datos locales anteriores se conservaron.',
            fr: 'La restauration n’a pas pu être enregistrée. Vos données locales précédentes ont été conservées.',
            pt: 'A restauração não pôde ser salva. Seus dados locais anteriores foram preservados.',
          ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _copy({
    required String en,
    required String tr,
    required String es,
    required String fr,
    required String pt,
  }) =>
      switch (widget.language) {
        MysticLanguage.turkish => tr,
        MysticLanguage.spanish => es,
        MysticLanguage.french => fr,
        MysticLanguage.portugueseBrazil => pt,
        _ => en,
      };
}
