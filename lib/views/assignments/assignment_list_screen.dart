import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_utils.dart';
import 'assignment_card.dart';
import 'assignment_form_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({Key? key}) : super(key: key);

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _loadAssignments();
      _isInit = true;
    }
  }

  Future<void> _loadAssignments() async {
    await Provider.of<AssignmentProvider>(context, listen: false).loadAssignments();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      Provider.of<AssignmentProvider>(context, listen: false)
          .setDateRange(_startDate, _endDate);
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    Provider.of<AssignmentProvider>(context, listen: false).clearFilters();
  }

  Future<void> _deleteAssignment(String id) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      context,
      'Delete Assignment',
      'Are you sure you want to delete this assignment?',
    );

    if (confirmed) {
      try {
        await Provider.of<AssignmentProvider>(context, listen: false).deleteAssignment(id);
        if (mounted) {
          AppUtils.showSnackBar(context, 'Assignment deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssignments,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAssignments,
        child: Consumer<AssignmentProvider>(
          builder: (ctx, assignmentProvider, child) {
            if (assignmentProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (assignmentProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${assignmentProvider.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAssignments,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final assignments = assignmentProvider.filteredAssignments;

            if (assignments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No assignments found',
                      style: TextStyle(fontSize: 18),
                    ),
                    if (assignmentProvider.selectedModule != null ||
                        assignmentProvider.selectedStatus != null ||
                        _startDate != null) ...[  
                      const SizedBox(height: 8),
                      const Text('Try clearing filters'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return Column(
              children: [
                if (_startDate != null && _endDate != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Date Range: ${AppUtils.formatDate(_startDate!)} - ${AppUtils.formatDate(_endDate!)}',
                          style: AppTextStyles.headline3,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: _clearFilters,
                        ),
                      ],
                    ),
                  ),
                if (assignmentProvider.selectedModule != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Module: ${assignmentProvider.selectedModule}',
                          style: AppTextStyles.headline3,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => assignmentProvider.setModuleFilter(null),
                        ),
                      ],
                    ),
                  ),
                if (assignmentProvider.selectedStatus != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Status: ${assignmentProvider.selectedStatus}',
                          style: AppTextStyles.headline3,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => assignmentProvider.setStatusFilter(null),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: assignments.length,
                    itemBuilder: (ctx, index) {
                      final assignment = assignments[index];
                      return AssignmentCard(
                        assignment: assignment,
                        onEdit: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => AssignmentFormScreen(assignment: assignment),
                          ),
                        ),
                        onDelete: () => _deleteAssignment(assignment.id),
                        onStatusChange: (newStatus) async {
                          try {
                            final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                            await assignmentProvider.updateAssignmentStatus(
                              assignment.id,
                              newStatus,
                            notificationProvider:  notificationProvider,
                            );
                            if (mounted) {
                              AppUtils.showSnackBar(
                                context,
                                'Status updated to $newStatus',
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              AppUtils.showSnackBar(
                                context,
                                'Error: ${e.toString()}',
                                isError: true,
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => const AssignmentFormScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _buildFilterBottomSheet(ctx),
    );
  }

  Widget _buildFilterBottomSheet(BuildContext context) {
    final assignmentProvider = Provider.of<AssignmentProvider>(context);
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Assignments', style: AppTextStyles.headline2),
                  TextButton(
                    onPressed: () {
                      _clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Date Range', style: AppTextStyles.headline3),
              ListTile(
                title: Text(
                  _startDate != null && _endDate != null
                      ? '${AppUtils.formatDate(_startDate!)} - ${AppUtils.formatDate(_endDate!)}'
                      : 'Select Date Range',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  Navigator.pop(context);
                  await _selectDateRange(context);
                },
              ),
              const SizedBox(height: 8),
              Text('Module', style: AppTextStyles.headline3),
              DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Select Module'),
                value: assignmentProvider.selectedModule,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Modules'),
                  ),
                  ...assignmentProvider.uniqueModules.map((module) {
                    return DropdownMenuItem<String>(
                      value: module,
                      child: Text(module),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  assignmentProvider.setModuleFilter(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              Text('Status', style: AppTextStyles.headline3),
              DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Select Status'),
                value: assignmentProvider.selectedStatus,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  ...assignmentProvider.allStatuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  assignmentProvider.setStatusFilter(value);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}