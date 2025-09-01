import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TransactionCardWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;

  const TransactionCardWidget({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense =
        (transaction['type'] as String).toLowerCase() == 'expense';
    final amount = transaction['amount'] as double;
    final category = transaction['category'] as String;
    final description = transaction['description'] as String;
    final time = transaction['time'] as String;
    final categoryIcon = transaction['categoryIcon'] as String;

    return Dismissible(
      key: Key(transaction['id'].toString()),
      background: _buildSwipeBackground(context, isLeft: false),
      secondaryBackground: _buildSwipeBackground(context, isLeft: true),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.heavyImpact();
          _showContextMenu(context);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: isExpense
                        ? theme.colorScheme.error.withValues(alpha: 0.1)
                        : theme.colorScheme.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: categoryIcon,
                      color: isExpense
                          ? theme.colorScheme.error
                          : theme.colorScheme.tertiary,
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Text(
                            category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            width: 1.w,
                            height: 1.w,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            time,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? '-' : '+'}Rs. ${amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isExpense
                            ? theme.colorScheme.error
                            : theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft
            ? theme.colorScheme.error.withValues(alpha: 0.1)
            : theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'delete' : 'edit',
                color: isLeft
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(height: 1.h),
              Text(
                isLeft ? 'Delete' : 'Edit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isLeft
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
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
              'Delete Transaction',
              style: theme.textTheme.titleLarge,
            ),
            content: Text(
              'Are you sure you want to delete this transaction? This action cannot be undone.',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  onDelete?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildContextMenuItem(
              context,
              icon: 'edit',
              title: 'Edit Transaction',
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            _buildContextMenuItem(
              context,
              icon: 'content_copy',
              title: 'Duplicate Transaction',
              onTap: () {
                Navigator.pop(context);
                onDuplicate?.call();
              },
            ),
            _buildContextMenuItem(
              context,
              icon: 'share',
              title: 'Share Transaction',
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            _buildContextMenuItem(
              context,
              icon: 'delete',
              title: 'Delete Transaction',
              isDestructive: true,
              onTap: () async {
                Navigator.pop(context);
                if (await _showDeleteConfirmation(context)) {
                  onDelete?.call();
                }
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isDestructive
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface,
        size: 6.w,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDestructive
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface,
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}
