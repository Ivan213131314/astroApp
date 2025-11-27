import 'dart:async';
import 'dart:math';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AstrologerChatScreen extends StatefulWidget {
  const AstrologerChatScreen({super.key});

  @override
  State<AstrologerChatScreen> createState() => _AstrologerChatScreenState();
}

class _AstrologerChatScreenState extends State<AstrologerChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController messageController = TextEditingController();
  bool chatStarted = false;
  bool isAstrologerTyping = false;

  final String astrologerName = "Astro Maya";
  final String astrologerImage = "assets/message/image1.png";

  final List<Map<String, dynamic>> messagesList = [];

  // Animation controller for typing dots
  late AnimationController _typingAnimationController;

  // Mock responses from the astrologer
  final List<String> mockResponses = [
    "I sense great energy around you today. The stars are aligned in your favor.",
    "Your aura tells me you've been thinking about important decisions lately.",
    "The cosmic forces suggest patience will serve you well this week.",
    "I see positive changes coming your way. Stay open to new opportunities.",
    "Your spiritual journey is progressing beautifully. Trust the universe.",
    "The planets indicate this is a good time for self-reflection.",
    "I feel strong protective energy surrounding you. You're on the right path.",
    "The celestial bodies are sending you messages of hope and renewal.",
  ];

  int mockResponseIndex = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    messageController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _startChat() {
    setState(() {
      chatStarted = true;
      // Add initial greeting from astrologer
      messagesList.add({
        "message":
            "Welcome! I'm Astro Maya. I've been expecting you. How can I guide you today?",
        "time": DateFormat.jm().format(DateTime.now()),
        "isMe": false,
      });
    });
  }

  void _sendMessage() {
    if (messageController.text.trim().isEmpty) return;
    if (isAstrologerTyping) return; // Don't allow sending while typing

    final userMessage = messageController.text;
    setState(() {
      messagesList.add({
        "message": userMessage,
        "time": DateFormat.jm().format(DateTime.now()),
        "isMe": true,
      });
    });
    messageController.clear();

    // Random delay before astrologer starts typing (1-5 seconds)
    final initialDelay = 1000 + _random.nextInt(4000);

    Timer(Duration(milliseconds: initialDelay), () {
      if (mounted) {
        setState(() {
          isAstrologerTyping = true;
        });

        // Get the response message
        final responseMessage =
            mockResponses[mockResponseIndex % mockResponses.length];

        // Typing duration depends on message length (50ms per character)
        final typingDuration = responseMessage.length * 150;

        Timer(Duration(milliseconds: typingDuration), () {
          if (mounted) {
            setState(() {
              isAstrologerTyping = false;
              messagesList.add({
                "message": responseMessage,
                "time": DateFormat.jm().format(DateTime.now()),
                "isMe": false,
              });
              mockResponseIndex++;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: Row(
          children: [
            _backButton(context),
            widthSpace,
            Stack(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(astrologerImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Online indicator
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: greenColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: scaffoldBgColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            widthSpace,
            width5Space,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        astrologerName,
                        style: medium14White,
                      ),
                      width5Space,
                      Container(
                        height: 8,
                        width: 8,
                        decoration: const BoxDecoration(
                          color: greenColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  height5Space,
                  Text(
                    isAstrologerTyping ? "typing..." : "Online",
                    style: TextStyle(
                      color: isAstrologerTyping ? primaryColor : greenColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: chatStarted ? _buildChatInterface() : _buildPreChatDialog(),
    );
  }

  Widget _buildPreChatDialog() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(fixPadding * 2.0),
        padding: const EdgeInsets.all(fixPadding * 2.5),
        decoration: BoxDecoration(
          color: recBgColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Astrologer avatar with online indicator
            Stack(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 3),
                    image: DecorationImage(
                      image: AssetImage(astrologerImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    height: 18,
                    width: 18,
                    decoration: BoxDecoration(
                      color: greenColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: recBgColor, width: 3),
                    ),
                  ),
                ),
              ],
            ),
            heightSpace,
            heightSpace,
            Text(
              astrologerName,
              style: bold18White,
            ),
            heightSpace,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                    color: greenColor,
                    shape: BoxShape.circle,
                  ),
                ),
                width5Space,
                const Text(
                  "Online",
                  style: TextStyle(
                    color: greenColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            heightSpace,
            heightSpace,
            const Text(
              "Astrologer is online.\nDo you want to start a chat?",
              textAlign: TextAlign.center,
              style: medium16Grey,
            ),
            heightSpace,
            heightSpace,
            GestureDetector(
              onTap: _startChat,
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(vertical: fixPadding * 1.5),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Text(
                  "Start Chat",
                  textAlign: TextAlign.center,
                  style: bold18White,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        _messagesListContent(),
        Padding(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          child: Row(
            children: [
              _messageField(),
              widthSpace,
              _sendButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _messagesListContent() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        reverse: true,
        itemCount: messagesList.length + (isAstrologerTyping ? 1 : 0),
        itemBuilder: (context, index) {
          // If typing, show typing indicator at index 0 (top of reversed list)
          if (isAstrologerTyping && index == 0) {
            return _typingIndicator();
          }

          // Adjust index for typing indicator
          final adjustedIndex = isAstrologerTyping ? index - 1 : index;
          int reverseIndex = messagesList.length - 1 - adjustedIndex;

          return messagesList[reverseIndex]['isMe'] == true
              ? _senderMessages(reverseIndex)
              : _astrologerMessages(reverseIndex);
        },
      ),
    );
  }

  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(
        top: fixPadding,
        bottom: fixPadding,
        right: fixPadding * 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(astrologerImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              height5Space,
            ],
          ),
          width5Space,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: fixPadding * 1.5,
              vertical: fixPadding * 1.2,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2449),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                topLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (dotIndex) {
                    // Staggered animation for each dot
                    final delay = dotIndex * 0.2;
                    final animValue =
                        (_typingAnimationController.value + delay) % 1.0;
                    final scale = 0.5 + (sin(animValue * pi) * 0.5);
                    final opacity = 0.4 + (sin(animValue * pi) * 0.6);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: opacity),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sendButton() {
    return InkWell(
      onTap: _sendMessage,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: greyColor),
          color: blueShade1,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.send,
          color: isAstrologerTyping ? greyColor.withValues(alpha: 0.5) : greyColor,
        ),
      ),
    );
  }

  Widget _messageField() {
    return Expanded(
      child: Container(
        height: 50,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: blueShade1,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: greyColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 6,
            ),
          ],
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          controller: messageController,
          cursorColor: primaryColor,
          style: medium15WhiteF4,
          enabled: !isAstrologerTyping,
          onSubmitted: (_) => _sendMessage(),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(
              CupertinoIcons.smiley,
              color: greyColor,
            ),
            hintText: isAstrologerTyping ? "Wait for response..." : "Type here...",
            hintStyle: regualr14Grey,
            suffixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: fixPadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mic_none,
                    color: greyColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _senderMessages(int index) {
    return Padding(
      padding: const EdgeInsets.only(
        top: fixPadding,
        bottom: fixPadding,
        left: fixPadding * 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: fixPadding,
                    vertical: fixPadding * 1.4,
                  ),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    messagesList[index]['message'].toString(),
                    style: medium14GreyD4,
                  ),
                ),
                height5Space,
                Text(
                  messagesList[index]['time'].toString(),
                  style: medium12Grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _astrologerMessages(int index) {
    return Padding(
      padding: const EdgeInsets.only(
        top: fixPadding,
        bottom: fixPadding,
        right: fixPadding * 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(astrologerImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              height5Space,
            ],
          ),
          width5Space,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: fixPadding,
                    vertical: fixPadding * 1.4,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F2449),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      topLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    messagesList[index]['message'].toString(),
                    style: medium14GreyD4,
                  ),
                ),
                height5Space,
                Text(
                  messagesList[index]['time'].toString(),
                  style: medium12Grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
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
    );
  }
}
