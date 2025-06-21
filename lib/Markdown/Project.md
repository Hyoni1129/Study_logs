Project Overview: iOS Study Log Tracker
1. Introduction
This document outlines the project plan for a Flutter-based iOS application designed as a study log tracker. The app will empower users to monitor their study habits by tracking time spent on specific tasks using stopwatch and Pomodoro timers. It will also provide insightful statistics through elegant, Apple-style data visualizations, helping users understand their study patterns and stay motivated.

2. Core Features
2.1. Task Management
Create & Manage Tasks: Users can create, edit, and delete custom study tasks (e.g., "Study English," "Practice Coding," "Read History").

Task List: A clear, intuitive list will display all created tasks for easy selection before starting a timer.

2.2. Time Tracking
Task Selection: Before starting a timer, the user must select a task from their list to associate the study session with it.

Stopwatch: A standard count-up timer that runs until the user manually stops it. The elapsed time is recorded and logged for the selected task.

Pomodoro Timer: A customizable timer based on the Pomodoro Technique.

Default settings: 25-minute focus session, 5-minute short break, 15-minute long break.

Users can customize the duration of focus sessions and breaks.

Completed Pomodoro sessions are automatically logged for the selected task.

Real-time Display: The active timer will display the elapsed or remaining time in real-time.

2.3. Statistics & Analytics
Data Visualization: The app will feature a dedicated statistics page with clean, Apple-style charts and graphs to present study data.

Time-based Filtering: Users can view their study data aggregated by:

Daily: A breakdown of study hours per task for the current day.

Weekly: A summary of study hours per task over the current week.

Monthly: A monthly overview of study hours per task.

Task-based Analytics:

Top Tasks: A visual representation (e.g., a bar chart) highlighting the tasks with the most accumulated study time.

Total Study Time per Task: A separate view that shows the all-time total hours logged for each task (e.g., "English: 120 hours," "Engineering Math: 140 hours").

3. App Architecture & Navigation
The app will be structured around a simple and intuitive TabBar navigation at the bottom of the screen.

Screen 1: Timer (Home)

This will be the main screen.

It will feature the task selection dropdown/menu.

It will house the Stopwatch and Pomodoro timer controls.

The visual design will be clean and focused to minimize distractions.

Screen 2: Tasks

A list of all user-created tasks.

Functionality to add, edit, or delete tasks.

Screen 3: Statistics

The dashboard for all data visualizations.

Tabs or segmented controls to switch between Daily, Weekly, and Monthly views.

Clear charts displaying study time per task and total time comparisons.

4. Visual Design & User Experience (UX)
Aesthetic: The design will adhere to Apple's Human Interface Guidelines to ensure a native, polished, and premium feel. This includes using SF Pro fonts, appropriate padding, and clean visual elements.

Graphs & Charts: We will use a library like fl_chart in Flutter to create beautiful and animated charts that feel responsive and modern.

Bar Charts: For comparing total study times across different tasks.

Pie Charts or Donut Charts: To show the proportion of study time dedicated to each task within a specific period (day, week, month).

Clarity & Simplicity: The UI will be uncluttered and intuitive, allowing users to start tracking their study sessions with minimal friction. The focus is on ease of use and clear data presentation.

5. Technical Stack
Framework: Flutter

Language: Dart

State Management: Provider or Riverpod (for managing app state, like the active timer and task selection).

Database: A local database solution like sqflite or Hive will be used to persistently store user tasks and study logs on the device.

Charts Library: fl_chart for its high degree of customization and elegant aesthetics.

Icons: A clean icon set that matches the iOS style.