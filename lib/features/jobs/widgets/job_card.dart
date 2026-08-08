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
    this.footer,
  });

  final VerificationJob job;
  final VoidCallback? onTap;
  final bool showChevron;
  final Widget? trailing;
  final String? subtitle;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return _PremiumJobShell(
      onTap: onTap,
      footer: footer,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWidget(
              initials: job.applicant.initials,
              imageUrl: job.applicant.avatarUrl,
              size: 48,
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
                          '${job.loanType.label}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (job.priority == JobPriority.high)
                        _PriorityDot(),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    job.applicant.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
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
                  SizedBox(height: 10.h),
                  _MetaChips(
                    chips: [
                      _MetaChip(
                        icon: Icons.schedule_outlined,
                        label: jobDeadlineLabel(job.deadline),
                      ),
                      _MetaChip(
                        icon: Icons.timer_outlined,
                        label: '${job.estimatedMinutes} min',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            trailing ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.currency(job.commission),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'commission',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            if (showChevron && onTap != null) ...[
              SizedBox(width: 2.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: AppColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
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
    return JobListTile(
      job: job,
      onTap: isProcessing ? null : onTap,
      showChevron: false,
      footer: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Row(
          children: [
            _IconActionButton(
              icon: Icons.close_rounded,
              onPressed: isProcessing ? null : onReject,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _GradientActionButton(
                label: 'Accept assignment',
                icon: Icons.arrow_forward_rounded,
                onPressed: isProcessing ? null : onAccept,
                isLoading: isProcessing,
              ),
            ),
          ],
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
    this.actionLabel,
  });

  final VerificationJob job;
  final VoidCallback onTap;
  final String statusLabel;
  final Color statusColor;
  final String? actionLabel;

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
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 6.h),
          _StatusPill(label: statusLabel, color: statusColor),
          if (actionLabel != null) ...[
            SizedBox(height: 6.h),
            Text(
              actionLabel!,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
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
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 6.h),
          _StatusPill(
            label: isApproved ? 'Approved' : 'Completed',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

/// Shared shell for premium job cards.
class _PremiumJobShell extends StatelessWidget {
  const _PremiumJobShell({
    required this.child,
    this.onTap,
    this.footer,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          if (footer != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Divider(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.6),
              ),
            ),
            footer!,
          ],
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: card,
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 6.w),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        'Urgent',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.error,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.chips});

  final List<_MetaChip> chips;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: chips.map((c) => c).toList(),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: AppColors.textTertiary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      height: 44.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(14.r),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.7),
              ),
            ),
            child: Icon(icon, size: 20.sp, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading || onPressed == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(14.r),
          child: Ink(
            decoration: BoxDecoration(
              gradient: onPressed != null ? AppColors.accentGradient : null,
              color: onPressed == null ? AppColors.textTertiary : null,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: onPressed != null
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.28),
                        blurRadius: 12.r,
                        offset: Offset(0, 4.h),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(icon, size: 16.sp, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// Legacy aliases
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
  Widget build(BuildContext context) => JobListTile(job: job, onTap: onTap);
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
  Widget build(BuildContext context) =>
      CompletedJobTile(job: job, onTap: onTap);
}
