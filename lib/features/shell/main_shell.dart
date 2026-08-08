import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/layout_constants.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: PremiumBackground(
              child: Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: KeyedSubtree(
                    key: ValueKey(controller.currentIndex.value),
                    child: _pages[controller.currentIndex.value],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: EdgeInsets.only(
                bottom: LayoutConstants.bottomNavOuterMargin.h,
              ),
              child: Obx(
                () => _FloatingBottomNav(
                  currentIndex: controller.currentIndex.value,
                  onTap: (index) {
                    HapticFeedback.selectionClick();
                    controller.changeTab(index);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _icons = [
    Icons.home_outlined,
    Icons.assignment_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.person_outline_rounded,
  ];

  static const _activeIcons = [
    Icons.home_rounded,
    Icons.assignment_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'Verifications', 'Earnings', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LayoutConstants.bottomNavBarHeight.h,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 1),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final selected = currentIndex == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  height: 58.h,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.accentGradient : null,
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 14.r,
                              offset: Offset(0, 5.h),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? _activeIcons[index] : _icons[index],
                        size: selected ? 23.sp : 21.sp,
                        color: selected
                            ? Colors.white
                            : AppColors.textTertiary,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        _labels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: selected ? 10.5.sp : 10.sp,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : AppColors.textTertiary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
