import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EmptyGoalsWidget extends StatelessWidget {
  const EmptyGoalsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 40.sp, color: Colors.grey[400]),
          SizedBox(height: 2.h),
          Text(
            'No savings goals yet.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
