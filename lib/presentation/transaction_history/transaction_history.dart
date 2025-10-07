import 'package:flutter/material.dart';
import 'package:flutter_app/services/transactionService.dart';
import 'package:flutter_app/services/authService.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_bottom_bar.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  late Future<List<Map<String, dynamic>>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = TransactionService.getTransactions();
  }

  Map<String, List<Map<String, dynamic>>> _groupByDate(
    List<Map<String, dynamic>> txs,
  ) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var tx in txs) {
      String date = (tx['date'] as DateTime).toString().substring(0, 10);
      grouped.putIfAbsent(date, () => []).add(tx);
    }
    return grouped;
  }

  Future<void> _deleteTransaction(String id) async {
    final token = await AuthService.getToken();
    if (token == null) return;
    final success = await TransactionService.deleteTransaction(token, id);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Transaction deleted!")));
      setState(() {
        _transactionsFuture = TransactionService.getTransactions();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete transaction")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search transactions...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            // Sort/filter row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sort: Date (Newest)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                Icon(Icons.filter_list, color: Colors.green),
              ],
            ),
            SizedBox(height: 2.h),
            // Transaction list
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _transactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No transactions found"));
                  }
                  final grouped = _groupByDate(snapshot.data!);
                  return ListView(
                    children: grouped.entries.map((entry) {
                      final date = entry.key;
                      final txs = entry.value;
                      final netAmount = txs.fold<double>(
                        0,
                        (sum, tx) =>
                            sum +
                            (tx['type'] == 'expense'
                                ? -tx['amount']
                                : tx['amount']),
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${date.split('-').reversed.join('/')}",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: netAmount < 0
                                        ? Colors.red.withOpacity(0.08)
                                        : netAmount > 0
                                        ? Colors.green.withOpacity(0.08)
                                        : Colors.blue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "${netAmount < 0
                                        ? '-'
                                        : netAmount > 0
                                        ? '+'
                                        : ''}Rs. ${netAmount.abs().toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: netAmount < 0
                                          ? Colors.red[700]
                                          : netAmount > 0
                                          ? Colors.green[700]
                                          : Colors.blue[700],
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Transaction cards
                          ...txs.map(
                            (tx) => Container(
                              margin: EdgeInsets.symmetric(vertical: 0.7.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.15),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                minVerticalPadding: 0,
                                leading: CircleAvatar(
                                  backgroundColor: _parseColor(
                                    tx['category']?['color'],
                                  ),
                                  radius: 22,
                                  child: Icon(
                                    _getIconData(tx['category']?['icon']),
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tx['category']?['name'] ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.5.sp,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${tx['type'] == 'expense' ? '-' : '+'}Rs. ${tx['amount'].toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: tx['type'] == 'expense'
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // if ((tx['description'] ?? '').isNotEmpty)
                                    //   Padding(
                                    //     padding: const EdgeInsets.only(
                                    //       top: 2.0,
                                    //     ),
                                    //     child: Text(
                                    //       tx['description'] ?? '',
                                    //       style: TextStyle(
                                    //         fontSize: 10.sp,
                                    //         color: Colors.grey[700],
                                    //       ),
                                    //       maxLines: 1,
                                    //       overflow: TextOverflow.ellipsis,
                                    //     ),
                                    //   ),
                                    const SizedBox(height: 2.0),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            tx['type'] == 'expense'
                                                ? Icons.arrow_downward
                                                : Icons.arrow_upward,
                                            color: tx['type'] == 'expense'
                                                ? Colors.red
                                                : Colors.green,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            tx['type'] == 'expense'
                                                ? "Expense"
                                                : "Income",
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: tx['type'] == 'expense'
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (tx['isRecurring'] == true)
                                            Container(
                                              margin: EdgeInsets.only(left: 8),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.repeat,
                                                    color: Colors.orange,
                                                    size: 14,
                                                  ),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    "Recurring",
                                                    style: TextStyle(
                                                      fontSize: 9.sp,
                                                      color: Colors.orange,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        Navigator.pushNamed(
                                          context,
                                          '/edit-transaction',
                                          arguments: tx,
                                        ).then((_) {
                                          setState(() {
                                            _transactionsFuture =
                                                TransactionService.getTransactions();
                                          });
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text("Delete Transaction"),
                                            content: Text(
                                              "Are you sure you want to delete this transaction?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: Text("No"),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: Text("Yes"),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await _deleteTransaction(tx['_id']);
                                        }
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/transaction-detail',
                                    arguments: tx['_id'],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction');
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/transaction-history',
        onRouteChanged: (route) {
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
      ),
      backgroundColor: Color(0xFFF7F7F7),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'receipt':
        return Icons.receipt_long;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  Color? _parseColor(dynamic colorString) {
    if (colorString == null) return Colors.orange;
    if (colorString is int) return Color(colorString);
    String hex = colorString.toString().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse('0x$hex'));
  }
}
