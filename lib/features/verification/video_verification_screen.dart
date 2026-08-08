import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'verification_controller.dart';

class VideoVerificationScreen extends StatefulWidget {
  const VideoVerificationScreen({super.key});

  @override
  State<VideoVerificationScreen> createState() =>
      _VideoVerificationScreenState();
}

class _VideoVerificationScreenState extends State<VideoVerificationScreen> {
  bool _isRecording = false;
  bool _isCaptured = false;
  int _duration = 0;

  VerificationController get _controller => Get.find<VerificationController>();

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _duration = 0;
    });
    HapticFeedback.mediumImpact();
    for (var i = 1; i <= 32; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_isRecording) break;
      if (mounted) setState(() => _duration = i ~/ 3);
    }
    if (mounted) {
      setState(() {
        _isRecording = false;
        _isCaptured = true;
        _duration = 32;
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _useVideo() {
    _controller.captureMedia('media-006', durationSeconds: _duration);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Video Verification'),
      body: PremiumBackground(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Text(
                'Record a short video confirming the applicant and property.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
              ),
              SizedBox(height: 8.h),
              Text('Maximum duration: 60 seconds',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary)),
              const Spacer(),
              if (_isCaptured) ...[
                const SuccessCheckmark(size: 90),
                SizedBox(height: 20.h),
                Text('Video captured ✓',
                    style: TextStyle(
                        fontSize: 20.sp, fontWeight: FontWeight.w700)),
                Text('Duration: ${_fmt(_duration)}'),
              ] else ...[
                GestureDetector(
                  onTap: _isRecording ? null : _startRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.error,
                        width: _isRecording ? 8 : 4,
                      ),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isRecording ? 36.w : 72.w,
                        height: _isRecording ? 36.w : 72.w,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape:
                              _isRecording ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius:
                              _isRecording ? BorderRadius.circular(6.r) : null,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(_isRecording
                    ? 'Recording... ${_fmt(_duration)}'
                    : 'Tap to record'),
              ],
              const Spacer(),
              if (_isCaptured) ...[
                SecondaryButton(
                  label: 'Retake',
                  onPressed: () => setState(() {
                    _isCaptured = false;
                    _duration = 0;
                  }),
                ),
                SizedBox(height: 12.h),
                PrimaryButton(label: 'Use Video', onPressed: _useVideo),
              ],
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
}
