import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyGoalsWidget extends StatelessWidget {
  final VoidCallback? onCreateGoal;

  const EmptyGoalsWidget({
    super.key,
    this.onCreateGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(theme),
            SizedBox(height: 4.h),
            _buildTitle(theme),
            SizedBox(height: 2.h),
            _buildDescription(theme),
            SizedBox(height: 4.h),
            _buildCreateButton(context, theme),
            SizedBox(height: 3.h),
            _buildMotivationalTips(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomIconWidget(
            iconName: 'savings',
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            size: 80,
          ),
          Positioned(
            top: 8.w,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onSecondary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      'Set Your First Goal',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      'Start your savings journey by creating your first financial goal. Whether it\'s an emergency fund, vacation, or a new purchase, every goal begins with a single step.',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCreateButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          onCreateGoal?.call();
        },
        icon: CustomIconWidget(
          iconName: 'add_circle',
          color: theme.colorScheme.onPrimary,
          size: 20,
        ),
        label: Text(
          'Create Your First Goal',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationalTips(ThemeData theme) {
    final tips = [
      {
        'icon': 'lightbulb',
        'title': 'Start Small',
        'description': 'Even Rs. 1,000 saved monthly adds up over time',
      },
      {
        'icon': 'trending_up',
        'title': 'Track Progress',
        'description': 'Visual progress tracking keeps you motivated',
      },
      {
        'icon': 'celebration',
        'title': 'Celebrate Wins',
        'description': 'Acknowledge every milestone you achieve',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Tips',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        ...tips.map((tip) => _buildTipItem(theme, tip)).toList(),
      ],
    );
  }

  Widget _buildTipItem(ThemeData theme, Map<String, String> tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: tip['icon']!,
              color: theme.colorScheme.secondary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title']!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  tip['description']!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
