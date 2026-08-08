import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import 'verification_controller.dart';
import 'widgets/media_capture.dart';
import 'widgets/otp_input.dart';
import 'widgets/verification_progress.dart';

class VerificationFlowScreen extends StatefulWidget {
  const VerificationFlowScreen({super.key});

  @override
  State<VerificationFlowScreen> createState() => _VerificationFlowScreenState();
}

class _VerificationFlowScreenState extends State<VerificationFlowScreen> {
  final _remarksController = TextEditingController();
  VerificationController get controller => Get.find<VerificationController>();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
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
                _FlowHeader(onClose: Get.back<void>),
                VerificationProgress(
                  currentStep: session.currentStep,
                  totalSteps: session.totalSteps,
                  steps: VerificationController.steps,
                  description: VerificationController
                      .stepDescriptions[session.currentStep],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                    child: _stepContent(session.currentStep, job, session)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.03, end: 0),
                  ),
                ),
                _BottomBar(
                  session: session,
                  remarksController: _remarksController,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _stepContent(
    int step,
    VerificationJob job,
    VerificationSession session,
  ) {
    return switch (step) {
      0 => _OverviewStep(job: job, controller: controller),
      1 => _ArriveStep(job: job, session: session),
      2 => _PhotosStep(session: session),
      3 => _VerifyStep(session: session, remarks: _remarksController),
      4 => _SubmitStep(job: job, session: session),
      _ => const SizedBox.shrink(),
    };
  }
}

