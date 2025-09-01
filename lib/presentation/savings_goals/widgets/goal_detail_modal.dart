import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class GoalDetailModal extends StatefulWidget {
  final Map<String, dynamic> goal;
  final Function(double) onContribute;

  const GoalDetailModal({
    super.key,
    required this.goal,
    required this.onContribute,
  });

  @override
  State<GoalDetailModal> createState() => _GoalDetailModalState();
}

class _GoalDetailModalState extends State<GoalDetailModal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _contributionController = TextEditingController();

  final List<Map<String, dynamic>> _contributionHistory = [
    {
      'id': 1,
      'amount': 5000.0,
      'date': '2025-01-15',
      'type': 'manual',
      'description': 'Monthly savings contribution',
    },
    {
      'id': 2,
      'amount': 2500.0,
      'date': '2025-01-10',
      'type': 'automatic',
      'description': 'Automatic transfer from checking',
    },
    {
      'id': 3,
      'amount': 1000.0,
      'date': '2025-01-05',
      'type': 'manual',
      'description': 'Bonus money allocation',
    },
  ];

  final List<Map<String, dynamic>> _milestones = [
    {
      'percentage': 25,
      'amount': 25000.0,
      'achieved': true,
      'date': '2025-01-10',
      'title': 'Quarter Way There!',
    },
    {
      'percentage': 50,
      'amount': 50000.0,
      'achieved': false,
      'date': null,
      'title': 'Halfway Milestone',
    },
    {
      'percentage': 75,
      'amount': 75000.0,
      'achieved': false,
      'date': null,
      'title': 'Three Quarters Done',
    },
    {
      'percentage': 100,
      'amount': 100000.0,
      'achieved': false,
      'date': null,
      'title': 'Goal Achieved!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contributionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(theme),
          _buildHeader(context, theme),
          _buildGoalSummary(theme),
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme),
                _buildHistoryTab(theme),
                _buildMilestonesTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      width: 40,
      height: 4,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: widget.goal['icon'] as String,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.goal['name'] as String,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.goal['category'] != null) ...[
                  Text(
                    widget.goal['category'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSummary(ThemeData theme) {
    final currentAmount = widget.goal['currentAmount'] as double;
    final targetAmount = widget.goal['targetAmount'] as double;
    final progress = currentAmount / targetAmount;
    final progressPercentage = (progress * 100).clamp(0, 100).toInt();

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Amount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Rs. ${currentAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
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
                    'Target Amount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Rs. ${targetAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$progressPercentage%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'History'),
          Tab(text: 'Milestones'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    final targetDate = DateTime.parse(widget.goal['targetDate'] as String);
    final now = DateTime.now();
    final daysRemaining = targetDate.difference(now).inDays;
    final remainingAmount = (widget.goal['targetAmount'] as double) -
        (widget.goal['currentAmount'] as double);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(theme, daysRemaining, remainingAmount),
          SizedBox(height: 3.h),
          _buildContributeSection(theme),
          SizedBox(height: 3.h),
          _buildRecentActivity(theme),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
      ThemeData theme, int daysRemaining, double remainingAmount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            icon: 'schedule',
            title: 'Days Left',
            value: daysRemaining > 0 ? '$daysRemaining' : 'Overdue',
            color: daysRemaining > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatCard(
            theme,
            icon: 'trending_up',
            title: 'Remaining',
            value: 'Rs. ${remainingAmount.toStringAsFixed(0)}',
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributeSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Contribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _contributionController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Text(
                        'Rs.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              ElevatedButton(
                onPressed: _addContribution,
                child: Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    final recentContributions = _contributionHistory.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        ...recentContributions
            .map((contribution) => _buildActivityItem(theme, contribution))
            .toList(),
      ],
    );
  }

  Widget _buildActivityItem(
      ThemeData theme, Map<String, dynamic> contribution) {
    final isAutomatic = contribution['type'] == 'automatic';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isAutomatic
                  ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: isAutomatic ? 'autorenew' : 'add_circle',
              color: isAutomatic
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contribution['description'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  contribution['date'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+Rs. ${(contribution['amount'] as double).toStringAsFixed(2)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _contributionHistory.length,
      itemBuilder: (context, index) {
        final contribution = _contributionHistory[index];
        return _buildActivityItem(theme, contribution);
      },
    );
  }

  Widget _buildMilestonesTab(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _milestones.length,
      itemBuilder: (context, index) {
        final milestone = _milestones[index];
        return _buildMilestoneItem(theme, milestone);
      },
    );
  }

  Widget _buildMilestoneItem(ThemeData theme, Map<String, dynamic> milestone) {
    final isAchieved = milestone['achieved'] as bool;

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isAchieved
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAchieved
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isAchieved
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: isAchieved ? 'check' : 'radio_button_unchecked',
              color: isAchieved
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone['title'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isAchieved
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${milestone['percentage']}% - Rs. ${(milestone['amount'] as double).toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isAchieved && milestone['date'] != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    'Achieved on ${milestone['date']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addContribution() {
    final amount = double.tryParse(_contributionController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    widget.onContribute(amount);
    _contributionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added Rs. ${amount.toStringAsFixed(2)} to your goal!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
