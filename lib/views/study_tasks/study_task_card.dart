import 'package:flutter/material.dart';
import '../../models/study_task.dart';
import '../../utils/app_utils.dart';

class StudyTaskCard extends StatelessWidget {
  final StudyTask studyTask;
  final VoidCallback onToggleCompletion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudyTaskCard({
    Key? key,
    required this.studyTask,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: studyTask.isDone,
                  onChanged: (_) => onToggleCompletion(),
                  activeColor: AppColors.studyTaskComplete,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studyTask.task,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: studyTask.isDone ? TextDecoration.lineThrough : null,
                          color: studyTask.isDone ? AppColors.textSecondary : AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Duration: ${AppUtils.formatDuration(studyTask.durationMinutes)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: studyTask.isDone ? AppColors.textSecondary : AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: onEdit,
                  tooltip: 'Edit Study Task',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: onDelete,
                  tooltip: 'Delete Study Task',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppUtils.formatDate(studyTask.date),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}