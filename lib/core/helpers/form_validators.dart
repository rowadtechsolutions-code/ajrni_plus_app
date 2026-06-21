class FormValidators {
  FormValidators._();

  static String? requiredText(String value, String message) {
    return value.trim().isEmpty ? message : null;
  }

  static String? name(String value, String message) {
    final clean = value.trim();
    if (clean.length < 3 || clean.length > 80) return message;
    if (!RegExp(r"^[\p{L}\p{M}\s.'-]+$", unicode: true).hasMatch(clean)) {
      return message;
    }
    return null;
  }

  static String? email(String value, String message) {
    final clean = value.trim().toLowerCase();
    final valid = RegExp(
      r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$",
    ).hasMatch(clean);
    return valid ? null : message;
  }

  static String normalizePhone(String value) {
    var clean = value.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.startsWith('00')) clean = '+${clean.substring(2)}';
    return clean;
  }

  static String? gulfPhone(String value, String country, String message) {
    var clean = normalizePhone(value).replaceFirst('+', '');
    final dialCode = _dialCodes[country];
    if (dialCode != null && clean.startsWith(dialCode)) {
      clean = clean.substring(dialCode.length);
    }
    final lengths = _localPhoneLengths[country] ?? const [8, 9];
    return lengths.contains(clean.length) ? null : message;
  }

  static String? password(String value, String message) {
    return value.length >= 6 ? null : message;
  }

  static const _dialCodes = {
    'SA': '966',
    'AE': '971',
    'QA': '974',
    'KW': '965',
    'BH': '973',
    'OM': '968',
  };

  static const _localPhoneLengths = {
    'SA': [9],
    'AE': [9],
    'QA': [8],
    'KW': [8],
    'BH': [8],
    'OM': [8],
  };
}
