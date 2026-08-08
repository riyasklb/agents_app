import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/enums.dart';
import 'jobs_controller.dart';
import 'widgets/job_card.dart';

class JobsScreen extends GetView<JobsController> {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            child: Text(
              'Jobs',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          TabBar(
            controller: controller.tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Available'),
              Tab(text: 'Active'),
              Tab(text: 'Submitted'),
              Tab(text: 'Completed'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _AvailableTab(),
                _JobList(jobs: controller.activeJobs, isCompleted: false),
                _JobList(
                  jobs: controller.submittedJobs,
                  emptyTitle: 'No submitted jobs',
                ),
                _JobList(
                  jobs: controller.completedJobs,
                  isCompleted: true,
                  emptyTitle: 'No completed jobs',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableTab extends GetView<JobsController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          child: TextField(
            onChanged: controller.setSearch,
            decoration: InputDecoration(
              hintText: 'Search applications...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 38.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: controller.filters.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final filter = controller.filters[index];
              return Obx(() {
                final selected = controller.selectedFilter.value == filter;
                return FilterChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (_) => controller.toggleFilter(filter),
                  labelStyle: TextStyle(
                    fontSize: 12.sp,
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  showCheckmark: false,
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                );
              });
            },
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: GetBuilder<JobsController>(
            id: 'available',
            builder: (c) {
              final jobs = c.filteredAvailable;
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (jobs.isEmpty) {
                return const EmptyState(
                  icon: Icons.work_off_outlined,
                  title: 'No available jobs',
                  subtitle: 'Try adjusting your filters.',
                );
              }
              return RefreshIndicator(
                onRefresh: c.refresh,
                child: ListView.separated(
                  padding: EdgeInsets.all(20.w),
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) => JobCard(
                    job: jobs[i],
                    compact: true,
                    onTap: () => Get.toNamed(
                      AppRoutes.jobDetails,
                      arguments: jobs[i].id,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JobList extends GetView<JobsController> {
  const _JobList({
    required this.jobs,
    this.isCompleted = false,
    this.emptyTitle = 'No active jobs',
  });

  final RxList jobs;
  final bool isCompleted;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (jobs.isEmpty) {
        return EmptyState(
          icon: Icons.assignment_outlined,
          title: emptyTitle,
          subtitle: 'Check back later for updates.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.separated(
          padding: EdgeInsets.all(20.w),
          itemCount: jobs.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, i) {
            final job = jobs[i];
            if (isCompleted) {
              return CompletedJobCard(
                job: job,
                onTap: () =>
                    Get.toNamed(AppRoutes.jobDetails, arguments: job.id),
              );
            }
            return JobCard(
              job: job,
              onTap: () {
                if (job.status == JobStatus.accepted ||
                    job.status == JobStatus.inProgress) {
                  Get.toNamed(AppRoutes.verification, arguments: job.id);
                } else {
                  Get.toNamed(AppRoutes.jobDetails, arguments: job.id);
                }
              },
            );
          },
        ),
      );
    });
  }
}
