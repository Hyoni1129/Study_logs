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
            child: AnimatedBuilder(
              animation: ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation,
              builder: (context, child) {
                final animation = ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
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
                  ),
                );
              },
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Card(
              key: ValueKey('total-time-${statsProvider.formattedTotalTime}'),
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
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Card(
              key: ValueKey('sessions-${statsProvider.totalSessions}'),
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
        
        // Pie chart with proper spacing and animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Study Time by Task',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24), // Increased spacing
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 250, // Fixed height to prevent overlap
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.0, // Square aspect ratio
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                        child: PieChart(
                          key: ValueKey(statsProvider.currentPeriod),
                          PieChartData(
                            sections: _buildPieChartSections(context, statsProvider),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 3,
                            centerSpaceRadius: 60, // Slightly larger center space
                            pieTouchData: PieTouchData(
                              enabled: true,
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                _handlePieChartTouch(context, event, pieTouchResponse, statsProvider);
                              },
                            ),
                          ),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Added bottom spacing
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20), // Increased spacing between charts
        
        // Bar chart with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Study Time Comparison',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24), // Increased spacing
                  SizedBox(
                    height: 250, // Fixed height
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: BarChart(
                        key: ValueKey('${statsProvider.currentPeriod}_bar'),
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(statsProvider),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchCallback: (FlTouchEvent event, barTouchResponse) {
                              _handleBarChartTouch(context, event, barTouchResponse, statsProvider);
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
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
                                reservedSize: 40,
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
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _getMaxY(statsProvider) / 5,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                        ),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOutCubic,
                      ),
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

  // Chart interaction handlers
  void _handlePieChartTouch(BuildContext context, FlTouchEvent event, PieTouchResponse? pieTouchResponse, StatisticsProvider statsProvider) {
    if (event is FlTapUpEvent && pieTouchResponse?.touchedSection != null) {
      final touchedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
      if (touchedIndex >= 0 && touchedIndex < statsProvider.taskStatistics.length) {
        final taskStat = statsProvider.taskStatistics[touchedIndex];
        _showTaskDetailDialog(context, taskStat);
      }
    }
  }

  void _handleBarChartTouch(BuildContext context, FlTouchEvent event, BarTouchResponse? barTouchResponse, StatisticsProvider statsProvider) {
    if (event is FlTapUpEvent && barTouchResponse?.spot != null) {
      final touchedIndex = barTouchResponse!.spot!.touchedBarGroupIndex;
      if (touchedIndex >= 0 && touchedIndex < statsProvider.taskStatistics.length) {
        final taskStat = statsProvider.taskStatistics[touchedIndex];
        _showTaskDetailDialog(context, taskStat);
      }
    }
  }

  void _showTaskDetailDialog(BuildContext context, TaskStatistics taskStat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final hours = taskStat.totalSeconds ~/ 3600;
        final minutes = (taskStat.totalSeconds % 3600) ~/ 60;
        final sessions = taskStat.sessionCount;
        final avgSessionTime = sessions > 0 ? taskStat.totalSeconds ~/ sessions : 0;
        final avgHours = avgSessionTime ~/ 3600;
        final avgMinutes = (avgSessionTime % 3600) ~/ 60;

        return AlertDialog(
          title: Text(
            taskStat.task.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Total Time:', '${hours}h ${minutes}m'),
              _buildDetailRow('Sessions:', '$sessions'),
              _buildDetailRow('Avg Session:', '${avgHours}h ${avgMinutes}m'),
              const SizedBox(height: 16),
              Text(
                'Tap on charts to see detailed statistics for each task.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
