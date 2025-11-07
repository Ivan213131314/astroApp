import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final notificationList = [
    {
      "image": "assets/notification/aries.png",
      "title": "Your weekly horoscope is here 🙏 🙏",
      "description":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet",
      "time": "2min ago"
    },
    {
      "image": "assets/notification/astrology.png",
      "title": "Natal chart😇🙏 ",
      "description":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet",
      "time": "2min ago"
    },
    {
      "image": "assets/notification/aries.png",
      "title": "Your daily horoscope is here 🙏 🙏",
      "description":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet",
      "time": "2min ago"
    },
    {
      "image": "assets/notification/natal-chart.png",
      "title": "Your weekly horoscope is here 🙏 🙏",
      "description":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet",
      "time": "2min ago"
    },
    {
      "image": "assets/notification/astrology.png",
      "title": "Your day at glance",
      "description":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet",
      "time": "2min ago"
    },
    {
      "image": "assets/notification/aries.png",
      "title": "Your weekly horoscope is here 🙏 🙏",
      "description":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet",
      "time": "2min ago"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: Text(
          getTranslation(context, 'notification.notification'),
          style: bold20White,
        ),
      ),
      body: notificationList.isEmpty
          ? emptyNotificationListContent()
          : notificationListContent(),
    );
  }

  emptyNotificationListContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LineAwesomeIcons.bell_slash,
            color: greyColor,
            size: 40,
          ),
          heightSpace,
          Text(
            getTranslation(context, 'notification.no_notification'),
            style: medium16Grey,
          )
        ],
      ),
    );
  }

  notificationListContent() {
    return ListView.builder(
      itemCount: notificationList.length,
      padding: const EdgeInsets.only(bottom: fixPadding),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: fixPadding),
            color: redColor,
          ),
          onDismissed: (direction) {
            setState(() {
              notificationList.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: whiteColor,
                duration: const Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
                content: Text(
                  getTranslation(context, 'notification.remove_notification'),
                  style: bold15Black03,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0, vertical: fixPadding),
            padding: const EdgeInsets.all(fixPadding),
            decoration: BoxDecoration(
              color: blueShade1,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  padding: const EdgeInsets.all(fixPadding / 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xFF1F2449),
                    boxShadow: [
                      BoxShadow(
                        color: blueShade1.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Image.asset(
                    notificationList[index]['image'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                widthSpace,
                width5Space,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificationList[index]['title'].toString(),
                        style: medium16WhiteF4,
                      ),
                      heightBox(3),
                      Text(
                        notificationList[index]['description'].toString(),
                        style: regualr14Grey,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      heightBox(3),
                      Text(
                        notificationList[index]['time'].toString(),
                        style: regualr14Grey,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
