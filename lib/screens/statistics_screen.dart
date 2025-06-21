import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/statistics_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<StatisticsProvider>().refresh(),
          ),
        ],
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, statsProvider, child) {
          if (statsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (statsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statsProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      statsProvider.clearError();
                      statsProvider.refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (statsProvider.taskStatistics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Data Available',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your study sessions to see statistics',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector
                _buildPeriodSelector(context, statsProvider),
                
                const SizedBox(height: 24),
                
                // Summary cards
                _buildSummaryCards(context, statsProvider),
                
                const SizedBox(height: 24),
                
                // Charts
                _buildChartsSection(context, statsProvider),
                
                const SizedBox(height: 24),
                
                // Task breakdown
                _buildTaskBreakdown(context, statsProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, StatisticsProvider statsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Period',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Period buttons
            SegmentedButton<StatsPeriod>(
              segments: const [
                ButtonSegment<StatsPeriod>(
                  value: StatsPeriod.daily,
                  label: Text('Daily'),
                ),
                ButtonSegment<StatsPeriod>(
                  value: StatsPeriod.weekly,
                  label: Text('Weekly'),
                ),
                ButtonSegment<StatsPeriod>(
                  value: StatsPeriod.monthly,
                  label: Text('Monthly'),
                ),
                ButtonSegment<StatsPeriod>(
                  value: StatsPeriod.allTime,
                  label: Text('All Time'),
                ),
              ],
              selected: {statsProvider.currentPeriod},
              onSelectionChanged: (Set<StatsPeriod> newSelection) {
                statsProvider.setPeriod(newSelection.first);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Date navigation
            if (statsProvider.currentPeriod != StatsPeriod.allTime) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: statsProvider.hasPreviousPeriod
                        ? () => statsProvider.goToPreviousPeriod()
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    statsProvider.periodTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: statsProvider.hasNextPeriod
                        ? () => statsProvider.goToNextPeriod()
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ] else ...[
              Center(
                child: Text(
                  statsProvider.periodTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, StatisticsProvider statsProvider) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total Time',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statsProvider.formattedTotalTime,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.task_alt,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sessions',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${statsProvider.totalSessions}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection(BuildContext context, StatisticsProvider statsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Distribution',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Pie chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Study Time by Task',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(context, statsProvider),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Bar chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Study Time Comparison',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(statsProvider),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < statsProvider.taskStatistics.length) {
                                final taskName = statsProvider.taskStatistics[index].task.name;
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    taskName.length > 8 ? '${taskName.substring(0, 8)}...' : taskName,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 3600).toStringAsFixed(0)}h',
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarChartGroups(context, statsProvider),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskBreakdown(BuildContext context, StatisticsProvider statsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Breakdown',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...statsProvider.taskStatistics.map((taskStat) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.task_alt,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                taskStat.task.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${taskStat.sessionCount} sessions • ${taskStat.percentage.toStringAsFixed(1)}% of total time',
              ),
              trailing: Text(
                taskStat.formattedTime,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(BuildContext context, StatisticsProvider statsProvider) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return statsProvider.taskStatistics.asMap().entries.map((entry) {
      final index = entry.key;
      final taskStat = entry.value;
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: taskStat.totalSeconds.toDouble(),
        title: '${taskStat.percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarChartGroups(BuildContext context, StatisticsProvider statsProvider) {
    return statsProvider.taskStatistics.asMap().entries.map((entry) {
      final index = entry.key;
      final taskStat = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: taskStat.totalSeconds.toDouble(),
            color: Theme.of(context).colorScheme.primary,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY(StatisticsProvider statsProvider) {
    if (statsProvider.taskStatistics.isEmpty) return 1;
    final maxSeconds = statsProvider.taskStatistics.first.totalSeconds;
    return (maxSeconds * 1.2).toDouble();
  }
}
