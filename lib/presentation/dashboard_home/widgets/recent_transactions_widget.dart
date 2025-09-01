import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final bool isSinhala;
  final Function(int) onDeleteTransaction;
  final VoidCallback onViewAll;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    required this.isSinhala,
    required this.onDeleteTransaction,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSinhala ? 'මෑත ගනුදෙනු' : 'Recent Transactions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  isSinhala ? 'සියල්ල බලන්න' : 'View All',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          transactions.isEmpty
              ? _buildEmptyState(context)
              : SizedBox(
                  height: 20.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => SizedBox(width: 3.w),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionCard(context, transaction, index);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 20.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'receipt_long',
            color: theme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            isSinhala ? 'ගනුදෙනු නොමැත' : 'No transactions yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            isSinhala
                ? 'ඔබේ පළමු ගනුදෙනුව එකතු කරන්න'
                : 'Add your first transaction',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, Map<String, dynamic> transaction, int index) {
    final theme = Theme.of(context);
    final isExpense = (transaction['type'] as String) == 'expense';
    final amount = transaction['amount'] as double;
    final category = transaction['category'] as String;
    final date = transaction['date'] as DateTime;
    final description = transaction['description'] as String? ?? '';

    return Dismissible(
      key: Key('transaction_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        onDeleteTransaction(index);
      },
      background: Container(
        width: 70.w,
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Container(
        width: 70.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: (isExpense
                            ? theme.colorScheme.error
                            : theme.colorScheme.tertiary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: _getCategoryIcon(category),
                    color: isExpense
                        ? theme.colorScheme.error
                        : theme.colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSinhala ? _getCategorySinhala(category) : category,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}Rs. ${amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isExpense
                        ? theme.colorScheme.error
                        : theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _getRelativeTime(date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'ආහාර':
        return 'restaurant';
      case 'transport':
      case 'ප්‍රවාහනය':
        return 'directions_car';
      case 'bills':
      case 'බිල්පත්':
        return 'receipt';
      case 'entertainment':
      case 'විනෝදාස්වාදය':
        return 'movie';
      case 'salary':
      case 'වැටුප':
        return 'work';
      case 'freelance':
      case 'නිදහස් වැඩ':
        return 'laptop';
      case 'business':
      case 'ව්‍යාපාරය':
        return 'business';
      default:
        return 'category';
    }
  }

  String _getCategorySinhala(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'ආහාර';
      case 'transport':
        return 'ප්‍රවාහනය';
      case 'bills':
        return 'බිල්පත්';
      case 'entertainment':
        return 'විනෝදාස්වාදය';
      case 'salary':
        return 'වැටුප';
      case 'freelance':
        return 'නිදහස් වැඩ';
      case 'business':
        return 'ව්‍යාපාරය';
      default:
        return category;
    }
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return isSinhala
          ? '${difference.inDays} දින පෙර'
          : '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return isSinhala
          ? '${difference.inHours} පැය පෙර'
          : '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return isSinhala
          ? '${difference.inMinutes} මිනිත්තු පෙර'
          : '${difference.inMinutes}m ago';
    } else {
      return isSinhala ? 'දැන්' : 'now';
    }
  }
}
