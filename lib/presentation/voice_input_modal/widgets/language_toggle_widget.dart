import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';


/// Language toggle widget for switching between Sinhala and English
class LanguageToggleWidget extends StatelessWidget {
  final bool isSinhala;
  final ValueChanged<bool> onLanguageChanged;

  const LanguageToggleWidget({
    super.key,
    required this.isSinhala,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(
            context,
            label: 'සිං',
            isSelected: isSinhala,
            onTap: () {
              if (!isSinhala) {
                HapticFeedback.lightImpact();
                onLanguageChanged(true);
              }
            },
          ),
          _buildLanguageOption(
            context,
            label: 'EN',
            isSelected: !isSinhala,
            onTap: () {
              if (isSinhala) {
                HapticFeedback.lightImpact();
                onLanguageChanged(false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
