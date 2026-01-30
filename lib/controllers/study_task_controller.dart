import 'package:uuid/uuid.dart';
import '../models/study_task.dart';
import '../services/db_service.dart';

class StudyTaskController {
  final DBService _dbService = DBService();
  final Uuid _uuid = Uuid();

  // Get all study tasks
  Future<List<StudyTask>> getAllStudyTasks() async {
    return await _dbService.getAllStudyTasks();
  }

  // Get study tasks for today
  Future<List<StudyTask>> getTodayStudyTasks() async {
    return await _dbService.getStudyTasksByDate(DateTime.now());
  }

  // Get study tasks by date
  Future<List<StudyTask>> getStudyTasksByDate(DateTime date) async {
    return await _dbService.getStudyTasksByDate(date);
  }

  // Get study tasks by subject
  Future<List<StudyTask>> getStudyTasksBySubject(String subject) async {
    return await _dbService.getStudyTasksBySubject(subject);
  }

  // Get study task by ID
  Future<StudyTask?> getStudyTaskById(String id) async {
    final map = await _dbService.getById('study_tasks', id);
    if (map == null) return null;
    return StudyTask.fromMap(map);
  }

  // Create a new study task
  Future<StudyTask> createStudyTask({
    required String subject,
    required String task,
    required DateTime date,
    required int durationMinutes,
  }) async {
    // Validate inputs
    if (subject.isEmpty) {
      throw Exception('Subject is required');
    }
    if (task.isEmpty) {
      throw Exception('Task is required');
    }
    if (durationMinutes <= 0) {
      throw Exception('Duration must be a positive number');
    }

    final studyTask = StudyTask(
      id: _uuid.v4(),
      subject: subject,
      task: task,
      date: date,
      durationMinutes: durationMinutes,
      isDone: false,
      createdAt: DateTime.now(),
    );

    await _dbService.insertStudyTask(studyTask);
    return studyTask;
  }

  // Update an existing study task
  Future<StudyTask> updateStudyTask(StudyTask studyTask) async {
    // Validate inputs
    if (studyTask.subject.isEmpty) {
      throw Exception('Subject is required');
    }
    if (studyTask.task.isEmpty) {
      throw Exception('Task is required');
    }
    if (studyTask.durationMinutes <= 0) {
      throw Exception('Duration must be a positive number');
    }

    await _dbService.updateStudyTask(studyTask);
    return studyTask;
  }

  // Toggle study task completion status
  Future<StudyTask> toggleStudyTaskCompletion(String id) async {
    final studyTask = await getStudyTaskById(id);
    if (studyTask == null) {
      throw Exception('Study task not found');
    }

    final updatedStudyTask = studyTask.copyWith(isDone: !studyTask.isDone);
    await _dbService.updateStudyTask(updatedStudyTask);
    return updatedStudyTask;
  }

  // Delete a study task
  Future<void> deleteStudyTask(String id) async {
    await _dbService.deleteStudyTask(id);
  }

  // Get total study time for a specific date
  Future<int> getTotalStudyTimeForDate(DateTime date) async {
    final tasks = await getStudyTasksByDate(date);
    return tasks.fold<int>(0, (sum, task) => task.isDone ? sum + task.durationMinutes : sum);
  }

  // Get total study time for a specific subject
  Future<int> getTotalStudyTimeForSubject(String subject) async {
    final tasks = await getStudyTasksBySubject(subject);
    return tasks.fold<int>(0, (sum, task) => task.isDone ? sum + task.durationMinutes : sum);
  }
}