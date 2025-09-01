import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/widgets/custom_bottom_bar.dart';
import 'package:sizer/sizer.dart';

import './widgets/balance_card_widget.dart';
import './widgets/floating_voice_button_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/quick_actions_grid_widget.dart';
import './widgets/recent_transactions_widget.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  bool _isSinhala = false;
  bool _isVoiceListening = false;
  bool _isRefreshing = false;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'id': 1,
      'type': 'expense',
      'amount': 1250.00,
      'category': 'Food',
      'description': 'Lunch at restaurant',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 2,
      'type': 'income',
      'amount': 50000.00,
      'category': 'Salary',
      'description': 'Monthly salary',
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 3,
      'type': 'expense',
      'amount': 800.00,
      'category': 'Transport',
      'description': 'Uber ride',
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 4,
      'type': 'expense',
      'amount': 3500.00,
      'category': 'Bills',
      'description': 'Electricity bill',
      'date': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': 5,
      'type': 'income',
      'amount': 15000.00,
      'category': 'Freelance',
      'description': 'Web development project',
      'date': DateTime.now().subtract(const Duration(days: 4)),
    },
  ];

  double get _totalBalance {
    double balance = 0;
    for (var transaction in _recentTransactions) {
      if ((transaction['type'] as String) == 'income') {
        balance += transaction['amount'] as double;
      } else {
        balance -= transaction['amount'] as double;
      }
    }
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _handleRefresh,
              color: theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Header
                    GreetingHeaderWidget(
                      isSinhala: _isSinhala,
                      onLanguageToggle: _toggleLanguage,
                    ),

                    // Balance Card
                    BalanceCardWidget(
                      totalBalance: _totalBalance,
                      isSinhala: _isSinhala,
                    ),

                    // Quick Actions Grid
                    QuickActionsGridWidget(
                      isSinhala: _isSinhala,
                      onAddExpense: _navigateToAddExpense,
                      onAddIncome: _navigateToAddIncome,
                      onVoiceInput: _handleVoiceInput,
                      onGoals: _navigateToGoals,
                    ),

                    // Recent Transactions
                    RecentTransactionsWidget(
                      transactions: _recentTransactions.take(5).toList(),
                      isSinhala: _isSinhala,
                      onDeleteTransaction: _deleteTransaction,
                      onViewAll: _navigateToTransactionHistory,
                    ),

                    // Bottom padding for floating button
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // Floating Voice Button
            FloatingVoiceButtonWidget(
              onPressed: _handleVoiceInput,
              isListening: _isVoiceListening,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/dashboard-home', // இந்த screen-க்கு route
        onRouteChanged: (route) {
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
      ),
    );
  }

  void _toggleLanguage() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSinhala = !_isSinhala;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSinhala
              ? 'භාෂාව සිංහලට වෙනස් කරන ලදී'
              : 'Language changed to English',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSinhala
                ? 'දත්ත යාවත්කාලීන කරන ලදී'
                : 'Data refreshed successfully',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleVoiceInput() {
    HapticFeedback.mediumImpact();

    if (_isVoiceListening) {
      // Stop voice input
      setState(() {
        _isVoiceListening = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSinhala ? 'හඬ ආදානය නතර කරන ලදී' : 'Voice input stopped',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Navigate to voice input modal
      Navigator.pushNamed(context, '/voice-input-modal');
    }
  }

  void _navigateToAddExpense() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/add-transaction',
      arguments: {'type': 'expense'},
    );
  }

  void _navigateToAddIncome() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/add-transaction',
      arguments: {'type': 'income'},
    );
  }

  void _navigateToGoals() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/savings-goals');
  }

  void _navigateToTransactionHistory() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/transaction-history');
  }

  void _deleteTransaction(int index) {
    final deletedTransaction = _recentTransactions[index];

    setState(() {
      _recentTransactions.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSinhala ? 'ගනුදෙනුව මකා දමන ලදී' : 'Transaction deleted',
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: _isSinhala ? 'අහෝසි කරන්න' : 'Undo',
          onPressed: () {
            setState(() {
              _recentTransactions.insert(index, deletedTransaction);
            });
          },
        ),
      ),
    );
  }
}
