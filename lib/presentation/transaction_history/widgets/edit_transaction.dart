import 'package:flutter/material.dart';
import 'package:flutter_app/services/categoryService.dart';
import 'package:flutter_app/services/authService.dart';
import 'package:flutter_app/services/transactionService.dart';

class EditTransaction extends StatefulWidget {
  final Map<String, dynamic> transaction;
  const EditTransaction({super.key, required this.transaction});

  @override
  State<EditTransaction> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransaction> {
  final _formKey = GlobalKey<FormState>();

  late String _type;
  String? _category;
  late DateTime _selectedDate;
  bool _isRecurring = false;
  List<dynamic> _categories = [];
  bool _isLoadingCategories = false;

  late TextEditingController _amountController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _type = tx['type'];
    _category = tx['category']?['_id'];
    _selectedDate = tx['date'] is DateTime
        ? tx['date']
        : DateTime.parse(tx['date']);
    _isRecurring = tx['isRecurring'] ?? false;
    _amountController = TextEditingController(text: tx['amount'].toString());
    _descController = TextEditingController(text: tx['description'] ?? '');
    _fetchCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categories = [];
    });
    try {
      String? token = await AuthService.getToken();
      if (token == null) throw Exception("User not logged in");
      final cats = await CategoryService.getCategories(
        token,
        isExpense: _type == "expense",
      );
      setState(() {
        _categories = cats.where((c) => c['type'] == _type).toList();
        // If current category not in list, set to null
        if (!_categories.any((c) => c['_id'] == _category)) {
          _category = null;
        }
      });
    } catch (e) {
      setState(() => _categories = []);
    }
    setState(() => _isLoadingCategories = false);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }
      final selectedCategory = _categories.firstWhere(
        (c) => c['_id'] == _category,
        orElse: () => null,
      );
      if (selectedCategory == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid category")));
        return;
      }
      final transaction = {
        "amount": double.parse(_amountController.text),
        "type": _type,
        "category": selectedCategory['_id'],
        "description": _descController.text,
        "date": _selectedDate.toIso8601String(),
        "isRecurring": _isRecurring,
      };
      bool success = await TransactionService.updateTransaction(
        token,
        widget.transaction['_id'],
        transaction,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction Updated Successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update transaction")),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Color? _parseColor(dynamic colorString) {
    if (colorString == null) return Colors.orange;
    String hex = colorString.toString().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse('0x$hex'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Transaction"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter amount";
                  if (double.tryParse(value) == null) return "Invalid amount";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type Dropdown
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: "Type",
                  border: OutlineInputBorder(),
                ),
                items: ["expense", "income"]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.capitalize()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null && value != _type) {
                    setState(() {
                      _type = value;
                      _category = null;
                    });
                    _fetchCategories();
                  }
                },
                validator: (value) => value == null ? "Select type" : null,
              ),
              const SizedBox(height: 16),

              // Category Dropdown or Loader
              if (_isLoadingCategories)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem<String>(
                          value: c['_id'].toString(), // Ensure String type
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _parseColor(c['color']),
                                radius: 10,
                                child: Icon(
                                  _getIconData(c['icon']),
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(c['name']),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _category = value);
                  },
                  validator: (value) =>
                      value == null ? "Select category" : null,
                ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              Row(
                children: [
                  Text(
                    "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text("Pick Date"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Is Recurring
              SwitchListTile(
                title: const Text("Is Recurring?"),
                value: _isRecurring,
                onChanged: (val) {
                  setState(() => _isRecurring = val);
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.save),
                label: const Text("Update Transaction"),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringCap on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
