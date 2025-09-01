import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SpendingTrendsChart extends StatefulWidget {
  final List<Map<String, dynamic>> trendData;
  final String period;

  const SpendingTrendsChart({
    super.key,
    required this.trendData,
    required this.period,
  });

  @override
  State<SpendingTrendsChart> createState() => _SpendingTrendsChartState();
}

class _SpendingTrendsChartState extends State<SpendingTrendsChart> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.trendData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Spending Trends',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          SizedBox(
              height: 35.h,
              child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue() * 1.2,
                  barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                                'Rs. ${rod.toY.toStringAsFixed(0)}',
                                TextStyle(
                                    color: theme.colorScheme.onInverseSurface,
                                    fontWeight: FontWeight.w500));
                          })),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 &&
                                    index < widget.trendData.length) {
                                  return Padding(
                                      padding: EdgeInsets.only(top: 1.h),
                                      child: Text(
                                          widget.trendData[index]['label']
                                              as String,
                                          style: theme.textTheme.bodySmall));
                                }
                                return const Text('');
                              },
                              reservedSize: 30)),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                    'Rs.${(value / 1000).toStringAsFixed(0)}k',
                                    style: theme.textTheme.bodySmall);
                              }))),
                  borderData: FlBorderData(
                      show: true,
                      border: Border(
                          bottom: BorderSide(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.2)),
                          left: BorderSide(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.2)))),
                  barGroups: _buildBarGroups(),
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getMaxValue() / 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.1),
                            strokeWidth: 1);
                      })))),
        ]));
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.trendData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
            toY: data['amount'] as double,
            color: Theme.of(context).colorScheme.primary,
            width: 6.w,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxValue() * 1.2,
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1))),
      ]);
    }).toList();
  }

  double _getMaxValue() {
    if (widget.trendData.isEmpty) return 0;
    return widget.trendData
        .map((data) => data['amount'] as double)
        .reduce((a, b) => a > b ? a : b);
  }

  Widget _buildEmptyState(BuildContext context) {
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
                  offset: const Offset(0, 2)),
            ]),
        child: Column(children: [
          Text('Spending Trends',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          CustomIconWidget(
              iconName: 'bar_chart',
              color: theme.colorScheme.onSurfaceVariant,
              size: 64),
          SizedBox(height: 2.h),
          Text('No trend data available',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text('Add transactions to see trends',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ]));
  }
}
