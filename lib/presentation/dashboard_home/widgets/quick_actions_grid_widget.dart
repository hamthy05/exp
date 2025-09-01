import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuickActionsGridWidget extends StatelessWidget {
  final bool isSinhala;
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onVoiceInput;
  final VoidCallback onGoals;

  const QuickActionsGridWidget({
    super.key,
    required this.isSinhala,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onVoiceInput,
    required this.onGoals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSinhala ? 'ක්ෂණික ක්‍රියාමාර්ග' : 'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.3,
            children: [
              _buildActionCard(
                context,
                icon: 'mic',
                title: isSinhala ? 'වියදම් එකතු කරන්න' : 'Add Expense',
                color: theme.colorScheme.error,
                onTap: onAddExpense,
              ),
              _buildActionCard(
                context,
                icon: 'add',
                title: isSinhala ? 'ආදායම් එකතු කරන්න' : 'Add Income',
                color: theme.colorScheme.tertiary,
                onTap: onAddIncome,
              ),
              _buildActionCard(
                context,
                icon: 'graphic_eq',
                title: isSinhala ? 'හඬ ආදානය' : 'Voice Input',
                color: theme.colorScheme.secondary,
                onTap: onVoiceInput,
                isProminent: true,
              ),
              _buildActionCard(
                context,
                icon: 'flag',
                title: isSinhala ? 'ඉලක්ක' : 'Goals',
                color: theme.colorScheme.primary,
                onTap: onGoals,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isProminent = false,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isProminent
              ? color.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isProminent
                ? color.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isProminent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: isProminent ? 28 : 24,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
