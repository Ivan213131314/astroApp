import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  final horoscopeList = [
    {
      "image": "assets/home/image-1.png",
      "name": translation('horoscope_list.aries')
    },
    {
      "image": "assets/home/image-2.png",
      "name": translation('horoscope_list.taurus')
    },
    {
      "image": "assets/home/image-3.png",
      "name": translation('horoscope_list.gemini')
    },
    {
      "image": "assets/home/image-4.png",
      "name": translation('horoscope_list.cancer')
    },
    {
      "image": "assets/home/image-5.png",
      "name": translation('horoscope_list.leo')
    },
    {
      "image": "assets/home/image-6.png",
      "name": translation('horoscope_list.virgo')
    },
    {
      "image": "assets/home/image-7.png",
      "name": translation('horoscope_list.libra')
    },
    {
      "image": "assets/home/image-8.png",
      "name": translation('horoscope_list.scorpio')
    },
    {
      "image": "assets/home/image-12.png",
      "name": translation('horoscope_list.sagittarius')
    },
    {
      "image": "assets/home/image-9.png",
      "name": translation("horoscope_list.capricorn")
    },
    {
      "image": "assets/home/image-10.png",
      "name": translation('horoscope_list.aquarius')
    },
    {
      "image": "assets/home/image-11.png",
      "name": translation('horoscope_list.pisces')
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            backButton(context),
            widthSpace,
            width5Space,
            Expanded(
              child: Text(
                getTranslation(context, 'horoscope.horoscope'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: horoscopeListContent(),
    );
  }

  horoscopeListContent() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
          left: fixPadding * 2.0,
          right: fixPadding * 2.0,
          bottom: fixPadding * 2.0,
          top: fixPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: fixPadding * 2.0,
          crossAxisSpacing: fixPadding * 2.0,
          childAspectRatio: 1.2),
      itemCount: horoscopeList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/horoscopeDetail');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: fixPadding, horizontal: fixPadding / 2),
            decoration: BoxDecoration(
              color: blueShade1,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: blueShade1.withValues(alpha: 0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    horoscopeList[index]['image'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                heightSpace,
                Text(
                  horoscopeList[index]['name'].toString(),
                  style: regualr16White,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
        );
      },
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
