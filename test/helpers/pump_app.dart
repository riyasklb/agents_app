import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Pumps a widget with ScreenUtil and GetX configured for tests.
Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  Size designSize = const Size(390, 844),
  bool settle = true,
  bool scrollable = false,
}) async {
  await tester.binding.setSurfaceSize(designSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final body = scrollable
      ? SingleChildScrollView(child: child)
      : SizedBox(width: designSize.width, height: designSize.height, child: child);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      builder: (_, __) => GetMaterialApp(
        home: Scaffold(body: body),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}
