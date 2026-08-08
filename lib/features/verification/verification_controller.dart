import 'package:get/get.dart';

import '../../core/services/app_services.dart';
import '../../data/models/models.dart';
import '../dashboard/dashboard_controller.dart';
import '../earnings/earnings_controller.dart';
import '../jobs/jobs_controller.dart';

class VerificationController extends GetxController {
  VerificationController({required this.jobId});

  final String jobId;

  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final session = Rxn<VerificationSession>();
  final job = Rxn<VerificationJob>();

  static const steps = [
    'Applicant',
    'Identity',
    'Address',
    'Media',
    'Questions',
    'Submit',
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

  Future<void> nextStep() async {
    final s = session.value;
    if (s == null || s.currentStep >= 5) return;
    session.value =
        await AppServices.verification.updateStep(jobId, s.currentStep + 1);
  }

  Future<void> goToStep(int step) async {
    session.value = await AppServices.verification.updateStep(jobId, step);
  }

  Future<void> captureMedia(String mediaId, {int? durationSeconds}) async {
    session.value = await AppServices.verification.captureMedia(
      jobId,
      mediaId,
      durationSeconds: durationSeconds,
    );
  }

  Future<void> confirmGps() async {
    session.value = await AppServices.verification.confirmGps(jobId);
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

  Future<void> submit() async {
    isSubmitting.value = true;
    try {
      session.value =
          await AppServices.verification.submitVerification(jobId);
      await AppServices.jobs.submitJob(jobId);
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
}
