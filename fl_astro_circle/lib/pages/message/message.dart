import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final messageList = [
    {
      "image": "assets/message/image1.png",
      "name": "jeklin Shah",
      "message": "Hello! how are you",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image2.png",
      "name": "Guy Hawkins",
      "message": "Hello! how are you",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image3.png",
      "name": "Jenny Wilson",
      "message": "Goodmorning",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image4.png",
      "name": "Jacob Jones",
      "message": "Nice!",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image5.png",
      "name": "Cody Fisher",
      "message": "Hello",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image6.png",
      "name": "Albert Flores",
      "message": "Oww! so sweet of you",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image7.png",
      "name": "Ralph Edwards",
      "message": "Oww! so sweet of you",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image8.png",
      "name": "Leslie Alexander",
      "message": "Hello ! good morning",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image9.png",
      "name": "Brooklyn Simmons",
      "message": "Hello",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image10.png",
      "name": "Annette Black",
      "message": "Nice! Get well soon",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image11.png",
      "name": "Courtney Henry",
      "message": "Hello mit. good morning",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image12.png",
      "name": "Eleanor Pena",
      "message": "thank you!",
      "time": "2.00am"
    },
    {
      "image": "assets/message/image13.png",
      "name": "Jerome Bell",
      "message": "Oww! so sweet of you",
      "time": "2.00am"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 20.0,
        title: Text(
          getTranslation(context, 'message.message'),
          style: bold20White,
        ),
      ),
      body: Column(
        children: [
          searchField(),
          heightSpace,
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: fixPadding),
              itemCount: messageList.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: fixPadding,
                    horizontal: fixPadding * 2.0,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                messageList[index]['image'].toString(),
                              ),
                            ),
                          ),
                        ),
                        widthSpace,
                        width5Space,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                messageList[index]['name'].toString(),
                                style: medium16WhiteF4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              height5Space,
                              Text(
                                messageList[index]['message'].toString(),
                                style: regualr14Grey,
                              )
                            ],
                          ),
                        ),
                        Text(
                          messageList[index]['time'].toString(),
                          style: regualr14Grey,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  searchField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: blueShade1, borderRadius: BorderRadius.circular(5.0)),
      child: TextField(
        style: medium16WhiteF4,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0,
            vertical: fixPadding * 1.4,
          ),
          hintText: getTranslation(context, 'message.search'),
          prefixIcon: const Icon(
            Icons.search,
            size: 22,
          ),
          hintStyle: medium16Grey,
        ),
      ),
    );
  }
}
