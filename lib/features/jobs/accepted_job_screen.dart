import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/app_services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/models.dart';
import 'widgets/job_card.dart';

class AcceptedJobScreen extends StatefulWidget {
  const AcceptedJobScreen({super.key});

  @override
  State<AcceptedJobScreen> createState() => _AcceptedJobScreenState();
}

class _AcceptedJobScreenState extends State<AcceptedJobScreen> {
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
    _job.value = await AppServices.jobs.getJobById(jobId);
    _loading.value = false;
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
                icon: Icons.error_outline,
                title: 'Assignment not found',
                subtitle: 'Unable to load details.',
              );
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: Get.back<void>,
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
                          Icons.close_rounded,
                          size: 20.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SuccessCheckmark(size: 100)
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                        duration: 700.ms,
                      ),
                  SizedBox(height: 28.h),
                  Text(
                    'You\'re all set',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.1, end: 0),
                  SizedBox(height: 8.h),
                  Text(
                    'Assignment accepted successfully',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 280.ms),
                  SizedBox(height: 28.h),
                  _JobSummaryCard(job: job)
                      .animate()
                      .fadeIn(delay: 350.ms)
                      .slideY(begin: 0.08, end: 0),
                  SizedBox(height: 20.h),
                  _NextSteps()
                      .animate()
                      .fadeIn(delay: 420.ms)
                      .slideY(begin: 0.06, end: 0),
                  const Spacer(),
                  SecondaryButton(
                    label: 'Navigate to location',
                    icon: Icons.navigation_rounded,
                    onPressed: () => Get.snackbar(
                      'Navigation',
                      'Opening maps to ${job.location}',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: EdgeInsets.all(16.w),
                      borderRadius: 12,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  PrimaryButton(
                    label: 'Start verification',
                    icon: Icons.verified_user_outlined,
                    onPressed: () =>
                        Get.toNamed(AppRoutes.verification, arguments: jobId),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _JobSummaryCard extends StatelessWidget {
  const _JobSummaryCard({required this.job});

  final VerificationJob job;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(18.w),
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
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${job.loanType.label} · ${job.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      Formatters.currency(job.commission),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '· ${jobDeadlineLabel(job.deadline)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextSteps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      ('Arrive at location', Icons.location_on_outlined),
      ('Verify OTP with applicant', Icons.sms_outlined),
      ('Complete on-site verification', Icons.verified_user_outlined),
      ('Submit and earn commission', Icons.payments_outlined),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s next',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...steps.asMap().entries.map((entry) {
            final isLast = entry.key == steps.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
              child: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(
                    entry.value.$2,
                    size: 16.sp,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      entry.value.$1,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
