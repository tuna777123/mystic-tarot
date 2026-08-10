import 'package:flutter_test/flutter_test.dart';

import '../tool/src/android_bundle_audit.dart';

void main() {
  test('locks the Google Play native-library bundle alignment to 16 KB', () {
    expect(requiredGooglePlayPageAlignment, 'PAGE_ALIGNMENT_16K');
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
}
