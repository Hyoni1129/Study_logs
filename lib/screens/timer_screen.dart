import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/task_selector.dart';
import '../widgets/timer_display.dart';
import '../widgets/timer_controls.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Timer',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showTimerSettings(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Task selector
              const TaskSelector(),
              
              const SizedBox(height: 32),
              
              // Timer display
              const Expanded(
                flex: 2,
                child: TimerDisplay(),
              ),
              
              const SizedBox(height: 32),
              
              // Timer controls
              const TimerControls(),
              
              const SizedBox(height: 16), // Reduced from 32
            ],
          ),
        ),
      ),
    );
  }

  void _showTimerSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const TimerSettingsSheet(),
    );
  }
}

class TimerSettingsSheet extends StatelessWidget {
  const TimerSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Timer Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Timer type selector
                  Text(
                    'Timer Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  SegmentedButton<TimerType>(
                    segments: const [
                      ButtonSegment<TimerType>(
                        value: TimerType.stopwatch,
                        label: Text('Stopwatch'),
                        icon: Icon(Icons.timer),
                      ),
                      ButtonSegment<TimerType>(
                        value: TimerType.pomodoro,
                        label: Text('Pomodoro'),
                        icon: Icon(Icons.hourglass_empty),
                      ),
                    ],
                    selected: {timerProvider.timerType},
                    onSelectionChanged: (Set<TimerType> newSelection) {
                      timerProvider.setTimerType(newSelection.first);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pomodoro settings (only show if Pomodoro is selected)
                  if (timerProvider.timerType == TimerType.pomodoro) ...[
                    Text(
                      'Pomodoro Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDurationSetting(
                      context,
                      'Focus Duration',
                      timerProvider.focusDuration ~/ 60,
                      (value) => timerProvider.updateFocusDuration(value),
                      'minutes',
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildDurationSetting(
                      context,
                      'Short Break Duration',
                      timerProvider.shortBreakDuration ~/ 60,
                      (value) => timerProvider.updateShortBreakDuration(value),
                      'minutes',
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildDurationSetting(
                      context,
                      'Long Break Duration',
                      timerProvider.longBreakDuration ~/ 60,
                      (value) => timerProvider.updateLongBreakDuration(value),
                      'minutes',
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildDurationSetting(
                      context,
                      'Long Break Interval',
                      timerProvider.longBreakInterval,
                      (value) => timerProvider.updateLongBreakInterval(value),
                      'rounds',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: timerProvider.isStopped 
                          ? () => timerProvider.resetPomodoroRounds()
                          : null,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Pomodoro Rounds'),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Current status
                  if (timerProvider.timerType == TimerType.pomodoro) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Status',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Phase: ${timerProvider.currentPhaseDescription}'),
                          Text('Completed Rounds: ${timerProvider.pomodoroRounds}'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDurationSetting(
    BuildContext context,
    String label,
    int currentValue,
    Function(int) onChanged,
    String unit,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              onPressed: currentValue > 1 
                  ? () => onChanged(currentValue - 1)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Text(
              '$currentValue $unit',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              onPressed: currentValue < 60 
                  ? () => onChanged(currentValue + 1)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
