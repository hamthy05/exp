import 'package:flutter/material.dart';
import 'package:flutter_app/services/categoryService.dart';
import 'package:flutter_app/services/authService.dart';
import 'package:flutter_app/services/transactionService.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransaction> {
  final _formKey = GlobalKey<FormState>();

  String? _type; // expense or income
  String? _category;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  List<dynamic> _categories = [];
  bool _isLoadingCategories = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['type'] != null && _type == null) {
      setState(() {
        _type = args['type'];
      });
      _fetchCategories();
    }
  }

  Future<void> _fetchCategories() async {
    if (_type == null) return;
    setState(() {
      _isLoadingCategories = true;
      _categories = [];
      _category = null;
    });
    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception("User not logged in");
      }
      final cats = await CategoryService.getCategories(
        token,
        isExpense: _type == "expense",
      );
      setState(() {
        _categories = cats.where((c) => c['type'] == _type).toList();
        _category = null;
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

      // Find selected category object to get its _id
      final selectedCategory = _categories.firstWhere(
        (c) => c['name'] == _category,
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

      bool success = await TransactionService.createTransaction(
        token,
        transaction,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction Added Successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add transaction")),
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

  // Helper: Convert backend color string (like "#FF9800") to Color
  Color? _parseColor(dynamic colorString) {
    if (colorString == null) return Colors.orange;
    String hex = colorString.toString().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // add alpha if missing
    return Color(int.parse('0x$hex'));
  }

  // Helper: Map backend icon name to Flutter icon
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction"), centerTitle: true),
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
                  prefixText: "Rs ",
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty && !value.contains('.')) {
                    setState(() {
                      _amountController.text = "$value.00";
                      _amountController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _amountController.text.length),
                      );
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter amount";
                  }
                  if (double.tryParse(value) == null) {
                    return "Enter valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type Dropdown
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: "Transaction Type",
                  border: OutlineInputBorder(),
                ),
                items: ["expense", "income"]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value;
                  });
                  _fetchCategories();
                },
                validator: (value) => value == null ? "Select type" : null,
              ),
              const SizedBox(height: 16),

              // Category Dropdown or Loader
              if (_type == null)
                const SizedBox() // Hide if type not selected
              else if (_isLoadingCategories)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map<DropdownMenuItem<String>>(
                        (c) => DropdownMenuItem<String>(
                          value: c['name'] as String,
                          child: Row(
                            children: [
                              if (c['icon'] != null &&
                                  c['icon'].toString().isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    color: _parseColor(c['color']),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    _getIconData(c['icon']),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              Text(c['name']),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                    });
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
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Pick Date"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Is Recurring
              SwitchListTile(
                title: const Text("Is Recurring?"),
                value: _isRecurring,
                onChanged: (val) {
                  setState(() {
                    _isRecurring = val;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: const Text("Save Transaction"),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
