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

  late SharedPreferences sharedPreferences;

  Future<void> get initCache async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  /// DATA

  Future<void> setter(CacheKeys key, dynamic value) async {
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

  dynamic getter(CacheKeys key) => sharedPreferences.get(key.name);

  Future<void> remove(CacheKeys key) async {
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
