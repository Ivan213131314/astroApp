import 'package:dotted_border/dotted_border.dart';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/widget/column_builder.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final planList = [
    {
      "price": "\$8.88",
      "time": 12,
    },
    {
      "price": "\$6.66",
      "time": 6,
    },
    {
      "price": "\$3.33",
      "time": 3,
    },
    {
      "price": "\$1.11",
      "time": 1,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/auth/bgImage.png"),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scaffoldBgColor,
                const Color(0xFF301B87).withValues(alpha: 0),
              ],
            ),
          ),
          child: Column(
            children: [
              header(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(
                      top: fixPadding, bottom: fixPadding),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    titleText(),
                    height5Space,
                    contentText(),
                    heightSpace,
                    heightSpace,
                    benefits(),
                    heightSpace,
                    heightSpace,
                    dottedDivider(),
                    heightSpace,
                    heightSpace,
                    planListContent(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  contentText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 5.0),
      child: Text(
        getTranslation(context, 'subscribe.content_text'),
        style: medium14Grey,
        textAlign: TextAlign.center,
      ),
    );
  }

  titleText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        getTranslation(context, 'subscribe.subscribe_plans'),
        style: bold17WhiteF4,
        textAlign: TextAlign.center,
      ),
    );
  }

  planListContent() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          margin: const EdgeInsets.symmetric(
              vertical: fixPadding, horizontal: fixPadding * 2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: recBgColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${planList[index]['time']} ${getTranslation(context, 'subscribe.month')}",
                      style: medium15Grey,
                    ),
                    height5Space,
                    Text(
                      planList[index]['price'].toString(),
                      style: medium20White,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/paymentMethod');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: fixPadding * 1.2, vertical: fixPadding / 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: primaryColor,
                  ),
                  child: Text(
                    getTranslation(context, 'subscribe.subscribe'),
                    style: medium16White,
                  ),
                ),
              )
            ],
          ),
        );
      },
      itemCount: planList.length,
    );
  }

  header(BuildContext context) {
    return AppBar(
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
              getTranslation(context, 'subscribe.subscribe'),
              style: bold18White,
            ),
          ),
        ],
      ),
    );
    // Padding(
    //   padding: const EdgeInsets.only(
    //     left: fixPadding * 2.0,
    //     right: fixPadding * 2.0,
    //     top: fixPadding * 4.0,
    //     bottom: fixPadding,
    //   ),
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       backButton(context),
    //       widthSpace,
    //       width5Space,
    //       Expanded(
    //         child: Text(
    //           getTranslation(context, 'subscribe.subscribe'),
    //           style: bold18White,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  dottedDivider() {
    return DottedBorder(
      padding: EdgeInsets.zero,
      dashPattern: const [2, 4],
      color: greyColor,
      child: Container(
        width: double.maxFinite,
      ),
    );
  }

  benefits() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Column(
        children: [
          Row(
            children: [
              textWidget(getTranslation(context, 'subscribe.detail_horoscope')),
              widthSpace,
              textWidget(
                  getTranslation(context, 'subscribe.numorology_feature')),
            ],
          ),
          heightSpace,
          Row(
            children: [
              textWidget(
                  getTranslation(context, 'subscribe.compatibility_feature')),
              widthSpace,
              textWidget(getTranslation(context, 'subscribe.plam_feature')),
            ],
          ),
        ],
      ),
    );
  }

  textWidget(title) {
    return Expanded(
      child: Row(
        children: [
          const Text(
            "•",
            style: bold15Grey,
          ),
          widthSpace,
          Expanded(
            child: Text(
              title,
              style: bold15Grey,
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
