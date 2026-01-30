import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/assignment.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_utils.dart';

class AssignmentFormScreen extends StatefulWidget {
  final Assignment? assignment;

  const AssignmentFormScreen({Key? key, this.assignment}) : super(key: key);

  @override
  State<AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends State<AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _moduleCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String _status = 'Not Started';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.assignment != null) {
      _nameController.text = widget.assignment!.name;
      _moduleCodeController.text = widget.assignment!.moduleCode;
      _descriptionController.text = widget.assignment!.description ?? '';
      _dueDate = widget.assignment!.dueDate;
      _status = widget.assignment!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _moduleCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AssignmentProvider>(context, listen: false);

      if (widget.assignment == null) {
        // Create new assignment
        await provider.addAssignment(
          name: _nameController.text.trim(),
          moduleCode: _moduleCodeController.text.trim(),
          dueDate: _dueDate,
          status: _status,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
        if (mounted) {
          AppUtils.showSnackBar(context, 'Assignment added successfully');
          Navigator.pop(context);
        }
      } else {
        // Update existing assignment
        final updatedAssignment = widget.assignment!.copyWith(
          name: _nameController.text.trim(),
          moduleCode: _moduleCodeController.text.trim(),
          dueDate: _dueDate,
          status: _status,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
        
        // Get notification provider if status is changed to Completed
        if (_status == 'Completed' && widget.assignment!.status != 'Completed') {
          final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
          await provider.updateAssignmentStatus(
            widget.assignment!.id,
            _status,
            notificationProvider: notificationProvider,
          );
        } else {
          await provider.updateAssignment(updatedAssignment);
        }
        if (mounted) {
          AppUtils.showSnackBar(context, 'Assignment updated successfully');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment == null ? 'Add Assignment' : 'Edit Assignment'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Assignment Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter assignment name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _moduleCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Module Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter module code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Due Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(AppUtils.formatDate(_dueDate)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: <String>['Not Started', 'In Progress', 'Completed', 'Overdue']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _status = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveAssignment,
                        child: Text(
                          widget.assignment == null ? 'Add Assignment' : 'Update Assignment',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}