import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/goalService.dart';

class GoalCardWidget extends StatelessWidget {
  final Map<String, dynamic> goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback?
  onContributionAdded; // To refresh parent after contribution

  const GoalCardWidget({
    Key? key,
    required this.goal,
    required this.onEdit,
    required this.onDelete,
    this.onContributionAdded,
  }) : super(key: key);

  void _showAddContributionDialog(BuildContext context) {
    final _amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Contribution"),
              content: TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixText: "Rs ",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final amount = double.tryParse(
                            _amountController.text,
                          );
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Enter valid amount"),
                              ),
                            );
                            return;
                          }
                          setState(() => isLoading = true);
                          final updatedGoal = {
                            "currentAmount":
                                (goal['currentAmount'] ?? 0) + amount,
                          };
                          final success = await GoalService.updateGoal(
                            goal['_id'],
                            updatedGoal,
                          );
                          setState(() => isLoading = false);
                          Navigator.pop(ctx);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Contribution added!"),
                              ),
                            );
                            if (onContributionAdded != null)
                              onContributionAdded!();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to add contribution"),
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        (goal['currentAmount'] ?? 0) / (goal['targetAmount'] ?? 1);
    if (progress > 1) progress = 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal['name'] ?? '',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: progress,
            minHeight: 1.2.h,
            backgroundColor: Colors.grey[200],
            color: Colors.green,
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Saved: Rs. ${(goal['currentAmount'] ?? 0).toStringAsFixed(0)}",
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
              ),
              Text(
                "Target: Rs. ${(goal['targetAmount'] ?? 0).toStringAsFixed(0)}",
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.green,
                  size: 22,
                ),
                onPressed: () => _showAddContributionDialog(context),
                tooltip: "Add Contribution",
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: onEdit,
                tooltip: "Edit Goal",
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: onDelete,
                tooltip: "Delete Goal",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
