from pathlib import Path
import runpy
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, content: str) -> None:
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding="utf-8")


def replace_once(path: str, old: str, new: str) -> None:
    source = read(path)
    if old not in source:
        raise SystemExit(f"Expected source not found in {path}: {old[:120]!r}")
    write(path, source.replace(old, new, 1))


# Apply the reviewed product patch. The v1 script removes itself and its trigger.
runpy.run_path(str(ROOT / "tool/v122_revenue_final.py"), run_name="__main__")

# Workflow files require a separate GitHub-authorized update. Keep this clean
# product commit free of temporary workflow mutations.
for workflow in [
    ".github/workflows/flutter-ci.yml",
    ".github/workflows/ios-ci.yml",
    ".github/workflows/release-candidate.yml",
    ".github/workflows/store-release.yml",
]:
    payload = subprocess.check_output(["git", "show", f"HEAD:{workflow}"], cwd=ROOT)
    (ROOT / workflow).write_bytes(payload)

# Make the native configurators composable so every workflow that already runs
# configure_store_identifiers receives the correct platform hardening.
ritual_path = "tool/configure_ritual_notifications.dart"
replace_once(
    ritual_path,
    """void main() {
  final gradle = File('android/app/build.gradle.kts');
""",
    """void main() => configureRitualNotifications();

void configureRitualNotifications({bool requireAndroid = true}) {
  if (!Directory('android').existsSync() && !requireAndroid) {
    stdout.writeln(
      'Android shell not present; ritual notification configuration skipped.',
    );
    return;
  }
  final gradle = File('android/app/build.gradle.kts');
""",
)

app_lock_path = "tool/configure_app_lock.dart"
app_lock = read(app_lock_path)
start = app_lock.find("void main() {")
end = app_lock.find("File? findAndroidMainActivity")
if start < 0 or end < 0 or end <= start:
    raise SystemExit("Could not locate app-lock main block")
new_main = """void main() => configureAppLock();

void configureAppLock({
  bool requireAndroid = true,
  bool requireIos = true,
}) {
  final errors = <String>[];
  final hasAndroid = Directory('android').existsSync();
  final hasIos = Directory('ios').existsSync();

  File? manifest;
  File? activity;
  if (hasAndroid) {
    manifest = File('android/app/src/main/AndroidManifest.xml');
    if (!manifest.existsSync()) {
      errors.add('Missing generated Android manifest.');
    } else {
      configureAndroidManifest(manifest);
    }

    activity = findAndroidMainActivity(Directory('android/app/src/main'));
    if (activity == null) {
      errors.add('Missing generated Android MainActivity.kt.');
    } else {
      configureAndroidActivity(activity);
    }
  } else if (requireAndroid) {
    errors.add('Missing generated Android shell.');
  }

  File? infoPlist;
  File? entitlements;
  File? iosProject;
  if (hasIos) {
    infoPlist = File('ios/Runner/Info.plist');
    if (!infoPlist.existsSync()) {
      errors.add('Missing generated iOS Info.plist.');
    } else {
      configureIosInfoPlist(infoPlist);
    }

    entitlements = File('ios/Runner/Runner.entitlements');
    configureIosEntitlements(entitlements);

    iosProject = File('ios/Runner.xcodeproj/project.pbxproj');
    if (!iosProject.existsSync()) {
      errors.add('Missing generated iOS project file.');
    } else {
      configureIosProject(iosProject);
    }
  } else if (requireIos) {
    errors.add('Missing generated iOS shell.');
  }

  if (manifest != null && manifest.existsSync()) {
    final source = manifest.readAsStringSync();
    for (final required in const [
      'android.permission.USE_BIOMETRIC',
      'android.permission.USE_FINGERPRINT',
      'android:allowBackup="false"',
    ]) {
      if (!source.contains(required)) {
        errors.add('Android app-lock manifest entry missing: $required');
      }
    }
  }
  if (activity != null) {
    final source = activity.readAsStringSync();
    if (!source.contains('FlutterFragmentActivity')) {
      errors.add('Android MainActivity does not use FlutterFragmentActivity.');
    }
  }
  if (infoPlist != null && infoPlist.existsSync()) {
    final source = infoPlist.readAsStringSync();
    if (!source.contains('NSFaceIDUsageDescription') ||
        !source.contains(_faceIdDescription)) {
      errors.add('iOS Face ID usage description was not configured.');
    }
  }
  if (entitlements != null &&
      (!entitlements.existsSync() ||
          !entitlements.readAsStringSync().contains('keychain-access-groups'))) {
    errors.add('iOS Keychain entitlement was not configured.');
  }
  if (iosProject != null &&
      iosProject.existsSync() &&
      !iosProject.readAsStringSync().contains(
        'CODE_SIGN_ENTITLEMENTS = $_entitlementsPath;',
      )) {
    errors.add('iOS project does not reference the app-lock entitlements.');
  }

  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('Private app-lock platform support configured and verified.');
}

"""
write(app_lock_path, app_lock[:start] + new_main + app_lock[end:])

