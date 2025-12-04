import 'dart:convert';
import 'dart:math';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'numorology_service.dart';
import 'numorology_result_screen.dart';

/// Wrapper для роутинга - управляет загрузкой данных и навигацией
class NumerologyLoadingWrapper extends StatefulWidget {
  const NumerologyLoadingWrapper({super.key});

  @override
  State<NumerologyLoadingWrapper> createState() => _NumerologyLoadingWrapperState();
}

class _NumerologyLoadingWrapperState extends State<NumerologyLoadingWrapper> {
  DateTime? _birthDate;
  late Future<NumerologyResult> _contentFuture;
  NumerologyResult? _result;
  String? _docId;
  bool _initialized = false;
  final NotificationStorageService _storageService = NotificationStorageService();
  late NumerologyService _service;
  late String _language;

  // ===== Локальный кэш через SharedPreferences =====
  
  String _getCacheKey(DateTime birthDate) {
    final key = '${birthDate.year}-${birthDate.month}-${birthDate.day}';
    return 'numerology_$key';
  }

  Future<void> _saveToCache(String key, NumerologyResult result, String? docId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'luckyNumber': result.luckyNumber,
        'birthDate': result.birthDate,
        'traits': result.traits,
        'aboutCharacter': result.aboutCharacter,
        'aboutBehavior': result.aboutBehavior,
        'aboutResponsibility': result.aboutResponsibility,
        'docId': docId,
      };
      await prefs.setString(key, jsonEncode(data));
      debugPrint('Numerology saved to cache: $key');
    } catch (e) {
      debugPrint('Error saving numerology to cache: $e');
    }
  }

  Future<Map<String, dynamic>?> _loadFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        debugPrint('Numerology loaded from cache: $key');
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading numerology from cache: $e');
    }
    return null;
  }

  // ===== Конец кэша =====

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _birthDate = args?['birthDate'] as DateTime? ?? DateTime.now();
      
      // Определяем язык из локали
      final locale = Localizations.localeOf(context);
      _language = 'English';
      switch (locale.languageCode) {
        case 'ru':
          _language = 'Russian';
          break;
        case 'es':
          _language = 'Spanish';
          break;
        case 'de':
          _language = 'German';
          break;
        case 'fr':
          _language = 'French';
          break;
      }
      
      _service = NumerologyService();
      
      // Создаем Future СРАЗУ, синхронно
      _contentFuture = _generateOrLoadNumerology();
    }
  }

  Future<NumerologyResult> _generateOrLoadNumerology() async {
    final formattedDate = '${_birthDate!.day.toString().padLeft(2, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.year}';
    final cacheKey = _getCacheKey(_birthDate!);
    
    // 1. Сначала проверяем локальный кэш
    final cached = await _loadFromCache(cacheKey);
    if (cached != null) {
      _result = NumerologyResult(
        luckyNumber: cached['luckyNumber'] as int,
        birthDate: cached['birthDate'] as String,
        traits: Map<String, double>.from(cached['traits'] as Map),
        aboutCharacter: cached['aboutCharacter'] as String,
        aboutBehavior: cached['aboutBehavior'] as String,
        aboutResponsibility: cached['aboutResponsibility'] as String,
      );
      _docId = cached['docId'] as String?;
      return _result!;
    }
    
    // 2. Проверяем Firebase
    try {
      final existing = await _storageService.findExistingNumerology(birthDate: formattedDate);
      
      if (existing != null) {
        _result = NumerologyResult(
          luckyNumber: existing.luckyNumber,
          birthDate: existing.birthDate,
          traits: existing.traits,
          aboutCharacter: existing.aboutCharacter,
          aboutBehavior: existing.aboutBehavior,
          aboutResponsibility: existing.aboutResponsibility,
        );
        _docId = existing.id;
        
        // Сохраняем в локальный кэш
        await _saveToCache(cacheKey, _result!, _docId);
        
        return _result!;
      }
    } catch (e) {
      debugPrint('Error checking existing numerology: $e');
    }
    
    // 3. Генерируем новый результат
    try {
      final result = await _service.generateNumerology(
        birthDate: _birthDate!,
        language: _language,
      );
      _result = result;
      
      // Сохраняем в Firebase
      try {
        _docId = await _storageService.saveNumerology(
          luckyNumber: result.luckyNumber,
          birthDate: result.birthDate,
          traits: result.traits,
          aboutCharacter: result.aboutCharacter,
          aboutBehavior: result.aboutBehavior,
          aboutResponsibility: result.aboutResponsibility,
        );
      } catch (e) {
        debugPrint('Error saving numerology to Firebase: $e');
      }
      
      // Сохраняем в локальный кэш
      await _saveToCache(cacheKey, result, _docId);
      
      return result;
    } catch (e) {
      debugPrint('Error generating numerology: $e');
      // Создаем fallback результат при ошибке
      final luckyNumber = _service.calculateLifePathNumber(_birthDate!);
      _result = NumerologyResult(
        luckyNumber: luckyNumber,
        birthDate: formattedDate,
        traits: {
          'funny': 0.75,
          'obedient': 0.70,
          'honest': 0.80,
          'responsible': 0.78,
          'hard_working': 0.82,
          'smart': 0.85,
        },
        aboutCharacter: 'Your Life Path Number $luckyNumber reveals a unique character blueprint. People with this number often possess natural charisma and inner strength.',
        aboutBehavior: 'As a Life Path $luckyNumber, your behavior patterns reflect a balance between independence and cooperation.',
        aboutResponsibility: 'Your sense of responsibility is deeply connected to your life purpose. Life Path Number $luckyNumber indicates a path of growth.',
      );
      
      // Сохраняем fallback в кэш тоже
      await _saveToCache(cacheKey, _result!, null);
      
      return _result!;
    }
  }

  void _onLoadingComplete() {
    if (_result != null && mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/numerologyResult',
        arguments: {
          'result': _result,
          'docId': _docId,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_birthDate == null) {
      return const Scaffold(
        backgroundColor: scaffoldBgColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return NumerologyLoadingScreen(
      birthDate: _birthDate!,
      contentFuture: _contentFuture,
      onComplete: _onLoadingComplete,
    );
  }
}

/// Wrapper для результата
class NumerologyResultWrapper extends StatelessWidget {
  const NumerologyResultWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final docId = args?['docId'] as String?;
    final fromNotifications = args?['fromNotifications'] == true;
    
    // Пробуем получить result как NumerologyResult или как Map
    NumerologyResult? result;
    
    if (args?['result'] is NumerologyResult) {
      result = args?['result'] as NumerologyResult;
    } else if (args?['result'] is Map<String, dynamic>) {
      // Конвертируем Map в NumerologyResult (из notification screen)
      final map = args?['result'] as Map<String, dynamic>;
      result = NumerologyResult(
        luckyNumber: map['luckyNumber'] as int? ?? 1,
        birthDate: map['birthDate'] as String? ?? '',
        traits: Map<String, double>.from(map['traits'] ?? {}),
        aboutCharacter: map['aboutCharacter'] as String? ?? '',
        aboutBehavior: map['aboutBehavior'] as String? ?? '',
        aboutResponsibility: map['aboutResponsibility'] as String? ?? '',
      );
    }
    
    if (result == null) {
      // Fallback если нет данных
      return const Scaffold(
        backgroundColor: scaffoldBgColor,
        body: Center(
          child: Text('Error: No data', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    
    return NumerologyResultScreen(
      result: result,
      docId: docId,
      fromNotifications: fromNotifications,
    );
  }
}

class NumerologyLoadingScreen extends StatefulWidget {
  final DateTime birthDate;
  final VoidCallback onComplete;
  final Future<NumerologyResult> contentFuture;

  const NumerologyLoadingScreen({
    super.key,
    required this.birthDate,
    required this.onComplete,
    required this.contentFuture,
  });

  @override
  State<NumerologyLoadingScreen> createState() =>
      _NumerologyLoadingScreenState();
}

class _NumerologyLoadingScreenState extends State<NumerologyLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _satelliteController;

  late Animation<double> _rotation;
  late Animation<double> _pulse;
  late Animation<double> _satelliteRotation;

  static const String _staticText =
      'Request is being sent to space via NASA satellites...';

  final List<String> _dynamicTexts = [
    'Calculating life path number...',
    'Analyzing cosmic vibrations...',
    'Reading numerological patterns...',
    'Generating mystical insights...',
  ];
  int _currentTextIndex = 0;

  final List<_Sparkle> _sparkles = [];
  final List<_Satellite> _satellites = [];
  final Random _random = Random();

  double _displayProgress = 0.0;
  late int _luckyNumber;

  @override
  void initState() {
    super.initState();

    // Вычисляем число судьбы для отображения
    _luckyNumber = _calculateLifePathNumber(widget.birthDate);

    // Инициализируем спутники
    _initSatellites();

    // Rotation animation for number
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(
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

    // Satellite rotation
    _satelliteController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _satelliteRotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _satelliteController, curve: Curves.linear),
    );

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();

    _sparkleController.addListener(_generateSparkles);

    // Запускаем прогресс и ожидание контента
    _startProgressAndWaitContent();
  }

  void _initSatellites() {
    // Создаём 3 спутника на разных орбитах
    _satellites.addAll([
      _Satellite(orbitRadius: 100, speed: 1.0, startAngle: 0),
      _Satellite(orbitRadius: 130, speed: 0.7, startAngle: pi * 0.66),
      _Satellite(orbitRadius: 160, speed: 0.5, startAngle: pi * 1.33),
    ]);
  }

  int _calculateLifePathNumber(DateTime date) {
    int sum = _sumDigits(date.day) + _sumDigits(date.month) + _sumDigits(date.year);
    while (sum > 9) {
      sum = _sumDigits(sum);
    }
    return sum == 0 ? 1 : sum;
  }

  int _sumDigits(int number) {
    int sum = 0;
    while (number > 0) {
      sum += number % 10;
      number ~/= 10;
    }
    return sum;
  }

  Future<void> _startProgressAndWaitContent() async {
    // Плавно увеличиваем прогресс до 90% пока ждём контент
    _animateProgressTo(0.9, const Duration(seconds: 4));

    // Ждём завершения генерации контента (с обработкой ошибок)
    try {
      await widget.contentFuture;
    } catch (e) {
      debugPrint('Content generation error (handled): $e');
      // Ошибка уже обработана в wrapper'е
    }

    // Быстро доводим до 100%
    await _animateProgressTo(1.0, const Duration(milliseconds: 300));

    // Пауза чтобы показать 100%
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

        // Обновляем текст в зависимости от прогресса
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
    if (_random.nextDouble() > 0.7) {
      setState(() {
        _sparkles.add(_Sparkle(
          x: _random.nextDouble() * 300 - 150,
          y: _random.nextDouble() * 300 - 150,
          size: _random.nextDouble() * 4 + 2,
          opacity: 1.0,
        ));

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
    _satelliteController.dispose();
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
              _buildAnimatedNumber(),
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

  Widget _buildAnimatedNumber() {
    return SizedBox(
      height: 350,
      width: 350,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationController,
          _pulseController,
          _satelliteController,
        ]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Sparkles
              ..._sparkles.map((sparkle) => Positioned(
                    left: 175 + sparkle.x,
                    top: 175 + sparkle.y,
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

              // Orbital paths
              CustomPaint(
                size: const Size(350, 350),
                painter: _OrbitPainter(
                  progress: _displayProgress,
                  color: primaryColor.withValues(alpha: 0.3),
                ),
              ),

              // Satellites
              ..._satellites.map((satellite) {
                final angle = _satelliteRotation.value * satellite.speed +
                    satellite.startAngle;
                return Transform.translate(
                  offset: Offset(
                    satellite.orbitRadius * cos(angle),
                    satellite.orbitRadius * sin(angle) * 0.6,
                  ),
                  child: _buildSatellite(),
                );
              }),

              // Signal waves from satellites to center
              if (_displayProgress > 0.3)
                CustomPaint(
                  size: const Size(350, 350),
                  painter: _SignalWavePainter(
                    progress: _displayProgress,
                    rotation: _rotation.value,
                  ),
                ),

              // Center glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 100 * _pulse.value,
                    height: 100 * _pulse.value,
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

              // Number container
              Transform.scale(
                scale: 0.9 + (_pulse.value - 0.8) * 0.25,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.6),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: primaryColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_luckyNumber',
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSatellite() {
    return SizedBox(
      width: 44, // 24 + 8 + 8 + 4 padding
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left solar panel
          Container(
            width: 8,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 2),
          // Main body
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.satellite_alt,
              size: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 2),
          // Right solar panel
          Container(
            width: 8,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.4),
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

    // Draw three orbital ellipses for satellites
    final orbits = [100.0, 130.0, 160.0];
    for (final radius in orbits) {
      final rect = Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 1.2,
      );
      canvas.drawOval(rect, paint..strokeWidth = 1.0);
    }

    // Inner glow ring
    final innerRect = Rect.fromCenter(
      center: center,
      width: 120,
      height: 120,
    );
    canvas.drawOval(
      innerRect,
      paint
        ..strokeWidth = 2.0
        ..color = primaryColor.withValues(alpha: progress * 0.5),
    );
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
      ..color = Colors.cyan.withValues(alpha: 0.3 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw signal waves from satellites to center
    for (int i = 0; i < 3; i++) {
      final angle = rotation * 0.5 + i * pi * 2 / 3;
      final startRadius = 80.0 + i * 20;

      for (int j = 0; j < 3; j++) {
        final waveRadius = startRadius - j * 15;
        if (waveRadius > 40) {
          final waveCenter = Offset(
            center.dx + waveRadius * cos(angle) * 0.3,
            center.dy + waveRadius * sin(angle) * 0.3,
          );
          canvas.drawCircle(
            waveCenter,
            5 + j * 3.0,
            paint..color = Colors.cyan.withValues(alpha: 0.2 - j * 0.05),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignalWavePainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.progress != progress;
  }
}



