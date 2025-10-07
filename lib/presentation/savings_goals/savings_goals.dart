import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/custom_bottom_bar.dart';
import 'package:sizer/sizer.dart';
import '../../services/goalService.dart';
import './widgets/add_goal_bottom_sheet.dart';
import './widgets/empty_goals_widget.dart';
import './widgets/goal_card_widget.dart';

class SavingsGoals extends StatefulWidget {
  const SavingsGoals({super.key});

  @override
  State<SavingsGoals> createState() => _SavingsGoalsState();
}

class _SavingsGoalsState extends State<SavingsGoals> {
  late Future<List<dynamic>> _goalsFuture;

  @override
  void initState() {
    super.initState();
    _refreshGoals();
  }

  void _refreshGoals() {
    setState(() {
      _goalsFuture = GoalService.getGoals();
    });
  }

  void _showAddGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddGoalBottomSheet(onGoalAdded: (_) => _refreshGoals()),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void _showEditGoalSheet(Map<String, dynamic> goal) {
    final nameController = TextEditingController(text: goal['name'] ?? '');
    final targetAmountController = TextEditingController(
      text: (goal['targetAmount'] ?? '').toString(),
    );
    DateTime? deadline = goal['deadline'] != null
        ? DateTime.tryParse(goal['deadline'])
        : null;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> _pickDeadline() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: deadline ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null) {
                setModalState(() {
                  deadline = picked;
                });
              }
            }

            Future<void> _submit() async {
              if (nameController.text.trim().isEmpty ||
                  targetAmountController.text.trim().isEmpty ||
                  deadline == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fill all fields")),
                );
                return;
              }
              setModalState(() => isLoading = true);
              final updatedGoal = {
                "name": nameController.text.trim(),
                "targetAmount": double.parse(targetAmountController.text),
                "deadline": deadline!.toIso8601String(),
              };
              final success = await GoalService.updateGoal(
                goal['_id'],
                updatedGoal,
              );
              setModalState(() => isLoading = false);
              if (success) {
                Navigator.pop(context);
                _refreshGoals();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Goal updated!")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to update goal")),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 5.w,
                right: 5.w,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 3.h,
                top: 3.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit Goal",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Goal Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: targetAmountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Target Amount",
                        prefixText: "Rs ",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            deadline == null
                                ? "No deadline selected"
                                : "Deadline: ${deadline!.toLocal().toString().split(' ')[0]}",
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
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text("Update Goal"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Future<void> _deleteGoal(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Goal"),
        content: const Text("Are you sure you want to delete this goal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await GoalService.deleteGoal(id);
      if (success) {
        _refreshGoals();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Goal deleted!")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to delete goal")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Savings Goals')),
      body: FutureBuilder<List<dynamic>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyGoalsWidget();
          }
          final goals = snapshot.data!;
          return AnimatedList(
            key: ValueKey(goals.length),
            initialItemCount: goals.length,
            itemBuilder: (context, index, animation) {
              final goal = goals[index];
              return SizeTransition(
                sizeFactor: animation,
                child: GoalCardWidget(
                  goal: goal,
                  onEdit: () => _showEditGoalSheet(goal),
                  onDelete: () => _deleteGoal(goal['_id']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalSheet,
        icon: const Icon(Icons.add),
        label: const Text("Add Goal"),
        backgroundColor: Colors.orange,
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/savings-goals',
        onRouteChanged: (route) {
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
      ),
      backgroundColor: const Color(0xFFF7F7F7),
    );
  }
}
