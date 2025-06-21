import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/task_selector.dart';
import '../widgets/timer_display.dart';
import '../widgets/timer_controls.dart';
import 'settings_screen.dart';

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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
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
}
