import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isFromSettings;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.isFromSettings = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Study Logs',
      description: 'Track your study sessions and boost your productivity with our powerful timer system.\n\n📱 100% Free & Ad-Free Experience',
      image: Icons.school,
      color: Colors.blue,
      isWelcome: true,
    ),
    OnboardingPage(
      title: 'Manage Your Tasks',
      description: 'Create and organize your study tasks. Keep track of different subjects and projects effortlessly.',
      image: Icons.task_alt,
      color: Colors.green,
      interactive: true,
      interactiveHint: 'Tap the + button to create your first task!',
    ),
    OnboardingPage(
      title: 'Smart Timers',
      description: 'Use Stopwatch for open-ended study sessions or Pomodoro technique for focused productivity.',
      image: Icons.timer,
      color: Colors.orange,
      interactive: true,
      interactiveHint: 'Try starting a timer by tapping the play button!',
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      description: 'View detailed statistics and insights about your study habits with beautiful charts and analytics.',
      image: Icons.analytics,
      color: Colors.purple,
    ),
    OnboardingPage(
      title: 'Support Open Source',
      description: 'This app is completely free with no ads! If you find it helpful, consider supporting the developer.',
      image: Icons.favorite,
      color: Colors.red,
      showGitHubButton: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: List.generate(
                  _pages.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < _pages.length - 1 ? 8 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  // Next/Get Started/Done button
                  ElevatedButton(
                    onPressed: _currentPage < _pages.length - 1
                        ? _nextPage
                        : _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 
                          ? 'Next' 
                          : widget.isFromSettings 
                              ? 'Done' 
                              : 'Get Started',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with special styling for welcome page
          Container(
            width: page.isWelcome ? 140 : 120,
            height: page.isWelcome ? 140 : 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.image,
              size: page.isWelcome ? 70 : 60,
              color: page.color,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Interactive hint
          if (page.interactive && page.interactiveHint != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: page.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 20,
                    color: page.color,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      page.interactiveHint!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: page.color,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // GitHub button for support page
          if (page.showGitHubButton) ...[
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _launchGitHub,
              icon: const Icon(Icons.code),
              label: const Text('Visit GitHub'),
              style: OutlinedButton.styleFrom(
                foregroundColor: page.color,
                side: BorderSide(color: page.color),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '⭐ Star the project if데 like it!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _launchGitHub() async {
    const url = 'https://github.com/Hyoni1129/Study_logs'; // Replace with your actual GitHub URL
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _completeOnboarding() async {
    if (!widget.isFromSettings) {
      // Mark onboarding as completed only if not from settings
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    }
    
    widget.onComplete();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData image;
  final Color color;
  final bool isWelcome;
  final bool interactive;
  final String? interactiveHint;
  final bool showGitHubButton;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
    this.isWelcome = false,
    this.interactive = false,
    this.interactiveHint,
    this.showGitHubButton = false,
  });
}
