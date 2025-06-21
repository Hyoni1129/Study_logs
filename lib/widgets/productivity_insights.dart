import 'package:flutter/material.dart';
import '../models/study_session.dart';

class ProductivityInsights {
  static List<InsightCard> generateInsights(List<StudySession> sessions) {
    if (sessions.isEmpty) return [];
    
    // Calculate basic stats
    final totalSessions = sessions.length;
    final totalMinutes = sessions.fold<int>(
      0, 
      (sum, session) => sum + (session.durationInSeconds ~/ 60)
    );
    final avgSessionMinutes = totalMinutes / totalSessions;
    
    // Group sessions by date
    final sessionsByDate = <DateTime, List<StudySession>>{};
    for (final session in sessions) {
      final date = DateTime(
        session.dateCreated.year,
        session.dateCreated.month,
        session.dateCreated.day,
      );
      sessionsByDate.putIfAbsent(date, () => []).add(session);
    }
    
    final studyDays = sessionsByDate.length;
    final avgSessionsPerDay = totalSessions / studyDays;
    
    // Generate insights
    final potentialInsights = [
      _generateStreakInsight(sessionsByDate),
      _generateProductivityInsight(avgSessionMinutes),
      _generateConsistencyInsight(avgSessionsPerDay, studyDays),
      _generateWeeklyGoalInsight(totalMinutes),
    ];
    
    return potentialInsights.where((insight) => insight != null).cast<InsightCard>().toList();
  }
  
  static InsightCard? _generateStreakInsight(Map<DateTime, List<StudySession>> sessionsByDate) {
    if (sessionsByDate.isEmpty) return null;
    
    final sortedDates = sessionsByDate.keys.toList()..sort();
    int currentStreak = 0;
    int longestStreak = 0;
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check if user studied today or yesterday for current streak
    final studiedToday = sessionsByDate.containsKey(DateTime(today.year, today.month, today.day));
    final studiedYesterday = sessionsByDate.containsKey(DateTime(yesterday.year, yesterday.month, yesterday.day));
    
    if (studiedToday || studiedYesterday) {
      DateTime checkDate = studiedToday ? 
        DateTime(today.year, today.month, today.day) : 
        DateTime(yesterday.year, yesterday.month, yesterday.day);
      
      while (sessionsByDate.containsKey(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }
    
    // Calculate longest streak
    int tempStreak = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      if (sortedDates[i].difference(sortedDates[i-1]).inDays == 1) {
        tempStreak++;
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      } else {
        tempStreak = 1;
      }
    }
    longestStreak = longestStreak == 0 ? 1 : longestStreak;
    
    String title, message;
    IconData icon;
    Color color;
    
    if (currentStreak >= 7) {
      title = '🔥 Amazing Streak!';
      message = 'You\'ve studied for $currentStreak days in a row! Keep it up!';
      icon = Icons.local_fire_department;
      color = Colors.orange;
    } else if (currentStreak >= 3) {
      title = '⚡ Great Momentum!';
      message = '$currentStreak day streak! You\'re building a great habit.';
      icon = Icons.trending_up;
      color = Colors.green;
    } else if (currentStreak >= 1) {
      title = '👍 Good Start!';
      message = 'You studied today! Try to continue tomorrow.';
      icon = Icons.celebration;
      color = Colors.blue;
    } else {
      title = '💪 Ready to Start?';
      message = 'Your longest streak was $longestStreak days. You can do it again!';
      icon = Icons.restart_alt;
      color = Colors.grey;
    }
    
    return InsightCard(
      title: title,
      message: message,
      icon: icon,
      color: color,
    );
  }
  
  static InsightCard? _generateProductivityInsight(double avgSessionMinutes) {
    String title, message;
    IconData icon;
    Color color;
    
    if (avgSessionMinutes >= 45) {
      title = '🎯 Focus Master!';
      message = 'Your average session is ${avgSessionMinutes.round()} minutes. Excellent focus!';
      icon = Icons.psychology;
      color = Colors.purple;
    } else if (avgSessionMinutes >= 25) {
      title = '📚 Steady Learner';
      message = '${avgSessionMinutes.round()}-minute sessions are perfect for sustained learning.';
      icon = Icons.school;
      color = Colors.green;
    } else if (avgSessionMinutes >= 15) {
      title = '🚀 Quick Learner';
      message = 'Short ${avgSessionMinutes.round()}-minute bursts can be very effective!';
      icon = Icons.flash_on;
      color = Colors.blue;
    } else {
      title = '⏰ Try Longer Sessions';
      message = 'Consider extending sessions to 15+ minutes for deeper focus.';
      icon = Icons.timer;
      color = Colors.orange;
    }
    
    return InsightCard(
      title: title,
      message: message,
      icon: icon,
      color: color,
    );
  }
  
  static InsightCard? _generateConsistencyInsight(double avgSessionsPerDay, int studyDays) {
    if (studyDays < 3) return null;
    
    String title, message;
    IconData icon;
    Color color;
    
    if (avgSessionsPerDay >= 3) {
      title = '🌟 Super Consistent!';
      message = 'You average ${avgSessionsPerDay.toStringAsFixed(1)} sessions per study day!';
      icon = Icons.stars;
      color = Colors.amber;
    } else if (avgSessionsPerDay >= 2) {
      title = '✅ Great Consistency';
      message = 'You\'re maintaining ${avgSessionsPerDay.toStringAsFixed(1)} sessions per day on average.';
      icon = Icons.check_circle;
      color = Colors.green;
    } else {
      title = '📈 Building Habits';
      message = 'Try adding one more session on your study days for better progress.';
      icon = Icons.trending_up;
      color = Colors.blue;
    }
    
    return InsightCard(
      title: title,
      message: message,
      icon: icon,
      color: color,
    );
  }
  
  static InsightCard? _generateWeeklyGoalInsight(int totalMinutes) {
    final hoursThisWeek = totalMinutes / 60;
    const recommendedWeeklyHours = 10; // Recommended 10 hours per week
    
    String title, message;
    IconData icon;
    Color color;
    
    if (hoursThisWeek >= recommendedWeeklyHours) {
      title = '🏆 Goal Achieved!';
      message = 'You\'ve studied ${hoursThisWeek.toStringAsFixed(1)} hours this period!';
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (hoursThisWeek >= recommendedWeeklyHours * 0.7) {
      title = '🎯 Almost There!';
      message = '${hoursThisWeek.toStringAsFixed(1)}/${recommendedWeeklyHours}h - You\'re ${((recommendedWeeklyHours - hoursThisWeek) * 60).round()} minutes away!';
      icon = Icons.near_me;
      color = Colors.blue;
    } else {
      title = '💪 Keep Going!';
      message = 'Target: ${recommendedWeeklyHours}h/week. Current: ${hoursThisWeek.toStringAsFixed(1)}h';
      icon = Icons.fitness_center;
      color = Colors.orange;
    }
    
    return InsightCard(
      title: title,
      message: message,
      icon: icon,
      color: color,
    );
  }
}

class InsightCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const InsightCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
