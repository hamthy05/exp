import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Large microphone button with state-based color changes and animations
class MicrophoneButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isListening;
  final bool isProcessing;
  final bool isIdle;

  const MicrophoneButtonWidget({
    super.key,
    required this.onPressed,
    required this.isListening,
    required this.isProcessing,
    required this.isIdle,
  });

  @override
  State<MicrophoneButtonWidget> createState() => _MicrophoneButtonWidgetState();
}

class _MicrophoneButtonWidgetState extends State<MicrophoneButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MicrophoneButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getButtonColor(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.isListening) {
      return theme.colorScheme.primary;
    } else if (widget.isProcessing) {
      return theme.colorScheme.secondary;
    } else {
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _getIconName() {
    if (widget.isListening) {
      return 'mic';
    } else if (widget.isProcessing) {
      return 'hourglass_empty';
    } else {
      return 'mic_none';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = _getButtonColor(context);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isListening ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onPressed();
            },
            child: Container(
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: buttonColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: buttonColor,
                  width: 3,
                ),
                boxShadow: widget.isListening
                    ? [
                        BoxShadow(
                          color: buttonColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getIconName(),
                  color: buttonColor,
                  size: 12.w,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
