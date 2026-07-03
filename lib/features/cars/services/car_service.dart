import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../offices/models/office_model.dart';
import '../models/car_model.dart';

class CarService {
  final SupabaseClient _client;

  CarService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<CarModel>> getActiveCars({String search = ''}) async {
    final query = _client.from(SupabaseTables.cars).select();
    final response = await query.order('created_at', ascending: false);
    final rawCars = List<Map<String, dynamic>>.from(response);
    return _buildCars(rawCars, search);
  }

  Future<List<CarModel>> getActiveCarsPaginated({
    int limit = 12,
    int offset = 0,
    String search = '',
    Set<String> brands = const {},
    Set<String> models = const {},
    Set<String> years = const {},
    Set<String> transmissions = const {},
    Set<String> fuels = const {},
    Set<String> colors = const {},
    Set<String> cities = const {},
    double? minPrice,
    double? maxPrice,
  }) async {
    var query = _client
        .from(SupabaseTables.cars)
        .select()
        .eq('is_active', true);
    final term = search.trim();
    if (term.isNotEmpty) {
      query = query.or(
        'name.ilike.%$term%,brand.ilike.%$term%,model.ilike.%$term%,color.ilike.%$term%',
      );
    }
    if (brands.isNotEmpty) query = query.inFilter('brand', brands.toList());
    if (models.isNotEmpty) query = query.inFilter('model', models.toList());
    if (years.isNotEmpty) query = query.inFilter('year', years.toList());
    if (transmissions.isNotEmpty) {
      query = query.inFilter('transmission', transmissions.toList());
    }
    if (fuels.isNotEmpty) query = query.inFilter('fuel', fuels.toList());
    if (colors.isNotEmpty) query = query.inFilter('color', colors.toList());
    if (minPrice != null) query = query.gte('daily_price', minPrice);
    if (maxPrice != null) query = query.lte('daily_price', maxPrice);
    if (cities.isNotEmpty) {
      final officeRows = await _client
          .from(SupabaseTables.offices)
          .select('id')
          .inFilter('city', cities.toList());
      final ids = officeRows.map<String>((o) => o['id'] as String).toList();
      if (ids.isEmpty) return [];
      query = query.inFilter('office_id', ids);
    }
    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    final rawCars = List<Map<String, dynamic>>.from(response);
    return _buildCars(rawCars, '');
  }

  Future<List<CarModel>> _buildCars(
    List<Map<String, dynamic>> rawCars,
    String search,
  ) async {
    final officeIds = rawCars
        .map((json) => CarModel.fromJson(json).officeId)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final offices = <String, OfficeModel>{};
    if (officeIds.isNotEmpty) {
      final officeRows = await _client
          .from(SupabaseTables.offices)
          .select()
          .inFilter('id', officeIds);
      for (final row in officeRows) {
        final office = OfficeModel.fromJson(row);
        offices[office.id] = office;
      }
    }
    final cars = rawCars
        .map((json) {
          final officeId = CarModel.fromJson(json).officeId;
          return CarModel.fromJson(json, office: offices[officeId]);
        })
        .where((car) => car.isActive && car.office?.isActive != false)
        .toList();
    final term = search.trim().toLowerCase();
    if (term.isEmpty) return cars;
    return cars.where((car) {
      return [
        car.name,
        car.brand,
        car.model,
        car.color,
      ].join(' ').toLowerCase().contains(term);
    }).toList();
  }

  Future<List<CarModel>> getCarsByIds(Set<String> ids) async {
    if (ids.isEmpty) return [];
    final response = await _client
        .from(SupabaseTables.cars)
        .select()
        .inFilter('id', ids.toList());
    final rawCars = List<Map<String, dynamic>>.from(response);
    return _buildCars(rawCars, '');
  }

  Future<List<CarModel>> getCarsByOffice(String officeId) async {
    final response = await _client
        .from(SupabaseTables.cars)
        .select()
        .eq('office_id', officeId)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return response.map(CarModel.fromJson).toList();
  }
}
