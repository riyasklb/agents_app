import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/mock/mock_verification_service.dart';
import '../verification_controller.dart';

class OtpVerificationCard extends StatefulWidget {
  const OtpVerificationCard({super.key});

  @override
  State<OtpVerificationCard> createState() => _OtpVerificationCardState();
}

class _OtpVerificationCardState extends State<OtpVerificationCard> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  VerificationController get controller => Get.find<VerificationController>();

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  PinTheme _pinTheme({bool hasError = false}) {
    return PinTheme(
      width: 48.w,
      height: 54.h,
      textStyle: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: hasError
              ? AppColors.error
              : AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme = _pinTheme();
    final focusedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
    );
    final submittedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration?.copyWith(
        color: AppColors.accent.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
    );
    final errorTheme = _pinTheme(hasError: true);

    return Obx(() {
      final session = controller.session.value;
      if (session == null) return const SizedBox.shrink();

      if (session.otpVerified) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_rounded, color: AppColors.success, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OTP verified',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      'Applicant identity confirmed at location',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      final hasError = controller.otpError.value != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter OTP from applicant',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            session.otpSent
                ? 'Sent to ${controller.maskedApplicantPhone()}'
                : 'Sending OTP to applicant...',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),
          Center(
            child: Pinput(
              length: 6,
              controller: _pinController,
              focusNode: _focusNode,
              enabled: !controller.isVerifyingOtp.value,
              defaultPinTheme: defaultTheme,
              focusedPinTheme: focusedTheme,
              submittedPinTheme: submittedTheme,
              errorPinTheme: errorTheme,
              forceErrorState: hasError,
              keyboardType: TextInputType.number,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: controller.verifyOtp,
              onChanged: (_) {
                if (hasError) controller.otpError.value = null;
              },
              separatorBuilder: (index) => SizedBox(width: 8.w),
            ),
          ),
          if (controller.isVerifyingOtp.value) ...[
            SizedBox(height: 16.h),
            const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
          if (hasError) ...[
            SizedBox(height: 12.h),
            Center(
              child: Text(
                controller.otpError.value!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16.sp, color: AppColors.accent),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Demo OTP: ${MockVerificationService.demoOtp}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (session.otpSent) ...[
            SizedBox(height: 10.h),
            Center(
              child: TextButton(
                onPressed: controller.isSendingOtp.value
                    ? null
                    : () {
                        _pinController.clear();
                        controller.sendOtp();
                      },
                child: Text(
                  controller.isSendingOtp.value ? 'Resending...' : 'Resend OTP',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
