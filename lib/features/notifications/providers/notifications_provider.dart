import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/notifications_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsService _service;

  NotificationsProvider({NotificationsService? service})
    : _service = service ?? NotificationsService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadNotifications({int limit = 30, int offset = 0}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await _service.getNotifications(limit: limit, offset: offset);
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load notifications: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
    await loadUnreadCount();
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _service.getUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load unread count: $e');
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index == -1) return;

    _notifications[index] = notification.copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
    if (_unreadCount > 0) _unreadCount--;
    notifyListeners();

    try {
      await _service.markAsRead(notification.id);
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
      _notifications[index] = notification;
      _unreadCount++;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final updated = _notifications.map((n) {
      if (!n.isRead) return n.copyWith(isRead: true, readAt: DateTime.now());
      return n;
    }).toList();
    _notifications = updated;
    _unreadCount = 0;
    notifyListeners();

    try {
      await _service.markAllAsRead();
    } catch (e) {
      debugPrint('Failed to mark all as read: $e');
      await loadUnreadCount();
      notifyListeners();
    }
  }
}
