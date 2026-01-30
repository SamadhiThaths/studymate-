import 'package:flutter/foundation.dart';
import '../models/assignment.dart';
import '../controllers/assignment_controller.dart';
import '../providers/notification_provider.dart';

class AssignmentProvider with ChangeNotifier {
  final AssignmentController _controller = AssignmentController();
  
  List<Assignment> _assignments = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedModule;
  String? _selectedStatus;
  
  // Getters
  List<Assignment> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get selectedStartDate => _selectedStartDate;
  DateTime? get selectedEndDate => _selectedEndDate;
  String? get selectedModule => _selectedModule;
  String? get selectedStatus => _selectedStatus;
  
  // Get filtered assignments based on selected filters
  List<Assignment> get filteredAssignments {
    List<Assignment> filtered = List.from(_assignments);
    
    // Filter by module
    if (_selectedModule != null && _selectedModule!.isNotEmpty) {
      filtered = filtered.where((a) => a.moduleCode == _selectedModule).toList();
    }
    
    // Filter by status
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((a) => a.status == _selectedStatus).toList();
    }
    
    // Filter by date range
    if (_selectedStartDate != null && _selectedEndDate != null) {
      filtered = filtered.where((a) => 
        a.dueDate.isAfter(_selectedStartDate!) && 
        a.dueDate.isBefore(_selectedEndDate!.add(const Duration(days: 1))))
        .toList();
    }
    
    // Sort by due date (closest first)
    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    
    return filtered;
  }
  
  // Get all unique module codes
  List<String> get uniqueModules {
    final Set<String> modules = {};
    for (var assignment in _assignments) {
      modules.add(assignment.moduleCode);
    }
    return modules.toList()..sort();
  }
  
  // Get all statuses
  List<String> get allStatuses => ['Not Started', 'In Progress', 'Completed', 'Overdue'];
  
  // Get count of assignments by status
  Map<String, int> get assignmentCountByStatus {
    final Map<String, int> counts = {
      'Not Started': 0,
      'In Progress': 0,
      'Completed': 0,
      'Overdue': 0,
    };
    
    for (var assignment in _assignments) {
      if (counts.containsKey(assignment.status)) {
        counts[assignment.status] = counts[assignment.status]! + 1;
      }
    }
    
    return counts;
  }
  
  // Get upcoming assignments (due in the next 7 days)
  List<Assignment> get upcomingAssignments {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    return _assignments.where((a) => 
      a.status != 'Completed' && 
      a.dueDate.isAfter(now) && 
      a.dueDate.isBefore(nextWeek))
      .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
  
  // Load all assignments
  Future<void> loadAssignments() async {
    _setLoading(true);
    try {
      // Check for overdue assignments first
      await _controller.checkAndUpdateOverdueAssignments();
      
      // Then load all assignments
      _assignments = await _controller.getAllAssignments();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  // Add a new assignment
  Future<void> addAssignment({
    required String name,
    required String moduleCode,
    required DateTime dueDate,
    required String status,
    String? description,
  }) async {
    _setLoading(true);
    try {
      final assignment = await _controller.createAssignment(
        name: name,
        moduleCode: moduleCode,
        dueDate: dueDate,
        status: status,
        description: description,
      );
      
      _assignments.add(assignment);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update an existing assignment
  Future<void> updateAssignment(Assignment assignment) async {
    _setLoading(true);
    try {
      final updatedAssignment = await _controller.updateAssignment(assignment);
      
      final index = _assignments.indexWhere((a) => a.id == assignment.id);
      if (index != -1) {
        _assignments[index] = updatedAssignment;
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update assignment status
  Future<void> updateAssignmentStatus(String id, String status, {NotificationProvider? notificationProvider}) async {
    _setLoading(true);
    try {
      final updatedAssignment = await _controller.updateAssignmentStatus(id, status);
      
      final index = _assignments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _assignments[index] = updatedAssignment;
        
        // Create notification if assignment is marked as completed and notification provider is available
        if (status == 'Completed' && notificationProvider != null) {
          await notificationProvider.addAssignmentCompletionNotification(
            assignmentId: id,
            assignmentName: updatedAssignment.name,
          );
        }
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete an assignment
  Future<void> deleteAssignment(String id) async {
    _setLoading(true);
    try {
      await _controller.deleteAssignment(id);
      _assignments.removeWhere((a) => a.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Set date range filter
  void setDateRange(DateTime? startDate, DateTime? endDate) {
    _selectedStartDate = startDate;
    _selectedEndDate = endDate;
    notifyListeners();
  }
  
  // Set module filter
  void setModuleFilter(String? module) {
    _selectedModule = module;
    notifyListeners();
  }
  
  // Set status filter
  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }
  
  // Clear all filters
  void clearFilters() {
    _selectedStartDate = null;
    _selectedEndDate = null;
    _selectedModule = null;
    _selectedStatus = null;
    notifyListeners();
  }
  
  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}