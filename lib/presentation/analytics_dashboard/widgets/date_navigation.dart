import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DateNavigation extends StatelessWidget {
  final DateTime currentDate;
  final String period;
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const DateNavigation({
    super.key,
    required this.currentDate,
    required this.period,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPreviousPressed,
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        Text(
          _getDateRangeText(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: onNextPressed,
          icon: CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
      ],
    );
  }

  String _getDateRangeText() {
    if (period == 'Weekly') {
      final startOfWeek =
          currentDate.subtract(Duration(days: currentDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}';
    } else {
      return '${_getMonthName(currentDate.month)} ${currentDate.year}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
