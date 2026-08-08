import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/layout_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/models.dart';
import '../../core/widgets/location_picker.dart';
import '../jobs/widgets/job_card.dart';
import '../shell/main_controller.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const _DashboardSkeleton();
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.accent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Header()
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.05, end: 0),
                      SizedBox(height: 20.h),
                      if (controller.stats.value != null)
                        _EarningsHero(stats: controller.stats.value!)
                            .animate()
                            .fadeIn(duration: 450.ms, delay: 80.ms)
                            .slideY(begin: 0.06, end: 0),
                      SizedBox(height: 28.h),
                      SectionHeader(
                        title: 'Nearby verifications',
                        actionLabel: 'See all',
                        onAction: () =>
                            Get.find<MainController>().changeTab(1),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
              if (controller.nearbyJobs.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No verifications nearby',
                    subtitle:
                        'Try another service location or check back later.',
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    0,
                    20.w,
                    LayoutConstants.scrollBottomPadding(context),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = controller.nearbyJobs[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: JobListTile(
                            job: job,
                            onTap: () => Get.toNamed(
                              AppRoutes.jobDetails,
                              arguments: job.id,
                            ),
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 60 * index),
                              )
                              .slideY(begin: 0.04, end: 0),
                        );
                      },
                      childCount: controller.nearbyJobs.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 24.sp,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Good morning,\n',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        fontSize: 15.sp,
                      ),
                    ),
                    TextSpan(
                      text: '${AppConstants.agentFirstName} 👋',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontSize: 26.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              const LocationPickerChip(),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.notifications),
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.8),
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 22.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EarningsHero extends StatelessWidget {
  const _EarningsHero({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final statItems = [
      ('${stats.available}', 'Available'),
      ('${stats.accepted}', 'Active'),
      ('${stats.completed}', 'Done'),
      ('${stats.pending}', 'Pending'),
    ];

    return AppCard(
      gradient: AppColors.earningsGradient,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'This month',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.north_east_rounded,
                      size: 12.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '${stats.monthlyGrowth}%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            Formatters.currency(stats.monthlyEarnings),
            style: TextStyle(
              fontSize: 34.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.2,
              height: 1.1,
            ),
          ),
          SizedBox(height: 16.h),
          MiniLineChart(
            data: stats.weeklyEarnings,
            height: 44.h,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          SizedBox(height: 18.h),
          Divider(
            color: Colors.white.withValues(alpha: 0.12),
            height: 1,
          ),
          SizedBox(height: 14.h),
          Row(
            children: statItems.map((item) {
              final isLast = item == statItems.last;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            item.$1,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.$2,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 1,
                        height: 28.h,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: 100.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
