import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../theme/theme.dart';

class PlamReaderDetailScreen extends StatefulWidget {
  const PlamReaderDetailScreen({super.key});

  @override
  State<PlamReaderDetailScreen> createState() => _PlamReaderDetailScreenState();
}

class _PlamReaderDetailScreenState extends State<PlamReaderDetailScreen> {
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
            expandedHeight: 330,
            backgroundColor: scaffoldBgColor,
            elevation: 0,
            titleSpacing: 20.0,
            centerTitle: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                backButton(context),
                // widthSpace,
                // width5Space,
                // Expanded(
                //   child: Text(
                //     getTranslation(context, "plam_reader_detail.horoscope"),
                //     style: bold18White,
                //   ),
                // ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: plamInfo(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(fixPadding * 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      detailWidget(getTranslation(
                          context, 'plam_reader_detail.life_line')),
                      heightSpace,
                      heightSpace,
                      detailWidget(getTranslation(
                          context, 'plam_reader_detail.heart_line')),
                      heightSpace,
                      heightSpace,
                      detailWidget(getTranslation(
                          context, 'plam_reader_detail.money_line')),
                      heightSpace,
                      heightSpace,
                      detailWidget(getTranslation(
                          context, 'plam_reader_detail.health_line'))
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  detailWidget(String title) {
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
          color: primaryColor,
        ),
        heightSpace,
        ReadMoreText(
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget",
          style: regualr14Grey,
          moreStyle: regualr14Primary,
          lessStyle: regualr14Primary,
          trimLines: 8,
          trimMode: TrimMode.Line,
          trimExpandedText:
              getTranslation(context, 'plam_reader_detail.show_less'),
          trimCollapsedText:
              getTranslation(context, 'plam_reader_detail.read_more'),
        )
      ],
    );
  }

  plamInfo() {
    return Padding(
      padding: const EdgeInsets.only(
          left: fixPadding * 2, right: fixPadding * 2.0, top: fixPadding * 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getTranslation(context, 'plam_reader_detail.personal_analysis'),
            style: medium22WhiteF4,
            textAlign: TextAlign.center,
          ),
          heightSpace,
          heightSpace,
          Container(
            height: 185,
            width: 185,
            decoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage("assets/plamreader/handImage.png"),
                fit: BoxFit.cover,
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
