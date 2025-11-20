import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

class DateOfBirthScreen extends StatefulWidget {
  const DateOfBirthScreen({super.key});

  @override
  State<DateOfBirthScreen> createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends State<DateOfBirthScreen> {
  DateTime selectedDate = DateTime(1982, 9, 29);

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
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    Expanded(
                      child: ScrollDatePicker(
                        selectedDate: selectedDate,
                        locale: const Locale('en'),
                        scrollViewOptions: const DatePickerScrollViewOptions(
                          year: ScrollViewDetailOptions(
                            label: 'Year',
                            margin: EdgeInsets.only(right: 8),
                          ),
                          month: ScrollViewDetailOptions(
                            label: 'Month',
                            margin: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          day: ScrollViewDetailOptions(
                            label: 'Day',
                            margin: EdgeInsets.only(left: 8),
                          ),
                        ),
                        options: const DatePickerOptions(
                          itemExtent: 50,
                        ),
                        onDateTimeChanged: (DateTime value) {
                          setState(() {
                            selectedDate = value;
                          });
                        },
                      ),
                    ),
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
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '♎',
                style: TextStyle(
                  fontSize: 40,
                  color: whiteColor,
                ),
              ),
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

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * 3.14159 / 180;
      final startPoint = Offset(
        center.dx + radius * 0.7 * cos(angle),
        center.dy + radius * 0.7 * sin(angle),
      );
      final endPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  
  double cos(double angle) => angle.cos();
  double sin(double angle) => angle.sin();
}

extension on double {
  double cos() => this * 0.5;
  double sin() => this * 0.866;
}

