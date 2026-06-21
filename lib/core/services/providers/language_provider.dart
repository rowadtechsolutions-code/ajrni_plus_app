import 'package:flutter/foundation.dart';

import '../../enums/enums.dart';
import '../cache/app_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String language = 'ar';

  void loadSavedLanguage() {
    final savedLanguage =
        AppPreferences().getter(CacheKeys.language) as String?;
    if (savedLanguage == null || savedLanguage == language) return;
    language = savedLanguage;
    notifyListeners();
  }

  Future<void> changeLanguage() async {
    language = language == 'ar' ? 'en' : 'ar';
    await AppPreferences().setter(CacheKeys.language, language);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    language = lang;
    await AppPreferences().setter(CacheKeys.language, lang);
    notifyListeners();
  }
}
