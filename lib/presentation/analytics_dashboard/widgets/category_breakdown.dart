import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CategoryBreakdown extends StatelessWidget {
  final List<Map<String, dynamic>> categoryData;

  const CategoryBreakdown({
    super.key,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (categoryData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Category Breakdown',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          ...categoryData
              .map((category) => _buildCategoryItem(context, category)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, Map<String, dynamic> category) {
    final theme = Theme.of(context);
    final total = categoryData.fold<double>(
      0.0,
      (sum, item) => sum + (item['amount'] as double),
    );
    final percentage = ((category['amount'] as double) / total * 100);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category['category'] as String)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getCategoryIcon(category['category'] as String),
                  color: _getCategoryColor(category['category'] as String),
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['category'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${category['transactions']} transactions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${(category['amount'] as double).toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCategoryColor(category['category'] as String),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFF2E7D32);
      case 'transportation':
        return const Color(0xFF388E3C);
      case 'bills':
        return const Color(0xFF4CAF50);
      case 'entertainment':
        return const Color(0xFF66BB6A);
      case 'shopping':
        return const Color(0xFF81C784);
      case 'health':
        return const Color(0xFF9CCC65);
      case 'education':
        return const Color(0xFFAED581);
      default:
        return const Color(0xFFC5E1A5);
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'restaurant';
      case 'transportation':
        return 'directions_car';
      case 'bills':
        return 'receipt';
      case 'entertainment':
        return 'movie';
      case 'shopping':
        return 'shopping_bag';
      case 'health':
        return 'local_hospital';
      case 'education':
        return 'school';
      default:
        return 'category';
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Category Breakdown',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          CustomIconWidget(
            iconName: 'category',
            color: theme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No category data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'Add transactions to see breakdown',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
