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
      body: PremiumBackground(
        child: SafeArea(
          child: Obx(() {
            if (_loading.value) {
              return const Center(child: CircularProgressIndicator());
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
                  const SuccessCheckmark(size: 120)
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                        duration: 700.ms,
                      ),
                  SizedBox(height: 32.h),
                  Text('Verification Submitted',
                      style: TextStyle(
                          fontSize: 24.sp, fontWeight: FontWeight.w800)),
                  SizedBox(height: 12.h),
                  Text(
                    'Your report has been submitted for bank review.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 32.h),
                  GlassCard(
                    child: Column(
                      children: [
                        _Row(label: 'Application ID', value: job.applicationId),
                        Divider(height: 24.h),
                        _Row(
                          label: 'Commission',
                          value: Formatters.currency(job.commission),
                          valueColor: AppColors.success,
                        ),
                        Divider(height: 24.h),
                        const _Row(
                          label: 'Status',
                          value: 'Under Review',
                          valueColor: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Back to Jobs',
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

class _Row extends StatelessWidget {
  const _Row({
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
        Text(label),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }
}
