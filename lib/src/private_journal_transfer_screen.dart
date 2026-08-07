import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'flagship.dart';
import 'journal_transfer_protection.dart';
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
  final _codeController = TextEditingController();
  final _createPassphraseController = TextEditingController();
  final _confirmPassphraseController = TextEditingController();
  final _restorePassphraseController = TextEditingController();
  final _service = PrivateJournalTransferService();

  PrivateJournalTransferPreview? _preview;
  String? _error;
  String? _success;
  bool _busy = false;
  bool _showCreatePassphrase = false;
  bool _showRestorePassphrase = false;

  @override
  void dispose() {
    _codeController.dispose();
    _createPassphraseController.dispose();
    _confirmPassphraseController.dispose();
    _restorePassphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        _copy(
          en: 'Protected journal transfer',
          tr: 'Korumalı günlük taşıma',
          es: 'Transferencia protegida',
          fr: 'Transfert protégé du journal',
          pt: 'Transferência protegida',
        ),
      ),
    ),
    body: MysticBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _privacyCard(context),
          const SizedBox(height: 22),
          Text(
            _copy(
              en: 'Create a protected transfer',
              tr: 'Korumalı taşıma oluştur',
              es: 'Crear una transferencia protegida',
              fr: 'Créer un transfert protégé',
              pt: 'Criar uma transferência protegida',
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _copy(
              en: 'Choose a passphrase you can enter on the other device. Mystic never saves or uploads it.',
              tr: 'Diğer cihazda girebileceğin bir parola seç. Mystic bu parolayı asla kaydetmez veya yüklemez.',
              es: 'Elige una frase que puedas escribir en el otro dispositivo. Mystic nunca la guarda ni la sube.',
              fr: 'Choisissez une phrase que vous pourrez saisir sur l’autre appareil. Mystic ne l’enregistre ni ne la téléverse.',
              pt: 'Escolha uma frase que você possa digitar no outro aparelho. O Mystic nunca a salva nem envia.',
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 14),
          _passphraseField(
            key: const Key('privateTransferCreatePassphrase'),
            controller: _createPassphraseController,
            label: _copy(
              en: 'Passphrase',
              tr: 'Parola',
              es: 'Frase de acceso',
              fr: 'Phrase secrète',
              pt: 'Frase secreta',
            ),
            visible: _showCreatePassphrase,
            onToggle: () =>
                setState(() => _showCreatePassphrase = !_showCreatePassphrase),
          ),
          const SizedBox(height: 10),
          _passphraseField(
            key: const Key('privateTransferConfirmPassphrase'),
            controller: _confirmPassphraseController,
            label: _copy(
              en: 'Confirm passphrase',
              tr: 'Parolayı doğrula',
              es: 'Confirmar frase',
              fr: 'Confirmer la phrase',
              pt: 'Confirmar frase',
            ),
            visible: _showCreatePassphrase,
            onToggle: () =>
                setState(() => _showCreatePassphrase = !_showCreatePassphrase),
          ),
          const SizedBox(height: 8),
          Text(
            _copy(
              en: 'Use at least ${JournalTransferProtection.minimumPassphraseLength} characters. If you forget it, the protected code cannot be recovered.',
              tr: 'En az ${JournalTransferProtection.minimumPassphraseLength} karakter kullan. Parolayı unutursan korumalı kod kurtarılamaz.',
              es: 'Usa al menos ${JournalTransferProtection.minimumPassphraseLength} caracteres. Si la olvidas, el código no se puede recuperar.',
              fr: 'Utilisez au moins ${JournalTransferProtection.minimumPassphraseLength} caractères. Si vous l’oubliez, le code ne peut pas être récupéré.',
              pt: 'Use pelo menos ${JournalTransferProtection.minimumPassphraseLength} caracteres. Se esquecer, o código não poderá ser recuperado.',
            ),
            style: const TextStyle(color: MysticColors.muted),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _busy || widget.records.isEmpty ? null : _shareCode,
            icon: const Icon(Icons.lock_outline),
            label: Text(
              _copy(
                en: 'Create protected code',
                tr: 'Korumalı kod oluştur',
                es: 'Crear código protegido',
                fr: 'Créer le code protégé',
                pt: 'Criar código protegido',
              ),
            ),
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
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 20),
          Text(
            _copy(
              en: 'Restore on this device',
              tr: 'Bu cihazda geri yükle',
              es: 'Restaurar en este dispositivo',
              fr: 'Restaurer sur cet appareil',
              pt: 'Restaurar neste aparelho',
            ),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 7),
          Text(
            _copy(
              en: 'Paste a protected V2 code or an older V1 code. Nothing changes until validation and confirmation are complete.',
              tr: 'Korumalı V2 kodunu veya eski bir V1 kodunu yapıştır. Doğrulama ve onay tamamlanana kadar hiçbir şey değişmez.',
              es: 'Pega un código V2 protegido o un código V1 anterior. Nada cambia hasta completar la validación y la confirmación.',
              fr: 'Collez un code V2 protégé ou un ancien code V1. Rien ne change avant la validation et la confirmation.',
              pt: 'Cole um código V2 protegido ou um código V1 antigo. Nada muda antes da validação e confirmação.',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('privateTransferCodeField'),
            controller: _codeController,
            minLines: 4,
            maxLines: 8,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (_) => _resetMessages(),
            decoration: InputDecoration(
              hintText: 'MYSTIC-TAROT-JOURNAL-V2…',
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
          const SizedBox(height: 10),
          _passphraseField(
            key: const Key('privateTransferRestorePassphrase'),
            controller: _restorePassphraseController,
            label: _copy(
              en: 'Passphrase for protected code',
              tr: 'Korumalı kodun parolası',
              es: 'Frase del código protegido',
              fr: 'Phrase du code protégé',
              pt: 'Frase do código protegido',
            ),
            visible: _showRestorePassphrase,
            onToggle: () => setState(
              () => _showRestorePassphrase = !_showRestorePassphrase,
            ),
            helper: _copy(
              en: 'Leave empty only for legacy V1 codes.',
              tr: 'Yalnızca eski V1 kodları için boş bırak.',
              es: 'Déjala vacía solo para códigos V1 antiguos.',
              fr: 'Laissez vide uniquement pour les anciens codes V1.',
              pt: 'Deixe em branco apenas para códigos V1 antigos.',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _validate,
            icon: const Icon(Icons.verified_user_outlined),
            label: Text(
              _copy(
                en: 'Unlock and validate',
                tr: 'Kilidi aç ve doğrula',
                es: 'Desbloquear y validar',
                fr: 'Déverrouiller et valider',
                pt: 'Desbloquear e validar',
              ),
            ),
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

  Widget _passphraseField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    String? helper,
  }) => TextField(
    key: key,
    controller: controller,
    obscureText: !visible,
    autocorrect: false,
    enableSuggestions: false,
    onChanged: (_) => _resetMessages(),
    decoration: InputDecoration(
      labelText: label,
      helperText: helper,
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
      ),
    ),
  );

  Widget _privacyCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: MysticColors.violet.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: MysticColors.lavender.withValues(alpha: .3)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.enhanced_encryption, color: MysticColors.gold),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _copy(
              en: 'New transfer codes are encrypted before sharing. The passphrase and journal stay on your devices; Mystic cannot read, recover, or reset them.',
              tr: 'Yeni taşıma kodları paylaşılmadan önce şifrelenir. Parola ve günlük cihazlarında kalır; Mystic bunları okuyamaz, kurtaramaz veya sıfırlayamaz.',
              es: 'Los códigos nuevos se cifran antes de compartirlos. La frase y el diario permanecen en tus dispositivos; Mystic no puede leerlos, recuperarlos ni restablecerlos.',
              fr: 'Les nouveaux codes sont chiffrés avant le partage. La phrase et le journal restent sur vos appareils ; Mystic ne peut ni les lire, ni les récupérer, ni les réinitialiser.',
              pt: 'Novos códigos são criptografados antes do compartilhamento. A frase e o diário ficam nos seus aparelhos; o Mystic não pode lê-los, recuperá-los ou redefini-los.',
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
  ) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _copy(
                  en: 'Verified transfer',
                  tr: 'Doğrulanmış taşıma',
                  es: 'Transferencia verificada',
                  fr: 'Transfert vérifié',
                  pt: 'Transferência verificada',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (preview.wasProtected)
              const Icon(Icons.lock, color: MysticColors.gold),
          ],
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
          icon: preview.totalChanges == 0 ? Icons.done_all : Icons.merge_type,
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
  }) => Container(
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

  void _resetMessages() {
    if (!mounted) return;
    setState(() {
      _preview = null;
      _error = null;
      _success = null;
    });
  }

  Future<void> _shareCode() async {
    final passphrase = _createPassphraseController.text;
    if (passphrase.length < JournalTransferProtection.minimumPassphraseLength) {
      setState(
        () => _error = _copy(
          en: 'Use at least ${JournalTransferProtection.minimumPassphraseLength} characters for the passphrase.',
          tr: 'Parola için en az ${JournalTransferProtection.minimumPassphraseLength} karakter kullan.',
          es: 'Usa al menos ${JournalTransferProtection.minimumPassphraseLength} caracteres.',
          fr: 'Utilisez au moins ${JournalTransferProtection.minimumPassphraseLength} caractères.',
          pt: 'Use pelo menos ${JournalTransferProtection.minimumPassphraseLength} caracteres.',
        ),
      );
      return;
    }
    if (passphrase != _confirmPassphraseController.text) {
      setState(
        () => _error = _copy(
          en: 'The passphrases do not match.',
          tr: 'Parolalar eşleşmiyor.',
          es: 'Las frases no coinciden.',
          fr: 'Les phrases ne correspondent pas.',
          pt: 'As frases não coincidem.',
        ),
      );
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _success = null;
    });
    String? code;
    try {
      code = await _service.createCode(widget.records, passphrase: passphrase);
      if (!mounted) return;
      final renderObject = context.findRenderObject();
      final origin = renderObject is RenderBox
          ? renderObject.localToGlobal(Offset.zero) & renderObject.size
          : const Rect.fromLTWH(0, 0, 1, 1);
      final result = await SharePlus.instance.share(
        ShareParams(
          text: code,
          title: _copy(
            en: 'Mystic Tarot protected journal transfer',
            tr: 'Mystic Tarot korumalı günlük taşıması',
            es: 'Transferencia protegida de Mystic Tarot',
            fr: 'Transfert protégé Mystic Tarot',
            pt: 'Transferência protegida Mystic Tarot',
          ),
          sharePositionOrigin: origin,
        ),
      );
      if (!mounted || result.status == ShareResultStatus.dismissed) return;
      if (result.status == ShareResultStatus.success) {
        _clearCreatePassphrases();
        setState(
          () => _success = _copy(
            en: 'Your protected transfer code was shared.',
            tr: 'Korumalı taşıma kodun paylaşıldı.',
            es: 'Tu código protegido se compartió.',
            fr: 'Votre code protégé a été partagé.',
            pt: 'Seu código protegido foi compartilhado.',
          ),
        );
        return;
      }
      await _copyCodeFallback(code);
    } catch (_) {
      if (!mounted) return;
      if (code != null) {
        await _copyCodeFallback(code);
      } else {
        setState(
          () => _error = _copy(
            en: 'The protected transfer code could not be created.',
            tr: 'Korumalı taşıma kodu oluşturulamadı.',
            es: 'No se pudo crear el código protegido.',
            fr: 'Impossible de créer le code protégé.',
            pt: 'Não foi possível criar o código protegido.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyCodeFallback(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    _clearCreatePassphrases();
    setState(
      () => _success = _copy(
        en: 'Sharing was unavailable. The protected code was copied instead.',
        tr: 'Paylaşım kullanılamadı. Korumalı kod bunun yerine kopyalandı.',
        es: 'No se pudo compartir. El código protegido se copió.',
        fr: 'Le partage était indisponible. Le code protégé a été copié.',
        pt: 'O compartilhamento não estava disponível. O código protegido foi copiado.',
      ),
    );
  }

  void _clearCreatePassphrases() {
    _createPassphraseController.clear();
    _confirmPassphraseController.clear();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      setState(
        () => _error = _copy(
          en: 'The clipboard does not contain a transfer code.',
          tr: 'Panoda bir taşıma kodu yok.',
          es: 'El portapapeles no contiene un código.',
          fr: 'Le presse-papiers ne contient aucun code.',
          pt: 'A área de transferência não contém um código.',
        ),
      );
      return;
    }
    _codeController.text = text;
    _resetMessages();
  }

  Future<void> _validate() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(
        () => _error = _copy(
          en: 'Paste a transfer code first.',
          tr: 'Önce bir taşıma kodu yapıştır.',
          es: 'Pega primero un código.',
          fr: 'Collez d’abord un code.',
          pt: 'Cole um código primeiro.',
        ),
      );
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
        passphrase: _restorePassphraseController.text,
      );
      if (!mounted) return;
      setState(() => _preview = preview);
    } on JournalTransferProtectionRequired {
      if (!mounted) return;
      setState(
        () => _error = _copy(
          en: 'Enter the passphrase for this protected code.',
          tr: 'Bu korumalı kodun parolasını gir.',
          es: 'Escribe la frase de este código protegido.',
          fr: 'Saisissez la phrase de ce code protégé.',
          pt: 'Digite a frase deste código protegido.',
        ),
      );
    } on JournalTransferUnlockFailed {
      if (!mounted) return;
      setState(
        () => _error = _copy(
          en: 'The passphrase is incorrect or the protected code is damaged. Nothing was changed.',
          tr: 'Parola yanlış veya korumalı kod bozuk. Hiçbir şey değiştirilmedi.',
          es: 'La frase es incorrecta o el código está dañado. No se cambió nada.',
          fr: 'La phrase est incorrecte ou le code est endommagé. Rien n’a été modifié.',
          pt: 'A frase está incorreta ou o código está danificado. Nada foi alterado.',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = _copy(
          en: 'This is not a valid or supported Mystic Tarot transfer code. Nothing was changed.',
          tr: 'Bu geçerli veya desteklenen bir Mystic Tarot taşıma kodu değil. Hiçbir şey değiştirilmedi.',
          es: 'No es un código válido o compatible. No se cambió nada.',
          fr: 'Ce code Mystic Tarot est invalide ou non pris en charge. Rien n’a été modifié.',
          pt: 'Este código não é válido ou compatível. Nada foi alterado.',
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmAndCommit() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          _copy(
            en: 'Merge private history?',
            tr: 'Özel geçmiş birleştirilsin mi?',
            es: '¿Combinar el historial privado?',
            fr: 'Fusionner l’historique privé ?',
            pt: 'Mesclar o histórico privado?',
          ),
        ),
        content: Text(
          _copy(
            en: 'Mystic will preserve current readings, add missing history, and keep a rollback snapshot while saving. Purchases and account settings are not included.',
            tr: 'Mystic mevcut okumaları koruyacak, eksik geçmişi ekleyecek ve kaydederken geri dönüş anlık görüntüsü tutacak. Satın alımlar ve hesap ayarları dahil değildir.',
            es: 'Mystic conservará las lecturas, añadirá el historial faltante y guardará una copia de reversión. Las compras y ajustes de cuenta no están incluidos.',
            fr: 'Mystic conservera les tirages, ajoutera l’historique manquant et gardera un instantané de retour. Les achats et réglages de compte ne sont pas inclus.',
            pt: 'O Mystic preservará as leituras, adicionará o histórico ausente e manterá um instantâneo de reversão. Compras e configurações da conta não estão incluídas.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              _copy(
                en: 'Cancel',
                tr: 'Vazgeç',
                es: 'Cancelar',
                fr: 'Annuler',
                pt: 'Cancelar',
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              _copy(
                en: 'Merge',
                tr: 'Birleştir',
                es: 'Combinar',
                fr: 'Fusionner',
                pt: 'Mesclar',
              ),
            ),
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
        code: _codeController.text.trim(),
        currentRecords: widget.records,
        passphrase: _restorePassphraseController.text,
      );
      widget.onRestored(result.mergedRecords);
      if (!mounted) return;
      _restorePassphraseController.clear();
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
      setState(
        () => _error = _copy(
          en: 'The restore could not be committed. Your previous local data was kept.',
          tr: 'Geri yükleme kaydedilemedi. Önceki yerel verilerin korundu.',
          es: 'No se pudo guardar la restauración. Tus datos locales anteriores se conservaron.',
          fr: 'La restauration n’a pas pu être enregistrée. Vos données locales précédentes ont été conservées.',
          pt: 'A restauração não pôde ser salva. Seus dados locais anteriores foram preservados.',
        ),
      );
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
  }) => switch (widget.language) {
    MysticLanguage.turkish => tr,
    MysticLanguage.spanish => es,
    MysticLanguage.french => fr,
    MysticLanguage.portugueseBrazil => pt,
    _ => en,
  };
}
