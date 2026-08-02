import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/src/mystic_search.dart';

void main() {
  test('Turkish characters match their keyboard-friendly equivalents', () {
    expect(normalizeMysticSearch('Aşk ve İçgörü'), 'ask ve icgoru');
    expect(
      mysticSearchMatches(query: 'ask', values: <String>['Aşk ve Bağ']),
      isTrue,
    );
    expect(
      mysticSearchMatches(query: 'icgoru', values: <String>['İçgörü']),
      isTrue,
    );
  });

  test('French accents and ligatures do not block discovery', () {
    expect(normalizeMysticSearch('Réflexion du cœur'), 'reflexion du coeur');
    expect(
      mysticSearchMatches(
        query: 'reflexion coeur',
        values: <String>['Réflexion du cœur'],
      ),
      isTrue,
    );
  });

  test('Spanish and Portuguese accents remain searchable', () {
    expect(
      mysticSearchMatches(
        query: 'proposito sanacion',
        values: <String>['Propósito', 'Sanación'],
      ),
      isTrue,
    );
    expect(
      mysticSearchMatches(
        query: 'mudanca coracao',
        values: <String>['Mudança no coração'],
      ),
      isTrue,
    );
  });

  test('punctuation and repeated spaces are normalized consistently', () {
    expect(normalizeMysticSearch('  The—Star:  Hope! '), 'the star hope');
  });

  test('empty normalized query keeps the complete timeline visible', () {
    expect(
      mysticSearchMatches(query: '---', values: <String>['Any reading']),
      isTrue,
    );
  });

  test('unrelated content still does not match', () {
    expect(
      mysticSearchMatches(
        query: 'career',
        values: <String>['Aşk', 'Kalp', 'İlişki'],
      ),
      isFalse,
    );
  });
}
