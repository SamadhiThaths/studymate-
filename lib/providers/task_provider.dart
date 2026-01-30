import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';

class TaskProvider extends ChangeNotifier {
  final TaskController _taskController = TaskController();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all tasks from database
  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _tasks = await _taskController.getAllTasks();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Add a new task
  Future<void> addTask(String title, {String? description}) async {
    _setLoading(true);
    try {
      final task = await _taskController.createTask(title, description: description);
      _tasks.add(task);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    _setLoading(true);
    try {
      final updatedTask = await _taskController.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String id) async {
    _setLoading(true);
    try {
      final updatedTask = await _taskController.toggleTaskCompletion(id);
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    _setLoading(true);
    try {
      await _taskController.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
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