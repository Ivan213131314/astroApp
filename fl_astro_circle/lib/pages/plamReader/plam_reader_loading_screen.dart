import 'dart:io';
import 'dart:math';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_astro_circle/services/palm_reading_service.dart';

class PlamReaderLoadingScreen extends StatefulWidget {
  const PlamReaderLoadingScreen({super.key});

  @override
  State<PlamReaderLoadingScreen> createState() => _PlamReaderLoadingScreenState();
}

class _PlamReaderLoadingScreenState extends State<PlamReaderLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  File? _imageFile;
  late Future<PalmReadingResult> _analysisFuture;
  bool _initialized = false;

  final List<String> _dynamicTexts = [
    'Analyzing palm image...',
    'Reading life line patterns...',
    'Interpreting heart line energy...',
    'Discovering financial paths...',
  ];
  int _currentTextIndex = 0;
  double _displayProgress = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _imageFile = args?['imageFile'] as File?;

      if (_imageFile != null) {
        final service = PalmReadingService();
        _analysisFuture = service.analyzePalm(
          imageFile: _imageFile!,
          language: _getLanguage(),
        );
        _startProgressAndWaitContent();
      }
    }
  }

  String _getLanguage() {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'ru':
        return 'Russian';
      case 'es':
        return 'Spanish';
      case 'de':
        return 'German';
      case 'fr':
        return 'French';
      default:
        return 'English';
    }
  }

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startProgressAndWaitContent() async {
    _animateProgressTo(0.9, const Duration(seconds: 3));

    try {
      final result = await _analysisFuture;
      await _animateProgressTo(1.0, const Duration(milliseconds: 300));
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/plamReaderDetail',
          arguments: {
            'result': result,
          },
        );
      }
    } catch (e) {
      debugPrint('Palm reading error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
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

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
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
              _buildAnimatedHand(),
              const Spacer(),
              Text(
                getTranslation(context, 'plam_reader.analyzing_palm'),
                style: const TextStyle(
                  color: whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
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

  Widget _buildAnimatedHand() {
    return SizedBox(
      height: 250,
      width: 250,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationController, _pulseController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Rotating gradient background
              Transform.rotate(
                angle: _rotationController.value * 2 * pi,
                child: Container(
                  width: 200 * _pulse.value,
                  height: 200 * _pulse.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.0),
                        primaryColor.withValues(alpha: 0.3),
                        primaryColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Pulsing glow
              Container(
                width: 150 * _pulse.value,
                height: 150 * _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.4),
                      primaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              
              // Hand icon
              Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.back_hand,
                    size: 60,
                    color: whiteColor,
                  ),
                ),
              ),
            ],
          );
        },
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

  Widget _buildDynamicText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Text(
          _dynamicTexts[_currentTextIndex],
          key: ValueKey(_dynamicTexts[_currentTextIndex]),
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
}
