import 'package:get/get.dart';

import '../../data/models/models.dart';
import '../../features/dashboard/dashboard_controller.dart';
import '../../features/jobs/jobs_controller.dart';

class ServiceLocation {
  const ServiceLocation({required this.label, required this.keyword});

  final String label;
  final String keyword;
}

class LocationController extends GetxController {
  static const locations = [
    ServiceLocation(label: 'Thrissur, Kerala', keyword: 'Thrissur'),
    ServiceLocation(label: 'Ollur, Thrissur', keyword: 'Ollur'),
    ServiceLocation(label: 'Mannuthy, Thrissur', keyword: 'Mannuthy'),
    ServiceLocation(label: 'Guruvayur, Thrissur', keyword: 'Guruvayur'),
    ServiceLocation(label: 'Kodungallur, Thrissur', keyword: 'Kodungallur'),
    ServiceLocation(label: 'Chalakudy, Thrissur', keyword: 'Chalakudy'),
    ServiceLocation(label: 'Kunnamkulam, Thrissur', keyword: 'Kunnamkulam'),
  ];

  final selectedIndex = 0.obs;

  ServiceLocation get selected => locations[selectedIndex.value];

  String get selectedLabel => selected.label;

  bool matchesJob(VerificationJob job) => matchesLocation(job.location);

  bool matchesLocation(String jobLocation) {
    final keyword = selected.keyword;
    if (keyword == 'Thrissur') return true;
    return jobLocation.toLowerCase().contains(keyword.toLowerCase());
  }

  List<VerificationJob> filterJobs(List<VerificationJob> jobs) {
    return jobs.where(matchesJob).toList();
  }

  void select(int index) {
    if (index < 0 || index >= locations.length) return;
    selectedIndex.value = index;
    _refreshLists();
  }

  void _refreshLists() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().applyLocationFilter();
    }
    if (Get.isRegistered<JobsController>()) {
      Get.find<JobsController>().applyLocationFilter();
    }
  }
}