class _FlowHeader extends StatelessWidget {
  const _FlowHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 4.h, 20.w, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
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
          SizedBox(width: 8.w),
          Text(
            'Field Verification',
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

class _BottomBar extends GetView<VerificationController> {
  const _BottomBar({
    required this.session,
    required this.remarksController,
  });

  final VerificationSession session;
  final TextEditingController remarksController;

  @override
  Widget build(BuildContext context) {
    final isLastStep = session.currentStep >= 4;
    final blockReason = controller.continueBlockReason;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (blockReason != null && !isLastStep)
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  blockReason,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            Row(
              children: [
                if (session.currentStep > 0)
                  Expanded(
                    child: SecondaryButton(
                      label: 'Back',
                      icon: Icons.arrow_back_rounded,
                      onPressed: controller.previousStep,
                    ),
                  ),
                if (session.currentStep > 0) SizedBox(width: 12.w),
                Expanded(
                  flex: session.currentStep > 0 ? 2 : 1,
                  child: isLastStep
                      ? PrimaryButton(
                          label: 'Submit report',
                          icon: Icons.send_rounded,
                          isLoading: controller.isSubmitting.value,
                          onPressed: controller.canProceed
                              ? () async {
                                  await controller.submit();
                                  Get.offNamed(
                                    AppRoutes.submissionSuccess,
                                    arguments: controller.jobId,
                                  );
                                }
                              : null,
                        )
                      : PrimaryButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward_rounded,
                          onPressed:
                              controller.canProceed ? controller.nextStep : null,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 0: Overview ────────────────────────────────────────────────────────

class _OverviewStep extends StatelessWidget {
  const _OverviewStep({required this.job, required this.controller});

  final VerificationJob job;
  final VerificationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (job.progressDeadline != null)
          AppCard(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Icon(Icons.timer_outlined,
                    color: AppColors.warning, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Update within ${_remaining(job.progressDeadline!)} or case returns to queue',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (job.progressDeadline != null) SizedBox(height: 12.h),
        GlassCard(
          padding: EdgeInsets.all(18.w),
          child: Row(
            children: [
              AvatarWidget(
                initials: job.applicant.initials,
                imageUrl: job.applicant.avatarUrl,
                size: 60,
              //  showBorder: true,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.applicant.name,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${job.verificationType.label} · ${job.applicationId}',
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
        ),
        SizedBox(height: 14.h),
        _InfoTile(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: job.location,
        ),
        _InfoTile(
          icon: Icons.timer_outlined,
          label: 'Estimated time',
          value: '${job.estimatedMinutes} minutes',
        ),
        _InfoTile(
          icon: Icons.schedule_outlined,
          label: 'Deadline',
          value: _deadline(job.deadline),
        ),
        SizedBox(height: 20.h),
        Text(
          'What you\'ll do',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        const _ChecklistItem(
          number: '1',
          text: 'Arrive at location & verify OTP with applicant',
        ),
        const _ChecklistItem(
          number: '2',
          text: 'Capture ID, photos & property evidence',
        ),
        const _ChecklistItem(
          number: '3',
          text: 'Record video, answer questions & submit',
        ),
        SizedBox(height: 16.h),
        SecondaryButton(
          label: 'Request deadline extension',
          icon: Icons.more_time_rounded,
          onPressed: () => _showExtensionSheet(context, controller),
        ),
      ],
    );
  }

  String _remaining(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return '0m';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m';
  }

  void _showExtensionSheet(
    BuildContext context,
    VerificationController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request 24-hour extension',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Select a valid reason. Deadline will be extended automatically.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                ...ExtensionReason.values.map(
                  (reason) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(reason.label),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.pop(context);
                      controller.requestExtension(reason);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _deadline(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) return 'Today · ${Formatters.time(d)}';
    return Formatters.dateTime(d);
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.textTertiary),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: Arrive + OTP ────────────────────────────────────────────────────

class _ArriveStep extends GetView<VerificationController> {
  const _ArriveStep({required this.job, required this.session});

  final VerificationJob job;
  final VerificationSession session;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: AppColors.earningsGradient,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      color: Colors.white.withValues(alpha: 0.9), size: 22.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      job.location,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                '${Formatters.distance(job.distanceKm)} from your location',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        if (!session.gpsConfirmed)
          PrimaryButton(
            label: 'I\'ve arrived at location',
            icon: Icons.gps_fixed_rounded,
            onPressed: controller.confirmGps,
          )
        else
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 22.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location confirmed',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Within ${session.gpsDistanceMeters.round()}m of target',
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
          ),
        if (session.gpsConfirmed) ...[
          SizedBox(height: 20.h),
          const OtpVerificationCard(),
        ],
      ],
    );
  }
}

// ─── Step 2: Photos ──────────────────────────────────────────────────────────

class _PhotosStep extends GetView<VerificationController> {
  const _PhotosStep({required this.session});

  final VerificationSession session;

  static const _items = [
    ('media-001', 'Government ID', Icons.badge_outlined),
    ('media-002', 'Applicant Photo', Icons.person_outline_rounded),
    ('media-003', 'Property Photo', Icons.home_outlined),
    ('media-004', 'Entrance Photo', Icons.door_front_door_outlined),
    ('media-005', 'Name Plate', Icons.signpost_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final captured = controller.capturedPhotoCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: captured / _items.length,
                  minHeight: 6.h,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              '$captured/${_items.length}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ..._items.map((item) {
          final media = session.media.firstWhere((m) => m.id == item.$1);
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: VerificationPhotoTile(
              mediaId: item.$1,
              label: item.$2,
              icon: item.$3,
              isCaptured: media.isCaptured,
              previewPath: media.thumbnailPath,
              geoStamp: media.geoStamp,
            ),
          );
        }),
      ],
    );
  }
}

// ─── Step 3: Video + Questions ───────────────────────────────────────────────

class _VerifyStep extends GetView<VerificationController> {
  const _VerifyStep({required this.session, required this.remarks});

  final VerificationSession session;
  final TextEditingController remarks;

  @override
  Widget build(BuildContext context) {
    final video = session.media.firstWhere((m) => m.id == 'media-006');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video recording',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10.h),
        if (video.isCaptured)
          CapturedVideoCard(
            label: 'Verification Video',
            filePath: video.thumbnailPath ?? '',
            durationSeconds: video.durationSeconds ?? 0,
            onRetake: () => Get.toNamed(
              AppRoutes.videoVerification,
              arguments: controller.jobId,
            ),
          )
        else
          AppCard(
            onTap: () => Get.toNamed(
              AppRoutes.videoVerification,
              arguments: controller.jobId,
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 16.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Icon(Icons.videocam_rounded,
                      size: 32.sp, color: Colors.white),
                ),
                SizedBox(height: 14.h),
                Text('Record verification video',
                    style: TextStyle(
                        fontSize: 15.sp, fontWeight: FontWeight.w600)),
                Text('Max 60 seconds',
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.textSecondary)),
              ],
            ),
          ),
        SizedBox(height: 24.h),
        Text(
          'Quick checklist',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 12.h),
        ...session.questions.map((q) {
          return Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.question,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _YesNoButton(
                        label: 'Yes',
                        isSelected: q.answer == true,
                        onTap: () => controller.answerQuestion(q.id, true),
                      ),
                      SizedBox(width: 10.w),
                      _YesNoButton(
                        label: 'No',
                        isSelected: q.answer == false,
                        onTap: () => controller.answerQuestion(q.id, false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 8.h),
        Text(
          'Notes (optional)',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: remarks,
          maxLines: 3,
          onChanged: controller.setRemarks,
          decoration: InputDecoration(
            hintText: 'Any additional observations...',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _YesNoButton extends StatelessWidget {
  const _YesNoButton({
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
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.accentGradient : null,
            color: isSelected ? null : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step 4: Submit ──────────────────────────────────────────────────────────

class _SubmitStep extends StatelessWidget {
  const _SubmitStep({required this.job, required this.session});

  final VerificationJob job;
  final VerificationSession session;

  @override
  Widget build(BuildContext context) {
    final photoCount = session.media
        .where((m) => m.isCaptured && m.type == MediaType.photo)
        .length;
    final video = session.media.firstWhere((m) => m.type == MediaType.video);

    return Column(
      children: [
        Container(
          width: 88.w,
          height: 88.w,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.task_alt_rounded,
              size: 44.sp, color: AppColors.success),
        ),
        SizedBox(height: 16.h),
        Text(
          'Ready to submit',
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800),
        ),
        Text(
          'Review your verification before sending',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 24.h),
        _ReviewRow(
          label: 'Location & OTP',
          done: session.gpsConfirmed && session.otpVerified,
        ),
        _ReviewRow(label: 'Photos captured', done: photoCount >= 5),
        _ReviewRow(label: 'Video recorded', done: video.isCaptured),
        _ReviewRow(
          label: 'Questions answered',
          done: session.questions.every((q) => q.answer != null),
        ),
        SizedBox(height: 16.h),
        AppCard(
          padding: EdgeInsets.all(18.w),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 22.sp,
                color: AppColors.accent,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.verificationType.label,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      job.applicationId,
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
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: done ? AppColors.success : AppColors.textTertiary,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: done ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
