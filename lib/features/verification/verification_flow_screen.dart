import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import 'verification_controller.dart';
import 'widgets/media_capture.dart';
import 'widgets/verification_progress.dart';

class VerificationFlowScreen extends GetView<VerificationController> {
  const VerificationFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final remarksController = TextEditingController();

    return Scaffold(
      appBar: AppAppBar(
        title: 'Verification',
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: Get.back,
        ),
      ),
      body: PremiumBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final session = controller.session.value;
          final job = controller.job.value;
          if (session == null || job == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Session error',
              subtitle: 'Unable to start verification.',
            );
          }
          return Column(
            children: [
              VerificationProgress(
                currentStep: session.currentStep,
                totalSteps: session.totalSteps,
                steps: VerificationController.steps,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: _stepContent(
                    session.currentStep,
                    job,
                    session,
                    remarksController,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final session = controller.session.value;
        if (session == null) return const SizedBox.shrink();
        return StickyBottomBar(
          child: session.currentStep < 5
              ? PrimaryButton(
                  label: 'Continue',
                  onPressed: controller.nextStep,
                )
              : PrimaryButton(
                  label: 'Submit Verification Report',
                  isLoading: controller.isSubmitting.value,
                  onPressed: () async {
                    await controller.submit();
                    Get.offNamed(
                      AppRoutes.submissionSuccess,
                      arguments: controller.jobId,
                    );
                  },
                ),
        );
      }),
    );
  }

  Widget _stepContent(
    int step,
    VerificationJob job,
    VerificationSession session,
    TextEditingController remarks,
  ) {
    switch (step) {
      case 0:
        return _ApplicantStep(job: job);
      case 1:
        return _IdentityStep(session: session);
      case 2:
        return _AddressStep(session: session);
      case 3:
        return _MediaStep();
      case 4:
        return _QuestionsStep(session: session, remarks: remarks);
      case 5:
        return _ReviewStep(job: job, session: session);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ApplicantStep extends StatelessWidget {
  const _ApplicantStep({required this.job});
  final VerificationJob job;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Applicant Details',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 16.h),
        ...[
          ('Name', job.applicant.name),
          ('Phone', job.applicant.phone),
          ('Address', job.applicant.address),
          ('Loan Type', job.loanType.label),
          ('Application ID', job.applicationId),
        ].map((e) => _InfoCard(label: e.$1, value: e.$2)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12.sp, color: AppColors.textSecondary)),
            SizedBox(height: 4.h),
            Text(value,
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _IdentityStep extends GetView<VerificationController> {
  const _IdentityStep({required this.session});
  final VerificationSession session;

  @override
  Widget build(BuildContext context) {
    final govId = session.media.firstWhere((m) => m.id == 'media-001');
    final photo = session.media.firstWhere((m) => m.id == 'media-002');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verify Applicant Identity',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 16.h),
        MediaCaptureButton(
          label: 'Government ID',
          isCaptured: govId.isCaptured,
          onCapture: () => controller.captureMedia('media-001'),
        ),
        SizedBox(height: 12.h),
        MediaCaptureButton(
          label: 'Applicant Photo',
          isCaptured: photo.isCaptured,
          onCapture: () => controller.captureMedia('media-002'),
        ),
      ],
    );
  }
}

class _AddressStep extends GetView<VerificationController> {
  const _AddressStep({required this.session});
  final VerificationSession session;

  @override
  Widget build(BuildContext context) {
    final property = session.media.firstWhere((m) => m.id == 'media-003');
    final entrance = session.media.firstWhere((m) => m.id == 'media-004');
    final namePlate = session.media.firstWhere((m) => m.id == 'media-005');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verify Residence',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 16.h),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    session.gpsConfirmed
                        ? Icons.gps_fixed_rounded
                        : Icons.gps_not_fixed_rounded,
                    color: session.gpsConfirmed
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    session.gpsConfirmed
                        ? 'Location detected ✓'
                        : 'Detecting location...',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: session.gpsConfirmed
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (session.gpsConfirmed) ...[
                SizedBox(height: 8.h),
                Text('Within expected location'),
                Text(
                  'Distance: ${session.gpsDistanceMeters.round()} meters',
                  style: TextStyle(
                      fontSize: 12.sp, color: AppColors.textSecondary),
                ),
              ] else ...[
                SizedBox(height: 12.h),
                PrimaryButton(
                  label: 'Confirm GPS Location',
                  height: 46.h,
                  onPressed: controller.confirmGps,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16.h),
        PhotoCaptureTile(
          label: 'Property Photo',
          isCaptured: property.isCaptured,
          onCapture: () => controller.captureMedia('media-003'),
        ),
        PhotoCaptureTile(
          label: 'Entrance Photo',
          isCaptured: entrance.isCaptured,
          onCapture: () => controller.captureMedia('media-004'),
        ),
        PhotoCaptureTile(
          label: 'Name Plate',
          isCaptured: namePlate.isCaptured,
          onCapture: () => controller.captureMedia('media-005'),
        ),
      ],
    );
  }
}

