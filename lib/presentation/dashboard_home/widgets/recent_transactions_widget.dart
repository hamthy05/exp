import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentTransactionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final bool isSinhala;
  final VoidCallback onViewAll;

  const RecentTransactionsWidget({
    Key? key,
    required this.transactions,
    required this.isSinhala,
    required this.onViewAll,
  }) : super(key: key);

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
      case 'work':
        return Icons.work;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSinhala ? 'මෑත ගනුදෙනු' : 'Recent Transactions',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  isSinhala ? 'සියල්ල බලන්න' : 'View All',
                  style: TextStyle(fontSize: 11.sp),
                ),
              ),
            ],
          ),
          transactions.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Center(
                    child: Text(
                      isSinhala
                          ? 'ගනුදෙනු எதுவும் இல்லை'
                          : 'No transactions found',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                    ),
                  ),
                )
              : SizedBox(
                  height: 16.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => SizedBox(width: 3.w),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final date = tx['date'] is DateTime
                          ? tx['date']
                          : DateTime.tryParse(tx['date'].toString());
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/transaction-detail',
                            arguments: (tx['_id'] ?? tx['id'])
                                .toString(), 
                          );
                        },
                        child: Container(
                          width: 48.w,
                          padding: EdgeInsets.all(3.w),
                          margin: EdgeInsets.only(bottom: 1.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: _parseColor(
                                        tx['category']?['color'],
                                      )?.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      _getIconData(tx['category']?['icon']),
                                      color: _parseColor(
                                        tx['category']?['color'],
                                      ),
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx['category']?['name'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          tx['description'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 9.5.sp,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.5.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${tx['type'] == 'expense' ? '-' : '+'}Rs. ${tx['amount'].toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: tx['type'] == 'expense'
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    date != null
                                        ? timeago.format(
                                            date,
                                            locale: 'en_short',
                                          )
                                        : '',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
