import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

/// Shows a bottom sheet to confirm or retake a captured photo.
Future<bool> showPhotoCapturePreview(
  BuildContext context, {
  required String filePath,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _PhotoPreviewSheet(filePath: filePath),
  );
  return result ?? false;
}

/// Shows a bottom sheet to confirm or retake a captured video.
Future<bool> showVideoCapturePreview(
  BuildContext context, {
  required String filePath,
  required int durationSeconds,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => _VideoPreviewSheet(
      filePath: filePath,
      durationSeconds: durationSeconds,
    ),
  );
  return result ?? false;
}

/// Full-screen photo viewer for already captured media.
void showPhotoViewer(BuildContext context, String filePath) {
  showDialog<void>(
    context: context,
    builder: (context) => _FullScreenPhotoViewer(filePath: filePath),
  );
}

/// Full-screen video viewer for already captured media.
void showVideoViewer(
  BuildContext context, {
  required String filePath,
  int? durationSeconds,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => _FullScreenVideoViewer(
        filePath: filePath,
        durationSeconds: durationSeconds,
      ),
    ),
  );
}

class _PhotoPreviewSheet extends StatelessWidget {
  const _PhotoPreviewSheet({required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Preview photo',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Make sure the image is clear and readable',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(
                    File(filePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SecondaryButton(
                      label: 'Retake',
                      icon: Icons.refresh_rounded,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 1,
                    child: PrimaryButton(
                      label: 'Use photo',
                      icon: Icons.check_rounded,
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPreviewSheet extends StatefulWidget {
  const _VideoPreviewSheet({
    required this.filePath,
    required this.durationSeconds,
  });

  final String filePath;
  final int durationSeconds;

  @override
  State<_VideoPreviewSheet> createState() => _VideoPreviewSheetState();
}

class _VideoPreviewSheetState extends State<_VideoPreviewSheet> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Preview video',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                _initialized
                    ? 'Duration: ${_fmt(_controller.value.duration.inSeconds)}'
                    : 'Loading preview...',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: AspectRatio(
                  aspectRatio: _initialized
                      ? _controller.value.aspectRatio
                      : 16 / 9,
                  child: ColoredBox(
                    color: Colors.black,
                    child: _initialized
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_controller),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                                child: Container(
                                  width: 56.w,
                                  height: 56.w,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 32.sp,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                        flex: 1,
                    child: SecondaryButton(
                      label: 'Retake',
                      icon: Icons.refresh_rounded,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 1,
                    child: PrimaryButton(
                      label: 'Use video',
                      icon: Icons.check_rounded,
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenPhotoViewer extends StatelessWidget {
  const _FullScreenPhotoViewer({required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16.w),
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: InteractiveViewer(
              child: Image.file(File(filePath), fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 20.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenVideoViewer extends StatefulWidget {
  const _FullScreenVideoViewer({
    required this.filePath,
    this.durationSeconds,
  });

  final String filePath;
  final int? durationSeconds;

  @override
  State<_FullScreenVideoViewer> createState() => _FullScreenVideoViewerState();
}

class _FullScreenVideoViewerState extends State<_FullScreenVideoViewer> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Video preview'),
      ),
      body: Center(
        child: _initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 64.sp,
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

/// Small thumbnail widget for captured photos.
class MediaThumbnail extends StatelessWidget {
  const MediaThumbnail({
    super.key,
    required this.filePath,
    this.isVideo = false,
    this.size = 44,
    this.onTap,
  });

  final String filePath;
  final bool isVideo;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    final exists = file.existsSync();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: exists && !isVideo
            ? Image.file(file, fit: BoxFit.cover)
            : ColoredBox(
                color: AppColors.surfaceVariant,
                child: Icon(
                  isVideo ? Icons.videocam_rounded : Icons.image_outlined,
                  color: AppColors.textTertiary,
                  size: (size * 0.45).sp,
                ),
              ),
      ),
    );
  }
}
