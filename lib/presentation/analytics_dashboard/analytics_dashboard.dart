import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/widgets/custom_bottom_bar.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_breakdown.dart';
import './widgets/date_navigation.dart';
import './widgets/expense_pie_chart.dart';
import './widgets/spending_trends_chart.dart';
import './widgets/summary_metrics.dart';
import './widgets/time_period_selector.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  String _selectedPeriod = 'Weekly';
  DateTime _currentDate = DateTime.now();
  bool _isLoading = false;

  // Mock data for analytics
  final List<Map<String, dynamic>> _mockExpenseData = [
    {"category": "Food", "amount": 15000.0},
    {"category": "Transportation", "amount": 8500.0},
    {"category": "Bills", "amount": 12000.0},
    {"category": "Entertainment", "amount": 5500.0},
    {"category": "Shopping", "amount": 9200.0},
    {"category": "Health", "amount": 3800.0},
  ];

  final List<Map<String, dynamic>> _mockWeeklyTrends = [
    {"label": "Mon", "amount": 2500.0},
    {"label": "Tue", "amount": 1800.0},
    {"label": "Wed", "amount": 3200.0},
    {"label": "Thu", "amount": 2100.0},
    {"label": "Fri", "amount": 4500.0},
    {"label": "Sat", "amount": 3800.0},
    {"label": "Sun", "amount": 2200.0},
  ];

  final List<Map<String, dynamic>> _mockMonthlyTrends = [
    {"label": "Week 1", "amount": 18500.0},
    {"label": "Week 2", "amount": 22300.0},
    {"label": "Week 3", "amount": 19800.0},
    {"label": "Week 4", "amount": 25400.0},
  ];

  final List<Map<String, dynamic>> _mockCategoryBreakdown = [
    {"category": "Food", "amount": 15000.0, "transactions": 28},
    {"category": "Bills", "amount": 12000.0, "transactions": 8},
    {"category": "Shopping", "amount": 9200.0, "transactions": 15},
    {"category": "Transportation", "amount": 8500.0, "transactions": 22},
    {"category": "Entertainment", "amount": 5500.0, "transactions": 12},
    {"category": "Health", "amount": 3800.0, "transactions": 6},
  ];

  final Map<String, dynamic> _mockMetrics = {
    "totalSpent": 54000.0,
    "avgDaily": 7714.0,
    "topCategory": "Food",
    "savingsRate": 23.5,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
        title: Text('Analytics', style: theme.appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _shareReport,
            tooltip: 'Share Report',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showMoreOptions,
            tooltip: 'More Options',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    // Time period selector
                    TimePeriodSelector(
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: _onPeriodChanged,
                    ),
                    SizedBox(height: 4.h),

                    // Date navigation
                    DateNavigation(
                      currentDate: _currentDate,
                      period: _selectedPeriod,
                      onPreviousPressed: _navigateToPrevious,
                      onNextPressed: _navigateToNext,
                    ),
                    SizedBox(height: 6.h),
                  ],
                ),
              ),
            ),

            // Charts and content
            if (_isLoading)
              SliverToBoxAdapter(child: _buildLoadingState())
            else if (_hasData())
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      // Summary metrics
                      SummaryMetrics(metricsData: _mockMetrics),
                      SizedBox(height: 6.h),

                      // Expense pie chart
                      ExpensePieChart(
                        expenseData: _mockExpenseData,
                        period: _selectedPeriod,
                      ),
                      SizedBox(height: 6.h),

                      // Spending trends chart
                      SpendingTrendsChart(
                        trendData: _selectedPeriod == 'Weekly'
                            ? _mockWeeklyTrends
                            : _mockMonthlyTrends,
                        period: _selectedPeriod,
                      ),
                      SizedBox(height: 6.h),

                      // Category breakdown
                      CategoryBreakdown(categoryData: _mockCategoryBreakdown),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              )
            else
              SliverToBoxAdapter(child: _buildEmptyState()),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/analytics-dashboard',
        onRouteChanged: (route) {
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
      ),
    );
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    HapticFeedback.lightImpact();
    _refreshData();
  }

  void _navigateToPrevious() {
    setState(() {
      if (_selectedPeriod == 'Weekly') {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      }
    });
    HapticFeedback.lightImpact();
    _refreshData();
  }

  void _navigateToNext() {
    final now = DateTime.now();
    final nextDate = _selectedPeriod == 'Weekly'
        ? _currentDate.add(const Duration(days: 7))
        : DateTime(_currentDate.year, _currentDate.month + 1, 1);

    if (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
      setState(() {
        _currentDate = nextDate;
      });
      HapticFeedback.lightImpact();
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate data loading
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
    });

    HapticFeedback.lightImpact();
  }

  void _shareReport() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Analytics report shared successfully'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMoreOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 4.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_download',
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Export Data'),
              onTap: () {
                Navigator.pop(context);
                _exportData();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Chart Settings'),
              onTap: () {
                Navigator.pop(context);
                _showChartSettings();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'help_outline',
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data export feature coming soon'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showChartSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chart settings feature coming soon'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics Help'),
        content: const Text(
          'This dashboard shows your spending patterns and financial insights. '
          'Switch between weekly and monthly views to see different trends. '
          'Tap on chart segments for detailed breakdowns.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  bool _hasData() {
    return _mockExpenseData.isNotEmpty;
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Loading skeleton for metrics
          Row(
            children: [
              Expanded(child: _buildSkeletonCard()),
              SizedBox(width: 4.w),
              Expanded(child: _buildSkeletonCard()),
            ],
          ),
          SizedBox(height: 4.w),
          Row(
            children: [
              Expanded(child: _buildSkeletonCard()),
              SizedBox(width: 4.w),
              Expanded(child: _buildSkeletonCard()),
            ],
          ),
          SizedBox(height: 6.h),

          // Loading skeleton for charts
          Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  SizedBox(height: 2.h),
                  Text(
                    'Loading analytics...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    final theme = Theme.of(context);

    return Container(
      height: 20.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10.h),
          CustomIconWidget(
            iconName: 'analytics',
            color: theme.colorScheme.onSurfaceVariant,
            size: 80,
          ),
          SizedBox(height: 4.h),
          Text(
            'No Data Available',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Add transactions to see insights and analytics',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add-transaction');
            },
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 20,
            ),
            label: const Text('Add Transaction'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            ),
          ),
        ],
      ),
    );
  }
}
