import 'dart:io';

import '../lib/src/growth_evidence_aggregator.dart';

void main(List<String> args) {
  if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
    stdout.writeln(
      'Usage: dart run tool/aggregate_growth_evidence.dart '
      '--as-of=YYYY-MM-DD evidence1.json evidence2.json ...',
    );
    exitCode = args.isEmpty ? 64 : 0;
    return;
  }

  final asOfArg = args.where((arg) => arg.startsWith('--as-of=')).toList();
  if (asOfArg.length != 1) {
    stderr.writeln('Exactly one --as-of=YYYY-MM-DD argument is required.');
    exitCode = 64;
    return;
  }
  final asOf = DateTime.tryParse(asOfArg.single.substring('--as-of='.length));
  if (asOf == null) {
    stderr.writeln('Invalid --as-of date.');
    exitCode = 64;
    return;
  }

  final paths = args.where((arg) => !arg.startsWith('--')).toList();
  if (paths.isEmpty) {
    stderr.writeln('At least one Growth Evidence JSON file is required.');
    exitCode = 64;
    return;
  }

  try {
    final payloads = paths.map((path) {
      final file = File(path);
      if (!file.existsSync()) {
        throw StateError('Evidence file does not exist: $path');
      }
      return file.readAsStringSync();
    });
    final report = const MysticGrowthEvidenceAggregator().aggregateJson(
      payloads,
      asOf: asOf,
    );
    stdout.write(report.toMarkdown());
    if (!report.productScaleGatePassed) {
      stdout.writeln('\nCapital status: DO NOT SCALE.');
    } else {
      stdout.writeln(
        '\nCapital status: PRODUCT GATE PASSED. Unit economics and three consecutive mature cohorts are still required before material paid scaling.',
      );
    }
  } catch (error) {
    stderr.writeln('Growth evidence aggregation failed: $error');
    exitCode = 1;
  }
}
