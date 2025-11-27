import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class TimeOfBirthScreen extends StatefulWidget {
  const TimeOfBirthScreen({super.key});

  @override
  State<TimeOfBirthScreen> createState() => _TimeOfBirthScreenState();
}

class _TimeOfBirthScreenState extends State<TimeOfBirthScreen> {
  int selectedHour = 13;
  int selectedMinute = 0;
  final FixedExtentScrollController hourController = FixedExtentScrollController(initialItem: 13);
  final FixedExtentScrollController minuteController = FixedExtentScrollController(initialItem: 0);

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
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
          'Time of birth',
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
              value: 0.35,
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
                    zodiacWheel(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    const Text(
                      'Time is important for determining your Houses, Rising sign, and the exact Moon position',
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            child: ListWheelScrollView.useDelegate(
                              controller: hourController,
                              itemExtent: 50,
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedHour = index;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 24,
                                builder: (context, index) {
                                  final isSelected = index == selectedHour;
                                  return Center(
                                    child: Text(
                                      index.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                        color: isSelected ? whiteColor : greyColor,
                                        fontSize: isSelected ? 32 : 24,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          widthSpace,
                          const Text(
                            ':',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          widthSpace,
                          SizedBox(
                            width: 80,
                            child: ListWheelScrollView.useDelegate(
                              controller: minuteController,
                              itemExtent: 50,
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedMinute = index;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 60,
                                builder: (context, index) {
                                  final isSelected = index == selectedMinute;
                                  return Center(
                                    child: Text(
                                      index.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                        color: isSelected ? whiteColor : greyColor,
                                        fontSize: isSelected ? 32 : 24,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              child: Column(
                children: [
                  dontKnowButton(),
                  heightSpace,
                  nextButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget zodiacWheel() {
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.3),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(90),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(180, 180),
            painter: ZodiacWheelPainter(),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '♐',
                style: TextStyle(fontSize: 28, color: Color(0xFFFF8C42)),
              ),
              Text(
                '♑',
                style: TextStyle(fontSize: 28, color: Color(0xFF64D2FF)),
              ),
            ],
          ),
          Positioned(
            left: 30,
            child: Text(
              '♏',
              style: TextStyle(fontSize: 24, color: primaryColor.withValues(alpha: 0.8)),
            ),
          ),
          Positioned(
            right: 30,
            child: Text(
              '♒',
              style: TextStyle(fontSize: 24, color: primaryColor.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget dontKnowButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/onboardingPlaceOfBirth');
      },
      child: const Text(
        "I DON'T KNOW",
        style: TextStyle(
          color: whiteColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget nextButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/onboardingPlaceOfBirth');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
        ),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'NEXT',
          style: TextStyle(
            color: whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class ZodiacWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9B7BFA).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.drawCircle(center, size.width / 2 - 10, paint);
    canvas.drawCircle(center, size.width / 3, paint);

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final startPoint = Offset(
        center.dx + (size.width / 3) * math.cos(angle),
        center.dy + (size.width / 3) * math.sin(angle),
      );
      final endPoint = Offset(
        center.dx + (size.width / 2 - 10) * math.cos(angle),
        center.dy + (size.width / 2 - 10) * math.sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

