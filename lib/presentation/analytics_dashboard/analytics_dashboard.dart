import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/widgets/custom_bottom_bar.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/transactionService.dart';
import './widgets/category_breakdown.dart';
import './widgets/date_navigation.dart';
import './widgets/expense_pie_chart.dart';
import './widgets/spending_trends_chart.dart';
import './widgets/summary_metrics.dart';
import './widgets/time_period_selector.dart';
import 'package:flutter_app/services/exportService.dart';
import '../../services/categoryService.dart';
import '../../services/authService.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  String _selectedPeriod = 'Weekly';
  DateTime _currentDate = DateTime.now();
  bool _isLoading = false;

  List<Map<String, dynamic>> _expenseData = [];
  List<Map<String, dynamic>> _trendData = [];
  List<Map<String, dynamic>> _categoryBreakdown = [];
  Map<String, dynamic> _metrics = {};

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    setState(() => _isLoading = true);

    final transactions = await TransactionService.getTransactions();

    // 1. Expense மட்டும் filter செய்யவும்
    final expenses = transactions
        .where((tx) => tx['type'] == 'expense')
        .toList();

    // 2. எல்லா category-களையும் 가져오기
    final token = await AuthService.getToken();
    final allCategories = token != null
        ? await CategoryService.getCategories(token, isExpense: true)
        : [];

    // 3. Category-wise group (transaction இல்லாத category-க்கும்)
    final Map<String, Map<String, dynamic>> grouped = {};
    for (var cat in allCategories) {
      grouped[cat['_id']] = {
        'category': cat['name'],
        'icon': cat['icon'],
        'color': cat['color'],
        'amount': 0.0,
        'transactions': 0,
      };
    }
    for (var tx in expenses) {
      final catObj = tx['category'];
      if (catObj == null) continue;
      final catId = catObj['_id'];
      if (grouped.containsKey(catId)) {
        grouped[catId]!['amount'] += (tx['amount'] as num).toDouble();
        grouped[catId]!['transactions'] += 1;
      }
    }
    _categoryBreakdown = grouped.values.toList();

    // 4. Expense Pie Chart Data
    _expenseData = _categoryBreakdown
        .map(
          (e) => {
            'category': e['category'],
            'amount': e['amount'],
            'color': e['color'],
          },
        )
        .toList();

    // 5. Trend data (weekly/monthly)
    _trendData = _selectedPeriod == 'Weekly'
        ? _getWeeklyTrends(expenses)
        : _getMonthlyTrends(expenses);

    // 6. Metrics
    final totalSpent = expenses.fold<double>(
      0,
      (sum, tx) => sum + (tx['amount'] as num).toDouble(),
    );
    final uniqueDays = expenses
        .map((e) => DateTime.tryParse(e['date'].toString())?.day)
        .where((d) => d != null)
        .toSet()
        .length;
    final avgDaily = expenses.isEmpty || uniqueDays == 0
        ? 0
        : totalSpent / uniqueDays;
    final topCategory = _categoryBreakdown.isEmpty
        ? ''
        : _categoryBreakdown.reduce(
            (a, b) => a['amount'] > b['amount'] ? a : b,
          )['category'];
    _metrics = {
      "totalSpent": totalSpent,
      "avgDaily": avgDaily,
      "topCategory": topCategory,
      "savingsRate": 0, // You can calculate if you have income data
    };

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _getWeeklyTrends(
    List<Map<String, dynamic>> expenses,
  ) {
    // Group by weekday (Mon-Sun)
    final Map<int, double> weekMap = {};
    for (var tx in expenses) {
      final date = DateTime.tryParse(tx['date'].toString());
      if (date != null) {
        final weekday = date.weekday; // 1=Mon, 7=Sun
        weekMap[weekday] =
            (weekMap[weekday] ?? 0) + (tx['amount'] as num).toDouble();
      }
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (i) {
      return {"label": days[i], "amount": weekMap[i + 1] ?? 0};
    });
  }

  List<Map<String, dynamic>> _getMonthlyTrends(
    List<Map<String, dynamic>> expenses,
  ) {
    // Group by week of month (1-4)
    final Map<int, double> monthMap = {};
    for (var tx in expenses) {
      final date = DateTime.tryParse(tx['date'].toString());
      if (date != null) {
        final weekOfMonth = ((date.day - 1) ~/ 7) + 1;
        monthMap[weekOfMonth] =
            (monthMap[weekOfMonth] ?? 0) + (tx['amount'] as num).toDouble();
      }
    }
    return List.generate(4, (i) {
      return {"label": "Week ${i + 1}", "amount": monthMap[i + 1] ?? 0};
    });
  }

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
        onRefresh: _fetchAnalyticsData,
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
                      onPeriodChanged: (period) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                        HapticFeedback.lightImpact();
                        _fetchAnalyticsData();
                      },
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
            else if (_expenseData.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      // Summary metrics
                      SummaryMetrics(metricsData: _metrics),
                      SizedBox(height: 6.h),

                      // Expense pie chart
                      ExpensePieChart(
                        expenseData: _expenseData,
                        period: _selectedPeriod,
                      ),
                      SizedBox(height: 6.h),

                      // Spending trends chart
                      SpendingTrendsChart(
                        trendData: _trendData,
                        period: _selectedPeriod,
                      ),
                      SizedBox(height: 6.h),

                      // Category breakdown
                      CategoryBreakdown(categoryData: _categoryBreakdown),
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

  void _navigateToPrevious() {
    setState(() {
      if (_selectedPeriod == 'Weekly') {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      }
    });
    HapticFeedback.lightImpact();
    _fetchAnalyticsData();
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
      _fetchAnalyticsData();
    }
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
                ).colorScheme.onSurfaceVariant.withOpacity(0.3),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.table_chart,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Export as CSV'),
              subtitle: const Text('Spreadsheet format for analysis'),
              onTap: () {
                Navigator.pop(context);
                exportDataFromBackend(context, 'csv');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.picture_as_pdf,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Export as PDF'),
              subtitle: const Text('Formatted report for sharing'),
              onTap: () {
                Navigator.pop(context);
                exportDataFromBackend(context, 'pdf');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
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
          color: theme.colorScheme.outline.withOpacity(0.1),
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
