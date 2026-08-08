import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
                  'Sign in to manage your verification assignments.',
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
                      Text(
                        'Mobile Number',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 16.sp),
                        decoration: InputDecoration(
                          hintText: 'Enter mobile number',
                          prefixIcon: const Icon(Icons.phone_android_rounded),
                          filled: true,
                          fillColor: AppColors.surface,
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
                            Text(
                              'OTP',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: controller.otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              style: TextStyle(fontSize: 16.sp),
                              decoration: InputDecoration(
                                hintText: 'Enter OTP (demo: 1234)',
                                prefixIcon:
                                    const Icon(Icons.lock_outline_rounded),
                                counterText: '',
                                filled: true,
                                fillColor: AppColors.surface,
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
                    label: 'Continue',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.continueLogin,
                  ),
                ).animate().fadeIn(delay: 450.ms),
                SizedBox(height: 24.h),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 16.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Secure access for verified field agents',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
