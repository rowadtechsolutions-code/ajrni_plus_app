import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmTokenService {
  FcmTokenService._();

  static final FcmTokenService _instance = FcmTokenService._();
  factory FcmTokenService() => _instance;

  bool _listenerRegistered = false;
  bool _syncing = false;
  String? _cachedToken;

  Future<void> init() async {
    if (_listenerRegistered) {
      await _refreshToken();
      return;
    }
    _listenerRegistered = true;

    final messaging = FirebaseMessaging.instance;
    messaging.onTokenRefresh.listen((newToken) {
      _cachedToken = newToken;
      _syncIfLoggedIn(newToken);
    });

    await _refreshToken();
  }

  Future<void> _refreshToken() async {
    final messaging = FirebaseMessaging.instance;
    final currentToken = await messaging.getToken();
    debugPrint(
      'FCM token: ${currentToken == null ? 'null (check iOS permission/APNs)' : '${currentToken.substring(0, 12)}...'}',
    );
    if (currentToken != null && currentToken != _cachedToken) {
      _cachedToken = currentToken;
      await _syncIfLoggedIn(currentToken);
    }
  }

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await FirebaseMessaging.instance.getToken();
    return _cachedToken;
  }

  Future<void> syncCurrentDeviceToken() async {
    _cachedToken = null;
    final token = await getToken();
    if (token == null) {
      debugPrint('FCM sync skipped: token is null');
      return;
    }
    await _syncIfLoggedIn(token);
  }

  Future<void> deactivateCurrentToken() async {
    debugPrint('FCM deactivate: started');
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('FCM deactivate skipped: no current user');
        return;
      }
      debugPrint('FCM deactivate: user id = ${user.id}');

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        debugPrint('FCM deactivate skipped: token is null');
        return;
      }
      debugPrint('FCM deactivate: token starts with ${token.substring(0, 10)}...');

      await Supabase.instance.client
          .from('user_devices')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('fcm_token', token);

      debugPrint('FCM deactivate: update sent');

      final rows = await Supabase.instance.client
          .from('user_devices')
          .select('user_id,fcm_token,is_active')
          .eq('user_id', user.id)
          .eq('fcm_token', token);

      debugPrint('FCM deactivate verification: $rows');
    } on PostgrestException catch (e) {
      debugPrint('FCM deactivate PostgrestException: ${e.message} code=${e.code}');
    } catch (e) {
      debugPrint('FCM deactivate error: $e');
    }
    debugPrint('FCM deactivate: finished');
  }

  Future<void> _syncIfLoggedIn(String token) async {
    if (_syncing) return;
    _syncing = true;
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      final platform = _detectPlatform();

      await Supabase.instance.client.from('user_devices').upsert({
        'user_id': currentUser.id,
        'fcm_token': token,
        'platform': platform,
        'is_active': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,fcm_token');

      debugPrint('FCM token synced successfully');
    } catch (e) {
      debugPrint('Failed to sync FCM token: $e');
    } finally {
      _syncing = false;
    }
  }

  String _detectPlatform() {
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
    } catch (_) {}
    return 'android';
  }
}
