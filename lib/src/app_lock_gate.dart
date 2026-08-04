import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_lock.dart';
import 'theme.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({
    required this.child,
    this.service,
    this.authenticator,
    this.promptDelay = const Duration(seconds: 6),
    this.backgroundGrace = const Duration(seconds: 5),
    super.key,
  });

  final Widget child;
  final AppLockService? service;
  final AppLockAuthenticator? authenticator;
  final Duration promptDelay;
  final Duration backgroundGrace;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

enum _AppLockMode { unlocked, locked, setup, manage }

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  late final AppLockService _service = widget.service ?? AppLockService();
  late final AppLockAuthenticator _authenticator =
      widget.authenticator ?? DeviceAppLockAuthenticator();
  AppLockState? _state;
  _AppLockMode _mode = _AppLockMode.unlocked;
  bool _loading = true;
  bool _biometricAvailable = false;
  bool _showPrompt = false;
  bool _authenticating = false;
  DateTime? _backgroundedAt;
  Timer? _promptTimer;

  String get _languageCode =>
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _promptTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final state = await _service.loadState();
      final biometrics = await _authenticator.isAvailable();
      if (!mounted) return;
      setState(() {
        _state = state;
        _biometricAvailable = biometrics;
        _mode = state.enabled ? _AppLockMode.locked : _AppLockMode.unlocked;
        _loading = false;
      });
      if (state.enabled && state.biometricsEnabled && biometrics) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _useBiometrics());
      } else if (!state.enabled && !state.promptDismissed) {
        _promptTimer = Timer(widget.promptDelay, () {
          if (mounted && _mode == _AppLockMode.unlocked) {
            setState(() => _showPrompt = true);
          }
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = const AppLockState(
          enabled: false,
          biometricsEnabled: false,
          failedAttempts: 0,
          lockedUntil: null,
          promptDismissed: true,
        );
        _mode = _AppLockMode.unlocked;
        _loading = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!(_state?.enabled ?? false)) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt ??= DateTime.now();
      return;
    }
    if (state != AppLifecycleState.resumed) return;
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (_authenticating || backgroundedAt == null) return;
    if (DateTime.now().difference(backgroundedAt) < widget.backgroundGrace) {
      return;
    }
    if (_mode == _AppLockMode.unlocked) {
      setState(() => _mode = _AppLockMode.locked);
      if ((_state?.biometricsEnabled ?? false) && _biometricAvailable) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _useBiometrics());
      }
    }
  }

  Future<void> _dismissPrompt() async {
    await _service.dismissPrompt();
    final state = await _service.loadState();
    if (!mounted) return;
    setState(() {
      _state = state;
      _showPrompt = false;
    });
  }

  Future<void> _completeSetup(String pin, bool biometrics) async {
    await _service.enableWithPin(pin);
    await _service.setBiometricsEnabled(
      biometrics && _biometricAvailable,
    );
    final state = await _service.loadState();
    if (!mounted) return;
    setState(() {
      _state = state;
      _showPrompt = false;
      _mode = _AppLockMode.unlocked;
    });
  }

  Future<bool> _verifyPin(String pin) async {
    try {
      return await _service.verifyPin(pin);
    } finally {
      final state = await _service.loadState();
      if (mounted) setState(() => _state = state);
    }
  }

  Future<void> _unlock() async {
    final state = await _service.loadState();
    if (!mounted) return;
    setState(() {
      _state = state;
      _mode = _AppLockMode.unlocked;
    });
  }

  Future<void> _useBiometrics() async {
    if (_authenticating || !_biometricAvailable) return;
    setState(() => _authenticating = true);
    final authenticated = await _authenticator.authenticate(
      appLockCopy(
        _languageCode,
        en: 'Unlock your private Mystic Tarot journal',
        tr: 'Özel Mystic Tarot günlüğünün kilidini aç',
        es: 'Desbloquea tu diario privado de Mystic Tarot',
        fr: 'Déverrouillez votre journal privé Mystic Tarot',
        pt: 'Desbloqueie seu diário privado do Mystic Tarot',
      ),
    );
    if (!mounted) return;
    setState(() => _authenticating = false);
    if (!authenticated) return;
    await _service.markTrustedUnlock();
    await _unlock();
  }

  Future<void> _changePin(String pin) async {
    final biometrics = _state?.biometricsEnabled ?? false;
    await _service.enableWithPin(pin);
    await _service.setBiometricsEnabled(
      biometrics && _biometricAvailable,
    );
    final state = await _service.loadState();
    if (mounted) setState(() => _state = state);
  }

  Future<void> _setBiometrics(bool enabled) async {
    await _service.setBiometricsEnabled(enabled && _biometricAvailable);
    final state = await _service.loadState();
    if (mounted) setState(() => _state = state);
  }

  Future<void> _disableLock() async {
    await _service.disable();
    final state = await _service.loadState();
    if (!mounted) return;
    setState(() {
      _state = state;
      _mode = _AppLockMode.unlocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _standalone(const _PrivateLoadingScreen());
    if (_mode == _AppLockMode.locked) {
      return _standalone(
        _UnlockScreen(
          languageCode: _languageCode,
          state: _state!,
          biometricsAvailable: _biometricAvailable,
          authenticating: _authenticating,
          onVerifyPin: _verifyPin,
          onUnlock: _unlock,
          onBiometrics: _useBiometrics,
          onManage: () => setState(() => _mode = _AppLockMode.manage),
        ),
      );
    }
    if (_mode == _AppLockMode.setup) {
      return _standalone(
        _SetupScreen(
          languageCode: _languageCode,
          biometricsAvailable: _biometricAvailable,
          onCancel: () => setState(() => _mode = _AppLockMode.unlocked),
          onComplete: _completeSetup,
        ),
      );
    }
    if (_mode == _AppLockMode.manage) {
      return _standalone(
        _ManageScreen(
          languageCode: _languageCode,
          state: _state!,
          biometricsAvailable: _biometricAvailable,
          onChangePin: _changePin,
          onBiometricsChanged: _setBiometrics,
          onDisable: _disableLock,
          onUnlock: _unlock,
          onReturnLocked: () => setState(() => _mode = _AppLockMode.locked),
        ),
      );
    }
    return _unlockedLayer(context);
  }

  Widget _unlockedLayer(BuildContext context) {
    final bottomInset = MediaQueryData.fromView(View.of(context)).padding.bottom;
    final lockEnabled = _state?.enabled ?? false;
    final actionLabel = lockEnabled
        ? appLockCopy(
            _languageCode,
            en: 'Lock now',
            tr: 'Şimdi kilitle',
            es: 'Bloquear ahora',
            fr: 'Verrouiller maintenant',
            pt: 'Bloquear agora',
          )
        : appLockCopy(
            _languageCode,
            en: 'Set private lock',
            tr: 'Özel kilit kur',
            es: 'Configurar bloqueo privado',
            fr: 'Configurer le verrou privé',
            pt: 'Configurar bloqueio privado',
          );
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (_showPrompt)
          Positioned(
            left: 14,
            right: 14,
            bottom: bottomInset + 14,
            child: _overlayMaterial(
              _PrivacyPrompt(
                languageCode: _languageCode,
                onLater: _dismissPrompt,
                onEnable: () => setState(() {
                  _showPrompt = false;
                  _mode = _AppLockMode.setup;
                }),
              ),
            ),
          )
        else
          Positioned(
            right: 12,
            bottom: bottomInset + 88,
            child: _overlayMaterial(
              Semantics(
                label: actionLabel,
                button: true,
                child: IconButton.filledTonal(
                  onPressed: () => setState(() {
                    _mode = lockEnabled
                        ? _AppLockMode.locked
                        : _AppLockMode.setup;
                  }),
                  icon: Icon(
                    lockEnabled ? Icons.lock_outline : Icons.shield_outlined,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _overlayMaterial(Widget child) => Theme(
        data: buildMysticTheme(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(color: Colors.transparent, child: child),
        ),
      );

  Widget _standalone(Widget home) => MaterialApp(
        title: 'Mystic Tarot',
        debugShowCheckedModeBanner: false,
        theme: buildMysticTheme(),
        home: home,
      );
}

class _PrivateLoadingScreen extends StatelessWidget {
  const _PrivateLoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFF080711),
        body: Center(
          child: CircularProgressIndicator(color: MysticColors.gold),
        ),
      );
}

class _PrivacyPrompt extends StatelessWidget {
  const _PrivacyPrompt({
    required this.languageCode,
    required this.onLater,
    required this.onEnable,
  });

  final String languageCode;
  final VoidCallback onLater;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF32204D), Color(0xFF171023)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .42)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: MysticColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    appLockCopy(
                      languageCode,
                      en: 'Protect your private journal',
                      tr: 'Özel günlüğünü koru',
                      es: 'Protege tu diario privado',
                      fr: 'Protégez votre journal privé',
                      pt: 'Proteja seu diário privado',
                    ),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appLockCopy(
                languageCode,
                en: 'Add a six-digit PIN and optional biometrics. The PIN never leaves this device.',
                tr: 'Altı haneli PIN ve isteğe bağlı biyometri ekle. PIN bu cihazdan asla çıkmaz.',
                es: 'Añade un PIN de seis dígitos y biometría opcional. El PIN nunca sale del dispositivo.',
                fr: 'Ajoutez un code à six chiffres et la biométrie facultative. Le code ne quitte jamais cet appareil.',
                pt: 'Adicione um PIN de seis dígitos e biometria opcional. O PIN nunca sai do dispositivo.',
              ),
              style: const TextStyle(color: MysticColors.mist, height: 1.4),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onLater,
                  child: Text(appLockCopy(
                    languageCode,
                    en: 'Not now',
                    tr: 'Şimdi değil',
                    es: 'Ahora no',
                    fr: 'Pas maintenant',
                    pt: 'Agora não',
                  )),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onEnable,
                  icon: const Icon(Icons.lock_outline),
                  label: Text(appLockCopy(
                    languageCode,
                    en: 'Enable lock',
                    tr: 'Kilidi etkinleştir',
                    es: 'Activar bloqueo',
                    fr: 'Activer le verrou',
                    pt: 'Ativar bloqueio',
                  )),
                ),
              ],
            ),
          ],
        ),
      );
}

