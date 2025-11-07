import 'dart:io';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/pages/screens.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  DateTime? backPressTime;

  final itemList = [
    LineAwesomeIcons.home_solid,
    CupertinoIcons.ellipses_bubble,
    LineAwesomeIcons.bell,
    LineAwesomeIcons.user,
  ];

  List pages = const [
    HomeScreen(),
    MessageScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        bool backStatus = onWillPop();
        if (backStatus) {
          exit(0);
        }
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light),
        child: Scaffold(
          body: pages.elementAt(selectedIndex),
          backgroundColor: scaffoldBgColor,
          bottomNavigationBar: bottomNavigationBar(),
        ),
      ),
    );
  }

  bottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: scaffoldBgColor,
        boxShadow: [
          BoxShadow(
            color: recBgColor.withValues(alpha: 0.45),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(itemList.length, (index) {
          return InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color:
                    selectedIndex == index ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                itemList[index],
                color: whiteF4Color,
              ),
            ),
          );
        }),
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
