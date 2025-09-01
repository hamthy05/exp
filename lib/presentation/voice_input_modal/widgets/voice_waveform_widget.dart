import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Voice waveform animation widget that provides real-time audio feedback
class VoiceWaveformWidget extends StatefulWidget {
  final bool isListening;
  final bool isProcessing;
  final double amplitude;

  const VoiceWaveformWidget({
    super.key,
    required this.isListening,
    required this.isProcessing,
    this.amplitude = 0.5,
  });

  @override
  State<VoiceWaveformWidget> createState() => _VoiceWaveformWidgetState();
}

class _VoiceWaveformWidgetState extends State<VoiceWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    if (widget.isListening || widget.isProcessing) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceWaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.isListening || widget.isProcessing) &&
        !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.isListening &&
        !widget.isProcessing &&
        _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 80.w,
      height: 15.h,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: WaveformPainter(
              animationValue: _animation.value,
              amplitude: widget.amplitude,
              isListening: widget.isListening,
              isProcessing: widget.isProcessing,
              primaryColor: theme.colorScheme.primary,
              secondaryColor: theme.colorScheme.secondary,
            ),
            size: Size(80.w, 15.h),
          );
        },
      ),
    );
  }
}

/// Custom painter for drawing the waveform animation
class WaveformPainter extends CustomPainter {
  final double animationValue;
  final double amplitude;
  final bool isListening;
  final bool isProcessing;
  final Color primaryColor;
  final Color secondaryColor;

  WaveformPainter({
    required this.animationValue,
    required this.amplitude,
    required this.isListening,
    required this.isProcessing,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isListening && !isProcessing) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centerY = size.height / 2;
    final waveLength = size.width / 4;

    // Draw multiple wave lines with different phases
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final phaseOffset = (i * math.pi / 4) + animationValue;
      final currentAmplitude = amplitude * (1.0 - (i * 0.15));

      // Set color based on state and wave index
      if (isProcessing) {
        paint.color = secondaryColor.withValues(alpha: 0.8 - (i * 0.15));
      } else {
        paint.color = primaryColor.withValues(alpha: 0.8 - (i * 0.15));
      }

      // Generate wave path
      for (double x = 0; x <= size.width; x += 2) {
        final normalizedX = x / waveLength;
        final y = centerY +
            (math.sin(normalizedX + phaseOffset) * currentAmplitude * 30) +
            (math.sin(normalizedX * 2 + phaseOffset * 1.5) *
                currentAmplitude *
                15);

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
