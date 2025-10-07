import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../services/categoryService.dart';
import '../../../services/authService.dart';

/// Quick category selection chips for common expenses
class CategoryChipsWidget extends StatefulWidget {
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
  State<CategoryChipsWidget> createState() => _CategoryChipsWidgetState();
}

class _CategoryChipsWidgetState extends State<CategoryChipsWidget> {
  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
  }

  Future<List<dynamic>> _fetchCategories() async {
    final token = await AuthService.getToken();
    if (token == null) return [];
    // You can set isExpense as needed, here true for expense categories
    return await CategoryService.getCategories(token, isExpense: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isSinhala ? 'ප්‍රවර්ග' : 'Quick Categories',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        FutureBuilder<List<dynamic>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Text(
                  widget.isSinhala ? 'ප්‍රවර්ග නොමැත' : 'No categories found',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
            final categories = snapshot.data!;
            return Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: categories
                  .map((category) => _buildCategoryChip(context, category))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, dynamic category) {
    final theme = Theme.of(context);
    final isSelected = widget.selectedCategory == category['id'];
    final label = widget.isSinhala
        ? (category['sinhala'] ?? category['name'] ?? '')
        : (category['english'] ?? category['name'] ?? '');

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onCategorySelected(category['id']);
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
                : theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: category['icon'] ?? 'category',
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
