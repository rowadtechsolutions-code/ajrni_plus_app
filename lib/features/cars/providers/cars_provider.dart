import 'package:flutter/foundation.dart';

import '../../../core/helpers/location_matcher.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';

class CarFilterSelection {
  final Set<String> brands;
  final Set<String> models;
  final Set<String> years;
  final Set<String> transmissions;
  final Set<String> fuels;
  final Set<String> colors;
  final Set<String> cities;
  final double? minPrice;
  final double? maxPrice;

  const CarFilterSelection({
    this.brands = const {},
    this.models = const {},
    this.years = const {},
    this.transmissions = const {},
    this.fuels = const {},
    this.colors = const {},
    this.cities = const {},
    this.minPrice,
    this.maxPrice,
  });

  bool get isEmpty =>
      brands.isEmpty &&
      models.isEmpty &&
      years.isEmpty &&
      transmissions.isEmpty &&
      fuels.isEmpty &&
      colors.isEmpty &&
      cities.isEmpty &&
      minPrice == null &&
      maxPrice == null;

  CarFilterSelection copyWith({
    Set<String>? brands,
    Set<String>? models,
    Set<String>? years,
    Set<String>? transmissions,
    Set<String>? fuels,
    Set<String>? colors,
    Set<String>? cities,
    double? minPrice,
    double? maxPrice,
  }) {
    return CarFilterSelection(
      brands: brands ?? this.brands,
      models: models ?? this.models,
      years: years ?? this.years,
      transmissions: transmissions ?? this.transmissions,
      fuels: fuels ?? this.fuels,
      colors: colors ?? this.colors,
      cities: cities ?? this.cities,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  CarFilterSelection copyWithPrice({double? minPrice, double? maxPrice}) {
    return CarFilterSelection(
      brands: brands,
      models: models,
      years: years,
      transmissions: transmissions,
      fuels: fuels,
      colors: colors,
      cities: cities,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}

class CarsProvider extends ChangeNotifier {
  final CarService _service;

  CarsProvider({CarService? service}) : _service = service ?? CarService();

  List<CarModel> _allCars = const [];
  List<CarModel> _cars = const [];
  bool _loading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  String _search = '';
  String _country = '';
  String _city = '';
  CarFilterSelection _filters = const CarFilterSelection();
  static const int _pageSize = 12;

  List<CarModel> get cars => _cars;
  List<CarModel> get allCars => _allCars;
  bool get loading => _loading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get search => _search;
  String get country => _country;
  String get city => _city;
  CarFilterSelection get filters => _filters;
  bool get hasActiveFilters => _search.trim().isNotEmpty || !_filters.isEmpty;

  Future<void> load({String? search, String? country, String? city}) async {
    if (search != null) _search = search;
    if (country != null) _country = country;
    if (city != null) _city = city;
    _allCars = const [];
    _cars = const [];
    _hasMore = true;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final fetched = await _service.getActiveCarsPaginated(
        limit: _pageSize,
        offset: 0,
        search: _search,
        country: _country,
        city: _city,
        brands: _filters.brands,
        models: _filters.models,
        years: _filters.years,
        transmissions: _filters.transmissions,
        fuels: _filters.fuels,
        colors: _filters.colors,
        cities: _filters.cities,
        minPrice: _filters.minPrice,
        maxPrice: _filters.maxPrice,
      );
      _allCars = fetched;
      if (fetched.length < _pageSize) _hasMore = false;
      _apply();
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final fetched = await _service.getActiveCarsPaginated(
        limit: _pageSize,
        offset: _allCars.length,
        search: _search,
        country: _country,
        city: _city,
        brands: _filters.brands,
        models: _filters.models,
        years: _filters.years,
        transmissions: _filters.transmissions,
        fuels: _filters.fuels,
        colors: _filters.colors,
        cities: _filters.cities,
        minPrice: _filters.minPrice,
        maxPrice: _filters.maxPrice,
      );
      if (fetched.length < _pageSize) _hasMore = false;
      _allCars = [..._allCars, ...fetched];
      _apply();
    } catch (_) {
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void applyFilters({
    String? search,
    String? country,
    String? city,
    CarFilterSelection? filters,
  }) {
    if (search != null && search != _search) {
      _search = search;
      load(search: search);
      return;
    }
    if (search != null) _search = search;
    if (country != null) _country = country;
    if (city != null) _city = city;
    if (filters != null) {
      _filters = filters;
      load();
      return;
    }
    _apply();
    notifyListeners();
  }

  void clearFilters({bool keepLocation = false}) {
    final hadActiveFilters = _search.trim().isNotEmpty || !_filters.isEmpty;
    _search = '';
    _filters = const CarFilterSelection();
    if (!keepLocation) {
      _country = '';
      _city = '';
    }
    if (hadActiveFilters) {
      load();
    } else {
      _apply();
      notifyListeners();
    }
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
      final matchesBrand = _matchesSet(car.brand, _filters.brands);
      final matchesModel = _matchesSet(car.model, _filters.models);
      final matchesYear = _filters.years.isEmpty
          ? true
          : car.year != null && _filters.years.contains(car.year.toString());
      final matchesTransmission = _matchesSet(
        _normalizeTransmission(car.transmission),
        _filters.transmissions,
      );
      final matchesFuel = _matchesSet(_normalizeFuel(car.fuel), _filters.fuels);
      final matchesColor = _matchesSet(car.color, _filters.colors);
      final matchesRegion =
          _filters.cities.isEmpty ||
          (office != null && _matchesSet(office.city, _filters.cities));
      final matchesPrice = _matchesPrice(car.dailyPrice, _filters);

      return matchesSearch &&
          matchesCountry &&
          matchesCity &&
          matchesBrand &&
          matchesModel &&
          matchesYear &&
          matchesTransmission &&
          matchesFuel &&
          matchesColor &&
          matchesRegion &&
          matchesPrice;
    }).toList();
  }

  static bool _matchesPrice(num? value, CarFilterSelection filters) {
    if (filters.minPrice == null && filters.maxPrice == null) return true;
    if (value == null) return false;
    final price = value.toDouble();
    if (filters.minPrice != null && price < filters.minPrice!) return false;
    if (filters.maxPrice != null && price > filters.maxPrice!) return false;
    return true;
  }

  static bool _matchesSet(String value, Set<String> selected) {
    if (selected.isEmpty) return true;
    final normalized = _normalize(value);
    if (normalized.isEmpty) return false;
    return selected.map(_normalize).contains(normalized);
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  static String _normalizeFuel(String value) {
    final normalized = _normalize(value);
    switch (normalized) {
      case 'gasoline':
      case 'petrol':
      case 'بنزين':
      case 'ط¨ظ†ط²ظٹظ†':
        return 'GASOLINE';
      case 'diesel':
      case 'ديزل':
      case 'ط¯ظٹط²ظ„':
        return 'DIESEL';
      case 'electric':
      case 'كهرباء':
      case 'كهربائي':
      case 'ظƒظ‡ط±ط¨ط§ط،':
        return 'ELECTRIC';
      case 'hybrid':
      case 'هايبرد':
      case 'هجين':
      case 'ظ‡ط¬ظٹظ†':
        return 'HYBRID';
      default:
        return value.trim();
    }
  }

  static String _normalizeTransmission(String value) {
    final normalized = _normalize(value);
    switch (normalized) {
      case 'automatic':
      case 'auto':
      case 'أوتوماتيك':
      case 'اوتوماتيك':
      case 'ط£ظˆطھظˆظ…ط§طھظٹظƒ':
        return 'AUTOMATIC';
      case 'manual':
      case 'يدوي':
      case 'عادي':
      case 'مانيوال':
      case 'ط¹ط§ط¯ظٹ':
        return 'MANUAL';
      default:
        return value.trim();
    }
  }
}
