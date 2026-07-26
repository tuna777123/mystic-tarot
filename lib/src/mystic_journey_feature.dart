import 'package:flutter/material.dart';

import 'flagship.dart';
import 'mystic_journey.dart';
import 'mystic_journey_store.dart';
import 'theme.dart';

class MysticJourneysFeature extends StatefulWidget {
  const MysticJourneysFeature({
    super.key,
    required this.language,
    this.store,
    this.onStartReading,
    this.clock,
  });

  final MysticLanguage language;
  final MysticJourneyStore? store;
  final VoidCallback? onStartReading;
  final DateTime Function()? clock;

  @override
  State<MysticJourneysFeature> createState() => _MysticJourneysFeatureState();
}

class _MysticJourneysFeatureState extends State<MysticJourneysFeature> {
  late final MysticJourneyStore _store =
      widget.store ?? SharedPreferencesMysticJourneyStore();
  late final DateTime Function() _clock = widget.clock ?? DateTime.now;

  List<MysticJourney> _journeys = const [];
  bool _loading = true;
  bool _recoveredFromBackup = false;
  int _rejectedItems = 0;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final result = await _store.load();
      if (!mounted) return;
      setState(() {
        _journeys = result.journeys;
        _recoveredFromBackup = result.recoveredFromBackup;
        _rejectedItems = result.rejectedItems;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = _t(
          widget.language,
          'Your journeys could not be opened safely.',
          'Yolculukların güvenli şekilde açılamadı.',
        );
      });
    }
  }

  Future<bool> _commit(List<MysticJourney> next) async {
    try {
      await _store.save(next);
      if (!mounted) return false;
      setState(() {
        _journeys = List.unmodifiable(next);
        _recoveredFromBackup = false;
        _rejectedItems = 0;
      });
      return true;
    } on Object {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              widget.language,
              'Changes were not saved. Please try again.',
              'Değişiklikler kaydedilemedi. Lütfen tekrar dene.',
            ),
          ),
        ),
      );
      return false;
    }
  }

  Future<void> _createJourney() async {
    final journey = await showModalBottomSheet<MysticJourney>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: MysticColors.night,
      builder: (context) => _JourneyEditorSheet(
        language: widget.language,
        now: _clock(),
      ),
    );
    if (journey == null || !mounted) return;
    await _commit([..._journeys, journey]);
  }

  Future<bool> _replaceJourney(MysticJourney updated) {
    final next = _journeys
        .map((item) => item.id == updated.id ? updated : item)
        .toList(growable: false);
    return _commit(next);
  }

  Future<void> _openJourney(MysticJourney journey) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _JourneyDetailScreen(
          language: widget.language,
          initialJourney: journey,
          clock: _clock,
          onChanged: _replaceJourney,
          onStartReading: widget.onStartReading,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return _LoadFailure(
        message: _loadError!,
        retryLabel: _t(widget.language, 'Try again', 'Tekrar dene'),
        onRetry: _load,
      );
    }

    final visible = _journeys
        .where((journey) => journey.status != JourneyStatus.archived)
        .toList(growable: false)
      ..sort((a, b) {
        final aDate = a.lastActivityAt ?? a.createdAt;
        final bDate = b.lastActivityAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });
    final active = visible
        .where((journey) => journey.status != JourneyStatus.completed)
        .toList(growable: false);
    final completed = visible
        .where((journey) => journey.status == JourneyStatus.completed)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: MysticColors.ink,
      appBar: AppBar(
        title: Text(_t(widget.language, 'Journeys', 'Yolculuklar')),
        actions: [
          IconButton(
            tooltip: _t(widget.language, 'Create journey', 'Yolculuk oluştur'),
            onPressed: _createJourney,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: visible.isEmpty
            ? _JourneyEmptyState(
                language: widget.language,
                onCreate: _createJourney,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
                children: [
                  if (_recoveredFromBackup || _rejectedItems > 0)
                    _RecoveryNotice(
                      language: widget.language,
                      recovered: _recoveredFromBackup,
                      rejectedItems: _rejectedItems,
                    ),
                  Text(
                    _t(
                      widget.language,
                      'Your reflection paths',
                      'Düşünce yolculukların',
                    ),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t(
                      widget.language,
                      'Follow meaningful themes over time without pressure or predictions.',
                      'Anlamlı temaları baskı veya kehanet olmadan zaman içinde takip et.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  for (final journey in active) ...[
                    _JourneyCard(
                      language: widget.language,
                      journey: journey,
                      onTap: () => _openJourney(journey),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (completed.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      _t(widget.language, 'Completed', 'Tamamlananlar'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    for (final journey in completed) ...[
                      _JourneyCard(
                        language: widget.language,
                        journey: journey,
                        onTap: () => _openJourney(journey),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ],
              ),
      ),
      floatingActionButton: visible.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _createJourney,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(_t(widget.language, 'New journey', 'Yeni yolculuk')),
            ),
    );
  }
}

class _JourneyEditorSheet extends StatefulWidget {
  const _JourneyEditorSheet({required this.language, required this.now});

  final MysticLanguage language;
  final DateTime now;

  @override
  State<_JourneyEditorSheet> createState() => _JourneyEditorSheetState();
}

class _JourneyEditorSheetState extends State<_JourneyEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _intentionController = TextEditingController();
  JourneyArea _area = JourneyArea.custom;

  @override
  void dispose() {
    _titleController.dispose();
    _intentionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final now = widget.now;
    Navigator.of(context).pop(
      MysticJourney(
        id: 'journey-${now.microsecondsSinceEpoch}',
        title: _titleController.text.trim(),
        area: _area,
        createdAt: now,
        intention: _optional(_intentionController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(widget.language, 'Create a journey', 'Yolculuk oluştur'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _t(
                    widget.language,
                    'Choose one theme you want to understand over time.',
                    'Zaman içinde anlamak istediğin tek bir tema seç.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  maxLength: 48,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText:
                        _t(widget.language, 'Journey name', 'Yolculuk adı'),
                    hintText: _t(
                      widget.language,
                      'Career clarity',
                      'Kariyer netliği',
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? _t(widget.language, 'A name is required.',
                          'Bir ad gerekli.')
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _intentionController,
                  maxLength: 160,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: _t(widget.language, 'Intention', 'Niyet'),
                    hintText: _t(
                      widget.language,
                      'What would you like to understand?',
                      'Neyi anlamak istiyorsun?',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _t(widget.language, 'Life area', 'Yaşam alanı'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: JourneyArea.values
                      .map(
                        (area) => ChoiceChip(
                          selected: _area == area,
                          avatar: Icon(_areaIcon(area), size: 18),
                          label: Text(_areaLabel(widget.language, area)),
                          onSelected: (_) => setState(() => _area = area),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: Text(
                      _t(widget.language, 'Begin journey', 'Yolculuğu başlat'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _JourneyDetailScreen extends StatefulWidget {
  const _JourneyDetailScreen({
    required this.language,
    required this.initialJourney,
    required this.clock,
    required this.onChanged,
    this.onStartReading,
  });

  final MysticLanguage language;
  final MysticJourney initialJourney;
  final DateTime Function() clock;
  final Future<bool> Function(MysticJourney journey) onChanged;
  final VoidCallback? onStartReading;

  @override
  State<_JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<_JourneyDetailScreen> {
  late MysticJourney _journey = widget.initialJourney;
  bool _saving = false;

  Future<void> _apply(MysticJourney updated) async {
    if (_saving) return;
    setState(() => _saving = true);
    final saved = await widget.onChanged(updated);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (saved) _journey = updated;
    });
  }

  Future<void> _addReflection() async {
    if (!_journey.canAcceptEntries) return;
    final entry = await showModalBottomSheet<JourneyEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: MysticColors.night,
      builder: (context) => _ReflectionSheet(
        language: widget.language,
        now: widget.clock(),
        sequence: _journey.entries.length + 1,
      ),
    );
    if (entry == null || !mounted) return;
    await _apply(_journey.addEntry(entry));
  }

  Future<void> _changeStatus(JourneyStatus status) =>
      _apply(_journey.copyWith(status: status));

  @override
  Widget build(BuildContext context) {
    final snapshot = JourneyInsights.summarize(
      _journey,
      generatedAt: widget.clock(),
    );
    final reversedEntries = _journey.entries.reversed.toList(growable: false);
    final accent = _areaColor(_journey.area);

    return Scaffold(
      appBar: AppBar(
        title: Text(_journey.title),
        actions: [
          PopupMenuButton<JourneyStatus>(
            tooltip: _t(widget.language, 'Journey status', 'Yolculuk durumu'),
            onSelected: _changeStatus,
            itemBuilder: (context) => [
              if (_journey.status != JourneyStatus.active)
                PopupMenuItem(
                  value: JourneyStatus.active,
                  child: Text(_t(widget.language, 'Resume', 'Devam et')),
                ),
              if (_journey.status == JourneyStatus.active)
                PopupMenuItem(
                  value: JourneyStatus.paused,
                  child: Text(_t(widget.language, 'Pause', 'Duraklat')),
                ),
              if (_journey.status != JourneyStatus.completed)
                PopupMenuItem(
                  value: JourneyStatus.completed,
                  child: Text(_t(widget.language, 'Complete', 'Tamamla')),
                ),
              PopupMenuItem(
                value: JourneyStatus.archived,
                child: Text(_t(widget.language, 'Archive', 'Arşivle')),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [accent.withValues(alpha: .24), MysticColors.night],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: accent.withValues(alpha: .38)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_areaIcon(_journey.area), color: accent),
                    const SizedBox(width: 10),
                    Text(
                      _areaLabel(widget.language, _journey.area),
                      style:
                          TextStyle(color: accent, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      _statusLabel(widget.language, _journey.status),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (_journey.intention?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  Text(
                    _journey.intention!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Metric(
                      value: '${snapshot.entryCount}',
                      label: _t(widget.language, 'Entries', 'Kayıt'),
                    ),
                    _Metric(
                      value: '${snapshot.activeDays}',
                      label: _t(widget.language, 'Active days', 'Aktif gün'),
                    ),
                    _Metric(
                      value: '${(snapshot.reflectionRate * 100).round()}%',
                      label: _t(widget.language, 'Reflected', 'Yansıtma'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  _t(widget.language, 'Timeline', 'Zaman çizelgesi'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (_saving)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (reversedEntries.isEmpty)
            _TimelineEmpty(language: widget.language)
          else
            for (final entry in reversedEntries) ...[
              _TimelineEntry(entry: entry, accent: accent),
              const SizedBox(height: 12),
            ],
          if (widget.onStartReading != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: widget.onStartReading,
              icon: const Icon(Icons.style_rounded),
              label: Text(
                _t(widget.language, 'Start a reading', 'Bir açılım başlat'),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: _journey.canAcceptEntries
          ? FloatingActionButton.extended(
              onPressed: _saving ? null : _addReflection,
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(
                _t(widget.language, 'Add reflection', 'Düşünce ekle'),
              ),
            )
          : null,
    );
  }
}

class _ReflectionSheet extends StatefulWidget {
  const _ReflectionSheet({
    required this.language,
    required this.now,
    required this.sequence,
  });

  final MysticLanguage language;
  final DateTime now;
  final int sequence;

  @override
  State<_ReflectionSheet> createState() => _ReflectionSheetState();
}

class _ReflectionSheetState extends State<_ReflectionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _reflectionController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _mood;

  @override
  void dispose() {
    _titleController.dispose();
    _reflectionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .take(8)
        .toSet();
    Navigator.of(context).pop(
      JourneyEntry(
        id: 'entry-${widget.now.microsecondsSinceEpoch}-${widget.sequence}',
        createdAt: widget.now,
        title: _optional(_titleController.text) ??
            _t(widget.language, 'Reflection', 'Düşünce'),
        reflection: _reflectionController.text.trim(),
        mood: _mood,
        tags: Set.unmodifiable(tags),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(widget.language, 'Add a reflection', 'Düşünce ekle'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  maxLength: 60,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: _t(widget.language, 'Title (optional)',
                        'Başlık (isteğe bağlı)'),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _reflectionController,
                  autofocus: true,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 1200,
                  decoration: InputDecoration(
                    labelText: _t(widget.language, 'What did you notice?',
                        'Ne fark ettin?'),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? _t(widget.language, 'Write at least one thought.',
                          'En az bir düşünce yaz.')
                      : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _mood,
                  decoration: InputDecoration(
                    labelText: _t(widget.language, 'Mood (optional)',
                        'Ruh hâli (isteğe bağlı)'),
                  ),
                  items: const [
                    'calm',
                    'hopeful',
                    'uncertain',
                    'energized',
                    'heavy'
                  ]
                      .map((mood) =>
                          DropdownMenuItem(value: mood, child: Text(mood)))
                      .toList(growable: false),
                  onChanged: (value) => setState(() => _mood = value),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _tagsController,
                  maxLength: 120,
                  decoration: InputDecoration(
                    labelText: _t(widget.language, 'Tags (comma separated)',
                        'Etiketler (virgülle ayır)'),
                    hintText:
                        _t(widget.language, 'clarity, work', 'netlik, iş'),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(_t(widget.language, 'Save reflection',
                        'Düşünceyi kaydet')),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.language,
    required this.journey,
    required this.onTap,
  });

  final MysticLanguage language;
  final MysticJourney journey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final snapshot = JourneyInsights.summarize(
      journey,
      generatedAt: DateTime.now(),
    );
    final accent = _areaColor(journey.area);
    return Semantics(
      button: true,
      label: '${journey.title}, ${snapshot.entryCount}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent.withValues(alpha: .20), MysticColors.night],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_areaIcon(journey.area), color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            journey.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_areaLabel(language, journey.area)} · ${_statusLabel(language, journey.status)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
                if (journey.intention?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 14),
                  Text(
                    journey.intention!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Metric(
                      value: '${snapshot.entryCount}',
                      label: _t(language, 'Entries', 'Kayıt'),
                    ),
                    _Metric(
                      value: '${snapshot.activeDays}',
                      label: _t(language, 'Days', 'Gün'),
                    ),
                    _Metric(
                      value: '${(snapshot.reflectionRate * 100).round()}%',
                      label: _t(language, 'Reflected', 'Yansıtma'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.entry, required this.accent});

  final JourneyEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .045),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: .22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(entry.title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text(
                  _dateLabel(entry.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (entry.reflection?.isNotEmpty ?? false) ...[
              const SizedBox(height: 10),
              Text(entry.reflection!,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (entry.mood != null || entry.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  if (entry.mood != null) Chip(label: Text(entry.mood!)),
                  ...entry.tags.map((tag) => Chip(label: Text(tag))),
                ],
              ),
            ],
          ],
        ),
      );
}

class _JourneyEmptyState extends StatelessWidget {
  const _JourneyEmptyState({required this.language, required this.onCreate});

  final MysticLanguage language;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hub_rounded,
                  size: 72, color: MysticColors.lavender),
              const SizedBox(height: 22),
              Text(
                _t(language, 'Begin a meaningful journey',
                    'Anlamlı bir yolculuk başlat'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                _t(
                  language,
                  'Connect readings and reflections around one part of your life.',
                  'Açılımları ve düşüncelerini hayatının tek bir alanında birleştir.',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(_t(
                    language, 'Create first journey', 'İlk yolculuğu oluştur')),
              ),
            ],
          ),
        ),
      );
}

class _TimelineEmpty extends StatelessWidget {
  const _TimelineEmpty({required this.language});

  final MysticLanguage language;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          _t(
            language,
            'Your first reflection will begin this timeline.',
            'İlk düşüncen bu zaman çizelgesini başlatacak.',
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
}

class _RecoveryNotice extends StatelessWidget {
  const _RecoveryNotice({
    required this.language,
    required this.recovered,
    required this.rejectedItems,
  });

  final MysticLanguage language;
  final bool recovered;
  final int rejectedItems;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MysticColors.gold.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .32)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_outlined, color: MysticColors.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                recovered
                    ? _t(
                        language,
                        'Mystic restored your last safe journey backup.',
                        'Mystic son güvenli yolculuk yedeğini geri yükledi.',
                      )
                    : _t(
                        language,
                        '$rejectedItems damaged item(s) were skipped safely.',
                        '$rejectedItems bozuk kayıt güvenle atlandı.',
                      ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              FilledButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ),
        ),
      );
}

String _t(MysticLanguage language, String english, String turkish) =>
    language == MysticLanguage.turkish ? turkish : english;

String? _optional(String value) {
  final clean = value.trim();
  return clean.isEmpty ? null : clean;
}

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

Color _areaColor(JourneyArea area) => switch (area) {
      JourneyArea.relationship => const Color(0xFFFF7AA8),
      JourneyArea.career => const Color(0xFF8DB9FF),
      JourneyArea.wellbeing => const Color(0xFF77D9B4),
      JourneyArea.education => const Color(0xFFFFC66D),
      JourneyArea.creativity => const Color(0xFFD89CFF),
      JourneyArea.confidence => const Color(0xFFFF9878),
      JourneyArea.custom => MysticColors.lavender,
    };

IconData _areaIcon(JourneyArea area) => switch (area) {
      JourneyArea.relationship => Icons.favorite_rounded,
      JourneyArea.career => Icons.work_rounded,
      JourneyArea.wellbeing => Icons.spa_rounded,
      JourneyArea.education => Icons.school_rounded,
      JourneyArea.creativity => Icons.palette_rounded,
      JourneyArea.confidence => Icons.bolt_rounded,
      JourneyArea.custom => Icons.auto_awesome_rounded,
    };

String _areaLabel(MysticLanguage language, JourneyArea area) => switch (area) {
      JourneyArea.relationship => _t(language, 'Relationship', 'İlişki'),
      JourneyArea.career => _t(language, 'Career', 'Kariyer'),
      JourneyArea.wellbeing => _t(language, 'Wellbeing', 'İyi oluş'),
      JourneyArea.education => _t(language, 'Education', 'Eğitim'),
      JourneyArea.creativity => _t(language, 'Creativity', 'Yaratıcılık'),
      JourneyArea.confidence => _t(language, 'Confidence', 'Özgüven'),
      JourneyArea.custom => _t(language, 'Personal', 'Kişisel'),
    };

String _statusLabel(MysticLanguage language, JourneyStatus status) =>
    switch (status) {
      JourneyStatus.active => _t(language, 'Active', 'Aktif'),
      JourneyStatus.paused => _t(language, 'Paused', 'Duraklatıldı'),
      JourneyStatus.completed => _t(language, 'Completed', 'Tamamlandı'),
      JourneyStatus.archived => _t(language, 'Archived', 'Arşivlendi'),
    };
