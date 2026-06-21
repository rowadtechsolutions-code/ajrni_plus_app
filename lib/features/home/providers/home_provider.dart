import 'package:flutter/foundation.dart';

import '../../../core/helpers/location_matcher.dart';
import '../../cars/models/car_model.dart';
import '../../cars/services/car_service.dart';
import '../../offices/models/office_model.dart';
import '../../offices/services/office_service.dart';

class HomeProvider extends ChangeNotifier {
  final OfficeService _officeService;
  final CarService _carService;

  HomeProvider({OfficeService? officeService, CarService? carService})
    : _officeService = officeService ?? OfficeService(),
      _carService = carService ?? CarService();

  List<OfficeModel> _nearbyOffices = const [];
  List<CarModel> _homeCars = const [];
  bool _loading = false;
  String? _error;

  List<OfficeModel> get nearbyOffices => _nearbyOffices;
  List<CarModel> get homeCars => _homeCars;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({String? country, String? city}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _officeService.getActiveOffices(),
        _carService.getActiveCars(),
      ]);
      final allOffices = results[0] as List<OfficeModel>;
      final allCars = results[1] as List<CarModel>;
      _nearbyOffices = allOffices.where((office) {
        final matchesCountry =
            country == null ||
            country.isEmpty ||
            LocationMatcher.country(office.country, country);
        final matchesCity =
            city == null ||
            city.isEmpty ||
            LocationMatcher.city(office.city, city);
        return matchesCountry && matchesCity;
      }).toList();
      _homeCars = allCars.where((car) {
        if (car.office == null) return false;
        final matchesCountry =
            country == null ||
            country.isEmpty ||
            LocationMatcher.country(car.office!.country, country);
        final matchesCity =
            city == null ||
            city.isEmpty ||
            LocationMatcher.city(car.office!.city, city);
        return matchesCountry && matchesCity;
      }).toList();
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
