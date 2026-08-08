import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Layout values for the floating bottom navigation shell.
abstract class LayoutConstants {
  LayoutConstants._();

  static const double bottomNavBarHeight = 72;
  static const double bottomNavOuterMargin = 10;

  /// Scroll padding so the last list item can clear the floating nav.
  static double scrollBottomPadding(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return bottomNavBarHeight.h +
        bottomNavOuterMargin.h +
        safeBottom +
        16.h;
  }
}
