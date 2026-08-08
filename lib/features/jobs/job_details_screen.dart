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
import 'widgets/job_card.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final _loading = true.obs;
  final _processing = false.obs;
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
    _processing.value = true;
    try {
      await AppServices.jobs.acceptJob(jobId);
      if (Get.isRegistered<JobsController>()) {
        await Get.find<JobsController>().loadAll();
      }
      Get.toNamed(AppRoutes.jobAccepted, arguments: jobId);
    } finally {
      _processing.value = false;
    }
  }

  Future<void> _reject() async {
    _processing.value = true;
    try {
      await AppServices.jobs.rejectJob(jobId);
      if (Get.isRegistered<JobsController>()) {
        await Get.find<JobsController>().loadAll();
      }
      Get.back<void>();
      Get.snackbar(
        'Assignment declined',
        'Removed from your available list.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      _processing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: Obx(() {
            if (_loading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }
            final job = _job.value;
            if (job == null) {
              return const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Assignment not found',
                subtitle: 'It may have been assigned to another agent.',
              );
            }
            return Column(
              children: [
                _DetailsHeader(onBack: Get.back<void>),
                Expanded(child: _Content(job: job)),
                if (job.status == JobStatus.available)
                  Obx(
                    () => _BottomActions(
                      onReject: _reject,
                      onAccept: _accept,
                      isProcessing: _processing.value,
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 20.w, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.7),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Assignment',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.job});

  final VerificationJob job;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VerificationHero(job: job)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.06, end: 0),
          SizedBox(height: 16.h),
          _ApplicantCard(job: job)
              .animate()
              .fadeIn(duration: 400.ms, delay: 60.ms)
              .slideY(begin: 0.05, end: 0),
          SizedBox(height: 16.h),
          _InfoGrid(job: job)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.05, end: 0),
          SizedBox(height: 20.h),
          Text(
            'Requirements',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          _RequirementsList(requirements: job.requirements)
              .animate()
              .fadeIn(duration: 400.ms, delay: 140.ms),
        ],
      ),
    );
  }
}

class _VerificationHero extends StatelessWidget {
  const _VerificationHero({required this.job});

  final VerificationJob job;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.earningsGradient,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.verificationType.label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              if (job.priority == JobPriority.high)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Urgent',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            job.applicationId,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _HeroChip(
                icon: Icons.schedule_outlined,
                label: _formatDeadline(job.deadline),
              ),
              _HeroChip(
                icon: Icons.location_on_outlined,
                label: Formatters.distance(job.distanceKm),
              ),
              _HeroChip(
                icon: Icons.timer_outlined,
                label: '${job.estimatedMinutes} min est.',
              ),
            ],
          ),
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

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: Colors.white.withValues(alpha: 0.9)),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({required this.job});

  final VerificationJob job;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          AvatarWidget(
            initials: job.applicant.initials,
            imageUrl: job.applicant.avatarUrl,
            size: 56,
            showBorder: true,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.applicant.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  job.verificationType.label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  job.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.job});

  final VerificationJob job;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Verification ID', job.applicationId),
      ('Phone', job.applicant.phone),
      ('Address', job.applicant.address),
      ('Status', job.status.name.toUpperCase()),
    ];

    return Column(
      children: items.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.w,
                child: Text(
                  item.$1,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RequirementsList extends StatelessWidget {
  const _RequirementsList({required this.requirements});

  final List<String> requirements;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: requirements.asMap().entries.map((entry) {
          final isLast = entry.key == requirements.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onReject,
    required this.onAccept,
    required this.isProcessing,
  });

  final VoidCallback onReject;
  final VoidCallback onAccept;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(flex: 1,
              child: SecondaryButton(
                label: 'Decline',
                icon: Icons.close_rounded,
                onPressed: isProcessing ? () {} : onReject,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 1,
              child: PrimaryButton(
                label: 'Accept',
                icon: Icons.check_rounded,
                isLoading: isProcessing,
                onPressed: isProcessing ? null : onAccept,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
