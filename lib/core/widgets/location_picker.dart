import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/allocation_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

class LocationPickerChip extends StatelessWidget {
  const LocationPickerChip({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AllocationController>();

    return Obx(() {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.allocationPreferences),
          borderRadius: BorderRadius.circular(compact ? 10.r : 12.r),
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10.w : 12.w,
              vertical: compact ? 6.h : 8.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(compact ? 10.r : 12.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.75),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: compact ? 14.sp : 15.sp,
                  color: AppColors.accent,
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    controller.summaryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 12.sp : 13.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: compact ? 16.sp : 18.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
