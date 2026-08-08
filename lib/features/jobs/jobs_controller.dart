import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/controllers/allocation_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_services.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';

class JobsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final isLoading = true.obs;
  final tabIndex = 0.obs;
  final searchQuery = ''.obs;
  final selectedFilter = RxnString();
  final processingJobIds = <String>{}.obs;

  final availableJobs = <VerificationJob>[].obs;
  final activeJobs = <VerificationJob>[].obs;
  final submittedJobs = <VerificationJob>[].obs;
  final completedJobs = <VerificationJob>[].obs;

  final filters = [
    'Nearby',
    'Due Today',
    'Address',
    'Business',
    'Property',
    'Identity',
  ];

  static const tabLabels = ['Available', 'Active', 'Submitted', 'Done'];

  late final TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabLabels.length, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        tabIndex.value = tabController.index;
      }
    });
    loadAll();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        AppServices.jobs.getAvailableJobs(),
        AppServices.jobs.getActiveJobs(),
        AppServices.jobs.getSubmittedJobs(),
        AppServices.jobs.getCompletedJobs(),
      ]);
      availableJobs.assignAll(results[0] as List<VerificationJob>);
      activeJobs.assignAll(results[1] as List<VerificationJob>);
      submittedJobs.assignAll(results[2] as List<VerificationJob>);
      completedJobs.assignAll(results[3] as List<VerificationJob>);
      _applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  List<VerificationJob> get filteredAvailable {
    var jobs = List<VerificationJob>.from(availableJobs);
    if (searchQuery.value.isNotEmpty) {
      jobs = AppServices.jobs
          .searchJobs(searchQuery.value)
          .where((j) => j.status == JobStatus.available)
          .toList();
    }
    jobs = Get.find<AllocationController>().filterJobs(jobs);
    if (selectedFilter.value != null) {
      jobs = AppServices.jobs.filterJobs(
        jobs: jobs,
        filter: selectedFilter.value,
      );
    }
    return jobs;
  }

  List<VerificationJob> get filteredActive =>
      Get.find<AllocationController>().filterJobs(activeJobs);

  List<VerificationJob> get filteredSubmitted =>
      Get.find<AllocationController>().filterJobs(submittedJobs);

  List<VerificationJob> get filteredCompleted =>
      Get.find<AllocationController>().filterJobs(completedJobs);

  void applyLocationFilter() => update(['available', 'tabs']);

  bool isProcessing(String jobId) => processingJobIds.contains(jobId);

  void setSearch(String query) {
    searchQuery.value = query;
    update(['available']);
  }

  void toggleFilter(String filter) {
    selectedFilter.value = selectedFilter.value == filter ? null : filter;
    update(['available']);
  }

  void _applyFilters() => update(['available']);

  Future<void> refresh() => loadAll();

  Future<VerificationJob?> getJob(String id) =>
      AppServices.jobs.getJobById(id);

  Future<void> acceptJob(String id) async {
    if (isProcessing(id)) return;
    processingJobIds.add(id);
    try {
      await AppServices.jobs.acceptJob(id);
      await loadAll();
      Get.toNamed(AppRoutes.jobAccepted, arguments: id);
    } catch (e) {
      Get.snackbar(
        'Case unavailable',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      await loadAll();
    } finally {
      processingJobIds.remove(id);
    }
  }

  Future<void> rejectJob(String id) async {
    if (isProcessing(id)) return;
    processingJobIds.add(id);
    try {
      await AppServices.jobs.rejectJob(id);
      await loadAll();
      Get.snackbar(
        'Job declined',
        'This assignment has been removed from your list.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      processingJobIds.remove(id);
    }
  }
}
