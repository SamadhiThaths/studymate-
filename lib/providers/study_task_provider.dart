import 'package:flutter/foundation.dart';
import '../models/study_task.dart';
import '../controllers/study_task_controller.dart';

class StudyTaskProvider extends ChangeNotifier {
  final StudyTaskController _studyTaskController = StudyTaskController();
  List<StudyTask> _studyTasks = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  String? _selectedSubject;

  // Getters
  List<StudyTask> get studyTasks => _studyTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  String? get selectedSubject => _selectedSubject;

  // Filtered study tasks based on selected date and/or subject
  List<StudyTask> get filteredStudyTasks {
    if (_selectedSubject != null) {
      return _studyTasks.where((task) {
        final isSameDate = task.date.year == _selectedDate.year &&
            task.date.month == _selectedDate.month &&
            task.date.day == _selectedDate.day;
        return isSameDate && task.subject == _selectedSubject;
      }).toList();
    } else {
      return _studyTasks.where((task) {
        return task.date.year == _selectedDate.year &&
            task.date.month == _selectedDate.month &&
            task.date.day == _selectedDate.day;
      }).toList();
    }
  }

  // Get all unique subjects
  List<String> get allSubjects {
    final subjects = _studyTasks.map((task) => task.subject).toSet().toList();
    subjects.sort();
    return subjects;
  }

  // Get total study time for selected date
  int get totalStudyTimeForSelectedDate {
    return filteredStudyTasks.fold(
        0, (sum, task) => task.isDone ? sum + task.durationMinutes : sum);
  }

  // Get total planned study time for selected date
  int get totalPlannedStudyTimeForSelectedDate {
    return filteredStudyTasks.fold(0, (sum, task) => sum + task.durationMinutes);
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Set selected subject
  void setSelectedSubject(String? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  // Load all study tasks from database
  Future<void> loadStudyTasks() async {
    _setLoading(true);
    try {
      _studyTasks = await _studyTaskController.getAllStudyTasks();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Add a new study task
  Future<void> addStudyTask({
    required String subject,
    required String task,
    required DateTime date,
    required int durationMinutes,
  }) async {
    _setLoading(true);
    try {
      final studyTask = await _studyTaskController.createStudyTask(
        subject: subject,
        task: task,
        date: date,
        durationMinutes: durationMinutes,
      );
      _studyTasks.add(studyTask);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing study task
  Future<void> updateStudyTask(StudyTask studyTask) async {
    _setLoading(true);
    try {
      final updatedStudyTask = await _studyTaskController.updateStudyTask(studyTask);
      final index = _studyTasks.indexWhere((t) => t.id == studyTask.id);
      if (index != -1) {
        _studyTasks[index] = updatedStudyTask;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Toggle study task completion status
  Future<void> toggleStudyTaskCompletion(String id) async {
    _setLoading(true);
    try {
      final updatedStudyTask = await _studyTaskController.toggleStudyTaskCompletion(id);
      final index = _studyTasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _studyTasks[index] = updatedStudyTask;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Delete a study task
  Future<void> deleteStudyTask(String id) async {
    _setLoading(true);
    try {
      await _studyTaskController.deleteStudyTask(id);
      _studyTasks.removeWhere((task) => task.id == id);
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