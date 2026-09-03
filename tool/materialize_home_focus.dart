import 'dart:io';

void main() => materializeHomeFocus();

/// Makes the retention-critical next step the only Home priority during the
/// first loop and whenever a Mystic Mirror is due.
///
/// The historical source keeps the complete discovery layout. Production
/// builds apply this deterministic transform after the ads-only materializer so
/// breadth is progressively disclosed without risking the established source
/// scaffold.
void materializeHomeFocus() {
  final app = File('lib/src/app.dart');
  if (!app.existsSync()) {
    throw StateError('Mystic Tarot app source is missing.');
  }
  final transformed = materializeHomeFocusInSource(app.readAsStringSync());
  app.writeAsStringSync(transformed);
  stdout.writeln(
    'Home focus materialized: first-loop and due-Mirror states prioritize the '
    'next step; discovery breadth returns after the loop advances.',
  );
}

String materializeHomeFocusInSource(String source) {
  var result = _insertAfterRequired(
    source,
    "import 'growth_engine.dart';\n",
    "import 'home_focus_policy.dart';\n",
    'Home focus policy import',
  );

  result = _replaceRequired(
    result,
    '''    final growthSnapshot = const MysticGrowthEngine().analyze(
      records: records,
      streak: streak,
      completedArcanaDays: completedArcanaDays.length,
      freeReadingsLeft: freeReadingsLeft,
      mirrorDueCount: mirrorDueCount,
    );
    return MysticBackground(''',
    '''    final growthSnapshot = const MysticGrowthEngine().analyze(
      records: records,
      streak: streak,
      completedArcanaDays: completedArcanaDays.length,
      freeReadingsLeft: freeReadingsLeft,
      mirrorDueCount: mirrorDueCount,
    );
    final homeFocusMode = HomeFocusPolicy.shouldFocus(
      readingCount: records.length,
      mirrorDueCount: mirrorDueCount,
    );
    return MysticBackground(''',
    'Home focus runtime policy',
  );

  result = _replaceRequired(
    result,
    '''                const SizedBox(height: 14),
                _DailyCard(''',
    '''                if (!homeFocusMode) ...[
                  const SizedBox(height: 14),
                  _DailyCard(''',
    'Home focus discovery guard start',
  );

  result = _replaceRequired(
    result,
    '''                const SizedBox(height: 12),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),''',
    '''                  const SizedBox(height: 12),
                ],
              ]),
            ),
          ),
          if (!homeFocusMode)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),''',
    'Home focus discovery guard end and featured-reading guard',
  );

  result = _replaceRequired(
    result,
    '''          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),''',
    '''          if (!homeFocusMode)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),''',
    'Home focus deep-reading guard',
  );

  final policyIndex = result.indexOf('final homeFocusMode =');
  final nextStepIndex = result.indexOf('MysticNextStepCard(');
  final firstGuardIndex = result.indexOf('if (!homeFocusMode)');
  final guardCount = RegExp(r'if \(!homeFocusMode\)').allMatches(result).length;
  if (!result.contains("import 'home_focus_policy.dart';") ||
      policyIndex < 0 ||
      nextStepIndex < 0 ||
      firstGuardIndex < 0 ||
      nextStepIndex > firstGuardIndex ||
      guardCount != 3) {
    throw StateError('Home focus production wiring failed verification.');
  }
  return result;
}

String _replaceRequired(
  String source,
  String oldValue,
  String newValue,
  String label,
) {
  if (source.contains(oldValue)) {
    return source.replaceFirst(oldValue, newValue);
  }
  if (source.contains(newValue)) return source;
  throw StateError(
    'Unable to materialize $label: expected source anchor missing.',
  );
}

String _insertAfterRequired(
  String source,
  String anchor,
  String value,
  String label,
) {
  if (source.contains(value)) return source;
  final index = source.indexOf(anchor);
  if (index < 0) {
    throw StateError(
      'Unable to materialize $label: expected source anchor missing.',
    );
  }
  final insertionPoint = index + anchor.length;
  return source.replaceRange(insertionPoint, insertionPoint, value);
}
