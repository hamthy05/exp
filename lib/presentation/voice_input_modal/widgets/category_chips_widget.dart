import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Quick category selection chips for common expenses
class CategoryChipsWidget extends StatelessWidget {
  final bool isSinhala;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryChipsWidget({
    super.key,
    required this.isSinhala,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSinhala ? 'ප්‍රවර්ග' : 'Quick Categories',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: categories
              .map((category) => _buildCategoryChip(
                    context,
                    category,
                  ))
              .toList(),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getCategories() {
    return [
      {
        'id': 'food',
        'sinhala': 'ආහාර',
        'english': 'Food',
        'icon': 'restaurant',
      },
      {
        'id': 'transport',
        'sinhala': 'ප්‍රවාහනය',
        'english': 'Transport',
        'icon': 'directions_car',
      },
      {
        'id': 'bills',
        'sinhala': 'බිල්පත්',
        'english': 'Bills',
        'icon': 'receipt',
      },
      {
        'id': 'shopping',
        'sinhala': 'සාප්පු සවාරි',
        'english': 'Shopping',
        'icon': 'shopping_bag',
      },
      {
        'id': 'entertainment',
        'sinhala': 'විනෝදාස්වාදය',
        'english': 'Entertainment',
        'icon': 'movie',
      },
      {
        'id': 'health',
        'sinhala': 'සෞඛ්‍යය',
        'english': 'Health',
        'icon': 'local_hospital',
      },
    ];
  }

  Widget _buildCategoryChip(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final theme = Theme.of(context);
    final isSelected = selectedCategory == category['id'];
    final label = isSinhala ? category['sinhala'] : category['english'];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onCategorySelected(category['id']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: category['icon'],
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              size: 4.w,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
