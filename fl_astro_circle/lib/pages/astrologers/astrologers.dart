import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AstrologersScreen extends StatefulWidget {
  const AstrologersScreen({super.key});

  @override
  State<AstrologersScreen> createState() => _AstrologersScreenState();
}

class _AstrologersScreenState extends State<AstrologersScreen> {
  final astrologerList = [
    {
      "image": "assets/astrologer/Astrologer1.png",
      "rate": 4.5,
      "name": "Brooklyn Simmons",
      "type": "Vasthu consultation, Vedic Astrology",
      "language": "English,Hindi,Gujarati",
      "experience": "8 Years",
      "charge": "\$30/hour"
    },
    {
      "image": "assets/astrologer/Astrologer2.png",
      "rate": 5.0,
      "name": "Cameron Williamson",
      "type": "Life Astrology, Planetary Aspects",
      "language": "English,Hindi,Gujarati",
      "experience": "8 Years",
      "charge": "\$30/hour"
    },
    {
      "image": "assets/astrologer/Astrologer3.png",
      "rate": 4.0,
      "name": "Leslie Alexander",
      "type": "Helth astrology, Vedic Astrology ",
      "language": "English,Hindi,Gujarati",
      "experience": "8 Years",
      "charge": "\$30/hour"
    },
    {
      "image": "assets/astrologer/Astrologer4.png",
      "rate": 3.5,
      "name": "Savannah Nguyen",
      "type": "Vasthu consultation, Vedic Astrology",
      "language": "English,Hindi,Gujarati",
      "experience": "8 Years",
      "charge": "\$30/hour"
    },
    {
      "image": "assets/astrologer/Astrologer5.png",
      "rate": 3.0,
      "name": "Brooklyn Simmons",
      "type": "Life Astrology, Planetary Aspects",
      "language": "English,Hindi,Gujarati",
      "experience": "8 Years",
      "charge": "\$30/hour"
    },
    {
      "image": "assets/astrologer/Astrologer6.png",
      "rate": 2.5,
      "name": "Brooklyn Simmons",
      "type": "Vasthu consultation, Vedic Astrology",
      "language": "English,Hindi,Gujarati",
      "experience": "8 Years",
      "charge": "\$30/hour"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            backButton(context),
            widthSpace,
            width5Space,
            Expanded(
              child: Text(
                getTranslation(context, 'astrologers.astrologers'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: astrologerListContent(size),
    );
  }

  astrologerListContent(Size size) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: fixPadding),
      physics: const BouncingScrollPhysics(),
      itemCount: astrologerList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/astrologersDetail');
          },
          child: Container(
            padding: const EdgeInsets.all(fixPadding),
            margin: const EdgeInsets.symmetric(
                vertical: fixPadding, horizontal: fixPadding * 2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: blueShade1,
              boxShadow: [
                BoxShadow(
                  color: recBgColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                astrologerImageAndRate(size, index),
                widthSpace,
                widthSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        astrologerList[index]['name'].toString(),
                        style: regualr16WhiteF4,
                      ),
                      height5Space,
                      Row(
                        children: [
                          Image.asset(
                            "assets/astrologer/reading.png",
                            height: 18,
                            color: greyColor,
                          ),
                          width5Space,
                          Expanded(
                            child: Text(
                              astrologerList[index]['type'].toString(),
                              style: regualr14Grey,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      height5Space,
                      Row(
                        children: [
                          const Icon(
                            Icons.language,
                            size: 18,
                            color: greyColor,
                          ),
                          width5Space,
                          Expanded(
                            child: Text(
                              astrologerList[index]['language'].toString(),
                              style: regualr14Grey,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      height5Space,
                      Row(
                        children: [
                          Image.asset(
                            "assets/astrologer/exp.png",
                            height: 18,
                            color: greyColor,
                          ),
                          width5Space,
                          Expanded(
                            child: Text(
                              astrologerList[index]['experience'].toString(),
                              style: regualr14Grey,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      height5Space,
                      Text(
                        "${getTranslation(context, 'astrologers.charge')} : ${astrologerList[index]['charge']}",
                        style: medium16Primary,
                      ),
                      height5Space,
                      Row(
                        children: [
                          iconWidget(Icons.call_outlined, () {
                            Navigator.pushNamed(context, '/call');
                          }),
                          widthSpace,
                          iconWidget(CupertinoIcons.ellipses_bubble,
                              () => Navigator.pushNamed(context, '/chat')),
                          widthSpace,
                          iconWidget(Icons.videocam_outlined,
                              () => Navigator.pushNamed(context, '/videocall'))
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  iconWidget(icon, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF332D57),
          borderRadius: BorderRadius.circular(5.0),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: whiteF4Color,
        ),
      ),
    );
  }

  astrologerImageAndRate(Size size, int index) {
    return SizedBox(
      height: 165,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: size.width * 0.32,
              height: 155,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: AssetImage(
                    astrologerList[index]['image'].toString(),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: fixPadding, vertical: fixPadding / 2),
              decoration: BoxDecoration(
                color: rec48BgColor,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: recBgColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: yellowColor,
                    size: 15,
                  ),
                  width5Space,
                  Text(
                    astrologerList[index]['rate'].toString(),
                    style: regualr14WhiteF4,
                  )
                ],
              ),
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
