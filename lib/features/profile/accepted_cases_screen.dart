import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/enums.dart';
import '../jobs/widgets/job_card.dart';
import 'profile_details_controller.dart';

class AcceptedCasesScreen extends GetView<AcceptedCasesController> {
  const AcceptedCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accepted cases')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.cases.isEmpty) {
          return const EmptyState(
            icon: Icons.assignment_outlined,
            title: 'No accepted cases',
            subtitle: 'Cases you accept will appear here.',
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(20.w),
          itemCount: controller.cases.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, i) {
            final job = controller.cases[i];
            return StatusJobTile(
              job: job,
              statusLabel: _statusLabel(job.status),
              statusColor: AppColors.accent,
              onTap: () {
                if (job.status == JobStatus.accepted ||
                    job.status == JobStatus.inProgress) {
                  Get.toNamed(AppRoutes.verification, arguments: job.id);
                } else {
                  Get.toNamed(AppRoutes.jobDetails, arguments: job.id);
                }
              },
            );
          },
        );
      }),
    );
  }

  String _statusLabel(JobStatus status) => switch (status) {
        JobStatus.accepted => 'Accepted',
        JobStatus.inProgress => 'In progress',
        JobStatus.submitted => 'Submitted',
        _ => status.name,
      };
}
