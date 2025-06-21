import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        return Column(
          children: [
            // Main control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start/Resume button
                if (timerProvider.canStart || timerProvider.canResume)
                  _buildControlButton(
                    context,
                    icon: timerProvider.canStart ? Icons.play_arrow : Icons.play_arrow,
                    label: timerProvider.canStart ? 'Start' : 'Resume',
                    color: Colors.green,
                    onPressed: timerProvider.canStart || timerProvider.canResume
                        ? () => timerProvider.startTimer()
                        : null,
                    isPrimary: true,
                  ),

                // Pause button
                if (timerProvider.canPause)
                  _buildControlButton(
                    context,
                    icon: Icons.pause,
                    label: 'Pause',
                    color: Colors.orange,
                    onPressed: () => timerProvider.pauseTimer(),
                    isPrimary: true,
                  ),

                // Stop button
                if (timerProvider.canStop)
                  _buildControlButton(
                    context,
                    icon: Icons.stop,
                    label: 'Stop',
                    color: Colors.red,
                    onPressed: () => timerProvider.stopTimer(),
                    isPrimary: false,
                  ),
              ],
            ),
            
            // Secondary actions
            if (timerProvider.isStopped) ...[
              const SizedBox(height: 16),
              
              // Timer type toggle
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
            ],

            // Error display
            if (timerProvider.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        timerProvider.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => timerProvider.clearError(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ],

            // Quick actions for Pomodoro
            if (timerProvider.timerType == TimerType.pomodoro && 
                timerProvider.isStopped) ...[
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset Rounds'),
                    onPressed: () => timerProvider.resetPomodoroRounds(),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.info, size: 18),
                    label: Text('Round ${timerProvider.pomodoroRounds + 1}'),
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
