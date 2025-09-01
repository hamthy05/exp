import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/widgets/custom_bottom_bar.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/date_section_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/sort_dropdown_widget.dart';
import './widgets/transaction_card_widget.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  List<String> _selectedCategories = [];
  RangeValues _amountRange = const RangeValues(0, 100000);
  SortOption _selectedSort = SortOption.dateNewest;
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  // Mock transaction data
  final List<Map<String, dynamic>> _allTransactions = [
    {
      "id": 1,
      "type": "expense",
      "amount": 2500.00,
      "category": "Food & Dining",
      "categoryIcon": "restaurant",
      "description": "Lunch at Green Cabin Restaurant",
      "date": DateTime(2025, 8, 4),
      "time": "12:30 PM",
      "note": "Team lunch meeting",
    },
    {
      "id": 2,
      "type": "income",
      "amount": 85000.00,
      "category": "Salary",
      "categoryIcon": "work",
      "description": "Monthly Salary - August 2025",
      "date": DateTime(2025, 8, 1),
      "time": "09:00 AM",
      "note": "Regular monthly salary",
    },
    {
      "id": 3,
      "type": "expense",
      "amount": 1200.00,
      "category": "Transportation",
      "categoryIcon": "directions_car",
      "description": "Uber ride to office",
      "date": DateTime(2025, 8, 4),
      "time": "08:15 AM",
      "note": "Morning commute",
    },
    {
      "id": 4,
      "type": "expense",
      "amount": 15000.00,
      "category": "Shopping",
      "categoryIcon": "shopping_bag",
      "description": "Grocery shopping at Keells Super",
      "date": DateTime(2025, 8, 3),
      "time": "06:30 PM",
      "note": "Weekly groceries",
    },
    {
      "id": 5,
      "type": "expense",
      "amount": 8500.00,
      "category": "Bills & Utilities",
      "categoryIcon": "receipt",
      "description": "Electricity bill payment",
      "date": DateTime(2025, 8, 3),
      "time": "02:15 PM",
      "note": "Monthly electricity bill",
    },
    {
      "id": 6,
      "type": "income",
      "amount": 25000.00,
      "category": "Freelance",
      "categoryIcon": "laptop",
      "description": "Web development project",
      "date": DateTime(2025, 8, 2),
      "time": "11:45 AM",
      "note": "Client payment for website",
    },
    {
      "id": 7,
      "type": "expense",
      "amount": 3500.00,
      "category": "Healthcare",
      "categoryIcon": "local_hospital",
      "description": "Doctor consultation",
      "date": DateTime(2025, 8, 2),
      "time": "10:00 AM",
      "note": "Regular checkup",
    },
    {
      "id": 8,
      "type": "expense",
      "amount": 4200.00,
      "category": "Entertainment",
      "categoryIcon": "movie",
      "description": "Movie tickets at Majestic Cinema",
      "date": DateTime(2025, 8, 1),
      "time": "07:30 PM",
      "note": "Weekend movie with family",
    },
    {
      "id": 9,
      "type": "expense",
      "amount": 1800.00,
      "category": "Food & Dining",
      "categoryIcon": "restaurant",
      "description": "Coffee at Barista",
      "date": DateTime(2025, 8, 1),
      "time": "04:00 PM",
      "note": "Afternoon coffee break",
    },
    {
      "id": 10,
      "type": "income",
      "amount": 12000.00,
      "category": "Investment",
      "categoryIcon": "trending_up",
      "description": "Dividend from CSE stocks",
      "date": DateTime(2025, 7, 31),
      "time": "09:30 AM",
      "note": "Quarterly dividend payment",
    },
    {
      "id": 11,
      "type": "expense",
      "amount": 6500.00,
      "category": "Transportation",
      "categoryIcon": "directions_car",
      "description": "Fuel for car",
      "date": DateTime(2025, 7, 31),
      "time": "08:00 AM",
      "note": "Weekly fuel top-up",
    },
    {
      "id": 12,
      "type": "expense",
      "amount": 2200.00,
      "category": "Food & Dining",
      "categoryIcon": "restaurant",
      "description": "Dinner at Ministry of Crab",
      "date": DateTime(2025, 7, 30),
      "time": "08:00 PM",
      "note": "Anniversary dinner",
    },
    {
      "id": 13,
      "type": "expense",
      "amount": 950.00,
      "category": "Transportation",
      "categoryIcon": "directions_car",
      "description": "Bus fare to Kandy",
      "date": DateTime(2025, 7, 30),
      "time": "06:00 AM",
      "note": "Weekend trip",
    },
    {
      "id": 14,
      "type": "income",
      "amount": 18000.00,
      "category": "Business",
      "categoryIcon": "business",
      "description": "Online store sales",
      "date": DateTime(2025, 7, 29),
      "time": "03:20 PM",
      "note": "Weekly sales revenue",
    },
    {
      "id": 15,
      "type": "expense",
      "amount": 12500.00,
      "category": "Shopping",
      "categoryIcon": "shopping_bag",
      "description": "Clothing at Fashion Bug",
      "date": DateTime(2025, 7, 29),
      "time": "02:00 PM",
      "note": "New work clothes",
    },
  ];

  List<Map<String, dynamic>> _filteredTransactions = [];
  List<Map<String, dynamic>> _displayedTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = List.from(_allTransactions);
    _applyFiltersAndSort();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  void _loadMoreTransactions() {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final startIndex = (_currentPage - 1) * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage;

      if (startIndex < _filteredTransactions.length) {
        final newItems = _filteredTransactions
            .skip(startIndex)
            .take(_itemsPerPage)
            .toList();
        setState(() {
          _displayedTransactions.addAll(newItems);
          _currentPage++;
          _isLoading = false;
          _hasMoreData = endIndex < _filteredTransactions.length;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasMoreData = false;
        });
      }
    });
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(_allTransactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final description = (transaction['description'] as String)
            .toLowerCase();
        final category = (transaction['category'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return description.contains(query) || category.contains(query);
      }).toList();
    }

    // Apply date range filter
    if (_selectedDateRange != null) {
      filtered = filtered.where((transaction) {
        final date = transaction['date'] as DateTime;
        return date.isAfter(
              _selectedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return _selectedCategories.contains(transaction['category']);
      }).toList();
    }

    // Apply amount range filter
    filtered = filtered.where((transaction) {
      final amount = transaction['amount'] as double;
      return amount >= _amountRange.start && amount <= _amountRange.end;
    }).toList();

    // Apply sorting
    switch (_selectedSort) {
      case SortOption.dateNewest:
        filtered.sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
        );
        break;
      case SortOption.dateOldest:
        filtered.sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
        );
        break;
      case SortOption.amountHighest:
        filtered.sort(
          (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
        );
        break;
      case SortOption.amountLowest:
        filtered.sort(
          (a, b) => (a['amount'] as double).compareTo(b['amount'] as double),
        );
        break;
      case SortOption.categoryAZ:
        filtered.sort(
          (a, b) =>
              (a['category'] as String).compareTo(b['category'] as String),
        );
        break;
      case SortOption.categoryZA:
        filtered.sort(
          (a, b) =>
              (b['category'] as String).compareTo(a['category'] as String),
        );
        break;
    }

    setState(() {
      _filteredTransactions = filtered;
      _displayedTransactions = filtered.take(_itemsPerPage).toList();
      _currentPage = 2;
      _hasMoreData = filtered.length > _itemsPerPage;
    });
  }

  void _onRefresh() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    _applyFiltersAndSort();
  }

  void _showFilterBottomSheet() {
    final maxAmount = _allTransactions
        .map((t) => t['amount'] as double)
        .reduce((a, b) => a > b ? a : b);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedDateRange: _selectedDateRange,
        selectedCategories: _selectedCategories,
        amountRange: _amountRange,
        maxAmount: maxAmount,
        onDateRangeChanged: (range) {
          setState(() {
            _selectedDateRange = range;
          });
        },
        onCategoriesChanged: (categories) {
          setState(() {
            _selectedCategories = categories;
          });
        },
        onAmountRangeChanged: (range) {
          setState(() {
            _amountRange = range;
          });
        },
        onClearFilters: () {
          setState(() {
            _selectedDateRange = null;
            _selectedCategories.clear();
            _amountRange = RangeValues(0, maxAmount);
          });
        },
        onApplyFilters: () {
          _applyFiltersAndSort();
        },
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final transaction in _displayedTransactions) {
      final date = transaction['date'] as DateTime;
      final dateKey = _formatDateKey(date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  double _calculateDayTotal(List<Map<String, dynamic>> transactions) {
    double total = 0;
    for (final transaction in transactions) {
      final amount = transaction['amount'] as double;
      final isExpense =
          (transaction['type'] as String).toLowerCase() == 'expense';
      total += isExpense ? -amount : amount;
    }
    return total;
  }

  void _handleTransactionEdit(Map<String, dynamic> transaction) {
    Navigator.pushNamed(context, '/add-transaction', arguments: transaction);
  }

  void _handleTransactionDelete(Map<String, dynamic> transaction) {
    setState(() {
      _allTransactions.removeWhere((t) => t['id'] == transaction['id']);
      _applyFiltersAndSort();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction deleted successfully'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _allTransactions.add(transaction);
              _applyFiltersAndSort();
            });
          },
        ),
      ),
    );
  }

  void _handleTransactionDuplicate(Map<String, dynamic> transaction) {
    final duplicated = Map<String, dynamic>.from(transaction);
    duplicated['id'] = _allTransactions.length + 1;
    duplicated['date'] = DateTime.now();
    duplicated['time'] =
        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    setState(() {
      _allTransactions.insert(0, duplicated);
      _applyFiltersAndSort();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction duplicated successfully')),
    );
  }

  void _handleTransactionShare(Map<String, dynamic> transaction) {
    final amount = transaction['amount'] as double;
    final type = transaction['type'] as String;
    final category = transaction['category'] as String;
    final description = transaction['description'] as String;
    final date = _formatDateKey(transaction['date'] as DateTime);

    final shareText =
        '''
Transaction Details:
${type.toUpperCase()}: Rs. ${amount.toStringAsFixed(2)}
Category: $category
Description: $description
Date: $date
    ''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality: $shareText'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedTransactions = _groupTransactionsByDate();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'add',
              color: theme.colorScheme.onSurface,
              size: 6.w,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pushNamed(context, '/add-transaction');
            },
            tooltip: 'Add Transaction',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            initialQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
              _applyFiltersAndSort();
            },
            onFilterPressed: _showFilterBottomSheet,
          ),

          // Sort Dropdown
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(1.w, 1.h, 1.w, 1.h),
            child: Row(
              children: [
                Text(
                  SortDropdownWidget.getSortDisplayText(_selectedSort),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                SortDropdownWidget(
                  selectedSort: _selectedSort,
                  onSortChanged: (sort) {
                    setState(() {
                      _selectedSort = sort;
                    });
                    _applyFiltersAndSort();
                  },
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: _displayedTransactions.isEmpty
                ? EmptyStateWidget(
                    onAddTransaction: () {
                      Navigator.pushNamed(context, '/add-transaction');
                    },
                  )
                : RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _calculateListItemCount(groupedTransactions),
                      itemBuilder: (context, index) {
                        return _buildListItem(
                          context,
                          groupedTransactions,
                          index,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, '/add-transaction');
        },
        child: CustomIconWidget(
          iconName: 'add',
          color:
              theme.floatingActionButtonTheme.foregroundColor ?? Colors.white,
          size: 7.w,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/transaction-history',
        onRouteChanged: (route) {
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
      ),
    );
  }

  int _calculateListItemCount(
    Map<String, List<Map<String, dynamic>>> groupedTransactions,
  ) {
    int count = 0;
    for (final entry in groupedTransactions.entries) {
      count += 1 + entry.value.length; // 1 for header + transactions
    }
    if (_isLoading) count += 1; // Loading indicator
    return count;
  }

  Widget _buildListItem(
    BuildContext context,
    Map<String, List<Map<String, dynamic>>> groupedTransactions,
    int index,
  ) {
    int currentIndex = 0;

    for (final entry in groupedTransactions.entries) {
      final dateKey = entry.key;
      final transactions = entry.value;

      // Date header
      if (currentIndex == index) {
        return DateSectionHeaderWidget(
          date: dateKey,
          totalAmount: _calculateDayTotal(transactions),
          transactionCount: transactions.length,
        );
      }
      currentIndex++;

      // Transaction cards
      for (int i = 0; i < transactions.length; i++) {
        if (currentIndex == index) {
          return TransactionCardWidget(
            transaction: transactions[i],
            onEdit: () => _handleTransactionEdit(transactions[i]),
            onDelete: () => _handleTransactionDelete(transactions[i]),
            onDuplicate: () => _handleTransactionDuplicate(transactions[i]),
            onShare: () => _handleTransactionShare(transactions[i]),
          );
        }
        currentIndex++;
      }
    }

    // Loading indicator
    if (_isLoading && index == currentIndex) {
      return Container(
        padding: EdgeInsets.all(4.w),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox.shrink();
  }
}