class _SetupScreen extends StatefulWidget {
  const _SetupScreen({
    required this.languageCode,
    required this.biometricsAvailable,
    required this.onCancel,
    required this.onComplete,
  });

  final String languageCode;
  final bool biometricsAvailable;
  final VoidCallback onCancel;
  final Future<void> Function(String pin, bool biometrics) onComplete;

  @override
  State<_SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<_SetupScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _biometrics = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!RegExp(r'^\d{6}$').hasMatch(_pin.text)) {
      setState(() => _error = appLockCopy(
            widget.languageCode,
            en: 'Use exactly six digits.',
            tr: 'Tam olarak altı rakam kullan.',
            es: 'Usa exactamente seis dígitos.',
            fr: 'Utilisez exactement six chiffres.',
            pt: 'Use exatamente seis dígitos.',
          ));
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(() => _error = appLockCopy(
            widget.languageCode,
            en: 'The PINs do not match.',
            tr: 'PIN’ler eşleşmiyor.',
            es: 'Los PIN no coinciden.',
            fr: 'Les codes ne correspondent pas.',
            pt: 'Os PINs não coincidem.',
          ));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onComplete(
        _pin.text,
        widget.biometricsAvailable && _biometrics,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = appLockCopy(
              widget.languageCode,
              en: 'The private lock could not be saved.',
              tr: 'Özel kilit kaydedilemedi.',
              es: 'No se pudo guardar el bloqueo privado.',
              fr: 'Le verrou privé n’a pas pu être enregistré.',
              pt: 'O bloqueio privado não pôde ser salvo.',
            ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _LockShell(
        title: appLockCopy(
          widget.languageCode,
          en: 'Create private lock',
          tr: 'Özel kilit oluştur',
          es: 'Crear bloqueo privado',
          fr: 'Créer un verrou privé',
          pt: 'Criar bloqueio privado',
        ),
        leading: IconButton(
          onPressed: _busy ? null : widget.onCancel,
          icon: const Icon(Icons.close),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          children: [
            const _LockHero(icon: Icons.shield_moon_outlined),
            const SizedBox(height: 20),
            Text(
              appLockCopy(
                widget.languageCode,
                en: 'Choose a six-digit PIN',
                tr: 'Altı haneli PIN seç',
                es: 'Elige un PIN de seis dígitos',
                fr: 'Choisissez un code à six chiffres',
                pt: 'Escolha um PIN de seis dígitos',
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              appLockCopy(
                widget.languageCode,
                en: 'Mystic stores only an encrypted verifier. There is no cloud reset or hidden recovery key.',
                tr: 'Mystic yalnızca şifreli bir doğrulayıcı saklar. Bulut sıfırlaması veya gizli kurtarma anahtarı yoktur.',
                es: 'Mystic solo guarda un verificador cifrado. No existe restablecimiento en la nube ni clave oculta.',
                fr: 'Mystic ne conserve qu’un vérificateur chiffré. Il n’existe ni réinitialisation cloud ni clé cachée.',
                pt: 'O Mystic guarda apenas um verificador criptografado. Não há redefinição na nuvem nem chave oculta.',
              ),
              style: const TextStyle(color: MysticColors.mist, height: 1.45),
            ),
            const SizedBox(height: 20),
            _PinField(controller: _pin, label: 'PIN'),
            const SizedBox(height: 12),
            _PinField(
              controller: _confirm,
              label: appLockCopy(
                widget.languageCode,
                en: 'Confirm PIN',
                tr: 'PIN’i doğrula',
                es: 'Confirmar PIN',
                fr: 'Confirmer le code',
                pt: 'Confirmar PIN',
              ),
            ),
            if (widget.biometricsAvailable) ...[
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                value: _biometrics,
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _biometrics = value),
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(
                  Icons.fingerprint,
                  color: MysticColors.gold,
                ),
                title: Text(appLockCopy(
                  widget.languageCode,
                  en: 'Use biometrics',
                  tr: 'Biyometri kullan',
                  es: 'Usar biometría',
                  fr: 'Utiliser la biométrie',
                  pt: 'Usar biometria',
                )),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFFF8796)),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_outline),
              label: Text(appLockCopy(
                widget.languageCode,
                en: 'Protect journal',
                tr: 'Günlüğü koru',
                es: 'Proteger diario',
                fr: 'Protéger le journal',
                pt: 'Proteger diário',
              )),
            ),
          ],
        ),
      );
}

