import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/db_service.dart';

class TaskController {
  final DBService _dbService = DBService();
  final Uuid _uuid = Uuid();

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    return await _dbService.getAllTasks();
  }

  // Get task by ID
  Future<Task?> getTaskById(String id) async {
    final map = await _dbService.getById('tasks', id);
    if (map == null) return null;
    return Task.fromMap(map);
  }

  // Create a new task
  Future<Task> createTask(String title, {String? description}) async {
    // Validate title
    if (title.isEmpty) {
      throw Exception('Task title is required');
    }
    if (title.length > 200) {
      throw Exception('Task title must be less than 200 characters');
    }

    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await _dbService.insertTask(task);
    return task;
  }

  // Update an existing task
  Future<Task> updateTask(Task task) async {
    // Validate title
    if (task.title.isEmpty) {
      throw Exception('Task title is required');
    }
    if (task.title.length > 200) {
      throw Exception('Task title must be less than 200 characters');
    }

    await _dbService.updateTask(task);
    return task;
  }

  // Toggle task completion status
  Future<Task> toggleTaskCompletion(String id) async {
    final task = await getTaskById(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _dbService.updateTask(updatedTask);
    return updatedTask;
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    await _dbService.deleteTask(id);
  }
}