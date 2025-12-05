import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'horoscope_deep_detail_screen.dart';

class HoroscopeDetailScreen extends StatefulWidget {
  const HoroscopeDetailScreen({super.key});

  @override
  State<HoroscopeDetailScreen> createState() => _HoroscopeDetailScreenState();
}

class _HoroscopeDetailScreenState extends State<HoroscopeDetailScreen> {
  final list = [
    translation('horoscope_detail.today'),
    translation('horoscope_detail.tomorrow'),
    translation('horoscope_detail.this_week'),
  ];

  int selectedindex = 0;

  final todayList = [
    {
      "title": translation('horoscope_detail.love'),
      "color": redColor,
      "value": 0.88,
    },
    {
      "title": translation('horoscope_detail.business'),
      "color": greenColor,
      "value": 0.95,
    },
    {
      "title": translation('horoscope_detail.health'),
      "color": primaryColor,
      "value": 0.60,
    }
  ];
  final tommorowList = [
    {
      "title": translation('horoscope_detail.love'),
      "color": redColor,
      "value": 0.95,
    },
    {
      "title": translation('horoscope_detail.business'),
      "color": greenColor,
      "value": 0.60,
    },
    {
      "title": translation('horoscope_detail.health'),
      "color": primaryColor,
      "value": 0.88,
    }
  ];
  final thisWeekList = [
    {
      "title": translation('horoscope_detail.love'),
      "color": redColor,
      "value": 0.60,
    },
    {
      "title": translation('horoscope_detail.business'),
      "color": greenColor,
      "value": 0.88,
    },
    {
      "title": translation('horoscope_detail.health'),
      "color": primaryColor,
      "value": 0.95,
    }
  ];

  void _navigateToDeepDetail(HoroscopeCategory category, String teaser) {
    final timePeriod = selectedindex == 0
        ? getTranslation(context, 'horoscope_detail.today')
        : (selectedindex == 1
            ? getTranslation(context, 'horoscope_detail.tomorrow')
            : getTranslation(context, 'horoscope_detail.this_week'));

    Navigator.pushNamed(
      context,
      '/horoscopeDeepDetail',
      arguments: {
        'zodiacSign': getTranslation(context, 'horoscope_detail.virgo'),
        'timePeriod': timePeriod,
        'category': category.name,
        'teaser': teaser,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: blueShade1,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: 310,
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
                    getTranslation(context, 'horoscope_detail.horoscope'),
                    style: bold18White,
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: hotoscopeInfo(size),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                contentList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  contentList() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding * 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: persentListContent(selectedindex == 0
                ? todayList
                : (selectedindex == 1 ? tommorowList : thisWeekList)),
          ),
          heightSpace,
          titleWidget(
              getTranslation(context, 'horoscope_detail.overall_horoscope'),
              primaryColor),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
            style: regualr14Grey,
          ),
          heightSpace,
          _buildGoDeeper(
            primaryColor,
            HoroscopeCategory.overall,
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus.",
            Icons.auto_awesome,
          ),
          heightSpace,
          heightSpace,
          titleWidget(getTranslation(context, 'horoscope_detail.love_passion'),
              redColor),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
            style: regualr14Grey,
          ),
          heightSpace,
          _buildGoDeeper(
            redColor,
            HoroscopeCategory.love,
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus.",
            Icons.favorite,
          ),
          heightSpace,
          heightSpace,
          titleWidget(
              getTranslation(context, 'horoscope_detail.business_career'),
              greenColor),
          heightSpace,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
            style: regualr14Grey,
          ),
          heightSpace,
          _buildGoDeeper(
            greenColor,
            HoroscopeCategory.business,
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus.",
            Icons.business_center,
          ),
          heightSpace,
          heightSpace,
        ],
      ),
    );
  }

  Widget _buildGoDeeper(
      Color color, HoroscopeCategory category, String teaser, IconData icon) {
    return GestureDetector(
      onTap: () => _navigateToDeepDetail(category, teaser),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 1.5,
          vertical: fixPadding,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.8), color],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: whiteColor, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Go Deeper',
              style: TextStyle(
                color: whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, color: whiteColor, size: 16),
          ],
        ),
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

  persentListContent(List listname) {
    return List.generate(
      listname.length,
      (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding),
          child: Column(
            children: [
              CircularPercentIndicator(
                percent: listname[index]['value'] as double,
                progressColor: todayList[index]['color'] as Color,
                backgroundColor: const Color(0xFF484363),
                radius: 32,
                center: Text(
                  "${((listname[index]['value'] as double) * 100).toInt()}%",
                  style: medium18Grey,
                ),
              ),
              heightSpace,
              Text(
                listname[index]['title'].toString(),
                style: regualr16Grey,
              )
            ],
          ),
        );
      },
    );
  }

  hotoscopeInfo(Size size) {
    return Container(
      padding: const EdgeInsets.only(
          left: fixPadding, right: fixPadding, top: fixPadding * 8.0),
      width: double.maxFinite,
      color: scaffoldBgColor,
      child: Column(
        children: [
          Image.asset(
            "assets/horoscopeDetail/image.png",
            height: 135,
          ),
          height5Space,
          Text(
            getTranslation(context, 'horoscope_detail.virgo'),
            style: medium25WhiteF4,
          ),
          heightSpace,
          heightSpace,
          listContent(),
        ],
      ),
    );
  }

  listContent() {
    return Row(
      children: List.generate(
        list.length,
        (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedindex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: fixPadding),
                padding: const EdgeInsets.symmetric(
                    vertical: fixPadding / 1.5, horizontal: fixPadding / 5),
                decoration: BoxDecoration(
                  color: selectedindex == index ? primaryColor : blueShade1,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  list[index],
                  style: selectedindex == index ? bold16WhiteF4 : bold16Grey,
                ),
              ),
            ),
          );
        },
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
