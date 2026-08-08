import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class MediaCaptureButton extends StatefulWidget {
  const MediaCaptureButton({
    super.key,
    required this.label,
    required this.isCaptured,
    required this.onCapture,
    this.isVideo = false,
    this.durationSeconds,
  });

  final String label;
  final bool isCaptured;
  final VoidCallback onCapture;
  final bool isVideo;
  final int? durationSeconds;

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
    if (widget.isCaptured) {
      return _CapturedMedia(
        label: widget.label,
        isVideo: widget.isVideo,
        durationSeconds: widget.durationSeconds,
        onRetake: _capture,
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
  });

  final String label;
  final bool isVideo;
  final VoidCallback onRetake;
  final int? durationSeconds;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
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
  });

  final String label;
  final bool isCaptured;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: isCaptured
          ? _CapturedMedia(label: label, isVideo: false, onRetake: onCapture)
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
