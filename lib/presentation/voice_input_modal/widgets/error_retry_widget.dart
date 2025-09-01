import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Error handling widget with retry functionality
class ErrorRetryWidget extends StatelessWidget {
  final String errorMessage;
  final bool isSinhala;
  final VoidCallback onRetry;
  final VoidCallback? onPermissionRequest;

  const ErrorRetryWidget({
    super.key,
    required this.errorMessage,
    required this.isSinhala,
    required this.onRetry,
    this.onPermissionRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          CustomIconWidget(
            iconName: 'error_outline',
            color: theme.colorScheme.error,
            size: 8.w,
          ),
          SizedBox(height: 2.h),

          // Error message
          Text(
            _getLocalizedErrorMessage(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Retry button
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRetry();
                },
                icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: theme.colorScheme.onPrimary,
                  size: 4.w,
                ),
                label: Text(
                  isSinhala ? 'නැවත උත්සාහ කරන්න' : 'Retry',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                ),
              ),

              // Permission button (if needed)
              if (onPermissionRequest != null) ...[
                SizedBox(width: 3.w),
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onPermissionRequest!();
                  },
                  icon: CustomIconWidget(
                    iconName: 'settings',
                    color: theme.colorScheme.primary,
                    size: 4.w,
                  ),
                  label: Text(
                    isSinhala ? 'අවසර' : 'Permission',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getLocalizedErrorMessage() {
    if (errorMessage.toLowerCase().contains('permission')) {
      return isSinhala
          ? 'මයික්‍රෆෝන් භාවිතා කිරීමට අවසර අවශ්‍යයි'
          : 'Microphone permission is required';
    } else if (errorMessage.toLowerCase().contains('network')) {
      return isSinhala
          ? 'අන්තර්ජාල සම්බන්ධතාවය පරීක්ෂා කරන්න'
          : 'Please check your internet connection';
    } else if (errorMessage.toLowerCase().contains('not supported')) {
      return isSinhala
          ? 'මෙම උපකරණයේ කටහඬ හඳුනාගැනීම සහාය නොදක්වයි'
          : 'Voice recognition not supported on this device';
    } else {
      return isSinhala
          ? 'කටහඬ හඳුනාගැනීමේ දෝෂයක් සිදුවිය'
          : 'Voice recognition error occurred';
    }
  }
}
