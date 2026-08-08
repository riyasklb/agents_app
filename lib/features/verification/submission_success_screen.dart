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
import '../shell/main_controller.dart';

class SubmissionSuccessScreen extends StatefulWidget {
  const SubmissionSuccessScreen({super.key});

  @override
  State<SubmissionSuccessScreen> createState() =>
      _SubmissionSuccessScreenState();
}

class _SubmissionSuccessScreenState extends State<SubmissionSuccessScreen> {
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
                title: 'Job not found',
                subtitle: 'Unable to load details.',
              );
            }
            return Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  const Spacer(),
                  const SuccessCheckmark(size: 110)
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                        duration: 700.ms,
                      ),
                  SizedBox(height: 28.h),
                  Text(
                    'Report submitted',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  SizedBox(height: 8.h),
                  Text(
                    'Your verification is under bank review',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 280.ms),
                  SizedBox(height: 28.h),
                  GlassCard(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AvatarWidget(
                              initials: job.applicant.initials,
                              imageUrl: job.applicant.avatarUrl,
                              size: 48,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.applicant.name,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    job.loanType.label,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Divider(color: AppColors.border.withValues(alpha: 0.6)),
                        SizedBox(height: 16.h),
                        _SummaryRow(
                          label: 'Application ID',
                          value: job.applicationId,
                        ),
                        SizedBox(height: 12.h),
                        _SummaryRow(
                          label: 'Commission',
                          value: Formatters.currency(job.commission),
                          valueColor: AppColors.success,
                        ),
                        SizedBox(height: 12.h),
                        const _SummaryRow(
                          label: 'Status',
                          value: 'Under review',
                          valueColor: AppColors.warning,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.06, end: 0),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Back to jobs',
                    icon: Icons.work_outline_rounded,
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.main);
                      Get.find<MainController>().changeTab(1);
                    },
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
