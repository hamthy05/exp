import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AppBar variant types
enum AppBarVariant {
  /// Standard app bar with title and optional actions
  standard,
  /// App bar with search functionality
  search,
  /// App bar with voice input capability
  voice,
  /// Minimal app bar with back button only
  minimal,
}

/// Custom AppBar widget implementing Contemporary Financial Minimalism design
/// with voice input pulse animation and contextual actions for personal finance app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The variant of the app bar
  final AppBarVariant variant;
  
  /// The title to display in the app bar
  final String? title;
  
  /// Custom title widget (overrides title string)
  final Widget? titleWidget;
  
  /// List of action widgets to display
  final List<Widget>? actions;
  
  /// Whether to show the back button
  final bool showBackButton;
  
  /// Custom leading widget
  final Widget? leading;
  
  /// Callback for search functionality
  final ValueChanged<String>? onSearchChanged;
  
  /// Callback for voice input
  final VoidCallback? onVoicePressed;
  
  /// Whether voice input is currently active
  final bool isVoiceActive;
  
  /// Background color override
  final Color? backgroundColor;
  
  /// Elevation override
  final double? elevation;

  const CustomAppBar({
    super.key,
    this.variant = AppBarVariant.standard,
    this.title,
    this.titleWidget,
    this.actions,
    this.showBackButton = true,
    this.leading,
    this.onSearchChanged,
    this.onVoicePressed,
    this.isVoiceActive = false,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: elevation ?? theme.appBarTheme.elevation,
      shadowColor: theme.appBarTheme.shadowColor,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light 
            ? Brightness.dark 
            : Brightness.light,
      ),
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: _buildActions(context),
    );
  }

  /// Builds the leading widget based on variant and configuration
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        tooltip: 'Back',
      );
    }
    
    return null;
  }

  /// Builds the title widget based on variant and configuration
  Widget? _buildTitle(BuildContext context) {
    if (titleWidget != null) return titleWidget;
    
    switch (variant) {
      case AppBarVariant.search:
        return _buildSearchField(context);
      case AppBarVariant.voice:
        return _buildVoiceTitle(context);
      case AppBarVariant.minimal:
        return null;
      case AppBarVariant.standard:
      default:
        return title != null 
            ? Text(
                title!,
                style: Theme.of(context).appBarTheme.titleTextStyle,
              )
            : null;
    }
  }

  /// Builds the search field for search variant
  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(77),
        ),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  /// Builds the voice title with pulse animation
  Widget _buildVoiceTitle(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Voice pulse animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isVoiceActive ? 12 : 8,
          height: isVoiceActive ? 12 : 8,
          decoration: BoxDecoration(
            color: isVoiceActive 
                ? theme.colorScheme.secondary
                : theme.colorScheme.onSurfaceVariant,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          isVoiceActive ? 'Listening...' : 'Voice Input',
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            color: isVoiceActive 
                ? theme.colorScheme.secondary
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Builds the actions list based on variant and configuration
  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final defaultActions = <Widget>[];
    
    // Add variant-specific actions
    switch (variant) {
      case AppBarVariant.voice:
        defaultActions.add(
          IconButton(
            icon: AnimatedScale(
              scale: isVoiceActive ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isVoiceActive ? Icons.mic : Icons.mic_none,
                color: isVoiceActive 
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface,
              ),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              onVoicePressed?.call();
            },
            tooltip: isVoiceActive ? 'Stop listening' : 'Start voice input',
          ),
        );
        break;
      case AppBarVariant.search:
        defaultActions.add(
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showFilterBottomSheet(context);
            },
            tooltip: 'Filter',
          ),
        );
        break;
      default:
        break;
    }
    
    // Add custom actions
    if (actions != null) {
      defaultActions.addAll(actions!);
    }
    
    // Add common actions based on current route
    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    switch (currentRoute) {
      case '/dashboard-home':
        defaultActions.add(
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showNotifications(context);
            },
            tooltip: 'Notifications',
          ),
        );
        defaultActions.add(
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showProfileMenu(context);
            },
            tooltip: 'Profile',
          ),
        );
        break;
      case '/transaction-history':
        defaultActions.add(
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showDatePicker(context);
            },
            tooltip: 'Select date range',
          ),
        );
        break;
      case '/analytics-dashboard':
        defaultActions.add(
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              _shareReport(context);
            },
            tooltip: 'Share report',
          ),
        );
        break;
    }
    
    return defaultActions.isNotEmpty ? defaultActions : null;
  }

  /// Shows filter bottom sheet for search variant
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            // Filter options would go here
            Text(
              'Filter options coming soon...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Shows notifications
  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Shows profile menu
  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile Settings'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('App Settings'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Shows date picker for transaction history
  void _showDatePicker(BuildContext context) {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );
  }

  /// Shares analytics report
  void _shareReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share report feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}