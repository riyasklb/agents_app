import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

class VerificationProgress extends StatelessWidget {
  const VerificationProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.steps,
    this.description,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> steps;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(),
              Text(
                '${(((currentStep + 1) / totalSteps) * 100).round()}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (description != null) ...[
            SizedBox(height: 4.h),
            Text(
              description!,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / totalSteps,
              minHeight: 4.h,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: List.generate(steps.length, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              gradient: isActive ? AppColors.accentGradient : null,
                              color: isCompleted
                                  ? AppColors.success
                                  : isActive
                                      ? null
                                      : AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive || isCompleted
                                    ? Colors.transparent
                                    : AppColors.border,
                              ),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? Icon(Icons.check_rounded,
                                      size: 14.sp, color: Colors.white)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isActive
                                            ? Colors.white
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            steps[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive
                                  ? AppColors.primary
                                  : isCompleted
                                      ? AppColors.success
                                      : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 12.w,
                        height: 2.h,
                        margin: EdgeInsets.only(bottom: 18.h),
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.4)
                            : AppColors.border,
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
