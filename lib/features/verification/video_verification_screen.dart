import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'verification_controller.dart';
import 'widgets/media_preview.dart';

class VideoVerificationScreen extends StatefulWidget {
  const VideoVerificationScreen({super.key});

  @override
  State<VideoVerificationScreen> createState() =>
      _VideoVerificationScreenState();
}

class _VideoVerificationScreenState extends State<VideoVerificationScreen> {
  bool _isPicking = false;
  String? _filePath;
  int _duration = 0;

  VerificationController get _controller => Get.find<VerificationController>();

  Future<void> _recordVideo() async {
    setState(() => _isPicking = true);
    HapticFeedback.mediumImpact();
    try {
      final file = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 60),
      );
      if (file == null) return;

      final confirmed = await showVideoCapturePreview(
        context,
        filePath: file.path,
        durationSeconds: _duration > 0 ? _duration : 30,
      );

      if (!confirmed) {
        await _recordVideo();
        return;
      }

      final duration = await _videoDurationSeconds(file.path);

      setState(() {
        _filePath = file.path;
        _duration = duration;
      });
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isPicking = true);
    try {
      final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (file == null) return;

      final confirmed = await showVideoCapturePreview(
        context,
        filePath: file.path,
        durationSeconds: 30,
      );

      if (!confirmed) return;

      final duration = await _videoDurationSeconds(file.path);

      setState(() {
        _filePath = file.path;
        _duration = duration;
      });
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<int> _videoDurationSeconds(String path) async {
    final player = VideoPlayerController.file(File(path));
    try {
      await player.initialize();
      return player.value.duration.inSeconds.clamp(1, 60);
    } catch (_) {
      return 30;
    } finally {
      await player.dispose();
    }
  }

  Future<void> _useVideo() async {
    if (_filePath == null) return;
    await _controller.captureVideo(
      filePath: _filePath!,
      durationSeconds: _duration,
    );
    Get.back<void>();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: Get.back<void>,
                      icon: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Record video',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Record a short video confirming the applicant and property.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Maximum duration: 60 seconds',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                if (_filePath != null) ...[
                  GestureDetector(
                    onTap: () => _controller.previewVideo(
                      _filePath!,
                      durationSeconds: _duration,
                    ),
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 20.r,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 48.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Video ready',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Duration: ${_fmt(_duration)} · Tap to preview',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else if (_isPicking) ...[
                  const CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(height: 16.h),
                  const Text('Opening camera...'),
                ] else ...[
                  GestureDetector(
                    onTap: _recordVideo,
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.error, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  const Text('Tap to record'),
                ],
                const Spacer(),
                if (_filePath != null) ...[
                  Expanded(
                    flex: 1,
                    child: SecondaryButton(
                      label: 'Retake',
                      icon: Icons.refresh_rounded,
                      onPressed: () => setState(() {
                        _filePath = null;
                        _duration = 0;
                      }),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    flex: 1,
                    child: PrimaryButton(
                      label: 'Use video',
                      icon: Icons.check_rounded,
                      onPressed: _useVideo,
                    ),
                  ),
                ] else if (!_isPicking) ...[
                  SecondaryButton(
                    label: 'Pick from gallery',
                    icon: Icons.video_library_outlined,
                    onPressed: _pickFromGallery,
                  ),
                ],
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
