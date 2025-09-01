import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FloatingVoiceButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isListening;

  const FloatingVoiceButtonWidget({
    super.key,
    required this.onPressed,
    this.isListening = false,
  });

  @override
  State<FloatingVoiceButtonWidget> createState() =>
      _FloatingVoiceButtonWidgetState();
}

class _FloatingVoiceButtonWidgetState extends State<FloatingVoiceButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(FloatingVoiceButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: 10.h,
      right: 4.w,
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.mediumImpact();
          _scaleController.forward();
        },
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onPressed();
        },
        onTapCancel: () {
          _scaleController.reverse();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse effect when listening
                  if (widget.isListening)
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.secondary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ),

                  // Main button
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isListening
                            ? [
                                theme.colorScheme.secondary,
                                theme.colorScheme.secondary
                                    .withValues(alpha: 0.8),
                              ]
                            : [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary
                                    .withValues(alpha: 0.8),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isListening
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.primary)
                              .withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: CustomIconWidget(
                          key: ValueKey(widget.isListening),
                          iconName: widget.isListening ? 'stop' : 'mic',
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Waveform indicator when listening
                  if (widget.isListening)
                    Positioned(
                      bottom: -2.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow
                                  .withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            return AnimatedContainer(
                              duration:
                                  Duration(milliseconds: 300 + (index * 100)),
                              margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                              width: 1.w,
                              height: widget.isListening ? 2.h : 1.h,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
