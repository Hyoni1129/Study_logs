import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> showPomodoroCompleteNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pomodoro_timer',
      'Pomodoro Timer',
      channelDescription: 'Notifications for Pomodoro timer completions',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> showStudySessionCompleteNotification({
    required String taskName,
    required String duration,
  }) async {
    await showPomodoroCompleteNotification(
      title: 'Study Session Complete! 🎉',
      body: 'You completed $duration of studying on "$taskName"',
      payload: 'session_complete',
    );
  }

  Future<void> showPomodoroFocusCompleteNotification() async {
    await showPomodoroCompleteNotification(
      title: 'Focus Session Complete! 🍅',
      body: 'Great job! Time for a well-deserved break.',
      payload: 'pomodoro_focus_complete',
    );
  }

  Future<void> showPomodoroBreakCompleteNotification() async {
    await showPomodoroCompleteNotification(
      title: 'Break Time Over! ⏰',
      body: 'Ready to get back to work? Let\'s start another focus session.',
      payload: 'pomodoro_break_complete',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap
    // You can navigate to specific screens based on payload
    debugPrint('Notification tapped with payload: ${notificationResponse.payload}');
  }
}
