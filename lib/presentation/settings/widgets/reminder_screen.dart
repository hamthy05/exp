import 'package:flutter/material.dart';
import '../../../services/reminderService.dart';
import '../../../services/authService.dart';

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<dynamic> reminders = [];
  bool loading = true;
  String token = "";

  @override
  void initState() {
    super.initState();
    loadTokenAndReminders();
  }

  Future<void> loadTokenAndReminders() async {
    setState(() => loading = true);
    token = await AuthService.getToken() ?? "";
    await fetchReminders();
  }

  Future<void> fetchReminders() async {
    setState(() => loading = true);
    try {
      reminders = await ReminderService().getReminders(token);
    } catch (e) {
      // Handle error (show snackbar, etc.)
    }
    setState(() => loading = false);
  }

  void showReminderDialog([Map? reminder]) {
    final _msgCtrl = TextEditingController(text: reminder?['message'] ?? "");
    String type = reminder?['type'] ?? 'daily';
    DateTime? time = reminder?['time'] != null
        ? DateTime.tryParse(reminder!['time']) ?? DateTime.now()
        : DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(reminder == null ? "Add Reminder" : "Edit Reminder"),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: type,
                items: [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'goal', child: Text('Goal')),
                  DropdownMenuItem(value: 'bill', child: Text('Bill')),
                ],
                onChanged: (v) => setStateDialog(() => type = v!),
              ),
              TextField(
                controller: _msgCtrl,
                decoration: InputDecoration(labelText: "Message"),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    time != null
                        ? "${time?.hour.toString().padLeft(2, '0')}:${time?.minute.toString().padLeft(2, '0')}"
                        : "No time",
                  ),
                  Spacer(),
                  TextButton(
                    child: Text("Pick Time"),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(time!),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          time = DateTime(
                            time!.year,
                            time!.month,
                            time!.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(reminder == null ? "Add" : "Update"),
            onPressed: () async {
              final data = {
                "type": type,
                "message": _msgCtrl.text,
                "time": time?.toIso8601String(),
              };
              try {
                if (reminder == null) {
                  await ReminderService().createReminder(data, token);
                } else {
                  await ReminderService().updateReminder(
                    reminder['_id'],
                    data,
                    token,
                  );
                }
                Navigator.pop(context);
                fetchReminders();
              } catch (e) {
                // Handle error (show snackbar, etc.)
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reminders"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : reminders.isEmpty
          ? Center(child: Text("No reminders found"))
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (ctx, i) {
                final r = reminders[i];
                return Dismissible(
                  key: ValueKey(r['_id']),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (_) async {
                    try {
                      await ReminderService().deleteReminder(r['_id'], token);
                      fetchReminders();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Delete failed: $e')),
                      );
                    }
                  },
                  child: ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text(r['message'] ?? ''),
                    subtitle: Text(r['type'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => showReminderDialog(r),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Delete Reminder"),
                                content: Text(
                                  "Are you sure you want to delete this reminder?",
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("Cancel"),
                                    onPressed: () => Navigator.pop(ctx, false),
                                  ),
                                  TextButton(
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await ReminderService().deleteReminder(
                                  r['_id'],
                                  token,
                                );
                                fetchReminders();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Delete failed: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showReminderDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
