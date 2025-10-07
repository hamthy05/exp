import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/authService.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/app_info_widget.dart';
import './widgets/currency_settings_widget.dart';
import './widgets/data_management_widget.dart';
import './widgets/language_settings_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/theme_settings_widget.dart';
import './widgets/voice_settings_widget.dart';
import 'widgets/reminder_screen.dart';

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

  late AnimationController _logoutAnimationController;
  late Animation<double> _logoutAnimation;

  // Section animation controller
  late AnimationController _sectionAnimationController;
  late Animation<double> _sectionAnimation;

  String _selectedLanguage = 'English';
  String _selectedCurrency = 'LKR';
  double _microphoneSensitivity = 0.7;
  bool _offlineRecognition = true;
  bool _transactionReminders = true;
  bool _goalMilestoneAlerts = true;
  bool _spendingLimitWarnings = true;
  bool _isDarkMode = false;
  Color _accentColor = const Color(0xFF6C63FF); // Modern accent color

  // Theme customization variables
  ThemeMode _themeMode = ThemeMode.light;
  bool _followSystemTheme = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );

    _logoutAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _logoutAnimation = CurvedAnimation(
      parent: _logoutAnimationController,
      curve: Curves.easeInOut,
    );
    _logoutAnimationController.forward();

    _sectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sectionAnimation = CurvedAnimation(
      parent: _sectionAnimationController,
      curve: Curves.easeInOut,
    );
    _sectionAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    _logoutAnimationController.dispose();
    _sectionAnimationController.dispose();
    super.dispose();
  }

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
      final accentColorValue = prefs.getInt('accent_color') ?? 0xFF6C63FF;
      _accentColor = Color(accentColorValue);

      // Theme customization
      String? themeModeStr = prefs.getString('theme_mode');
      if (themeModeStr == 'ThemeMode.dark') {
        _themeMode = ThemeMode.dark;
      } else if (themeModeStr == 'ThemeMode.light') {
        _themeMode = ThemeMode.light;
      } else if (themeModeStr == 'ThemeMode.system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
      _followSystemTheme = prefs.getBool('follow_system_theme') ?? false;
    });
  }

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
    HapticFeedback.lightImpact();
  }

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

  bool _shouldShowSection(String sectionTitle, List<String> keywords) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return sectionTitle.toLowerCase().contains(query) ||
        keywords.any((keyword) => keyword.toLowerCase().contains(query));
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  // Theme mode change function
  void _changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
      _isDarkMode = mode == ThemeMode.dark;
      _followSystemTheme = mode == ThemeMode.system;
    });
    _saveSetting('theme_mode', mode.toString());
    _saveSetting('dark_mode', _isDarkMode);
    _saveSetting('follow_system_theme', _followSystemTheme);
  }

  Widget _animatedSection({required Widget child, required int index}) {
    double start = 0.1 * index;
    double end = start + 0.4;
    if (end > 1.0) end = 1.0;
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _sectionAnimationController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.95),
          child: Container(padding: const EdgeInsets.all(18), child: child),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFFB2FEFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                title: 'Settings',
                actions: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isSearchVisible
                        ? Container(
                            key: const ValueKey('search_field'),
                            width: 220,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
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
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                ),
                              ),
                              style: theme.textTheme.bodyMedium,
                              autofocus: true,
                            ),
                          )
                        : IconButton(
                            key: const ValueKey('search_icon'),
                            icon: const Icon(Icons.search),
                            onPressed: _toggleSearch,
                          ),
                  ),
                  if (_isSearchVisible)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _toggleSearch,
                    ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_shouldShowSection('Language', [
                        'sinhala',
                        'english',
                        'font',
                        'locale',
                      ]))
                        _animatedSection(
                          index: 1,
                          child: LanguageSettingsWidget(
                            selectedLanguage: _selectedLanguage,
                            onLanguageChanged: (language) {
                              setState(() {
                                _selectedLanguage = language;
                              });
                              _saveSetting('language', language);
                            },
                          ),
                        ),
                      if (_shouldShowSection('Currency', [
                        'lkr',
                        'format',
                        'decimal',
                        'money',
                      ]))
                        _animatedSection(
                          index: 2,
                          child: CurrencySettingsWidget(
                            selectedCurrency: _selectedCurrency,
                            onCurrencyChanged: (currency) {
                              setState(() {
                                _selectedCurrency = currency;
                              });
                              _saveSetting('currency', currency);
                            },
                          ),
                        ),
                      if (_shouldShowSection('Voice Input', [
                        'microphone',
                        'sensitivity',
                        'speech',
                        'recognition',
                      ]))
                        _animatedSection(
                          index: 3,
                          child: VoiceSettingsWidget(
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
                            },
                          ),
                        ),
                      if (_shouldShowSection('Reminders', [
                        'reminder',
                        'alert',
                        'notification',
                      ]))
                        _animatedSection(
                          index: 8,
                          child: ListTile(
                            leading: Icon(Icons.alarm, color: _accentColor),
                            title: Text('Manage Reminders'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReminderScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      if (_shouldShowSection('Data Management', [
                        'export',
                        'backup',
                        'clear',
                        'csv',
                        'pdf',
                      ]))
                        _animatedSection(
                          index: 5,
                          child: const DataManagementWidget(),
                        ),
                      if (_shouldShowSection('Theme', [
                        'dark',
                        'light',
                        'appearance',
                        'color',
                        'system',
                      ]))
                        _animatedSection(
                          index: 6,
                          child: ThemeSettingsWidget(
                            isDarkMode: _isDarkMode,
                            accentColor: _accentColor,
                            followSystemTheme: _followSystemTheme,
                            onDarkModeChanged: (value) {
                              _changeThemeMode(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
                            },
                            onAccentColorChanged: (color) {
                              setState(() {
                                _accentColor = color;
                              });
                              _saveSetting('accent_color', color.value);
                            },
                            onFollowSystemThemeChanged: (value) {
                              _changeThemeMode(
                                value
                                    ? ThemeMode.system
                                    : (_isDarkMode
                                          ? ThemeMode.dark
                                          : ThemeMode.light),
                              );
                            },
                          ),
                        ),
                      if (_shouldShowSection('App Information', [
                        'version',
                        'privacy',
                        'terms',
                        'support',
                        'about',
                      ]))
                        _animatedSection(
                          index: 7,
                          child: const AppInfoWidget(),
                        ),
                      const SizedBox(height: 32),
                      FadeTransition(
                        opacity: _logoutAnimation,
                        child: Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                            ),
                            onPressed: _handleLogout,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              CustomBottomBar(
                currentRoute: '/settings',
                onRouteChanged: (route) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    route,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
