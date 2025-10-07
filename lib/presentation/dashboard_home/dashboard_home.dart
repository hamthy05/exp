import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/widgets/custom_bottom_bar.dart';
import 'package:sizer/sizer.dart';

import '../../services/transactionService.dart';
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

  late Future<List<Map<String, dynamic>>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = TransactionService.getTransactions();
  }

  double _calculateTotalBalance(List<Map<String, dynamic>> transactions) {
    double balance = 0;
    for (var transaction in transactions) {
      if ((transaction['type'] as String) == 'income') {
        balance += transaction['amount'] as double;
      } else {
        balance -= transaction['amount'] as double;
      }
    }
    return balance;
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
      _transactionsFuture = TransactionService.getTransactions();
    });

    HapticFeedback.mediumImpact();

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

  void _handleVoiceInput() {
    HapticFeedback.mediumImpact();

    if (_isVoiceListening) {
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _transactionsFuture,
                builder: (context, snapshot) {
                  final transactions = snapshot.data ?? [];
                  final recentTransactions = transactions.length > 5
                      ? transactions.sublist(0, 5)
                      : transactions;

                  return SingleChildScrollView(
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
                          totalBalance: _calculateTotalBalance(transactions),
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
                          transactions: recentTransactions,
                          isSinhala: _isSinhala,
                          onViewAll: _navigateToTransactionHistory,
                        ),

                        // Bottom padding for floating button
                        SizedBox(height: 12.h),
                      ],
                    ),
                  );
                },
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
        currentRoute: '/dashboard-home',
        onRouteChanged: (route) {
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
      ),
    );
  }
}
