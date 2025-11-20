import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class BirthChartIntroScreen extends StatefulWidget {
  const BirthChartIntroScreen({super.key});

  @override
  State<BirthChartIntroScreen> createState() => _BirthChartIntroScreenState();
}

class _BirthChartIntroScreenState extends State<BirthChartIntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
          'Birth chart',
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
              value: 0.25,
              backgroundColor: const Color(0xFF3D3761),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 3,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: RotationTransition(
                        turns: _rotationAnimation,
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 70,
                                color: whiteColor.withValues(alpha: 0.8),
                              ),
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Icon(
                                  Icons.star,
                                  size: 20,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        "Let's personalize your experience",
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    heightSpace,
                    heightSpace,
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: fixPadding),
                        child: Text(
                          "You'll get all personalized insights, tips, and daily guidance based on your unique birth chart - a snapshot of the sky at the moment and place of your birth",
                          style: TextStyle(
                            color: greyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
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

  Widget nextButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/onboardingDateOfBirth');
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

