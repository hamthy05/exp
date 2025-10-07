import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/goalService.dart';

class AddGoalBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onGoalAdded;

  const AddGoalBottomSheet({super.key, required this.onGoalAdded});

  @override
  State<AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends State<AddGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  DateTime? _deadline;
  bool _isLoading = false;

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a deadline")));
      return;
    }
    setState(() => _isLoading = true);

    final goalData = {
      "name": _nameController.text.trim(),
      "targetAmount": double.parse(_targetAmountController.text),
      "deadline": _deadline!.toIso8601String(),
    };

    final success = await GoalService.createGoal(goalData);

    setState(() => _isLoading = false);

    if (success) {
      widget.onGoalAdded(goalData);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Goal created successfully!")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to create goal")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create Savings Goal",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Goal Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter goal name" : null,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Target Amount",
                  prefixText: "Rs ",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Enter amount";
                  if (double.tryParse(v) == null) return "Enter valid number";
                  return null;
                },
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline == null
                          ? "No deadline selected"
                          : "Deadline: ${_deadline!.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(fontSize: 11.sp),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDeadline,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Pick Deadline"),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Create Goal"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
