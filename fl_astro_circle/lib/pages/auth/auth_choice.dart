import 'dart:io';

import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen> {
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
            color: scaffoldBgColor.withValues(alpha: 0.5),
            image: const DecorationImage(
              image: AssetImage("assets/auth/bgImage.png"),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scaffoldBgColor,
                  const Color(0xFF301B87).withValues(alpha: 0),
                ],
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                physics: const BouncingScrollPhysics(),
                children: [
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  welcomeTitle(),
                  heightSpace,
                  heightSpace,
                  welcomeText(),
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
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
    return Text(
      getTranslation(context, 'auth_choice.welcome'),
      style: bold24White,
      textAlign: TextAlign.center,
    );
  }

  welcomeText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'auth_choice.welcome_text'),
        style: medium14WhiteF4,
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
          vertical: fixPadding * 1.2,
          horizontal: fixPadding * 2.0,
        ),
        decoration: BoxDecoration(
          color: recBgColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: recBgColor.withValues(alpha: 0.25),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'auth_choice.log_in'),
          style: bold20White,
        ),
      ),
    );
  }

  getStartedButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/register');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.2,
          horizontal: fixPadding * 2.0,
        ),
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
          getTranslation(context, 'auth_choice.get_started'),
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

