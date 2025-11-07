import 'dart:async';

import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final defaultPinTheme = PinTheme(
    height: 50,
    width: 50,
    textStyle: medium22WhiteF4,
    margin: const EdgeInsets.symmetric(horizontal: fixPadding / 1.5),
    decoration: BoxDecoration(
      color: recBgColor,
      borderRadius: BorderRadius.circular(5.0),
    ),
  );

  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = const Duration(minutes: 5));
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    if (mounted) {
      setState(
        () {
          final seconds = myDuration.inSeconds - reduceSecondsBy;
          if (seconds < 0) {
            countdownTimer!.cancel();
          } else {
            myDuration = Duration(seconds: seconds);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Scaffold(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                backButton(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: fixPadding * 2.0),
                    children: [
                      verificationTitle(),
                      heightSpace,
                      height5Space,
                      confirmationText(),
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      otpField(),
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      timer(minutes, seconds),
                      heightSpace,
                      heightSpace,
                      verifyButton(),
                      height5Space,
                      resendButton(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  resendButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          if (myDuration == const Duration(seconds: 0)) {
            resetTimer();
            startTimer();
          }
        },
        child: Text(
          getTranslation(context, 'verification.resend'),
          style: medium16White,
        ),
      ),
    );
  }

  verifyButton() {
    return InkWell(
      onTap: () {
        Timer(const Duration(seconds: 3), () {
          Navigator.popAndPushNamed(context, '/bottombar');
          stopTimer();
        });
        pleaseWaitDialog();
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding * 1.2),
        decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.25),
                blurRadius: 6,
              )
            ]),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'verification.verify'),
          style: bold20White,
        ),
      ),
    );
  }

  pleaseWaitDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0, vertical: fixPadding * 2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(
                  color: primaryColor,
                  radius: 18,
                ),
                heightSpace,
                Text(
                  getTranslation(context, 'verification.please_wait'),
                  style: medium18Primary,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  timer(String minutes, String seconds) {
    return Text(
      "$minutes:$seconds",
      textAlign: TextAlign.center,
      style: medium16White,
    );
  }

  otpField() {
    return Pinput(
      defaultPinTheme: defaultPinTheme,
      cursor: Container(
        height: 20,
        width: 1.5,
        color: primaryColor,
      ),
      onCompleted: (completed) {
        Timer(const Duration(seconds: 3), () {
          Navigator.popAndPushNamed(context, '/bottombar');
          stopTimer();
        });
        pleaseWaitDialog();
      },
    );
  }

  confirmationText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'verification.confirm'),
        style: medium15Grey,
        textAlign: TextAlign.center,
      ),
    );
  }

  verificationTitle() {
    return Text(
      getTranslation(context, 'verification.verification'),
      style: bold24WhiteF4,
      textAlign: TextAlign.center,
    );
  }

  backButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 35,
        width: 35,
        margin: const EdgeInsets.only(
            left: fixPadding * 2.0,
            right: fixPadding * 2,
            top: fixPadding * 2,
            bottom: fixPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: recBgColor,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: whiteColor,
          size: 22,
        ),
      ),
    );
  }
}
