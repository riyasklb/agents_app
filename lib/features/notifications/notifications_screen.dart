import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/enums.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Notifications',
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: PremiumBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications',
              subtitle: "You're all caught up!",
            );
          }
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: controller.notifications.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final n = controller.notifications[i];
                return _Card(
                  notification: n,
                  onTap: () => controller.markAsRead(n.id),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.notification, required this.onTap});
  final dynamic notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: _color(notification.type).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(_icon(notification.type),
                color: _color(notification.type), size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(notification.message,
                    style: TextStyle(
                        fontSize: 13.sp, color: AppColors.textSecondary)),
                SizedBox(height: 6.h),
                Text(_timeAgo(notification.timestamp),
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(NotificationType t) => switch (t) {
        NotificationType.newJob => Icons.work_outline_rounded,
        NotificationType.verificationApproved => Icons.verified_rounded,
        NotificationType.paymentAdded => Icons.payments_outlined,
        NotificationType.general => Icons.notifications_outlined,
      };

  Color _color(NotificationType t) => switch (t) {
        NotificationType.newJob => AppColors.accent,
        NotificationType.verificationApproved => AppColors.success,
        NotificationType.paymentAdded => AppColors.warning,
        NotificationType.general => AppColors.textSecondary,
      };

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return DateFormat('dd MMM').format(t);
  }
}
