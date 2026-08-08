import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/models.dart';

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

  Color get _accent {
    switch (job.priority) {
      case JobPriority.high:
        return AppColors.error;
      case JobPriority.medium:
        return AppColors.warning;
      case JobPriority.low:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      accentColor: _accent,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(initials: job.applicant.initials, size: 46),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${job.loanType.label} Verification',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      job.applicant.name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (job.priority == JobPriority.high)
                const StatusBadge(
                  label: 'HIGH',
                  color: AppColors.error,
                  backgroundColor: AppColors.errorLight,
                ),
            ],
          ),
          SizedBox(height: 14.h),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: '${Formatters.distance(job.distanceKm)} · ${job.location}',
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  icon: Icons.payments_outlined,
                  text: Formatters.currency(job.commission),
                  bold: true,
                  color: AppColors.success,
                ),
              ),
              if (!compact) ...[
                SizedBox(width: 8.w),
                Flexible(
                  child: _InfoRow(
                    icon: Icons.schedule_outlined,
                    text: _deadlineText(job.deadline),
                  ),
                ),
              ],
            ],
          ),
          if (!compact) ...[
            SizedBox(height: 6.h),
            _InfoRow(
              icon: Icons.timer_outlined,
              text: 'Est. ${job.estimatedMinutes} min',
            ),
          ],
          if (showViewButton) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              height: 42.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  compact ? 'View Details' : 'View Job',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _deadlineText(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay =
        DateTime(deadline.year, deadline.month, deadline.day);
    if (deadlineDay == today) return 'Today, ${Formatters.time(deadline)}';
    if (deadlineDay == today.add(const Duration(days: 1))) return 'Tomorrow';
    return Formatters.date(deadline);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.bold = false,
    this.color,
  });

  final IconData icon;
  final String text;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.textTertiary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: color ??
                  (bold ? AppColors.textPrimary : AppColors.textSecondary),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
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
    return AppCard(
      onTap: onTap,
      accentColor: AppColors.success,
      child: Row(
        children: [
          AvatarWidget(initials: job.applicant.initials),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${job.loanType.label} Verification',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  job.applicant.name,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                ),
                if (job.completedAt != null)
                  Text(
                    'Completed: ${Formatters.date(job.completedAt!)}',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
          Column(
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
              const StatusBadge(
                label: 'Approved ✓',
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
