import 'package:dotted_border/dotted_border.dart';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CompatibilityDetailScreen extends StatefulWidget {
  const CompatibilityDetailScreen({super.key});

  @override
  State<CompatibilityDetailScreen> createState() =>
      _CompatibilityDetailScreenState();
}

class _CompatibilityDetailScreenState extends State<CompatibilityDetailScreen> {
  final percentageList = [
    {
      "title": translation('compatibility_detail.love'),
      "color": redColor,
      "value": 0.88,
    },
    {
      "title": translation('compatibility_detail.business'),
      "color": greenColor,
      "value": 0.95,
    },
    {
      "title": translation('compatibility_detail.health'),
      "color": primaryColor,
      "value": 0.60,
    }
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
                getTranslation(context, 'compatibility_detail.compatibility'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          horoscopeDetail(size),
          contentList(),
        ],
      ),
    );
  }

  contentList() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(fixPadding * 2.0),
      decoration: const BoxDecoration(
        color: blueShade1,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: persentListContent(),
          ),
          heightSpace,
          heightSpace,
          titleWidget(
              getTranslation(context, 'compatibility_detail.overall_horoscope'),
              primaryColor),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
            style: regualr14Grey,
          ),
          heightSpace,
          heightSpace,
          titleWidget(
              getTranslation(context, 'compatibility_detail.love_passion'),
              redColor),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
            style: regualr14Grey,
          ),
          heightSpace,
          heightSpace,
          titleWidget(
              getTranslation(context, 'compatibility_detail.business_career'),
              greenColor),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
            style: regualr14Grey,
          ),
          heightSpace,
          heightSpace,
          titleWidget(getTranslation(context, 'compatibility_detail.health'),
              primaryColor),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
            style: regualr14Grey,
          ),
        ],
      ),
    );
  }

  persentListContent() {
    return List.generate(
      percentageList.length,
      (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding),
          child: Column(
            children: [
              CircularPercentIndicator(
                percent: percentageList[index]['value'] as double,
                progressColor: percentageList[index]['color'] as Color,
                backgroundColor: const Color(0xFF484363),
                radius: 32,
                center: Text(
                  "${((percentageList[index]['value'] as double) * 100).toInt()}%",
                  style: medium18Grey,
                ),
              ),
              heightSpace,
              Text(
                percentageList[index]['title'].toString(),
                style: regualr16Grey,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        );
      },
    );
  }

  titleWidget(String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: medium18White,
        ),
        height5Space,
        Container(
          height: 5,
          width: 45,
          color: color,
        )
      ],
    );
  }

  horoscopeDetail(Size size) {
    return Padding(
      padding: const EdgeInsets.only(
          left: fixPadding * 2.0,
          right: fixPadding * 2.0,
          bottom: fixPadding * 3.0,
          top: fixPadding),
      child: Row(
        children: [
          horoscopeWidget(size, "assets/home/image-7.png",
              getTranslation(context, 'compatibility_detail.libra')),
          Expanded(
            child: Row(
              children: [
                dottedBorder(),
                compareButton(),
                dottedBorder(),
              ],
            ),
          ),
          horoscopeWidget(size, "assets/home/image-1.png",
              getTranslation(context, 'compatibility_detail.aries')),
        ],
      ),
    );
  }

  compareButton() {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor,
        border: Border.all(
          color: whiteColor,
          width: 5,
        ),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        "assets/compatibility/compare-icon.png",
        height: 20,
        width: 20,
      ),
    );
  }

  dottedBorder() {
    return Expanded(
      child: DottedBorder(
        padding: EdgeInsets.zero,
        dashPattern: const [2.5],
        color: greyColor,
        child: Container(),
      ),
    );
  }

  horoscopeWidget(Size size, image, text) {
    return Container(
      width: size.width * 0.25,
      padding: const EdgeInsets.symmetric(vertical: fixPadding),
      decoration: BoxDecoration(
        color: blueShade1,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blueShade1.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            image,
            fit: BoxFit.cover,
            height: 50,
          ),
          heightSpace,
          Text(
            text,
            style: regualr16White,
            overflow: TextOverflow.ellipsis,
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
