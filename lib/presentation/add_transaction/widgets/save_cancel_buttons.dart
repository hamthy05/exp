import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Save and cancel buttons with loading state
class SaveCancelButtons extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool isEnabled;

  const SaveCancelButtons({
    super.key,
    this.onSave,
    this.onCancel,
    this.isLoading = false,
    this.isEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Cancel Button
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onCancel?.call();
                      },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(6.h), // responsive height
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            // Save Button
            Expanded(
              child: ElevatedButton(
                onPressed: (isEnabled && !isLoading)
                    ? () {
                        HapticFeedback.mediumImpact();
                        onSave?.call();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(6.h),
                  backgroundColor: isEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.12),
                  foregroundColor: isEnabled
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 2.2.h,
                        width: 2.2.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Save',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isEnabled ? Colors.white : null,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
