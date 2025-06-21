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
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      expect(find.text('Tasks'), findsOneWidget);

      // Test navigation to Statistics tab
      await tester.tap(find.text('Statistics'));
      await tester.pumpAndSettle();
      expect(find.text('Statistics'), findsOneWidget);

      // Test navigation back to Timer tab
      await tester.tap(find.text('Timer'));
      await tester.pumpAndSettle();
      expect(find.text('Study Timer'), findsOneWidget);
    });
  });

  group('Task Provider Tests', () {
    test('Should add task successfully', () async {
      final taskProvider = TaskProvider();
      
      // Initialize the provider
      await taskProvider.initialize();
      
      // Add a task
      final success = await taskProvider.addTask('Test Task');
      expect(success, true);
      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks.first.name, 'Test Task');
    });

    test('Should not add duplicate task names', () async {
      final taskProvider = TaskProvider();
      await taskProvider.initialize();
      
      // Add first task
      await taskProvider.addTask('Test Task');
      
      // Try to add duplicate
      final success = await taskProvider.addTask('Test Task');
      expect(success, false);
      expect(taskProvider.tasks.length, 1);
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
