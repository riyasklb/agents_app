import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.h),
                Center(
                  child: const AppLogo(size: 72, showSubtitle: true)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.15, end: 0),
                ),
                SizedBox(height: 48.h),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.05, end: 0),
                SizedBox(height: 8.h),
                Text(
                  'Sign in with your mobile number and OTP.',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 250.ms),
                SizedBox(height: 36.h),
                GlassCard(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Mobile Number'),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 16.sp),
                        decoration: _inputDecoration(
                          hint: 'Enter mobile number',
                          icon: Icons.phone_android_rounded,
                        ),
                      ),
                      Obx(() {
                        if (!controller.showOtp.value) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            _fieldLabel('OTP'),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: controller.otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              style: TextStyle(fontSize: 16.sp),
                              decoration: _inputDecoration(
                                hint: 'Enter OTP (demo: 1234)',
                                icon: Icons.lock_outline_rounded,
                                counterText: '',
                              ),
                            ),
                          ],
                        ).animate().fadeIn().slideY(begin: 0.08, end: 0);
                      }),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),
                SizedBox(height: 28.h),
                Obx(
                  () => PrimaryButton(
                    label: controller.showOtp.value ? 'Sign in' : 'Continue',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.continueLogin,
                  ),
                ).animate().fadeIn(delay: 450.ms),
                SizedBox(height: 16.h),
                // Center(
                //   child: TextButton(
                //     onPressed: () => Get.toNamed(AppRoutes.signup),
                //     child: Text(
                //       'New agent? Create account',
                //       style: TextStyle(
                //         fontSize: 14.sp,
                //         fontWeight: FontWeight.w600,
                //         color: AppColors.accent,
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String counterText = '',
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      counterText: counterText,
      filled: true,
      fillColor: AppColors.surface,
    );
  }
}
