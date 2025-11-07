import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isMute = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/videocall/image.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 1.0],
                  colors: [
                    scaffoldBgColor.withValues(alpha: 0.1),
                    scaffoldBgColor.withValues(alpha: 0.5)
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: fixPadding * 2.0),
                    child: backButton(context),
                  ),
                  Column(
                    children: [
                      callerImage(size),
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      callOptions(),
                      heightSpace,
                      heightSpace,
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  callerImage(Size size) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        height: size.height * 0.2,
        width: size.width * 0.32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          image: const DecorationImage(
            image: AssetImage("assets/videocall/image2.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  callOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        messageButton(),
        callEndButton(),
        muteButton(),
      ],
    );
  }

  muteButton() {
    return GestureDetector(
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
        ),
      ),
    );
  }

  callEndButton() {
    return GestureDetector(
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
        alignment: Alignment.center,
        child: const Icon(
          CupertinoIcons.phone_down_fill,
          color: whiteColor,
          size: 32,
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
        child: const Icon(CupertinoIcons.bubble_left_fill),
      ),
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
            margin: const EdgeInsets.only(top: fixPadding * 2.0),
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
