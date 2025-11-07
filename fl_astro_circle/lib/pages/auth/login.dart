import 'dart:io';

import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/pages/profile/languages.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                  loginText(),
                  heightSpace,
                  heightSpace,
                  mobileNumberTitle(),
                  heightSpace,
                  phoneField(),
                  heightSpace,
                  infoText(),
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  loginButton()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  infoText() {
    return Text(
      getTranslation(context, 'login.text'),
      style: medium14Red,
    );
  }

  mobileNumberTitle() {
    return Text(
      getTranslation(context, 'login.mobile_number'),
      style: medium16White,
    );
  }

  loginText() {
    return Text(
      getTranslation(context, 'login.login'),
      style: bold24White,
      textAlign: TextAlign.center,
    );
  }

  loginButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/register');
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
              blurRadius: 5,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'login.login'),
          style: bold20White,
        ),
      ),
    );
  }

  phoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 1.5),
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
      child: IntlPhoneField(
        style: medium15WhiteF4,
        cursorColor: primaryColor,
        disableLengthCheck: true,
        textAlign: languageValue == 4 ? TextAlign.right : TextAlign.left,
        dropdownIconPosition: IconPosition.trailing,
        dropdownIcon: const Icon(
          Icons.keyboard_arrow_down_outlined,
          size: 20,
          color: whiteColor,
        ),
        pickerDialogStyle: PickerDialogStyle(backgroundColor: recBgColor),
        initialCountryCode: "IN",
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: fixPadding * 1.4),
          border: InputBorder.none,
          hintText: getTranslation(context, 'login.enter_number'),
          hintStyle: medium16GreyD4,
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
