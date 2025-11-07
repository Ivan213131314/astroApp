import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/pages/profile/languages.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  final messagesList = [
    {"message": "Hii Galina,good morning", "time": "1.30 pm", "isMe": false},
    {"message": "Hii, how are you ? ", "time": "1.30 pm", "isMe": true},
    {
      "message": "Lorem ipsum dolor sit amet consectetur",
      "time": "1.30 pm",
      "isMe": false
    },
    {
      "message": "Lorem ipsum dolor sit amet consectetur",
      "time": "1.30 pm",
      "isMe": true
    },
    {
      "message": "Lorem ipsum dolor sit amet consectetur",
      "time": "1.30 pm",
      "isMe": false
    },
    {
      "message": "Lorem ipsum dolor sit amet consectetur",
      "time": "1.30 pm",
      "isMe": true
    },
    {
      "message": "Lorem ipsum dolor sit amet consectetur",
      "time": "1.30 pm",
      "isMe": false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: Row(
          children: [
            backButton(context),
            widthSpace,
            Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: AssetImage("assets/chat/user1.png"),
                    fit: BoxFit.fill),
              ),
            ),
            widthSpace,
            width5Space,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "jeklin Shah",
                    style: medium14White,
                  ),
                  height5Space,
                  Text(
                    getTranslation(context, 'chat.active_now'),
                    style: medium12Grey,
                  )
                ],
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          messagesListContent(),
          Padding(
            padding: const EdgeInsets.all(fixPadding * 2.0),
            child: Row(
              children: [
                messageField(),
                widthSpace,
                sendButton(),
              ],
            ),
          )
        ],
      ),
    );
  }

  messagesListContent() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        reverse: true,
        itemCount: messagesList.length,
        itemBuilder: (context, index) {
          int reverseIndex = messagesList.length - 1 - index;
          return messagesList[reverseIndex]['isMe'] == true
              ? senderMessages(reverseIndex)
              : otherUserMessages(reverseIndex);
        },
      ),
    );
  }

  sendButton() {
    return InkWell(
      onTap: () {
        setState(() {
          messagesList.add(
            {
              "message": messageController.text,
              "time": DateFormat.jm().format(DateTime.now()),
              "isMe": true,
            },
          );
        });
        messagesList;
        messageController.clear();
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: greyColor),
          color: blueShade1,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.send,
          color: greyColor,
        ),
      ),
    );
  }

  messageField() {
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
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(
              CupertinoIcons.smiley,
              color: greyColor,
            ),
            hintText: getTranslation(context, 'chat.type_here'),
            hintStyle: regualr14Grey,
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: fixPadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: 0.7,
                    child: const Icon(
                      Icons.attach_file,
                      color: greyColor,
                    ),
                  ),
                  const Icon(
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

  senderMessages(int index) {
    return Padding(
      padding: languageValue == 4
          ? const EdgeInsets.only(
              top: fixPadding, bottom: fixPadding, right: fixPadding * 7)
          : const EdgeInsets.only(
              top: fixPadding, bottom: fixPadding, left: fixPadding * 7),
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
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: languageValue == 4
                        ? const BorderRadius.only(
                            topRight: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          )
                        : const BorderRadius.only(
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
                )
              ],
            ),
          ),
          width5Space,
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage("assets/chat/user2.png"),
                      fit: BoxFit.cover),
                ),
              ),
              height5Space,
            ],
          ),
        ],
      ),
    );
  }

  otherUserMessages(int index) {
    return Padding(
      padding: languageValue == 4
          ? const EdgeInsets.only(
              top: fixPadding, bottom: fixPadding, left: fixPadding * 7)
          : const EdgeInsets.only(
              top: fixPadding, bottom: fixPadding, right: fixPadding * 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage("assets/chat/user1.png"),
                      fit: BoxFit.cover),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2449),
                    borderRadius: languageValue == 4
                        ? const BorderRadius.only(
                            topRight: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                          )
                        : const BorderRadius.only(
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  backButton(BuildContext context) {
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
