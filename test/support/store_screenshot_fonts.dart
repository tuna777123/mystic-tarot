import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> loadStoreScreenshotFonts() async {
  final materialFontDirectory = _flutterMaterialFontDirectory();
  final roboto = File('${materialFontDirectory.path}/Roboto-Regular.ttf');
  final materialIcons = File(
    '${materialFontDirectory.path}/MaterialIcons-Regular.otf',
  );

  if (!roboto.existsSync()) {
    throw StateError('Roboto font not found at ${roboto.path}.');
  }
  if (!materialIcons.existsSync()) {
    throw StateError('Material Icons font not found at ${materialIcons.path}.');
  }

  final robotoBytes = await roboto.readAsBytes();
  await _loadFontFamily('Roboto', robotoBytes);
  await _loadFontFamily('Arial', robotoBytes);
  await _loadFontFamily('MaterialIcons', await materialIcons.readAsBytes());
}

void verifyStoreScreenshotFonts() {
  for (final family in const <String>['Roboto', 'Arial']) {
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

Future<void> _loadFontFamily(String family, Uint8List bytes) async {
  final loader = FontLoader(family)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
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
