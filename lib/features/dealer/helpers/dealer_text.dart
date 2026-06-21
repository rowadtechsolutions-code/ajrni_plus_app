import 'package:flutter/widgets.dart';

class DealerText {
  final bool ar;

  const DealerText._(this.ar);

  factory DealerText.of(BuildContext context) {
    return DealerText._(Localizations.localeOf(context).languageCode == 'ar');
  }

  String get dashboard => ar ? 'لوحة التحكم' : 'Dashboard';
  String get myCars => ar ? 'سياراتي' : 'My cars';
  String get requests => ar ? 'الطلبات' : 'Requests';
  String get statistics => ar ? 'الإحصائيات' : 'Statistics';
  String get profile => ar ? 'الملف الشخصي' : 'Profile';
  String get addCar => ar ? 'إضافة سيارة' : 'Add car';
  String get editCar => ar ? 'تعديل السيارة' : 'Edit car';
  String get noCars => ar ? 'لا توجد سيارات حتى الآن' : 'No cars yet';
  String get noRequests => ar ? 'لا توجد طلبات حاليًا' : 'No requests yet';
  String get requestsComingSoon => ar
      ? 'قريبًا سيتم تضمين الطلبات داخل التطبيق'
      : 'Requests will be included in the app soon';
  String get requestsAvailableOnWeb => ar
      ? 'الخدمة متاحة الآن عبر موقع أجرني بلس'
      : 'The service is currently available on the Ajrni Plus website';
  String get totalCars => ar ? 'إجمالي السيارات' : 'Total cars';
  String get availableCars => ar ? 'السيارات المتاحة' : 'Available cars';
  String get totalRequests => ar ? 'إجمالي الطلبات' : 'Total requests';
  String get pendingRequests => ar ? 'الطلبات المعلقة' : 'Pending requests';
  String get latestRequests => ar ? 'آخر الطلبات' : 'Latest requests';
  String get active => ar ? 'نشط' : 'Active';
  String get pendingApproval => ar ? 'بانتظار الموافقة' : 'Pending approval';
  String get carName => ar ? 'اسم السيارة' : 'Car name';
  String get brand => ar ? 'العلامة التجارية' : 'Brand';
  String get model => ar ? 'الموديل' : 'Model';
  String get year => ar ? 'سنة الصنع' : 'Year';
  String get color => ar ? 'اللون' : 'Color';
  String get fuel => ar ? 'الوقود' : 'Fuel';
  String get transmission => ar ? 'القير' : 'Transmission';
  String get seats => ar ? 'عدد المقاعد' : 'Seats';
  String get plate => ar ? 'رقم اللوحة' : 'Plate number';
  String get rentalType => ar ? 'نوع الإيجار' : 'Rental type';
  String get daily => ar ? 'يومي' : 'Daily';
  String get monthly => ar ? 'شهري' : 'Monthly';
  String get price => ar ? 'السعر' : 'Price';
  String get status => ar ? 'الحالة' : 'Status';
  String get available => ar ? 'متاح' : 'Available';
  String get rented => ar ? 'مستأجر' : 'Rented';
  String get maintenance => ar ? 'صيانة' : 'Maintenance';
  String get images => ar ? 'صور السيارة' : 'Car images';
  String get imagesHint => ar ? 'الحد الأقصى 3 صور' : 'Maximum 3 images';
  String get save => ar ? 'حفظ السيارة' : 'Save car';
  String get delete => ar ? 'حذف' : 'Delete';
  String get edit => ar ? 'تعديل' : 'Edit';
  String get deleteTitle => ar ? 'حذف السيارة' : 'Delete car';
  String get deleteMessage => ar
      ? 'هل أنت متأكد من حذف السيارة؟ لا يمكن التراجع عن هذا الإجراء.'
      : 'Delete this car? This action cannot be undone.';
  String get requiredFields =>
      ar ? 'أكمل جميع البيانات المطلوبة' : 'Complete all required fields';
  String get saved => ar ? 'تم حفظ السيارة بنجاح' : 'Car saved successfully';
  String get failed => ar ? 'تعذر تنفيذ العملية' : 'Operation failed';
  String get officeProfile =>
      ar ? 'بيانات مكتب التأجير' : 'Rental office profile';
  String get logout => ar ? 'تسجيل الخروج' : 'Log out';
}
