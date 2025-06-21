import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/statistics_provider.dart';
import 'timer_screen.dart';
import 'tasks_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _tabAnimationController;
  late Animation<double> _tabAnimation;
  
  final List<Widget> _screens = [
    const TimerScreen(),
    const TasksScreen(),
    const StatisticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Longer for smoother animations
      vsync: this,
    );
    
    _tabAnimation = CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeInOutCubic, // More elegant curve
    );
    
    // Start the initial animation
    _tabAnimationController.forward();
    
    // Initialize providers after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeProviders() async {
    // Capture providers before async operations
    final taskProvider = context.read<TaskProvider>();
    final statisticsProvider = context.read<StatisticsProvider>();
    final timerProvider = context.read<TimerProvider>();
    
    // Initialize providers when the app starts
    await taskProvider.initialize();
    await statisticsProvider.initialize();
    
    // Set up callback for automatic statistics refresh after session save
    timerProvider.setSessionSavedCallback(() {
      statisticsProvider.refresh();
    });
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      
      // Restart animation for smooth transition
      _tabAnimationController.reset();
      _tabAnimationController.forward();
      
      // Animate page transition with custom curve
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400), // Slightly longer for smoother feel
        curve: Curves.easeInOutCubic, // More elegant curve
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: _screens.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _tabAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _tabAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_tabAnimation),
                  child: _screens[index],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'Log',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Statistics',
            ),
          ],
        ),
      ),
    );
  }
}
