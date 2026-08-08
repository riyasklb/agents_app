import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/layout_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/mock/mock_data.dart';
import '../auth/auth_controller.dart';
import 'profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Obx(() {
        final agent = controller.agent.value;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20.w,
            12.h,
            20.w,
            LayoutConstants.scrollBottomPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile',
                  style: TextStyle(
                      fontSize: 28.sp, fontWeight: FontWeight.w800)),
              SizedBox(height: 20.h),
              GlassCard(
                padding: EdgeInsets.all(22.w),
                child: Column(
                  children: [
                    AvatarWidget(
                      initials: agent.avatarInitials,
                      imageUrl: agent.avatarUrl,
                      size: 88,
                    //  showBorder: true,
                    ),
                    SizedBox(height: 14.h),
                    Text(agent.name,
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6.h),
                    const StatusBadge(
                      label: 'Verified Field Agent',
                      color: AppColors.success,
                      backgroundColor: AppColors.successLight,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_rounded,
                            color: const Color(0xFFFBBF24), size: 18.sp),
                        Text(' ${agent.rating}',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        _Stat('${agent.totalJobs}', 'Verifications'),
                        _divider(),
                        _Stat('${agent.successRate.toInt()}%', 'Success'),
                        _divider(),
                        _Stat(Formatters.currencyCompact(agent.totalEarned),
                            'Earned'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              _KycCard(),
              SizedBox(height: 24.h),
              _QuickLinks(),
              SizedBox(height: 24.h),
              _MenuSection('Account', [
                _MenuItem('Personal details', AppRoutes.personalDetails),
                _MenuItem('Case allocation', AppRoutes.allocationPreferences),
                _MenuItem('Accepted cases', AppRoutes.acceptedCases),
                _MenuItem('Payments', AppRoutes.paymentHistory),
              ]),
              SizedBox(height: 16.h),
              _DemoMenuSection('Preferences', [
                'Notifications',
                'Location Services',
                'Language',
              ]),
              SizedBox(height: 16.h),
              _DemoMenuSection('Support', [
                'Help Center',
                'Contact Support',
                'Terms & Privacy',
              ]),
              SizedBox(height: 16.h),
              GlassCard(
                onTap: () => Get.find<AuthController>().logout(),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.error),
                    SizedBox(width: 12.w),
                    Text('Logout',
                        style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _divider() => Container(width: 1, height: 32.h, color: AppColors.border);
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 17.sp, fontWeight: FontWeight.w800)),
          Text(label,
              style: TextStyle(
                  fontSize: 11.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _KycCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    final kyc = controller.agent.value.kycStatus;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Agent Verification',
              style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 14.h),
          _KycItem('Identity Verified', kyc.identityVerified),
          _KycItem('Bank Account Verified', kyc.bankAccountVerified),
          _KycItem('Background Check Completed', kyc.backgroundCheckCompleted),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Status'),
              StatusBadge(
                label: kyc.status,
                color: AppColors.success,
                backgroundColor: AppColors.successLight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KycItem extends StatelessWidget {
  const _KycItem(this.label, this.done);
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 20.sp,
            color: done ? AppColors.success : AppColors.textTertiary,
          ),
          SizedBox(width: 10.w),
          Text(label),
        ],
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final agent = MockData.agent;
    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            icon: Icons.badge_outlined,
            label: 'Aadhaar',
            value: agent.aadhaarVerified ? 'Verified' : 'Pending',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _InfoChip(
            icon: Icons.school_outlined,
            label: 'Certification',
            value: agent.certificationVerified ? 'Verified' : 'Pending',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _InfoChip(
            icon: Icons.account_balance_wallet_outlined,
            label: 'UPI',
            value: agent.upiId,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.accent),
          SizedBox(height: 8.h),
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.title, this.route);
  final String title;
  final String route;
}

class _MenuSection extends StatelessWidget {
  const _MenuSection(this.title, this.items);
  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 10.h),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((e) {
              return Column(
                children: [
                  ListTile(
                    title: Text(e.value.title),
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppColors.textTertiary),
                    onTap: () => Get.toNamed(e.value.route),
                  ),
                  if (e.key < items.length - 1)
                    Divider(height: 1, indent: 16.w),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DemoMenuSection extends StatelessWidget {
  const _DemoMenuSection(this.title, this.items);
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 10.h),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((e) {
              return Column(
                children: [
                  ListTile(
                    title: Text(e.value),
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: AppColors.textTertiary),
                    onTap: () => Get.snackbar(
                      e.value,
                      'Demo only',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: EdgeInsets.all(16.w),
                      borderRadius: 12,
                    ),
                  ),
                  if (e.key < items.length - 1)
                    Divider(height: 1, indent: 16.w),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
