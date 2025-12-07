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
  String? currentQuestionForDialog; // Track which question's response is being shown

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
    messageService.loadResponses();
    
    // Check for existing unread messages when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUnreadMessages();
    });
    
    messageService.addListener(() {
      if (mounted) {
        _checkForUnreadMessages();
      }
    });
  }
  
  void _checkForUnreadMessages() {
    if (!showReceivedDialog && 
        messageService.responses.isNotEmpty && 
        currentStatus == MessageStatus.idle) {
      final latestMessage = messageService.responses.first;
      if (!latestMessage.isRead) {
        setState(() {
          showReceivedDialog = true;
          currentQuestionForDialog = latestMessage.question;
        });
      }
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    responseTimer?.cancel();
    super.dispose();
  }

  void sendMessageToUniverse() {
    if (messageController.text.trim().isEmpty) return;
    
    final questionText = messageController.text;
    
    setState(() {
      currentStatus = MessageStatus.sending;
    });

    // Анимация висит 10 секунд, потом сразу показываем диалог
    responseTimer = Timer(const Duration(seconds: 10), () {
      // Сохраняем сообщение в Firestore
      messageService.addUniverseResponse(questionText);
      
      if (mounted) {
        currentQuestionForDialog = questionText;
        setState(() {
          showReceivedDialog = true;
          currentStatus = MessageStatus.idle;
        });
        messageController.clear();
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
              padding: const EdgeInsets.all(fixPadding * 2),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: currentStatus == MessageStatus.sending
                    ? TweenAnimationBuilder<double>(
                        key: const ValueKey('sending'),
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 10),
                        builder: (context, value, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(0, -50 * value),
                                child: Opacity(
                                  opacity: 1.0 - (value > 0.8 ? (value - 0.8) * 5 : 0.0),
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Ripples
                                        ...List.generate(3, (index) {
                                          double localValue = (value * 5) % (1 + index * 0.5); 
                                          // Simple cyclic ripple effect derived from main value would be tricky without separate controllers,
                                          // but we can use the main value for expansion if we want just one wave or simplified ones.
                                          // Let's stick to a simpler static animation or reusing the previous independent builders if we want detailed ripple loops.
                                          // However, nesting builders is fine. Let's keep the ripples simple or use the main value.
                                          // Re-instating the independent ripple builders for better visual quality:
                                          return TweenAnimationBuilder<double>(
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            duration: Duration(seconds: 1 + index),
                                            builder: (context, rippleValue, child) {
                                              return Container(
                                                height: 60 + (40 * rippleValue),
                                                width: 60 + (40 * rippleValue),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: primaryColor.withValues(alpha: 0.5 * (1 - rippleValue)),
                                                    width: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                            onEnd: () {}, 
                                          );
                                        }),
                                        const Icon(
                                          Icons.rocket_launch_rounded,
                                          size: 50,
                                          color: primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              heightSpace,
                              heightSpace,
                              const Text(
                                'Sending via satellites...',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Connecting to NASA network',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              heightSpace,
                              heightSpace,
                              // Progress Bar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: fixPadding * 4),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: value,
                                        backgroundColor: whiteColor.withValues(alpha: 0.1),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          primaryColor.withValues(alpha: 0.8),
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${(value * 100).toInt()}%',
                                      style: const TextStyle(
                                        color: whiteColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : Column(
                        key: const ValueKey('idle'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: 5,
                                  left: 10,
                                  child: Icon(
                                    Icons.star,
                                    size: 16,
                                    color: primaryColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 15,
                                  child: Icon(
                                    Icons.star,
                                    size: 14,
                                    color: primaryColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 5,
                                  child: Icon(
                                    Icons.star,
                                    size: 12,
                                    color: primaryColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                const Icon(
                                  Icons.mail_outline_rounded,
                                  size: 48,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                          ),
                          heightSpace,
                          const Text(
                            'Ask the Universe',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          heightSpace,
                          heightSpace,

                          if (currentStatus == MessageStatus.idle)
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 10.0,
                              alignment: WrapAlignment.center,
                              children: quickSuggestions.map((suggestion) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      messageController.text = suggestion;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: whiteColor.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: whiteColor.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Text(
                                      suggestion,
                                      style: const TextStyle(
                                        color: whiteColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                          if (currentStatus == MessageStatus.idle)
                            const SizedBox(height: 100), // Space for bottom bar
                        ],
                      ),
              ),
            ),
          ),
          if (currentStatus == MessageStatus.idle)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      scaffoldBgColor,
                      scaffoldBgColor.withValues(alpha: 0.0),
                    ],
                    stops: const [0.8, 1.0],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: whiteColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: whiteColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: TextField(
                          controller: messageController,
                          enabled: currentStatus == MessageStatus.idle,
                          style: const TextStyle(color: whiteColor),
                          decoration: const InputDecoration(
                            hintText: 'Write a message...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    widthSpace,
                    GestureDetector(
                      onTap: currentStatus == MessageStatus.idle ? sendMessageToUniverse : null,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: currentStatus == MessageStatus.idle ? primaryColor : greyColor.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          boxShadow: currentStatus == MessageStatus.idle
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: whiteColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (showReceivedDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
                    padding: const EdgeInsets.all(fixPadding * 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F2E),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: whiteColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                        const Icon(
                          Icons.mark_email_read_rounded,
                          size: 60,
                          color: greenColor,
                        ),
                        heightSpace,
                        heightSpace,
                        const Text(
                          'Message Received',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        heightSpace,
                        const Text(
                          'The universe has responded with an audio message.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        heightSpace,
                        heightSpace,
                        GestureDetector(
                          onTap: () async {
                            await SuperwallService().showPaywall(
                              placement: "subscribe_button",
                              onPurchased: () {
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
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [primaryColor, Color(0xFF7B5CFA)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'Decipher Message',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                            ],
                          ),
                        ),
                        // Close button
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              // Mark message as read when closing
                              if (messageService.responses.isNotEmpty) {
                                final latestMessage = messageService.responses.first;
                                messageService.markAsRead(latestMessage.id);
                              }
                              setState(() {
                                showReceivedDialog = false;
                                currentStatus = MessageStatus.idle;
                                currentQuestionForDialog = 'closed'; // Mark as closed to prevent reopening
                                messageController.clear();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: whiteColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: whiteColor,
                                size: 20,
                              ),
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

