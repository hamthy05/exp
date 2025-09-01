import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Theme settings widget with light/dark mode toggle and accent color selection
class ThemeSettingsWidget extends StatelessWidget {
  final bool isDarkMode;
  final Color accentColor;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<Color> onAccentColorChanged;

  const ThemeSettingsWidget({
    super.key,
    required this.isDarkMode,
    required this.accentColor,
    required this.onDarkModeChanged,
    required this.onAccentColorChanged,
  });

  static const List<Color> _accentColors = [
    Color(0xFF2E7D32), // Default green
    Color(0xFF1976D2), // Blue
    Color(0xFF7B1FA2), // Purple
    Color(0xFFD32F2F), // Red
    Color(0xFFFF8F00), // Orange
    Color(0xFF455A64), // Blue Grey
    Color(0xFF8BC34A), // Light Green
    Color(0xFF00ACC1), // Cyan
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Theme Customization',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Dark mode toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dark Mode',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDarkMode
                            ? 'Switch to light theme'
                            : 'Switch to dark theme',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    onDarkModeChanged(value);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // System preference detection
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.brightness_auto,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Follow System Theme',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Automatically match your device theme',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: false, // For now, disabled
                  onChanged: null, // Will be implemented in future
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Accent color selection
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.color_lens,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Accent Color',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose your preferred accent color',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _accentColors
                      .map((color) => _buildColorOption(
                            context,
                            color,
                            accentColor == color,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onAccentColorChanged(color);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(77),
              blurRadius: isSelected ? 8 : 4,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 24,
              )
            : null,
      ),
    );
  }
}
