import 'package:dotted_border/dotted_border.dart';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class CompatibilityScreen extends StatefulWidget {
  final bool showBackButton;
  const CompatibilityScreen({super.key, this.showBackButton = false});

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen> {
  final leftHoroscope = [
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

  final rightHoroscope = [
    {
      "image": "assets/home/image-1.png",
      "name": translation('horoscope_list.aries')
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
      "image": "assets/home/image-3.png",
      "name": translation('horoscope_list.gemini')
    },
    {
      "image": "assets/home/image-2.png",
      "name": translation('horoscope_list.taurus')
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

  PageController leftpageController =
      PageController(viewportFraction: 0.35, initialPage: 1);

  int leftSelectedIndex = 1;

  PageController rightpageController =
      PageController(viewportFraction: 0.35, initialPage: 1);

  int rightSelectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: widget.showBackButton ? AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: backButton(context),
      ) : null,
      body: SafeArea(
        child: Stack(
          children: [
            bgImage(size),
            ListView(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              physics: const BouncingScrollPhysics(),
              children: [
                heightSpace,
                compatibilityText(),
              heightSpace,
              contentText(),
              heightSpace,
              heightSpace,
              heightSpace,
              heightSpace,
              Row(
                children: [
                  leftHoroscopeListContent(),
                  Expanded(
                    child: Row(
                      children: [
                        dottedBorder(),
                        goButton(),
                        dottedBorder(),
                      ],
                    ),
                  ),
                  rightHoroscopeListContent()
                ],
              )
            ],
          )
        ],
        ),
      ),
    );
  }

  goButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/compatibilityDetail');
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor,
          border: Border.all(
            color: whiteColor,
            width: 5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(fixPadding * 1.2),
          child: Text(
            getTranslation(context, 'compatibility.go'),
            style: bold20White,
          ),
        ),
      ),
    );
  }

  dottedBorder() {
    return Expanded(
      child: DottedBorder(
        padding: EdgeInsets.zero,
        dashPattern: const [2.4],
        color: greyColor,
        child: Container(
          width: double.maxFinite,
        ),
      ),
    );
  }

  rightHoroscopeListContent() {
    return SizedBox(
      height: 300,
      width: 100,
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: rightpageController,
        itemCount: rightHoroscope.length,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(
            () {
              rightSelectedIndex = index;
            },
          );
        },
        itemBuilder: (context, index) {
          return listContent(
            index,
            rightSelectedIndex,
            rightHoroscope,
          );
        },
      ),
    );
  }

  leftHoroscopeListContent() {
    return SizedBox(
      height: 300,
      width: 100,
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: leftpageController,
        itemCount: leftHoroscope.length,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(
            () {
              leftSelectedIndex = index;
            },
          );
        },
        itemBuilder: (context, index) {
          return listContent(
            index,
            leftSelectedIndex,
            leftHoroscope,
          );
        },
      ),
    );
  }

  listContent(int index, value, listname) {
    return Stack(
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: fixPadding),
          margin: const EdgeInsets.symmetric(vertical: fixPadding),
          decoration: BoxDecoration(
            color: blueShade1,
            borderRadius: BorderRadius.circular(10.0),
            border:
                value == index ? Border.all(color: whiteColor, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: recBgColor.withValues(alpha: 0.25),
                blurRadius: 6,
              )
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  listname[index]['image'].toString(),
                  fit: BoxFit.cover,
                ),
              ),
              height5Space,
              Text(
                listname[index]['name'].toString(),
                style: regualr16White,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        value == index
            ? const SizedBox()
            : Container(
                decoration: BoxDecoration(
                  color: blueShade1.withValues(alpha: 0.35),
                ),
              ),
      ],
    );
  }

  contentText() {
    return Text(
      getTranslation(context, 'compatibility.text'),
      style: medium16Grey,
      textAlign: TextAlign.center,
    );
  }

  compatibilityText() {
    return Text(
      getTranslation(context, 'compatibility.compatibility'),
      style: bold20White,
      textAlign: TextAlign.center,
    );
  }

  bgImage(Size size) {
    return Container(
      height: size.height,
      width: size.width,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.maxFinite,
        height: size.height * 0.22,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/compatibility/bgImage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scaffoldBgColor,
                scaffoldBgColor.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
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
