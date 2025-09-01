import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class GoalCardWidget extends StatelessWidget {
  final Map<String, dynamic> goal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalCardWidget({
    super.key,
    required this.goal,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress =
        (goal['currentAmount'] as double) / (goal['targetAmount'] as double);
    final progressPercentage = (progress * 100).clamp(0, 100).toInt();
    final isCompleted = progress >= 1.0;

    return Dismissible(
      key: Key('goal_${goal['id']}'),
      background: _buildSwipeBackground(context, isLeft: true),
      secondaryBackground: _buildSwipeBackground(context, isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          HapticFeedback.lightImpact();
          onEdit?.call();
          return false;
        } else {
          HapticFeedback.mediumImpact();
          return await _showDeleteConfirmation(context);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: isCompleted ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isCompleted),
                  SizedBox(height: 2.h),
                  _buildProgressSection(context, progress, progressPercentage),
                  SizedBox(height: 2.h),
                  _buildAmountSection(context),
                  SizedBox(height: 1.h),
                  _buildDateSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompleted) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: goal['icon'] as String,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal['name'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (goal['category'] != null) ...[
                SizedBox(height: 0.5.h),
                Text(
                  goal['category'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isCompleted) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Completed',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection(
      BuildContext context, double progress, int progressPercentage) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '$progressPercentage%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final theme = Theme.of(context);
    final currentAmount = goal['currentAmount'] as double;
    final targetAmount = goal['targetAmount'] as double;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Rs. ${currentAmount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Target',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Rs. ${targetAmount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context) {
    final theme = Theme.of(context);
    final targetDate = DateTime.parse(goal['targetDate'] as String);
    final now = DateTime.now();
    final daysRemaining = targetDate.difference(now).inDays;
    final isOverdue = daysRemaining < 0;

    return Row(
      children: [
        CustomIconWidget(
          iconName: 'calendar_today',
          color: theme.colorScheme.onSurfaceVariant,
          size: 16,
        ),
        SizedBox(width: 2.w),
        Text(
          isOverdue
              ? 'Overdue by ${(-daysRemaining)} days'
              : daysRemaining == 0
                  ? 'Due today'
                  : '$daysRemaining days remaining',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isOverdue
                ? theme.colorScheme.error
                : daysRemaining <= 7
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurfaceVariant,
            fontWeight: isOverdue || daysRemaining <= 7
                ? FontWeight.w500
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'edit' : 'delete',
                color: isLeft
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeft ? 'Edit' : 'Delete',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isLeft
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final theme = Theme.of(context);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete Goal',
              style: theme.textTheme.titleLarge,
            ),
            content: Text(
              'Are you sure you want to delete "${goal['name']}"? This action cannot be undone.',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(true);
                  onDelete?.call();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
