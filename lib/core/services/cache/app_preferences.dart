import 'package:arini_plus_app/core/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  /// SINGLETON

  AppPreferences._();

  static AppPreferences obj = AppPreferences._();

  factory AppPreferences() {
    return obj;
  }

  /// SHARED PREF.

  SharedPreferences? _sharedPreferences;
  Future<void>? _initialization;

  Future<void> get initCache {
    return _initialization ??= SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
    });
  }

  /// DATA

  Future<void> setter(CacheKeys key, dynamic value) async {
    await initCache;
    final sharedPreferences = _sharedPreferences!;
    if (value is String) {
      await sharedPreferences.setString(key.name, value);
    } else if (value is int) {
      await sharedPreferences.setInt(key.name, value);
    } else if (value is double) {
      await sharedPreferences.setDouble(key.name, value);
    } else if (value is bool) {
      await sharedPreferences.setBool(key.name, value);
    }
  }

  dynamic getter(CacheKeys key) => _sharedPreferences?.get(key.name);

  Future<void> remove(CacheKeys key) async {
    await initCache;
    final sharedPreferences = _sharedPreferences!;
    await sharedPreferences.remove(key.name);
  }

  Future<void> removeSession() async {
    for (final key in [
      CacheKeys.loggedIn,
      CacheKeys.id,
      CacheKeys.name,
      CacheKeys.email,
      CacheKeys.accountType,
      CacheKeys.guestMode,
    ]) {
      await remove(key);
    }
  }
}
