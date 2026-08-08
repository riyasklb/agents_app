import 'package:get/get.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_controller.dart';
import '../../features/earnings/earnings_controller.dart';
import '../../features/jobs/accepted_job_screen.dart';
import '../../features/jobs/job_details_screen.dart';
import '../../features/jobs/jobs_controller.dart';
import '../../features/notifications/notifications_controller.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_controller.dart';
import '../../features/shell/main_controller.dart';
import '../../features/shell/main_shell.dart';
import '../../features/verification/submission_success_screen.dart';
import '../../features/verification/verification_controller.dart';
import '../../features/verification/verification_flow_screen.dart';
import '../../features/verification/video_verification_screen.dart';
import '../bindings/initial_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.main;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(AuthController.new);
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainShell(),
      binding: BindingsBuilder(() {
        Get.lazyPut(MainController.new);
        Get.lazyPut(AuthController.new, fenix: true);
        Get.lazyPut(DashboardController.new);
        Get.lazyPut(JobsController.new);
        Get.lazyPut(EarningsController.new);
        Get.lazyPut(ProfileController.new);
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.jobDetails,
      page: () => const JobDetailsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.jobAccepted,
      page: () => const AcceptedJobScreen(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: AppRoutes.verification,
      page: () => const VerificationFlowScreen(),
      binding: BindingsBuilder(() {
        final jobId = Get.arguments as String;
        Get.lazyPut(() => VerificationController(jobId: jobId));
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.videoVerification,
      page: () => const VideoVerificationScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.submissionSuccess,
      page: () => const SubmissionSuccessScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(NotificationsController.new);
      }),
      transition: Transition.rightToLeft,
    ),
  ];

  static void initServices() => InitialBinding().dependencies();
}
