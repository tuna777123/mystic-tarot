import 'package:flutter/material.dart';

import 'app_language.dart';
import 'flagship.dart';
import 'language_bridge.dart';
import 'ritual_reminder.dart';
import 'ritual_reminder_service.dart';
import 'theme.dart';
import 'widgets.dart';

class RitualReminderChoice {
  const RitualReminderChoice({required this.time});

  final TimeOfDay time;
}

Future<RitualReminderChoice?> showRitualReminderOfferSheet({
  required BuildContext context,
  required MysticLanguage language,
  DateTime? now,
}) async {
  final suggestion = suggestedRitualTime(now ?? DateTime.now());
  final suggestedTime = TimeOfDay(
    hour: suggestion.hour,
    minute: suggestion.minute,
  );
  return showModalBottomSheet<RitualReminderChoice>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF171128),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        16,
        22,
        22 + MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 66,
            height: 66,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MysticColors.gold.withValues(alpha: .1),
              border: Border.all(
                color: MysticColors.gold.withValues(alpha: .45),
              ),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              size: 31,
              color: MysticColors.gold,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _copy(
              language,
              en: 'Keep this ritual yours',
              tr: 'Bu ritüeli kendine ayır',
              es: 'Haz que este ritual sea tuyo',
              fr: 'Gardez ce rituel pour vous',
              pt: 'Mantenha este ritual só seu',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(sheetContext).textTheme.headlineSmall,
          ),
          const SizedBox(height: 9),
          Text(
            _copy(
              language,
              en: 'Choose one gentle daily reminder. Mystic will not send marketing notifications.',
              tr: 'Günde tek ve nazik bir hatırlatıcı seç. Mystic pazarlama bildirimi göndermez.',
              es: 'Elige un recordatorio diario y discreto. Mystic no enviará notificaciones de marketing.',
              fr: 'Choisissez un rappel quotidien discret. Mystic n’enverra aucune notification marketing.',
              pt: 'Escolha um lembrete diário e gentil. O Mystic não enviará notificações de marketing.',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(sheetContext).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          GoldButton(
            label: _copy(
              language,
              en: 'Remind me at ${suggestedTime.format(sheetContext)}',
              tr: '${suggestedTime.format(sheetContext)} saatinde hatırlat',
              es: 'Recordarme a las ${suggestedTime.format(sheetContext)}',
              fr: 'Me rappeler à ${suggestedTime.format(sheetContext)}',
              pt: 'Lembrar às ${suggestedTime.format(sheetContext)}',
            ),
            icon: Icons.schedule,
            onPressed: () => Navigator.pop(
              sheetContext,
              RitualReminderChoice(time: suggestedTime),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final selected = await showTimePicker(
                  context: sheetContext,
                  initialTime: suggestedTime,
                  helpText: _copy(
                    language,
                    en: 'Daily ritual time',
                    tr: 'Günlük ritüel saati',
                    es: 'Hora del ritual diario',
                    fr: 'Heure du rituel quotidien',
                    pt: 'Horário do ritual diário',
                  ),
                );
                if (selected != null && sheetContext.mounted) {
                  Navigator.pop(
                    sheetContext,
                    RitualReminderChoice(time: selected),
                  );
                }
              },
              icon: const Icon(Icons.edit_calendar_outlined),
              label: Text(
                _copy(
                  language,
                  en: 'Choose another time',
                  tr: 'Başka bir saat seç',
                  es: 'Elegir otra hora',
                  fr: 'Choisir une autre heure',
                  pt: 'Escolher outro horário',
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(sheetContext),
            child: Text(
              _copy(
                language,
                en: 'Not now',
                tr: 'Şimdi değil',
                es: 'Ahora no',
                fr: 'Pas maintenant',
                pt: 'Agora não',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class RitualReminderSettingsPanel extends StatefulWidget {
  const RitualReminderSettingsPanel({required this.language, super.key});

  final MysticLanguage language;

  @override
  State<RitualReminderSettingsPanel> createState() =>
      _RitualReminderSettingsPanelState();
}

class _RitualReminderSettingsPanelState
    extends State<RitualReminderSettingsPanel> {
  final _store = RitualReminderStore();
  final _service = RitualReminderService.instance;
  RitualReminderSettings settings = const RitualReminderSettings.defaults();
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await _store.load();
    if (!mounted) return;
    setState(() {
      settings = loaded;
      loading = false;
    });
  }

  Future<void> _setEnabled(bool enabled) async {
    if (saving) return;
    setState(() => saving = true);
    if (!enabled) {
      await _service.cancel();
      final updated = settings.copyWith(
        enabled: false,
        promptCompleted: true,
        languageCode: widget.language.code,
      );
      await _store.save(updated);
      if (mounted) setState(() => settings = updated);
      if (mounted) setState(() => saving = false);
      return;
    }

    final permission = await _service.requestPermission();
    if (!mounted) return;
    if (permission != RitualReminderPermissionResult.granted) {
      setState(() => saving = false);
      _showStatus(permission);
      return;
    }
    final updated = settings.copyWith(
      enabled: true,
      promptCompleted: true,
      languageCode: widget.language.code,
    );
    final scheduled = await _service.scheduleDaily(
      settings: updated,
      language: widget.language,
    );
    if (!scheduled) {
      if (mounted) {
        setState(() => saving = false);
        _showStatus(RitualReminderPermissionResult.failed);
      }
      return;
    }
    await _store.save(updated);
    if (!mounted) return;
    setState(() {
      settings = updated;
      saving = false;
    });
  }

  Future<void> _chooseTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
      helpText: _copy(
        widget.language,
        en: 'Daily ritual time',
        tr: 'Günlük ritüel saati',
        es: 'Hora del ritual diario',
        fr: 'Heure du rituel quotidien',
        pt: 'Horário do ritual diário',
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => saving = true);
    var updated = settings.copyWith(
      hour: selected.hour,
      minute: selected.minute,
      promptCompleted: true,
      languageCode: widget.language.code,
    );
    if (updated.enabled) {
      final scheduled = await _service.scheduleDaily(
        settings: updated,
        language: widget.language,
      );
      if (!scheduled) updated = updated.copyWith(enabled: false);
    }
    await _store.save(updated);
    if (!mounted) return;
    setState(() {
      settings = updated;
      saving = false;
    });
  }

  void _showStatus(RitualReminderPermissionResult result) {
    final message = switch (result) {
      RitualReminderPermissionResult.denied => _copy(
        widget.language,
        en: 'Notifications are off. You can allow them later in device settings.',
        tr: 'Bildirimler kapalı. Daha sonra cihaz ayarlarından izin verebilirsin.',
        es: 'Las notificaciones están desactivadas. Puedes permitirlas más tarde en los ajustes del dispositivo.',
        fr: 'Les notifications sont désactivées. Vous pourrez les autoriser plus tard dans les réglages de l’appareil.',
        pt: 'As notificações estão desativadas. Você pode permiti-las depois nos ajustes do dispositivo.',
      ),
      RitualReminderPermissionResult.unsupported => _copy(
        widget.language,
        en: 'Daily reminders are available in the iOS and Android apps.',
        tr: 'Günlük hatırlatıcılar iOS ve Android uygulamalarında kullanılabilir.',
        es: 'Los recordatorios diarios están disponibles en las apps de iOS y Android.',
        fr: 'Les rappels quotidiens sont disponibles dans les apps iOS et Android.',
        pt: 'Os lembretes diários estão disponíveis nos apps para iOS e Android.',
      ),
      _ => _copy(
        widget.language,
        en: 'Mystic could not schedule the reminder. Your other data is safe.',
        tr: 'Mystic hatırlatıcıyı planlayamadı. Diğer verilerin güvende.',
        es: 'Mystic no pudo programar el recordatorio. Tus demás datos están seguros.',
        fr: 'Mystic n’a pas pu programmer le rappel. Vos autres données sont en sécurité.',
        pt: 'O Mystic não conseguiu agendar o lembrete. Seus outros dados estão seguros.',
      ),
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: CircularProgressIndicator(),
        ),
      );
    }
    final supported = _service.isSupported;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _copy(
            widget.language,
            en: 'A ritual, not a notification feed',
            tr: 'Bildirim akışı değil, bir ritüel',
            es: 'Un ritual, no un flujo de notificaciones',
            fr: 'Un rituel, pas un flux de notifications',
            pt: 'Um ritual, não um fluxo de notificações',
          ),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          _copy(
            widget.language,
            en: 'Mystic schedules one private local reminder at the time you choose. No journal text is included or uploaded.',
            tr: 'Mystic seçtiğin saatte tek bir özel yerel hatırlatıcı planlar. Günlük metnin bildirime eklenmez veya yüklenmez.',
            es: 'Mystic programa un único recordatorio local y privado a la hora que elijas. No incluye ni sube texto de tu diario.',
            fr: 'Mystic programme un seul rappel local et privé à l’heure choisie. Aucun texte du journal n’est inclus ni envoyé.',
            pt: 'O Mystic agenda um único lembrete local e privado no horário escolhido. Nenhum texto do diário é incluído ou enviado.',
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: supported && settings.enabled,
          onChanged: supported && !saving ? _setEnabled : null,
          activeThumbColor: MysticColors.gold,
          title: Text(
            _copy(
              widget.language,
              en: 'Daily ritual reminder',
              tr: 'Günlük ritüel hatırlatıcısı',
              es: 'Recordatorio del ritual diario',
              fr: 'Rappel du rituel quotidien',
              pt: 'Lembrete do ritual diário',
            ),
          ),
          subtitle: Text(
            supported
                ? settings.enabled
                      ? _copy(
                          widget.language,
                          en: 'Active every day at ${settings.formattedTime}',
                          tr: 'Her gün ${settings.formattedTime} saatinde etkin',
                          es: 'Activo cada día a las ${settings.formattedTime}',
                          fr: 'Actif chaque jour à ${settings.formattedTime}',
                          pt: 'Ativo todos os dias às ${settings.formattedTime}',
                        )
                      : _copy(
                          widget.language,
                          en: 'Off until you choose to enable it',
                          tr: 'Sen açana kadar kapalı',
                          es: 'Desactivado hasta que decidas activarlo',
                          fr: 'Désactivé jusqu’à ce que vous l’activiez',
                          pt: 'Desativado até você decidir ativar',
                        )
                : _copy(
                    widget.language,
                    en: 'Available in the iOS and Android apps',
                    tr: 'iOS ve Android uygulamalarında kullanılabilir',
                    es: 'Disponible en las apps de iOS y Android',
                    fr: 'Disponible dans les apps iOS et Android',
                    pt: 'Disponível nos apps para iOS e Android',
                  ),
          ),
        ),
        const Divider(),
        ListTile(
          enabled: supported && !saving,
          contentPadding: EdgeInsets.zero,
          onTap: _chooseTime,
          leading: const Icon(Icons.schedule, color: MysticColors.gold),
          title: Text(
            _copy(
              widget.language,
              en: 'Reminder time',
              tr: 'Hatırlatma saati',
              es: 'Hora del recordatorio',
              fr: 'Heure du rappel',
              pt: 'Horário do lembrete',
            ),
          ),
          subtitle: Text(settings.formattedTime),
          trailing: const Icon(Icons.chevron_right),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MysticColors.gold.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: MysticColors.gold.withValues(alpha: .2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline, color: MysticColors.gold),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  _copy(
                    widget.language,
                    en: 'Scheduled on this device. No ad profile, tracking identifier, or private reading text is used.',
                    tr: 'Bu cihazda planlanır. Reklam profili, izleme kimliği veya özel okuma metni kullanılmaz.',
                    es: 'Se programa en este dispositivo. No usa perfiles publicitarios, identificadores de seguimiento ni texto privado de lecturas.',
                    fr: 'Programmé sur cet appareil. Aucun profil publicitaire, identifiant de suivi ou texte privé de tirage n’est utilisé.',
                    pt: 'Agendado neste dispositivo. Não usa perfil de anúncios, identificador de rastreamento nem texto privado de leituras.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _copy(
  MysticLanguage language, {
  required String en,
  required String tr,
  required String es,
  required String fr,
  required String pt,
}) => localized(
  language.appLanguage,
  english: en,
  turkish: tr,
  spanish: es,
  french: fr,
  portugueseBrazil: pt,
  italian: en,
  german: en,
);
