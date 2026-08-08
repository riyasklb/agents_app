import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/models.dart';

String jobDeadlineLabel(DateTime deadline) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
  if (deadlineDay == today) return 'Today';
  if (deadlineDay == today.add(const Duration(days: 1))) return 'Tomorrow';
  return Formatters.date(deadline);
}

class JobListTile extends StatelessWidget {
  const JobListTile({
    super.key,
    required this.job,
    this.onTap,
    this.showChevron = true,
    this.trailing,
    this.subtitle,
  });

  final VerificationJob job;
  final VoidCallback? onTap;
  final bool showChevron;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          AvatarWidget(
            initials: job.applicant.initials,
            imageUrl: job.applicant.avatarUrl,
            size: 42,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${job.loanType.label} Verification',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (job.priority == JobPriority.high) ...[
                      SizedBox(width: 6.w),
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  job.applicant.name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle ??
                      '${Formatters.distance(job.distanceKm)} · ${job.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          trailing ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(job.commission),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    jobDeadlineLabel(job.deadline),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
          if (showChevron && onTap != null) ...[
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.textTertiary,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return _tileShell(child: content);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: _tileShell(child: content),
      ),
    );
  }

  Widget _tileShell({required Widget child}) {
    return Ink(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: child,
    );
  }
}

class AvailableJobTile extends StatelessWidget {
  const AvailableJobTile({
    super.key,
    required this.job,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
    this.isProcessing = false,
  });

  final VerificationJob job;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          JobListTile(
            job: job,
            onTap: isProcessing ? null : onTap,
            showChevron: !isProcessing,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Reject',
                    icon: Icons.close_rounded,
                    onPressed: isProcessing ? null : onReject,
                    variant: _ActionVariant.outline,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: _ActionButton(
                    label: 'Accept',
                    icon: Icons.check_rounded,
                    onPressed: isProcessing ? null : onAccept,
                    variant: _ActionVariant.primary,
                    isLoading: isProcessing,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ActionVariant { outline, primary }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.variant,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final _ActionVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == _ActionVariant.primary;

    return SizedBox(
      height: 40.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed?.call();
                },
          borderRadius: BorderRadius.circular(12.r),
          child: Ink(
            decoration: BoxDecoration(
              gradient: isPrimary && onPressed != null
                  ? AppColors.accentGradient
                  : null,
              color: isPrimary
                  ? (onPressed == null ? AppColors.textTertiary : null)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: isPrimary
                  ? null
                  : Border.all(
                      color: AppColors.border.withValues(alpha: 0.9),
                    ),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 16.sp,
                          color: isPrimary
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isPrimary
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusJobTile extends StatelessWidget {
  const StatusJobTile({
    super.key,
    required this.job,
    required this.onTap,
    required this.statusLabel,
    this.statusColor = AppColors.accent,
  });

  final VerificationJob job;
  final VoidCallback onTap;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return JobListTile(
      job: job,
      onTap: onTap,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Formatters.currency(job.commission),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompletedJobTile extends StatelessWidget {
  const CompletedJobTile({
    super.key,
    required this.job,
    required this.onTap,
  });

  final VerificationJob job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isApproved = job.status == JobStatus.approved;
    return JobListTile(
      job: job,
      onTap: onTap,
      subtitle: job.completedAt != null
          ? 'Completed ${Formatters.date(job.completedAt!)}'
          : null,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Formatters.currency(job.commission),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            isApproved ? 'Approved' : 'Completed',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

// Legacy card kept for any screens still referencing it.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.showViewButton = true,
    this.compact = false,
  });

  final VerificationJob job;
  final VoidCallback onTap;
  final bool showViewButton;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return JobListTile(job: job, onTap: onTap);
  }
}

class CompletedJobCard extends StatelessWidget {
  const CompletedJobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  final VerificationJob job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CompletedJobTile(job: job, onTap: onTap);
  }
}
