import 'dart:async';

import 'package:flutter/material.dart';

import 'flagship.dart';
import 'theme.dart';

enum DailyPracticeKind { breath, intention, gratitude }

class DailyPracticeDefinition {
  const DailyPracticeDefinition({
    required this.kind,
    required this.icon,
    required this.title,
    required this.body,
  });

  final DailyPracticeKind kind;
  final IconData icon;
  final String title;
  final String body;
}

String dailyPracticeId(DailyPracticeKind kind) => 'daily-${kind.name}';

List<DailyPracticeDefinition> dailyPracticeDefinitions(
  MysticLanguage language,
) => [
  DailyPracticeDefinition(
    kind: DailyPracticeKind.breath,
    icon: Icons.air_rounded,
    title: _copy(
      language,
      en: 'Grounding breath',
      es: 'Respiración de anclaje',
      fr: 'Respiration d’ancrage',
      pt: 'Respiração de aterramento',
      tr: 'Topraklanma nefesi',
    ),
    body: _copy(
      language,
      en: 'Follow two calm breathing cycles for 24 seconds.',
      es: 'Sigue dos ciclos de respiración tranquila durante 24 segundos.',
      fr: 'Suivez deux cycles de respiration calme pendant 24 secondes.',
      pt: 'Siga dois ciclos de respiração calma por 24 segundos.',
      tr: '24 saniye boyunca iki sakin nefes döngüsünü takip et.',
    ),
  ),
  DailyPracticeDefinition(
    kind: DailyPracticeKind.intention,
    icon: Icons.center_focus_strong_rounded,
    title: _copy(
      language,
      en: 'One honest intention',
      es: 'Una intención honesta',
      fr: 'Une intention sincère',
      pt: 'Uma intenção honesta',
      tr: 'Dürüst bir niyet',
    ),
    body: _copy(
      language,
      en: 'Name the smallest action that would honor today’s reading.',
      es: 'Nombra la acción más pequeña que honraría la lectura de hoy.',
      fr: 'Nommez la plus petite action qui respecterait le tirage du jour.',
      pt: 'Dê nome à menor ação que honraria a leitura de hoje.',
      tr: 'Bugünkü okumayı onurlandıracak en küçük eylemi adlandır.',
    ),
  ),
  DailyPracticeDefinition(
    kind: DailyPracticeKind.gratitude,
    icon: Icons.favorite_outline_rounded,
    title: _copy(
      language,
      en: 'Gratitude anchor',
      es: 'Ancla de gratitud',
      fr: 'Ancrage de gratitude',
      pt: 'Âncora de gratidão',
      tr: 'Şükran çapası',
    ),
    body: _copy(
      language,
      en: 'Write one specific thing that is supporting you right now.',
      es: 'Escribe una cosa concreta que te esté apoyando ahora.',
      fr: 'Écrivez une chose précise qui vous soutient en ce moment.',
      pt: 'Escreva uma coisa específica que está apoiando você agora.',
      tr: 'Şu anda seni destekleyen somut bir şeyi yaz.',
    ),
  ),
];

String dailyPracticeCta(MysticLanguage language) => _copy(
  language,
  en: 'Open today’s private ritual',
  es: 'Abrir el ritual privado de hoy',
  fr: 'Ouvrir le rituel privé du jour',
  pt: 'Abrir o ritual privado de hoje',
  tr: 'Bugünün özel ritüelini aç',
);

Future<DailyPracticeKind?> showDailyPracticeSheet({
  required BuildContext context,
  required MysticLanguage language,
}) => showModalBottomSheet<DailyPracticeKind>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: MysticColors.night,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  ),
  builder: (_) => DailyPracticeSheet(language: language),
);

class DailyPracticeSheet extends StatefulWidget {
  const DailyPracticeSheet({required this.language, super.key});

  final MysticLanguage language;

  @override
  State<DailyPracticeSheet> createState() => _DailyPracticeSheetState();
}

class _DailyPracticeSheetState extends State<DailyPracticeSheet> {
  static const _breathSeconds = 24;

