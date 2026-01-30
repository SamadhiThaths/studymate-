import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/study_task.dart';
import '../../providers/study_task_provider.dart';
import '../../utils/app_utils.dart';
import 'study_task_form_screen.dart';
import 'study_task_card.dart';

class StudyTaskListScreen extends StatefulWidget {
  const StudyTaskListScreen({Key? key}) : super(key: key);

  @override
  State<StudyTaskListScreen> createState() => _StudyTaskListScreenState();
}

class _StudyTaskListScreenState extends State<StudyTaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Load study tasks when screen initializes
    Future.microtask(() => context.read<StudyTaskProvider>().loadStudyTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Select Date',
          ),
        ],
      ),
      body: Consumer<StudyTaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadStudyTasks(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildFilters(context, provider),
              _buildProgressBar(context, provider),
              Expanded(
                child: _buildStudyTaskList(context, provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddStudyTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, StudyTaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date: ${AppUtils.formatDate(provider.selectedDate)}',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          if (provider.allSubjects.isNotEmpty) ...[  
            const Text('Filter by Subject:', style: AppTextStyles.subtitle2),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: provider.selectedSubject == null,
                      onSelected: (_) => provider.setSelectedSubject(null),
                    ),
                  ),
                  ...provider.allSubjects.map((subject) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(subject),
                          selected: provider.selectedSubject == subject,
                          onSelected: (_) => provider.setSelectedSubject(subject),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, StudyTaskProvider provider) {
    final completedMinutes = provider.totalStudyTimeForSelectedDate;
    final totalMinutes = provider.totalPlannedStudyTimeForSelectedDate;
    final progress = totalMinutes > 0 ? completedMinutes / totalMinutes : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress:', style: AppTextStyles.subtitle2),
              Text(
                '${AppUtils.formatDuration(completedMinutes)} / ${AppUtils.formatDuration(totalMinutes)}',
                style: AppTextStyles.subtitle2,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: AppColors.studyTaskComplete,
            minHeight: 10,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStudyTaskList(BuildContext context, StudyTaskProvider provider) {
    final filteredTasks = provider.filteredStudyTasks;

    if (filteredTasks.isEmpty) {
      return const Center(
        child: Text('No study tasks for the selected date and filters.'),
      );
    }

    // Group tasks by subject if no subject filter is applied
    if (provider.selectedSubject == null) {
      final tasksBySubject = <String, List<StudyTask>>{};
      for (var task in filteredTasks) {
        if (!tasksBySubject.containsKey(task.subject)) {
          tasksBySubject[task.subject] = [];
        }
        tasksBySubject[task.subject]!.add(task);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasksBySubject.length,
        itemBuilder: (context, index) {
          final subject = tasksBySubject.keys.elementAt(index);
          final tasks = tasksBySubject[subject]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  subject,
                  style: AppTextStyles.headline3,
                ),
              ),
              ...tasks.map((task) => StudyTaskCard(
                    studyTask: task,
                    onToggleCompletion: () =>
                        provider.toggleStudyTaskCompletion(task.id),
                    onEdit: () => _navigateToEditStudyTask(context, task),
                    onDelete: () => _confirmDeleteStudyTask(context, task),
                  )),
              const SizedBox(height: 16),
            ],
          );
        },
      );
    } else {
      // Show flat list when a subject filter is applied
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return StudyTaskCard(
            studyTask: task,
            onToggleCompletion: () => provider.toggleStudyTaskCompletion(task.id),
            onEdit: () => _navigateToEditStudyTask(context, task),
            onDelete: () => _confirmDeleteStudyTask(context, task),
          );
        },
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = context.read<StudyTaskProvider>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      provider.setSelectedDate(picked);
    }
  }

  void _navigateToAddStudyTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StudyTaskFormScreen(),
      ),
    );
  }

  void _navigateToEditStudyTask(BuildContext context, StudyTask studyTask) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyTaskFormScreen(studyTask: studyTask),
      ),
    );
  }

  Future<void> _confirmDeleteStudyTask(BuildContext context, StudyTask studyTask) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      context,
      'Delete Study Task',
      'Are you sure you want to delete "${studyTask.task}"?',
    );

    if (confirmed && context.mounted) {
      await context.read<StudyTaskProvider>().deleteStudyTask(studyTask.id);
      if (context.mounted) {
        AppUtils.showSnackBar(context, 'Study task deleted successfully');
      }
    }
  }
}