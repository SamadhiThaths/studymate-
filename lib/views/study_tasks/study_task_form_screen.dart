import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/study_task.dart';
import '../../providers/study_task_provider.dart';
import '../../utils/app_utils.dart';

class StudyTaskFormScreen extends StatefulWidget {
  final StudyTask? studyTask; // If provided, we're editing an existing study task

  const StudyTaskFormScreen({Key? key, this.studyTask}) : super(key: key);

  @override
  State<StudyTaskFormScreen> createState() => _StudyTaskFormScreenState();
}

class _StudyTaskFormScreenState extends State<StudyTaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _durationController = TextEditingController();
  
  String _subject = AppConstants.studySubjects.first;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing, populate the form with existing study task data
    if (widget.studyTask != null) {
      _taskController.text = widget.studyTask!.task;
      _durationController.text = widget.studyTask!.durationMinutes.toString();
      _subject = widget.studyTask!.subject;
      _date = widget.studyTask!.date;
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studyTask == null ? 'Add Study Task' : 'Edit Study Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSubjectDropdown(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Task',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Duration must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveStudyTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.studyTask == null ? 'Add Study Task' : 'Save Changes',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return DropdownButtonFormField<String>(
      value: _subject,
      decoration: const InputDecoration(
        labelText: 'Subject',
        border: OutlineInputBorder(),
      ),
      items: AppConstants.studySubjects.map((subject) {
        return DropdownMenuItem<String>(
          value: subject,
          child: Text(subject),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _subject = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a subject';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppUtils.formatDate(_date)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _saveStudyTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final provider = context.read<StudyTaskProvider>();
        final task = _taskController.text.trim();
        final durationMinutes = int.parse(_durationController.text.trim());

        if (widget.studyTask == null) {
          // Creating a new study task
          await provider.addStudyTask(
            subject: _subject,
            task: task,
            date: _date,
            durationMinutes: durationMinutes,
          );
          if (context.mounted) {
            AppUtils.showSnackBar(context, 'Study task added successfully');
            Navigator.of(context).pop();
          }
        } else {
          // Updating an existing study task
          final updatedStudyTask = widget.studyTask!.copyWith(
            subject: _subject,
            task: task,
            date: _date,
            durationMinutes: durationMinutes,
          );
          await provider.updateStudyTask(updatedStudyTask);
          if (context.mounted) {
            AppUtils.showSnackBar(context, 'Study task updated successfully');
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (context.mounted) {
          AppUtils.showSnackBar(
            context,
            'Error: ${e.toString()}',
            isError: true,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}