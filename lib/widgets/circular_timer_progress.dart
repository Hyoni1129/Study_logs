import 'dart:math';
import 'package:flutter/material.dart';

class CircularTimerProgress extends StatefulWidget {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;
  final double size;
  final Widget? child;

  const CircularTimerProgress({
    super.key,
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    this.strokeWidth = 6.0,
    this.size = 200.0,
    this.child,
  });

  @override
  State<CircularTimerProgress> createState() => _CircularTimerProgressState();
}

class _CircularTimerProgressState extends State<CircularTimerProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CircularTimerProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: widget.strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(widget.backgroundColor),
            ),
          ),
          // Progress circle
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: Transform.rotate(
                  angle: -pi / 2, // Start from top
                  child: CircularProgressIndicator(
                    value: _animation.value,
                    strokeWidth: widget.strokeWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              );
            },
          ),
          // Child widget (timer text, etc.)
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}
