import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Description input field with voice input capability
class DescriptionInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onVoicePressed;
  final bool isVoiceActive;

  const DescriptionInputField({
    super.key,
    required this.controller,
    this.onVoicePressed,
    this.isVoiceActive = false,
  });

  @override
  State<DescriptionInputField> createState() => _DescriptionInputFieldState();
}

class _DescriptionInputFieldState extends State<DescriptionInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Add a note about this transaction...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                ),
              ),
              if (widget.onVoicePressed != null) ...[
                Container(
                  width: 1,
                  height: 40.h,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onVoicePressed?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    child: AnimatedScale(
                      scale: widget.isVoiceActive ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: CustomIconWidget(
                        iconName: widget.isVoiceActive ? 'mic' : 'mic_none',
                        color: widget.isVoiceActive
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.isVoiceActive) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Listening... Speak in English or Sinhala',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
