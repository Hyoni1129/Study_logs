import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/timer_provider.dart';

class TaskSelector extends StatelessWidget {
  const TaskSelector({super.key});

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

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Task',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                            final selectedTask = taskProvider.getTaskById(taskId);
                            timerProvider.setSelectedTask(selectedTask);
                          }
                        },
                ),
                
                // Selected task info
                if (timerProvider.selectedTask != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Total time logged: ${timerProvider.selectedTask!.formattedTotalTime}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Timer disabled warning
                if (timerProvider.isRunning) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Task selection is locked while timer is running',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Error display
                if (timerProvider.error != null) ...[
                  const SizedBox(height: 12),
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
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            timerProvider.error!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => timerProvider.clearError(),
                          icon: const Icon(Icons.close, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
