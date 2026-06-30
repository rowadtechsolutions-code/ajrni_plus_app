import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationsService {
  final SupabaseClient _client;

  NotificationsService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<NotificationModel>> getNotifications({
    int limit = 30,
    int offset = 0,
  }) async {
    final userId = _userId;
    if (userId == null) return [];

    final end = offset + limit - 1;
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, end);

    final list = response as List;
    return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> getUnreadCount() async {
    final userId = _userId;
    if (userId == null) return 0;

    final response = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    final list = response as List;
    return list.length;
  }

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', notificationId);
    debugPrint('Notification $notificationId marked as read');
  }

  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId == null) return;

    await _client
        .from('notifications')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('is_read', false);
    debugPrint('All notifications marked as read');
  }
}
