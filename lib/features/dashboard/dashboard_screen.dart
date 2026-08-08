import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/models.dart';
import '../jobs/widgets/job_card.dart';
import '../shell/main_controller.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value) {
          return _DashboardSkeleton();
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.accent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(),
                      SizedBox(height: 24.h),
                      if (controller.stats.value != null)
                        _EarningsHero(stats: controller.stats.value!)
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.08, end: 0),
                      SizedBox(height: 20.h),
                      if (controller.stats.value != null)
                        _QuickStats(stats: controller.stats.value!),
                      SizedBox(height: 28.h),
                      SectionHeader(
                        title: 'Jobs Near You',
                        actionLabel: 'View All →',
                        onAction: () =>
                            Get.find<MainController>().changeTab(1),
                      ),
                      SizedBox(height: 14.h),
                    ],
                  ),
                ),
              ),
              if (controller.nearbyJobs.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No jobs nearby',
                    subtitle:
                        'Check back later for new verification assignments.',
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = controller.nearbyJobs[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: JobCard(
                            job: job,
                            onTap: () => Get.toNamed(
                              AppRoutes.jobDetails,
                              arguments: job.id,
                            ),
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 80 * index),
                              )
                              .slideX(begin: 0.04, end: 0),
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${AppConstants.agentFirstName} 👋',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14.sp,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        AppConstants.agentLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _IconButton(
          icon: Icons.notifications_outlined,
          onTap: () => Get.toNamed(AppRoutes.notifications),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12.r,
            ),
          ],
        ),
        child: Icon(icon, size: 22.sp, color: AppColors.textPrimary),
      ),
    );
  }
}

class _EarningsHero extends StatelessWidget {
  const _EarningsHero({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.earningsGradient,
      padding: EdgeInsets.all(22.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'This Month',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up_rounded,
                        size: 14.sp, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      '+${stats.monthlyGrowth}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'from last month',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 18.h),
          MiniLineChart(
            data: stats.weeklyEarnings,
            height: 48.h,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Available', '${stats.available}', AppColors.accent),
      ('Accepted', '${stats.accepted}', AppColors.warning),
      ('Completed', '${stats.completed}', AppColors.success),
      ('Pending', '${stats.pending}', AppColors.textSecondary),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: item != items.last ? 10.w : 0),
            child: GlassCard(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
              child: Column(
                children: [
                  Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: item.$3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.$1,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
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
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              height: 160.h,
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
