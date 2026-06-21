class CountryCityData {
  static Map<String, List<String>> countries = {
    'SA': [
      'الرياض',
      'جدة',
      'مكة المكرمة',
      'المدينة المنورة',
      'الدمام',
      'الخبر',
      'تبوك',
      'أبها',
      'القصيم',
      'حائل',
      'جازان',
      'نجران',
      'الباحة',
      'الحدود الشمالية',
      'الطائف',
      'بريدة',
      'الهفوف',
      'ينبع',
    ],
    'AE': [
      'أبو ظبي',
      'دبي',
      'الشارقة',
      'عجمان',
      'أم القيوين',
      'رأس الخيمة',
      'الفجيرة',
      'العين',
      'خورفكان',
      'كلباء',
      'دبا الفجيرة',
    ],
    'QA': [
      'الدوحة',
      'الريان',
      'الوكرة',
      'الخور',
      'الشمال',
      'أم صلال',
      'الظعاين',
      'الشحانية',
      'مسيعيد',
      'دخان',
    ],
    'KW': [
      'الكويت العاصمة',
      'حولي',
      'الأحمدي',
      'الجهراء',
      'الفروانية',
      'مبارك الكبير',
      'السالمية',
      'الفحيحيل',
      'صباح السالم',
      'القرين',
    ],
    'BH': [
      'المنامة',
      'المحرق',
      'الرفاع',
      'مدينة عيسى',
      'سترة',
      'مدينة حمد',
      'البديع',
      'جد حفص',
      'عالي',
      'عراد',
    ],
    'OM': [
      'مسقط',
      'صلالة',
      'صحار',
      'نزوى',
      'البريمي',
      'صور',
      'الرستاق',
      'عبري',
      'خصب',
      'إبراء',
      'السيب',
      'بوشر',
      'مطرح',
      'بركاء',
      'صحم',
      'السويق',
      'شناص',
      'سمائل',
      'بهلاء',
      'الدقم',
    ],
  };

  static List<Map<String, String>> get countryList {
    return countries.keys.map((key) {
      return {
        'key': key,
        'name_ar': countryNameAr(key),
        'name_en': countryNameEn(key),
      };
    }).toList();
  }

  static List<String> citiesFor(String countryKey) {
    return countries[countryKey] ?? [];
  }

  static String countryNameAr(String key) {
    switch (key) {
      case 'SA':
        return 'السعودية';
      case 'AE':
        return 'الإمارات';
      case 'QA':
        return 'قطر';
      case 'KW':
        return 'الكويت';
      case 'BH':
        return 'البحرين';
      case 'OM':
        return 'عمان';
      default:
        return key;
    }
  }

  static String countryNameEn(String key) {
    switch (key) {
      case 'SA':
        return 'Saudi Arabia';
      case 'AE':
        return 'UAE';
      case 'QA':
        return 'Qatar';
      case 'KW':
        return 'Kuwait';
      case 'BH':
        return 'Bahrain';
      case 'OM':
        return 'Oman';
      default:
        return key;
    }
  }
}
