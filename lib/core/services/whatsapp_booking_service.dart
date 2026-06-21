import 'package:url_launcher/url_launcher.dart';

import '../../features/cars/models/car_model.dart';
import 'contact_launcher_service.dart';

class WhatsAppBookingService {
  WhatsAppBookingService._();

  static Future<void> book({
    required CarModel car,
    String customerPhone = '',
  }) async {
    final office = car.office;
    final merchantPhone = ContactLauncherService.internationalPhone(
      office?.phoneNumber ?? '',
      office?.country ?? '',
    );
    if (merchantPhone.isEmpty) {
      throw Exception('رقم واتساب المكتب غير متوفر.');
    }
    final carUrl = 'https://www.ajrniplus.com/cars/${car.id}';
    final location = [
      office?.city ?? '',
      office?.country ?? '',
    ].where((item) => item.isNotEmpty).join('، ');
    final price = car.dailyPrice == null
        ? ''
        : '${car.dailyPrice} ${car.currency} /يوم';
    final message =
        '''
🔗 رابط السيارة: $carUrl
🚗 حجز سيارة

📋 السيارة: ${car.name}
🏭 الماركة: ${car.brand}
📦 الموديل: ${car.model}
📅 السنة: ${car.year ?? ''}
⚙️ القير: ${car.transmission}
⛽ الوقود: ${car.fuel}
👥 المقاعد: ${car.seats ?? ''}
🎨 اللون: ${car.color}
💰 السعر: $price
🏢 المكتب: ${office?.officeName ?? ''}${location.isEmpty ? '' : ' ($location)'}

أرغب في حجز هذه السيارة. يرجى التواصل معي.
📞 رقم الجوال: [$customerPhone]
''';
    final uri = Uri.https('wa.me', '/$merchantPhone', {'text': message});
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) throw Exception('تعذر فتح واتساب.');
  }
}