class _UnlockScreen extends StatefulWidget {
  const _UnlockScreen({
    required this.languageCode,
    required this.state,
    required this.biometricsAvailable,
    required this.authenticating,
    required this.onVerifyPin,
    required this.onUnlock,
    required this.onBiometrics,
    required this.onManage,
  });

  final String languageCode;
  final AppLockState state;
  final bool biometricsAvailable;
  final bool authenticating;
  final Future<bool> Function(String pin) onVerifyPin;
  final Future<void> Function() onUnlock;
  final Future<void> Function() onBiometrics;
  final VoidCallback onManage;

  @override
  State<_UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<_UnlockScreen> {
  final _pin = TextEditingController();
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _remaining = widget.state.remainingLockout(DateTime.now().toUtc());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _syncLockout());
  }

  @override
  void didUpdateWidget(covariant _UnlockScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncLockout();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pin.dispose();
    super.dispose();
  }

  void _syncLockout() {
    final remaining = widget.state.remainingLockout(DateTime.now().toUtc());
    if (mounted && remaining != _remaining) {
      setState(() => _remaining = remaining);
    }
  }

  Future<void> _submit({bool manage = false}) async {
    if (_remaining > Duration.zero) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final valid = await widget.onVerifyPin(_pin.text);
      if (!mounted) return;
      if (!valid) {
        setState(() => _error = appLockCopy(
              widget.languageCode,
              en: 'Incorrect PIN.',
              tr: 'PIN yanlış.',
              es: 'PIN incorrecto.',
              fr: 'Code incorrect.',
              pt: 'PIN incorreto.',
            ));
        return;
      }
      _pin.clear();
      if (manage) {
        widget.onManage();
      } else {
        await widget.onUnlock();
      }
    } on AppLockTemporarilyUnavailable catch (error) {
      if (mounted) setState(() => _remaining = error.remaining);
    } on ArgumentError {
      if (mounted) {
        setState(() => _error = appLockCopy(
              widget.languageCode,
              en: 'Enter your six-digit PIN.',
              tr: 'Altı haneli PIN’ini gir.',
              es: 'Introduce tu PIN de seis dígitos.',
              fr: 'Saisissez votre code à six chiffres.',
              pt: 'Digite seu PIN de seis dígitos.',
            ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _LockShell(
        title: appLockCopy(
          widget.languageCode,
          en: 'Private journal locked',
          tr: 'Özel günlük kilitli',
          es: 'Diario privado bloqueado',
          fr: 'Journal privé verrouillé',
          pt: 'Diário privado bloqueado',
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 36),
          children: [
            const _LockHero(icon: Icons.lock_person_outlined),
            const SizedBox(height: 24),
            Text(
              appLockCopy(
                widget.languageCode,
                en: 'Your readings, Mirror reflections, and Oracle memory stay hidden until you unlock.',
                tr: 'Okumaların, Mirror yansımaların ve Oracle hafızan kilidi açana kadar gizli kalır.',
                es: 'Tus lecturas, reflexiones Mirror y memoria Oracle permanecen ocultas hasta desbloquear.',
                fr: 'Vos tirages, réflexions Mirror et mémoire Oracle restent masqués jusqu’au déverrouillage.',
                pt: 'Suas leituras, reflexões Mirror e memória Oracle ficam ocultas até o desbloqueio.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: MysticColors.mist, height: 1.45),
            ),
            const SizedBox(height: 24),
            _PinField(
              controller: _pin,
              autofocus: !(widget.state.biometricsEnabled &&
                  widget.biometricsAvailable),
              label: 'PIN',
              onSubmitted: (_) => _submit(),
            ),
            if (_remaining > Duration.zero) ...[
              const SizedBox(height: 12),
              Text(
                appLockCopy(
                  widget.languageCode,
                  en: 'Try again in ${_remaining.inSeconds + 1} seconds.',
                  tr: '${_remaining.inSeconds + 1} saniye sonra tekrar dene.',
                  es: 'Inténtalo de nuevo en ${_remaining.inSeconds + 1} segundos.',
                  fr: 'Réessayez dans ${_remaining.inSeconds + 1} secondes.',
                  pt: 'Tente novamente em ${_remaining.inSeconds + 1} segundos.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: MysticColors.gold),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFFF8796)),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _busy || _remaining > Duration.zero ? null : _submit,
              icon: const Icon(Icons.lock_open_outlined),
              label: Text(appLockCopy(
                widget.languageCode,
                en: 'Unlock',
                tr: 'Kilidi aç',
                es: 'Desbloquear',
                fr: 'Déverrouiller',
                pt: 'Desbloquear',
              )),
            ),
            if (widget.state.biometricsEnabled &&
                widget.biometricsAvailable) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed:
                    widget.authenticating ? null : widget.onBiometrics,
                icon: const Icon(Icons.fingerprint),
                label: Text(appLockCopy(
                  widget.languageCode,
                  en: 'Use biometrics',
                  tr: 'Biyometri kullan',
                  es: 'Usar biometría',
                  fr: 'Utiliser la biométrie',
                  pt: 'Usar biometria',
                )),
              ),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _busy || _remaining > Duration.zero
                  ? null
                  : () => _submit(manage: true),
              icon: const Icon(Icons.settings_outlined),
              label: Text(appLockCopy(
                widget.languageCode,
                en: 'Manage lock after PIN',
                tr: 'PIN’den sonra kilidi yönet',
                es: 'Gestionar bloqueo tras el PIN',
                fr: 'Gérer le verrou après le code',
                pt: 'Gerenciar bloqueio após o PIN',
              )),
            ),
          ],
        ),
      );
}

class _ManageScreen extends StatefulWidget {
  const _ManageScreen({
    required this.languageCode,
    required this.state,
    required this.biometricsAvailable,
    required this.onChangePin,
    required this.onBiometricsChanged,
    required this.onDisable,
    required this.onUnlock,
    required this.onReturnLocked,
  });

  final String languageCode;
  final AppLockState state;
  final bool biometricsAvailable;
  final Future<void> Function(String pin) onChangePin;
  final Future<void> Function(bool enabled) onBiometricsChanged;
  final Future<void> Function() onDisable;
  final Future<void> Function() onUnlock;
  final VoidCallback onReturnLocked;

  @override
  State<_ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<_ManageScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _changePin() async {
    final first = TextEditingController();
    final second = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appLockCopy(
          widget.languageCode,
          en: 'Change PIN',
          tr: 'PIN’i değiştir',
          es: 'Cambiar PIN',
          fr: 'Changer le code',
          pt: 'Alterar PIN',
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PinField(controller: first, label: 'PIN'),
            const SizedBox(height: 10),
            _PinField(
              controller: second,
              label: appLockCopy(
                widget.languageCode,
                en: 'Confirm',
                tr: 'Doğrula',
                es: 'Confirmar',
                fr: 'Confirmer',
                pt: 'Confirmar',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              if (RegExp(r'^\d{6}$').hasMatch(first.text) &&
                  first.text == second.text) {
                Navigator.pop(dialogContext, first.text);
              }
            },
            child: Text(appLockCopy(
              widget.languageCode,
              en: 'Save',
              tr: 'Kaydet',
              es: 'Guardar',
              fr: 'Enregistrer',
              pt: 'Salvar',
            )),
          ),
        ],
      ),
    );
    first.dispose();
    second.dispose();
    if (pin == null || !mounted) return;
    setState(() => _busy = true);
    await widget.onChangePin(pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = appLockCopy(
        widget.languageCode,
        en: 'PIN changed.',
        tr: 'PIN değiştirildi.',
        es: 'PIN cambiado.',
        fr: 'Code modifié.',
        pt: 'PIN alterado.',
      );
    });
  }

  Future<void> _disable() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appLockCopy(
          widget.languageCode,
          en: 'Disable private lock?',
          tr: 'Özel kilit kapatılsın mı?',
          es: '¿Desactivar el bloqueo privado?',
          fr: 'Désactiver le verrou privé ?',
          pt: 'Desativar o bloqueio privado?',
        )),
        content: Text(appLockCopy(
          widget.languageCode,
          en: 'Anyone holding the unlocked device will be able to open the journal.',
          tr: 'Kilidi açık cihazı elinde tutan herkes günlüğü açabilecek.',
          es: 'Cualquiera que tenga el dispositivo desbloqueado podrá abrir el diario.',
          fr: 'Toute personne tenant l’appareil déverrouillé pourra ouvrir le journal.',
          pt: 'Qualquer pessoa com o dispositivo desbloqueado poderá abrir o diário.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(appLockCopy(
              widget.languageCode,
              en: 'Disable',
              tr: 'Kapat',
              es: 'Desactivar',
              fr: 'Désactiver',
              pt: 'Desativar',
            )),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    await widget.onDisable();
  }

  @override
  Widget build(BuildContext context) => _LockShell(
        title: appLockCopy(
          widget.languageCode,
          en: 'Private lock settings',
          tr: 'Özel kilit ayarları',
          es: 'Ajustes del bloqueo privado',
          fr: 'Réglages du verrou privé',
          pt: 'Configurações do bloqueio privado',
        ),
        leading: IconButton(
          onPressed: _busy ? null : widget.onReturnLocked,
          icon: const Icon(Icons.arrow_back),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          children: [
            const _LockHero(icon: Icons.admin_panel_settings_outlined),
            const SizedBox(height: 22),
            ListTile(
              leading: const Icon(Icons.password, color: MysticColors.gold),
              title: Text(appLockCopy(
                widget.languageCode,
                en: 'Change PIN',
                tr: 'PIN’i değiştir',
                es: 'Cambiar PIN',
                fr: 'Changer le code',
                pt: 'Alterar PIN',
              )),
              trailing: const Icon(Icons.chevron_right),
              onTap: _busy ? null : _changePin,
            ),
            if (widget.biometricsAvailable)
              SwitchListTile.adaptive(
                value: widget.state.biometricsEnabled,
                onChanged: _busy
                    ? null
                    : (value) async {
                        setState(() => _busy = true);
                        await widget.onBiometricsChanged(value);
                        if (mounted) setState(() => _busy = false);
                      },
                secondary: const Icon(
                  Icons.fingerprint,
                  color: MysticColors.gold,
                ),
                title: Text(appLockCopy(
                  widget.languageCode,
                  en: 'Biometric unlock',
                  tr: 'Biyometrik kilit açma',
                  es: 'Desbloqueo biométrico',
                  fr: 'Déverrouillage biométrique',
                  pt: 'Desbloqueio biométrico',
                )),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.no_encryption_outlined,
                color: Color(0xFFFF8796),
              ),
              title: Text(appLockCopy(
                widget.languageCode,
                en: 'Disable private lock',
                tr: 'Özel kilidi kapat',
                es: 'Desactivar bloqueo privado',
                fr: 'Désactiver le verrou privé',
                pt: 'Desativar bloqueio privado',
              )),
              onTap: _busy ? null : _disable,
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MysticColors.gold),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _busy ? null : widget.onUnlock,
              icon: const Icon(Icons.lock_open_outlined),
              label: Text(appLockCopy(
                widget.languageCode,
                en: 'Unlock app',
                tr: 'Uygulamayı aç',
                es: 'Desbloquear aplicación',
                fr: 'Déverrouiller l’application',
                pt: 'Desbloquear aplicativo',
              )),
            ),
          ],
        ),
      );
}

