import 'package:flutter/foundation.dart';

import '../../../core/helpers/location_matcher.dart';
import '../models/office_model.dart';
import '../services/office_service.dart';

class OfficesProvider extends ChangeNotifier {
  final OfficeService _service;

  OfficesProvider({OfficeService? service})
    : _service = service ?? OfficeService();

  List<OfficeModel> _allOffices = const [];
  List<OfficeModel> _offices = const [];
  bool _loading = false;
  String? _error;
  String _search = '';
  String _country = '';
  String _city = '';

  List<OfficeModel> get offices => _offices;
  List<OfficeModel> get allOffices => _allOffices;
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
      _allOffices = await _service.getActiveOffices();
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
    _offices = _allOffices.where((office) {
      final matchesSearch =
          term.isEmpty ||
          [
            office.officeName,
            office.bio,
            office.city,
            office.country,
          ].join(' ').toLowerCase().contains(term);
      return matchesSearch &&
          LocationMatcher.country(office.country, _country) &&
          LocationMatcher.city(office.city, _city);
    }).toList();
  }
}