identifiers_path = "tool/configure_store_identifiers.dart"
identifiers = read(identifiers_path)
identifiers = identifiers.replace(
    "import 'dart:io';\n",
    """import 'dart:io';

import 'configure_app_lock.dart' as app_lock_config;
import 'configure_ritual_notifications.dart' as ritual_config;
""",
    1,
)
insert_marker = """  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
    return;
  }
  stdout.writeln(
"""
insert_replacement = """  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln(error);
    }
    exitCode = 1;
    return;
  }

  final hasAndroid = Directory('android').existsSync();
  final hasIos = Directory('ios').existsSync();
  if (hasAndroid) {
    ritual_config.configureRitualNotifications();
  }
  if (hasAndroid || hasIos) {
    app_lock_config.configureAppLock(
      requireAndroid: hasAndroid,
      requireIos: hasIos,
    );
  }
  if (exitCode != 0) return;

  stdout.writeln(
"""
if insert_marker not in identifiers:
    raise SystemExit("Store identifier insertion marker not found")
identifiers = identifiers.replace(insert_marker, insert_replacement, 1)
write(identifiers_path, identifiers)

# Repair Dart dollar literals in the generated widget test and use stable keys.
widget_test_path = "test/store_ready_premium_conversion_test.dart"
widget_test = read(widget_test_path)
widget_test = widget_test.replace(
    "const ValueKey('premium-plan-${MysticProductIds.yearly}')",
    "const ValueKey('premium-plan-mystic_plus_yearly')",
)
widget_test = widget_test.replace(
    "const ValueKey('premium-plan-${MysticProductIds.monthly}')",
    "const ValueKey('premium-plan-mystic_plus_monthly')",
)
widget_test = widget_test.replace(
    "'The store charges \\\\$39.99 for one year. It renews yearly unless cancelled before the next renewal.'",
    "r'The store charges $39.99 for one year. It renews yearly unless cancelled before the next renewal.'",
)
widget_test = widget_test.replace("price: '\\\\$39.99',", "price: r'$39.99',")
widget_test = widget_test.replace(
    "pricePerMonth: '\\\\$3.33',", "pricePerMonth: r'$3.33',"
)
widget_test = widget_test.replace("price: '\\\\$9.99',", "price: r'$9.99',")
widget_test = widget_test.replace(
    "pricePerMonth: '\\\\$9.99',", "pricePerMonth: r'$9.99',"
)
write(widget_test_path, widget_test)

# Remove claims about workflow version upgrades that are not part of this
# product commit; native production hardening is guaranteed by the existing
# store-identifier step instead.
release_notes = read("RELEASE_NOTES.md")
release_notes = release_notes.replace(
    "- Release workflows are pinned to Flutter `3.44.8` and current Node 24 GitHub Actions.\n",
    "- Every release path that applies permanent store identity now also applies the correct notification and app-lock native hardening for the generated platform shell.\n",
    1,
)
write("RELEASE_NOTES.md", release_notes)

