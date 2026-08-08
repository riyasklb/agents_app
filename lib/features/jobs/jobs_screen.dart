import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/layout_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import 'jobs_controller.dart';
import 'widgets/job_card.dart';

class JobsScreen extends GetView<JobsController> {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
            child: Obx(() {
              final count = controller.tabIndex.value == 0
                  ? controller.filteredAvailable.length
                  : _tabCount(controller, controller.tabIndex.value);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jobs',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$count ${_tabSubtitle(controller.tabIndex.value)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 18.h),
          _SegmentedTabs(controller: controller),
          SizedBox(height: 14.h),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: const [
                _AvailableTab(),
                _ActiveTab(),
                _SubmittedTab(),
                _CompletedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _tabCount(JobsController c, int index) => switch (index) {
        0 => c.filteredAvailable.length,
        1 => c.activeJobs.length,
        2 => c.submittedJobs.length,
        3 => c.completedJobs.length,
        _ => 0,
      };

  String _tabSubtitle(int index) => switch (index) {
        0 => 'assignments available',
        1 => 'in progress',
        2 => 'awaiting review',
        3 => 'completed',
        _ => 'assignments',
      };
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.controller});

  final JobsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.tabController,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            height: 44.h,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: List.generate(JobsController.tabLabels.length, (index) {
                final selected = controller.tabController.index == index;
                final count = _countForTab(controller, index);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.tabController.animateTo(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              JobsController.tabLabels[index],
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                            ),
                            if (count > 0) ...[
                              SizedBox(width: 5.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.accent.withValues(alpha: 0.12)
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppColors.accent
                                        : AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  int _countForTab(JobsController c, int index) => switch (index) {
        0 => c.availableJobs.length,
        1 => c.activeJobs.length,
        2 => c.submittedJobs.length,
        3 => c.completedJobs.length,
        _ => 0,
      };
}

class _AvailableTab extends GetView<JobsController> {
  const _AvailableTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            height: 46.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.65),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.03),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: TextField(
              onChanged: controller.setSearch,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name or location',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20.sp,
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 32.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: controller.filters.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final filter = controller.filters[index];
              return Obx(() {
                final selected = controller.selectedFilter.value == filter;
                return GestureDetector(
                  onTap: () => controller.toggleFilter(filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: selected ? AppColors.primaryGradient : null,
                      color: selected ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : AppColors.border.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        SizedBox(height: 14.h),
        Expanded(
          child: GetBuilder<JobsController>(
            id: 'available',
            builder: (c) {
              if (c.isLoading.value) return const _JobsListSkeleton();
              final jobs = c.filteredAvailable;
              if (jobs.isEmpty) {
                return const EmptyState(
                  icon: Icons.work_off_outlined,
                  title: 'No assignments found',
                  subtitle: 'Adjust filters or check back soon.',
                );
              }
              return RefreshIndicator(
                onRefresh: c.refresh,
                color: AppColors.accent,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    0,
                    20.w,
                    LayoutConstants.scrollBottomPadding(context),
                  ),
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) {
                    final job = jobs[i];
                    return Obx(
                      () => AvailableJobTile(
                        job: job,
                        isProcessing: c.isProcessing(job.id),
                        onTap: () => Get.toNamed(
                          AppRoutes.jobDetails,
                          arguments: job.id,
                        ),
                        onAccept: () => c.acceptJob(job.id),
                        onReject: () => c.rejectJob(job.id),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 50 * i))
                        .slideY(begin: 0.04, end: 0);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActiveTab extends GetView<JobsController> {
  const _ActiveTab();

  @override
  Widget build(BuildContext context) {
    return _JobStatusList(
      jobs: controller.activeJobs,
      emptyTitle: 'No active assignments',
      emptySubtitle: 'Accept a job to begin verification.',
      itemBuilder: (job, i) => StatusJobTile(
        job: job,
        statusLabel: job.status == JobStatus.inProgress ? 'In progress' : 'Active',
        statusColor: AppColors.accent,
        actionLabel: 'Continue →',
        onTap: () => Get.toNamed(AppRoutes.verification, arguments: job.id),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 50 * i))
          .slideY(begin: 0.04, end: 0),
    );
  }
}

class _SubmittedTab extends GetView<JobsController> {
  const _SubmittedTab();

  @override
  Widget build(BuildContext context) {
    return _JobStatusList(
      jobs: controller.submittedJobs,
      emptyTitle: 'Nothing submitted yet',
      emptySubtitle: 'Finished verifications will appear here.',
      itemBuilder: (job, i) => StatusJobTile(
        job: job,
        statusLabel: 'Under review',
        statusColor: AppColors.warning,
        onTap: () => Get.toNamed(AppRoutes.jobDetails, arguments: job.id),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 50 * i))
          .slideY(begin: 0.04, end: 0),
    );
  }
}

class _CompletedTab extends GetView<JobsController> {
  const _CompletedTab();

  @override
  Widget build(BuildContext context) {
    return _JobStatusList(
      jobs: controller.completedJobs,
      emptyTitle: 'No completed jobs',
      emptySubtitle: 'Your earnings history starts here.',
      itemBuilder: (job, i) => CompletedJobTile(
        job: job,
        onTap: () => Get.toNamed(AppRoutes.jobDetails, arguments: job.id),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 50 * i))
          .slideY(begin: 0.04, end: 0),
    );
  }
}

class _JobStatusList extends GetView<JobsController> {
  const _JobStatusList({
    required this.jobs,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.itemBuilder,
  });

  final RxList<VerificationJob> jobs;
  final String emptyTitle;
  final String emptySubtitle;
  final Widget Function(VerificationJob job, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const _JobsListSkeleton();
      if (jobs.isEmpty) {
        return EmptyState(
          icon: Icons.assignment_outlined,
          title: emptyTitle,
          subtitle: emptySubtitle,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.accent,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(
            20.w,
            4.h,
            20.w,
            LayoutConstants.scrollBottomPadding(context),
          ),
          itemCount: jobs.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, i) => itemBuilder(jobs[i], i),
        ),
      );
    });
  }
}

class _JobsListSkeleton extends StatelessWidget {
  const _JobsListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          20.w,
          0,
          20.w,
          LayoutConstants.scrollBottomPadding(context),
        ),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, __) => Container(
          height: 148.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}
