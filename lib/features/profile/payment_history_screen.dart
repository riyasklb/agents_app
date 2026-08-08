import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import 'profile_details_controller.dart';

class PaymentHistoryScreen extends GetView<PaymentHistoryController> {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final summary = controller.summary.value;
        if (summary == null) {
          return const EmptyState(
            icon: Icons.payments_outlined,
            title: 'No payments yet',
            subtitle: 'Submit verifications to start earning.',
          );
        }
        return ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            GlassCard(
              child: Row(
                children: [
                  _BalanceTile(
                    label: 'Available',
                    value: Formatters.currency(summary.availableBalance),
                  ),
                  _BalanceTile(
                    label: 'Pending',
                    value: Formatters.currency(summary.pendingAmount),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text('Payment lifecycle',
                style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Text(
              'Submission → Bank review → Payment credited to your UPI',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            ...summary.transactions.map(
              (txn) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: GlassCard(
                  child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(txn.title,
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            Formatters.date(txn.date),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.currency(txn.amount),
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        StatusBadge(
                          label: txn.status,
                          color: txn.status == 'Paid'
                              ? AppColors.success
                              : AppColors.warning,
                          backgroundColor: txn.status == 'Paid'
                              ? AppColors.successLight
                              : AppColors.warning.withValues(alpha: 0.12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ),
          ],
        );
      }),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
          Text(label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
