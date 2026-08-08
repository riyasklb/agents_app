import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'signup_controller.dart';

class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: Get.back<void>,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Create account',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _stepSubtitle(controller.step.value),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  GlassCard(
                    padding: EdgeInsets.all(20.w),
                    child: _stepContent(controller.step.value),
                  ),
                  SizedBox(height: 24.h),
                  PrimaryButton(
                    label: controller.step.value == 2 ? 'Verify & continue' : 'Continue',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.nextStep,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  String _stepSubtitle(int step) => switch (step) {
        0 => 'Step 1 of 3 · Mobile number',
        1 => 'Step 2 of 3 · Set your PIN',
        _ => 'Step 3 of 3 · OTP verification',
      };

  Widget _stepContent(int step) {
    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Full name'),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                hintText: 'Your name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            SizedBox(height: 16.h),
            _label('Mobile number'),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '10-digit mobile number',
                prefixIcon: Icon(Icons.phone_android_rounded),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Create PIN'),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: '4–6 digit PIN',
                prefixIcon: Icon(Icons.pin_rounded),
                counterText: '',
              ),
            ),
            SizedBox(height: 16.h),
            _label('Confirm PIN'),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Re-enter PIN',
                prefixIcon: Icon(Icons.pin_outlined),
                counterText: '',
              ),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('OTP sent to ${controller.phoneController.text}'),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Enter OTP (demo: 1234)',
                prefixIcon: Icon(Icons.sms_outlined),
                counterText: '',
              ),
            ),
          ],
        );
    }
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      );
}
