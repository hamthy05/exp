import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget to display transcribed text with language-appropriate fonts
class TranscriptionDisplayWidget extends StatelessWidget {
  final String transcribedText;
  final bool isSinhala;
  final double confidence;

  const TranscriptionDisplayWidget({
    super.key,
    required this.transcribedText,
    required this.isSinhala,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 12.h,
        maxHeight: 20.h,
      ),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transcribed text
          Expanded(
            child: SingleChildScrollView(
              child: transcribedText.isEmpty
                  ? _buildPlaceholderText(context)
                  : _buildTranscribedText(context),
            ),
          ),

          // Confidence indicator
          if (transcribedText.isNotEmpty && confidence > 0) ...[
            SizedBox(height: 2.h),
            _buildConfidenceIndicator(context),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderText(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'record_voice_over',
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 8.w,
          ),
          SizedBox(height: 2.h),
          Text(
            isSinhala ? 'කතා කරන්න...' : 'Start speaking...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTranscribedText(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      transcribedText,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        height: 1.4,
        // Use appropriate font for Sinhala text
        fontFamily: isSinhala ? null : 'Inter',
      ),
      textAlign: TextAlign.start,
    );
  }

  Widget _buildConfidenceIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final confidencePercentage = (confidence * 100).round();

    return Row(
      children: [
        CustomIconWidget(
          iconName: 'psychology',
          color: _getConfidenceColor(theme),
          size: 4.w,
        ),
        SizedBox(width: 2.w),
        Text(
          'Confidence: $confidencePercentage%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: _getConfidenceColor(theme),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor:
                AlwaysStoppedAnimation<Color>(_getConfidenceColor(theme)),
            minHeight: 0.5.h,
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(ThemeData theme) {
    if (confidence >= 0.8) {
      return theme.colorScheme.primary;
    } else if (confidence >= 0.6) {
      return theme.colorScheme.secondary;
    } else {
      return theme.colorScheme.error;
    }
  }
}
