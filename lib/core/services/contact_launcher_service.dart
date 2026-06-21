import 'package:url_launcher/url_launcher.dart';

class ContactLauncherService {
  ContactLauncherService._();

  static Future<void> call(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (normalized.isEmpty) throw Exception('رقم الهاتف غير متوفر.');
    final launched = await launchUrl(Uri(scheme: 'tel', path: normalized));
    if (!launched) throw Exception('تعذر فتح تطبيق الاتصال.');
  }

  static Future<void> whatsapp({
    required String phone,
    required String country,
    String message = '',
  }) async {
    final normalized = internationalPhone(phone, country);
    if (normalized.isEmpty) throw Exception('رقم واتساب غير متوفر.');
    final uri = Uri.https('wa.me', '/$normalized', {
      if (message.isNotEmpty) 'text': message,
    });
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) throw Exception('تعذر فتح واتساب.');
  }

  static String internationalPhone(String phone, String country) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    final code = _dialCodes[country];
    if (code == null) return digits;
    if (digits.startsWith(code)) return digits;
    while (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return '$code$digits';
  }

  static const _dialCodes = {
    'SA': '966',
    'AE': '971',
    'QA': '974',
    'KW': '965',
    'BH': '973',
    'OM': '968',
  };
}
