import 'dart:math';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class CosmicBackground extends StatefulWidget {
  final Widget? child;
  const CosmicBackground({super.key, this.child});

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _generateStars();
  }

  void _generateStars() {
    for (int i = 0; i < 50; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2 + 0.5,
        opacity: _random.nextDouble(),
        speed: _random.nextDouble() * 0.2 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(
          decoration: const BoxDecoration(
            color: scaffoldBgColor, // Matches the app theme
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0C0332), // Deep Blue
                Color(0xFF050118), // Darker towards bottom
              ],
            ),
          ),
        ),
        // Animated Stars
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: StarPainter(_stars, _controller.value),
              size: Size.infinite,
            );
          },
        ),
        // Child content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class Star {
  double x;
  double y;
  final double size;
  final double opacity;
  final double speed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
  });
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double progress;

  StarPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      // Simulating movement
      // We can use a sine wave for twinkling opacity
      final twinkle = (sin((progress * 2 * pi * star.speed) + (star.x * 10)) + 1) / 2; 
      final currentOpacity = (star.opacity * 0.5 + 0.2) + (twinkle * 0.3);

      paint.color = Colors.white.withOpacity(currentOpacity.clamp(0.0, 1.0));
      
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
