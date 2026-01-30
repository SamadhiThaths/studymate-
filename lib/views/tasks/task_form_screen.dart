import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../utils/app_utils.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task; // If provided, we're editing an existing task

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing, populate the form with existing task data
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      if (widget.task!.description != null) {
        _descriptionController.text = widget.task!.description!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length > 200) {
                    return 'Title must be less than 200 characters';
                  }
                  return null;
                },
                maxLength: 200,
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
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.task == null ? 'Add Task' : 'Save Changes',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final taskProvider = context.read<TaskProvider>();
        final title = _titleController.text.trim();
        final description = _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null;

        if (widget.task == null) {
          // Creating a new task
          await taskProvider.addTask(title, description: description);
          if (context.mounted) {
            AppUtils.showSnackBar(context, 'Task added successfully');
            Navigator.of(context).pop();
          }
        } else {
          // Updating an existing task
          final updatedTask = widget.task!.copyWith(
            title: title,
            description: description,
          );
          await taskProvider.updateTask(updatedTask);
          if (context.mounted) {
            AppUtils.showSnackBar(context, 'Task updated successfully');
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