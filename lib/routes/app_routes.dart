import 'package:flutter/material.dart';
import '../presentation/analytics_dashboard/analytics_dashboard.dart';
import '../presentation/savings_goals/savings_goals.dart';
import '../presentation/transaction_history/transaction_history.dart';
import '../presentation/add_transaction/add_transaction.dart';
import '../presentation/voice_input_modal/voice_input_modal.dart';
import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/settings/settings.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String analyticsDashboard = '/analytics-dashboard';
  static const String savingsGoals = '/savings-goals';
  static const String transactionHistory = '/transaction-history';
  static const String addTransaction = '/add-transaction';
  static const String voiceInputModal = '/voice-input-modal';
  static const String dashboardHome = '/dashboard-home';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const Settings(),
    analyticsDashboard: (context) => const AnalyticsDashboard(),
    savingsGoals: (context) => const SavingsGoals(),
    transactionHistory: (context) => const TransactionHistory(),
    addTransaction: (context) => const AddTransaction(),
    voiceInputModal: (context) => const VoiceInputModal(),
    dashboardHome: (context) => const DashboardHome(),
    settings: (context) => const Settings(),
    // TODO: Add your other routes here
  };
}
