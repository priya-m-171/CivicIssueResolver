import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => [..._notifications];

  List<AppNotification> notificationsFor(String role, String userId) {
    // Supabase RLS already filters notifications to only those meant for the user.
    // We just return them sorted.
    final list = [..._notifications];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int unreadCount(String role, String userId) {
    return notificationsFor(role, userId).where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String id) async {
    try {
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);

      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        _notifications[idx].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification read: \$e');
    }
  }

  Future<void> markAllAsRead(String role, String userId) async {
    try {
      // Find all unread in local list
      final unreadIds = _notifications
          .where((n) => !n.isRead)
          .map((n) => n.id)
          .toList();

      if (unreadIds.isEmpty) return;

      // Update in Supabase
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .inFilter(
            'id',
            unreadIds,
          ); // 'in' is a reserved keyword in some contexts, but supabase dart uses inFilter

      for (var n in _notifications) {
        n.isRead = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications read: \$e');
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    try {
      final response = await SupabaseService.client
          .from('notifications')
          .insert(notification.toJson())
          .select()
          .single();

      final newNotification = AppNotification.fromJson(response);
      _notifications.insert(0, newNotification);
      notifyListeners();
    } catch (e) {
      debugPrint('Error inserting notification: \$e');
    }
  }

  Future<void> loadNotifications() async {
    try {
      // Supabase RLS filters this for the user automatically based on our policy
      final data = await SupabaseService.client
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      _notifications = data
          .map<AppNotification>((e) => AppNotification.fromJson(e))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: \$e');
    }
  }

  Future<void> resetData() async {
    await loadNotifications();
  }
}
