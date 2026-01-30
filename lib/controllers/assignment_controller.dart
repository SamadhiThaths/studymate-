import 'package:uuid/uuid.dart';
import '../models/assignment.dart';
import '../services/db_service.dart';

class AssignmentController {
  final DBService _dbService = DBService();
  final Uuid _uuid = Uuid();

  // Get all assignments
  Future<List<Assignment>> getAllAssignments() async {
    return await _dbService.getAllAssignments();
  }

  // Get assignments by status
  Future<List<Assignment>> getAssignmentsByStatus(String status) async {
    return await _dbService.getAssignmentsByStatus(status);
  }

  // Get assignments by module
  Future<List<Assignment>> getAssignmentsByModule(String moduleCode) async {
    return await _dbService.getAssignmentsByModule(moduleCode);
  }

  // Get assignments by due date range
  Future<List<Assignment>> getAssignmentsByDueDate(DateTime startDate, DateTime endDate) async {
    return await _dbService.getAssignmentsByDueDate(startDate, endDate);
  }

  // Get assignment by ID
  Future<Assignment?> getAssignmentById(String id) async {
    final map = await _dbService.getById('assignments', id);
    if (map == null) return null;
    return Assignment.fromMap(map);
  }

  // Create a new assignment
  Future<Assignment> createAssignment({
    required String name,
    required String moduleCode,
    required DateTime dueDate,
    required String status,
    String? description,
  }) async {
    // Validate inputs
    if (name.isEmpty) {
      throw Exception('Assignment name is required');
    }
    if (moduleCode.isEmpty) {
      throw Exception('Module code is required');
    }
    if (!_isValidStatus(status)) {
      throw Exception('Invalid status. Must be one of: Not Started, In Progress, Completed, Overdue');
    }

    final assignment = Assignment(
      id: _uuid.v4(),
      name: name,
      moduleCode: moduleCode,
      dueDate: dueDate,
      status: status,
      description: description,
      createdAt: DateTime.now(),
    );

    await _dbService.insertAssignment(assignment);
    return assignment;
  }

  // Update an existing assignment
  Future<Assignment> updateAssignment(Assignment assignment) async {
    // Validate inputs
    if (assignment.name.isEmpty) {
      throw Exception('Assignment name is required');
    }
    if (assignment.moduleCode.isEmpty) {
      throw Exception('Module code is required');
    }
    if (!_isValidStatus(assignment.status)) {
      throw Exception('Invalid status. Must be one of: Not Started, In Progress, Completed, Overdue');
    }

    await _dbService.updateAssignment(assignment);
    return assignment;
  }

  // Update assignment status
  Future<Assignment> updateAssignmentStatus(String id, String status) async {
    if (!_isValidStatus(status)) {
      throw Exception('Invalid status. Must be one of: Not Started, In Progress, Completed, Overdue');
    }

    final assignment = await getAssignmentById(id);
    if (assignment == null) {
      throw Exception('Assignment not found');
    }

    final updatedAssignment = assignment.copyWith(status: status);
    await _dbService.updateAssignment(updatedAssignment);
    return updatedAssignment;
  }

  // Delete an assignment
  Future<void> deleteAssignment(String id) async {
    await _dbService.deleteAssignment(id);
  }

  // Get all unique module codes
  Future<List<String>> getAllModuleCodes() async {
    final assignments = await getAllAssignments();
    final Set<String> moduleCodes = {};
    
    for (var assignment in assignments) {
      moduleCodes.add(assignment.moduleCode);
    }
    
    return moduleCodes.toList();
  }

  // Get count of assignments by status
  Future<Map<String, int>> getAssignmentCountByStatus() async {
    final assignments = await getAllAssignments();
    final Map<String, int> counts = {
      'Not Started': 0,
      'In Progress': 0,
      'Completed': 0,
      'Overdue': 0,
    };
    
    for (var assignment in assignments) {
      if (counts.containsKey(assignment.status)) {
        counts[assignment.status] = counts[assignment.status]! + 1;
      }
    }
    
    return counts;
  }

  // Check for overdue assignments and update their status
  Future<void> checkAndUpdateOverdueAssignments() async {
    final now = DateTime.now();
    final assignments = await getAllAssignments();
    
    for (var assignment in assignments) {
      if (assignment.status != 'Completed' && 
          assignment.dueDate.isBefore(now)) {
        await updateAssignmentStatus(assignment.id, 'Overdue');
      }
    }
  }

  // Helper method to validate status
  bool _isValidStatus(String status) {
    return ['Not Started', 'In Progress', 'Completed', 'Overdue'].contains(status);
  }
}