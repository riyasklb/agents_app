import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../verification_controller.dart';
import 'media_preview.dart';

class VerificationPhotoTile extends GetView<VerificationController> {
  const VerificationPhotoTile({
    super.key,
    required this.mediaId,
    required this.label,
    required this.icon,
    required this.isCaptured,
    this.previewPath,
  });

  final String mediaId;
  final String label;
  final IconData icon;
  final bool isCaptured;
  final String? previewPath;

  bool get _hasPreview =>
      previewPath != null &&
      previewPath!.isNotEmpty &&
      !previewPath!.startsWith('captured_') &&
      File(previewPath!).existsSync();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.capturePhoto(mediaId),
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          decoration: BoxDecoration(
            color: isCaptured ? AppColors.successLight : AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isCaptured
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.border.withValues(alpha: 0.7),
            ),
          ),
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              if (_hasPreview)
                MediaThumbnail(
                  filePath: previewPath!,
                  size: 44,
                  onTap: () => controller.previewPhoto(previewPath!),
                )
              else
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: isCaptured
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    isCaptured ? Icons.check_rounded : icon,
                    color:
                        isCaptured ? AppColors.success : AppColors.textTertiary,
                    size: 22.sp,
                  ),
                ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isCaptured)
                      Text(
                        'Tap to retake · Preview available',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              if (_hasPreview)
                TextButton(
                  onPressed: () => controller.previewPhoto(previewPath!),
                  child: Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                )
              else
                Text(
                  isCaptured ? 'Done' : 'Capture',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isCaptured ? AppColors.success : AppColors.accent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CapturedVideoCard extends GetView<VerificationController> {
  const CapturedVideoCard({
    super.key,
    required this.label,
    required this.filePath,
    required this.durationSeconds,
    required this.onRetake,
  });

  final String label;
  final String filePath;
  final int durationSeconds;
  final VoidCallback onRetake;

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          MediaThumbnail(
            filePath: filePath,
            isVideo: true,
            size: 72,
            onTap: () => controller.previewVideo(
              filePath,
              durationSeconds: durationSeconds,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Duration: ${_fmt(durationSeconds)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                GestureDetector(
                  onTap: () => controller.previewVideo(
                    filePath,
                    durationSeconds: durationSeconds,
                  ),
                  child: Text(
                    'Preview video',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onRetake, child: const Text('Retake')),
        ],
      ),
    );
  }
}

class MediaCaptureButton extends StatefulWidget {
  const MediaCaptureButton({
    super.key,
    required this.label,
    required this.isCaptured,
    required this.onCapture,
    this.isVideo = false,
    this.durationSeconds,
    this.previewPath,
    this.onPreview,
    this.onRetake,
  });

  final String label;
  final bool isCaptured;
  final VoidCallback onCapture;
  final bool isVideo;
  final int? durationSeconds;
  final String? previewPath;
  final VoidCallback? onPreview;
  final VoidCallback? onRetake;

  @override
  State<MediaCaptureButton> createState() => _MediaCaptureButtonState();
}

class _MediaCaptureButtonState extends State<MediaCaptureButton> {
  bool _isCapturing = false;

  Future<void> _capture() async {
    setState(() => _isCapturing = true);
    HapticFeedback.mediumImpact();
    try {
      final picker = ImagePicker();
      if (widget.isVideo) {
        await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 60),
        );
      } else {
        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      }
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isCapturing = false);
    widget.onCapture();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCaptured && widget.isVideo && widget.previewPath != null) {
      return CapturedVideoCard(
        label: widget.label,
        filePath: widget.previewPath!,
        durationSeconds: widget.durationSeconds ?? 0,
        onRetake: widget.onRetake ?? _capture,
      );
    }

    if (widget.isCaptured) {
      return _CapturedMedia(
        label: widget.label,
        isVideo: widget.isVideo,
        durationSeconds: widget.durationSeconds,
        previewPath: widget.previewPath,
        onRetake: widget.onRetake ?? _capture,
        onPreview: widget.onPreview,
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _isCapturing ? null : _capture,
            child: Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border),
              ),
              child: _isCapturing
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isVideo
                              ? Icons.videocam_outlined
                              : Icons.camera_alt_outlined,
                          size: 32.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.isVideo ? 'Record Video' : 'Capture Document',
                          style: TextStyle(
                              fontSize: 12.sp, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapturedMedia extends StatelessWidget {
  const _CapturedMedia({
    required this.label,
    required this.isVideo,
    required this.onRetake,
    this.durationSeconds,
    this.previewPath,
    this.onPreview,
  });

  final String label;
  final bool isVideo;
  final VoidCallback onRetake;
  final int? durationSeconds;
  final String? previewPath;
  final VoidCallback? onPreview;

  bool get _hasPreview =>
      previewPath != null &&
      previewPath!.isNotEmpty &&
      !previewPath!.startsWith('captured_') &&
      File(previewPath!).existsSync();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          if (_hasPreview && !isVideo)
            MediaThumbnail(
              filePath: previewPath!,
              size: 72,
              onTap: onPreview,
            )
          else
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                isVideo ? Icons.play_circle_outline : Icons.image_outlined,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  isVideo && durationSeconds != null
                      ? 'Duration: ${_fmt(durationSeconds!)}'
                      : 'Captured successfully',
                  style: TextStyle(
                      fontSize: 12.sp, color: AppColors.textSecondary),
                ),
                if (_hasPreview && onPreview != null) ...[
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: onPreview,
                    child: Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(onPressed: onRetake, child: const Text('Retake')),
        ],
      ),
    );
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
}

class PhotoCaptureTile extends StatelessWidget {
  const PhotoCaptureTile({
    super.key,
    required this.label,
    required this.isCaptured,
    required this.onCapture,
    this.previewPath,
    this.onPreview,
  });

  final String label;
  final bool isCaptured;
  final VoidCallback onCapture;
  final String? previewPath;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: isCaptured
          ? _CapturedMedia(
              label: label,
              isVideo: false,
              onRetake: onCapture,
              previewPath: previewPath,
              onPreview: onPreview,
            )
          : GlassCard(
              onTap: onCapture,
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(Icons.camera_alt_outlined,
                        color: AppColors.textTertiary),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                      child: Text(label,
                          style: TextStyle(fontWeight: FontWeight.w600))),
                  Icon(Icons.add_circle_outline, color: AppColors.accent),
                ],
              ),
            ),
    );
  }
}
