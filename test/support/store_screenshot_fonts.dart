import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _storeScreenshotLatinFamilies = <String>['Roboto', 'Arial'];
const _storeScreenshotTarotFamily = 'TarotSymbols';
const _storeScreenshotTarotSymbols = <String>[
  '✦',
  '✶',
  '☽',
  '♌',
  '➶',
  '☾',
  '◎',
];

Future<void> loadStoreScreenshotFonts() async {
  final materialFontDirectory = _flutterMaterialFontDirectory();
  final roboto = File('${materialFontDirectory.path}/Roboto-Regular.ttf');
  final materialIcons = File(
    '${materialFontDirectory.path}/MaterialIcons-Regular.otf',
  );
  final tarotSymbols = _storeScreenshotSymbolFont();

  if (!roboto.existsSync()) {
    throw StateError('Roboto font not found at ${roboto.path}.');
  }
  if (!materialIcons.existsSync()) {
    throw StateError('Material Icons font not found at ${materialIcons.path}.');
  }
  if (!tarotSymbols.existsSync()) {
    throw StateError('Tarot symbol font not found at ${tarotSymbols.path}.');
  }

  final robotoBytes = await roboto.readAsBytes();
  final tarotSymbolBytes = await tarotSymbols.readAsBytes();
  await _loadFontFamily('Roboto', <Uint8List>[robotoBytes]);
  await _loadFontFamily('Arial', <Uint8List>[robotoBytes]);
  await _loadFontFamily('Georgia', <Uint8List>[tarotSymbolBytes]);
  await _loadFontFamily(_storeScreenshotTarotFamily, <Uint8List>[
    tarotSymbolBytes,
  ]);
  await _loadFontFamily('MaterialIcons', <Uint8List>[
    await materialIcons.readAsBytes(),
  ]);
}

void verifyStoreScreenshotFonts() {
  for (final family in _storeScreenshotLatinFamilies) {
    final narrow = _widthOf('iiiiiiii', family: family);
    final wide = _widthOf('WWWWWWWW', family: family);
    if (wide <= narrow * 1.5) {
      throw StateError(
        '$family must not fall back to Flutter test Ahem squares.',
      );
    }
    if (_widthOf('ĞİŞÇÖÜ éèñãç', family: family) <= 0) {
      throw StateError('$family must render launch-language accents.');
    }
  }

  final symbolWidths = <String>{
    for (final symbol in _storeScreenshotTarotSymbols)
      _widthOf(symbol, family: _storeScreenshotTarotFamily).toStringAsFixed(2),
  };
  if (symbolWidths.length < 3) {
    throw StateError(
      'TarotSymbols glyphs must not collapse to one missing-glyph box.',
    );
  }
}

Directory _flutterMaterialFontDirectory() {
  final configuredRoot = Platform.environment['FLUTTER_ROOT'];
  if (configuredRoot != null && configuredRoot.trim().isNotEmpty) {
    return Directory('$configuredRoot/bin/cache/artifacts/material_fonts');
  }

  var flutterRoot = File(Platform.resolvedExecutable).parent;
  for (var depth = 0; depth < 4; depth++) {
    flutterRoot = flutterRoot.parent;
  }
  return Directory('${flutterRoot.path}/bin/cache/artifacts/material_fonts');
}

File _storeScreenshotSymbolFont() {
  final configuredPath = Platform.environment['STORE_SCREENSHOT_SYMBOL_FONT'];
  if (configuredPath != null && configuredPath.trim().isNotEmpty) {
    return File(configuredPath);
  }

  for (final path in const <String>[
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    '/usr/share/fonts/dejavu/DejaVuSans.ttf',
  ]) {
    final file = File(path);
    if (file.existsSync()) return file;
  }

  return File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf');
}

Future<void> _loadFontFamily(String family, List<Uint8List> fonts) async {
  final loader = FontLoader(family);
  for (final bytes in fonts) {
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

double _widthOf(String text, {required String family}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontFamily: family, fontSize: 32),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}
