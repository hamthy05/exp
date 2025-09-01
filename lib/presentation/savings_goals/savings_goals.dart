import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/widgets/custom_bottom_bar.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/add_goal_bottom_sheet.dart';
import './widgets/empty_goals_widget.dart';
import './widgets/goal_card_widget.dart';
import './widgets/goal_detail_modal.dart';

class SavingsGoals extends StatefulWidget {
  const SavingsGoals({super.key});

  @override
  State<SavingsGoals> createState() => _SavingsGoalsState();
}

class _SavingsGoalsState extends State<SavingsGoals> {
  List<Map<String, dynamic>> _goals = [];
  String _sortBy = 'progress'; // progress, amount, date
  bool _sortAscending = false;

  final List<Map<String, dynamic>> _mockGoals = [
    {
      'id': 1,
      'name': 'Emergency Fund',
      'targetAmount': 100000.0,
      'currentAmount': 25000.0,
      'targetDate': '2025-12-31',
      'category': 'Emergency',
      'icon': 'medical_services',
      'createdAt': '2025-01-01',
    },
    {
      'id': 2,
      'name': 'Vacation to Maldives',
      'targetAmount': 150000.0,
      'currentAmount': 75000.0,
      'targetDate': '2025-08-15',
      'category': 'Travel',
      'icon': 'flight_takeoff',
      'createdAt': '2024-12-15',
    },
    {
      'id': 3,
      'name': 'New iPhone',
      'targetAmount': 200000.0,
      'currentAmount': 180000.0,
      'targetDate': '2025-03-01',
      'category': 'Personal',
      'icon': 'phone_android',
      'createdAt': '2024-11-20',
    },
    {
      'id': 4,
      'name': 'Car Down Payment',
      'targetAmount': 500000.0,
      'currentAmount': 125000.0,
      'targetDate': '2026-06-30',
      'category': 'Personal',
      'icon': 'directions_car',
      'createdAt': '2024-10-01',
    },
  ];

