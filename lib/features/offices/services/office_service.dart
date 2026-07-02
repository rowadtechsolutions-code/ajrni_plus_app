import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/office_model.dart';

class OfficeService {
  final SupabaseClient _client;

  OfficeService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<void> upsertOffice(OfficeModel office) async {
    await _client
        .from(SupabaseTables.offices)
        .upsert(office.toJson(), onConflict: 'id');
  }

  Future<OfficeModel?> getOfficeById(String id) async {
    final response = await _client
        .from(SupabaseTables.offices)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response == null ? null : OfficeModel.fromJson(response);
  }

  Future<List<OfficeModel>> getActiveOffices() async {
    final response = await _client
        .from(SupabaseTables.offices)
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return response.map(OfficeModel.fromJson).toList();
  }

  Future<List<OfficeModel>> getActiveOfficesPaginated({
    int limit = 12,
    int offset = 0,
    String search = '',
    String country = '',
    String city = '',
  }) async {
    var query = _client
        .from(SupabaseTables.offices)
        .select()
        .eq('is_active', true);
    final term = search.trim();
    if (term.isNotEmpty) {
      query = query.or(
        'office_name.ilike.%$term%,bio.ilike.%$term%,city.ilike.%$term%,country.ilike.%$term%',
      );
    }
    if (country.trim().isNotEmpty) {
      query = query.ilike('country', '%${country.trim()}%');
    }
    if (city.trim().isNotEmpty) {
      query = query.ilike('city', '%${city.trim()}%');
    }
    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return response.map(OfficeModel.fromJson).toList();
  }

  Future<void> updateOffice(OfficeModel office) async {
    await _client
        .from(SupabaseTables.offices)
        .update(office.toJson()..remove('id'))
        .eq('id', office.id);
  }
}
