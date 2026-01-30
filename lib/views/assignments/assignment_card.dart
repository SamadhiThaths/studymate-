import 'package:flutter/material.dart';
import '../../models/assignment.dart';
import '../../utils/app_utils.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final Function() onEdit;
  final Function() onDelete;
  final Function(String) onStatusChange;

  const AssignmentCard({
    Key? key,
    required this.assignment,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    assignment.name,
                    style: AppTextStyles.headline2,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.school, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  assignment.moduleCode,
                  style: AppTextStyles.headline3,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Due: ${AppUtils.formatDate(assignment.dueDate)}',
                  style: AppTextStyles.body1,
                ),
                const SizedBox(width: 8),
                _buildDueIndicator(),
              ],
            ),
            if (assignment.description != null && assignment.description!.isNotEmpty) ...[  
              const SizedBox(height: 8),
              Text(
                assignment.description!,
                style: AppTextStyles.body1,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusDropdown(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: AppColors.primary,
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    switch (assignment.status) {
      case 'Completed':
        chipColor = Colors.green;
        break;
      case 'In Progress':
        chipColor = Colors.blue;
        break;
      case 'Overdue':
        chipColor = Colors.red;
        break;
      default: // Not Started
        chipColor = Colors.orange;
    }

    return Chip(
      label: Text(
        assignment.status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDueIndicator() {
    final now = DateTime.now();
    final daysLeft = assignment.dueDate.difference(now).inDays;
    
    if (assignment.status == 'Completed') {
      return const Text('Completed', style: TextStyle(color: Colors.green));
    } else if (assignment.status == 'Overdue') {
      return const Text('Overdue!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
    } else if (daysLeft < 0) {
      return const Text('Due date passed', style: TextStyle(color: Colors.red));
    } else if (daysLeft == 0) {
      return const Text('Due today!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
    } else if (daysLeft <= 3) {
      return Text('$daysLeft days left', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold));
    } else {
      return Text('$daysLeft days left', style: const TextStyle(color: Colors.green));
    }
  }

  Widget _buildStatusDropdown() {
    return DropdownButton<String>(
      value: assignment.status,
      underline: Container(height: 1, color: AppColors.primary),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onStatusChange(newValue);
        }
      },
      items: <String>['Not Started', 'In Progress', 'Completed', 'Overdue']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}