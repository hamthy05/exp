import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../services/categoryService.dart';

class CategoryListScreen extends StatefulWidget {
  final String token;
  const CategoryListScreen({super.key, required this.token});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late Future<List<dynamic>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = CategoryService.getCategories(widget.token, isExpense: true);
  }

  void _refresh() {
    setState(() {
      _categories = CategoryService.getCategories(
        widget.token,
        isExpense: true,
      );
    });
  }

  Future<void> _showCategoryDialog({Map<String, dynamic>? category}) async {
    final nameController = TextEditingController(text: category?['name'] ?? '');
    String type = category?['type'] ?? 'expense';
    Color selectedColor = category != null && category['color'] != null
        ? Color(int.tryParse(category['color'] ?? '') ?? Colors.blue.value)
        : Colors.blue;
    String icon = category?['icon'] ?? 'category';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                ],
                onChanged: (val) {
                  if (val != null) type = val;
                },
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Color:'),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      Color picked = selectedColor;
                      await showDialog(
                        context: context,
                        builder: (ctx2) => AlertDialog(
                          title: const Text('Pick a color'),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: selectedColor,
                              onColorChanged: (color) {
                                picked = color;
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx2).pop();
                              },
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      );
                      setState(() {
                        selectedColor = picked;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Icon:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: icon,
                    items: [
                      DropdownMenuItem(
                        value: 'category',
                        child: Icon(Icons.category),
                      ),
                      DropdownMenuItem(
                        value: 'restaurant',
                        child: Icon(Icons.restaurant),
                      ),
                      DropdownMenuItem(
                        value: 'directions_car',
                        child: Icon(Icons.directions_car),
                      ),
                      DropdownMenuItem(
                        value: 'receipt',
                        child: Icon(Icons.receipt),
                      ),
                      DropdownMenuItem(
                        value: 'movie',
                        child: Icon(Icons.movie),
                      ),
                      DropdownMenuItem(
                        value: 'shopping_bag',
                        child: Icon(Icons.shopping_bag),
                      ),
                      DropdownMenuItem(
                        value: 'local_hospital',
                        child: Icon(Icons.local_hospital),
                      ),
                      DropdownMenuItem(
                        value: 'school',
                        child: Icon(Icons.school),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          icon = val;
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
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final data = {
                'name': nameController.text.trim(),
                'type': type,
                'color': selectedColor.value.toString(),
                'icon': icon,
              };
              try {
                if (category == null) {
                  await CategoryService.addCategory(widget.token, data);
                } else {
                  await CategoryService.updateCategory(
                    widget.token,
                    category['_id'],
                    data,
                  );
                }
                Navigator.pop(ctx, true);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: FutureBuilder<List<dynamic>>(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final categories = snapshot.data!;
          if (categories.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ListTile(
                leading: Icon(
                  _getIconData(cat['icon']),
                  color: cat['color'] != null
                      ? Color(
                          int.tryParse(cat['color'] ?? '') ?? Colors.blue.value,
                        )
                      : Colors.blue,
                ),
                title: Text(cat['name']),
                subtitle: Text(cat['type']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showCategoryDialog(category: cat);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete?'),
                            content: const Text('Are you sure?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await CategoryService.deleteCategory(
                            widget.token,
                            cat['_id'],
                          );
                          _refresh();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCategoryDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'receipt':
        return Icons.receipt;
      case 'movie':
        return Icons.movie;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}
