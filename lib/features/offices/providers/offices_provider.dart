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
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  String _search = '';
  String _country = '';
  String _city = '';
  static const int _pageSize = 12;

  List<OfficeModel> get offices => _offices;
  List<OfficeModel> get allOffices => _allOffices;
  bool get loading => _loading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String get search => _search;
  String get country => _country;
  String get city => _city;

  Future<void> load({String? search, String? country, String? city}) async {
    if (search != null) _search = search;
    if (country != null) _country = country;
    if (city != null) _city = city;
    _allOffices = const [];
    _offices = const [];
    _hasMore = true;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final fetched = await _service.getActiveOfficesPaginated(
        limit: _pageSize,
        offset: 0,
        search: _search,
        country: _country,
        city: _city,
      );
      _allOffices = fetched;
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
      final fetched = await _service.getActiveOfficesPaginated(
        limit: _pageSize,
        offset: _allOffices.length,
        search: _search,
        country: _country,
        city: _city,
      );
      if (fetched.length < _pageSize) _hasMore = false;
      _allOffices = [..._allOffices, ...fetched];
      _apply();
    } catch (_) {
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void applyFilters({String? search, String? country, String? city}) {
    if (search != null && search != _search) {
      _search = search;
      load(search: search);
      return;
    }
    final locationChanged = (country != null && country != _country) ||
        (city != null && city != _city);
    if (search != null) _search = search;
    if (country != null) _country = country;
    if (city != null) _city = city;
    if (locationChanged) {
      load();
    } else {
      _apply();
      notifyListeners();
    }
  }

  void clearFilters({bool keepLocation = false}) {
    final hadActiveFilters =
        _search.trim().isNotEmpty ||
        _country.trim().isNotEmpty ||
        _city.trim().isNotEmpty;
    _search = '';
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
