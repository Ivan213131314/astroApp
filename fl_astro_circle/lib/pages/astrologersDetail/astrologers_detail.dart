import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/widget/column_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../theme/theme.dart';

class AstrologerDetailScreen extends StatefulWidget {
  const AstrologerDetailScreen({super.key});

  @override
  State<AstrologerDetailScreen> createState() => _AstrologerDetailScreenState();
}

class _AstrologerDetailScreenState extends State<AstrologerDetailScreen> {
  final reviewList = [
    {
      "image": "assets/astrologerDetail/review1.png",
      "name": "Ralph Edwards",
      "rate": 4,
      "date": "25 april 2020",
      "review":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris atmattis laoreet quam. Cursus risus nisl nulla et magna maecenasid"
    },
    {
      "image": "assets/astrologerDetail/review2.png",
      "name": "Brooklyn Simmons",
      "rate": 4,
      "date": "25 april 2020",
      "review":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris atmattis laoreet quam. Cursus risus nisl nulla et magna maecenasid"
    },
    {
      "image": "assets/astrologerDetail/review3.png",
      "name": "Esther Howard",
      "rate": 4,
      "date": "25 april 2020",
      "review":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris atmattis laoreet quam. Cursus risus nisl nulla et magna maecenasid"
    },
  ];

