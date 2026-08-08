import 'package:get/get.dart';

import '../../core/services/app_services.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../features/dashboard/dashboard_controller.dart';
import '../../features/jobs/jobs_controller.dart';

class AllocationController extends GetxController {
  final mode = AppServices.preferences.preferences.mode.obs;
  final selectedPincodes =
      AppServices.preferences.preferences.pincodes.obs;
  final distanceRadius =
      AppServices.preferences.preferences.distanceRadiusKm.obs;

  String get summaryLabel {
    if (mode.value == AllocationMode.pincode) {
      if (selectedPincodes.isEmpty) return 'All pincodes';
      if (selectedPincodes.length == 1) {
        return 'PIN ${selectedPincodes.first}';
      }
      return '${selectedPincodes.length} pincodes';
    }
    return 'Within ${distanceRadius.value.toStringAsFixed(0)} km';
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await AppServices.preferences.getAllocationPreferences();
    mode.value = prefs.mode;
    selectedPincodes.assignAll(prefs.pincodes);
    distanceRadius.value = prefs.distanceRadiusKm;
  }

  bool matchesJob(VerificationJob job) =>
      AppServices.preferences.matchesJob(job);

  List<VerificationJob> filterJobs(List<VerificationJob> jobs) =>
      AppServices.preferences.filterJobs(jobs);

  Future<void> save() async {
    await AppServices.preferences.saveAllocationPreferences(
      AgentAllocationPreferences(
        mode: mode.value,
        pincodes: List.from(selectedPincodes),
        distanceRadiusKm: distanceRadius.value,
      ),
    );
    _refreshLists();
  }

  void togglePincode(String pincode) {
    if (selectedPincodes.contains(pincode)) {
      selectedPincodes.remove(pincode);
    } else {
      selectedPincodes.add(pincode);
    }
  }

  bool addCustomPincode(String pincode) {
    final normalized = pincode.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(normalized)) return false;
    if (!selectedPincodes.contains(normalized)) {
      selectedPincodes.add(normalized);
    }
    return true;
  }

  void removePincode(String pincode) => selectedPincodes.remove(pincode);

  List<String> get customPincodes => selectedPincodes
      .where(
        (pin) => !MockData.availablePincodes.any((entry) => entry.$1 == pin),
      )
      .toList();

  void setMode(AllocationMode value) => mode.value = value;

  void setDistance(double value) => distanceRadius.value = value;

  void _refreshLists() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().applyLocationFilter();
    }
    if (Get.isRegistered<JobsController>()) {
      Get.find<JobsController>().applyLocationFilter();
    }
  }
}
