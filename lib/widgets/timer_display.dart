import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import 'circular_timer_progress.dart';
import 'pulsing_widget.dart';

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
            padding: const EdgeInsets.all(24.0), // Reduced padding
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Timer type indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timerProvider.currentPhaseIcon,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            timerProvider.currentPhaseDescription,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Circular timer display for Pomodoro
                    if (timerProvider.timerType == TimerType.pomodoro)
                      PulsingWidget(
                        isActive: timerProvider.isRunning,
                        child: CircularTimerProgress(
                          progress: timerProvider.progress,
                          progressColor: _getProgressColor(context, timerProvider.pomodoroPhase),
                          backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          strokeWidth: 8.0,
                          size: constraints.maxWidth * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Main timer display
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  timerProvider.formattedTimeRemaining,
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -1,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Phase indicator
                              Text(
                                'Round ${timerProvider.pomodoroRounds + 1}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    
                    // Stopwatch display
                    else
                      PulsingWidget(
                        isActive: timerProvider.isRunning,
                        child: Column(
                          children: [
                            // Main timer display
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                timerProvider.formattedElapsedTime,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -2,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Timer state indicator
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStateIcon(timerProvider.timerState),
                          color: _getStateColor(context, timerProvider.timerState),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
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
                      const SizedBox(height: 12),
                      Text(
                        'Task: ${timerProvider.selectedTask!.name}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                );
              },
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
