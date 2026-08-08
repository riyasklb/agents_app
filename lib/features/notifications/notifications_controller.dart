import 'package:get/get.dart';

import '../../core/services/app_services.dart';
import '../../data/models/models.dart';

class NotificationsController extends GetxController {
  final isLoading = true.obs;
  final notifications = <AppNotification>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      notifications.assignAll(
        await AppServices.notifications.getNotifications(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    await AppServices.notifications.markAsRead(id);
    await loadData();
  }

  Future<void> markAllRead() async {
    await AppServices.notifications.markAllAsRead();
    await loadData();
  }

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;
}
