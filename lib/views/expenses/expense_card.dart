import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../utils/app_utils.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseCard({
    Key? key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCategoryIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.category,
                        style: AppTextStyles.subtitle1,
                      ),
                      if (expense.description != null && expense.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            expense.description!,
                            style: AppTextStyles.body2,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  AppUtils.formatCurrency(expense.amount),
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppUtils.formatTime(expense.date),
                    style: AppTextStyles.body2,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: onEdit,
                        tooltip: 'Edit Expense',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: onDelete,
                        tooltip: 'Delete Expense',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    // Get a color based on the category name
    final categoryIndex = AppConstants.expenseCategories.indexOf(expense.category);
    final color = categoryIndex >= 0 && categoryIndex < AppColors.expenseCategoryColors.length
        ? AppColors.expenseCategoryColors[categoryIndex]
        : AppColors.expenseCategoryColors.last;

    // Get an icon based on the category
    IconData icon;
    switch (expense.category) {
      case 'Food':
        icon = Icons.restaurant;
        break;
      case 'Transportation':
        icon = Icons.directions_car;
        break;
      case 'Entertainment':
        icon = Icons.movie;
        break;
      case 'Shopping':
        icon = Icons.shopping_bag;
        break;
      case 'Utilities':
        icon = Icons.power;
        break;
      case 'Housing':
        icon = Icons.home;
        break;
      case 'Health':
        icon = Icons.medical_services;
        break;
      case 'Education':
        icon = Icons.school;
        break;
      default:
        icon = Icons.attach_money;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}