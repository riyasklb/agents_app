import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/app_services.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/models.dart';

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
                subtitle: 'Unable to load assignment.',
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
                  SizedBox(height: 32.h),
                  Text(
                    'Assignment Accepted ✓',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'You have successfully accepted this verification.',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    job.applicant.name,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  SecondaryButton(
                    label: 'Navigate to Applicant',
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
                    label: 'Start Verification',
                    icon: Icons.verified_user_outlined,
                    onPressed: () =>
                        Get.toNamed(AppRoutes.verification, arguments: jobId),
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
