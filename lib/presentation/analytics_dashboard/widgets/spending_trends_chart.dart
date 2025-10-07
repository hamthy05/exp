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

    final maxValue = _getMaxValue();
    final roundedMax = ((maxValue / 10000).ceil() * 10000).toDouble();
    final chartMaxY = roundedMax == 0 ? 10000 : roundedMax;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Trends',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              height: 30.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY.toDouble(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'Rs. ${rod.toY.toStringAsFixed(0)}',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < widget.trendData.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 0.8.h),
                              child: Text(
                                widget.trendData[index]['label'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: 10000,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          if (value % 10000 == 0) {
                            return Text(
                              'Rs.${(value / 1000).toStringAsFixed(0)}k',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 8.5.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.18),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.18),
                        width: 1,
                      ),
                      right: BorderSide.none,
                      top: BorderSide.none,
                    ),
                  ),
                  barGroups: _buildBarGroups(chartMaxY.toDouble()),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withOpacity(0.09),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(double chartMaxY) {
    final theme = Theme.of(context);
    return widget.trendData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data['amount'] as double,
            color: theme.colorScheme.primary,
            width: 6.w.clamp(18.0, 32.0),
            borderRadius: BorderRadius.circular(5),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: chartMaxY,
              color: theme.colorScheme.outline.withOpacity(0.10),
            ),
          ),
        ],
      );
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Spending Trends',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 6.h),
            CustomIconWidget(
              iconName: 'bar_chart',
              color: theme.colorScheme.onSurfaceVariant,
              size: 48.sp,
            ),
            SizedBox(height: 2.h),
            Text(
              'No trend data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Add transactions to see trends',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 9.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
