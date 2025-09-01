import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/widgets/custom_bottom_bar.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/amount_input_field.dart';
import './widgets/category_selection_field.dart';
import './widgets/date_selection_field.dart';
import './widgets/description_input_field.dart';
import './widgets/save_cancel_buttons.dart';
import './widgets/transaction_type_toggle.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isExpense = true;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isVoiceActive = false;
  bool _isLoading = false;

  String? _amountError;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      if (_amountController.text.isEmpty) {
        _amountError = 'Amount is required';
      } else {
        final amount = double.tryParse(_amountController.text);
        if (amount == null || amount <= 0) {
          _amountError = 'Please enter a valid amount';
        } else {
          _amountError = null;
        }
      }
      if (_selectedCategory == null || _selectedCategory!.isEmpty) {
        _categoryError = 'Please select a category';
      } else {
        _categoryError = null;
      }
    });
  }

  bool get _isFormValid {
    return _amountError == null &&
        _categoryError == null &&
        _amountController.text.isNotEmpty &&
        _selectedCategory != null;
  }

  void _handleTransactionTypeChange(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      _selectedCategory = null;
    });
    HapticFeedback.lightImpact();
    _validateForm();
  }

  void _handleCategorySelection(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _validateForm();
  }

  void _handleDateSelection(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _handleVoiceInput() {
    setState(() {
      _isVoiceActive = !_isVoiceActive;
    });
    if (_isVoiceActive) {
      _startVoiceRecognition();
    } else {
      _stopVoiceRecognition();
    }
  }

  void _startVoiceRecognition() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_isVoiceActive) {
        setState(() {
          _descriptionController.text = 'Lunch at restaurant with colleagues';
          _isVoiceActive = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice input completed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _stopVoiceRecognition() {
    setState(() {
      _isVoiceActive = false;
    });
  }

  void _handleSave() async {
    _validateForm();
    if (!_isFormValid) {
      HapticFeedback.heavyImpact();
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_isExpense ? 'Expense' : 'Income'} of Rs. ${_amountController.text} saved successfully',
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard-home',
        (route) => false,
      );
    }
  }

  void _handleCancel() {
    if (_hasUnsavedChanges()) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.pop(context);
    }
  }

  bool _hasUnsavedChanges() {
    return _amountController.text.isNotEmpty ||
        _selectedCategory != null ||
        _descriptionController.text.isNotEmpty ||
        !_isToday(_selectedDate);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'close',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: _handleCancel,
        ),
        actions: [
          if (_isFormValid && !_isLoading)
            TextButton(
              onPressed: _handleSave,
              child: Text(
                'Save',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 5.w,
                right: 5.w,
                top: 2.h,
                bottom: 12.h, // space for bottom buttons
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TransactionTypeToggle(
                      isExpense: _isExpense,
                      onChanged: _handleTransactionTypeChange,
                    ),
                    SizedBox(height: 3.h),
                    AmountInputField(
                      controller: _amountController,
                      errorText: _amountError,
                      onChanged: (value) => _validateForm(),
                    ),
                    SizedBox(height: 2.h),
                    CategorySelectionField(
                      selectedCategory: _selectedCategory,
                      isExpense: _isExpense,
                      onCategorySelected: _handleCategorySelection,
                      errorText: _categoryError,
                    ),
                    SizedBox(height: 2.h),
                    DateSelectionField(
                      selectedDate: _selectedDate,
                      onDateSelected: _handleDateSelection,
                    ),
                    SizedBox(height: 2.h),
                    DescriptionInputField(
                      controller: _descriptionController,
                      onVoicePressed: _handleVoiceInput,
                      isVoiceActive: _isVoiceActive,
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
            // Fixed Save/Cancel Buttons
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SaveCancelButtons(
                onSave: _handleSave,
                onCancel: _handleCancel,
                isLoading: _isLoading,
                isEnabled: _isFormValid,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/add-transaction',
        onRouteChanged: (route) {
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
      ),
    );
  }
}
