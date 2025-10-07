import 'package:flutter/material.dart';
import 'package:flutter_app/services/transactionService.dart';
import 'package:sizer/sizer.dart';

class TransactionDetail extends StatefulWidget {
  final String transactionId;
  const TransactionDetail({super.key, required this.transactionId});

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  late Future<Map<String, dynamic>?> _transactionFuture;

  @override
  void initState() {
    super.initState();
    _transactionFuture = TransactionService.getTransactionById(
      widget.transactionId,
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
      // ...add more as needed
      default:
        return Icons.category;
    }
  }

  Color? _parseColor(dynamic colorString) {
    if (colorString == null) return Colors.orange;
    if (colorString is int) return Color(colorString);
    String hex = colorString.toString().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // add alpha if missing
    return Color(int.parse('0x$hex'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Detail")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _transactionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Transaction not found"));
          }
          final tx = snapshot.data!;
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 3.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 10.h,
                          color: tx['type'] == 'expense'
                              ? Colors.red
                              : Colors.green,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "${tx['type'] == 'expense' ? '-' : '+'}Rs. ${tx['amount'].toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: tx['type'] == 'expense'
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _parseColor(
                              tx['category']?['color'],
                            ),
                            radius: 3.5.h,
                            child: Icon(
                              _getIconData(tx['category']?['icon']),
                              color: Colors.white,
                              size: 3.h,
                            ),
                          ),
                          title: Text(
                            tx['category']?['name'] ?? '',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          subtitle: Text(
                            "Category",
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.description, size: 3.h),
                          title: Text(
                            tx['description'] ?? '-',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          subtitle: Text(
                            "Description",
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.calendar_today, size: 3.h),
                          title: Text(
                            tx['date'] is DateTime
                                ? (tx['date'] as DateTime)
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]
                                : tx['date'].toString().split('T')[0],
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          subtitle: Text(
                            "Date",
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.repeat, size: 3.h),
                          title: Text(
                            tx['isRecurring'] == true ? "Yes" : "No",
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          subtitle: Text(
                            "Recurring",
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
