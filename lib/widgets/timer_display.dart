import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                // Timer type indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    timerProvider.currentPhaseDescription,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Main timer display
                Text(
                  timerProvider.formattedElapsedTime,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    letterSpacing: -2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                
                // Pomodoro specific info
                if (timerProvider.timerType == TimerType.pomodoro) ...[
                  const SizedBox(height: 16),
                  
                  // Progress bar
                  LinearProgressIndicator(
                    value: timerProvider.progress,
                    backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(context, timerProvider.pomodoroPhase),
                    ),
                    minHeight: 8,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Remaining time
                  Text(
                    'Remaining: ${timerProvider.formattedRemainingTime}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Pomodoro rounds
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Round ${timerProvider.pomodoroRounds + 1}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                
                // Timer state indicator
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getStateIcon(timerProvider.timerState),
                      color: _getStateColor(context, timerProvider.timerState),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStateText(timerProvider.timerState),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getStateColor(context, timerProvider.timerState),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                // Selected task info
                if (timerProvider.selectedTask != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Task: ${timerProvider.selectedTask!.name}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getProgressColor(BuildContext context, PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.focus:
        return Theme.of(context).colorScheme.primary;
      case PomodoroPhase.shortBreak:
        return Theme.of(context).colorScheme.secondary;
      case PomodoroPhase.longBreak:
        return Theme.of(context).colorScheme.tertiary;
    }
  }

  IconData _getStateIcon(TimerState state) {
    switch (state) {
      case TimerState.running:
        return Icons.play_arrow;
      case TimerState.paused:
        return Icons.pause;
      case TimerState.stopped:
        return Icons.stop;
    }
  }

  Color _getStateColor(BuildContext context, TimerState state) {
    switch (state) {
      case TimerState.running:
        return Colors.green;
      case TimerState.paused:
        return Colors.orange;
      case TimerState.stopped:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  String _getStateText(TimerState state) {
    switch (state) {
      case TimerState.running:
        return 'Running';
      case TimerState.paused:
        return 'Paused';
      case TimerState.stopped:
        return 'Stopped';
    }
  }
}
