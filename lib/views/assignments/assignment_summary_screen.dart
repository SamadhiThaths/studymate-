import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/assignment_provider.dart';
import '../../utils/app_utils.dart';

class AssignmentSummaryScreen extends StatefulWidget {
  const AssignmentSummaryScreen({Key? key}) : super(key: key);

  @override
  State<AssignmentSummaryScreen> createState() =>
      _AssignmentSummaryScreenState();
}

class _AssignmentSummaryScreenState extends State<AssignmentSummaryScreen> {
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
    await Provider.of<AssignmentProvider>(
      context,
      listen: false,
    ).loadAssignments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Summary'),
        actions: [
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

            final assignments = assignmentProvider.assignments;

            if (assignments.isEmpty) {
              return const Center(
                child: Text(
                  'No assignments found',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            final statusCounts = assignmentProvider.assignmentCountByStatus;
            final upcomingAssignments = assignmentProvider.upcomingAssignments;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusSummaryCard(statusCounts),
                  const SizedBox(height: 16),
                  _buildStatusPieChart(statusCounts),
                  const SizedBox(height: 24),
                  Text(
                    'Upcoming Assignments (Next 7 Days)',
                    style: AppTextStyles.headline2,
                  ),
                  const SizedBox(height: 8),
                  _buildUpcomingAssignmentsList(upcomingAssignments),
                  const SizedBox(height: 24),
                  Text('Assignments by Module', style: AppTextStyles.headline2),
                  const SizedBox(height: 8),
                  _buildModuleBarChart(assignmentProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusSummaryCard(Map<String, int> statusCounts) {
    final totalAssignments = statusCounts.values.fold(
      0,
      (sum, count) => sum + count,
    );
    final completedCount = statusCounts['Completed'] ?? 0;
    final completionRate = totalAssignments > 0
        ? (completedCount / totalAssignments * 100).toStringAsFixed(1)
        : '0';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assignment Overview', style: AppTextStyles.headline2),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusCountItem('Total', totalAssignments, Colors.blue),
                _buildStatusCountItem(
                  'Completed',
                  completedCount,
                  Colors.green,
                ),
                _buildStatusCountItem(
                  'In Progress',
                  statusCounts['In Progress'] ?? 0,
                  Colors.orange,
                ),
                _buildStatusCountItem(
                  'Overdue',
                  statusCounts['Overdue'] ?? 0,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Completion Rate: $completionRate%',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalAssignments > 0
                  ? completedCount / totalAssignments
                  : 0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCountItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: AppTextStyles.body1),
      ],
    );
  }

  Widget _buildStatusPieChart(Map<String, int> statusCounts) {
    final List<PieChartSectionData> sections = [];
    final colors = {
      'Not Started': Colors.orange,
      'In Progress': Colors.blue,
      'Completed': Colors.green,
      'Overdue': Colors.red,
    };

    int totalCount = 0;
    statusCounts.forEach((key, value) {
      totalCount += value;
    });

    if (totalCount == 0) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No data available for chart')),
        ),
      );
    }

    statusCounts.forEach((status, count) {
      if (count > 0) {
        final double percentage = count / totalCount * 100;
        sections.add(
          PieChartSectionData(
            color: colors[status] ?? Colors.grey,
            value: count.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assignments by Status', style: AppTextStyles.headline2),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: colors.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 16, height: 16, color: entry.value),
                    const SizedBox(width: 4),
                    Text('${entry.key} (${statusCounts[entry.key] ?? 0})'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAssignmentsList(List<dynamic> upcomingAssignments) {
    if (upcomingAssignments.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No upcoming assignments in the next 7 days'),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: upcomingAssignments.length,
        itemBuilder: (ctx, index) {
          final assignment = upcomingAssignments[index];
          final daysLeft = assignment.dueDate.difference(DateTime.now()).inDays;

          return ListTile(
            title: Text(assignment.name),
            subtitle: Text(
              '${assignment.moduleCode} - ${AppUtils.formatDate(assignment.dueDate)}',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: daysLeft == 0
                    ? Colors.red
                    : daysLeft <= 2
                    ? Colors.orange
                    : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                daysLeft == 0
                    ? 'Due Today!'
                    : daysLeft == 1
                    ? 'Tomorrow'
                    : '$daysLeft days left',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModuleBarChart(AssignmentProvider provider) {
    // Group assignments by module
    final Map<String, int> moduleAssignmentCounts = {};
    for (var assignment in provider.assignments) {
      moduleAssignmentCounts[assignment.moduleCode] =
          (moduleAssignmentCounts[assignment.moduleCode] ?? 0) + 1;
    }

    if (moduleAssignmentCounts.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No data available for chart')),
        ),
      );
    }

    // Sort modules by assignment count (descending)
    final sortedModules = moduleAssignmentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Limit to top 5 modules if there are more
    final displayModules = sortedModules.length > 5
        ? sortedModules.sublist(0, 5)
        : sortedModules;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayModules.length < sortedModules.length
                  ? 'Top 5 Modules by Assignment Count'
                  : 'Modules by Assignment Count',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      displayModules
                          .map((e) => e.value.toDouble())
                          .reduce(
                            (value, element) =>
                                value > element ? value : element,
                          ) *
                      1.2,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(value.toInt().toString()),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= displayModules.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              displayModules[value.toInt()].key,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: List.generate(
                    displayModules.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: displayModules[index].value.toDouble(),
                          color: AppColors.primary,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
