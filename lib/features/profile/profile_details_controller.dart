import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/app_services.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';

class ProfileDetailsController extends GetxController {
  final agent = MockData.agent.obs;
  final isSaving = false.obs;

  late final nameController = TextEditingController(text: agent.value.name);
  late final phoneController = TextEditingController(text: agent.value.phone);
  late final addressController =
      TextEditingController(text: agent.value.address);
  late final upiController = TextEditingController(text: agent.value.upiId);

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    upiController.dispose();
    super.onClose();
  }

  Future<void> save() async {
    isSaving.value = true;
    agent.value = agent.value.copyWith(
      name: nameController.text,
      phone: phoneController.text,
      address: addressController.text,
      upiId: upiController.text,
    );
    await AppServices.auth.updateAgentProfile(agent.value);
    isSaving.value = false;
    Get.back<void>();
    Get.snackbar(
      'Profile updated',
      'Your details have been saved',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

class AcceptedCasesController extends GetxController {
  final cases = <VerificationJob>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    cases.assignAll(
      await AppServices.jobs.getAcceptedCasesForAgent(MockData.agent.id),
    );
    isLoading.value = false;
  }
}

class PaymentHistoryController extends GetxController {
  final summary = Rxn<EarningsSummary>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    summary.value = await AppServices.earnings.getEarningsSummary();
    isLoading.value = false;
  }
}
