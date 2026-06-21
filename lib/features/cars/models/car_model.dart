import '../../../core/constants/assets_app.dart';
import '../../offices/models/office_model.dart';

class CarModel {
  final String id;
  final String image;
  final List<String> images;
  final String name;
  final String brand;
  final String model;
  final int? year;
  final String transmission;
  final String fuel;
  final int? seats;
  final String color;
  final num? dailyPrice;
  final String currency;
  final bool isActive;
  final bool isFavorite;
  final String officeId;
  final OfficeModel? office;

  const CarModel({
    this.id = '',
    this.image = AssetsApp.hyundaiAvante,
    this.images = const [],
    this.name = '',
    this.brand = '',
    this.model = '',
    this.year,
    this.transmission = '',
    this.fuel = '',
    this.seats,
    this.color = '',
    this.dailyPrice,
    this.currency = 'OMR',
    this.isActive = true,
    this.isFavorite = false,
    this.officeId = '',
    this.office,
  });

  factory CarModel.fromJson(
    Map<String, dynamic> json, {
    OfficeModel? office,
    bool isFavorite = false,
  }) {
    final parsedImages = _images(
      json['images'] ?? json['car_images'] ?? json['gallery'] ?? json['photos'],
    );
    for (final key in [
      'image_1',
      'image_2',
      'image_3',
      'image1',
      'image2',
      'image3',
      'photo_1',
      'photo_2',
      'photo_3',
    ]) {
      final image = json[key]?.toString().trim() ?? '';
      if (image.isNotEmpty && !parsedImages.contains(image)) {
        parsedImages.add(image);
      }
    }
    final mainImage =
        _value(json, [
          'image',
          'main_image',
          'cover',
          'image_url',
          'photo',
          'thumbnail',
        ]) ??
        (parsedImages.isNotEmpty
            ? parsedImages.first
            : AssetsApp.hyundaiAvante);
    if (!parsedImages.contains(mainImage)) parsedImages.insert(0, mainImage);
    final nestedOffice = _nestedOffice(json);

    return CarModel(
      id: _value(json, ['id', 'car_id']) ?? '',
      image: mainImage,
      images: parsedImages,
      name: _value(json, ['name', 'car_name', 'title', 'vehicle_name']) ?? '',
      brand: _value(json, ['brand', 'make', 'manufacturer']) ?? '',
      model: _value(json, ['model', 'car_model', 'vehicle_model']) ?? '',
      year: _intValue(json, [
        'year',
        'manufacturing_year',
        'model_year',
        'production_year',
      ]),
      transmission:
          _value(json, [
            'transmission',
            'gear',
            'gearbox',
            'transmission_type',
          ]) ??
          '',
      fuel: _value(json, ['fuel', 'fuel_type', 'fuelType']) ?? '',
      seats: _intValue(json, [
        'seats',
        'seat_count',
        'number_of_seats',
        'passengers',
      ]),
      color: _value(json, ['color', 'car_color']) ?? '',
      dailyPrice: _numValue(json, [
        'daily_price',
        'price_per_day',
        'price',
        'day_price',
        'rental_price',
      ]),
      currency:
          _value(json, ['currency', 'currency_code']) ??
          _currencyForCountry((office ?? nestedOffice)?.country ?? ''),
      isActive:
          json['is_active'] != false &&
          json['active'] != false &&
          json['status']?.toString().toLowerCase() != 'inactive',
      isFavorite: isFavorite,
      officeId:
          _value(json, [
            'office_id',
            'officeId',
            'office_uuid',
            'rental_office_id',
            'owner_id',
            'user_id',
          ]) ??
          nestedOffice?.id ??
          '',
      office: office ?? nestedOffice,
    );
  }

  CarModel copyWith({OfficeModel? office, bool? isFavorite}) {
    return CarModel(
      id: id,
      image: image,
      images: images,
      name: name,
      brand: brand,
      model: model,
      year: year,
      transmission: transmission,
      fuel: fuel,
      seats: seats,
      color: color,
      dailyPrice: dailyPrice,
      currency: currency,
      isActive: isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      officeId: officeId,
      office: office ?? this.office,
    );
  }

  static String? _value(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  static int? _intValue(Map<String, dynamic> json, List<String> keys) {
    final value = _value(json, keys);
    return value == null ? null : num.tryParse(value)?.toInt();
  }

  static num? _numValue(Map<String, dynamic> json, List<String> keys) {
    final value = _value(json, keys);
    return value == null ? null : num.tryParse(value);
  }

  static List<String> _images(dynamic raw) {
    if (raw is List) {
      return raw
          .map((item) {
            if (item is Map) {
              return _value(Map<String, dynamic>.from(item), [
                    'url',
                    'image',
                    'image_url',
                    'path',
                  ]) ??
                  '';
            }
            return item.toString();
          })
          .where((item) => item.trim().isNotEmpty)
          .toSet()
          .toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();
    }
    return [];
  }

  static OfficeModel? _nestedOffice(Map<String, dynamic> json) {
    for (final key in ['office', 'Office', 'Offices']) {
      final value = json[key];
      if (value is Map) {
        return OfficeModel.fromJson(Map<String, dynamic>.from(value));
      }
    }
    return null;
  }

  static String _currencyForCountry(String country) {
    switch (country.trim().toUpperCase()) {
      case 'SA':
        return 'SAR';
      case 'AE':
        return 'AED';
      case 'QA':
        return 'QAR';
      case 'KW':
        return 'KWD';
      case 'BH':
        return 'BHD';
      default:
        return 'OMR';
    }
  }
}
