import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';

class VideoPreviewResult {
  const VideoPreviewResult({
    required this.confirmed,
    required this.durationSeconds,
  });

  final bool confirmed;
  final int durationSeconds;
}

/// Safely initializes a file-based video player with graceful fallback.
class SafeVideoPlayer extends StatefulWidget {
  const SafeVideoPlayer({
    super.key,
    required this.filePath,
    this.aspectRatio = 16 / 9,
    this.showPlayOverlay = true,
    this.onInitialized,
    this.onFailed,
  });

  final String filePath;
  final double aspectRatio;
  final bool showPlayOverlay;
  final void Function(VideoPlayerController controller)? onInitialized;
  final VoidCallback? onFailed;

  @override
  State<SafeVideoPlayer> createState() => SafeVideoPlayerState();
}

class SafeVideoPlayerState extends State<SafeVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _failed = false;

  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _initialized;
  bool get hasFailed => _failed;

  int get durationSeconds {
    if (_initialized && _controller != null) {
      return _controller!.value.duration.inSeconds.clamp(1, 3600);
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    if (!File(widget.filePath).existsSync()) {
      if (mounted) setState(() => _failed = true);
      widget.onFailed?.call();
      return;
    }

    final player = VideoPlayerController.file(
      File(widget.filePath),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    try {
      await player.initialize();
      if (!mounted) {
        await player.dispose();
        return;
      }
      setState(() {
        _controller = player;
        _initialized = true;
      });
      widget.onInitialized?.call(player);
    } catch (_) {
      await player.dispose();
      if (mounted) {
        setState(() => _failed = true);
        widget.onFailed?.call();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _initialized && _controller != null
          ? _controller!.value.aspectRatio
          : widget.aspectRatio,
      child: ColoredBox(
        color: Colors.black,
        child: _initialized && _controller != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller!),
                  if (widget.showPlayOverlay)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _controller!.value.isPlaying
                              ? _controller!.pause()
                              : _controller!.play();
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
                          _controller!.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                    ),
                ],
              )
            : _failed
                ? _VideoFallback(filePath: widget.filePath)
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
      ),
    );
  }
}

class _VideoFallback extends StatelessWidget {
  const _VideoFallback({required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    final fileName = filePath.split('/').last;
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_rounded, color: Colors.white, size: 48.sp),
          SizedBox(height: 12.h),
          Text(
            'Video captured',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Preview unavailable on this device',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 11.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String formatVideoDuration(int seconds) {
  return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}
