import 'dart:convert';
import 'dart:typed_data';

class AuditFailure implements Exception {
  const AuditFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class PubspecVersion {
  const PubspecVersion({required this.name, required this.code});

  final String name;
  final int code;

  static PubspecVersion parse(String source) {
    final match = RegExp(
      r'^version:\s*([^\s+]+)\+(\d+)\s*$',
      multiLine: true,
    ).firstMatch(source);
    if (match == null) {
      throw const AuditFailure('pubspec.yaml has no strict version name+code.');
    }
    return PubspecVersion(
      name: match.group(1)!,
      code: int.parse(match.group(2)!),
    );
  }
}

class ManifestSnapshot {
  const ManifestSnapshot({
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.permissions,
  });

  final String packageName;
  final String versionName;
  final int versionCode;
  final Set<String> permissions;

  static ManifestSnapshot parse(String xml) {
    final manifestTag = RegExp(r'<manifest\b[^>]*>').firstMatch(xml)?.group(0);
    if (manifestTag == null) {
      throw const AuditFailure('bundletool did not return a manifest element.');
    }

    String requiredAttribute(String name) {
      final value = RegExp(
        '${RegExp.escape(name)}="([^"]+)"',
      ).firstMatch(manifestTag)?.group(1);
      if (value == null || value.isEmpty) {
        throw AuditFailure('Manifest is missing $name.');
      }
      return value;
    }

    final permissionPattern = RegExp(
      r'<uses-permission(?:-sdk-\d+)?\b[^>]*android:name="([^"]+)"',
    );
    final permissions = permissionPattern
        .allMatches(xml)
        .map((match) => match.group(1)!)
        .toSet();

    return ManifestSnapshot(
      packageName: requiredAttribute('package'),
      versionName: requiredAttribute('android:versionName'),
      versionCode: int.parse(requiredAttribute('android:versionCode')),
      permissions: permissions,
    );
  }
}

const requiredAndroidAbis = <String>{'arm64-v8a', 'armeabi-v7a', 'x86_64'};

const forbiddenAndroidPermissions = <String>{
  'com.google.android.gms.permission.AD_ID',
  'android.permission.ACCESS_ADSERVICES_AD_ID',
  'android.permission.ACCESS_ADSERVICES_ATTRIBUTION',
  'android.permission.ACCESS_ADSERVICES_TOPICS',
  'android.permission.ACCESS_FINE_LOCATION',
  'android.permission.ACCESS_COARSE_LOCATION',
  'android.permission.ACCESS_BACKGROUND_LOCATION',
  'android.permission.CAMERA',
  'android.permission.RECORD_AUDIO',
  'android.permission.READ_CONTACTS',
  'android.permission.WRITE_CONTACTS',
  'android.permission.GET_ACCOUNTS',
  'android.permission.READ_CALENDAR',
  'android.permission.WRITE_CALENDAR',
  'android.permission.READ_SMS',
  'android.permission.RECEIVE_SMS',
  'android.permission.SEND_SMS',
  'android.permission.READ_PHONE_STATE',
  'android.permission.READ_PHONE_NUMBERS',
  'android.permission.CALL_PHONE',
  'android.permission.ANSWER_PHONE_CALLS',
  'android.permission.READ_EXTERNAL_STORAGE',
  'android.permission.WRITE_EXTERNAL_STORAGE',
  'android.permission.MANAGE_EXTERNAL_STORAGE',
  'android.permission.READ_MEDIA_AUDIO',
  'android.permission.READ_MEDIA_IMAGES',
  'android.permission.READ_MEDIA_VIDEO',
  'android.permission.ACTIVITY_RECOGNITION',
  'android.permission.BODY_SENSORS',
  'android.permission.BODY_SENSORS_BACKGROUND',
  'android.permission.BLUETOOTH_SCAN',
  'android.permission.BLUETOOTH_ADVERTISE',
  'android.permission.BLUETOOTH_CONNECT',
  'android.permission.NEARBY_WIFI_DEVICES',
  'android.permission.QUERY_ALL_PACKAGES',
  'android.permission.PACKAGE_USAGE_STATS',
  'android.permission.REQUEST_INSTALL_PACKAGES',
  'android.permission.SYSTEM_ALERT_WINDOW',
  'android.permission.INSTALL_PACKAGES',
  'android.permission.BIND_ACCESSIBILITY_SERVICE',
};

const forbiddenDexClassMarkers = <String>{
  'Lcom/appsflyer/',
  'Lcom/onesignal/',
  'Lcom/mixpanel/',
  'Lcom/amplitude/',
  'Lcom/facebook/appevents/',
  'Lcom/adjust/sdk/',
  'Lcom/google/firebase/analytics/',
  'Lcom/google/android/gms/ads/identifier/',
  'Lio/sentry/',
};

Set<String> parseAndroidAbis(Iterable<String> bundleEntries) {
  final pattern = RegExp(r'^base/lib/([^/]+)/[^/]+\.so$');
  final result = <String>{};
  for (final entry in bundleEntries) {
    final match = pattern.firstMatch(entry);
    if (match != null) {
      result.add(match.group(1)!);
    }
  }
  return result;
}

Set<String> findForbiddenPermissions(Set<String> permissions) {
  return permissions.intersection(forbiddenAndroidPermissions);
}

Set<String> findForbiddenDexMarkers(Uint8List bytes) {
  return {
    for (final marker in forbiddenDexClassMarkers)
      if (containsAsciiSequence(bytes, marker)) marker,
  };
}

bool containsAsciiSequence(Uint8List bytes, String marker) {
  final needle = ascii.encode(marker);
  if (needle.isEmpty || needle.length > bytes.length) {
    return false;
  }

  final lastStart = bytes.length - needle.length;
  for (var start = 0; start <= lastStart; start++) {
    var matches = true;
    for (var index = 0; index < needle.length; index++) {
      if (bytes[start + index] != needle[index]) {
        matches = false;
        break;
      }
    }
    if (matches) {
      return true;
    }
  }
  return false;
}

String formatByteCount(int bytes) {
  const mebibyte = 1024 * 1024;
  return '${(bytes / mebibyte).toStringAsFixed(2)} MiB';
}
