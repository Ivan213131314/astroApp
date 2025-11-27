import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/services/universe_message_service.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:fl_astro_circle/services/cosmic_audio_generator.dart';
import 'package:fl_astro_circle/services/superwall_service.dart';
import 'package:fl_astro_circle/pages/universeMessage/universe_decipher_screen.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final UniverseMessageService messageService = UniverseMessageService();
  final NotificationStorageService storageService = NotificationStorageService();
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

  Future<void> playUniverseAudio(UniverseMessageData response) async {
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
        duration: const Duration(seconds: 2),
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

  Future<void> togglePlayPause(UniverseMessageData response) async {
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
      body: StreamBuilder<List<NatalChartData>>(
        stream: storageService.getNatalChartsStream(),
        builder: (context, natalSnapshot) {
          return StreamBuilder<List<CompatibilityData>>(
            stream: storageService.getCompatibilityStream(),
            builder: (context, compatSnapshot) {
              final natalCharts = natalSnapshot.data ?? [];
              final compatibilities = compatSnapshot.data ?? [];
              final universeMessages = messageService.responses;
              
              final hasAnyNotifications = natalCharts.isNotEmpty || 
                  compatibilities.isNotEmpty || 
                  universeMessages.isNotEmpty;

              if (!hasAnyNotifications) {
                return emptyNotificationListContent();
              }

              return allNotificationsContent(
                universeMessages: universeMessages,
                natalCharts: natalCharts,
                compatibilities: compatibilities,
              );
            },
          );
        },
      ),
    );
  }

  Widget allNotificationsContent({
    required List<UniverseMessageData> universeMessages,
    required List<NatalChartData> natalCharts,
    required List<CompatibilityData> compatibilities,
  }) {
    return ListView(
      padding: const EdgeInsets.only(bottom: fixPadding),
      physics: const BouncingScrollPhysics(),
      children: [
        // Universe Messages Section
        if (universeMessages.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: fixPadding * 2.0,
              vertical: fixPadding,
            ),
            child: Row(
              children: [
                Icon(Icons.rocket_launch_rounded, color: primaryColor, size: 20),
                widthSpace,
                Text(
                  'Universe Messages',
                  style: bold18White,
                ),
              ],
            ),
          ),
          ...universeMessages.map((response) => universeMessageItem(response)).toList(),
          heightSpace,
        ],

        // Natal Charts Section
        if (natalCharts.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: fixPadding * 2.0,
              vertical: fixPadding,
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: primaryColor, size: 20),
                widthSpace,
                Text(
                  'Natal Charts',
                  style: bold18White,
                ),
              ],
            ),
          ),
          ...natalCharts.map((chart) => natalChartItem(chart)).toList(),
          heightSpace,
        ],

        // Compatibility Section
        if (compatibilities.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: fixPadding * 2.0,
              vertical: fixPadding,
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: redColor, size: 20),
                widthSpace,
                Text(
                  'Compatibility Results',
                  style: bold18White,
                ),
              ],
            ),
          ),
          ...compatibilities.map((compat) => compatibilityItem(compat)).toList(),
          heightSpace,
        ],
      ],
    );
  }

  Widget universeMessageItem(UniverseMessageData response) {
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
          const SnackBar(
            backgroundColor: whiteColor,
            duration: Duration(milliseconds: 1500),
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
            heightBox(10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  await SuperwallService().showPaywall(
                    placement: "subscribe_button",
                    onPurchased: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          child: UniverseDecipherScreen(question: response.question),
                          type: PageTransitionType.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    onDeclined: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Subscribe to decipher universe messages',
                            style: medium14WhiteF4,
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: fixPadding * 1.2,
                    vertical: fixPadding * 0.8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, Color(0xFF7B5CFA)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hearing, color: whiteColor, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Decipher',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget natalChartItem(NatalChartData chart) {
    return Dismissible(
      key: Key(chart.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: fixPadding),
        color: redColor,
      ),
      onDismissed: (direction) {
        storageService.deleteNatalChart(chart.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: whiteColor,
            duration: Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Natal chart removed',
              style: bold15Black03,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          storageService.markNatalChartAsRead(chart.id);
          Navigator.pushNamed(
            context,
            '/natalchartDetail',
            arguments: {
              'name': chart.name,
              'dateOfBirth': chart.dateOfBirth,
              'timeOfBirth': chart.timeOfBirth,
              'location': chart.location,
              'planetsData': chart.planetsData,
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0,
            vertical: fixPadding,
          ),
          padding: const EdgeInsets.all(fixPadding * 1.5),
          decoration: BoxDecoration(
            color: chart.isRead ? blueShade1 : blueShade1.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10.0),
            border: chart.isRead
                ? null
                : Border.all(color: primaryColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color(0xFF1F2449),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: primaryColor,
                  size: 30,
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
                        Expanded(
                          child: Text(
                            'Natal Chart: ${chart.name}',
                            style: medium16WhiteF4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!chart.isRead)
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
                      '${chart.location} • ${chart.timeOfBirth}',
                      style: regualr14Grey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    heightBox(3),
                    Text(
                      chart.getTimeAgo(),
                      style: regualr14Grey,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: greyColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget compatibilityItem(CompatibilityData compat) {
    final avgPercent = ((compat.lovePercent + compat.businessPercent + compat.healthPercent) / 3 * 100).toInt();
    
    return Dismissible(
      key: Key(compat.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: fixPadding),
        color: redColor,
      ),
      onDismissed: (direction) {
        storageService.deleteCompatibility(compat.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: whiteColor,
            duration: Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Compatibility result removed',
              style: bold15Black03,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          storageService.markCompatibilityAsRead(compat.id);
          Navigator.pushNamed(
            context,
            '/compatibilityDetail',
            arguments: {
              'sign1': compat.sign1,
              'sign1Image': compat.sign1Image,
              'sign2': compat.sign2,
              'sign2Image': compat.sign2Image,
              'lovePercent': compat.lovePercent,
              'businessPercent': compat.businessPercent,
              'healthPercent': compat.healthPercent,
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0,
            vertical: fixPadding,
          ),
          padding: const EdgeInsets.all(fixPadding * 1.5),
          decoration: BoxDecoration(
            color: compat.isRead ? blueShade1 : blueShade1.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10.0),
            border: compat.isRead
                ? null
                : Border.all(color: redColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color(0xFF1F2449),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: redColor,
                  size: 30,
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
                        Expanded(
                          child: Text(
                            '${compat.sign1} & ${compat.sign2}',
                            style: medium16WhiteF4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!compat.isRead)
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
                      'Compatibility: $avgPercent%',
                      style: regualr14Grey,
                    ),
                    heightBox(3),
                    Text(
                      compat.getTimeAgo(),
                      style: regualr14Grey,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: greyColor),
            ],
          ),
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
