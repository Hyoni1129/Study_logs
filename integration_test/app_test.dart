import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:studylogs/main_new.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('StudyLogs Integration Tests', () {
    testWidgets('Complete user flow: onboarding, task creation, timer usage', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Check if onboarding screen appears for first-time users
      // If onboarding is shown, complete it
      if (find.text('Welcome to Study Logs').evaluate().isNotEmpty) {
        // Navigate through onboarding
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }

      // Verify we're on the main screen
      expect(find.text('Study Timer'), findsOneWidget);

      // Navigate to Tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Create a new task if none exist
      if (find.text('No tasks yet').evaluate().isNotEmpty) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Test Study Task');
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();
      }

      // Verify task was created
      expect(find.text('Test Study Task'), findsOneWidget);

      // Navigate back to Timer tab
      await tester.tap(find.text('Timer'));
      await tester.pumpAndSettle();

      // Select the task for timing
      await tester.tap(find.text('Select a task'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Study Task'));
      await tester.pumpAndSettle();

      // Verify task is selected
      expect(find.text('Test Study Task'), findsOneWidget);

      // Start the timer
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Wait a moment to let timer run
      await tester.pump(const Duration(seconds: 2));

      // Stop the timer
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // Navigate to Statistics tab
      await tester.tap(find.text('Statistics'));
      await tester.pumpAndSettle();

      // Verify we can see statistics (even if minimal)
      expect(find.text('Statistics'), findsOneWidget);

      // Test period selection
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
    });

    testWidgets('Timer type switching and settings', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if shown
      if (find.text('Get Started').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }

      // Test timer type switching
      await tester.tap(find.text('Pomodoro'));
      await tester.pumpAndSettle();

      expect(find.text('25:00'), findsOneWidget); // Default 25 minute timer

      await tester.tap(find.text('Stopwatch'));
      await tester.pumpAndSettle();

      expect(find.text('00:00'), findsOneWidget); // Stopwatch starts at 0

      // Open settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });

    testWidgets('Task CRUD operations', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if shown
      if (find.text('Get Started').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }

      // Navigate to Tasks
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Create a task
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Integration Test Task');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify task creation
      expect(find.text('Integration Test Task'), findsOneWidget);

      // Edit the task (if edit functionality exists)
      await tester.longPress(find.text('Integration Test Task'));
      await tester.pumpAndSettle();

      // Delete the task (if delete functionality exists) 
      if (find.byIcon(Icons.delete).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();
        
        // Confirm deletion if dialog appears
        if (find.text('Delete').evaluate().isNotEmpty) {
          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
