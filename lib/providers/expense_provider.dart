import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../controllers/expense_controller.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseController _expenseController = ExpenseController();
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedCategory;

  // Getters
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String? get selectedCategory => _selectedCategory;

  // Filtered expenses based on selected date range and/or category
  List<Expense> get filteredExpenses {
    if (_selectedCategory != null) {
      return _expenses.where((expense) {
        final isInDateRange = expense.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(_endDate.add(const Duration(days: 1)));
        return isInDateRange && expense.category == _selectedCategory;
      }).toList();
    } else {
      return _expenses.where((expense) {
        return expense.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();
    }
  }

  // Get all unique categories
  List<String> get allCategories {
    final categories = _expenses.map((expense) => expense.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Get total expenses for selected date range and category
  double get totalExpenses {
    return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses summary by category
  Map<String, double> get expensesByCategory {
    final Map<String, double> summary = {};
    for (var expense in filteredExpenses) {
      if (summary.containsKey(expense.category)) {
        summary[expense.category] = summary[expense.category]! + expense.amount;
      } else {
        summary[expense.category] = expense.amount;
      }
    }
    return summary;
  }

  // Get daily expenses
  Map<DateTime, double> get dailyExpenses {
    final Map<DateTime, double> daily = {};
    for (var expense in filteredExpenses) {
      // Normalize to date only (no time)
      final dateOnly = DateTime(expense.date.year, expense.date.month, expense.date.day);
      
      if (daily.containsKey(dateOnly)) {
        daily[dateOnly] = daily[dateOnly]! + expense.amount;
      } else {
        daily[dateOnly] = expense.amount;
      }
    }
    return daily;
  }

  // Set date range
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Load all expenses from database
  Future<void> loadExpenses() async {
    _setLoading(true);
    try {
      _expenses = await _expenseController.getAllExpenses();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Add a new expense
  Future<void> addExpense({
    required String category,
    required double amount,
    String? description,
    DateTime? date,
  }) async {
    _setLoading(true);
    try {
      final expense = await _expenseController.createExpense(
        category: category,
        amount: amount,
        description: description,
        date: date,
      );
      _expenses.add(expense);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    _setLoading(true);
    try {
      final updatedExpense = await _expenseController.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Delete an expense
  Future<void> deleteExpense(String id) async {
    _setLoading(true);
    try {
      await _expenseController.deleteExpense(id);
      _expenses.removeWhere((expense) => expense.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}