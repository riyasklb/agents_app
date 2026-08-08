import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../dashboard/dashboard_screen.dart';
import '../earnings/earnings_screen.dart';
import '../jobs/jobs_screen.dart';
import '../profile/profile_screen.dart';
import 'main_controller.dart';

class MainShell extends GetView<MainController> {
  const MainShell({super.key});

  static const _pages = [
    DashboardScreen(),
    JobsScreen(),
    EarningsScreen(),
    ProfileScreen(),
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.assignment_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'Jobs', 'Earnings', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey(controller.currentIndex.value),
              child: _pages[controller.currentIndex.value],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(() => _PremiumBottomNav(
            currentIndex: controller.currentIndex.value,
            onTap: (i) {
              HapticFeedback.selectionClick();
              controller.changeTab(i);
            },
          )),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  const _PremiumBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 32.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(MainShell._labels.length, (index) {
            final selected = currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.accentGradient : null,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 12.r,
                              offset: Offset(0, 4.h),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MainShell._icons[index],
                        size: 22.sp,
                        color: selected
                            ? Colors.white
                            : AppColors.textTertiary,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        MainShell._labels[index],
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
