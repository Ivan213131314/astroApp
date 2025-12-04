import 'dart:math';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class NatalChartLoadingScreen extends StatefulWidget {
  final String name;
  final DateTime dateOfBirth;
  final String? timeOfBirth;
  final String? location;
  final Future<Map<String, dynamic>> calculationFuture;
  final VoidCallback onComplete;

  const NatalChartLoadingScreen({
    super.key,
    required this.name,
    required this.dateOfBirth,
    this.timeOfBirth,
    this.location,
    required this.calculationFuture,
    required this.onComplete,
  });

  @override
  State<NatalChartLoadingScreen> createState() => _NatalChartLoadingScreenState();
}

class _NatalChartLoadingScreenState extends State<NatalChartLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _satelliteController;
  late AnimationController _planetController;

  late Animation<double> _rotation;
  late Animation<double> _pulse;
  late Animation<double> _satelliteRotation;
  late Animation<double> _planetRotation;

  static const String _staticText =
      'Connecting to the Universe via cosmic satellites...';

  final List<String> _dynamicTexts = [
    'Scanning star positions...',
    'Calculating planetary alignments...',
    'Reading cosmic energy patterns...',
    'Analyzing your birth chart...',
    'Receiving celestial wisdom...',
  ];
  int _currentTextIndex = 0;

  final List<_Sparkle> _sparkles = [];
  final List<_Satellite> _satellites = [];
  final List<_Planet> _planets = [];
  final Random _random = Random();

  double _displayProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _initSatellites();
    _initPlanets();

    // Rotation animation for center
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Satellite rotation
    _satelliteController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _satelliteRotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _satelliteController, curve: Curves.linear),
    );

    // Planet rotation (slower)
    _planetController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _planetRotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _planetController, curve: Curves.linear),
    );

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();

    _sparkleController.addListener(_generateSparkles);

    _startProgressAndWaitContent();
  }

  void _initSatellites() {
    _satellites.addAll([
      _Satellite(orbitRadius: 80, speed: 1.2, startAngle: 0),
      _Satellite(orbitRadius: 105, speed: 0.8, startAngle: pi * 0.5),
      _Satellite(orbitRadius: 130, speed: 0.5, startAngle: pi),
    ]);
  }

  void _initPlanets() {
    // Создаём планеты на разных орбитах
    _planets.addAll([
      _Planet(orbitRadius: 55, speed: 0.3, startAngle: 0, color: Colors.orange, size: 7, name: '☉'), // Sun
      _Planet(orbitRadius: 68, speed: 0.5, startAngle: pi * 0.3, color: Colors.grey, size: 4, name: '☿'), // Mercury
      _Planet(orbitRadius: 82, speed: 0.4, startAngle: pi * 0.7, color: Colors.pink[200]!, size: 5, name: '♀'), // Venus
      _Planet(orbitRadius: 95, speed: 0.35, startAngle: pi * 1.2, color: Colors.red, size: 5, name: '♂'), // Mars
      _Planet(orbitRadius: 110, speed: 0.2, startAngle: pi * 1.5, color: Colors.amber, size: 8, name: '♃'), // Jupiter
      _Planet(orbitRadius: 125, speed: 0.15, startAngle: pi * 1.8, color: Colors.yellow[700]!, size: 7, name: '♄'), // Saturn
    ]);
  }

  Future<void> _startProgressAndWaitContent() async {
    _animateProgressTo(0.85, const Duration(seconds: 5));

    try {
      await widget.calculationFuture;
    } catch (e) {
      debugPrint('Content generation error (handled): $e');
    }

    await _animateProgressTo(1.0, const Duration(milliseconds: 400));
    await Future.delayed(const Duration(milliseconds: 300));

    widget.onComplete();
  }

  Future<void> _animateProgressTo(double target, Duration duration) async {
    final startProgress = _displayProgress;
    final startTime = DateTime.now();

    while (_displayProgress < target) {
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted) return;

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final t = (elapsed / duration.inMilliseconds).clamp(0.0, 1.0);

      setState(() {
        _displayProgress = startProgress + (target - startProgress) * t;

        int newIndex = (_displayProgress * _dynamicTexts.length).floor();
        if (newIndex >= _dynamicTexts.length) {
          newIndex = _dynamicTexts.length - 1;
        }
        _currentTextIndex = newIndex;
      });

      if (t >= 1.0) break;
    }
  }

  void _generateSparkles() {
    if (_random.nextDouble() > 0.6) {
      setState(() {
        _sparkles.add(_Sparkle(
          x: _random.nextDouble() * 340 - 170,
          y: _random.nextDouble() * 340 - 170,
          size: _random.nextDouble() * 3 + 1,
          opacity: 1.0,
        ));

        _sparkles.removeWhere((s) => s.opacity <= 0);
        for (var sparkle in _sparkles) {
          sparkle.opacity -= 0.04;
        }
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    _satelliteController.dispose();
    _planetController.dispose();
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
            radius: 1.5,
            colors: [
              primaryColor.withValues(alpha: 0.2),
              const Color(0xFF1a0a3e),
              scaffoldBgColor,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.08),
                      _buildAnimatedChart(),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      _buildStaticText(),
                      heightSpace,
                      heightSpace,
                      _buildProgressBar(),
                      heightSpace,
                      heightSpace,
                      _buildDynamicText(),
                      SizedBox(height: constraints.maxHeight * 0.08),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedChart() {
    return SizedBox(
      height: 320,
      width: 320,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationController,
          _pulseController,
          _satelliteController,
          _planetController,
        ]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Stars background
              ..._sparkles.asMap().entries.map((entry) => Positioned(
                    key: ValueKey('sparkle_${entry.key}_${entry.value.x.toStringAsFixed(2)}_${entry.value.y.toStringAsFixed(2)}'),
                    left: 160 + entry.value.x,
                    top: 160 + entry.value.y,
                    child: Opacity(
                      opacity: entry.value.opacity.clamp(0.0, 1.0),
                      child: Container(
                        width: entry.value.size,
                        height: entry.value.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),

              // Zodiac wheel (outer ring)
              Transform.rotate(
                angle: _rotation.value * 0.1,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: _ZodiacWheelPainter(
                    progress: _displayProgress,
                  ),
                ),
              ),

              // Orbital paths
              CustomPaint(
                size: const Size(320, 320),
                painter: _OrbitPainter(
                  progress: _displayProgress,
                  color: primaryColor.withValues(alpha: 0.2),
                ),
              ),

              // Planets
              ..._planets.asMap().entries.map((entry) {
                final planet = entry.value;
                final angle = _planetRotation.value * planet.speed + planet.startAngle;
                return Transform.translate(
                  key: ValueKey('planet_${entry.key}'),
                  offset: Offset(
                    planet.orbitRadius * cos(angle),
                    planet.orbitRadius * sin(angle),
                  ),
                  child: _buildPlanet(planet),
                );
              }),

              // Satellites
              ..._satellites.asMap().entries.map((entry) {
                final satellite = entry.value;
                final angle = _satelliteRotation.value * satellite.speed + satellite.startAngle;
                return Transform.translate(
                  key: ValueKey('satellite_${entry.key}'),
                  offset: Offset(
                    satellite.orbitRadius * cos(angle),
                    satellite.orbitRadius * sin(angle) * 0.7,
                  ),
                  child: _buildSatellite(),
                );
              }),

              // Signal waves
              if (_displayProgress > 0.2)
                CustomPaint(
                  size: const Size(320, 320),
                  painter: _SignalWavePainter(
                    progress: _displayProgress,
                    rotation: _satelliteRotation.value,
                  ),
                ),

              // Center glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 90 * _pulse.value,
                    height: 90 * _pulse.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.7),
                          primaryColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Center - Earth
              Transform.scale(
                scale: 0.9 + (_pulse.value - 0.85) * 0.3,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF4A90D9),
                        Color(0xFF2E5A8B),
                        Color(0xFF1E3A5F),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.8),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.public,
                    color: Colors.white70,
                    size: 30,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanet(_Planet planet) {
    return Container(
      width: planet.size,
      height: planet.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: planet.color,
        boxShadow: [
          BoxShadow(
            color: planet.color.withValues(alpha: 0.6),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSatellite() {
    return SizedBox(
      width: 36,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              Icons.satellite_alt,
              size: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 6,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
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

class _Satellite {
  final double orbitRadius;
  final double speed;
  final double startAngle;

  _Satellite({
    required this.orbitRadius,
    required this.speed,
    required this.startAngle,
  });
}

class _Planet {
  final double orbitRadius;
  final double speed;
  final double startAngle;
  final Color color;
  final double size;
  final String name;

  _Planet({
    required this.orbitRadius,
    required this.speed,
    required this.startAngle,
    required this.color,
    required this.size,
    required this.name,
  });
}

class _ZodiacWheelPainter extends CustomPainter {
  final double progress;

  _ZodiacWheelPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Outer zodiac ring
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, paint);

    // Zodiac segments
    final zodiacSymbols = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 12; i++) {
      final angle = (i * pi / 6) - pi / 2;
      
      // Draw segment line
      final lineStart = Offset(
        center.dx + (radius - 15) * cos(angle),
        center.dy + (radius - 15) * sin(angle),
      );
      final lineEnd = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(lineStart, lineEnd, paint..strokeWidth = 1);

      // Draw zodiac symbol
      final symbolAngle = angle + pi / 12;
      final symbolPos = Offset(
        center.dx + (radius - 25) * cos(symbolAngle),
        center.dy + (radius - 25) * sin(symbolAngle),
      );

      textPainter.text = TextSpan(
        text: zodiacSymbols[i],
        style: TextStyle(
          color: primaryColor.withValues(alpha: 0.5 * progress),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(symbolPos.dx - textPainter.width / 2, symbolPos.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ZodiacWheelPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
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
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);

    // Planet orbits
    final orbits = [55.0, 68.0, 82.0, 95.0, 110.0, 125.0];
    for (final radius in orbits) {
      canvas.drawCircle(center, radius, paint..strokeWidth = 0.5);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _SignalWavePainter extends CustomPainter {
  final double progress;
  final double rotation;

  _SignalWavePainter({required this.progress, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw signal beams from satellites to center
    for (int i = 0; i < 3; i++) {
      final satelliteRadius = [80.0, 105.0, 130.0][i];
      final speed = [1.2, 0.8, 0.5][i];
      final startAngle = [0.0, pi * 0.5, pi][i];
      final angle = rotation * speed + startAngle;
      
      final satellitePos = Offset(
        center.dx + satelliteRadius * cos(angle),
        center.dy + satelliteRadius * sin(angle) * 0.7,
      );

      // Draw dashed line from satellite to center
      final path = Path();
      path.moveTo(satellitePos.dx, satellitePos.dy);
      path.lineTo(center.dx, center.dy);

      paint.color = Colors.cyan.withValues(alpha: 0.3 * progress);
      
      // Draw signal pulses along the line
      final pulseCount = 3;
      for (int j = 0; j < pulseCount; j++) {
        final t = ((rotation * 2 + j / pulseCount) % 1.0);
        final pulsePos = Offset(
          satellitePos.dx + (center.dx - satellitePos.dx) * t,
          satellitePos.dy + (center.dy - satellitePos.dy) * t,
        );
        
        canvas.drawCircle(
          pulsePos,
          3 * (1 - t),
          Paint()..color = Colors.cyan.withValues(alpha: 0.5 * (1 - t) * progress),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignalWavePainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.progress != progress;
  }
}


