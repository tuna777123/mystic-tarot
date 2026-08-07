import 'dart:convert';

import 'mystic_journey.dart';

class JourneyDecodeReport {
  const JourneyDecodeReport({
    required this.journeys,
    required this.schemaVersion,
    required this.rejectedItems,
  });

  final List<MysticJourney> journeys;
  final int schemaVersion;
  final int rejectedItems;
}

/// Versioned, defensive serialization for the local-first Journey feature.
///
/// Invalid records are rejected individually so one damaged item cannot make
/// the user's entire journal unreadable. Unknown enum values fall back to safe
/// defaults to keep future migrations backwards compatible.
abstract final class MysticJourneyCodec {
  static const int schemaVersion = 1;

  static String encode(Iterable<MysticJourney> journeys) {
    final ordered = journeys.toList(growable: false)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return jsonEncode({
      'schemaVersion': schemaVersion,
      'journeys': ordered.map(_encodeJourney).toList(growable: false),
    });
  }

  static JourneyDecodeReport decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Journey payload must be a JSON object.');
    }

    final root = Map<String, dynamic>.from(decoded);
    final version = root['schemaVersion'];
    if (version is! int || version < 1 || version > schemaVersion) {
      throw FormatException('Unsupported journey schema version: $version');
    }

    final items = root['journeys'];
    if (items is! List) {
      throw const FormatException('Journey payload is missing its item list.');
    }

    final journeys = <MysticJourney>[];
    final journeyIds = <String>{};
    var rejected = 0;

    for (final item in items) {
      try {
        if (item is! Map) throw const FormatException('Invalid journey item.');
        final journey = _decodeJourney(Map<String, dynamic>.from(item));
        if (!journeyIds.add(journey.id)) {
          rejected++;
          continue;
        }
        journeys.add(journey);
      } on Object {
        rejected++;
      }
    }

    journeys.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return JourneyDecodeReport(
      journeys: List.unmodifiable(journeys),
      schemaVersion: version,
      rejectedItems: rejected,
    );
  }

  static Map<String, Object?> _encodeJourney(MysticJourney journey) => {
    'id': journey.id,
    'title': journey.title,
    'area': journey.area.name,
    'createdAt': journey.createdAt.toUtc().toIso8601String(),
    'status': journey.status.name,
    'intention': journey.intention,
    'targetDate': journey.targetDate?.toUtc().toIso8601String(),
    'entries': journey.entries.map(_encodeEntry).toList(growable: false),
  };

  static Map<String, Object?> _encodeEntry(JourneyEntry entry) => {
    'id': entry.id,
    'createdAt': entry.createdAt.toUtc().toIso8601String(),
    'title': entry.title,
    'readingId': entry.readingId,
    'reflection': entry.reflection,
    'mood': entry.mood,
    'tags': (entry.tags.toList()..sort()),
  };

  static MysticJourney _decodeJourney(Map<String, dynamic> value) {
    final id = _requiredText(value['id'], 'journey.id');
    final title = _requiredText(value['title'], 'journey.title');
    final createdAt = _requiredDate(value['createdAt'], 'journey.createdAt');
    final entriesValue = value['entries'];
    if (entriesValue is! List) {
      throw const FormatException('journey.entries must be a list.');
    }

    final entries = <JourneyEntry>[];
    final entryIds = <String>{};
    for (final item in entriesValue) {
      try {
        if (item is! Map) continue;
        final entry = _decodeEntry(Map<String, dynamic>.from(item));
        if (entryIds.add(entry.id)) entries.add(entry);
      } on Object {
        continue;
      }
    }
    entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return MysticJourney(
      id: id,
      title: title,
      area: _enumByName(JourneyArea.values, value['area'], JourneyArea.custom),
      createdAt: createdAt,
      status: _enumByName(
        JourneyStatus.values,
        value['status'],
        JourneyStatus.active,
      ),
      intention: _optionalText(value['intention']),
      targetDate: _optionalDate(value['targetDate']),
      entries: List.unmodifiable(entries),
    );
  }

  static JourneyEntry _decodeEntry(Map<String, dynamic> value) {
    final tagsValue = value['tags'];
    final tags = tagsValue is List
        ? tagsValue
              .whereType<String>()
              .map((tag) => tag.trim().toLowerCase())
              .where((tag) => tag.isNotEmpty)
              .toSet()
        : <String>{};

    return JourneyEntry(
      id: _requiredText(value['id'], 'entry.id'),
      createdAt: _requiredDate(value['createdAt'], 'entry.createdAt'),
      title: _requiredText(value['title'], 'entry.title'),
      readingId: _optionalText(value['readingId']),
      reflection: _optionalText(value['reflection']),
      mood: _optionalText(value['mood']),
      tags: Set.unmodifiable(tags),
    );
  }

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
    final date = _optionalDate(value);
    if (date == null) throw FormatException('$field is invalid.');
    return date;
  }

  static DateTime? _optionalDate(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
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
