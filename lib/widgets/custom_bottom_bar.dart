import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom bar variant types
enum BottomBarVariant {
  /// Standard bottom navigation with 5 tabs
  standard,

  /// Compact bottom navigation with 3 main tabs
  compact,

  /// Bottom navigation with floating action button integration
  withFab,
}

/// with contextual navigation and micro-feedback interactions
class CustomBottomBar extends StatelessWidget {
  /// Navigation item data structure
  static const List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      route: '/dashboard-home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    _NavigationItem(
      route: '/transaction-history',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'History',
    ),
    _NavigationItem(
      route: '/add-transaction',
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: 'Add',
    ),
    _NavigationItem(
      route: '/analytics-dashboard',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
    ),
    _NavigationItem(
      route: '/settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  /// Compact navigation items (3 main tabs)
  static const List<_NavigationItem> _compactNavigationItems = [
    _NavigationItem(
      route: '/dashboard-home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    _NavigationItem(
      route: '/transaction-history',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'History',
    ),
    _NavigationItem(
      route: '/analytics-dashboard',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
    ),
  ];

  /// The variant of the bottom bar
  final BottomBarVariant variant;

  /// Current selected route
  final String currentRoute;

  /// Callback when navigation item is tapped
  final ValueChanged<String>? onRouteChanged;

  /// Whether to show labels
  final bool showLabels;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom elevation
  final double? elevation;

  const CustomBottomBar({
    super.key,
    this.variant = BottomBarVariant.standard,
    required this.currentRoute,
    this.onRouteChanged,
    this.showLabels = true,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = variant == BottomBarVariant.compact
        ? _compactNavigationItems
        : _navigationItems;

    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          // height:
          //     kBottomNavigationBarHeight +
          //     MediaQuery.of(context).padding.bottom,
          // height: showLabels ? 65 : 60,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items
                .map(
                  (item) =>
                      _buildNavigationItem(context, item, items.indexOf(item)),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// Builds individual navigation item with micro-feedback interactions
  Widget _buildNavigationItem(
    BuildContext context,
    _NavigationItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentRoute == item.route;
    final selectedColor =
        theme.bottomNavigationBarTheme.selectedItemColor ??
        theme.colorScheme.primary;
    final unselectedColor =
        theme.bottomNavigationBarTheme.unselectedItemColor ??
        theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(context, item.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with scale animation
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withAlpha(26)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? selectedColor : unselectedColor,
                    size: 24,
                  ),
                ),
              ),

              // Label with fade animation
              if (showLabels) ...[
                const SizedBox(height: 4),
                AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.7,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    item.label,
                    style: theme.bottomNavigationBarTheme.selectedLabelStyle
                        ?.copyWith(
                          color: isSelected ? selectedColor : unselectedColor,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Handles navigation with haptic feedback and route management
  void _handleNavigation(BuildContext context, String route) {
    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Don't navigate if already on the same route
    if (currentRoute == route) return;

    // Handle special navigation cases
    if (route == '/add-transaction') {
      _showAddTransactionModal(context);
      return;
    }

    // Call custom callback if provided
    if (onRouteChanged != null) {
      onRouteChanged!(route);
      return;
    }

    // Default navigation behavior
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  /// Shows add transaction modal with contextual bottom sheet
  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withAlpha(77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Add Transaction',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Quick action buttons
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildQuickActionButton(
                      context,
                      icon: Icons.mic,
                      title: 'Voice Input',
                      subtitle: 'Add transaction by speaking',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/voice-input-modal');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActionButton(
                      context,
                      icon: Icons.edit,
                      title: 'Manual Entry',
                      subtitle: 'Add transaction manually',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add-transaction');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActionButton(
                      context,
                      icon: Icons.camera_alt,
                      title: 'Scan Receipt',
                      subtitle: 'Add transaction from receipt photo',
                      onTap: () {
                        Navigator.pop(context);
                        _showComingSoon(context, 'Receipt scanning');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds quick action button for add transaction modal
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline.withAlpha(51)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows coming soon message
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Internal navigation item data structure
class _NavigationItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavigationItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
