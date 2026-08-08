import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/app_services.dart';

class SignupController extends GetxController {
  final phoneController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();
  final otpController = TextEditingController();
  final nameController = TextEditingController(text: 'New Agent');

  final step = 0.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    pinController.dispose();
    confirmPinController.dispose();
    otpController.dispose();
    nameController.dispose();
    super.onClose();
  }

  Future<void> nextStep() async {
    switch (step.value) {
      case 0:
        if (phoneController.text.length < 10) {
          _snack('Enter a valid mobile number');
          return;
        }
        step.value = 1;
      case 1:
        if (pinController.text.length < 4) {
          _snack('PIN must be at least 4 digits');
          return;
        }
        if (pinController.text != confirmPinController.text) {
          _snack('PINs do not match');
          return;
        }
        step.value = 2;
      case 2:
        await _verifyOtpAndSignup();
    }
  }

  Future<void> _verifyOtpAndSignup() async {
    isLoading.value = true;
    final success = await AppServices.auth.signUp(
      phone: phoneController.text,
      pin: pinController.text,
      otp: otpController.text.isEmpty ? '1234' : otpController.text,
      name: nameController.text,
    );
    isLoading.value = false;
    if (!success) {
      _snack('Invalid OTP. Demo OTP: 1234');
      return;
    }
    Get.offAllNamed(AppRoutes.allocationPreferences, arguments: true);
  }

  void _snack(String message) {
    Get.snackbar(
      'Signup',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
