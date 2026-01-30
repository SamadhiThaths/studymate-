import 'package:flutter/material.dart';
import '../utils/app_utils.dart';
import 'tasks/task_list_screen.dart';
import 'study_tasks/study_task_list_screen.dart';
import 'expenses/expense_list_screen.dart';
import 'expenses/expense_summary_screen.dart';
import 'assignments/assignment_list_screen.dart';
import 'assignments/assignment_summary_screen.dart';
import 'notifications/notification_list_screen.dart';
import 'notifications/notification_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyMate'),
        centerTitle: true,
        actions: [
          NotificationBadge(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.notifications,color: Colors.white,),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationListScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
       
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome to StudyMate',
              style: AppTextStyles.headline1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your personal productivity assistant',
              style: AppTextStyles.subtitle1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildModuleCard(
              context,
              title: 'To-Do List',
              description: 'Manage your daily tasks',
              icon: Icons.check_circle_outline,
              color: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaskListScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              title: 'Study Tasks',
              description: 'Track your academic goals',
              icon: Icons.school,
              color: AppColors.accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StudyTaskListScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              title: 'Expenses',
              description: 'Manage your spending',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExpenseListScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              title: 'Expense Summary',
              description: 'View spending analytics',
              icon: Icons.pie_chart,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExpenseSummaryScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              title: 'Assignments',
              description: 'Track your academic assignments',
              icon: Icons.assignment,
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssignmentListScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              title: 'Assignment Summary',
              description: 'View assignment analytics',
              icon: Icons.analytics,
              color: Colors.indigo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssignmentSummaryScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.headline3),
                    const SizedBox(height: 4),
                    Text(description, style: AppTextStyles.body2),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}