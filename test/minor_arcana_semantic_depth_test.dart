import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/minor_arcana_semantics.dart';

import '../tool/materialize_minor_arcana_semantic_depth.dart';

void main() {
  const launchCodes = <String>['EN', 'TR', 'ES', 'FR', 'PT-BR'];

  test('all 56 Minor Arcana have authored semantics in every launch language', () {
    expect(minorArcanaSemanticsEnglish, hasLength(56));
    final cardNames = minorArcanaSemanticsEnglish.keys.toSet();

    for (final code in launchCodes) {
      final lights = <String>{};
      final shadows = <String>{};
      final actions = <String>{};
      for (final cardName in cardNames) {
        final semantic = minorArcanaSemantic(cardName, code);
        expect(semantic, isNotNull, reason: '$code: $cardName');
        expect(semantic, hasLength(3), reason: '$code: $cardName');
        expect(semantic![0].length, greaterThan(70), reason: '$code light: $cardName');
        expect(semantic[1].length, greaterThan(70), reason: '$code shadow: $cardName');
        expect(semantic[2].length, greaterThan(45), reason: '$code action: $cardName');
        lights.add(semantic[0]);
        shadows.add(semantic[1]);
        actions.add(semantic[2]);
      }

      expect(lights, hasLength(56), reason: '$code upright meanings repeat');
      expect(shadows, hasLength(56), reason: '$code shadow meanings repeat');
      expect(actions, hasLength(56), reason: '$code actions repeat');
    }
  });

  test('same rank no longer collapses into one generic cross-suit meaning', () {
    for (final code in launchCodes) {
      final wandAce = minorArcanaSemantic('Ace of Wands', code)!;
      final cupAce = minorArcanaSemantic('Ace of Cups', code)!;
      final swordAce = minorArcanaSemantic('Ace of Swords', code)!;
      final pentacleAce = minorArcanaSemantic('Ace of Pentacles', code)!;

      expect(
        {wandAce[0], cupAce[0], swordAce[0], pentacleAce[0]},
        hasLength(4),
        reason: '$code Ace meanings must be card-specific',
      );
      expect(
        {wandAce[1], cupAce[1], swordAce[1], pentacleAce[1]},
        hasLength(4),
        reason: '$code Ace shadows must be card-specific',
      );
      expect(
        {wandAce[2], cupAce[2], swordAce[2], pentacleAce[2]},
        hasLength(4),
        reason: '$code Ace actions must be card-specific',
      );
    }
  });

  test('representative cards preserve their actual reflective distinctions', () {
    expect(
      minorArcanaSemantic('Ten of Wands', 'EN')![0],
      contains('heavy load'),
    );
    expect(
      minorArcanaSemantic('Five of Cups', 'TR')![0],
      contains('Kayıp'),
    );
    expect(
      minorArcanaSemantic('Seven of Swords', 'ES')![1],
      contains('engaño'),
    );
    expect(
      minorArcanaSemantic('Eight of Swords', 'FR')![0],
      contains('limites'),
    );
    expect(
      minorArcanaSemantic('Three of Pentacles', 'PT-BR')![0],
      contains('habilidade'),
    );
    expect(
      minorArcanaSemanticsEnglish.values
          .expand((semantic) => semantic)
          .contains(
            'The same energy may be blocked, exaggerated, or seeking approval instead of alignment.',
          ),
      isFalse,
    );
  });

  test('deck materializer replaces the generic rank plus suit generator', () {
    final source = File('lib/src/tarot_data.dart').readAsStringSync();
    final transformed = materializeTarotDataSemanticDepth(source);

    expect(transformed, contains("minorArcanaSemantic(name, 'EN')"));
    expect(transformed, contains('Missing authored Minor Arcana semantics'));
    expect(
      transformed,
      isNot(contains('The same energy may be blocked, exaggerated')),
    );
    expect(materializeTarotDataSemanticDepth(transformed), transformed);
  });

  test('localization materializer routes launch languages to card semantics', () {
    final source = File('lib/src/tarot_localization.dart').readAsStringSync();
    final transformed = materializeTarotLocalizationSemanticDepth(source);

    expect(
      'minorArcanaSemantic(drawn.card.name, code)'.allMatches(transformed),
      hasLength(2),
    );
    expect(transformed, contains('if (semantic != null) return semantic[2];'));
    expect(
      materializeTarotLocalizationSemanticDepth(transformed),
      transformed,
    );
  });

  test('verified build chain always applies Minor Arcana semantic depth', () {
    final source = File(
      'tool/materialize_result_core_loop.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        "import 'materialize_minor_arcana_semantic_depth.dart' as minor_arcana_semantics;",
      ),
    );
    expect(
      source,
      contains('minor_arcana_semantics.materializeMinorArcanaSemanticDepth();'),
    );
  });

  test('semantic materializers fail closed when source anchors disappear', () {
    expect(
      () => materializeTarotDataSemanticDepth('unknown tarot source'),
      throwsStateError,
    );
    expect(
      () => materializeTarotLocalizationSemanticDepth(
        "import 'models.dart';\nunknown localization source",
      ),
      throwsStateError,
    );
  });
}