  final _note = TextEditingController();
  DailyPracticeKind _selected = DailyPracticeKind.breath;
  Timer? _timer;
  int _remaining = _breathSeconds;
  bool _breathRunning = false;
  bool _breathComplete = false;

  @override
  void dispose() {
    _timer?.cancel();
    _note.dispose();
    super.dispose();
  }

  void _select(DailyPracticeKind kind) {
    if (_selected == kind) return;
    _timer?.cancel();
    setState(() {
      _selected = kind;
      _remaining = _breathSeconds;
      _breathRunning = false;
      _breathComplete = false;
      _note.clear();
    });
  }

  void _startBreathing() {
    if (_breathRunning || _breathComplete) return;
    setState(() => _breathRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _remaining = 0;
          _breathRunning = false;
          _breathComplete = true;
          timer.cancel();
        }
      });
    });
  }

  bool get _canComplete => _selected == DailyPracticeKind.breath
      ? _breathComplete
      : _note.text.trim().length >= 3;

  String get _breathPhase {
    if (_breathComplete) {
      return _copy(
        widget.language,
        en: 'Complete',
        es: 'Completo',
        fr: 'Terminé',
        pt: 'Concluído',
        tr: 'Tamamlandı',
      );
    }
    if (!_breathRunning) {
      return _copy(
        widget.language,
        en: 'Ready',
        es: 'Listo',
        fr: 'Prêt',
        pt: 'Pronto',
        tr: 'Hazır',
      );
    }
    final elapsed = _breathSeconds - _remaining;
    final phase = elapsed % 12;
    if (phase < 4) {
      return _copy(
        widget.language,
        en: 'Breathe in',
        es: 'Inhala',
        fr: 'Inspirez',
        pt: 'Inspire',
        tr: 'Nefes al',
      );
    }
    if (phase < 6) {
      return _copy(
        widget.language,
        en: 'Hold softly',
        es: 'Sostén suavemente',
        fr: 'Retenez doucement',
        pt: 'Segure suavemente',
        tr: 'Yumuşakça tut',
      );
    }
    return _copy(
      widget.language,
      en: 'Breathe out',
      es: 'Exhala',
      fr: 'Expirez',
      pt: 'Expire',
      tr: 'Nefes ver',
    );
  }

  @override
  Widget build(BuildContext context) {
    final definitions = dailyPracticeDefinitions(widget.language);
    final selected = definitions.firstWhere((item) => item.kind == _selected);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, keyboard + 22),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _copy(
                widget.language,
                en: 'Today’s private ritual',
                es: 'El ritual privado de hoy',
                fr: 'Le rituel privé du jour',
                pt: 'O ritual privado de hoje',
                tr: 'Bugünün özel ritüeli',
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 7),
            Text(
              _copy(
                widget.language,
                en: 'Choose one small practice. Mystic saves only that it was completed—not what you write.',
                es: 'Elige una práctica pequeña. Mystic solo guarda que fue completada, no lo que escribes.',
                fr: 'Choisissez une petite pratique. Mystic enregistre seulement qu’elle a été terminée, jamais ce que vous écrivez.',
                pt: 'Escolha uma prática pequena. O Mystic salva apenas que ela foi concluída, não o que você escreve.',
                tr: 'Küçük bir pratik seç. Mystic yalnızca tamamlandığını kaydeder; yazdıklarını kaydetmez.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            for (final definition in definitions) ...[
              _PracticeChoice(
                definition: definition,
                selected: definition.kind == _selected,
                onTap: () => _select(definition.kind),
              ),
              const SizedBox(height: 9),
            ],
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _selected == DailyPracticeKind.breath
                  ? _BreathPractice(
                      key: const ValueKey('breath-practice'),
                      phase: _breathPhase,
                      remaining: _remaining,
                      running: _breathRunning,
                      complete: _breathComplete,
                      language: widget.language,
                      onStart: _startBreathing,
                    )
                  : _WritingPractice(
                      key: ValueKey(_selected),
                      controller: _note,
                      language: widget.language,
                      kind: _selected,
                      onChanged: (_) => setState(() {}),
                    ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canComplete
                    ? () => Navigator.of(context).pop(_selected)
                    : null,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  _copy(
                    widget.language,
                    en: 'Complete this ritual',
                    es: 'Completar este ritual',
                    fr: 'Terminer ce rituel',
                    pt: 'Concluir este ritual',
                    tr: 'Bu ritüeli tamamla',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                selected.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MysticColors.muted, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeChoice extends StatelessWidget {
  const _PracticeChoice({
    required this.definition,
    required this.selected,
    required this.onTap,
  });

  final DailyPracticeDefinition definition;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: definition.title,
    child: InkWell(
      key: ValueKey('practice-${definition.kind.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? MysticColors.violet.withValues(alpha: .24)
              : Colors.white.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? MysticColors.gold.withValues(alpha: .48)
                : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: MysticColors.gold.withValues(alpha: .11),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(definition.icon, color: MysticColors.gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    definition.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    definition.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? MysticColors.gold : MysticColors.muted,
            ),
          ],
        ),
      ),
    ),
  );
}

