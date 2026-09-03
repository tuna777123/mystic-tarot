import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/materialize_result_core_loop.dart' as result_core_loop;

void main() {
  test('foregrounds the 24h evidence loop before secondary result features', () {
    final source = File('lib/src/app.dart').readAsStringSync();
    final materialized = result_core_loop.materializeResultCoreLoopInSource(
      source,
    );

    final guidance = materialized.indexOf('✦  YOUR GUIDANCE');
    final loop = materialized.indexOf('MYSTIC MIRROR • 24H LOOP');
    final save = materialized.indexOf('Save this reading');
    final memory = materialized.indexOf('_memoryBridge(context)');
    final oracle = materialized.indexOf('_oracleInvitation(context, record)');

    expect(guidance, greaterThanOrEqualTo(0));
    expect(guidance, lessThan(loop));
    expect(loop, lessThan(save));
    expect(save, lessThan(memory));
    expect(memory, lessThan(oracle));
  });

  test('materialization is idempotent', () {
    final source = File('lib/src/app.dart').readAsStringSync();
    final once = result_core_loop.materializeResultCoreLoopInSource(source);
    final twice = result_core_loop.materializeResultCoreLoopInSource(once);

    expect(twice, once);
  });

  test('unknown hierarchy fails closed', () {
    final source = File('lib/src/app.dart').readAsStringSync().replaceFirst(
      '_oracleInvitation(context, record),',
      '_unexpectedOracleInvitation(context, record),',
    );

    expect(
      () => result_core_loop.materializeResultCoreLoopInSource(source),
      throwsStateError,
    );
  });

  test('production release materializer wires the result hierarchy pass', () {
    final source = File('tool/configure_store_identifiers.dart').readAsStringSync();

    expect(
      source,
      contains(
        "import 'materialize_result_core_loop.dart' as result_core_loop;",
      ),
    );
    expect(
      source,
      contains('result_core_loop.materializeResultCoreLoop();'),
    );
  });
}
