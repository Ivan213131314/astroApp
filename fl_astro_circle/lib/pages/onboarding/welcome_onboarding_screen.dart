import 'dart:io';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  State<WelcomeOnboardingScreen> createState() => _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen> {
  DateTime? backPressTime;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        bool backStatus = onWillPop();
        if (backStatus) {
          exit(0);
        }
      },
      child: Scaffold(
        body: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scaffoldBgColor,
                const Color(0xFF301B87),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  welcomeTitle(),
                  heightSpace,
                  heightSpace,
                  welcomeText(),
                  const Spacer(),
                  logInButton(),
                  heightSpace,
                  heightSpace,
                  getStartedButton(),
                  heightSpace,
                  heightSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  welcomeTitle() {
    return const Text(
      'Welcome',
      style: TextStyle(
        color: whiteColor,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }

  welcomeText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        'Choose how you want to continue',
        style: TextStyle(
          color: whiteF4Color,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  logInButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/login');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
          horizontal: fixPadding * 2.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF3D3761),
          borderRadius: BorderRadius.circular(12.0),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Log In',
          style: TextStyle(
            color: whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  getStartedButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/onboardingGoals');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
          horizontal: fixPadding * 2.0,
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
          'Get Started',
          style: TextStyle(
            color: whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime == null ||
        now.difference(backPressTime!) >= const Duration(seconds: 2)) {
      backPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: whiteColor,
          content: Text(
            'Press back again to exit',
            style: TextStyle(
              color: black03Color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}

