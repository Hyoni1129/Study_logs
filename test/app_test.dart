import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studylogs/main.dart';
import 'package:studylogs/providers/task_provider.dart';
import 'package:studylogs/providers/timer_provider.dart';

void main() {
  group('StudyLogs App Tests', () {
    testWidgets('App should launch without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const StudyLogsApp());

      // Verify that the app starts with the timer screen
      expect(find.text('Study Timer'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('Should navigate between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const StudyLogsApp());
      
      // Wait for initialization
      await tester.pumpAndSettle();

      // Test navigation to Tasks tab
      await tester.tap(find.byIcon(Icons.task_alt_outlined));
      await tester.pumpAndSettle();
      
      // Test navigation to Statistics tab
      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pumpAndSettle();

      // Test navigation back to Timer tab
      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pumpAndSettle();
    });
  });

  group('Task Provider Tests', () {
    test('Should initialize with correct defaults', () {
      final taskProvider = TaskProvider();
      
      expect(taskProvider.tasks.length, 0);
      expect(taskProvider.selectedTask, null);
      expect(taskProvider.isLoading, false);
      expect(taskProvider.hasTasks, false);
    });
  });

  group('Timer Provider Tests', () {
    test('Should initialize with correct defaults', () {
      final timerProvider = TimerProvider();
      
      expect(timerProvider.timerType, TimerType.stopwatch);
      expect(timerProvider.timerState, TimerState.stopped);
      expect(timerProvider.elapsedSeconds, 0);
      expect(timerProvider.focusDuration, 25 * 60); // 25 minutes
      expect(timerProvider.shortBreakDuration, 5 * 60); // 5 minutes
      expect(timerProvider.longBreakDuration, 15 * 60); // 15 minutes
    });

    test('Should change timer type', () {
      final timerProvider = TimerProvider();
      
      timerProvider.setTimerType(TimerType.pomodoro);
      expect(timerProvider.timerType, TimerType.pomodoro);
      
      timerProvider.setTimerType(TimerType.stopwatch);
      expect(timerProvider.timerType, TimerType.stopwatch);
    });
  });
}
