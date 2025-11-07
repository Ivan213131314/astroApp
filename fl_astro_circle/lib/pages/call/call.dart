import 'dart:async';

import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 0);

  bool isMute = false;

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

  void setCountDown() {
    const increaseSecondsBy = 1;
    if (mounted) {
      setState(
        () {
          final seconds = myDuration.inSeconds + increaseSecondsBy;
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
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.all(fixPadding * 2.0),
            height: size.height,
            width: size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                heightSpace,
                heightSpace,
                heightSpace,
                heightSpace,
                backButton(context),
                heightSpace,
                heightSpace,
                callTimeAndInfo(size, minutes, seconds),
                const Spacer(),
                callOptions(context),
                heightSpace,
                heightSpace,
                heightSpace,
              ],
            ),
          )
        ],
      ),
    );
  }

  callOptions(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            videoCallButton(),
            messageButton(),
            muteButton(),
          ],
        ),
        heightSpace,
        heightSpace,
        heightSpace,
        heightSpace,
        callEndButton(context)
      ],
    );
  }

  callEndButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 65,
        width: 65,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: red50Color,
        ),
        child: const Icon(
          CupertinoIcons.phone_down_fill,
          size: 30,
        ),
      ),
    );
  }

  muteButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () {
        setState(() {
          isMute = !isMute;
        });
      },
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isMute ? primaryColor : blueShade1,
        ),
        alignment: Alignment.center,
        child: Icon(
          isMute ? CupertinoIcons.mic_fill : CupertinoIcons.mic_slash_fill,
          color: whiteColor,
        ),
      ),
    );
  }

  messageButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/chat');
      },
      child: Container(
        height: 55,
        width: 55,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: blueShade1,
        ),
        alignment: Alignment.center,
        child: const Icon(
          CupertinoIcons.bubble_left_fill,
          color: whiteColor,
          size: 22,
        ),
      ),
    );
  }

  videoCallButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/videocall');
      },
      child: Container(
        height: 55,
        width: 55,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: blueShade1,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.videocam,
          color: whiteColor,
        ),
      ),
    );
  }

  callTimeAndInfo(Size size, String minutes, String seconds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: size.height * 0.2,
          width: size.height * 0.2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage("assets/call/image.png"),
            ),
          ),
        ),
        heightSpace,
        height5Space,
        const Text(
          "Brooklyn Simmons",
          style: medium18White,
        ),
        heightSpace,
        Text(
          "$minutes : $seconds",
          style: medium18White,
        )
      ],
    );
  }

  backButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 35,
            width: 35,
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
        ),
      ],
    );
  }
}
