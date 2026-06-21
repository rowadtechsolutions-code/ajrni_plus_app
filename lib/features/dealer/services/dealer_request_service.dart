import 'package:supabase_flutter/supabase_flutter.dart';

class DealerRequestService {
  final SupabaseClient _client;

  DealerRequestService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRequests(String officeId) async {
    try {
      final rows = await _client
          .from('BookingRequestOffices')
          .select('*, request:BookingRequests(*)')
          .eq('office_id', officeId)
          .neq('status', 'rejected')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } on PostgrestException catch (error) {
      if (error.code == 'PGRST205' || error.code == '42P01') return [];
      rethrow;
    }
  }
}
