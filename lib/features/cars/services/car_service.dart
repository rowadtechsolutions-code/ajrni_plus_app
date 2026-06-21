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
    final cars = rawCars.map((json) {
      final officeId = CarModel.fromJson(json).officeId;
      return CarModel.fromJson(json, office: offices[officeId]);
    }).where((car) => car.isActive && car.office?.isActive != false).toList();
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
