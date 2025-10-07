import 'package:flutter/material.dart';
import '../presentation/analytics_dashboard/analytics_dashboard.dart';
import '../presentation/savings_goals/savings_goals.dart';
import '../presentation/transaction_history/transaction_history.dart';
import '../presentation/add_transaction/add_transaction.dart';
import '../presentation/voice_input_modal/voice_input_modal.dart';
import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/settings/settings.dart';
import '../presentation/auth/auth_screen.dart';
import '../presentation/analytics_dashboard/widgets/category_list_screen.dart';
import '../presentation/transaction_history/widgets/edit_transaction.dart';
import '../presentation/transaction_history/widgets/transaction_detail.dart';
import '../presentation/settings/widgets/reminder_screen.dart';


class AppRoutes {
  static const String initial = '/';
  static const String analyticsDashboard = '/analytics-dashboard';
  static const String savingsGoals = '/savings-goals';
  static const String transactionHistory = '/transaction-history';
  static const String addTransaction = '/add-transaction';
  static const String voiceInputModal = '/voice-input-modal';
  static const String dashboardHome = '/dashboard-home';
  static const String settings = '/settings';
  static const String categoryList = '/category-list';
  static const String editTransaction = '/edit-transaction';
  static const String transactionDetail = '/transaction-detail';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const AuthScreen(), // <-- Set AuthScreen as initial
    analyticsDashboard: (context) => const AnalyticsDashboard(),
    savingsGoals: (context) => const SavingsGoals(),
    transactionHistory: (context) => const TransactionHistory(),
    addTransaction: (context) => const AddTransaction(),
    voiceInputModal: (context) => const VoiceInputModal(),
    dashboardHome: (context) => const DashboardHome(),
    settings: (context) => const Settings(),
    categoryList: (context) => CategoryListScreen(
      token: ModalRoute.of(context)!.settings.arguments as String,
    ),
    editTransaction: (context) {
      final tx =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return EditTransaction(transaction: tx);
    },
    transactionDetail: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as String;
      return TransactionDetail(transactionId: id);
    },
    // TODO: Add your other routes here
  };
}
