import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/banner_model.dart';

class BannerService {
  final SupabaseClient _client;

  BannerService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<BannerModel>> getActiveBanners() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from(SupabaseTables.banners)
          .select()
          .eq('is_active', true)
          .lte('start_date', now)
          .gte('end_date', now)
          .order('created_at', ascending: false);
      return response.map(BannerModel.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }
}
