import 'package:get/get.dart';

import '../../core/controllers/allocation_controller.dart';
import '../../core/services/app_services.dart';
import '../../data/models/models.dart';

class DashboardController extends GetxController {
  final isLoading = true.obs;
  final stats = Rxn<DashboardStats>();
  final nearbyJobs = <VerificationJob>[].obs;

  List<VerificationJob> _allAvailable = [];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        AppServices.jobs.getDashboardStats(),
        AppServices.jobs.getAvailableJobs(),
      ]);
      stats.value = results[0] as DashboardStats;
      _allAvailable = results[1] as List<VerificationJob>;
      applyLocationFilter();
    } finally {
      isLoading.value = false;
    }
  }

  void applyLocationFilter() {
    final allocation = Get.find<AllocationController>();
    nearbyJobs.assignAll(allocation.filterJobs(_allAvailable).take(2).toList());
  }

  Future<void> refresh() => loadData();
}