class _BreathPractice extends StatelessWidget {
  const _BreathPractice({
    super.key,
    required this.phase,
    required this.remaining,
    required this.running,
    required this.complete,
    required this.language,
    required this.onStart,
  });

  final String phase;
  final int remaining;
  final bool running;
  final bool complete;
  final MysticLanguage language;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF3A2858), Color(0xFF171220)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: MysticColors.lavender.withValues(alpha: .2)),
    ),
    child: Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          width: running ? 92 : 72,
          height: running ? 92 : 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: complete
                ? MysticColors.gold.withValues(alpha: .18)
                : MysticColors.violet.withValues(alpha: .28),
            border: Border.all(color: MysticColors.gold.withValues(alpha: .5)),
          ),
          child: Text(
            complete ? '✓' : '$remaining',
            style: const TextStyle(
              color: MysticColors.gold,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(phase, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (!running && !complete)
          OutlinedButton.icon(
            key: const ValueKey('start-breath-practice'),
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              _copy(
                language,
                en: 'Begin 24-second breathing',
                es: 'Iniciar respiración de 24 segundos',
                fr: 'Commencer 24 secondes de respiration',
                pt: 'Iniciar respiração de 24 segundos',
                tr: '24 saniyelik nefese başla',
              ),
            ),
          ),
      ],
    ),
  );
}

class _WritingPractice extends StatelessWidget {
  const _WritingPractice({
    super.key,
    required this.controller,
    required this.language,
    required this.kind,
    required this.onChanged,
  });

  final TextEditingController controller;
  final MysticLanguage language;
  final DailyPracticeKind kind;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    key: const ValueKey('daily-practice-note'),
    controller: controller,
    autofocus: false,
    minLines: 3,
    maxLines: 5,
    maxLength: 220,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: kind == DailyPracticeKind.intention
          ? _copy(
              language,
              en: 'My smallest honest action',
              es: 'Mi acción honesta más pequeña',
              fr: 'Ma plus petite action sincère',
              pt: 'Minha menor ação honesta',
              tr: 'En küçük dürüst eylemim',
            )
          : _copy(
              language,
              en: 'What is supporting me now',
              es: 'Lo que me sostiene ahora',
              fr: 'Ce qui me soutient maintenant',
              pt: 'O que está me apoiando agora',
              tr: 'Şu anda beni destekleyen şey',
            ),
      helperText: _copy(
        language,
        en: 'This text disappears when the sheet closes.',
        es: 'Este texto desaparece al cerrar la hoja.',
        fr: 'Ce texte disparaît à la fermeture de la feuille.',
        pt: 'Este texto desaparece quando a tela é fechada.',
        tr: 'Bu metin ekran kapandığında silinir.',
      ),
    ),
  );
}

String _copy(
  MysticLanguage language, {
  required String en,
  required String es,
  required String fr,
  required String pt,
  required String tr,
}) => switch (language) {
  MysticLanguage.spanish => es,
  MysticLanguage.french => fr,
  MysticLanguage.portugueseBrazil => pt,
  MysticLanguage.turkish => tr,
  _ => en,
};
