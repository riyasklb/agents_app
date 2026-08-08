import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/controllers/allocation_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/enums.dart';

class AllocationPreferencesController extends GetxController {
  final isOnboarding = false.obs;
  final isSaving = false.obs;

  AllocationController get allocation => Get.find<AllocationController>();

  @override
  void onInit() {
    super.onInit();
    isOnboarding.value = Get.arguments == true;
  }

  Future<void> save() async {
    isSaving.value = true;
    await allocation.save();
    isSaving.value = false;
    if (isOnboarding.value) {
      Get.offAllNamed(AppRoutes.main);
      return;
    }
    Get.back<void>();
    Get.snackbar(
      'Preferences saved',
      allocation.summaryLabel,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

class AllocationPreferencesScreen
    extends GetView<AllocationPreferencesController> {
  const AllocationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allocation = controller.allocation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Case allocation'),
        automaticallyImplyLeading: !controller.isOnboarding.value,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How should cases be allocated to you?',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: _ModeCard(
                          title: 'By PIN code',
                          subtitle: 'Select multiple service pincodes',
                          icon: Icons.pin_drop_outlined,
                          selected:
                              allocation.mode.value == AllocationMode.pincode,
                          onTap: () =>
                              allocation.setMode(AllocationMode.pincode),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _ModeCard(
                          title: 'By distance',
                          subtitle: 'Cases within a radius',
                          icon: Icons.radar_rounded,
                          selected:
                              allocation.mode.value == AllocationMode.distance,
                          onTap: () =>
                              allocation.setMode(AllocationMode.distance),
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 20.h),
              Expanded(
                child: Obx(() {
                  if (allocation.mode.value == AllocationMode.pincode) {
                    final customPincodes = allocation.customPincodes;
                    return ListView(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showAddPincodeDialog(
                            context,
                            allocation,
                          ),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add PIN code'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: BorderSide(color: AppColors.accent),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                        ),
                        if (customPincodes.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(
                            'Added pincodes',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ...customPincodes.map(
                            (pin) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.pin_drop_rounded,
                                color: AppColors.accent,
                              ),
                              title: Text('PIN $pin'),
                              subtitle: const Text('Custom pincode'),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textTertiary,
                                  size: 20.sp,
                                ),
                                onPressed: () =>
                                    allocation.removePincode(pin),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 16.h),
                        Text(
                          'Suggested pincodes',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ...MockData.availablePincodes.map((entry) {
                          final selected =
                              allocation.selectedPincodes.contains(entry.$1);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (_) =>
                                allocation.togglePincode(entry.$1),
                            title: Text('PIN ${entry.$1}'),
                            subtitle: Text(entry.$2),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maximum distance: ${allocation.distanceRadius.value.toStringAsFixed(0)} km',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Slider(
                        value: allocation.distanceRadius.value,
                        min: 5,
                        max: 30,
                        divisions: 5,
                        label:
                            '${allocation.distanceRadius.value.toStringAsFixed(0)} km',
                        onChanged: allocation.setDistance,
                      ),
                      Text(
                        'You will receive cases within this radius from your current location.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Obx(
                () => PrimaryButton(
                  label: controller.isOnboarding.value
                      ? 'Finish setup'
                      : 'Save preferences',
                  isLoading: controller.isSaving.value,
                  onPressed: controller.save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPincodeDialog(
    BuildContext context,
    AllocationController allocation,
  ) {
    final pinController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add PIN code'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter 6-digit PIN code',
              prefixIcon: Icon(Icons.pin_drop_outlined),
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final added = allocation.addCustomPincode(pinController.text);
                if (!added) {
                  Get.snackbar(
                    'Invalid PIN',
                    'Enter a valid 6-digit pincode',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                  return;
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? AppColors.accent : AppColors.textTertiary),
            SizedBox(height: 10.h),
            Text(title, style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
