import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Country {
  final String id;
  final String code;
  final String nameAr;
  final String nameEn;
  final String phoneCode;

  Country({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.phoneCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      phoneCode: json['phone_code']?.toString() ?? '',
    );
  }
}

class City {
  final String id;
  final String countryId;
  final String nameAr;
  final String nameEn;

  City({required this.id, required this.countryId, required this.nameAr, required this.nameEn});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id']?.toString() ?? '',
      countryId: json['country_id']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
    );
  }
}

class LocationService {
  LocationService._();

  static List<Country>? _countries;
  static final Map<String, List<City>> _citiesByCountry = {};

  static Future<List<Country>> getCountries() async {
    if (_countries != null) return _countries!;
    final response = await Supabase.instance.client
        .from('countries')
        .select()
        .order('sort_order', ascending: true);
    _countries = (response as List).map((json) {
      debugPrint('country: ${json['name_ar']} sort_order: ${json['sort_order']}');
      return Country.fromJson(json as Map<String, dynamic>);
    }).toList();
    return _countries!;
  }

  static Future<List<City>> getCities(String countryCode) async {
    if (_citiesByCountry.containsKey(countryCode)) return _citiesByCountry[countryCode]!;
    if (_countries == null) await getCountries();
    final country = _countries!.firstWhere((c) => c.code == countryCode);
    final response = await Supabase.instance.client
        .from('cities')
        .select()
        .eq('country_id', country.id)
        .order('sort_order', ascending: true);
    final cities = (response as List).map((json) {
      debugPrint('city: ${json['name_ar']} sort_order: ${json['sort_order']}');
      return City.fromJson(json as Map<String, dynamic>);
    }).toList();
    _citiesByCountry[countryCode] = cities;
    return cities;
  }

  static String countryName(String code, bool isArabic) {
    if (_countries == null) return code;
    try {
      final country = _countries!.firstWhere((c) => c.code == code);
      return isArabic ? country.nameAr : country.nameEn;
    } catch (_) {
      return code;
    }
  }

  static void clearCache() {
    _countries = null;
    _citiesByCountry.clear();
  }
}
