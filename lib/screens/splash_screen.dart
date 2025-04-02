import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: OrbitalPainter(
                    progress: _controller.value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OrbitalPainter extends CustomPainter {
  final double progress;

  OrbitalPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw central WE icon
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'WE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // Draw orbiting profile images
    final orbitRadius = radius * 1.5;
    const orbitCount = 3;
    const orbitSpeed = 2 * math.pi / orbitCount;

    for (var i = 0; i < orbitCount; i++) {
      final angle = progress * 2 * math.pi + i * orbitSpeed;
      final x = center.dx + orbitRadius * math.cos(angle);
      final y = center.dy + orbitRadius * math.sin(angle);

      // Draw orbit path
      final orbitPaint = Paint()
        ..color = Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 51)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, orbitRadius, orbitPaint);

      // Draw profile image placeholder
      final profilePaint = Paint()
        ..color = Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 204)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 20, profilePaint);
    }
  }

  @override
  bool shouldRepaint(OrbitalPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
} 