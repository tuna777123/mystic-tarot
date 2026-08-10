import 'package:flutter_test/flutter_test.dart';

import '../tool/src/android_bundle_audit.dart';

void main() {
  test('locks the Google Play native-library bundle alignment to 16 KB', () {
    expect(requiredGooglePlayPageAlignment, 'PAGE_ALIGNMENT_16K');
    expect(minimumGooglePlayElfLoadAlignmentBytes, 16 * 1024);
  });

  test('accepts bundletool config requesting 16 KB page alignment', () {
    expect(
      validateGooglePlayPageAlignment('''
compression {
  install_time_asset_module_default_compression: COMPRESSED
}
optimizations {
  uncompress_native_libraries {
    enabled: true
    alignment: PAGE_ALIGNMENT_16K
  }
}
'''),
      'PAGE_ALIGNMENT_16K',
    );
  });

  test('rejects legacy 4 KB page alignment', () {
    expect(
      () => validateGooglePlayPageAlignment('''
optimizations {
  uncompress_native_libraries {
    enabled: true
    alignment: PAGE_ALIGNMENT_4K
  }
}
'''),
      throwsA(isA<AuditFailure>()),
    );
  });

  test('rejects missing page-alignment evidence', () {
    expect(
      () => validateGooglePlayPageAlignment('''
optimizations {
  uncompress_native_libraries {
    enabled: true
  }
}
'''),
      throwsA(isA<AuditFailure>()),
    );
  });

  test('rejects ambiguous config containing both 16 KB and 4 KB values', () {
    expect(
      () => validateGooglePlayPageAlignment('''
alignment: PAGE_ALIGNMENT_16K
legacy_alignment: PAGE_ALIGNMENT_4K
'''),
      throwsA(isA<AuditFailure>()),
    );
  });

  test('rejects a lookalike value instead of exact 16 KB alignment', () {
    expect(
      () => validateGooglePlayPageAlignment(
        'alignment: PAGE_ALIGNMENT_16K_COMPAT',
      ),
      throwsA(isA<AuditFailure>()),
    );
  });

  test('parses and accepts 16 KB ELF LOAD program-header alignment', () {
    const output = '''
Elf file type is DYN (Shared object file)
Program Headers:
  Type           Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   Flg Align
  LOAD           0x000000 0x0000000000000000 0x0000000000000000 0x001000 0x001000 R E 0x4000
  LOAD           0x004000 0x0000000000004000 0x0000000000004000 0x002000 0x002000 RW  0x10000
''';

    expect(parseElfLoadAlignments(output), <int>[0x4000, 0x10000]);
    expect(
      () => validateGooglePlayElfLoadAlignment(
        output,
        label: 'base/lib/arm64-v8a/libapp.so',
      ),
      returnsNormally,
    );
  });

  test('rejects a 4 KB ELF LOAD program-header segment', () {
    const output = '''
Program Headers:
  Type           Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   Flg Align
  LOAD           0x000000 0x0000000000000000 0x0000000000000000 0x001000 0x001000 R E 0x1000
  LOAD           0x004000 0x0000000000004000 0x0000000000004000 0x002000 0x002000 RW  0x4000
''';

    expect(
      () => validateGooglePlayElfLoadAlignment(
        output,
        label: 'base/lib/x86_64/libapp.so',
      ),
      throwsA(isA<AuditFailure>()),
    );
  });

  test('rejects ELF output without LOAD segments', () {
    expect(
      () => parseElfLoadAlignments('There are no program headers.'),
      throwsA(isA<AuditFailure>()),
    );
  });
}
