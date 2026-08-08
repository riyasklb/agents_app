import '../mock/mock_data.dart';
import '../models/models.dart';

class MockNotificationService {
  List<AppNotification> _notifications =
      List<AppNotification>.from(MockData.notifications);

  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List<AppNotification>.from(_notifications);
  }

  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] =
          _notifications[index].copyWith(isRead: true);
    }
  }

  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
  }

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;
}
