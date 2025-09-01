import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Voice input settings widget with microphone sensitivity slider,
/// language priority selection, and offline recognition toggle
class VoiceSettingsWidget extends StatelessWidget {
  final double microphoneSensitivity;
  final bool offlineRecognition;
  final ValueChanged<double> onSensitivityChanged;
  final ValueChanged<bool> onOfflineRecognitionChanged;

  const VoiceSettingsWidget({
    super.key,
    required this.microphoneSensitivity,
    required this.offlineRecognition,
    required this.onSensitivityChanged,
    required this.onOfflineRecognitionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.mic,
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Voice Input',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Microphone sensitivity
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tune,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Microphone Sensitivity',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Adjust how sensitive the microphone is to your voice',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.volume_down,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    Expanded(
                      child: Slider(
                        value: microphoneSensitivity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          onSensitivityChanged(value);
                        },
                      ),
                    ),
                    Icon(
                      Icons.volume_up,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Low',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${(microphoneSensitivity * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'High',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Language priority
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.priority_high,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language Priority',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Primary language for voice recognition',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showLanguagePriorityDialog(context);
                  },
                  child: const Text('Configure'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Offline recognition
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.offline_bolt,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offline Recognition',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enable voice recognition without internet',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: offlineRecognition,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    onOfflineRecognitionChanged(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePriorityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguagePriorityItem(context, 'English', 'Primary'),
            _buildLanguagePriorityItem(context, 'Sinhala', 'Secondary'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePriorityItem(
      BuildContext context, String language, String priority) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              language,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priority == 'Primary'
                  ? theme.colorScheme.primary.withAlpha(26)
                  : theme.colorScheme.secondary.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              priority,
              style: theme.textTheme.bodySmall?.copyWith(
                color: priority == 'Primary'
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
