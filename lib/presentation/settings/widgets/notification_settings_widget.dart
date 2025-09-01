import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Notification settings widget for controlling transaction reminders,
/// goal milestone alerts, and spending limit warnings with granular timing options
class NotificationSettingsWidget extends StatelessWidget {
  final bool transactionReminders;
  final bool goalMilestoneAlerts;
  final bool spendingLimitWarnings;
  final ValueChanged<bool> onTransactionRemindersChanged;
  final ValueChanged<bool> onGoalMilestoneAlertsChanged;
  final ValueChanged<bool> onSpendingLimitWarningsChanged;

  const NotificationSettingsWidget({
    super.key,
    required this.transactionReminders,
    required this.goalMilestoneAlerts,
    required this.spendingLimitWarnings,
    required this.onTransactionRemindersChanged,
    required this.onGoalMilestoneAlertsChanged,
    required this.onSpendingLimitWarningsChanged,
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
                    color: Colors.orange.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notification Preferences',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Transaction reminders
          _buildNotificationOption(
            context,
            Icons.receipt_long,
            'Transaction Reminders',
            'Get reminded to log your daily expenses',
            transactionReminders,
            onTransactionRemindersChanged,
            () => _showTimingDialog(context, 'Transaction Reminders'),
          ),

          const Divider(height: 1),

          // Goal milestone alerts
          _buildNotificationOption(
            context,
            Icons.savings,
            'Goal Milestone Alerts',
            'Celebrate when you reach savings milestones',
            goalMilestoneAlerts,
            onGoalMilestoneAlertsChanged,
            () => _showTimingDialog(context, 'Goal Milestone Alerts'),
          ),

          const Divider(height: 1),

          // Spending limit warnings
          _buildNotificationOption(
            context,
            Icons.warning,
            'Spending Limit Warnings',
            'Alert when approaching budget limits',
            spendingLimitWarnings,
            onSpendingLimitWarningsChanged,
            () => _showTimingDialog(context, 'Spending Limit Warnings'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    VoidCallback onTiming,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: (newValue) {
                  HapticFeedback.lightImpact();
                  onChanged(newValue);
                },
              ),
            ],
          ),
          if (value) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 32),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onTiming,
                    icon: Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      'Configure Timing',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showTimingDialog(BuildContext context, String notificationType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$notificationType Timing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimingOption(context, 'Immediate', true),
            _buildTimingOption(context, 'Daily at 9:00 AM', false),
            _buildTimingOption(context, 'Weekly on Sunday', false),
            _buildTimingOption(context, 'When limit is reached', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingOption(
      BuildContext context, String option, bool isSelected) {
    final theme = Theme.of(context);

    return RadioListTile<bool>(
      title: Text(
        option,
        style: theme.textTheme.bodyMedium,
      ),
      value: true,
      groupValue: isSelected,
      onChanged: (value) {
        HapticFeedback.selectionClick();
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}
