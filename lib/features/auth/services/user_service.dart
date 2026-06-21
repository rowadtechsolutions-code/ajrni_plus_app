import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _client;

  UserService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<void> upsertUser(UserModel user) async {
    await _client
        .from(SupabaseTables.users)
        .upsert(user.toJson(), onConflict: 'id');
  }

  Future<UserModel?> getUserById(String id) async {
    final response = await _client
        .from(SupabaseTables.users)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response == null ? null : UserModel.fromJson(response);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final response = await _client
        .from(SupabaseTables.users)
        .select()
        .eq('email', email.trim().toLowerCase())
        .maybeSingle();
    return response == null ? null : UserModel.fromJson(response);
  }

  Future<void> updateUser(UserModel user) async {
    await _client
        .from(SupabaseTables.users)
        .update(user.toJson()..remove('id'))
        .eq('id', user.id);
  }
}
