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
  final List<ShootingStar> _shootingStars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Controls the star twinkle cycle
    )..repeat();
    _generateStars();
    
    // Periodically spawn shooting stars
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 3000 + _random.nextInt(5000))); // Random 3-8s
      if (mounted) {
        _spawnShootingStar();
      }
      return mounted;
    });
  }

  void _generateStars() {
    _stars.clear();
    for (int i = 0; i < 60; i++) { // Increased star count
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2 + 1.0, // Slightly bigger
        opacity: _random.nextDouble(),
        speed: _random.nextDouble() * 5 + 2, // Faster twinkling (2-7 cycles)
      ));
    }
  }

  void _spawnShootingStar() {
    // Start from top or left
    double startX = _random.nextDouble();
    double startY = _random.nextDouble() * 0.5; // Top half
    
    // Direction mostly down-right
    double angle = pi / 4 + (_random.nextDouble() - 0.5) * 0.2; 
    
    setState(() {
      _shootingStars.add(ShootingStar(
        x: startX,
        y: startY,
        length: 50.0 + _random.nextDouble() * 50,
        angle: angle,
        speed: 1.5 + _random.nextDouble(), // Screen fraction per second
        startTime: DateTime.now(),
      ));
    });
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
            color: scaffoldBgColor, 
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
            // Update shooting stars
            final now = DateTime.now();
            _shootingStars.removeWhere((s) => 
                now.difference(s.startTime).inMilliseconds > 1500); // Remove after 1.5s

            return CustomPaint(
              painter: StarPainter(_stars, _shootingStars, _controller.value),
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
  final double speed; // Frequency of twinkle

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
  });
}

class ShootingStar {
  final double x;
  final double y;
  final double length;
  final double angle;
  final double speed;
  final DateTime startTime;

  ShootingStar({
    required this.x,
    required this.y,
    required this.length,
    required this.angle,
    required this.speed,
    required this.startTime,
  });
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final List<ShootingStar> shootingStars;
  final double progress;

  StarPainter(this.stars, this.shootingStars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    // Draw static twinkling stars
    for (var star in stars) {
      // Use full 2*pi range multiple times based on speed
      // progress goes 0->1 in 10s. 
      // speed ~5 means 5 cycles in 10s => 1 cycle per 2s.
      final t = (progress * 2 * pi * star.speed) + (star.x * 10);
      final wave = sin(t); // -1 to 1
      final twinkle = (wave + 1) / 2; // 0 to 1
      
      // Opacity varies between 0.3 and 1.0
      final currentOpacity = 0.3 + (twinkle * 0.7);

      paint.color = Colors.white.withOpacity(currentOpacity.clamp(0.0, 1.0));
      
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }

    // Draw shooting stars
    final now = DateTime.now();
    for (var shoot in shootingStars) {
        final age = now.difference(shoot.startTime).inMilliseconds / 1000.0; // Seconds alive
        if (age < 0) continue;
        
        final dist = shoot.speed * age;
        final dx = cos(shoot.angle) * dist * size.width; // Scale movement by width
        final dy = sin(shoot.angle) * dist * size.height; // Scale movement by height (approx)

        final startX = shoot.x * size.width + dx;
        final startY = shoot.y * size.height + dy;

        // Tail
        final tailDx = cos(shoot.angle) * shoot.length;
        final tailDy = sin(shoot.angle) * shoot.length;
        
        // Fade out as it flies
        double opacity = (1.0 - (age / 1.0)).clamp(0.0, 1.0); 

        final trailPaint = Paint()
          ..shader = LinearGradient(
            colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(opacity)],
            stops: const [0.0, 1.0],
          ).createShader(Rect.fromPoints(
            Offset(startX - tailDx, startY - tailDy), 
            Offset(startX, startY)
          ))
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
           Offset(startX - tailDx, startY - tailDy),
           Offset(startX, startY),
           trailPaint,
        );
        
        // Head
        paint.color = Colors.white.withOpacity(opacity);
        canvas.drawCircle(Offset(startX, startY), 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
