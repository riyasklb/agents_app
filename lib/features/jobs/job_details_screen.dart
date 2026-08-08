import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/app_services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import 'jobs_controller.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final _loading = true.obs;
  final _job = Rxn<VerificationJob>();
  late final String jobId;

  @override
  void initState() {
    super.initState();
    jobId = Get.arguments as String;
    _load();
  }

  Future<void> _load() async {
    _loading.value = true;
    _job.value = await AppServices.jobs.getJobById(jobId);
    _loading.value = false;
  }

  Future<void> _accept() async {
    await AppServices.jobs.acceptJob(jobId);
    if (Get.isRegistered<JobsController>()) {
      await Get.find<JobsController>().loadAll();
    }
    Get.toNamed(AppRoutes.jobAccepted, arguments: jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Verification Assignment'),
      body: PremiumBackground(
        child: Obx(() {
          if (_loading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final job = _job.value;
          if (job == null) {
            return const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Job not found',
              subtitle: 'This assignment may have been removed.',
            );
          }
          return _Content(job: job);
        }),
      ),
      bottomNavigationBar: Obx(() {
        final job = _job.value;
        if (job == null || job.status != JobStatus.available) {
          return const SizedBox.shrink();
        }
        return StickyBottomBar(
          child: PrimaryButton(
            label: 'Accept Assignment',
            onPressed: _accept,
          ),
        );
      }),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.job});

  final VerificationJob job;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            children: [
              StatusBadge(label: job.status.name.toUpperCase()),
              if (job.priority == JobPriority.high)
                const StatusBadge(
                  label: 'HIGH PRIORITY',
                  color: AppColors.error,
                  backgroundColor: AppColors.errorLight,
                ),
            ],
          ).animate().fadeIn(),
          SizedBox(height: 24.h),
          _Section(
            title: 'Applicant',
            child: Row(
              children: [
                AvatarWidget(initials: job.applicant.initials),
                SizedBox(width: 12.w),
                Text(
                  job.applicant.name,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Verification Type',
            child: Text(job.verificationType.label,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
          ),
          _Section(
            title: 'Location',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.location,
                    style:
                        TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
                Text(
                  '${Formatters.distance(job.distanceKm)} away',
                  style: TextStyle(
                      fontSize: 13.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Commission',
            child: Text(
              Formatters.currency(job.commission),
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ),
          ),
          _Section(
            title: 'Deadline',
            child: Text(
              _formatDeadline(job.deadline),
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Verification Requirements',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),
          GlassCard(
            child: Column(
              children: job.requirements.map((req) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.check_rounded,
                            size: 16.sp, color: AppColors.success),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(req, style: TextStyle(fontSize: 14.sp)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(deadline.year, deadline.month, deadline.day);
    if (d == today) return 'Today · ${Formatters.time(deadline)}';
    if (d == today.add(const Duration(days: 1))) {
      return 'Tomorrow · ${Formatters.time(deadline)}';
    }
    return Formatters.dateTime(deadline);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}
