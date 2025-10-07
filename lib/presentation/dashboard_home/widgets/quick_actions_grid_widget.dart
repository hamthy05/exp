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
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              double aspectRatio = constraints.maxWidth > 600 ? 1.1 : 1.3;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 2.h,
                childAspectRatio: aspectRatio,
                children: [
                  _ActionCard(
                    icon: 'mic',
                    title: isSinhala ? 'වියදම් එකතු කරන්න' : 'Add Expense',
                    color: theme.colorScheme.error,
                    onTap: onAddExpense,
                  ),
                  _ActionCard(
                    icon: 'add',
                    title: isSinhala ? 'ආදායම් එකතු කරන්න' : 'Add Income',
                    color: theme.colorScheme.tertiary,
                    onTap: onAddIncome,
                  ),
                  _ActionCard(
                    icon: 'graphic_eq',
                    title: isSinhala ? 'හඬ ආදානය' : 'Voice Input',
                    color: theme.colorScheme.secondary,
                    onTap: onVoiceInput,
                  ),
                  _ActionCard(
                    icon: 'flag',
                    title: isSinhala ? 'ඉලක්ක' : 'Goals',
                    color: Colors.purple,
                    onTap: onGoals,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final String icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isProminent;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.isProminent = false,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovering = false;
  bool _pressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.isProminent
        ? widget.color.withOpacity(0.15)
        : theme.colorScheme.surface;
    final hoverColor = widget.color.withOpacity(0.18);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: widget.isProminent
                  ? LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.13),
                        widget.color.withOpacity(0.22),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isProminent
                  ? null
                  : (_hovering ? hoverColor : baseColor),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.isProminent
                    ? widget.color.withOpacity(0.3)
                    : theme.colorScheme.outline.withOpacity(0.18),
                width: widget.isProminent ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(widget.isProminent ? 3.5.w : 3.w),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(_hovering ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: CustomIconWidget(
                    iconName: widget.icon,
                    color: widget.color,
                    size: widget.isProminent ? 30 : 24,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  widget.title,
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
        ),
      ),
    );
  }
}
