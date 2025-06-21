import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../utils/app_colors.dart';
import 'circular_timer_progress.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Reduced padding
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate responsive sizes based on available space
                final availableHeight = constraints.maxHeight;
                final maxCircularSize = constraints.maxWidth * 0.6; // Reduced from 0.65
                final circularSize = maxCircularSize.clamp(180.0, 240.0); // Reduced max size
                
                return SingleChildScrollView( // Add scroll capability
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: availableHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    // Timer type indicator - ultra compact
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Even more compact
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10), // Smaller radius
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timerProvider.currentPhaseIcon,
                            style: const TextStyle(fontSize: 12), // Even smaller icon
                          ),
                          const SizedBox(width: 3), // Minimal spacing
                          Flexible(
                            child: Text(
                              timerProvider.currentPhaseDescription,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                                fontSize: 11, // Smaller font
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12), // Further reduced spacing
                    
                    // Circular timer display for Pomodoro
                    if (timerProvider.timerType == TimerType.pomodoro)
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: circularSize,
                          maxHeight: circularSize,
                        ),
                        child: CircularTimerProgress(
                          progress: timerProvider.progress,
                          progressColor: _getProgressColor(context, timerProvider.pomodoroPhase),
                          backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          strokeWidth: 8.0,
                          size: circularSize,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Main timer display with smooth animation
                                Flexible(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    child: FittedBox(
                                      key: ValueKey(timerProvider.formattedTimeRemaining),
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        timerProvider.formattedTimeRemaining,
                                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: -1,
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: circularSize * 0.15, // Responsive font size
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4), // Minimal spacing
                                // Phase indicator - ultra compact
                                Flexible(
                                  child: Text(
                                    'Round ${timerProvider.pomodoroRounds + 1}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11, // Even smaller font size
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    
                    // Stopwatch display
                    else
                      Column(
                        children: [
                          // Main timer display with smooth animation
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: FittedBox(
                              key: ValueKey(timerProvider.formattedElapsedTime),
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
                          ),
                        ],
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
                    
                    // Show today's total time when stopped
                    if (timerProvider.isStopped && timerProvider.todayStudyTime > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Today: ${timerProvider.formattedTodayTime}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                ),
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
