class LocationMatcher {
  LocationMatcher._();

  static const Map<String, Set<String>> _countryAliases = {
    'OM': {'om', 'oman', 'عمان', 'سلطنة عمان'},
    'SA': {'sa', 'saudi arabia', 'السعودية', 'المملكة العربية السعودية'},
    'AE': {'ae', 'uae', 'united arab emirates', 'الإمارات', 'الامارات'},
    'QA': {'qa', 'qatar', 'قطر'},
    'KW': {'kw', 'kuwait', 'الكويت'},
    'BH': {'bh', 'bahrain', 'البحرين'},
  };

  static bool country(String value, String filter) {
    if (filter.trim().isEmpty) return true;
    final left = _normalize(value);
    final right = _normalize(filter);
    if (left == right) return true;
    for (final aliases in _countryAliases.values) {
      if (aliases.contains(left) && aliases.contains(right)) return true;
    }
    return false;
  }

  static bool city(String value, String filter) {
    if (filter.trim().isEmpty) return true;
    return _normalize(value) == _normalize(filter);
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه');
  }
}
