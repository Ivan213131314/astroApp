import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class MainReasonScreen extends StatefulWidget {
  const MainReasonScreen({super.key});

  @override
  State<MainReasonScreen> createState() => _MainReasonScreenState();
}

class _MainReasonScreenState extends State<MainReasonScreen> with TickerProviderStateMixin {
  String? selectedReason;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<Map<String, dynamic>> reasons = [
    {
      'text': 'Make decisions with confidence',
      'icon': Icons.psychology_outlined,
      'gradient': [const Color(0xFF7B2FF7), const Color(0xFFB565F2)],
    },
    {
      'text': 'Receive answers to my questions',
      'icon': Icons.lightbulb_outline,
      'gradient': [const Color(0xFF6B4CE6), const Color(0xFF9B7AF0)],
    },
    {
      'text': 'Get an outside perspective',
      'icon': Icons.visibility_outlined,
      'gradient': [const Color(0xFF5A3DD5), const Color(0xFF8A6EE8)],
    },
    {
      'text': 'Feel hope and motivation',
      'icon': Icons.favorite_outline,
      'gradient': [const Color(0xFF7E3FE8), const Color(0xFFAE6FF5)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      reasons.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your goals',
          style: TextStyle(
            color: whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scaffoldBgColor,
              Color(0xFF301B87),
            ],
          ),
        ),
        child: Column(
          children: [
            const LinearProgressIndicator(
              value: 0.15,
              backgroundColor: Color(0xFF3D3761),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 3,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                child: Column(
                  children: [
                    heightSpace,
                    heightSpace,
                    const Text(
                      'What is your main reason for\nwanting to get guidance and\nadvice?',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    Expanded(
                      child: ListView.builder(
                        itemCount: reasons.length,
                        itemBuilder: (context, index) {
                          return ScaleTransition(
                            scale: _animations[index],
                            child: reasonItem(
                              reasons[index]['text'],
                              reasons[index]['icon'],
                              reasons[index]['gradient'],
                              index,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reasonItem(String text, IconData icon, List<Color> gradient, int index) {
    final isSelected = selectedReason == text;
    return Padding(
      padding: const EdgeInsets.only(bottom: fixPadding * 1.8),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedReason = text;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pushNamed(context, '/onboardingGoalTogether');
          });
        },
        borderRadius: BorderRadius.circular(20.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(fixPadding * 2.0),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : const Color(0xFF2F2955),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isSelected 
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: gradient[0].withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(fixPadding),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? whiteColor : primaryColor,
                  size: 28,
                ),
              ),
              widthSpace,
              widthSpace,
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: whiteColor,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

