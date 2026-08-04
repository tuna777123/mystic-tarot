from pathlib import Path


def replace_once(source: str, old: str, new: str) -> str:
    count = source.count(old)
    if count != 1:
        raise RuntimeError(f'Expected exactly one occurrence, found {count}: {old[:80]}')
    return source.replace(old, new, 1)


path = Path('lib/src/reading_synthesis.dart')
source = path.read_text(encoding='utf-8')

replacements = {
    'One grounded experiment is to ${_lowerFirst(_sentence(card.advice))}':
        'Try this grounded action: ${_sentence(card.advice)}',
    'Un experimento concreto es ${_lowerFirst(_sentence(card.advice))}':
        'Prueba esta acción concreta: ${_sentence(card.advice)}',
    'Une expérience concrète consiste à ${_lowerFirst(_sentence(card.advice))}':
        'Essayez cette action concrète : ${_sentence(card.advice)}',
    'Um experimento concreto é ${_lowerFirst(_sentence(card.advice))}':
        'Experimente esta ação concreta: ${_sentence(card.advice)}',
    'Tek ve somut deney şu olabilir: ${_lowerFirst(_sentence(card.advice))}':
        'Şu somut eylemi dene: ${_sentence(card.advice)}',
    'One grounded experiment is to ${_lowerFirst(_sentence(second.advice))}':
        'Try this grounded action: ${_sentence(second.advice)}',
    'Un experimento concreto es ${_lowerFirst(_sentence(second.advice))}':
        'Prueba esta acción concreta: ${_sentence(second.advice)}',
    'Une expérience concrète consiste à ${_lowerFirst(_sentence(second.advice))}':
        'Essayez cette action concrète : ${_sentence(second.advice)}',
    'Um experimento concreto é ${_lowerFirst(_sentence(second.advice))}':
        'Experimente esta ação concreta: ${_sentence(second.advice)}',
    'Tek somut deney şu olabilir: ${_lowerFirst(_sentence(second.advice))}':
        'Şu somut eylemi dene: ${_sentence(second.advice)}',
}

for old, new in replacements.items():
    source = replace_once(source, old, new)

lower_first = '''\nString _lowerFirst(String value) {
  final text = value.trim();
  if (text.isEmpty) return text;
  return '${text[0].toLowerCase()}${text.substring(1)}';
}\n'''
source = replace_once(source, lower_first, '\n')
path.write_text(source, encoding='utf-8')
Path(__file__).unlink()
