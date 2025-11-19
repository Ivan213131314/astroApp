import 'dart:io';

import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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
          padding: const EdgeInsets.all(fixPadding * 2.0),
          height: size.height,
          width: size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/onboarding/background.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              title(),
              heightSpace,
              height5Space,
              contentText(),
              heightSpace,
              heightSpace,
              heightSpace,
              heightSpace,
              getStartedButton(context),
              heightSpace,
              heightSpace,
              heightSpace,
              heightSpace,
            ],
          ),
        ),
      ),
    );
  }

  contentText() {
    return Text(
      getTranslation(context, 'onboarding.content_text'),
      textAlign: TextAlign.center,
      style: medium14White,
    );
  }

  title() {
    return Text(
      getTranslation(context, 'onboarding.the_astrology'),
      style: bold30White,
    );
  }

  getStartedButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/authChoice');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.2, horizontal: fixPadding * 2.0),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.25),
              blurRadius: 6,
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'onboarding.get_started'),
          style: bold20White,
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
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: whiteColor,
          content: Text(
            getTranslation(context, 'exit_app.exit_text'),
            style: bold15Black03,
          ),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}