  final astrologersList = [
    {
      "image": "assets/home/astrologer1.png",
      "rate": 5.0,
      "name": "Astro Vivek K",
      "price": "\$5",
    },
    {
      "image": "assets/home/astrologer2.png",
      "rate": 4.2,
      "name": "Astro Jenny H",
      "price": "\$5",
    },
    {
      "image": "assets/home/astrologer3.png",
      "rate": 3.5,
      "name": "Astro Johan K",
      "price": "\$5",
    },
    {
      "image": "assets/home/astrologer4.png",
      "rate": 5.0,
      "name": "Astro Khushi U",
      "price": "\$5",
    }
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: backButton(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: fixPadding),
        children: [
          astrologerInfo(size),
          heightSpace,
          Container(
            width: double.maxFinite,
            color: blueShade1,
            padding: const EdgeInsets.all(fixPadding * 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget(
                    getTranslation(context, 'astrologer_detail.about_me')),
                heightSpace,
                aboutText(),
                heightSpace,
                heightSpace,
                reviewTitle(),
                reviewListContent()
              ],
            ),
          ),
          heightSpace,
          heightSpace,
          similarTitle(),
          astrologersListContent(size),
        ],
      ),
      bottomNavigationBar: bottomButtonBar(size),
    );
  }

  bottomButtonBar(Size size) {
    return Container(
      color: scaffoldBgColor,
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Row(
        children: [
          buttonWidget(getTranslation(context, 'astrologer_detail.chat'),
              CupertinoIcons.ellipses_bubble, () {
            Navigator.pushNamed(context, '/chat');
          }, size.width * 0.25),
          widthSpace,
          buttonWidget(getTranslation(context, 'astrologer_detail.call'),
              Icons.call_outlined, () {
            Navigator.pushNamed(context, '/call');
          }, size.width * 0.25),
          widthSpace,
          Expanded(
              child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/videocall');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: fixPadding, horizontal: fixPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: primaryColor,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.videocam_outlined,
                    color: whiteColor,
                  ),
                  widthSpace,
                  Expanded(
                    child: Text(
                      getTranslation(context, 'astrologer_detail.video_call'),
                      style: bold18White,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  buttonWidget(String title, IconData icon, Function() onTap, double size) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: size,
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding, horizontal: fixPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: primaryColor,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: whiteColor,
            ),
            widthSpace,
            Expanded(
              child: Text(
                title,
                style: bold18White,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  astrologersListContent(Size size) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(fixPadding),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          astrologersList.length,
          (index) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/astrologersDetail');
              },
              child: Container(
                width: size.width * 0.35,
                padding: const EdgeInsets.all(fixPadding),
                margin: const EdgeInsets.symmetric(horizontal: fixPadding),
                decoration: BoxDecoration(
                  color: blueShade1,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 75,
                          width: 75,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                astrologersList[index]['image'].toString(),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: fixPadding / 1.5,
                                vertical: fixPadding / 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: rec48BgColor,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 15,
                                  color: yellowColor,
                                ),
                                width5Space,
                                Text(
                                  astrologersList[index]['rate'].toString(),
                                  style: medium13WhiteF4,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    heightSpace,
                    height5Space,
                    Text(
                      astrologersList[index]['name'].toString(),
                      style: regualr16White,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${astrologersList[index]['price']}/${getTranslation(context, 'astrologer_detail.min')}",
                      style: bold14Grey,
                      overflow: TextOverflow.ellipsis,
                    ),
                    heightSpace,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: fixPadding * 1.2, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: grey5EColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        getTranslation(context, 'astrologer_detail.connect'),
                        style: medium16White,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  similarTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: titleWidget(getTranslation(context, 'astrologer_detail.title')),
    );
  }

  reviewListContent() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: fixPadding * 2.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: black03Color.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(1, 1),
                            )
                          ],
                          image: DecorationImage(
                            image: AssetImage(
                              reviewList[index]['image'].toString(),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      widthSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reviewList[index]['name'].toString(),
                              style: medium16White,
                            ),
                            height5Space,
                            Row(
                              children: [
                                for (int i = 0; i < 5; i++)
                                  Icon(
                                    i < (reviewList[index]['rate'] as int)
                                        ? Icons.star
                                        : Icons.star_outline,
                                    color: yellowColor,
                                    size: 15,
                                  )
                              ],
                            )
                          ],
                        ),
                      ),
                      widthSpace,
                      Text(
                        reviewList[index]['date'].toString(),
                        style: regualr14Grey,
                      )
                    ],
                  ),
                  heightSpace,
                  Text(
                    reviewList[index]['review'].toString(),
                    style: regualr14Grey,
                  )
                ],
              ),
            ),
            reviewList.length == index + 1
                ? const SizedBox()
                : Container(
                    height: 1,
                    width: double.maxFinite,
                    color: rec48BgColor,
                  )
          ],
        );
      },
      itemCount: reviewList.length,
    );
  }

  reviewTitle() {
    return Row(
      children: [
        Expanded(
          child:
              titleWidget(getTranslation(context, 'astrologer_detail.review')),
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/review');
          },
          child: Text(
            getTranslation(context, 'astrologer_detail.see_all'),
            style: medium14Primary,
          ),
        )
      ],
    );
  }

  aboutText() {
    return const ReadMoreText(
      "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh vivamus et malesuada nulla bibendum.",
      style: regualr14Grey,
      lessStyle: regualr14Primary,
      moreStyle: regualr14Primary,
    );
  }

  titleWidget(String title) {
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
        )
      ],
    );
  }

  astrologerInfo(Size size) {
    return Container(
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
          SizedBox(
            height: 150,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: size.width * 0.32,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: const DecorationImage(
                        image: AssetImage(
                          "assets/astrologer/Astrologer1.png",
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: yellowColor,
                          size: 15,
                        ),
                        width5Space,
                        Text(
                          "4.5",
                          style: regualr14WhiteF4,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          widthSpace,
          widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Brooklyn Simmons",
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
                    const Expanded(
                      child: Text(
                        "Vasthu consultation, Vedic Astrology",
                        style: regualr14Grey,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                height5Space,
                const Row(
                  children: [
                    Icon(
                      Icons.language,
                      size: 18,
                      color: greyColor,
                    ),
                    width5Space,
                    Expanded(
                      child: Text(
                        "English,Hindi,Gujarti",
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
                    const Expanded(
                      child: Text(
                        "8 Years",
                        style: regualr14Grey,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                height5Space,
                Text(
                  "${getTranslation(context, 'astrologer_detail.charge')} : \$30/hour",
                  style: medium16Primary,
                ),
              ],
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
