import 'dart:math';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:fl_astro_circle/services/cosmic_audio_generator.dart';
import 'package:fl_astro_circle/services/superwall_service.dart';
import 'package:fl_astro_circle/pages/universeMessage/universe_decipher_screen.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rxdart/rxdart.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationStorageService storageService = NotificationStorageService();
  final CosmicAudioGenerator audioGenerator = CosmicAudioGenerator();
  String? currentPlayingId;
  
  // Сохраняем callback для правильной очистки
  late final VoidCallback _audioGeneratorListener;

  @override
  void initState() {
    super.initState();
    
    _audioGeneratorListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    
    audioGenerator.setOnStateChanged(_audioGeneratorListener);
  }

  @override
  void dispose() {
    // Очищаем listeners чтобы предотвратить утечку памяти
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
      await storageService.updateUniverseMessageAudioPath(response.id, filePath);
    }
    
    storageService.markUniverseMessageAsRead(response.id);
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
      body: StreamBuilder<List<dynamic>>(
        stream: Rx.combineLatest4(
          storageService.getNatalChartsStream(),
          storageService.getCompatibilityStream(),
          storageService.getNumerologyStream(),
          storageService.getUniverseMessagesStream(),
          (natalCharts, compatibilities, numerologies, universeMessages) {
            return [natalCharts, compatibilities, numerologies, universeMessages];
          },
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final data = snapshot.data!;
          final natalCharts = data[0] as List<NatalChartData>;
          final compatibilities = data[1] as List<CompatibilityData>;
          final numerologies = data[2] as List<NumerologyData>;
          final universeMessages = data[3] as List<UniverseMessageData>;

          final hasAnyNotifications = natalCharts.isNotEmpty || 
              compatibilities.isNotEmpty || 
              numerologies.isNotEmpty ||
              universeMessages.isNotEmpty;

          if (!hasAnyNotifications) {
            return emptyNotificationListContent();
          }

          return allNotificationsContent(
            universeMessages: universeMessages,
            natalCharts: natalCharts,
            compatibilities: compatibilities,
            numerologies: numerologies,
          );
        },
      ),
    );
  }

  Widget allNotificationsContent({
    required List<UniverseMessageData> universeMessages,
    required List<NatalChartData> natalCharts,
    required List<CompatibilityData> compatibilities,
    required List<NumerologyData> numerologies,
  }) {
    // Объединяем все уведомления в один список с типом
    final List<_NotificationItem> allItems = [
      ...universeMessages.map((m) => _NotificationItem(
        type: _NotificationType.universe,
        data: m,
        isRead: m.isRead,
        createdAt: m.createdAt,
      )),
      ...natalCharts.map((c) => _NotificationItem(
        type: _NotificationType.natal,
        data: c,
        isRead: c.isRead,
        createdAt: c.createdAt,
      )),
      ...compatibilities.map((c) => _NotificationItem(
        type: _NotificationType.compatibility,
        data: c,
        isRead: c.isRead,
        createdAt: c.createdAt,
      )),
      ...numerologies.map((n) => _NotificationItem(
        type: _NotificationType.numerology,
        data: n,
        isRead: n.isRead,
        createdAt: n.createdAt,
      )),
    ];

    // Сортируем: непрочитанные вверху, затем по дате (новые сверху)
    allItems.sort((a, b) {
      // Сначала по isRead (false < true, чтобы непрочитанные были вверху)
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1;
      }
      // Затем по дате (новые сверху)
      return b.createdAt.compareTo(a.createdAt);
    });

    // Разделяем на новые и прочитанные
    final unreadItems = allItems.where((item) => !item.isRead).toList();
    final readItems = allItems.where((item) => item.isRead).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: fixPadding),
      physics: const BouncingScrollPhysics(),
      children: [
        // Секция "New" для непрочитанных уведомлений
        if (unreadItems.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: fixPadding * 2.0,
              vertical: fixPadding,
            ),
            child: Row(
              children: [
                Icon(Icons.fiber_new_rounded, color: redColor, size: 24),
                widthSpace,
                Text(
                  'New',
                  style: bold18White,
                ),
              ],
            ),
          ),
          ...unreadItems.map((item) => _buildNotificationItem(item)).toList(),
          heightSpace,
        ],

        // Секция "Earlier" для прочитанных уведомлений
        if (readItems.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: fixPadding * 2.0,
              vertical: fixPadding,
            ),
            child: Row(
              children: [
                Icon(Icons.history, color: greyColor, size: 20),
                widthSpace,
                Text(
                  'Earlier',
                  style: bold18White,
                ),
              ],
            ),
          ),
          ...readItems.map((item) => _buildNotificationItem(item)).toList(),
          heightSpace,
        ],
      ],
    );
  }

  Widget _buildNotificationItem(_NotificationItem item) {
    switch (item.type) {
      case _NotificationType.universe:
        return universeMessageItem(item.data as UniverseMessageData);
      case _NotificationType.natal:
        return natalChartItem(item.data as NatalChartData);
      case _NotificationType.compatibility:
        return compatibilityItem(item.data as CompatibilityData);
      case _NotificationType.numerology:
        return numerologyItem(item.data as NumerologyData);
    }
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
        storageService.deleteUniverseMessage(response.id);
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
              'docId': chart.id,
              'name': chart.name,
              'dateOfBirth': chart.dateOfBirth,
              'timeOfBirth': chart.timeOfBirth,
              'location': chart.location,
              'planetsData': chart.planetsData,
              'sunSign': chart.sunSign,
              'moonSign': chart.moonSign,
              'risingSign': chart.risingSign,
              'sunTeaser': chart.sunTeaser,
              'moonTeaser': chart.moonTeaser,
              'risingTeaser': chart.risingTeaser,
              'fromNotifications': true,
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
                child: Center(
                  child: CustomPaint(
                    size: const Size(36, 36),
                    painter: _NatalChartIconPainter(),
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
                    if (chart.sunSign != null) ...[
                      heightBox(3),
                      Text(
                        '☉ ${chart.sunSign}${chart.moonSign != null ? ' • ☽ ${chart.moonSign}' : ''}',
                        style: regualr14Grey,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
              'docId': compat.id,
              'sign1': compat.sign1,
              'sign1Image': compat.sign1Image,
              'sign2': compat.sign2,
              'sign2Image': compat.sign2Image,
              'person1Name': compat.name1,
              'person2Name': compat.name2,
              'person1BirthDate': compat.birthDate1,
              'person2BirthDate': compat.birthDate2,
              'lovePercent': compat.lovePercent,
              'businessPercent': compat.businessPercent,
              'healthPercent': compat.healthPercent,
              'loveTeaser': compat.loveTeaser,
              'businessTeaser': compat.businessTeaser,
              'healthTeaser': compat.healthTeaser,
              'fromNotifications': true,
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
              // Показываем иконки знаков
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color(0xFF1F2449),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 5,
                      child: Image.asset(
                        compat.sign1Image,
                        height: 28,
                        width: 28,
                        errorBuilder: (_, __, ___) => const Icon(Icons.star, color: primaryColor, size: 28),
                      ),
                    ),
                    Positioned(
                      right: 5,
                      child: Image.asset(
                        compat.sign2Image,
                        height: 28,
                        width: 28,
                        errorBuilder: (_, __, ___) => const Icon(Icons.star, color: primaryColor, size: 28),
                      ),
                    ),
                    const Positioned(
                      bottom: 5,
                      child: Icon(Icons.favorite, color: redColor, size: 16),
                    ),
                  ],
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
                            compat.displayTitle,
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
                    if (compat.displaySubtitle.isNotEmpty) ...[
                      heightBox(2),
                      Text(
                        compat.displaySubtitle,
                        style: const TextStyle(color: primaryColor, fontSize: 12),
                      ),
                    ],
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

  Widget numerologyItem(NumerologyData numerology) {
    return Dismissible(
      key: Key(numerology.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: fixPadding),
        color: redColor,
      ),
      onDismissed: (direction) {
        storageService.deleteNumerology(numerology.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: whiteColor,
            duration: Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Numerology result removed',
              style: bold15Black03,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          storageService.markNumerologyAsRead(numerology.id);
          // Создаем NumerologyResult из NumerologyData
          Navigator.pushNamed(
            context,
            '/numerologyResult',
            arguments: {
              'result': _convertToNumerologyResult(numerology),
              'docId': numerology.id,
              'fromNotifications': true,
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
            color: numerology.isRead ? blueShade1 : blueShade1.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10.0),
            border: numerology.isRead
                ? null
                : Border.all(color: primaryColor, width: 2),
          ),
          child: Row(
            children: [
              // Показываем число судьбы с космической иконкой
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: const Color(0xFF1F2449),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(50, 50),
                    painter: _NumerologyIconPainter(luckyNumber: numerology.luckyNumber),
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
                            'Numerology Analysis',
                            style: medium16WhiteF4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!numerology.isRead)
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
                      'Life Path Number ${numerology.luckyNumber} • ${numerology.birthDate}',
                      style: regualr14Grey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    heightBox(3),
                    Text(
                      numerology.getTimeAgo(),
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

  // Конвертация NumerologyData в NumerologyResult для навигации
  dynamic _convertToNumerologyResult(NumerologyData data) {
    // Импортируем через dynamic чтобы избежать циклических зависимостей
    // NumerologyResult из numorology_service.dart
    return {
      'luckyNumber': data.luckyNumber,
      'birthDate': data.birthDate,
      'traits': data.traits,
      'aboutCharacter': data.aboutCharacter,
      'aboutBehavior': data.aboutBehavior,
      'aboutResponsibility': data.aboutResponsibility,
    };
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


// Вспомогательные классы для сортировки уведомлений
enum _NotificationType { universe, natal, compatibility, numerology }

class _NotificationItem {
  final _NotificationType type;
  final dynamic data;
  final bool isRead;
  final DateTime createdAt;

  _NotificationItem({
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });
}

/// Custom painter для иконки натальной карты
class _NatalChartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Внешний круг
    canvas.drawCircle(center, radius - 1, paint);
    
    // Внутренний круг
    canvas.drawCircle(center, radius * 0.7, paint..strokeWidth = 1);
    
    // 12 делений (знаки зодиака)
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final outerPoint = Offset(
        center.dx + (radius - 1) * cos(angle),
        center.dy + (radius - 1) * sin(angle),
      );
      final innerPoint = Offset(
        center.dx + radius * 0.7 * cos(angle),
        center.dy + radius * 0.7 * sin(angle),
      );
      canvas.drawLine(outerPoint, innerPoint, paint..strokeWidth = 0.8);
    }
    
    // Центральная точка
    canvas.drawCircle(center, 2, paint..style = PaintingStyle.fill);
    
    // Геометрические линии (аспекты)
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.5;
    paint.color = primaryColor.withValues(alpha: 0.6);
    
    // Треугольник
    final triangleRadius = radius * 0.5;
    for (int i = 0; i < 3; i++) {
      final angle1 = (i * 120 - 90) * pi / 180;
      final angle2 = ((i + 1) * 120 - 90) * pi / 180;
      final p1 = Offset(
        center.dx + triangleRadius * cos(angle1),
        center.dy + triangleRadius * sin(angle1),
      );
      final p2 = Offset(
        center.dx + triangleRadius * cos(angle2),
        center.dy + triangleRadius * sin(angle2),
      );
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter для иконки нумерологии
class _NumerologyIconPainter extends CustomPainter {
  final int luckyNumber;
  
  _NumerologyIconPainter({required this.luckyNumber});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Внешнее свечение/орбита
    canvas.drawCircle(center, radius - 2, paint);
    
    // Второе кольцо
    paint.color = primaryColor.withValues(alpha: 0.5);
    canvas.drawCircle(center, radius * 0.75, paint);
    
    // Звёздочки по кругу (9 точек для чисел 1-9)
    paint.style = PaintingStyle.fill;
    paint.color = primaryColor.withValues(alpha: 0.6);
    for (int i = 0; i < 9; i++) {
      final angle = (i * 40 - 90) * pi / 180;
      final starPos = Offset(
        center.dx + (radius - 5) * cos(angle),
        center.dy + (radius - 5) * sin(angle),
      );
      // Подсветить звезду для активного числа
      if (i + 1 == luckyNumber) {
        paint.color = primaryColor;
        canvas.drawCircle(starPos, 3, paint);
      } else {
        paint.color = primaryColor.withValues(alpha: 0.4);
        canvas.drawCircle(starPos, 1.5, paint);
      }
    }
    
    // Центральный круг с градиентом
    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.8),
          primaryColor.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.45));
    canvas.drawCircle(center, radius * 0.45, centerPaint);
    
    // Рисуем число в центре
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$luckyNumber',
        style: const TextStyle(
          color: whiteColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _NumerologyIconPainter oldDelegate) => 
      oldDelegate.luckyNumber != luckyNumber;
}
