import 'package:flutter/foundation.dart';

import '../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _service;

  FavoritesProvider({FavoritesService? service})
    : _service = service ?? FavoritesService();

  Set<String> _ids = {};
  bool _loading = false;
  String? _error;

  Set<String> get ids => _ids;
  bool get loading => _loading;
  String? get error => _error;
  bool contains(String carId) => _ids.contains(carId);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _ids = await _service.getFavoriteCarIds();
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
    } catch (_) {
      if (wasFavorite) {
        _ids.add(carId);
      } else {
        _ids.remove(carId);
      }
      notifyListeners();
      rethrow;
    }
  }
}
