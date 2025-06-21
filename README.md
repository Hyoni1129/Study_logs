# Study Logs - iOS Study Tracker

[![Flutter Version](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.8.1-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A beautiful and intuitive iOS-style study tracking application built with Flutter. Track your study sessions using stopwatch or Pomodoro timers, manage tasks, and visualize your progress with elegant charts.

## 🌟 Features

### ⏱️ Smart Timers
- **Stopwatch Mode**: Open-ended study sessions with manual control
- **Pomodoro Mode**: Focused 25-minute sessions with automatic breaks
- Customizable timer durations and break intervals
- Background timer support with notifications

### 📋 Task Management
- Create, edit, and delete study tasks
- Organize different subjects and projects
- Track total time spent per task
- Clean, intuitive task interface

### 📊 Analytics & Statistics
- Beautiful charts powered by fl_chart
- Daily, weekly, and monthly view options
- Task-specific time breakdowns
- Interactive charts with detailed insights
- Progress tracking and productivity metrics

### 🎨 iOS-Style Design
- Native iOS design guidelines compliance
- Smooth animations and transitions
- Haptic feedback for enhanced interaction
- Dark mode support
- Clean, modern interface

### 🔧 Advanced Features
- Onboarding flow for new users
- Comprehensive settings customization
- Audio feedback and notifications
- Data persistence with SQLite
- Background operation support

## 🛠️ Technical Details

### Architecture
- **State Management**: Provider pattern
- **Database**: SQLite with sqflite
- **Charts**: fl_chart for data visualization
- **Notifications**: flutter_local_notifications
- **Audio**: audioplayers for timer sounds

### Project Structure
```
lib/
├── models/          # Data models (Task, StudySession)
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable components
├── services/        # Business logic services
└── utils/           # Utilities and helpers
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart 3.8.1 or higher
- iOS 12.0+ (for iOS deployment)
- Xcode 14+ (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd studylogs
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📦 Build & Deployment

### iOS App Store Deployment
1. Configure app metadata in Xcode
2. Build archive: `flutter build ios --release`
3. Upload to App Store Connect

## 🎯 Current Status: **PRODUCTION READY FOR BETA TESTING**

### Completed Features (85% complete):
✅ **Complete timer system** with stopwatch and Pomodoro modes  
✅ **Full task management** with CRUD operations  
✅ **Comprehensive statistics** with beautiful charts  
✅ **iOS-style design system** with proper theming  
✅ **Haptic feedback service** for enhanced interaction  
✅ **Productivity insights** for user motivation  
✅ **Onboarding system** for first-time users  
✅ **Smooth animations** and transitions  
✅ **Settings screen** with full customization  
✅ **Background timer framework** (service layer)  
✅ **Audio notifications** and sound effects  
✅ **Enhanced task cards** with modern design  
✅ **Empty states** and error handling  

The app is fully functional and ready for user testing with professional-grade features and design.

---

*Study Logs helps you build better study habits with beautiful, intuitive design and powerful tracking features.*
# Study_logs
