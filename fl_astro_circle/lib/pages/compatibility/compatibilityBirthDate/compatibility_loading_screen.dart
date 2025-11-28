import 'dart:math';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class CompatibilityLoadingScreen extends StatefulWidget {
  final String sign1Image;
  final String sign2Image;
  final String sign1Name;
  final String sign2Name;
  final VoidCallback onComplete;
  final Future<Map<String, String>>? contentFuture; // Future с генерацией контента

  const CompatibilityLoadingScreen({
    super.key,
    required this.sign1Image,
    required this.sign2Image,
    required this.sign1Name,
    required this.sign2Name,
    required this.onComplete,
    this.contentFuture,
  });

  @override
  State<CompatibilityLoadingScreen> createState() =>
      _CompatibilityLoadingScreenState();
}

class _CompatibilityLoadingScreenState extends State<CompatibilityLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;

  late Animation<double> _rotation1;
  late Animation<double> _rotation2;
  late Animation<double> _pulse;

  static const String _staticText = 'Request is being sent to space via satellites...';
  
  final List<String> _dynamicTexts = [
    'Analyzing star positions...',
    'Comparing astrological charts...',
    'Calculating compatibility...',
    'Generating cosmic insights...',
  ];
  int _currentTextIndex = 0;

  final List<_Sparkle> _sparkles = [];
  final Random _random = Random();
  
  double _displayProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotation1 = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _rotation2 = Tween<double>(begin: 2 * pi, end: 0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();

    _sparkleController.addListener(_generateSparkles);

    // Запускаем плавный прогресс и ожидание контента
    _startProgressAndWaitContent();
  }

  Future<void> _startProgressAndWaitContent() async {
    // Плавно увеличиваем прогресс до 90% пока ждём контент
    _animateProgressTo(0.9, const Duration(seconds: 3));
    
    // Ждём завершения генерации контента
    if (widget.contentFuture != null) {
      await widget.contentFuture;
    }
    
    // Быстро доводим до 100% и переходим
    await _animateProgressTo(1.0, const Duration(milliseconds: 300));
    
    // Небольшая пауза чтобы показать 100%
    await Future.delayed(const Duration(milliseconds: 200));
    
    widget.onComplete();
  }

  Future<void> _animateProgressTo(double target, Duration duration) async {
    final startProgress = _displayProgress;
    final startTime = DateTime.now();
    
    while (_displayProgress < target) {
      await Future.delayed(const Duration(milliseconds: 16)); // ~60fps
      if (!mounted) return;
      
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final t = (elapsed / duration.inMilliseconds).clamp(0.0, 1.0);
      
      setState(() {
        _displayProgress = startProgress + (target - startProgress) * t;
        
        // Update text based on progress
        int newIndex = (_displayProgress * _dynamicTexts.length).floor();
        if (newIndex >= _dynamicTexts.length) newIndex = _dynamicTexts.length - 1;
        _currentTextIndex = newIndex;
      });
      
      if (t >= 1.0) break;
    }
  }

  double get _scale => 1.0 - (_displayProgress * 0.3); // 1.0 -> 0.7

  void _generateSparkles() {
    if (_random.nextDouble() > 0.7) {
      setState(() {
        _sparkles.add(_Sparkle(
          x: _random.nextDouble() * 300 - 150,
          y: _random.nextDouble() * 300 - 150,
          size: _random.nextDouble() * 4 + 2,
          opacity: 1.0,
        ));

        // Remove old sparkles
        _sparkles.removeWhere((s) => s.opacity <= 0);
        for (var sparkle in _sparkles) {
          sparkle.opacity -= 0.05;
        }
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              primaryColor.withValues(alpha: 0.15),
              scaffoldBgColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildAnimatedSigns(),
              const Spacer(),
              _buildStaticText(),
              heightSpace,
              heightSpace,
              _buildProgressBar(),
              heightSpace,
              heightSpace,
              _buildDynamicText(),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSigns() {
    return SizedBox(
      height: 250,
      width: 300,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationController,
          _pulseController,
        ]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Sparkles
              ..._sparkles.map((sparkle) => Positioned(
                    left: 150 + sparkle.x,
                    top: 125 + sparkle.y,
                    child: Opacity(
                      opacity: sparkle.opacity.clamp(0.0, 1.0),
                      child: Container(
                        width: sparkle.size,
                        height: sparkle.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),

              // Orbital path
              CustomPaint(
                size: const Size(250, 250),
                painter: _OrbitPainter(
                  progress: _displayProgress,
                  color: primaryColor.withValues(alpha: 0.3),
                ),
              ),

              // Center glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 60 * _pulse.value,
                    height: 60 * _pulse.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.6),
                          primaryColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Heart in center
              Icon(
                Icons.favorite,
                color: redColor.withValues(alpha: 0.8),
                size: 30,
              ),

              // Sign 1 - orbiting
              Transform.translate(
                offset: Offset(
                  100 * cos(_rotation1.value) * _scale,
                  60 * sin(_rotation1.value) * _scale,
                ),
                child: Transform.rotate(
                  angle: _rotation1.value * 0.5,
                  child: _buildSignWidget(widget.sign1Image, widget.sign1Name),
                ),
              ),

              // Sign 2 - orbiting opposite
              Transform.translate(
                offset: Offset(
                  100 * cos(_rotation2.value) * _scale,
                  60 * sin(_rotation2.value) * _scale,
                ),
                child: Transform.rotate(
                  angle: -_rotation2.value * 0.5,
                  child: _buildSignWidget(widget.sign2Image, widget.sign2Name),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSignWidget(String image, String name) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: blueShade1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            image,
            height: 45,
            width: 45,
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: whiteColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        _staticText,
        style: const TextStyle(
          color: whiteColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDynamicText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Text(
          _dynamicTexts[_currentTextIndex],
          key: ValueKey(_currentTextIndex),
          style: const TextStyle(
            color: greyColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _displayProgress,
              backgroundColor: blueShade1,
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 8,
            ),
          ),
          heightSpace,
          Text(
            '${(_displayProgress * 100).toInt()}%',
            style: const TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sparkle {
  double x;
  double y;
  double size;
  double opacity;

  _Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });
}

class _OrbitPainter extends CustomPainter {
  final double progress;
  final Color color;

  _OrbitPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw elliptical orbit
    final rect = Rect.fromCenter(
      center: center,
      width: 200,
      height: 120,
    );
    canvas.drawOval(rect, paint);

    // Draw inner orbit
    final innerRect = Rect.fromCenter(
      center: center,
      width: 100,
      height: 60,
    );
    canvas.drawOval(innerRect, paint..strokeWidth = 1.0);

    // Draw connecting lines based on progress
    if (progress > 0.5) {
      final connectPaint = Paint()
        ..color = primaryColor.withValues(alpha: (progress - 0.5) * 2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int i = 0; i < 8; i++) {
        final angle = i * pi / 4;
        final start = Offset(
          center.dx + 30 * cos(angle),
          center.dy + 30 * sin(angle),
        );
        final end = Offset(
          center.dx + 50 * cos(angle),
          center.dy + 30 * sin(angle),
        );
        canvas.drawLine(start, end, connectPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
