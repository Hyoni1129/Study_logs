# 📚 Study Logs - iOS Study Tracker

<div align="center">
  <img src="assets/icons/app_icon.png" alt="Study Logs Icon" width="120" height="120">
  
  <p><em>Track your study habits with elegant, Apple-style design</em></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)](https://www.apple.com/ios)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
</div>

## 🌟 Overview

**Study Logs** is a beautifully designed iOS study tracker that empowers users to monitor their study habits through stopwatch and Pomodoro timers. Built with Flutter, it provides elegant Apple-style data visualizations to help users understand their study patterns and stay motivated.

## ✨ Features

### 📋 Task Management
- **Create & Manage Tasks**: Add, edit, and delete custom study tasks (e.g., "Study English," "Practice Coding," "Read History")
- **Intuitive Task List**: Clean, organized list for easy task selection before starting timers
- **Real-time Progress**: Track total time spent on each task with automatic updates

### ⏱️ Time Tracking
- **Task Selection**: Associate study sessions with specific tasks for detailed tracking
- **Stopwatch Timer**: Standard count-up timer that runs until manually stopped
- **Pomodoro Timer**: Fully customizable Pomodoro Technique implementation
  - Default: 25-minute focus, 5-minute short break, 15-minute long break
  - Customizable durations for all timer phases
  - Automatic session logging upon completion
- **Real-time Display**: Live elapsed/remaining time updates with beautiful animations

### 📊 Statistics & Analytics
- **Apple-style Data Visualization**: Clean, modern charts powered by fl_chart
- **Multi-period Views**: 
  - **Daily**: Breakdown of study hours per task for the current day
  - **Weekly**: Summary of study hours per task over the current week  
  - **Monthly**: Monthly overview of study hours per task
  - **All Time**: Complete historical data analysis
- **Visual Insights**:
  - **Pie Charts**: Study time distribution across tasks
  - **Bar Charts**: Comparative analysis of task performance
  - **Study Days Counter**: Track consistency with unique study days
- **Interactive Charts**: Touch interactions with detailed data popups

## 🎨 Design Philosophy

### Visual Excellence
- **Apple Human Interface Guidelines**: Native iOS feel with premium design
- **SF Pro Font Family**: Authentic iOS typography
- **Brand Color Palette**: Beautiful gradients using `#40a9da` and complementary shades
- **Smooth Animations**: Polished transitions and micro-interactions
- **Card-based UI**: Clean, modern interface with elegant shadows and gradients

### User Experience
- **Minimalist Design**: Uncluttered interface focused on ease of use
- **Intuitive Navigation**: Simple 3-tab structure for effortless access
- **Responsive Layout**: Optimized for various iOS screen sizes
- **Dark/Light Mode**: Automatic theme adaptation

## 🛠️ Technical Stack

- **Framework**: Flutter 3.8+
- **Language**: Dart
- **State Management**: Provider pattern for reactive UI updates
- **Database**: SQLite with sqflite for local data persistence
- **Charts**: fl_chart for beautiful, customizable data visualizations
- **Platform**: iOS (with potential for cross-platform expansion)

## 📱 App Architecture

### Navigation Structure
```
├── 📊 Timer (Home)
│   ├── Task Selection Dropdown
│   ├── Stopwatch Controls
│   └── Pomodoro Timer Interface
├── 📝 Tasks
│   ├── Task Creation & Management
│   ├── Total Time Tracking
│   └── Task Organization
└── 📈 Statistics
    ├── Period Selection (Daily/Weekly/Monthly/All Time)
    ├── Interactive Charts
    └── Study Insights
```

### Core Components
- **TimerProvider**: Manages timer state, session tracking, and data persistence
- **TaskProvider**: Handles task CRUD operations and total time calculations
- **StatisticsProvider**: Processes study data and generates analytics
- **DatabaseHelper**: SQLite operations with automatic schema management

## 🚀 Getting Started

### Prerequisites
- Flutter 3.8.1 or higher
- iOS 12.0+ target device or simulator
- Xcode 14+ for iOS development

### Setup
```bash
# Clone the repository
git clone https://github.com/your-username/study-logs.git

# Navigate to project directory
cd study-logs

# Install dependencies
flutter pub get

# Run on iOS simulator
flutter run
```

## 🎯 App Store Ready

Study Logs is production-ready with:

- ✅ **Professional UI/UX**: Apple-standard design and interactions
- ✅ **Performance Optimized**: Smooth 60fps animations and efficient memory usage
- ✅ **Data Accuracy**: Reliable time tracking and statistics calculation
- ✅ **Error Handling**: Graceful error states and user feedback
- ✅ **Accessibility**: Full VoiceOver and Dynamic Type support
- ✅ **Testing**: Comprehensive unit and integration test coverage

## 👨‍💻 Developer

**JeongHan Lee**
- Email: Team.Stella.Global@gmail.com

## 📄 License

This project is licensed under the MIT License.

---

<div align="center">
  <p>Made with ❤️ for students everywhere</p>
  <p><strong>Study smarter, not harder</strong></p>
</div>

The app is fully functional and ready for user testing with professional-grade features and design.

---

*Study Logs helps you build better study habits with beautiful, intuitive design and powerful tracking features.*
# Study_logs
