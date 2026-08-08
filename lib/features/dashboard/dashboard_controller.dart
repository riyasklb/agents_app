import 'package:get/get.dart';

import '../../core/services/app_services.dart';
import '../../data/models/models.dart';

class DashboardController extends GetxController {
  final isLoading = true.obs;
  final stats = Rxn<DashboardStats>();
  final nearbyJobs = <VerificationJob>[].obs;

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
      nearbyJobs.assignAll(
        (results[1] as List<VerificationJob>).take(2).toList(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadData();
}
