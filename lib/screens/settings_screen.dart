import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Pomodoro Settings
              _buildSectionCard(
                context,
                'Pomodoro Timer',
                Icons.access_time_filled_rounded,
                [
                  _buildSliderTile(
                    context,
                    'Focus Duration',
                    '${timerProvider.focusDuration ~/ 60} minutes',
                    timerProvider.focusDuration / 60,
                    5.0,
                    60.0,
                    (value) => timerProvider.updateFocusDuration(value.round()),
                  ),
                  _buildSliderTile(
                    context,
                    'Short Break',
                    '${timerProvider.shortBreakDuration ~/ 60} minutes',
                    timerProvider.shortBreakDuration / 60,
                    1.0,
                    15.0,
                    (value) => timerProvider.updateShortBreakDuration(value.round()),
                  ),
                  _buildSliderTile(
                    context,
                    'Long Break',
                    '${timerProvider.longBreakDuration ~/ 60} minutes',
                    timerProvider.longBreakDuration / 60,
                    5.0,
                    30.0,
                    (value) => timerProvider.updateLongBreakDuration(value.round()),
                  ),
                  _buildSliderTile(
                    context,
                    'Long Break Interval',
                    'Every ${timerProvider.longBreakInterval} sessions',
                    timerProvider.longBreakInterval.toDouble(),
                    2.0,
                    8.0,
                    (value) => timerProvider.updateLongBreakInterval(value.round()),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Audio Settings
              _buildSectionCard(
                context,
                'Audio & Notifications',
                Icons.volume_up_outlined,
                [
                  _buildSwitchTile(
                    context,
                    'Sound Effects',
                    'Play sounds when timer starts/stops',
                    timerProvider.soundEnabled,
                    (value) => timerProvider.setSoundEnabled(value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Notifications',
                    'Show notifications when sessions complete',
                    true, // This would come from a notification settings provider
                    (value) {
                      // Handle notification settings
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Data Settings
              _buildSectionCard(
                context,
                'Data & Statistics',
                Icons.analytics_outlined,
                [
                  _buildActionTile(
                    context,
                    'Reset Pomodoro Counter',
                    'Start pomodoro rounds from zero',
                    Icons.restart_alt,
                    timerProvider.canStop ? null : () {
                      _showResetConfirmation(context, timerProvider);
                    },
                  ),
                  _buildActionTile(
                    context,
                    'Export Data',
                    'Export your study sessions',
                    Icons.download_outlined,
                    () {
                      // Handle data export
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Export feature coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // About Section
              _buildSectionCard(
                context,
                'About',
                Icons.info_outline,
                [
                  _buildInfoTile(
                    context,
                    'Version',
                    '1.0.0',
                  ),
                  _buildInfoTile(
                    context,
                    'Developer',
                    'Study Logs Team',
                  ),
                  _buildActionTile(
                    context,
                    'Feedback',
                    'Send us your thoughts',
                    Icons.feedback_outlined,
                    () {
                      // Handle feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback feature coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context,
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      enabled: onTap != null,
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, TimerProvider timerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pomodoro Counter?'),
        content: const Text(
          'This will reset your pomodoro round counter to zero. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              timerProvider.resetPomodoroRounds();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pomodoro counter reset successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
