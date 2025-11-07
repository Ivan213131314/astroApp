import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final reviewList = [
    {
      "image": "assets/review/review1.png",
      "name": "Ralph Edwards",
      "rate": 4,
      "date": "25 april 2020",
      "review":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris atmattis laoreet quam. Cursus risus nisl nulla et magna maecenasid"
    },
    {
      "image": "assets/review/review3.png",
      "name": "Brooklyn Simmons",
      "rate": 4,
      "date": "25 april 2020",
      "review":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris atmattis laoreet quam. Cursus risus nisl nulla et magna maecenasid"
    },
    {
      "image": "assets/review/review2.png",
      "name": "Esther Howard",
      "rate": 3,
      "date": "25 april 2020",
      "review":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris atmattis laoreet quam. Cursus risus nisl nulla et magna maecenasid"
    },
    {
      "image": "assets/review/review2.png",
      "name": "Esther Howard",
      "rate": 5,
      "date": "25 april 2020",
      "review":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris atmattis laoreet quam. Cursus risus nisl nulla et magna maecenasid"
    },
    {
      "image": "assets/review/review2.png",
      "name": "Esther Howard",
      "rate": 2,
      "date": "25 april 2020",
      "review":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris atmattis laoreet quam. Cursus risus nisl nulla et magna maecenasid"
    },
    {
      "image": "assets/review/review2.png",
      "name": "Esther Howard",
      "rate": 4,
      "date": "25 april 2020",
      "review":
          "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris atmattis laoreet quam. Cursus risus nisl nulla et magna maecenasid"
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
                getTranslation(context, 'review.review'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        itemCount: reviewList.length,
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