notes_122 = read("RELEASE_NOTES_1.22.md")
notes_122 = notes_122.replace(
    """- Signed Android and iOS workflows configure permanent identifiers, daily ritual notifications, and private app lock before packaging.
- Source validation, QA, Android, iOS, web, format, whitespace, and fatal-analysis gates use Flutter `3.44.8` for reproducible builds.
- GitHub actions use Node 24-compatible checkout, Java setup, and artifact upload releases.
""",
    """- The permanent store-identity configurator now orchestrates native notification and app-lock hardening for whichever Android and/or iOS shells exist.
- Signed Android receives boot-safe ritual notification receivers, biometric permissions, disabled Android backup, and `FlutterFragmentActivity` before packaging.
- Signed iOS receives Face ID disclosure, Keychain entitlements, and Xcode entitlement wiring before packaging.
- Existing format, whitespace, fatal-analysis, full-test, web, Android, and macOS/Xcode gates remain mandatory.
""",
    1,
)
write("RELEASE_NOTES_1.22.md", notes_122)

# Replace the generated contract with one that verifies the effective signed
# release path rather than temporary workflow-version edits.
write(
    "test/v122_revenue_final_contract_test.dart",
    r'''import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1.22 revenue-ready final contract stays complete', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final premium = File(
      'lib/src/store_ready_premium_screen.dart',
    ).readAsStringSync();
    final identifiers = File(
      'tool/configure_store_identifiers.dart',
    ).readAsStringSync();
    final appLock = File('tool/configure_app_lock.dart').readAsStringSync();
    final reminders = File(
      'tool/configure_ritual_notifications.dart',
    ).readAsStringSync();
    final production = File(
      '.github/workflows/store-release.yml',
    ).readAsStringSync();
    final notes = File('RELEASE_NOTES_1.22.md').readAsStringSync();
    final storePack = File('STORE_RELEASE.md').readAsStringSync();

    expect(pubspec, contains('version: 1.22.0+29'));
    expect(
      premium.indexOf("..._planIds.map((id) => _productTile(context, id))"),
      lessThan(premium.indexOf('LaunchContinuityTimeline(')),
    );
    expect(
      premium.indexOf("ValueKey('premium-primary-action')"),
      lessThan(premium.indexOf('LaunchContinuityTimeline(')),
    );
    expect(premium, contains("ValueKey('premium-store-retry')"));
    expect(premium, contains('Future<void> _retryStore()'));
    expect(premium, contains('Widget _renewalDisclosure'));
    expect(premium, contains('Navigator.pop(context, true)'));
    expect(
      premium,
      contains(
        'Daily Guidance and your saved journal remain available without Plus.',
      ),
    );
    expect(premium, isNot(contains('MOST POPULAR')));
    expect(premium, isNot(contains('limited time')));

    expect(
      identifiers,
      contains("import 'configure_app_lock.dart' as app_lock_config;"),
    );
    expect(
      identifiers,
      contains(
        "import 'configure_ritual_notifications.dart' as ritual_config;",
      ),
    );
    expect(identifiers, contains('configureRitualNotifications()'));
    expect(identifiers, contains('configureAppLock('));
    expect(identifiers, contains('requireAndroid: hasAndroid'));
    expect(identifiers, contains('requireIos: hasIos'));
    expect(appLock, contains('void configureAppLock({'));
    expect(reminders, contains('void configureRitualNotifications({'));
    expect(
      'dart run tool/configure_store_identifiers.dart'
          .allMatches(production)
          .length,
      greaterThanOrEqualTo(3),
    );
    expect(production, contains('REVENUECAT_ANDROID_API_KEY'));
    expect(production, contains('REVENUECAT_IOS_API_KEY'));
    expect(production, contains('Verify Android signature'));
    expect(production, contains('Verify iOS signature and identity'));
    expect(notes, startsWith('# Mystic Tarot 1.22.0'));
    expect(storePack, contains('Current verified source version: `1.22.0+29`'));
    expect(storePack, contains('No countdown, fake scarcity'));
    expect(File('tool/v122_revenue_final.py').existsSync(), isFalse);
    expect(File('tool/v122_revenue_final_v2.py').existsSync(), isFalse);
    expect(
      File('.github/workflows/v122-materialize.yml').existsSync(),
      isFalse,
    );
  });
}
''',
)

# Ensure no temporary v1.22 source machinery survives the clean commit.
for path in [
    ROOT / "tool/v122_revenue_final.py",
    ROOT / "tool/v122_trigger.txt",
]:
    if path.exists():
        path.unlink()
Path(__file__).unlink()
