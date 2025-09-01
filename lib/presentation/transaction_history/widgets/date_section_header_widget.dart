import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class DateSectionHeaderWidget extends StatelessWidget {
  final String date;
  final double totalAmount;
  final int transactionCount;

  const DateSectionHeaderWidget({
    super.key,
    required this.date,
    required this.totalAmount,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalAmount >= 0
                    ? '+Rs. ${totalAmount.toStringAsFixed(2)}'
                    : '-Rs. ${(-totalAmount).toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: totalAmount >= 0
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Net Amount',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
