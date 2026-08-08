import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/app_services.dart';

class AuthController extends GetxController {
  final phoneController = TextEditingController(text: '9876543210');
  final otpController = TextEditingController();

  final showOtp = false.obs;
  final isLoading = false.obs;
  final isAuthenticated = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> continueLogin() async {
    if (!showOtp.value) {
      if (phoneController.text.length < 10) {
        _snack('Please enter a valid mobile number');
        return;
      }
      showOtp.value = true;
      return;
    }

    isLoading.value = true;
    final success = await AppServices.auth.login(
      phoneController.text,
      otpController.text.isEmpty ? '1234' : otpController.text,
    );
    isLoading.value = false;

    if (success) {
      isAuthenticated.value = true;
      Get.offAllNamed(AppRoutes.main);
    } else {
      _snack('Invalid OTP. Demo OTP: 1234');
    }
  }

  Future<void> logout() async {
    await AppServices.auth.logout();
    isAuthenticated.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  void _snack(String message) {
    Get.snackbar(
      'Sign in',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
