import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Category selection field with bottom sheet picker
class CategorySelectionField extends StatelessWidget {
  final String? selectedCategory;
  final bool isExpense;
  final ValueChanged<String> onCategorySelected;
  final String? errorText;

  const CategorySelectionField({
    super.key,
    this.selectedCategory,
    required this.isExpense,
    required this.onCategorySelected,
    this.errorText,
  });

  // Mock expense categories
  final List<Map<String, dynamic>> expenseCategories = const [
    {"name": "Food & Dining", "icon": "restaurant", "color": 0xFFFF6B6B},
    {"name": "Transportation", "icon": "directions_car", "color": 0xFF4ECDC4},
    {"name": "Shopping", "icon": "shopping_bag", "color": 0xFF45B7D1},
    {"name": "Bills & Utilities", "icon": "receipt", "color": 0xFF96CEB4},
    {"name": "Healthcare", "icon": "local_hospital", "color": 0xFFFECA57},
    {"name": "Entertainment", "icon": "movie", "color": 0xFFFF9FF3},
    {"name": "Education", "icon": "school", "color": 0xFF54A0FF},
    {"name": "Travel", "icon": "flight", "color": 0xFF5F27CD},
    {"name": "Groceries", "icon": "local_grocery_store", "color": 0xFF00D2D3},
    {"name": "Personal Care", "icon": "spa", "color": 0xFFFF9F43},
    {"name": "Gifts", "icon": "card_giftcard", "color": 0xFFEE5A6F},
    {"name": "Other", "icon": "more_horiz", "color": 0xFF778CA3},
  ];

  // Mock income categories
  final List<Map<String, dynamic>> incomeCategories = const [
    {"name": "Salary", "icon": "work", "color": 0xFF2ECC71},
    {"name": "Freelance", "icon": "laptop", "color": 0xFF3498DB},
    {"name": "Business", "icon": "business", "color": 0xFF9B59B6},
    {"name": "Investment", "icon": "trending_up", "color": 0xFFE74C3C},
    {"name": "Rental", "icon": "home", "color": 0xFFF39C12},
    {"name": "Bonus", "icon": "star", "color": 0xFF1ABC9C},
    {"name": "Gift", "icon": "card_giftcard", "color": 0xFFE67E22},
    {"name": "Refund", "icon": "refresh", "color": 0xFF34495E},
    {"name": "Other", "icon": "more_horiz", "color": 0xFF95A5A6},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = isExpense ? expenseCategories : incomeCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _showCategoryBottomSheet(context, categories),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(
                color: errorText != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (selectedCategory != null) ...[
                  _getCategoryIcon(selectedCategory!, categories),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: Text(
                    selectedCategory ?? 'Select Category',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selectedCategory != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 8.h),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _getCategoryIcon(
      String categoryName, List<Map<String, dynamic>> categories) {
    final category = categories.firstWhere(
      (cat) => cat['name'] == categoryName,
      orElse: () => categories.last,
    );

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Color(category['color'] as int).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: CustomIconWidget(
        iconName: category['icon'] as String,
        color: Color(category['color'] as int),
        size: 20,
      ),
    );
  }

  void _showCategoryBottomSheet(
      BuildContext context, List<Map<String, dynamic>> categories) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.w),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: [
                  Text(
                    'Select ${isExpense ? 'Expense' : 'Income'} Category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Categories grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category['name'];

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onCategorySelected(category['name'] as String);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(category['color'] as int)
                                  .withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12.w),
                          border: Border.all(
                            color: isSelected
                                ? Color(category['color'] as int)
                                : Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Color(category['color'] as int)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.w),
                              ),
                              child: CustomIconWidget(
                                iconName: category['icon'] as String,
                                color: Color(category['color'] as int),
                                size: 28,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              category['name'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Color(category['color'] as int)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Create custom category button
            Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    _showCreateCategoryDialog(context);
                  },
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Create Custom Category'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 16.h),
            Text(
              'Custom categories will be available for future transactions.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                HapticFeedback.lightImpact();
                onCategorySelected(nameController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Custom category "${nameController.text.trim()}" created'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
