import 'package:flutter/foundation.dart';

import '../../cars/models/car_model.dart';
import '../../cars/services/car_service.dart';
import '../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _service;
  final CarService _carService;

  FavoritesProvider({FavoritesService? service, CarService? carService})
    : _service = service ?? FavoritesService(),
      _carService = carService ?? CarService();

  Set<String> _ids = {};
  List<CarModel> _cars = [];
  bool _loading = false;
  String? _error;

  Set<String> get ids => _ids;
  List<CarModel> get cars => _cars;
  bool get loading => _loading;
  String? get error => _error;
  bool contains(String carId) => _ids.contains(carId);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _ids = await _service.getFavoriteCarIds();
      _cars = _ids.isNotEmpty
          ? await _carService.getCarsByIds(_ids)
          : const [];
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(String carId) async {
    if (carId.isEmpty) return;
    final wasFavorite = contains(carId);
    if (wasFavorite) {
      _ids.remove(carId);
      _cars.removeWhere((car) => car.id == carId);
    } else {
      _ids.add(carId);
    }
    notifyListeners();
    try {
      if (wasFavorite) {
        await _service.remove(carId);
      } else {
        await _service.add(carId);
      }
      if (!wasFavorite) {
        _cars = _ids.isNotEmpty
            ? await _carService.getCarsByIds(_ids)
            : const [];
        notifyListeners();
      }
    } catch (_) {
      if (wasFavorite) {
        _ids.add(carId);
      } else {
        _ids.remove(carId);
      }
      try {
        _cars = _ids.isNotEmpty
            ? await _carService.getCarsByIds(_ids)
            : const [];
      } catch (_) {}
      notifyListeners();
      rethrow;
    }
  }
}
