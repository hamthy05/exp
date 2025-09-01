import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SummaryMetrics extends StatelessWidget {
  final Map<String, dynamic> metricsData;

  const SummaryMetrics({
    super.key,
    required this.metricsData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total Spent',
                'Rs. ${(metricsData['totalSpent'] as double).toStringAsFixed(2)}',
                'account_balance_wallet',
                const Color(0xFFD32F2F),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildMetricCard(
                context,
                'Avg Daily',
                'Rs. ${(metricsData['avgDaily'] as double).toStringAsFixed(2)}',
                'trending_up',
                const Color(0xFF388E3C),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.w),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Top Category',
                metricsData['topCategory'] as String,
                'star',
                const Color(0xFFFF8F00),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildMetricCard(
                context,
                'Savings Rate',
                '${(metricsData['savingsRate'] as double).toStringAsFixed(1)}%',
                'savings',
                const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String iconName,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
