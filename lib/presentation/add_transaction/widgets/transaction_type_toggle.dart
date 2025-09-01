import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';


/// Transaction type toggle widget for switching between Expense and Income
class TransactionTypeToggle extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;

  const TransactionTypeToggle({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.w),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isExpense) {
                  HapticFeedback.lightImpact();
                  onChanged(true);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color:
                      isExpense ? theme.colorScheme.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: Center(
                  child: Text(
                    'Expense',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isExpense
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isExpense ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isExpense) {
                  HapticFeedback.lightImpact();
                  onChanged(false);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: !isExpense
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: Center(
                  child: Text(
                    'Income',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: !isExpense
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          !isExpense ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
