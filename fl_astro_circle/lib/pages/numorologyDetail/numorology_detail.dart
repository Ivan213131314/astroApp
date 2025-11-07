import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../theme/theme.dart';

class NumorologyDetailScreen extends StatefulWidget {
  const NumorologyDetailScreen({super.key});

  @override
  State<NumorologyDetailScreen> createState() => _NumorologyDetailScreenState();
}

class _NumorologyDetailScreenState extends State<NumorologyDetailScreen> {
  final percentageList = [
    {
      "title": translation('numorology_detail.funny'),
      "value": 0.88,
      "color": redColor,
    },
    {
      "title": translation('numorology_detail.obedient'),
      "value": 0.80,
      "color": greenColor,
    },
    {
      "title": translation('numorology_detail.honest'),
      "value": 0.95,
      "color": const Color(0xFF77CCF0),
    },
    {
      "title": translation('numorology_detail.responsible'),
      "value": 0.70,
      "color": const Color(0xFFDFCF3E),
    },
    {
      "title": translation('numorology_detail.hard_working'),
      "value": 0.90,
      "color": const Color(0xFFE46BEE),
    },
    {
      "title": translation('numorology_detail.smart'),
      "value": 0.60,
      "color": const Color(0xFFFF965A),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blueShade1,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: 270,
            backgroundColor: scaffoldBgColor,
            elevation: 0,
            titleSpacing: 20.0,
            centerTitle: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                backButton(context),
                widthSpace,
                width5Space,
                Expanded(
                  child: Text(
                    translation('numorology_detail.numorology'),
                    style: bold18White,
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: numorologyInfo(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                percentageListContent(),
                details(),
                heightSpace,
                heightSpace,
              ],
            ),
          )
        ],
      ),
    );
  }

  details() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget(
            getTranslation(context, 'numorology_detail.about_character'),
            const Color(0xFF77CCF0),
          ),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
            style: regualr14Grey,
          ),
          heightSpace,
          heightSpace,
          titleWidget(
            getTranslation(context, 'numorology_detail.about_behavior'),
            const Color(0xFFE46BEE),
          ),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
            style: regualr14Grey,
          ),
          heightSpace,
          heightSpace,
          titleWidget(
            getTranslation(context, 'numorology_detail.responsible'),
            const Color(0xFFDFCF3E),
          ),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
            style: regualr14Grey,
          )
        ],
      ),
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

  percentageListContent() {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(fixPadding * 2.0),
      itemCount: percentageList.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: fixPadding * 2.0,
          crossAxisSpacing: fixPadding * 2.0,
          childAspectRatio: 1.1),
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Text(
              percentageList[index]['title'].toString(),
              style: regualr16Grey,
              overflow: TextOverflow.ellipsis,
            )
          ],
        );
      },
    );
  }

  percentIndicator(double value, Color color, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding),
      child: Column(
        children: [
          CircularPercentIndicator(
            percent: value,
            progressColor: color,
            backgroundColor: const Color(0xFF484363),
            radius: 30,
            center: Text(
              "${((value) * 100).toInt()}%",
              style: medium18Grey,
            ),
          ),
          heightSpace,
          Text(
            title,
            style: regualr16Grey,
          )
        ],
      ),
    );
  }

  numorologyInfo() {
    return Padding(
      padding: const EdgeInsets.only(
        // left: fixPadding * 2.0,
        // right: fixPadding * 2.0,
        top: fixPadding * 2.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          Container(
            height: 100,
            width: 100,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: primaryColor,
              ),
              alignment: Alignment.center,
              child: const FittedBox(
                child: Text(
                  "5",
                  style: bold70White,
                ),
              ),
            ),
          ),
          heightSpace,
          Text(
            getTranslation(context, 'numorology_detail.lucky_number'),
            style: medium16Grey,
          ),
          height5Space,
          const Text(
            "09-10-1995",
            style: bold18Grey,
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
