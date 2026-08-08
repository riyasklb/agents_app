import 'package:get/get.dart';

import '../../core/services/app_services.dart';
import '../../data/models/models.dart';

class EarningsController extends GetxController {
  final isLoading = true.obs;
  final summary = Rxn<EarningsSummary>();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      summary.value = await AppServices.earnings.getEarningsSummary();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadData();

  Future<bool> withdraw(double amount) =>
      AppServices.earnings.withdrawEarnings(amount);
}