class _LockShell extends StatelessWidget {
  const _LockShell({
    required this.title,
    required this.child,
    this.leading,
  });

  final String title;
  final Widget child;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title), leading: leading),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF171027), Color(0xFF080711)],
            ),
          ),
          child: SafeArea(child: child),
        ),
      );
}

class _LockHero extends StatelessWidget {
  const _LockHero({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 92,
          height: 92,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MysticColors.violet.withValues(alpha: .24),
            border: Border.all(
              color: MysticColors.gold.withValues(alpha: .45),
            ),
            boxShadow: [
              BoxShadow(
                color: MysticColors.violet.withValues(alpha: .24),
                blurRadius: 32,
              ),
            ],
          ),
          child: Icon(icon, size: 43, color: MysticColors.gold),
        ),
      );
}

class _PinField extends StatelessWidget {
  const _PinField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        autofocus: autofocus,
        obscureText: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        maxLength: AppLockService.pinLength,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(AppLockService.pinLength),
        ],
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          counterText: '',
          prefixIcon: const Icon(Icons.password),
        ),
      );
}

String appLockCopy(
  String languageCode, {
  required String en,
  required String tr,
  required String es,
  required String fr,
  required String pt,
}) =>
    switch (languageCode.toLowerCase()) {
      'tr' => tr,
      'es' => es,
      'fr' => fr,
      'pt' => pt,
      _ => en,
    };
