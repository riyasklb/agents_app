import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/enums.dart';
import '../../core/services/app_services.dart';
import '../../data/models/models.dart';
import '../dashboard/dashboard_controller.dart';
import '../earnings/earnings_controller.dart';
import '../jobs/jobs_controller.dart';
import 'widgets/media_preview.dart';

class VerificationController extends GetxController {
  VerificationController({required this.jobId});

  final String jobId;

  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final isVerifyingOtp = false.obs;
  final isSendingOtp = false.obs;
  final otpError = RxnString();
  final session = Rxn<VerificationSession>();
  final job = Rxn<VerificationJob>();

  static const steps = [
    'Overview',
    'Arrive',
    'Photos',
    'Verify',
    'Submit',
  ];

  static const stepDescriptions = [
    'Review assignment details',
    'Confirm location & verify OTP',
    'Capture required documents',
    'Record video & answer questions',
    'Review and submit report',
  ];

  static const photoMediaIds = [
    'media-001',
    'media-002',
    'media-003',
    'media-004',
    'media-005',
  ];

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    isLoading.value = true;
    try {
      job.value = await AppServices.jobs.getJobById(jobId);
      session.value = await AppServices.verification.startSession(jobId);
    } finally {
      isLoading.value = false;
    }
  }

  bool get canProceed {
    final s = session.value;
    if (s == null) return false;
    return switch (s.currentStep) {
      0 => true,
      1 => s.gpsConfirmed && s.otpVerified,
      2 => _photosComplete(s),
      3 => _videoComplete(s) && _questionsComplete(s),
      4 => true,
      _ => false,
    };
  }

  String? get continueBlockReason {
    final s = session.value;
    if (s == null) return null;
    return switch (s.currentStep) {
      1 when !s.gpsConfirmed => 'Confirm your arrival at the location',
      1 when !s.otpVerified => 'Enter the OTP sent to the applicant',
      2 when !_photosComplete(s) => 'Capture all required photos',
      3 when !_videoComplete(s) => 'Record the verification video',
      3 when !_questionsComplete(s) => 'Answer all verification questions',
      _ => null,
    };
  }

  bool _photosComplete(VerificationSession s) =>
      photoMediaIds.every((id) => s.media.any((m) => m.id == id && m.isCaptured));

  bool _videoComplete(VerificationSession s) =>
      s.media.any((m) => m.id == 'media-006' && m.isCaptured);

  bool _questionsComplete(VerificationSession s) =>
      s.questions.every((q) => q.answer != null);

  int get capturedPhotoCount {
    final s = session.value;
    if (s == null) return 0;
    return photoMediaIds
        .where((id) => s.media.any((m) => m.id == id && m.isCaptured))
        .length;
  }

  Future<void> nextStep() async {
    if (!canProceed) return;
    final s = session.value;
    if (s == null || s.currentStep >= 4) return;
    await AppServices.jobs.recordProgress(jobId);
    session.value =
        await AppServices.verification.updateStep(jobId, s.currentStep + 1);
    job.value = await AppServices.jobs.getJobById(jobId);
  }

  Future<void> previousStep() async {
    final s = session.value;
    if (s == null || s.currentStep <= 0) return;
    session.value =
        await AppServices.verification.updateStep(jobId, s.currentStep - 1);
  }

  Future<void> captureMedia(
    String mediaId, {
    int? durationSeconds,
    String? filePath,
  }) async {
    session.value = await AppServices.verification.captureMedia(
      jobId,
      mediaId,
      durationSeconds: durationSeconds,
      filePath: filePath,
    );
  }

  Future<void> capturePhoto(String mediaId) async {
    final context = Get.context;
    if (context == null) return;

    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return;

    final confirmed = await showPhotoCapturePreview(
      context,
      filePath: file.path,
    );
    if (!confirmed) {
      await capturePhoto(mediaId);
      return;
    }

    await captureMedia(mediaId, filePath: file.path);
    await AppServices.jobs.recordProgress(jobId);
    job.value = await AppServices.jobs.getJobById(jobId);
  }

  Future<void> captureVideo({
    required String filePath,
    required int durationSeconds,
  }) async {
    await captureMedia(
      'media-006',
      durationSeconds: durationSeconds,
      filePath: filePath,
    );
  }

  void previewPhoto(String filePath) {
    final context = Get.context;
    if (context == null) return;
    showPhotoViewer(context, filePath);
  }

  void previewVideo(String filePath, {int? durationSeconds}) {
    final context = Get.context;
    if (context == null) return;
    showVideoViewer(
      context,
      filePath: filePath,
      durationSeconds: durationSeconds,
    );
  }

  Future<void> confirmGps() async {
    session.value = await AppServices.verification.confirmGps(jobId);
    await AppServices.jobs.recordProgress(jobId);
    job.value = await AppServices.jobs.getJobById(jobId);
    if (session.value?.gpsConfirmed == true && session.value?.otpSent != true) {
      await sendOtp();
    }
  }

  Future<void> sendOtp() async {
    isSendingOtp.value = true;
    otpError.value = null;
    try {
      session.value = await AppServices.verification.sendOtp(jobId);
    } finally {
      isSendingOtp.value = false;
    }
  }

  Future<void> verifyOtp(String otp) async {
    isVerifyingOtp.value = true;
    otpError.value = null;
    try {
      final valid = await AppServices.verification.verifyOtp(jobId, otp);
      if (!valid) {
        otpError.value = 'Invalid OTP. Please try again.';
        return;
      }
      session.value = await AppServices.verification.getSession(jobId);
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  Future<void> answerQuestion(String questionId, bool answer) async {
    session.value = await AppServices.verification.answerQuestion(
      jobId,
      questionId,
      answer,
    );
  }

  Future<void> setRemarks(String remarks) async {
    session.value = await AppServices.verification.setRemarks(jobId, remarks);
  }

  Future<void> requestExtension(ExtensionReason reason) async {
    job.value = await AppServices.jobs.requestExtension(jobId, reason);
    Get.snackbar(
      'Deadline extended',
      'Case deadline extended by 24 hours',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> submit() async {
    isSubmitting.value = true;
    try {
      session.value = await AppServices.verification.submitVerification(jobId);
      final submitted = await AppServices.jobs.submitJob(jobId);
      job.value = submitted;
      await AppServices.earnings.onCaseSubmitted(submitted);
      _scheduleBankApproval(jobId);
      if (Get.isRegistered<JobsController>()) {
        await Get.find<JobsController>().loadAll();
      }
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().loadData();
      }
      if (Get.isRegistered<EarningsController>()) {
        await Get.find<EarningsController>().loadData();
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  void _scheduleBankApproval(String id) {
    Future<void>.delayed(const Duration(seconds: 4), () async {
      await AppServices.jobs.approveJob(id);
      await AppServices.earnings.simulateBankApproval(id);
      if (Get.isRegistered<JobsController>()) {
        await Get.find<JobsController>().loadAll();
      }
      if (Get.isRegistered<EarningsController>()) {
        await Get.find<EarningsController>().loadData();
      }
    });
  }

  String maskedApplicantPhone() {
    final phone = job.value?.applicant.phone ?? '';
    if (phone.length < 4) return '••••';
    return '•••• ${phone.substring(phone.length - 4)}';
  }
}
