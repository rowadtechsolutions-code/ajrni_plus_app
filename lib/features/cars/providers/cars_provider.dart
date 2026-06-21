import 'package:flutter/foundation.dart';

import '../../../core/helpers/location_matcher.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';

class CarsProvider extends ChangeNotifier {
  final CarService _service;

  CarsProvider({CarService? service}) : _service = service ?? CarService();

  List<CarModel> _allCars = const [];
  List<CarModel> _cars = const [];
  bool _loading = false;
  String? _error;
  String _search = '';
  String _country = '';
  String _city = '';

  List<CarModel> get cars => _cars;
  List<CarModel> get allCars => _allCars;
  bool get loading => _loading;
  String? get error => _error;
  String get search => _search;
  String get country => _country;
  String get city => _city;

  Future<void> load({String? search, String? country, String? city}) async {
    if (search != null) _search = search;
    if (country != null) _country = country;
    if (city != null) _city = city;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _allCars = await _service.getActiveCars();
      _apply();
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void applyFilters({String? search, String? country, String? city}) {
    if (search != null) _search = search;
    if (country != null) _country = country;
    if (city != null) _city = city;
    _apply();
    notifyListeners();
  }

  void clearFilters({bool keepLocation = false}) {
    _search = '';
    if (!keepLocation) {
      _country = '';
      _city = '';
    }
    _apply();
    notifyListeners();
  }

  void _apply() {
    final term = _search.trim().toLowerCase();
    _cars = _allCars.where((car) {
      final office = car.office;
      final matchesSearch =
          term.isEmpty ||
          [
            car.name,
            car.brand,
            car.model,
            car.color,
            office?.officeName ?? '',
          ].join(' ').toLowerCase().contains(term);
      final matchesCountry =
          _country.isEmpty ||
          (office != null && LocationMatcher.country(office.country, _country));
      final matchesCity =
          _city.isEmpty ||
          (office != null && LocationMatcher.city(office.city, _city));
      return matchesSearch && matchesCountry && matchesCity;
    }).toList();
  }
}
