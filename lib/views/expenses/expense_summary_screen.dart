import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';
import '../../utils/app_utils.dart';

class ExpenseSummaryScreen extends StatefulWidget {
  const ExpenseSummaryScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseSummaryScreen> createState() => _ExpenseSummaryScreenState();
}

class _ExpenseSummaryScreenState extends State<ExpenseSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Select Date Range',
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

          if (provider.filteredExpenses.isEmpty) {
            return const Center(
              child: Text('No expenses for the selected date range.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRangeHeader(provider),
                const SizedBox(height: 16),
                _buildTotalExpensesCard(provider),
                const SizedBox(height: 24),
                const Text('Expenses by Category', style: AppTextStyles.headline2),
                const SizedBox(height: 16),
                _buildPieChart(provider),
                const SizedBox(height: 16),
                _buildCategoryList(provider),
                const SizedBox(height: 24),
                const Text('Daily Expenses', style: AppTextStyles.headline2),
                const SizedBox(height: 16),
                _buildBarChart(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangeHeader(ExpenseProvider provider) {
    return Row(
      children: [
        const Icon(Icons.date_range, size: 16),
        const SizedBox(width: 8),
        Text(
          '${AppUtils.formatDate(provider.startDate)} - ${AppUtils.formatDate(provider.endDate)}',
          style: AppTextStyles.subtitle1,
        ),
      ],
    );
  }

  Widget _buildTotalExpensesCard(ExpenseProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Total Expenses', style: AppTextStyles.headline3),
            const SizedBox(height: 8),
            Text(
              AppUtils.formatCurrency(provider.totalExpenses),
              style: AppTextStyles.headline1.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(ExpenseProvider provider) {
    final expensesByCategory = provider.expensesByCategory;
    final categories = expensesByCategory.keys.toList();
    final totalExpenses = provider.totalExpenses;

    if (categories.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: _getPieSections(expensesByCategory, totalExpenses),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieSections(
      Map<String, double> expensesByCategory, double totalExpenses) {
    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;

    expensesByCategory.forEach((category, amount) {
      final percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0;
      final color = colorIndex < AppColors.expenseCategoryColors.length
          ? AppColors.expenseCategoryColors[colorIndex]
          : AppColors.expenseCategoryColors[colorIndex % AppColors.expenseCategoryColors.length];

      sections.add(
        PieChartSectionData(
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          color: color,
          radius: 80,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );

      colorIndex++;
    });

    return sections;
  }

  Widget _buildCategoryList(ExpenseProvider provider) {
    final expensesByCategory = provider.expensesByCategory;
    final categories = expensesByCategory.keys.toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (int i = 0; i < categories.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: i < AppColors.expenseCategoryColors.length
                          ? AppColors.expenseCategoryColors[i]
                          : AppColors.expenseCategoryColors[i % AppColors.expenseCategoryColors.length],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(categories[i], style: AppTextStyles.body1),
                    ),
                    Text(
                      AppUtils.formatCurrency(expensesByCategory[categories[i]]!),
                      style: AppTextStyles.subtitle1.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(ExpenseProvider provider) {
    final dailyExpenses = provider.dailyExpenses;
    final days = dailyExpenses.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    if (days.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: dailyExpenses.values.reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
             
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = days[groupIndex];
                final amount = dailyExpenses[day]!;
                return BarTooltipItem(
                  AppUtils.formatCurrency(amount),
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= days.length) {
                    return const SizedBox();
                  }
                  final day = days[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${day.day}/${day.month}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
                reservedSize: 40,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            days.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: dailyExpenses[days[index]]!,
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
}