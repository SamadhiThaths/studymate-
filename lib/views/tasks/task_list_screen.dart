import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../utils/app_utils.dart';
import 'task_form_screen.dart';
import 'task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when screen initializes
    Future.microtask(() => context.read<TaskProvider>().loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${taskProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => taskProvider.loadTasks(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (taskProvider.tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet. Add a task to get started!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              return TaskCard(
                task: task,
                onToggleCompletion: () => taskProvider.toggleTaskCompletion(task.id),
                onEdit: () => _navigateToEditTask(context, task),
                onDelete: () => _confirmDeleteTask(context, task),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TaskFormScreen(),
      ),
    );
  }

  void _navigateToEditTask(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );
  }

  Future<void> _confirmDeleteTask(BuildContext context, Task task) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      context,
      'Delete Task',
      'Are you sure you want to delete "${task.title}"?',
    );

    if (confirmed && context.mounted) {
      await context.read<TaskProvider>().deleteTask(task.id);
      if (context.mounted) {
        AppUtils.showSnackBar(context, 'Task deleted successfully');
      }
    }
  }
}