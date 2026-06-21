import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';

class FavoritesService {
  final SupabaseClient _client;

  FavoritesService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('يجب تسجيل الدخول أولًا.');
    return id;
  }

  Future<Set<String>> getFavoriteCarIds() async {
    final response = await _client
        .from(SupabaseTables.favorites)
        .select('car_id')
        .eq('user_id', _userId);
    return response.map((row) => row['car_id'].toString()).toSet();
  }

  Future<void> add(String carId) async {
    await _client.from(SupabaseTables.favorites).upsert({
      'user_id': _userId,
      'car_id': carId,
    }, onConflict: 'user_id,car_id');
  }

  Future<void> remove(String carId) async {
    await _client
        .from(SupabaseTables.favorites)
        .delete()
        .eq('user_id', _userId)
        .eq('car_id', carId);
  }
}
