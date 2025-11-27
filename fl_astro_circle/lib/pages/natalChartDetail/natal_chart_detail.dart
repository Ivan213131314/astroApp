import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/widget/column_builder.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class NatalChartDetailScreen extends StatefulWidget {
  const NatalChartDetailScreen({super.key});

  @override
  State<NatalChartDetailScreen> createState() => _NatalChartDetailScreenState();
}

class _NatalChartDetailScreenState extends State<NatalChartDetailScreen> {
  Map<String, dynamic>? chartData;
  List<Map<String, dynamic>> planetsData = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      chartData = args;
      planetsData = List<Map<String, dynamic>>.from(args['planetsData'] ?? []);
    }
  }

  List<Map<String, dynamic>> get planetsList {
    if (planetsData.isEmpty) {
      // Fallback to default data if no data passed
      return [
        {
          "title": translation('natal_chart_detail.planets'),
          "list": ["Sun", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]
        },
        {
          "title": translation('natal_chart_detail.position_degree'),
          "list": ["10°", "12°", "14°", "10°", "05°", "03°", "02°", "15°", "10°"]
        },
        {
          "title": translation('natal_chart_detail.sign'),
          "list": ["Aries", "Leo", "Libra", "Scorpio", "Capricorn", "Pisces", "Cancer", "Aquarius", "Aries"]
        },
        {
          "title": translation('natal_chart_detail.position_hour'),
          "list": ["05", "03", "06", "04", "04", "03", "02", "07", "05"]
        },
      ];
    }

    // Transform planetsData to display format
    return [
      {
        "title": translation('natal_chart_detail.planets'),
        "list": planetsData.map((p) => p['planet'] as String).toList()
      },
      {
        "title": translation('natal_chart_detail.position_degree'),
        "list": planetsData.map((p) => p['degree'] as String).toList()
      },
      {
        "title": translation('natal_chart_detail.sign'),
        "list": planetsData.map((p) => p['sign'] as String).toList()
      },
      {
        "title": translation('natal_chart_detail.position_hour'),
        "list": planetsData.map((p) => p['house'] as String).toList()
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: backButton(context),
        centerTitle: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (chartData != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
              child: Column(
                children: [
                  Text(
                    chartData!['name'] ?? '',
                    style: bold20White,
                    textAlign: TextAlign.center,
                  ),
                  height5Space,
                  Text(
                    '${chartData!['location'] ?? ''} • ${chartData!['timeOfBirth'] ?? ''}',
                    style: regualr14Grey,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            heightSpace,
          ],
          Text(
            getTranslation(context, 'natal_chart_detail.natal_chart'),
            style: medium18White,
            textAlign: TextAlign.center,
          ),
          Center(
            child: Image.asset(
              "assets/natalDetail/natalchartImage.png",
              height: size.height * 0.35,
              fit: BoxFit.cover,
            ),
          ),
          planetsListContent(),
          heightSpace,
          heightSpace,
          detailTextWidget(
              getTranslation(context, 'natal_chart_detail.title1'), "08°"),
          heightSpace,
          heightSpace,
          detailTextWidget(
              getTranslation(context, 'natal_chart_detail.title2'), "22°"),
          heightSpace,
          heightSpace,
          detailTextWidget(
              getTranslation(context, 'natal_chart_detail.title3'), "17°"),
          heightSpace,
          heightSpace,
        ],
      ),
    );
  }

  detailTextWidget(String title, String degree) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: medium16White,
                    ),
                    height5Space,
                    Container(
                      height: 5,
                      width: 45,
                      color: primaryColor,
                    )
                  ],
                ),
              ),
              width5Space,
              Text(
                degree,
                style: medium18White,
              )
            ],
          ),
          heightSpace,
          ReadMoreText(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget ",
            moreStyle: regualr14Primary,
            lessStyle: regualr14Primary,
            trimExpandedText:
                getTranslation(context, 'natal_chart_detail.show_less'),
            trimCollapsedText:
                getTranslation(context, 'natal_chart_detail.read_more'),
            style: regualr14Grey,
          )
        ],
      ),
    );
  }

  planetsListContent() {
    final list = planetsList;
    return Container(
      width: double.maxFinite,
      color: blueShade1,
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 2.0, horizontal: fixPadding * 1.5),
      child: Column(
        children: [
          Row(
            children: List.generate(
              list.length,
              (index) {
                return Expanded(
                  child: Text(
                    list[index]['title'].toString(),
                    style: medium16White,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          Row(
            children: List.generate(
              list.length,
              (index) {
                List itemData = list[index]['list'] as List;
                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: fixPadding / 2),
                    child: ColumnBuilder(
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: fixPadding),
                            child: Text(
                              itemData[i].toString(),
                              style:
                                  index == 0 ? regualr15GreyD4 : regualr14Grey,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        itemCount: itemData.length),
                  ),
                );
              },
            ),
          ),
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
