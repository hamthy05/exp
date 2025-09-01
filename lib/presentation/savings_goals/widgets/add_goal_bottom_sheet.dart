import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AddGoalBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onGoalAdded;

  const AddGoalBottomSheet({
    super.key,
    required this.onGoalAdded,
  });

  @override
  State<AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends State<AddGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedIcon = 'savings';
  String _selectedCategory = 'Personal';

  final List<Map<String, String>> _goalIcons = [
    {'icon': 'savings', 'label': 'Savings'},
    {'icon': 'flight_takeoff', 'label': 'Travel'},
    {'icon': 'phone_android', 'label': 'Phone'},
    {'icon': 'directions_car', 'label': 'Car'},
    {'icon': 'home', 'label': 'Home'},
    {'icon': 'school', 'label': 'Education'},
    {'icon': 'medical_services', 'label': 'Health'},
    {'icon': 'celebration', 'label': 'Event'},
  ];

  final List<String> _categories = [
    'Personal',
    'Emergency',
    'Investment',
    'Travel',
    'Education',
    'Health',
  ];

  final List<String> _smartSuggestions = [
    'Emergency Fund',
    'Vacation Fund',
    'New Phone',
    'Car Down Payment',
    'Wedding Fund',
    'Education Fund',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(theme),
          _buildHeader(context, theme),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(6.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSmartSuggestions(theme),
                    SizedBox(height: 4.h),
                    _buildGoalNameField(theme),
                    SizedBox(height: 3.h),
                    _buildTargetAmountField(theme),
                    SizedBox(height: 3.h),
                    _buildTargetDateField(context, theme),
                    SizedBox(height: 3.h),
                    _buildCategorySelection(theme),
                    SizedBox(height: 3.h),
                    _buildIconSelection(theme),
                    SizedBox(height: 4.h),
                    _buildCreateButton(context, theme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      width: 40,
      height: 4,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        children: [
          Text(
            'Create New Goal',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSuggestions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Suggestions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _smartSuggestions.map((suggestion) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _nameController.text = suggestion;
                  _setDefaultsForSuggestion(suggestion);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGoalNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Name',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter goal name (English/Sinhala)',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'flag',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a goal name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTargetAmountField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Amount',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: '0.00',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Text(
                'Rs.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter target amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTargetDateField(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Date',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
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
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select target date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _selectedDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  CustomIconWidget(
                    iconName: 'arrow_drop_down',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedCategory = category);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Icon',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1,
          ),
          itemCount: _goalIcons.length,
          itemBuilder: (context, index) {
            final iconData = _goalIcons[index];
            final isSelected = _selectedIcon == iconData['icon'];

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedIcon = iconData['icon']!);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: iconData['icon']!,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        iconData['label']!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _createGoal,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Create Goal',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _setDefaultsForSuggestion(String suggestion) {
    switch (suggestion) {
      case 'Emergency Fund':
        _selectedIcon = 'medical_services';
        _selectedCategory = 'Emergency';
        _amountController.text = '100000.00';
        break;
      case 'Vacation Fund':
        _selectedIcon = 'flight_takeoff';
        _selectedCategory = 'Travel';
        _amountController.text = '50000.00';
        break;
      case 'New Phone':
        _selectedIcon = 'phone_android';
        _selectedCategory = 'Personal';
        _amountController.text = '75000.00';
        break;
      case 'Car Down Payment':
        _selectedIcon = 'directions_car';
        _selectedCategory = 'Personal';
        _amountController.text = '500000.00';
        break;
      case 'Wedding Fund':
        _selectedIcon = 'celebration';
        _selectedCategory = 'Personal';
        _amountController.text = '200000.00';
        break;
      case 'Education Fund':
        _selectedIcon = 'school';
        _selectedCategory = 'Education';
        _amountController.text = '150000.00';
        break;
    }
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      HapticFeedback.lightImpact();
      setState(() => _selectedDate = picked);
    }
  }

  void _createGoal() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target date')),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final goal = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text.trim(),
      'targetAmount': double.parse(_amountController.text),
      'currentAmount': 0.0,
      'targetDate': _selectedDate!.toIso8601String(),
      'category': _selectedCategory,
      'icon': _selectedIcon,
      'createdAt': DateTime.now().toIso8601String(),
    };

    widget.onGoalAdded(goal);
    Navigator.pop(context);
  }
}