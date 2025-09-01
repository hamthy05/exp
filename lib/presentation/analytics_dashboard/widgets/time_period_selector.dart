import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class TimePeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const TimePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _buildPeriodButton(
            context,
            'Weekly',
            selectedPeriod == 'Weekly',
          ),
          _buildPeriodButton(
            context,
            'Monthly',
            selectedPeriod == 'Monthly',
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
      BuildContext context, String period, bool isSelected) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => onPeriodChanged(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              period,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
