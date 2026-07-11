import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:arini_plus_app/core/constants/supabase_tables.dart';

class AppVersion {
  final String platform;
  final String minimumVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String? storeUrl;
  final int minimumBuild;
  final int latestBuild;

  AppVersion({
    required this.platform,
    required this.minimumVersion,
    required this.latestVersion,
    required this.forceUpdate,
    this.storeUrl,
    required this.minimumBuild,
    required this.latestBuild,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      platform: json['platform']?.toString() ?? '',
      minimumVersion: json['minimum_version']?.toString() ?? '',
      latestVersion: json['latest_version']?.toString() ?? '',
      forceUpdate: json['force_update'] == true,
      storeUrl: json['store_url']?.toString(),
      minimumBuild: json['minimum_build'] is int
          ? json['minimum_build'] as int
          : int.tryParse(json['minimum_build']?.toString() ?? '') ?? 0,
      latestBuild: json['latest_build'] is int
          ? json['latest_build'] as int
          : int.tryParse(json['latest_build']?.toString() ?? '') ?? 0,
    );
  }
}

class UpdateService {
  UpdateService._();

  static bool _checked = false;

  /// Returns [AppVersion] if a force update is needed, null otherwise.
  static Future<AppVersion?> check({
    required String currentVersion,
    required int currentBuild,
    required String platform,
  }) async {
    if (_checked) return null;
    _checked = true;

    try {
      final response = await Supabase.instance.client
          .from(SupabaseTables.appVersions)
          .select()
          .eq('platform', platform)
          .maybeSingle();

      if (response == null) {
        debugPrint('UpdateService: no row found for platform $platform');
        return null;
      }

      final appVersion = AppVersion.fromJson(response);

      if (!appVersion.forceUpdate) {
        debugPrint('UpdateService: force_update is false');
        return null;
      }

      if (platform == 'android' &&
          (appVersion.storeUrl == null || appVersion.storeUrl!.isEmpty)) {
        debugPrint('UpdateService: store_url empty on Android, skipping');
        return null;
      }

      if (_needsUpdate(
          currentVersion, currentBuild, appVersion.minimumVersion,
          appVersion.minimumBuild)) {
        return appVersion;
      }
    } catch (e) {
      debugPrint('UpdateService error: $e');
    }

    return null;
  }

  static bool _needsUpdate(String currentVersion, int currentBuild,
      String minimumVersion, int minimumBuild) {
    final cmp = _compareVersion(currentVersion, minimumVersion);
    if (cmp < 0) return true;
    if (cmp == 0 && currentBuild < minimumBuild) return true;
    return false;
  }

  static int _compareVersion(String a, String b) {
    final partsA = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final partsB = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final len = partsA.length > partsB.length
        ? partsA.length
        : partsB.length;
    for (var i = 0; i < len; i++) {
      final pa = i < partsA.length ? partsA[i] : 0;
      final pb = i < partsB.length ? partsB[i] : 0;
      if (pa < pb) return -1;
      if (pa > pb) return 1;
    }
    return 0;
  }
}
