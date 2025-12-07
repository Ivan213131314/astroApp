import 'dart:io';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/pages/screens.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:fl_astro_circle/services/universe_message_service.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class BottomBar extends StatefulWidget {
  final int initialIndex;
  const BottomBar({super.key, this.initialIndex = 0});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  DateTime? backPressTime;
  final NotificationStorageService _notificationService = NotificationStorageService();
  final UniverseMessageService _universeMessageService = UniverseMessageService();

  final itemList = [
    LineAwesomeIcons.home_solid,
    CupertinoIcons.heart,
    Icons.mail_outline_rounded,
    LineAwesomeIcons.bell,
    LineAwesomeIcons.user,
  ];

  List pages = const [
    HomeScreen(),
    CompatibilityScreen(),
    UniverseMessageScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    // Load universe messages to show badge count
    _universeMessageService.loadResponses();
  }
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
      child: StreamBuilder<int>(
        stream: _notificationService.getUnreadCountStream(),
        builder: (context, notificationSnapshot) {
          final notificationUnreadCount = notificationSnapshot.data ?? 0;
          
          return ListenableBuilder(
            listenable: _universeMessageService,
            builder: (context, child) {
              final universeUnreadCount = _universeMessageService.unreadCount;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(itemList.length, (index) {
                  final isCenterIcon = index == 2; // Center icon (mail/envelope)
                  final containerSize = isCenterIcon ? 65.0 : 45.0;
                  final iconSize = isCenterIcon ? 32.0 : 24.0;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      height: containerSize,
                      width: containerSize,
                      decoration: BoxDecoration(
                        color: selectedIndex == index ? primaryColor : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: index == 2
                          ? _buildUniverseMessageIcon(universeUnreadCount, iconSize)
                          : index == 3 
                              ? _buildNotificationIcon(notificationUnreadCount, iconSize)
                              : Icon(
                                  itemList[index],
                                  color: whiteF4Color,
                                  size: iconSize,
                                ),
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationIcon(int unreadCount, double iconSize) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          itemList[3],
          color: whiteF4Color,
          size: iconSize,
        ),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: redColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: whiteColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUniverseMessageIcon(int unreadCount, double iconSize) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          itemList[2],
          color: whiteF4Color,
          size: iconSize,
        ),
        if (unreadCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: redColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: whiteColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
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