  @override
  void initState() {
    super.initState();
    _goals = List.from(_mockGoals);
    _sortGoals();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, theme),
      body: _goals.isEmpty ? _buildEmptyState() : _buildGoalsList(),
      floatingActionButton: _buildFloatingActionButton(theme),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/savings-goals',
        onRouteChanged: (route) {
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      title: Text('Savings Goals', style: theme.appBarTheme.titleTextStyle),
      actions: [
        if (_goals.isNotEmpty) ...[
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'sort',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onSelected: (value) {
              HapticFeedback.lightImpact();
              _changeSortOrder(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'progress',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'trending_up',
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Sort by Progress'),
                    const Spacer(),
                    if (_sortBy == 'progress')
                      CustomIconWidget(
                        iconName: _sortAscending
                            ? 'arrow_upward'
                            : 'arrow_downward',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'amount',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'attach_money',
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Sort by Amount'),
                    const Spacer(),
                    if (_sortBy == 'amount')
                      CustomIconWidget(
                        iconName: _sortAscending
                            ? 'arrow_upward'
                            : 'arrow_downward',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'calendar_today',
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Sort by Date'),
                    const Spacer(),
                    if (_sortBy == 'date')
                      CustomIconWidget(
                        iconName: _sortAscending
                            ? 'arrow_upward'
                            : 'arrow_downward',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showGoalSummary(context);
            },
            icon: CustomIconWidget(
              iconName: 'info_outline',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Goal Summary',
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyGoalsWidget(onCreateGoal: _showAddGoalBottomSheet);
  }

  Widget _buildGoalsList() {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildSummaryCard(theme),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshGoals,
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 20.h),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                return GoalCardWidget(
                  goal: goal,
                  onTap: () => _showGoalDetail(goal),
                  onEdit: () => _editGoal(goal),
                  onDelete: () => _deleteGoal(goal['id'] as int),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final totalGoals = _goals.length;
    final completedGoals = _goals.where((goal) {
      final progress =
          (goal['currentAmount'] as double) / (goal['targetAmount'] as double);
      return progress >= 1.0;
    }).length;
    final totalTarget = _goals.fold<double>(
      0,
      (sum, goal) => sum + (goal['targetAmount'] as double),
    );
    final totalSaved = _goals.fold<double>(
      0,
      (sum, goal) => sum + (goal['currentAmount'] as double),
    );
    final overallProgress = totalTarget > 0
        ? (totalSaved / totalTarget * 100)
        : 0;

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'dashboard',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Goals Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  theme,
                  icon: 'flag',
                  label: 'Total Goals',
                  value: '$totalGoals',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  theme,
                  icon: 'check_circle',
                  label: 'Completed',
                  value: '$completedGoals',
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  theme,
                  icon: 'trending_up',
                  label: 'Progress',
                  value: '${overallProgress.toInt()}%',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Saved',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Rs. ${totalSaved.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Target',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Rs. ${totalTarget.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    ThemeData theme, {
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.secondary,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _showAddGoalBottomSheet,
      icon: CustomIconWidget(
        iconName: 'add',
        color: theme.floatingActionButtonTheme.foregroundColor ?? Colors.white,
        size: 24,
      ),
      label: Text(
        'Add Goal',
        style: TextStyle(
          color:
              theme.floatingActionButtonTheme.foregroundColor ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddGoalBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddGoalBottomSheet(onGoalAdded: _addGoal),
    );
  }

  void _showGoalDetail(Map<String, dynamic> goal) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalDetailModal(
        goal: goal,
        onContribute: (amount) => _addContribution(goal['id'] as int, amount),
      ),
    );
  }

  void _showGoalSummary(BuildContext context) {
    final theme = Theme.of(context);
    final totalGoals = _goals.length;
    final completedGoals = _goals.where((goal) {
      final progress =
          (goal['currentAmount'] as double) / (goal['targetAmount'] as double);
      return progress >= 1.0;
    }).length;
    final onTrackGoals = _goals.where((goal) {
      final targetDate = DateTime.parse(goal['targetDate'] as String);
      final now = DateTime.now();
      final daysRemaining = targetDate.difference(now).inDays;
      final progress =
          (goal['currentAmount'] as double) / (goal['targetAmount'] as double);
      final expectedProgress = 1.0 - (daysRemaining / 365.0);
      return progress >= expectedProgress * 0.8; // 80% of expected progress
    }).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'analytics',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Goals Summary'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(theme, 'Total Goals', '$totalGoals'),
            _buildSummaryRow(theme, 'Completed Goals', '$completedGoals'),
            _buildSummaryRow(theme, 'On Track Goals', '$onTrackGoals'),
            _buildSummaryRow(
              theme,
              'Behind Schedule',
              '${totalGoals - onTrackGoals - completedGoals}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _addGoal(Map<String, dynamic> goal) {
    setState(() {
      _goals.add(goal);
      _sortGoals();
    });

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goal "${goal['name']}" created successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => _showGoalDetail(goal),
        ),
      ),
    );
  }

  void _editGoal(Map<String, dynamic> goal) {
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit goal feature coming soon')),
    );
  }

  void _deleteGoal(int goalId) {
    setState(() {
      _goals.removeWhere((goal) => goal['id'] == goalId);
    });

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Goal deleted successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addContribution(int goalId, double amount) {
    setState(() {
      final goalIndex = _goals.indexWhere((goal) => goal['id'] == goalId);
      if (goalIndex != -1) {
        _goals[goalIndex]['currentAmount'] =
            (_goals[goalIndex]['currentAmount'] as double) + amount;
      }
    });

    // Check if goal is completed
    final goal = _goals.firstWhere((g) => g['id'] == goalId);
    final progress =
        (goal['currentAmount'] as double) / (goal['targetAmount'] as double);

    if (progress >= 1.0) {
      _showGoalCompletedCelebration(goal);
    }
  }

  void _showGoalCompletedCelebration(Map<String, dynamic> goal) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'celebration',
              color: Theme.of(context).colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Congratulations!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'You\'ve successfully achieved your "${goal['name']}" goal!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Rs. ${(goal['targetAmount'] as double).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _changeSortOrder(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
        _sortAscending = false;
      }
      _sortGoals();
    });
  }

  void _sortGoals() {
    _goals.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'progress':
          final progressA =
              (a['currentAmount'] as double) / (a['targetAmount'] as double);
          final progressB =
              (b['currentAmount'] as double) / (b['targetAmount'] as double);
          comparison = progressA.compareTo(progressB);
          break;
        case 'amount':
          comparison = (a['targetAmount'] as double).compareTo(
            b['targetAmount'] as double,
          );
          break;
        case 'date':
          final dateA = DateTime.parse(a['targetDate'] as String);
          final dateB = DateTime.parse(b['targetDate'] as String);
          comparison = dateA.compareTo(dateB);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });
  }

  Future<void> _refreshGoals() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would fetch updated data from the server
    setState(() {
      // Refresh the goals list
    });

    HapticFeedback.lightImpact();
  }
}
