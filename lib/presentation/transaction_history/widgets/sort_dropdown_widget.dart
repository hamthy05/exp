import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
  categoryAZ,
  categoryZA,
}

class SortDropdownWidget extends StatelessWidget {
  final SortOption selectedSort;
  final ValueChanged<SortOption> onSortChanged;

  const SortDropdownWidget({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: selectedSort,
          onChanged: (SortOption? newValue) {
            if (newValue != null) {
              HapticFeedback.lightImpact();
              onSortChanged(newValue);
            }
          },
          icon: CustomIconWidget(
            iconName: 'keyboard_arrow_down',
            color: theme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          dropdownColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          items: [
            DropdownMenuItem(
              value: SortOption.dateNewest,
              child: _buildDropdownItem(
                context,
                icon: 'schedule',
                text: 'Date (Newest First)',
              ),
            ),
            DropdownMenuItem(
              value: SortOption.dateOldest,
              child: _buildDropdownItem(
                context,
                icon: 'history',
                text: 'Date (Oldest First)',
              ),
            ),
            DropdownMenuItem(
              value: SortOption.amountHighest,
              child: _buildDropdownItem(
                context,
                icon: 'trending_up',
                text: 'Amount (Highest First)',
              ),
            ),
            DropdownMenuItem(
              value: SortOption.amountLowest,
              child: _buildDropdownItem(
                context,
                icon: 'trending_down',
                text: 'Amount (Lowest First)',
              ),
            ),
            DropdownMenuItem(
              value: SortOption.categoryAZ,
              child: _buildDropdownItem(
                context,
                icon: 'sort_by_alpha',
                text: 'Category (A-Z)',
              ),
            ),
            DropdownMenuItem(
              value: SortOption.categoryZA,
              child: _buildDropdownItem(
                context,
                icon: 'sort_by_alpha',
                text: 'Category (Z-A)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem(
    BuildContext context, {
    required String icon,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
        SizedBox(width: 3.w),
        Text(
          text,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  static String getSortDisplayText(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        return 'Sort: Date (Newest)';
      case SortOption.dateOldest:
        return 'Sort: Date (Oldest)';
      case SortOption.amountHighest:
        return 'Sort: Amount (High)';
      case SortOption.amountLowest:
        return 'Sort: Amount (Low)';
      case SortOption.categoryAZ:
        return 'Sort: Category (A-Z)';
      case SortOption.categoryZA:
        return 'Sort: Category (Z-A)';
    }
  }
}
