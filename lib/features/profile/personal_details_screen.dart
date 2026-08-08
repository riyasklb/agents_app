import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/mock/mock_data.dart';
import 'profile_details_controller.dart';

class PersonalDetailsScreen extends GetView<ProfileDetailsController> {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agent = MockData.agent;
    return Scaffold(
      appBar: AppBar(title: const Text('Personal details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Basic information',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: controller.phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: controller.addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payments',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: controller.upiController,
                    decoration: const InputDecoration(labelText: 'UPI ID'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verification documents',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 14.h),
                  _DocRow(
                    label: 'Aadhaar',
                    value: agent.aadhaarMasked,
                    verified: agent.aadhaarVerified,
                  ),
                  _DocRow(
                    label: 'Certification',
                    value: agent.certification,
                    verified: agent.certificationVerified,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Obx(
              () => PrimaryButton(
                label: 'Save changes',
                isLoading: controller.isSaving.value,
                onPressed: controller.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({
    required this.label,
    required this.value,
    required this.verified,
  });

  final String label;
  final String value;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textSecondary)),
                Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          StatusBadge(
            label: verified ? 'Verified' : 'Pending',
            color: verified ? AppColors.success : AppColors.warning,
            backgroundColor: verified
                ? AppColors.successLight
                : AppColors.warning.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }
}
