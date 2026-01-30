import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // Date formatters
  static final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat timeFormatter = DateFormat('hh:mm a');
  static final DateFormat dateTimeFormatter = DateFormat('MMM dd, yyyy hh:mm a');
  static final DateFormat monthYearFormatter = DateFormat('MMMM yyyy');
  
  // Currency formatter
  static final NumberFormat currencyFormatter = NumberFormat.currency(symbol: '\$');
  
  // Format date
  static String formatDate(DateTime date) {
    return dateFormatter.format(date);
  }
  
  // Format time
  static String formatTime(DateTime time) {
    return timeFormatter.format(time);
  }
  
  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return dateTimeFormatter.format(dateTime);
  }
  
  // Format month and year
  static String formatMonthYear(DateTime date) {
    return monthYearFormatter.format(date);
  }
  
  // Format currency
  static String formatCurrency(double amount) {
    return currencyFormatter.format(amount);
  }
  
  // Format duration in minutes to hours and minutes
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hr';
      } else {
        return '$hours hr $remainingMinutes min';
      }
    }
  }
  
  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// App colors
class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryDark = Color(0xFF3700B3);
  static const Color accent = Color(0xFF03DAC6);
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
  static const Color text = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Task colors
  static const Color taskComplete = Color(0xFF4CAF50);
  static const Color taskIncomplete = Color(0xFFFF9800);
  
  // Study task colors
  static const Color studyTaskComplete = Color(0xFF4CAF50);
  static const Color studyTaskIncomplete = Color(0xFFFF9800);
  
  // Expense category colors
  static const List<Color> expenseCategoryColors = [
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFF9800), // Orange
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
  ];
}

// App text styles
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

// App constants
class AppConstants {
  // Default expense categories
  static const List<String> expenseCategories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Utilities',
    'Housing',
    'Health',
    'Education',
    'Other',
  ];
  
  // Default study subjects
  static const List<String> studySubjects = [
    'Mathematics',
    'Science',
    'History',
    'English',
    'Computer Science',
    'Physics',
    'Chemistry',
    'Biology',
    'Economics',
    'Other',
  ];
}