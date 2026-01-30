import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/db_service.dart';

class ExpenseController {
  final DBService _dbService = DBService();
  final Uuid _uuid = Uuid();

  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    return await _dbService.getAllExpenses();
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    return await _dbService.getExpensesByDateRange(startDate, endDate);
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    return await _dbService.getExpensesByCategory(category);
  }

  // Get expense by ID
  Future<Expense?> getExpenseById(String id) async {
    final map = await _dbService.getById('expenses', id);
    if (map == null) return null;
    return Expense.fromMap(map);
  }

  // Create a new expense
  Future<Expense> createExpense({
    required String category,
    required double amount,
    String? description,
    DateTime? date,
  }) async {
    // Validate inputs
    if (category.isEmpty) {
      throw Exception('Category is required');
    }
    if (amount <= 0) {
      throw Exception('Amount must be a positive number');
    }

    final expense = Expense(
      id: _uuid.v4(),
      category: category,
      amount: amount,
      description: description,
      date: date ?? DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _dbService.insertExpense(expense);
    return expense;
  }

  // Update an existing expense
  Future<Expense> updateExpense(Expense expense) async {
    // Validate inputs
    if (expense.category.isEmpty) {
      throw Exception('Category is required');
    }
    if (expense.amount <= 0) {
      throw Exception('Amount must be a positive number');
    }

    await _dbService.updateExpense(expense);
    return expense;
  }

  // Delete an expense
  Future<void> deleteExpense(String id) async {
    await _dbService.deleteExpense(id);
  }

  // Get total expenses for a specific date range
  Future<double> getTotalExpensesForDateRange(DateTime startDate, DateTime endDate) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get total expenses for a specific category
Future<double> getTotalExpensesForCategory(String category) async {
  final List<Expense> expenses = await getExpensesByCategory(category);
  return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
}


  // Get expenses summary by category for a date range
  Future<Map<String, double>> getExpensesSummaryByCategory(DateTime startDate, DateTime endDate) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    final Map<String, double> summary = {};
    
    for (var expense in expenses) {
      if (summary.containsKey(expense.category)) {
        summary[expense.category] = summary[expense.category]! + expense.amount;
      } else {
        summary[expense.category] = expense.amount;
      }
    }
    
    return summary;
  }

  // Get daily expenses for a date range
  Future<Map<DateTime, double>> getDailyExpenses(DateTime startDate, DateTime endDate) async {
    final expenses = await getExpensesByDateRange(startDate, endDate);
    final Map<DateTime, double> dailyExpenses = {};
    
    for (var expense in expenses) {
      // Normalize to date only (no time)
      final dateOnly = DateTime(expense.date.year, expense.date.month, expense.date.day);
      
      if (dailyExpenses.containsKey(dateOnly)) {
        dailyExpenses[dateOnly] = dailyExpenses[dateOnly]! + expense.amount;
      } else {
        dailyExpenses[dateOnly] = expense.amount;
      }
    }
    
    return dailyExpenses;
  }
}