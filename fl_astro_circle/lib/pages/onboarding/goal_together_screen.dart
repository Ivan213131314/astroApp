import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class GoalTogetherScreen extends StatefulWidget {
  const GoalTogetherScreen({super.key});

  @override
  State<GoalTogetherScreen> createState() => _GoalTogetherScreenState();
}

class _GoalTogetherScreenState extends State<GoalTogetherScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
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
            LinearProgressIndicator(
              value: 0.2,
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
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Icon(
                                Icons.search,
                                size: 60,
                                color: whiteColor.withValues(alpha: 0.9),
                              ),
                              Positioned(
                                top: 30,
                                right: 30,
                                child: Icon(
                                  Icons.star,
                                  size: 24,
                                  color: primaryColor,
                                ),
                              ),
                              Positioned(
                                bottom: 35,
                                left: 35,
                                child: Icon(
                                  Icons.star,
                                  size: 16,
                                  color: whiteColor.withValues(alpha: 0.5),
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
                        "Let's reach your goal together",
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
                          'AstroCircle will help you feel hope and motivation with personalized readings from top psychic advisors',
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
        Navigator.pushNamed(context, '/onboardingBirthChartIntro');
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

