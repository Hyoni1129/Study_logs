import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';

class WeeklyConsistencyChart extends StatelessWidget {
  const WeeklyConsistencyChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_view_week,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Study Consistency',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your daily study activity this week',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<bool>>(
              future: context.read<StatisticsProvider>().getCurrentWeekConsistency(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading consistency data',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }

                final weekData = snapshot.data ?? [];
                if (weekData.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No study data available'),
                    ),
                  );
                }

                final statsProvider = context.read<StatisticsProvider>();
                final weekLabel = statsProvider.getCurrentWeekLabel();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Week label
                    Text(
                      weekLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Day labels
                    SizedBox(
                      height: 20,
                      child: Row(
                        children: _buildDayLabels(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Day squares
                    SizedBox(
                      height: 24,
                      child: Row(
                        children: weekData.asMap().entries.map((entry) {
                          final dayIndex = entry.key;
                          final hasStudied = entry.value;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: _buildDaySquare(context, hasStudied, dayIndex),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Legend
                    _buildLegend(context),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDayLabels(BuildContext context) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return dayLabels.map((label) {
      return Expanded(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildDaySquare(BuildContext context, bool hasStudied, int dayIndex) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: hasStudied
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: hasStudied
          ? Icon(
              Icons.check,
              size: 12,
              color: Theme.of(context).colorScheme.onPrimary,
            )
          : null,
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          'No activity',
          Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          context,
          'Study day',
          Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
