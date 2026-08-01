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
    this.onOpenDestiny,
    this.clock,
  });

  final MysticLanguage language;
  final MysticJourneyStore? store;
  final VoidCallback? onStartReading;
  final VoidCallback? onOpenDestiny;
  final DateTime Function()? clock;

  @override
  State<MysticJourneysFeature> createState() => _MysticJourneysFeatureState();
}

class _MysticJourneysFeatureState extends State<MysticJourneysFeature> {
  late final MysticJourneyStore _store =
      widget.store ?? SharedPreferencesMysticJourneyStore();
  late final DateTime Function() _clock = widget.clock ?? DateTime.now;

  List<MysticJourney> _journeys = const [];
  JourneyLoadResult? _loadResult;
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadFailed = false;
      });
    }

    try {
      final result = await _store.load();
      if (!mounted) return;
      setState(() {
        _journeys = result.journeys;
        _loadResult = result;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  Future<bool> _persist(List<MysticJourney> next) async {
    try {
      await _store.save(next);
      if (!mounted) return false;
      setState(() {
        _journeys = List.unmodifiable(next);
        _loadResult = const JourneyLoadResult(
          journeys: [],
          recoveredFromBackup: false,
          rejectedItems: 0,
        );
      });
      return true;
    } on Object {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _copy(
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
    final created = await showModalBottomSheet<MysticJourney>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: MysticColors.night,
      builder: (_) => _CreateJourneySheet(
        language: widget.language,
        now: _clock(),
      ),
    );
    if (!mounted || created == null) return;
    await _persist([..._journeys, created]);
  }

  Future<bool> _replaceJourney(MysticJourney updated) {
    final next = _journeys
        .map((journey) => journey.id == updated.id ? updated : journey)
        .toList(growable: false);
    return _persist(next);
  }

  void _openJourney(MysticJourney journey) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _JourneyDetailPage(
          journey: journey,
          language: widget.language,
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
    if (_loadFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 16),
              Text(
                _copy(
                  widget.language,
                  'Your journeys could not be opened safely.',
                  'Yolculukların güvenli şekilde açılamadı.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => _load(),
                child: Text(_copy(widget.language, 'Try again', 'Tekrar dene')),
              ),
            ],
          ),
        ),
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

    return Scaffold(
      backgroundColor: MysticColors.ink,
      appBar: AppBar(
        title: Text(_copy(widget.language, 'Journeys', 'Yolculuklar')),
        actions: [
          if (widget.onOpenDestiny != null)
            IconButton(
              tooltip: _copy(widget.language, 'Destiny path', 'Kader yolu'),
              onPressed: widget.onOpenDestiny,
              icon: const Icon(Icons.auto_awesome_motion_rounded),
            ),
          IconButton(
            tooltip: _copy(widget.language, 'Create journey', 'Yolculuk oluştur'),
            onPressed: _createJourney,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: visible.isEmpty
            ? _EmptyJourneys(
                language: widget.language,
                onCreate: _createJourney,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 104),
                children: [
                  if (_loadResult?.recoveredFromBackup ?? false)
                    _Notice(
                      text: _copy(
                        widget.language,
                        'Mystic restored your last safe journey backup.',
                        'Mystic son güvenli yolculuk yedeğini geri yükledi.',
                      ),
                    ),
                  if ((_loadResult?.rejectedItems ?? 0) > 0)
                    _Notice(
                      text: _copy(
                        widget.language,
                        '${_loadResult!.rejectedItems} damaged item(s) were skipped safely.',
                        '${_loadResult!.rejectedItems} bozuk kayıt güvenle atlandı.',
                      ),
                    ),
                  Text(
                    _copy(
                      widget.language,
                      'Your reflection paths',
                      'Düşünce yolculukların',
                    ),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _copy(
                      widget.language,
                      'Follow meaningful themes over time without pressure or predictions.',
                      'Anlamlı temaları baskı veya kehanet olmadan zaman içinde takip et.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 22),
                  for (final journey in visible) ...[
                    _JourneyCard(
                      journey: journey,
                      language: widget.language,
                      onTap: () => _openJourney(journey),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
      ),
      floatingActionButton: visible.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _createJourney,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(_copy(widget.language, 'New journey', 'Yeni yolculuk')),
            ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.journey,
    required this.language,
    required this.onTap,
  });

  final MysticJourney journey;
  final MysticLanguage language;
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
                      label: _copy(language, 'Entries', 'Kayıt'),
                    ),
                    _Metric(
                      value: '${snapshot.activeDays}',
                      label: _copy(language, 'Days', 'Gün'),
                    ),
                    _Metric(
                      value: '${(snapshot.reflectionRate * 100).round()}%',
                      label: _copy(language, 'Reflected', 'Yansıtma'),
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

class _CreateJourneySheet extends StatefulWidget {
  const _CreateJourneySheet({required this.language, required this.now});

  final MysticLanguage language;
  final DateTime now;

  @override
  State<_CreateJourneySheet> createState() => _CreateJourneySheetState();
}

class _CreateJourneySheetState extends State<_CreateJourneySheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _intention = TextEditingController();
  JourneyArea _area = JourneyArea.custom;

  @override
  void dispose() {
    _title.dispose();
    _intention.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      MysticJourney(
        id: 'journey-${widget.now.microsecondsSinceEpoch}',
        title: _title.text.trim(),
        area: _area,
        createdAt: widget.now,
        intention: _trimmedOrNull(_intention.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
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
                _copy(widget.language, 'Create a journey', 'Yolculuk oluştur'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _title,
                autofocus: true,
                maxLength: 48,
                decoration: InputDecoration(
                  labelText: _copy(widget.language, 'Journey name', 'Yolculuk adı'),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? _copy(widget.language, 'A name is required.', 'Bir ad gerekli.')
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _intention,
                minLines: 2,
                maxLines: 3,
                maxLength: 160,
                decoration: InputDecoration(
                  labelText: _copy(widget.language, 'Intention', 'Niyet'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _copy(widget.language, 'Life area', 'Yaşam alanı'),
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
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    _copy(widget.language, 'Begin journey', 'Yolculuğu başlat'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneyDetailPage extends StatefulWidget {
  const _JourneyDetailPage({
    required this.journey,
    required this.language,
    required this.clock,
    required this.onChanged,
    this.onStartReading,
  });

  final MysticJourney journey;
  final MysticLanguage language;
  final DateTime Function() clock;
  final Future<bool> Function(MysticJourney journey) onChanged;
  final VoidCallback? onStartReading;

  @override
  State<_JourneyDetailPage> createState() => _JourneyDetailPageState();
}

class _JourneyDetailPageState extends State<_JourneyDetailPage> {
  late MysticJourney _journey = widget.journey;
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
    final entry = await showModalBottomSheet<JourneyEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: MysticColors.night,
      builder: (_) => _ReflectionSheet(
        language: widget.language,
        now: widget.clock(),
        sequence: _journey.entries.length + 1,
      ),
    );
    if (!mounted || entry == null) return;
    await _apply(_journey.addEntry(entry));
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = JourneyInsights.summarize(
      _journey,
      generatedAt: widget.clock(),
    );
    final entries = _journey.entries.reversed.toList(growable: false);
    final accent = _areaColor(_journey.area);

    return Scaffold(
      appBar: AppBar(
        title: Text(_journey.title),
        actions: [
          PopupMenuButton<JourneyStatus>(
            onSelected: (status) => _apply(_journey.copyWith(status: status)),
            itemBuilder: (_) => [
              if (_journey.status != JourneyStatus.active)
                PopupMenuItem(
                  value: JourneyStatus.active,
                  child: Text(_copy(widget.language, 'Resume', 'Devam et')),
                ),
              if (_journey.status == JourneyStatus.active)
                PopupMenuItem(
                  value: JourneyStatus.paused,
                  child: Text(_copy(widget.language, 'Pause', 'Duraklat')),
                ),
              if (_journey.status != JourneyStatus.completed)
                PopupMenuItem(
                  value: JourneyStatus.completed,
                  child: Text(_copy(widget.language, 'Complete', 'Tamamla')),
                ),
              PopupMenuItem(
                value: JourneyStatus.archived,
                child: Text(_copy(widget.language, 'Archive', 'Arşivle')),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 104),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [accent.withValues(alpha: .22), MysticColors.night],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: accent.withValues(alpha: .34)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_areaLabel(widget.language, _journey.area)} · ${_statusLabel(widget.language, _journey.status)}',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                ),
                if (_journey.intention?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 14),
                  Text(
                    _journey.intention!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    _Metric(
                      value: '${snapshot.entryCount}',
                      label: _copy(widget.language, 'Entries', 'Kayıt'),
                    ),
                    _Metric(
                      value: '${snapshot.activeDays}',
                      label: _copy(widget.language, 'Active days', 'Aktif gün'),
                    ),
                    _Metric(
                      value: '${(snapshot.reflectionRate * 100).round()}%',
                      label: _copy(widget.language, 'Reflected', 'Yansıtma'),
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
                  _copy(widget.language, 'Timeline', 'Zaman çizelgesi'),
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
          if (entries.isEmpty)
            _Notice(
              text: _copy(
                widget.language,
                'Your first reflection will begin this timeline.',
                'İlk düşüncen bu zaman çizelgesini başlatacak.',
              ),
            )
          else
            for (final entry in entries) ...[
              _EntryCard(entry: entry, accent: accent),
              const SizedBox(height: 12),
            ],
          if (widget.onStartReading != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: widget.onStartReading,
              icon: const Icon(Icons.style_rounded),
              label: Text(
                _copy(widget.language, 'Start a reading', 'Bir açılım başlat'),
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
                _copy(widget.language, 'Add reflection', 'Düşünce ekle'),
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
  final _reflection = TextEditingController();
  final _tags = TextEditingController();
  String? _mood;

  static const moods = ['calm', 'hopeful', 'uncertain', 'energized', 'heavy'];

  @override
  void dispose() {
    _reflection.dispose();
    _tags.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final normalizedTags = _tags.text
        .split(',')
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .take(8)
        .toSet();

    Navigator.of(context).pop(
      JourneyEntry(
        id: 'entry-${widget.now.microsecondsSinceEpoch}-${widget.sequence}',
        createdAt: widget.now,
        title: _copy(widget.language, 'Reflection', 'Düşünce'),
        reflection: _reflection.text.trim(),
        mood: _mood,
        tags: Set.unmodifiable(normalizedTags),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
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
                _copy(widget.language, 'Add a reflection', 'Düşünce ekle'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _reflection,
                autofocus: true,
                minLines: 4,
                maxLines: 8,
                maxLength: 1200,
                decoration: InputDecoration(
                  labelText: _copy(
                    widget.language,
                    'What did you notice?',
                    'Ne fark ettin?',
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? _copy(
                        widget.language,
                        'Write at least one thought.',
                        'En az bir düşünce yaz.',
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                _copy(widget.language, 'Mood (optional)', 'Ruh hâli (isteğe bağlı)'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: moods
                    .map(
                      (mood) => ChoiceChip(
                        selected: _mood == mood,
                        label: Text(mood),
                        onSelected: (selected) {
                          setState(() => _mood = selected ? mood : null);
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tags,
                maxLength: 120,
                decoration: InputDecoration(
                  labelText: _copy(
                    widget.language,
                    'Tags (comma separated)',
                    'Etiketler (virgülle ayır)',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    _copy(widget.language, 'Save reflection', 'Düşünceyi kaydet'),
                  ),
                ),
              ),
            ],
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
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.accent});

  final JourneyEntry entry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(_date(entry.createdAt)),
            ],
          ),
          if (entry.reflection?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            Text(
              entry.reflection!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
}

class _EmptyJourneys extends StatelessWidget {
  const _EmptyJourneys({required this.language, required this.onCreate});

  final MysticLanguage language;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6948A9), Color(0xFF211735)],
                ),
                border: Border.all(color: MysticColors.gold.withValues(alpha: .42)),
                boxShadow: [
                  BoxShadow(
                    color: MysticColors.violet.withValues(alpha: .35),
                    blurRadius: 32,
                  ),
                ],
              ),
              child: const Icon(
                Icons.hub_rounded,
                size: 42,
                color: MysticColors.gold,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              _copy(
                language,
                'Begin a meaningful journey',
                'Anlamlı bir yolculuk başlat',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _copy(
                language,
                'Connect readings and reflections around one part of your life.',
                'Açılımları ve düşüncelerini hayatının tek bir alanında birleştir.',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2B2046), Color(0xFF15111F)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: MysticColors.lavender.withValues(alpha: .24)),
              ),
              child: Column(
                children: [
                  _JourneyPromise(
                    number: '01',
                    title: _copy(language, 'Name what matters', 'Önemli olanı adlandır'),
                    body: _copy(language, 'Love, work, healing or your own path', 'Aşk, iş, iyileşme veya kendi yolun'),
                  ),
                  const SizedBox(height: 15),
                  _JourneyPromise(
                    number: '02',
                    title: _copy(language, 'Connect your readings', 'Okumalarını birbirine bağla'),
                    body: _copy(language, 'Watch one question evolve over time', 'Tek bir sorunun zamanla değişimini gör'),
                  ),
                  const SizedBox(height: 15),
                  _JourneyPromise(
                    number: '03',
                    title: _copy(language, 'See your turning points', 'Dönüm noktalarını gör'),
                    body: _copy(language, 'Mystic reveals the pattern behind your choices', 'Mystic seçimlerinin ardındaki örüntüyü gösterir'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  _copy(language, 'Create first journey', 'İlk yolculuğu oluştur'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyPromise extends StatelessWidget {
  const _JourneyPromise({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MysticColors.gold.withValues(alpha: .12),
              border: Border.all(color: MysticColors.gold.withValues(alpha: .36)),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'Arial',
                color: MysticColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 3),
                Text(body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MysticColors.gold.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MysticColors.gold.withValues(alpha: .30)),
      ),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}

String _copy(MysticLanguage language, String english, String turkish) {
  return mysticText(language, english, turkish);
}

String? _trimmedOrNull(String value) {
  final clean = value.trim();
  return clean.isEmpty ? null : clean;
}

String _date(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}.'
      '${value.month.toString().padLeft(2, '0')}.${value.year}';
}

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
      JourneyArea.relationship => _copy(language, 'Relationship', 'İlişki'),
      JourneyArea.career => _copy(language, 'Career', 'Kariyer'),
      JourneyArea.wellbeing => _copy(language, 'Wellbeing', 'İyi oluş'),
      JourneyArea.education => _copy(language, 'Education', 'Eğitim'),
      JourneyArea.creativity => _copy(language, 'Creativity', 'Yaratıcılık'),
      JourneyArea.confidence => _copy(language, 'Confidence', 'Özgüven'),
      JourneyArea.custom => _copy(language, 'Personal', 'Kişisel'),
    };

String _statusLabel(MysticLanguage language, JourneyStatus status) =>
    switch (status) {
      JourneyStatus.active => _copy(language, 'Active', 'Aktif'),
      JourneyStatus.paused => _copy(language, 'Paused', 'Duraklatıldı'),
      JourneyStatus.completed => _copy(language, 'Completed', 'Tamamlandı'),
      JourneyStatus.archived => _copy(language, 'Archived', 'Arşivlendi'),
    };
