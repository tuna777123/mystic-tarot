import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Pages deployment verifies every public store and legal URL', () {
    final workflow = File('.github/workflows/pages.yml').readAsStringSync();

    expect(workflow, contains('health:'));
    expect(workflow, contains('needs: deploy'));
    expect(workflow, contains('Verify public store and legal URLs'));
    expect(workflow, contains(r'label="${path:-root}"'));
    expect(workflow, contains('--write-out \'%{http_code}\''));
    expect(workflow, contains(r'[[ "$code" == "200" ]]'));
    expect(workflow, contains("grep -qi '<html'"));
    expect(workflow, contains("grep -qi 'Mystic Tarot'"));
    expect(workflow, contains('for attempt in {1..10}'));

    for (final path in <String>[
      'privacy.html',
      'terms.html',
      'support.html',
      'privacy-tr.html',
      'terms-tr.html',
      'support-tr.html',
      'privacy-es.html',
      'terms-es.html',
      'support-es.html',
      'privacy-fr.html',
      'terms-fr.html',
      'support-fr.html',
      'privacy-pt-br.html',
      'terms-pt-br.html',
      'support-pt-br.html',
    ]) {
      expect(workflow, contains(path), reason: '$path must be health-checked');
    }

    expect(workflow, contains('needs: [build, deploy, health]'));
    expect(workflow, contains(r'HEALTH_RESULT: ${{ needs.health.result }}'));
    expect(
      workflow,
      contains(
        r'[[ "$DEPLOY_RESULT" == "success" && '
        r'"$HEALTH_RESULT" == "success" ]]',
      ),
    );
    expect(workflow, contains('Mystic Tarot Pages and public URLs are live'));
    expect(workflow, isNot(contains('continue-on-error')));
  });
}
