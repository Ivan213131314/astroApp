import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/services/universe_message_service.dart';
import 'package:fl_astro_circle/services/cosmic_audio_generator.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final UniverseMessageService messageService = UniverseMessageService();
  final CosmicAudioGenerator audioGenerator = CosmicAudioGenerator();
  String? currentPlayingId;

  @override
  void initState() {
    super.initState();
    messageService.loadResponses();
    messageService.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    audioGenerator.setOnStateChanged(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    audioGenerator.dispose();
    super.dispose();
  }

  Future<void> playUniverseAudio(UniverseResponse response) async {
    if (currentPlayingId == response.id) {
      return;
    }

    if (currentPlayingId != null) {
      await audioGenerator.stop();
    }

    setState(() {
      currentPlayingId = response.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: blueShade1,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: primaryColor),
            widthSpace,
            Expanded(
              child: Text(
                response.audioFilePath == null
                    ? 'Generating cosmic audio message...'
                    : 'Playing cosmic audio message (${response.audioDuration}s)',
                style: medium14WhiteF4,
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    final filePath = await audioGenerator.playCosmicMessage(
      messageId: response.id,
      durationSeconds: response.audioDuration,
      audioFilePath: response.audioFilePath,
      onComplete: () {
        if (mounted) {
          setState(() {
            currentPlayingId = null;
          });
        }
      },
    );
    
    if (response.audioFilePath == null && filePath != null) {
      await messageService.updateAudioFilePath(response.id, filePath);
    }
    
    messageService.markAsRead(response.id);
  }

  Future<void> togglePlayPause(UniverseResponse response) async {
    if (currentPlayingId == response.id) {
      if (audioGenerator.isPlaying) {
        await audioGenerator.pause();
      } else {
        await audioGenerator.resume();
      }
      setState(() {});
    } else {
      await playUniverseAudio(response);
    }
  }

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
    final hasUniverseMessages = messageService.responses.isNotEmpty;
    final hasRegularNotifications = notificationList.isNotEmpty;
    
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
      body: !hasUniverseMessages && !hasRegularNotifications
          ? emptyNotificationListContent()
          : allNotificationsContent(),
    );
  }

  allNotificationsContent() {
    return ListView(
      padding: const EdgeInsets.only(bottom: fixPadding),
      physics: const BouncingScrollPhysics(),
      children: [
        if (messageService.responses.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: fixPadding * 2.0,
              vertical: fixPadding,
            ),
            child: Row(
              children: [
                const Icon(Icons.rocket_launch_rounded, color: primaryColor, size: 20),
                widthSpace,
                const Text(
                  'Universe Messages',
                  style: bold18White,
                ),
              ],
            ),
          ),
          ...messageService.responses.map((response) => universeMessageItem(response)).toList(),
          heightSpace,
          heightSpace,
        ],
        if (notificationList.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: fixPadding * 2.0,
              vertical: fixPadding,
            ),
            child: Text(
              'Other Notifications',
              style: bold18White,
            ),
          ),
          ...List.generate(notificationList.length, (index) => regularNotificationItem(index)),
        ],
      ],
    );
  }

  Widget universeMessageItem(UniverseResponse response) {
    final isCurrentPlaying = currentPlayingId == response.id;
    
    return Dismissible(
      key: Key(response.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: fixPadding),
        color: redColor,
      ),
      onDismissed: (direction) {
        messageService.deleteResponse(response.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: whiteColor,
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Universe message removed',
              style: bold15Black03,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0,
          vertical: fixPadding,
        ),
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          color: response.isRead ? blueShade1 : blueShade1.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10.0),
          border: response.isRead
              ? null
              : Border.all(color: primaryColor, width: 2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => togglePlayPause(response),
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFF1F2449),
                      gradient: LinearGradient(
                        colors: [primaryColor.withValues(alpha: 0.3), Colors.transparent],
                      ),
                    ),
                    child: Icon(
                      isCurrentPlaying && audioGenerator.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: primaryColor,
                      size: 35,
                    ),
                  ),
                ),
                widthSpace,
                width5Space,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Universe Response 🌌 ✨',
                              style: medium16WhiteF4,
                            ),
                          ),
                          if (!response.isRead)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: redColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      heightBox(3),
                      Text(
                        'Your question: ${response.question}',
                        style: regualr14Grey,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      heightBox(3),
                      Text(
                        response.getTimeAgo(),
                        style: regualr14Grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isCurrentPlaying) ...[
              heightBox(10),
              StreamBuilder<Duration>(
                stream: audioGenerator.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final totalDuration = Duration(seconds: response.audioDuration);
                  final progress = totalDuration.inMilliseconds > 0
                      ? position.inMilliseconds / totalDuration.inMilliseconds
                      : 0.0;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            _formatDuration(position),
                            style: regualr14Grey,
                          ),
                          const Spacer(),
                          Text(
                            _formatDuration(totalDuration),
                            style: regualr14Grey,
                          ),
                        ],
                      ),
                      heightBox(5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: const Color(0xFF1F2449),
                          valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget regularNotificationItem(int index) {
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
          horizontal: fixPadding * 2.0,
          vertical: fixPadding,
        ),
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
}
