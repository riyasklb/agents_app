import 'package:flutter/material.dart';
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
            child: Text(
              'Jobs',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _SegmentedTabs(controller: controller.tabController),
          SizedBox(height: 16.h),
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
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: List.generate(JobsController.tabLabels.length, (index) {
                final selected = controller.index == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.animateTo(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(vertical: 9.h),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        JobsController.tabLabels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
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
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.8),
              ),
            ),
            child: TextField(
              onChanged: controller.setSearch,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
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
          height: 34.h,
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
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12.sp,
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
        SizedBox(height: 12.h),
        Expanded(
          child: GetBuilder<JobsController>(
            id: 'available',
            builder: (c) {
              if (c.isLoading.value) return const _JobsListSkeleton();
              final jobs = c.filteredAvailable;
              if (jobs.isEmpty) {
                return const EmptyState(
                  icon: Icons.work_off_outlined,
                  title: 'No available jobs',
                  subtitle: 'Try adjusting your filters or check back later.',
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
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
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
                    );
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
      emptyTitle: 'No active jobs',
      emptySubtitle: 'Accept a job to get started.',
      itemBuilder: (job) => StatusJobTile(
        job: job,
        statusLabel: job.status == JobStatus.inProgress ? 'In progress' : 'Active',
        statusColor: AppColors.accent,
        onTap: () => Get.toNamed(AppRoutes.verification, arguments: job.id),
      ),
    );
  }
}

class _SubmittedTab extends GetView<JobsController> {
  const _SubmittedTab();

  @override
  Widget build(BuildContext context) {
    return _JobStatusList(
      jobs: controller.submittedJobs,
      emptyTitle: 'No submitted jobs',
      emptySubtitle: 'Completed verifications will appear here.',
      itemBuilder: (job) => StatusJobTile(
        job: job,
        statusLabel: 'Submitted',
        statusColor: AppColors.warning,
        onTap: () => Get.toNamed(AppRoutes.jobDetails, arguments: job.id),
      ),
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
      emptySubtitle: 'Your finished assignments will show here.',
      itemBuilder: (job) => CompletedJobTile(
        job: job,
        onTap: () => Get.toNamed(AppRoutes.jobDetails, arguments: job.id),
      ),
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
  final Widget Function(VerificationJob job) itemBuilder;

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
            0,
            20.w,
            LayoutConstants.scrollBottomPadding(context),
          ),
          itemCount: jobs.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (_, i) => itemBuilder(jobs[i]),
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
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, __) => Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}
