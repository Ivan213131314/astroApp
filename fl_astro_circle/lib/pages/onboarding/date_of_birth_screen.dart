import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

class DateOfBirthScreen extends StatefulWidget {
  const DateOfBirthScreen({super.key});

  @override
  State<DateOfBirthScreen> createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends State<DateOfBirthScreen> with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime(1982, 9, 29);
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;
  
  int selectedDay = 29;
  int selectedMonth = 9;
  int selectedYear = 1982;
  
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  
  String get zodiacSign {
    final month = selectedDate.month;
    final day = selectedDate.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '♈'; // Aries
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '♉'; // Taurus
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '♊'; // Gemini
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '♋'; // Cancer
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '♌'; // Leo
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '♍'; // Virgo
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '♎'; // Libra
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '♏'; // Scorpio
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '♐'; // Sagittarius
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '♑'; // Capricorn
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '♒'; // Aquarius
    return '♓'; // Pisces
  }
  
  int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    
    _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    _monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);
    _yearController = FixedExtentScrollController(initialItem: selectedYear - 1950);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
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
          'Date of birth',
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
            LinearProgressIndicator(
              value: 0.3,
              backgroundColor: const Color(0xFF3D3761),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 3,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                child: Column(
                  children: [
                    heightSpace,
                    heightSpace,
                    zodiacCircle(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    const Text(
                      'Date is important for determining your Sun sign, numerology and compatibility',
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    datePicker(),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              child: nextButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget zodiacCircle() {
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.3),
            primaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(90),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(180, 180),
            painter: ZodiacCirclePainter(),
          ),
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  zodiacSign,
                  style: const TextStyle(
                    fontSize: 40,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget datePicker() {
    final daysInMonth = getDaysInMonth(selectedYear, selectedMonth);
    
    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CupertinoPicker(
              scrollController: _dayController,
              itemExtent: 50,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: primaryColor.withValues(alpha: 0.3), width: 1),
                    bottom: BorderSide(color: primaryColor.withValues(alpha: 0.3), width: 1),
                  ),
                ),
              ),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedDay = index + 1;
                  if (selectedDay > daysInMonth) {
                    selectedDay = daysInMonth;
                  }
                  selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
                  _animationController.reset();
                  _animationController.forward();
                });
              },
              children: List.generate(daysInMonth, (index) {
                return Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            flex: 2,
            child: CupertinoPicker(
              scrollController: _monthController,
              itemExtent: 50,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: primaryColor.withValues(alpha: 0.3), width: 1),
                    bottom: BorderSide(color: primaryColor.withValues(alpha: 0.3), width: 1),
                  ),
                ),
              ),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedMonth = index + 1;
                  final newDaysInMonth = getDaysInMonth(selectedYear, selectedMonth);
                  if (selectedDay > newDaysInMonth) {
                    selectedDay = newDaysInMonth;
                  }
                  selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
                  _animationController.reset();
                  _animationController.forward();
                });
              },
              children: months.map((month) {
                return Center(
                  child: Text(
                    month,
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              scrollController: _yearController,
              itemExtent: 50,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: primaryColor.withValues(alpha: 0.3), width: 1),
                    bottom: BorderSide(color: primaryColor.withValues(alpha: 0.3), width: 1),
                  ),
                ),
              ),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedYear = 1950 + index;
                  final newDaysInMonth = getDaysInMonth(selectedYear, selectedMonth);
                  if (selectedDay > newDaysInMonth) {
                    selectedDay = newDaysInMonth;
                  }
                  selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
                  _animationController.reset();
                  _animationController.forward();
                });
              },
              children: List.generate(101, (index) {
                return Center(
                  child: Text(
                    '${1950 + index}',
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget nextButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/onboardingTimeOfBirth');
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

class ZodiacCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9B7BFA).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer circle
    canvas.drawCircle(center, radius - 5, paint);
    
    // Draw inner circle
    canvas.drawCircle(center, radius * 0.7, paint);

    // Draw 12 lines for zodiac divisions
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final startPoint = Offset(
        center.dx + (radius * 0.7) * math.cos(angle),
        center.dy + (radius * 0.7) * math.sin(angle),
      );
      final endPoint = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, paint);
    }

    // Draw zodiac symbols around the circle
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    final zodiacSymbols = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
    
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 75) * math.pi / 180;
      final x = center.dx + (radius * 0.85) * math.cos(angle);
      final y = center.dy + (radius * 0.85) * math.sin(angle);
      
      textPainter.text = TextSpan(
        text: zodiacSymbols[i],
        style: TextStyle(
          fontSize: 16,
          color: const Color(0xFF9B7BFA).withValues(alpha: 0.6),
        ),
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

