import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/timer_provider.dart';
import '../services/backup_service.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDialogShowing = false; // Track dialog state

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
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                    true,
                    (value) {
                      // Handle notification settings
                    },
                  ),
                ],
              ),
              
              // Data Settings
              _buildSectionCard(
                context,
                'Data & Backup',
                Icons.backup_outlined,
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
                    'Backup your study sessions',
                    Icons.cloud_download_outlined,
                    () => _exportData(context),
                  ),
                  _buildActionTile(
                    context,
                    'Import Data',
                    'Restore from backup file',
                    Icons.cloud_upload_outlined,
                    () => _importData(context),
                  ),
                ],
              ),
              
              // Developer Profile Section
              _buildSectionCard(
                context,
                'Developer Profile',
                Icons.person_outline,
                [
                  _buildDeveloperProfile(context),
                ],
              ),
              
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
                  _buildActionTile(
                    context,
                    'View Tutorial',
                    'Revisit the app introduction',
                    Icons.school_outlined,
                    () => _showOnboarding(context),
                  ),
                  _buildActionTile(
                    context,
                    'Feedback',
                    'Send us your thoughts',
                    Icons.feedback_outlined,
                    () => _showFeedbackDialog(context),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            ...children.map((child) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: child,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperProfile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.code,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Developer Name
          Text(
            'JeongHan Lee',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Developer Role
          Text(
            'Flutter Developer',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // GitHub Link
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _launchGitHub(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GitHub Profile',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Sponsor Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _launchSponsor(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sponsor',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bio
          Text(
            'Passionate about creating clean, efficient, and user-friendly mobile applications with Flutter.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/JeongHanLee');
    if (!await launchUrl(url)) {
      // Handle error - could show a snackbar
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _launchSponsor() async {
    final Uri url = Uri.parse('https://github.com/sponsors/JeongHanLee');
    if (!await launchUrl(url)) {
      // Handle error - could show a snackbar
      debugPrint('Could not launch $url');
    }
  }

  void _showFeedbackDialog(BuildContext context) {
    if (_isDialogShowing) return; // Prevent duplicate dialogs
    
    _isDialogShowing = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'We\'d love to hear from you! Please send your feedback to:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SelectableText(
                        'Team.Stella.Global@gmail.com',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.copy,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: 'Team.Stella.Global@gmail.com'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Email copied to clipboard!'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                      tooltip: 'Copy email address',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing = false; // Reset flag when dialog closes
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    ).then((_) {
      _isDialogShowing = false; // Reset flag when dialog closes
    });
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
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
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              onChanged: onChanged,
            ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String value,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final backupService = BackupService();
      final filePath = await backupService.exportData();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        if (filePath != null) {
          // Show success dialog only if file was actually saved
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Export Successful'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your data has been exported successfully!'),
                  const SizedBox(height: 12),
                  const Text('File saved to:'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      filePath,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        // If filePath is null, user cancelled, so don't show any message
      }
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Failed'),
            content: Text('Failed to export data: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      // Show warning dialog first
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data'),
          content: const Text(
            'Importing data will replace all your current tasks and study sessions. This action cannot be undone.\n\nAre you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final backupService = BackupService();
      final imported = await backupService.importData();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        if (imported) {
          // Show success dialog only if import actually happened
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Successful'),
              content: const Text('Your data has been imported successfully!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        // If imported is false, user cancelled, so don't show any message
      }
    } catch (e) {
      // Close loading dialog if open and context is still mounted
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Failed'),
            content: Text('Failed to import data: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showOnboarding(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(
          isFromSettings: true,
          onComplete: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, TimerProvider timerProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Reset Pomodoro Counter'),
          content: const Text(
            'This will reset your current pomodoro round count to zero. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                timerProvider.resetPomodoroRounds();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pomodoro counter reset'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
