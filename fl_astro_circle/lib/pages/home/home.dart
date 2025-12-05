import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/widget/column_builder.dart';
import 'package:flutter/material.dart';
import 'package:fl_astro_circle/services/user_service.dart';
import 'dart:io';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'user';
  String? _userPhotoPath;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userService = UserService();
    final name = await userService.getUserName();
    final photoPath = await userService.getLocalProfilePhotoPath();
    
    if (name != null && name.isNotEmpty) {
      setState(() {
        userName = name;
      });
    }
    
    if (photoPath != null) {
      setState(() {
        _userPhotoPath = photoPath;
      });
    }
  }
  final horoscope = [
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

  final otherServicesList = [
    {
      "image": "assets/home/service6.png",
      "title": "Ask Universe",
      "detail": "Send your question to the universe via NASA satellites",
      "route": '/universeMessage'
    },
    {
      "image": "assets/home/service1.png",
      "title": "Numerology",
      "detail": "Know how number effect",
      "route": '/numorology'
    },
    {
      "image": "assets/home/service2.png",
      "title": "Compatibility",
      "detail": "Check love and business compatibility ",
      "route": '/compatibility'
    },
    {
      "image": "assets/home/service3.png",
      "title": "Palm reading",
      "detail": "Check heartline,loveline and moneyline",
      "route": '/plamReader'
    },
    {
      "image": "assets/home/service4.png",
      "title": "Netal chart",
      "detail": "Calculate your Netal chart and check your planet position",
      'route': '/natalchart'
    }
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: scaffoldBgColor,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: whiteF4Color, width: 1),
                image: DecorationImage(
                  image: _userPhotoPath != null
                      ? FileImage(File(_userPhotoPath!)) as ImageProvider
                      : const AssetImage("assets/home/profileImage.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            widthSpace,
            width5Space,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello $userName',
                    style: medium14WhiteF4,
                  ),
                  Text(
                    "${getTranslation(context, 'home.welcome_text')} astro circle",
                    style: medium16WhiteF4,
                  )
                ],
              ),
            )
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          startNowPoster(size),
          heightSpace,
          titleWidget(getTranslation(context, 'home.horoscope'), () {
            Navigator.pushNamed(context, '/horoscope');
          }),
          heightSpace,
          horoscopeListContent(),
          heightSpace,
          heightSpace,
          // Секция астрологов убрана
          // titleWidget(getTranslation(context, 'home.top_astrologers'), () {
          //   Navigator.pushNamed(context, '/astrologers');
          // }),
          // heightSpace,
          // astrologersListContent(size),
          // heightSpace,
          otherServicesTitle(),
          otherServicesListContent(),
          heightSpace,
        ],
      ),
    );
  }

  otherServicesListContent() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
                context, otherServicesList[index]['route'].toString());
          },
          child: Container(
            height: 145,
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(
              vertical: fixPadding,
              horizontal: fixPadding * 2.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: greyColor),
              image: DecorationImage(
                image: AssetImage(
                  otherServicesList[index]['image'].toString(),
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(fixPadding * 1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                  colors: [
                    blueShade1,
                    const Color(0xFF514587).withValues(alpha: 0),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherServicesList[index]['title'].toString(),
                        style: bold18White,
                        overflow: TextOverflow.ellipsis,
                      ),
                      height5Space,
                      Padding(
                        padding: const EdgeInsets.only(right: fixPadding * 5.0),
                        child: Text(
                          otherServicesList[index]['detail'].toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: medium16Grey,
                        ),
                      )
                    ],
                  ),
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: grey5EColor,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: whiteColor,
                      size: 22,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      itemCount: otherServicesList.length,
    );
  }

  otherServicesTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslation(context, 'home.other_services'),
            style: medium18White,
          ),
          height5Space,
          Container(
            height: 5,
            width: 45,
            color: primaryColor,
          )
        ],
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
                  color: recBgColor,
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
                      "${astrologersList[index]['price']}/min",
                      style: bold14GreyD4,
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
                        getTranslation(context, 'home.connect'),
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

  horoscopeListContent() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 1.5),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          horoscope.length,
          (index) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/horoscopeDetail');
              },
              child: Container(
                height: 78,
                width: 83,
                margin: const EdgeInsets.symmetric(horizontal: fixPadding / 2),
                decoration: BoxDecoration(
                  color: recBgColor,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: blueShade1.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      horoscope[index]['image'].toString(),
                      height: 40,
                    ),
                    height5Space,
                    Text(
                      horoscope[index]['name'].toString(),
                      style: medium16WhiteF4,
                      overflow: TextOverflow.ellipsis,
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

  titleWidget(title, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: medium18White,
                ),
              ),
              InkWell(
                onTap: onTap,
                child: Text(
                  getTranslation(context, 'home.see_all'),
                  style: medium15Grey,
                ),
              )
            ],
          ),
          height5Space,
          Container(
            height: 5,
            width: 45,
            color: primaryColor,
          )
        ],
      ),
    );
  }

  startNowPoster(Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding),
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding * 1.5),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: recBgColor.withValues(alpha: 0.25),
          ),
        ],
        borderRadius: BorderRadius.circular(10.0),
        image: const DecorationImage(
          image: AssetImage("assets/home/poster.png"),
          fit: BoxFit.cover,
          matchTextDirection: true,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslation(context, 'home.talk_to_astrology'),
            style: bold20Black03,
            overflow: TextOverflow.ellipsis,
          ),
          heightBox(7.0),
          Text(
            getTranslation(context, 'home.change_life'),
            style: medium16Black03,
            overflow: TextOverflow.ellipsis,
          ),
          heightSpace,
          heightSpace,
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/astrologerChat');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 1.5,
                vertical: 7.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1A07),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                getTranslation(context, 'home.start_now'),
                style: medium18White,
              ),
            ),
          )
        ],
      ),
    );
  }
}