class _MediaStep extends GetView<VerificationController> {
  @override
  Widget build(BuildContext context) {
    final session = controller.session.value;
    final video = session?.media.firstWhere((m) => m.id == 'media-006');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Video Verification',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 8.h),
        Text('Record a short video confirming applicant and property.',
            style: TextStyle(color: AppColors.textSecondary)),
        SizedBox(height: 20.h),
        if (video != null && video.isCaptured)
          MediaCaptureButton(
            label: 'Verification Video',
            isCaptured: true,
            isVideo: true,
            durationSeconds: video.durationSeconds ?? 32,
            onCapture: () {},
          )
        else
          AppCard(
            onTap: () => Get.toNamed(
              AppRoutes.videoVerification,
              arguments: controller.jobId,
            ),
            padding: EdgeInsets.all(28.w),
            child: Column(
              children: [
                Container(
                  width: 88.w,
                  height: 88.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.error, width: 3),
                  ),
                  child: Icon(Icons.videocam_rounded,
                      size: 36.sp, color: AppColors.error),
                ),
                SizedBox(height: 16.h),
                Text('Record Video',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Max 60 seconds',
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.textSecondary)),
              ],
            ),
          ),
        if (video != null && !video.isCaptured) ...[
          SizedBox(height: 12.h),
          SecondaryButton(
            label: 'Simulate Video Capture',
            onPressed: () =>
                controller.captureMedia('media-006', durationSeconds: 32),
          ),
        ],
      ],
    );
  }
}

class _QuestionsStep extends GetView<VerificationController> {
  const _QuestionsStep({required this.session, required this.remarks});
  final VerificationSession session;
  final TextEditingController remarks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...session.questions.map((q) {
          return Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.category,
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8.h),
                Text(q.question,
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _RadioOption(
                      label: 'Yes',
                      isSelected: q.answer == true,
                      onTap: () => controller.answerQuestion(q.id, true),
                    ),
                    SizedBox(width: 12.w),
                    _RadioOption(
                      label: 'No',
                      isSelected: q.answer == false,
                      onTap: () => controller.answerQuestion(q.id, false),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        Text('Additional Observation',
            style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        TextField(
          controller: remarks,
          maxLines: 4,
          onChanged: controller.setRemarks,
          decoration: const InputDecoration(
            hintText: 'Add your observations...',
          ),
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  const _RadioOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.job, required this.session});
  final VerificationJob job;
  final VerificationSession session;

  @override
  Widget build(BuildContext context) {
    final photoCount = session.media
        .where((m) => m.isCaptured && m.type == MediaType.photo)
        .length;
    final video = session.media.firstWhere((m) => m.type == MediaType.video);
    final remarks = session.remarks.isNotEmpty
        ? session.remarks
        : 'Applicant was available at the provided address and the residence details matched the submitted application.';

    return Column(
      children: [
        CircularProgressRing(progress: 1, size: 100, label: '100%'),
        SizedBox(height: 12.h),
        Text('Review Verification',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
        Text('100% Complete',
            style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
        SizedBox(height: 28.h),
        _ReviewItem(title: 'Applicant', value: '✓ Verified'),
        _ReviewItem(title: 'Identity', value: '✓ Completed'),
        _ReviewItem(
          title: 'Address',
          value: session.gpsConfirmed ? '✓ GPS Confirmed' : '○ Pending',
        ),
        _ReviewItem(title: 'Photos', value: '✓ $photoCount Photos'),
        _ReviewItem(
          title: 'Video',
          value: video.isCaptured
              ? '✓ ${video.durationSeconds ?? 32}s'
              : '○ Not captured',
        ),
        _ReviewItem(
          title: 'Questionnaire',
          value: session.questions.every((q) => q.answer != null)
              ? '✓ Completed'
              : '○ Incomplete',
        ),
        SizedBox(height: 16.h),
        GlassCard(child: Text(remarks)),
        SizedBox(height: 16.h),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Commission', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                Formatters.currency(job.commission),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 80.h),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
