import 'dart:async';
import 'package:fl_astro_circle/pages/screens.dart';
import 'package:fl_astro_circle/pages/universeMessage/universe_decipher_screen.dart';
import 'package:fl_astro_circle/services/universe_message_service.dart';
import 'package:fl_astro_circle/services/superwall_service.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;
import 'package:page_transition/page_transition.dart';

class UniverseMessageScreen extends StatefulWidget {
  const UniverseMessageScreen({super.key});

  @override
  State<UniverseMessageScreen> createState() => _UniverseMessageScreenState();
}

class _UniverseMessageScreenState extends State<UniverseMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  final UniverseMessageService messageService = UniverseMessageService();
  
  MessageStatus currentStatus = MessageStatus.idle;
  Timer? responseTimer;
  bool showReceivedDialog = false;

  final List<String> quickSuggestions = [
    "When will I find my love?",
    "When will I get rich?",
    "What is my purpose?",
    "Will I be successful?",
    "When will I marry?",
    "What awaits me?",
    "Is my partner loyal?",
    "Will I change careers?",
    "When will I travel?",
    "What is my destiny?",
  ];

  @override
  void initState() {
    super.initState();
    messageService.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    responseTimer?.cancel();
    super.dispose();
  }

  void sendMessageToUniverse() {
    if (messageController.text.trim().isEmpty) return;
    
    setState(() {
      currentStatus = MessageStatus.sending;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          currentStatus = MessageStatus.waiting;
        });
        
        // Получение ответа от вселенной через 5 секунд
        responseTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            messageService.addUniverseResponse(messageController.text);
            setState(() {
              showReceivedDialog = true;
            });
            
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  showReceivedDialog = false;
                  currentStatus = MessageStatus.idle;
                  messageController.clear();
                });
              }
            });
          }
        });
      }
    });
  }

  String getTooltipText() {
    switch (currentStatus) {
      case MessageStatus.idle:
        return "Your message will be sent to the universe via NASA satellites. The universe will respond with an audio message that we will decipher.";
      case MessageStatus.sending:
        return "Sending your message to the universe via NASA satellites...";
      case MessageStatus.waiting:
        return "Message sent to the universe! Waiting for a response from space. This may take several hours to a day.";
      case MessageStatus.received:
        return "Message from space received!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
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
            const SizedBox(width: 16),
            const Text(
              'Universe Message',
              style: bold20White,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: badges.Badge(
              showBadge: messageService.unreadCount > 0,
              badgeContent: Text(
                '${messageService.unreadCount}',
                style: const TextStyle(color: whiteColor, fontSize: 10),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: redColor,
                padding: EdgeInsets.all(6),
              ),
              child: IconButton(
                icon: const Icon(LineAwesomeIcons.bell, color: whiteF4Color),
                onPressed: () {
                  messageService.markAllAsRead();
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const NotificationScreen(),
                      type: PageTransitionType.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
                    padding: const EdgeInsets.all(fixPadding * 2),
                    decoration: BoxDecoration(
                      color: blueShade1,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Звездочки вокруг конверта
                              Positioned(
                                top: 0,
                                left: 5,
                                child: Icon(
                                  Icons.star,
                                  size: 14,
                                  color: primaryColor.withValues(alpha: 0.7),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 5,
                                child: Icon(
                                  Icons.star,
                                  size: 14,
                                  color: primaryColor.withValues(alpha: 0.7),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 0,
                                child: Icon(
                                  Icons.star,
                                  size: 12,
                                  color: primaryColor.withValues(alpha: 0.6),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                right: 0,
                                child: Icon(
                                  Icons.star,
                                  size: 12,
                                  color: primaryColor.withValues(alpha: 0.6),
                                ),
                              ),
                              // Конверт в центре
                              const Icon(
                                Icons.mail_outline_rounded,
                                size: 38,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                        heightSpace,
                        const Text(
                          'Ready? Send a message to space',
                          style: bold18White,
                          textAlign: TextAlign.center,
                        ),
                        heightSpace,
                        heightSpace,
                        const Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: primaryColor,
                              size: 20,
                            ),
                            widthSpace,
                            Expanded(
                              child: Text(
                                'Ask anything that\'s on your mind',
                                style: medium14WhiteF4,
                              ),
                            ),
                          ],
                        ),
                        heightSpace,
                        const Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: primaryColor,
                              size: 20,
                            ),
                            widthSpace,
                            Expanded(
                              child: Text(
                                'Your message stays private and confidential',
                                style: medium14WhiteF4,
                              ),
                            ),
                          ],
                        ),
                        heightSpace,
                        heightSpace,
                        Container(
                          padding: const EdgeInsets.all(fixPadding * 1.5),
                          decoration: BoxDecoration(
                            color: scaffoldBgColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            getTooltipText(),
                            style: regualr14Grey,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 2),
              decoration: BoxDecoration(
                color: blueShade1,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentStatus == MessageStatus.idle) ...[
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: quickSuggestions.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                messageController.text = quickSuggestions[index];
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: fixPadding),
                              padding: const EdgeInsets.symmetric(
                                horizontal: fixPadding * 1.5,
                                vertical: fixPadding,
                              ),
                              decoration: BoxDecoration(
                                color: scaffoldBgColor,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  quickSuggestions[index],
                                  style: medium14WhiteF4,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    heightSpace,
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 1.5),
                          decoration: BoxDecoration(
                            color: scaffoldBgColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: messageController,
                            enabled: currentStatus == MessageStatus.idle,
                            style: regualr16WhiteF4,
                            decoration: const InputDecoration(
                              hintText: 'Write a message',
                              hintStyle: regualr16Grey,
                              border: InputBorder.none,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                      widthSpace,
                      GestureDetector(
                        onTap: currentStatus == MessageStatus.idle
                            ? sendMessageToUniverse
                            : null,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: currentStatus == MessageStatus.idle
                                ? primaryColor
                                : greyColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (currentStatus != MessageStatus.idle) ...[
                    heightSpace,
                    Text(
                      currentStatus == MessageStatus.sending
                          ? 'Sending to space...'
                          : 'Waiting for response...',
                      style: medium14Grey,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (showReceivedDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
                    padding: const EdgeInsets.all(fixPadding * 3),
                    decoration: BoxDecoration(
                      color: blueShade1,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.mark_email_read_rounded,
                          size: 80,
                          color: greenColor,
                        ),
                        heightSpace,
                        heightSpace,
                        const Text(
                          'Message from space received!',
                          style: bold20White,
                          textAlign: TextAlign.center,
                        ),
                        heightSpace,
                        const Text(
                          'Check notifications to decipher',
                          style: medium16Grey,
                          textAlign: TextAlign.center,
                        ),
                        heightSpace,
                        heightSpace,
                        GestureDetector(
                          onTap: () async {
                            // Показать Superwall paywall
                            await SuperwallService().showPaywall(
                              placement: "subscribe_button",
                              onPurchased: () {
                                // После покупки переходим к расшифровке
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: UniverseDecipherScreen(
                                      question: messageController.text,
                                    ),
                                    type: PageTransitionType.rightToLeft,
                                    duration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              onDeclined: () {
                                // Пользователь отклонил - можно показать сообщение
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Subscribe to unlock universe messages'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: fixPadding * 2,
                              vertical: fixPadding * 1.5,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [primaryColor, Color(0xFF7B5CFA)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.hearing, color: whiteColor, size: 20),
                                widthSpace,
                                Text(
                                  'Decipher Universe Message',
                                  style: bold16WhiteF4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum MessageStatus {
  idle,
  sending,
  waiting,
  received,
}

