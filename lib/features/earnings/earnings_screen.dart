import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/models.dart';
import 'earnings_controller.dart';

class EarningsScreen extends GetView<EarningsController> {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value) return const _Skeleton();
        final data = controller.summary.value;
        if (data == null) return const SizedBox.shrink();
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Earnings',
                          style: TextStyle(
                              fontSize: 28.sp, fontWeight: FontWeight.w800)),
                      SizedBox(height: 24.h),
                      AppCard(
                        gradient: AppColors.earningsGradient,
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Formatters.currency(data.monthlyTotal),
                              style: TextStyle(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Total earnings this month',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8)),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '+${data.monthlyGrowth}% from last month',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13.sp),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      GlassCard(
                        padding: EdgeInsets.fromLTRB(12.w, 20.h, 12.w, 8.h),
                        child: EarningsBarChart(
                          data: data.dailyEarnings
                              .map((d) => (day: d.day, amount: d.amount))
                              .toList(),
                          height: 180.h,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                              child: _BalanceCard(
                                  'Available', data.availableBalance,
                                  AppColors.success)),
                          SizedBox(width: 10.w),
                          Expanded(
                              child: _BalanceCard(
                                  'Pending', data.pendingAmount,
                                  AppColors.warning)),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      _BalanceCard('Total Earned', data.totalEarned,
                          AppColors.primary,
                          fullWidth: true),
                      SizedBox(height: 20.h),
                      PrimaryButton(
                        label: 'Withdraw Earnings',
                        icon: Icons.account_balance_wallet_outlined,
                        onPressed: () => _withdrawSheet(data),
                      ),
                      SizedBox(height: 28.h),
                      Text('Earnings History',
                          style: TextStyle(
                              fontSize: 17.sp, fontWeight: FontWeight.w700)),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _TxnRow(transaction: data.transactions[i]),
                    ),
                    childCount: data.transactions.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _withdrawSheet(EarningsSummary data) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Withdraw Earnings',
                style: TextStyle(
                    fontSize: 20.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Text(
              'Withdraw ${Formatters.currency(data.availableBalance)} to your bank account?',
            ),
            SizedBox(height: 24.h),
            PrimaryButton(
              label: 'Confirm Withdrawal',
              onPressed: () async {
                Get.back();
                await controller.withdraw(data.availableBalance);
                Get.snackbar(
                  'Success',
                  'Withdrawal request submitted!',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: EdgeInsets.all(16.w),
                  borderRadius: 12,
                );
              },
            ),
            SizedBox(height: 12.h),
            SecondaryButton(label: 'Cancel', onPressed: Get.back),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard(this.label, this.amount, this.color,
      {this.fullWidth = false});
  final String label;
  final double amount;
  final Color color;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
          SizedBox(height: 6.h),
          Text(Formatters.currency(amount),
              style: TextStyle(
                  fontSize: 20.sp, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.transaction});
  final EarningTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.arrow_downward_rounded,
                color: AppColors.success, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(Formatters.date(transaction.date),
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            Formatters.currency(transaction.amount),
            style: TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Container(
              height: 140.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
