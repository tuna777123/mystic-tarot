import 'dart:convert';

import 'mystic_memory.dart';

class MemoryDecodeReport {
  const MemoryDecodeReport({
    required this.events,
    required this.schemaVersion,
    required this.rejectedItems,
  });

  final List<TimelineEvent> events;
  final int schemaVersion;
  final int rejectedItems;
}

/// Versioned and defensive serialization for the unified memory timeline.
abstract final class MysticMemoryCodec {
  static const int schemaVersion = 1;

  static String encode(Iterable<TimelineEvent> events) {
    final ordered = events.toList(growable: false)
      ..sort((a, b) {
        final byDate = a.occurredAt.compareTo(b.occurredAt);
        return byDate != 0 ? byDate : a.id.compareTo(b.id);
      });

    return jsonEncode({
      'schemaVersion': schemaVersion,
      'events': ordered.map(_encodeEvent).toList(growable: false),
    });
  }

  static MemoryDecodeReport decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Memory payload must be a JSON object.');
    }

    final root = Map<String, dynamic>.from(decoded);
    final version = root['schemaVersion'];
    if (version is! int || version < 1 || version > schemaVersion) {
      throw FormatException('Unsupported memory schema version: $version');
    }

    final items = root['events'];
    if (items is! List) {
      throw const FormatException('Memory payload is missing its event list.');
    }

    final events = <TimelineEvent>[];
    final eventIds = <String>{};
    var rejected = 0;

    for (final item in items) {
      try {
        if (item is! Map) throw const FormatException('Invalid memory event.');
        final event = _decodeEvent(Map<String, dynamic>.from(item));
        if (!eventIds.add(event.id)) {
          rejected++;
          continue;
        }
        events.add(event);
      } on Object {
        rejected++;
      }
    }

    events.sort((a, b) {
      final byDate = a.occurredAt.compareTo(b.occurredAt);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return MemoryDecodeReport(
      events: List.unmodifiable(events),
      schemaVersion: version,
      rejectedItems: rejected,
    );
  }

  static Map<String, Object?> _encodeEvent(TimelineEvent event) {
    final themes = event.themes.toList(growable: false)
      ..sort((a, b) => a.index.compareTo(b.index));
    return {
      'id': event.id,
      'occurredAt': event.occurredAt.toUtc().toIso8601String(),
      'type': event.type.name,
      'title': event.title,
      'reflection': event.reflection,
      'themes': themes.map((theme) => theme.name).toList(growable: false),
      'tags': event.tags.toList(growable: false),
      'cardIds': event.cardIds,
      'mood': event.mood,
      'journeyId': event.journeyId,
      'sourceId': event.sourceId,
    };
  }

  static TimelineEvent _decodeEvent(Map<String, dynamic> value) {
    return TimelineEvent(
      id: _requiredText(value['id'], 'event.id'),
      occurredAt: _requiredDate(value['occurredAt'], 'event.occurredAt'),
      type: _enumByName(
        MemoryEventType.values,
        value['type'],
        MemoryEventType.note,
      ),
      title: _requiredText(value['title'], 'event.title'),
      reflection: _optionalText(value['reflection']),
      themes: _decodeThemes(value['themes']),
      tags: _decodeStrings(value['tags']),
      cardIds: _decodeStrings(value['cardIds']),
      mood: _optionalText(value['mood']),
      journeyId: _optionalText(value['journeyId']),
      sourceId: _optionalText(value['sourceId']),
    );
  }

  static Set<MemoryTheme> _decodeThemes(Object? value) {
    if (value is! List) return const <MemoryTheme>{};
    final themes = <MemoryTheme>{};
    for (final raw in value.whereType<String>()) {
      for (final theme in MemoryTheme.values) {
        if (theme.name == raw) {
          themes.add(theme);
          break;
        }
      }
    }
    return themes;
  }

  static List<String> _decodeStrings(Object? value) => value is List
      ? value.whereType<String>().toList(growable: false)
      : const [];

  static String _requiredText(Object? value, String field) {
    final text = _optionalText(value);
    if (text == null) throw FormatException('$field must not be empty.');
    return text;
  }

  static String? _optionalText(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static DateTime _requiredDate(Object? value, String field) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$field is invalid.');
    }
    final date = DateTime.tryParse(value);
    if (date == null) throw FormatException('$field is invalid.');
    return date.toLocal();
  }

  static T _enumByName<T extends Enum>(
    Iterable<T> values,
    Object? value,
    T fallback,
  ) {
    if (value is String) {
      for (final item in values) {
        if (item.name == value) return item;
      }
    }
    return fallback;
  }
}
