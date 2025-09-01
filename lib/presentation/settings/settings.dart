import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/app_info_widget.dart';
import './widgets/currency_settings_widget.dart';
import './widgets/data_management_widget.dart';
import './widgets/language_settings_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/theme_settings_widget.dart';
import './widgets/voice_settings_widget.dart';

/// Settings screen providing comprehensive app configuration within bottom tab navigation
/// Features language selection, currency preferences, voice input settings, notifications,
/// data management, theme customization, and app information
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchVisible = false;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  // Settings state management
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'LKR';
  double _microphoneSensitivity = 0.7;
  bool _offlineRecognition = true;
  bool _transactionReminders = true;
  bool _goalMilestoneAlerts = true;
  bool _spendingLimitWarnings = true;
  bool _isDarkMode = false;
  Color _accentColor = const Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _searchAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _searchAnimation = CurvedAnimation(
        parent: _searchAnimationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _selectedCurrency = prefs.getString('currency') ?? 'LKR';
      _microphoneSensitivity = prefs.getDouble('mic_sensitivity') ?? 0.7;
      _offlineRecognition = prefs.getBool('offline_recognition') ?? true;
      _transactionReminders = prefs.getBool('transaction_reminders') ?? true;
      _goalMilestoneAlerts = prefs.getBool('goal_milestone_alerts') ?? true;
      _spendingLimitWarnings = prefs.getBool('spending_limit_warnings') ?? true;
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      final accentColorValue = prefs.getInt('accent_color') ?? 0xFF2E7D32;
      _accentColor = Color(accentColorValue);
    });
  }

  /// Save individual setting to SharedPreferences
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  /// Toggle search visibility
  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  /// Filter settings based on search query
  bool _shouldShowSection(String sectionTitle, List<String> keywords) {
    if (_searchQuery.isEmpty) return true;

    final query = _searchQuery.toLowerCase();
    return sectionTitle.toLowerCase().contains(query) ||
        keywords.any((keyword) => keyword.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(title: 'Settings', actions: [
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isSearchVisible
                  ? Container(
                      key: const ValueKey('search_field'),
                      width: 200,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                              hintText: 'Search settings...',
                              hintStyle: theme.textTheme.bodySmall,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  })),
                          style: theme.textTheme.bodyMedium,
                          autofocus: true))
                  : IconButton(
                      key: const ValueKey('search_icon'),
                      icon: const Icon(Icons.search),
                      onPressed: _toggleSearch)),
          if (_isSearchVisible)
            IconButton(icon: const Icon(Icons.close), onPressed: _toggleSearch),
        ]),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Language Settings
              if (_shouldShowSection(
                  'Language', ['sinhala', 'english', 'font', 'locale']))
                LanguageSettingsWidget(
                    selectedLanguage: _selectedLanguage,
                    onLanguageChanged: (language) {
                      setState(() {
                        _selectedLanguage = language;
                      });
                      _saveSetting('language', language);
                    }),

              const SizedBox(height: 24),

              // Currency Settings
              if (_shouldShowSection(
                  'Currency', ['lkr', 'format', 'decimal', 'money']))
                CurrencySettingsWidget(
                    selectedCurrency: _selectedCurrency,
                    onCurrencyChanged: (currency) {
                      setState(() {
                        _selectedCurrency = currency;
                      });
                      _saveSetting('currency', currency);
                    }),

              const SizedBox(height: 24),

              // Voice Input Settings
              if (_shouldShowSection('Voice Input',
                  ['microphone', 'sensitivity', 'speech', 'recognition']))
                VoiceSettingsWidget(
                    microphoneSensitivity: _microphoneSensitivity,
                    offlineRecognition: _offlineRecognition,
                    onSensitivityChanged: (value) {
                      setState(() {
                        _microphoneSensitivity = value;
                      });
                      _saveSetting('mic_sensitivity', value);
                    },
                    onOfflineRecognitionChanged: (value) {
                      setState(() {
                        _offlineRecognition = value;
                      });
                      _saveSetting('offline_recognition', value);
                    }),

              const SizedBox(height: 24),

              // Notification Settings
              if (_shouldShowSection('Notifications',
                  ['alerts', 'reminders', 'warnings', 'goals']))
                NotificationSettingsWidget(
                    transactionReminders: _transactionReminders,
                    goalMilestoneAlerts: _goalMilestoneAlerts,
                    spendingLimitWarnings: _spendingLimitWarnings,
                    onTransactionRemindersChanged: (value) {
                      setState(() {
                        _transactionReminders = value;
                      });
                      _saveSetting('transaction_reminders', value);
                    },
                    onGoalMilestoneAlertsChanged: (value) {
                      setState(() {
                        _goalMilestoneAlerts = value;
                      });
                      _saveSetting('goal_milestone_alerts', value);
                    },
                    onSpendingLimitWarningsChanged: (value) {
                      setState(() {
                        _spendingLimitWarnings = value;
                      });
                      _saveSetting('spending_limit_warnings', value);
                    }),

              const SizedBox(height: 24),

              // Data Management
              if (_shouldShowSection('Data Management',
                  ['export', 'backup', 'clear', 'csv', 'pdf']))
                const DataManagementWidget(),

              const SizedBox(height: 24),

              // Theme Settings
              if (_shouldShowSection(
                  'Theme', ['dark', 'light', 'appearance', 'color']))
                ThemeSettingsWidget(
                    isDarkMode: _isDarkMode,
                    accentColor: _accentColor,
                    onDarkModeChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      _saveSetting('dark_mode', value);
                    },
                    onAccentColorChanged: (color) {
                      setState(() {
                        _accentColor = color;
                      });
                      _saveSetting('accent_color', color.value);
                    }),

              const SizedBox(height: 24),

              // App Information
              if (_shouldShowSection('App Information',
                  ['version', 'privacy', 'terms', 'support', 'about']))
                const AppInfoWidget(),

              const SizedBox(height: 100), // Extra space for bottom navigation
            ])),
        bottomNavigationBar: CustomBottomBar(
            currentRoute: '/settings',
            onRouteChanged: (route) {
              Navigator.pushNamedAndRemoveUntil(
                  context, route, (route) => false);
            }));
  }
}
