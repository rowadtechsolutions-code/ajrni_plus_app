import 'package:arini_plus_app/core/helpers/form_validators.dart';
import 'package:arini_plus_app/core/helpers/location_matcher.dart';
import 'package:arini_plus_app/core/services/contact_launcher_service.dart';
import 'package:arini_plus_app/features/cars/models/car_model.dart';
import 'package:arini_plus_app/features/offices/models/office_model.dart';
import 'package:arini_plus_app/features/dealer/data/car_brands_data.dart';
import 'package:arini_plus_app/features/auth/helpers/auth_error_mapper.dart';
import 'package:arini_plus_app/core/l10n/app_localizations_en.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormValidators', () {
    test('validates emails', () {
      expect(FormValidators.email('user@example.com', 'error'), isNull);
      expect(FormValidators.email('not-an-email', 'error'), 'error');
    });

    test('requires strong passwords', () {
      expect(FormValidators.password('Strong123', 'error'), isNull);
      expect(FormValidators.password('weak', 'error'), 'error');
    });

    test('validates Gulf phone lengths', () {
      expect(FormValidators.gulfPhone('+968 9912 3456', 'OM', 'error'), isNull);
      expect(FormValidators.gulfPhone('123', 'OM', 'error'), 'error');
    });
  });

  test('CarModel maps common Supabase column aliases', () {
    final car = CarModel.fromJson({
      'id': 'car-id',
      'car_name': 'Hyundai Avante',
      'make': 'Hyundai',
      'car_model': 'Elantra',
      'model_year': 2019,
      'gearbox': 'Automatic',
      'fuel_type': 'Petrol',
      'number_of_seats': 5,
      'price_per_day': 8,
      'office_id': 'office-id',
    });

    expect(car.id, 'car-id');
    expect(car.name, 'Hyundai Avante');
    expect(car.brand, 'Hyundai');
    expect(car.year, 2019);
    expect(car.dailyPrice, 8);
    expect(car.officeId, 'office-id');
  });

  test('CarModel maps the live Ajrni Plus cars schema', () {
    const office = OfficeModel(
      id: 'office-id',
      officeName: 'Adams Cars',
      email: 'office@example.com',
      phoneNumber: '93686336',
      country: 'OM',
      city: 'مسقط',
      commercialRegistrationNumber: '123',
    );
    final car = CarModel.fromJson({
      'id': 'car-id',
      'name': 'اكسنت',
      'brand': 'Hyundai',
      'model': 'Accent',
      'year': 2026,
      'fuel_type': 'GASOLINE',
      'transmission': 'AUTOMATIC',
      'seats': 5,
      'price': '12',
      'office_id': 'office-id',
      'image': 'https://example.com/main.jpg',
      'images': ['https://example.com/second.jpg'],
    }, office: office);

    expect(car.name, 'اكسنت');
    expect(car.dailyPrice, 12);
    expect(car.fuel, 'GASOLINE');
    expect(car.office?.officeName, 'Adams Cars');
    expect(car.images, hasLength(2));
  });

  test('location matching supports country codes and Arabic names', () {
    expect(LocationMatcher.country('OM', 'عمان'), isTrue);
    expect(LocationMatcher.country('Oman', 'OM'), isTrue);
    expect(LocationMatcher.city('مسقط', 'مسقط'), isTrue);
    expect(LocationMatcher.city('مسقط', 'صلالة'), isFalse);
  });

  test('dealer brands provide scoped models and working selections', () {
    final toyota = CarBrandsData.byName('Toyota');
    final nissan = CarBrandsData.byName('Nissan');

    expect(toyota, isNotNull);
    expect(toyota!.models, containsAll(['Camry', 'Corolla', 'Yaris', 'Prado']));
    expect(nissan!.models, containsAll(['Sunny', 'Altima', 'Patrol']));
    expect(toyota.models, isNot(contains('Patrol')));
    expect(CarBrandsData.brands.length, greaterThanOrEqualTo(30));
    for (final brand in CarBrandsData.brands) {
      expect(brand.logoUrl, startsWith('https://'));
      expect(brand.models, isNotEmpty);
      expect(brand.models.toSet().length, brand.models.length);
    }
  });

  test('registration database errors are not shown as unexpected errors', () {
    final message = AuthErrorMapper.message(
      const AuthException('Database error saving new user'),
      AppLocalizationsEn(),
    );
    expect(
      message,
      'Registration was reached, but the account profile could not be created. Update the database setup and try again.',
    );
  });

  test('normalizes Gulf phone to international WhatsApp format', () {
    expect(
      ContactLauncherService.internationalPhone('099123456', 'OM'),
      '96899123456',
    );
    expect(
      ContactLauncherService.internationalPhone('+971501234567', 'AE'),
      '971501234567',
    );
  });
}
