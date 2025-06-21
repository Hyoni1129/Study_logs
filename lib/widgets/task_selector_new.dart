import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/timer_provider.dart';

class TaskSelector extends StatefulWidget {
  const TaskSelector({super.key});

  @override
  State<TaskSelector> createState() => _TaskSelectorState();
}

class _TaskSelectorState extends State<TaskSelector> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _heightAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMinimized() {
    setState(() {
      _isMinimized = !_isMinimized;
      if (_isMinimized) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskProvider, TimerProvider>(
      builder: (context, taskProvider, timerProvider, child) {
        if (taskProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!taskProvider.hasTasks) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.task_alt_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No tasks available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create a task in the Tasks tab to start timing',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Card(
              child: Column(
                children: [
                  // Header with minimize button (only show when task is selected)
                  if (timerProvider.selectedTask != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Task: ${timerProvider.selectedTask!.name}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: AnimatedRotation(
                              turns: _isMinimized ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.expand_less,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            onPressed: _toggleMinimized,
                            tooltip: _isMinimized ? 'Expand' : 'Minimize',
                          ),
                        ],
                      ),
                    ),
                  
                  // Main content with animation
                  ClipRect(
                    child: AnimatedBuilder(
                      animation: _heightAnimation,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment.topCenter,
                          heightFactor: timerProvider.selectedTask != null 
                              ? _heightAnimation.value 
                              : 1.0,
                          child: Opacity(
                            opacity: timerProvider.selectedTask != null 
                                ? _opacityAnimation.value 
                                : 1.0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (timerProvider.selectedTask == null)
                                    Text(
                                      'Select Task',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  if (timerProvider.selectedTask == null)
                                    const SizedBox(height: 12),
                                  
                                  // Task dropdown
                                  DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    hint: const Text('Choose a task to time'),
                                    value: timerProvider.selectedTask?.id,
                                    isExpanded: true,
                                    items: taskProvider.tasks.map((task) {
                                      return DropdownMenuItem<int>(
                                        value: task.id,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                task.name,
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              task.formattedTotalTime,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: timerProvider.isRunning 
                                        ? null 
                                        : (int? taskId) {
                                            if (taskId != null) {
                                              final selectedTask = taskProvider.tasks.firstWhere(
                                                (task) => task.id == taskId,
                                              );
                                              timerProvider.setSelectedTask(selectedTask);
                                              
                                              // Auto-minimize after selection with delay
                                              if (!_isMinimized) {
                                                Future.delayed(const Duration(milliseconds: 300), () {
                                                  if (mounted) {
                                                    _toggleMinimized();
                                                  }
                                                });
                                              }
                                            }
                                          },
                                  ),
                                  
                                  // Timer type selector
                                  const SizedBox(height: 16),
                                  Text(
                                    'Timer Type',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SegmentedButton<TimerType>(
                                    segments: const [
                                      ButtonSegment<TimerType>(
                                        value: TimerType.stopwatch,
                                        label: Text('Stopwatch'),
                                        icon: Icon(Icons.timer_outlined),
                                      ),
                                      ButtonSegment<TimerType>(
                                        value: TimerType.pomodoro,
                                        label: Text('Pomodoro'),
                                        icon: Icon(Icons.access_time),
                                      ),
                                    ],
                                    selected: {timerProvider.timerType},
                                    onSelectionChanged: timerProvider.isRunning 
                                        ? null 
                                        : (Set<TimerType> selection) {
                                            timerProvider.setTimerType(selection.first);
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
