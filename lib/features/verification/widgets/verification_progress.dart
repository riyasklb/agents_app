import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

class VerificationProgress extends StatelessWidget {
  const VerificationProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.steps,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / totalSteps,
              minHeight: 5.h,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isActive = index == currentStep;
                final isCompleted = index < currentStep;
                return Padding(
                  padding: EdgeInsets.only(right: index < steps.length - 1 ? 4.w : 0),
                  child: Row(
                    children: [
                      Text(
                        step,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? AppColors.primary
                              : isCompleted
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                        ),
                      ),
                      if (index < steps.length - 1)
                        Icon(Icons.chevron_right_rounded,
                            size: 16.sp, color: AppColors.textTertiary),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
