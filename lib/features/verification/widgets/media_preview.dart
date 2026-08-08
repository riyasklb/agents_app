import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import 'video_preview_player.dart';

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
Future<VideoPreviewResult?> showVideoCapturePreview(
  BuildContext context, {
  required String filePath,
}) async {
  return showModalBottomSheet<VideoPreviewResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => _VideoPreviewSheet(filePath: filePath),
  );
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
  const _VideoPreviewSheet({required this.filePath});

  final String filePath;

  @override
  State<_VideoPreviewSheet> createState() => _VideoPreviewSheetState();
}

class _VideoPreviewSheetState extends State<_VideoPreviewSheet> {
  final _playerKey = GlobalKey<SafeVideoPlayerState>();
  int _durationSeconds = 0;
  bool _playerFailed = false;

  void _confirm() {
    final duration = _playerKey.currentState?.durationSeconds ?? 0;
    Navigator.pop(
      context,
      VideoPreviewResult(
        confirmed: true,
        durationSeconds: duration > 0 ? duration : 30,
      ),
    );
  }

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
                _durationSeconds > 0
                    ? 'Duration: ${formatVideoDuration(_durationSeconds)}'
                    : _playerFailed
                        ? 'Video saved — preview unavailable'
                        : 'Loading preview...',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: SafeVideoPlayer(
                  key: _playerKey,
                  filePath: widget.filePath,
                  onInitialized: (controller) {
                    setState(() {
                      _durationSeconds =
                          controller.value.duration.inSeconds.clamp(1, 3600);
                    });
                  },
                  onFailed: () => setState(() => _playerFailed = true),
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
                      onPressed: () => Navigator.pop(
                        context,
                        const VideoPreviewResult(
                          confirmed: false,
                          durationSeconds: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 1,
                    child: PrimaryButton(
                      label: 'Use video',
                      icon: Icons.check_rounded,
                      onPressed: _confirm,
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

class _FullScreenVideoViewer extends StatelessWidget {
  const _FullScreenVideoViewer({
    required this.filePath,
    this.durationSeconds,
  });

  final String filePath;
  final int? durationSeconds;

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
        child: SafeVideoPlayer(
          filePath: filePath,
          showPlayOverlay: true,
        ),
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
