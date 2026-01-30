import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../utils/app_utils.dart';
import 'expense_form_screen.dart';
import 'expense_card.dart';
import 'expense_summary_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    // Load expenses when screen initializes
    Future.microtask(() => context.read<ExpenseProvider>().loadExpenses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => _navigateToSummary(context),
            tooltip: 'View Summary',
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadExpenses(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildFilters(context, provider),
              _buildTotalExpenses(context, provider),
              Expanded(
                child: _buildExpenseList(context, provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpense(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range, size: 16),
              const SizedBox(width: 8),
              Text(
                '${AppUtils.formatDate(provider.startDate)} - ${AppUtils.formatDate(provider.endDate)}',
                style: AppTextStyles.subtitle1,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (provider.allCategories.isNotEmpty) ...[  
            const Text('Filter by Category:', style: AppTextStyles.subtitle2),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: provider.selectedCategory == null,
                      onSelected: (_) => provider.setSelectedCategory(null),
                    ),
                  ),
                  ...provider.allCategories.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: provider.selectedCategory == category,
                          onSelected: (_) => provider.setSelectedCategory(category),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalExpenses(BuildContext context, ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Expenses:', style: AppTextStyles.subtitle1),
              Text(
                AppUtils.formatCurrency(provider.totalExpenses),
                style: AppTextStyles.headline3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, ExpenseProvider provider) {
    final filteredExpenses = provider.filteredExpenses;

    if (filteredExpenses.isEmpty) {
      return const Center(
        child: Text('No expenses for the selected date range and filters.'),
      );
    }

    // Group expenses by date
    final expensesByDate = <DateTime, List<Expense>>{};
    for (var expense in filteredExpenses) {
      final dateOnly = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (!expensesByDate.containsKey(dateOnly)) {
        expensesByDate[dateOnly] = [];
      }
      expensesByDate[dateOnly]!.add(expense);
    }

    // Sort dates in descending order (newest first)
    final sortedDates = expensesByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final expenses = expensesByDate[date]!;
        final dailyTotal = expenses.fold(
            0.0, (sum, expense) => sum + expense.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppUtils.formatDate(date),
                    style: AppTextStyles.headline3,
                  ),
                  Text(
                    AppUtils.formatCurrency(dailyTotal),
                    style: AppTextStyles.subtitle1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            ...expenses.map((expense) => ExpenseCard(
                  expense: expense,
                  onEdit: () => _navigateToEditExpense(context, expense),
                  onDelete: () => _confirmDeleteExpense(context, expense),
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final provider = context.read<ExpenseProvider>();
    final initialDateRange = DateTimeRange(
      start: provider.startDate,
      end: provider.endDate,
    );

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      provider.setDateRange(picked.start, picked.end);
    }
  }

  void _navigateToAddExpense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ExpenseFormScreen(),
      ),
    );
  }

  void _navigateToEditExpense(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(expense: expense),
      ),
    );
  }

  void _navigateToSummary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ExpenseSummaryScreen(),
      ),
    );
  }

  Future<void> _confirmDeleteExpense(BuildContext context, Expense expense) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      context,
      'Delete Expense',
      'Are you sure you want to delete this expense of ${AppUtils.formatCurrency(expense.amount)}?',
    );

    if (confirmed && context.mounted) {
      await context.read<ExpenseProvider>().deleteExpense(expense.id);
      if (context.mounted) {
        AppUtils.showSnackBar(context, 'Expense deleted successfully');
      }
    }
  }
}