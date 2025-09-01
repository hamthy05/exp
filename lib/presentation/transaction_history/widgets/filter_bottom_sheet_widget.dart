import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final DateTimeRange? selectedDateRange;
  final List<String> selectedCategories;
  final RangeValues amountRange;
  final double maxAmount;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(List<String>) onCategoriesChanged;
  final Function(RangeValues) onAmountRangeChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onApplyFilters;

  const FilterBottomSheetWidget({
    super.key,
    this.selectedDateRange,
    required this.selectedCategories,
    required this.amountRange,
    required this.maxAmount,
    required this.onDateRangeChanged,
    required this.onCategoriesChanged,
    required this.onAmountRangeChanged,
    required this.onClearFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late DateTimeRange? _selectedDateRange;
  late List<String> _selectedCategories;
  late RangeValues _amountRange;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food & Dining', 'icon': 'restaurant', 'type': 'expense'},
    {'name': 'Transportation', 'icon': 'directions_car', 'type': 'expense'},
    {'name': 'Shopping', 'icon': 'shopping_bag', 'type': 'expense'},
    {'name': 'Bills & Utilities', 'icon': 'receipt', 'type': 'expense'},
    {'name': 'Healthcare', 'icon': 'local_hospital', 'type': 'expense'},
    {'name': 'Entertainment', 'icon': 'movie', 'type': 'expense'},
    {'name': 'Salary', 'icon': 'work', 'type': 'income'},
    {'name': 'Freelance', 'icon': 'laptop', 'type': 'income'},
    {'name': 'Business', 'icon': 'business', 'type': 'income'},
    {'name': 'Investment', 'icon': 'trending_up', 'type': 'income'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDateRange = widget.selectedDateRange;
    _selectedCategories = List.from(widget.selectedCategories);
    _amountRange = widget.amountRange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              children: [
                Text(
                  'Filter Transactions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedDateRange = null;
                      _selectedCategories.clear();
                      _amountRange = RangeValues(0, widget.maxAmount);
                    });
                    widget.onClearFilters();
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // Date Range Section
                  _buildSectionTitle('Date Range'),
                  SizedBox(height: 1.h),
                  _buildDateRangeSelector(context),
                  SizedBox(height: 3.h),

                  // Categories Section
                  _buildSectionTitle('Categories'),
                  SizedBox(height: 1.h),
                  _buildCategorySelector(context),
                  SizedBox(height: 3.h),

                  // Amount Range Section
                  _buildSectionTitle('Amount Range'),
                  SizedBox(height: 1.h),
                  _buildAmountRangeSelector(context),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      widget.onDateRangeChanged(_selectedDateRange);
                      widget.onCategoriesChanged(_selectedCategories);
                      widget.onAmountRangeChanged(_amountRange);
                      widget.onApplyFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
          initialDateRange: _selectedDateRange,
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: theme.colorScheme.primary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _selectedDateRange = picked;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'calendar_today',
              color: theme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                _selectedDateRange != null
                    ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                    : 'Select date range',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _selectedDateRange != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (_selectedDateRange != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedDateRange = null;
                  });
                },
                child: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _categories.map((category) {
        final isSelected = _selectedCategories.contains(category['name']);
        final isExpense = category['type'] == 'expense';

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              if (isSelected) {
                _selectedCategories.remove(category['name']);
              } else {
                _selectedCategories.add(category['name']);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: category['icon'],
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isExpense
                          ? theme.colorScheme.error
                          : theme.colorScheme.tertiary),
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  category['name'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountRangeSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rs. ${_amountRange.start.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Rs. ${_amountRange.end.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        RangeSlider(
          values: _amountRange,
          min: 0,
          max: widget.maxAmount,
          divisions: 20,
          labels: RangeLabels(
            'Rs. ${_amountRange.start.toStringAsFixed(0)}',
            'Rs. ${_amountRange.end.toStringAsFixed(0)}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _amountRange = values;
            });
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
