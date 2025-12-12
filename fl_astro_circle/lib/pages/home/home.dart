import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/widget/column_builder.dart';
import 'package:flutter/material.dart';
import 'package:fl_astro_circle/services/user_service.dart';
import 'package:fl_astro_circle/widget/cosmic_background.dart';
import 'dart:io';
import 'dart:ui' as ui;


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
      "image": "assets/home/numerology_premium.png",
      "title": "Numerology",
      "detail": "Know how number effect",
      "route": '/numorology'
    },
    {
      "image": "assets/home/compatibility_premium.png",
      "title": "Compatibility",
      "detail": "Check love and business compatibility ",
      "route": '/compatibility'
    },
    {
      "image": "assets/home/palm_reading_premium.png",
      "title": "Palm reading",
      "detail": "Check heartline,loveline and moneyline",
      "route": '/plamReader'
    },
    {
      "image": "assets/home/natal_chart_premium.png",
      "title": "Netal chart",
      "detail": "Calculate your Netal chart and check your planet position",
      'route': '/natalchart'
    }
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Ensure bottom padding for the floating nav bar
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by CosmicBackground
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent, // Transparent for cosmic background
        centerTitle: false,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: whiteColor.withOpacity(0.5), width: 1),
                image: DecorationImage(
                  image: _userPhotoPath != null
                      ? FileImage(File(_userPhotoPath!)) as ImageProvider
                      : const AssetImage("assets/home/profileImage.png"),
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
                    'Hello, $userName',
                    style: medium14White.copyWith(color: whiteColor.withOpacity(0.7)),
                  ),
                  Text(
                    "${getTranslation(context, 'home.welcome_text')} astro circle",
                    style: medium18White.copyWith(fontWeight: FontWeight.w600),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      body: CosmicBackground(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 100), // Padding for floating nav bar
          children: [
            askUniverseHero(size),
            heightSpace,
            titleWidget(getTranslation(context, 'home.horoscope'), () {
              Navigator.pushNamed(context, '/horoscope');
            }),
            heightSpace,
            horoscopeListContent(),
            heightSpace,
            heightSpace,
            otherServicesTitle(),
            servicesGridContent(),
            heightSpace,
          ],
        ),
      ),
    );
  }

  Widget servicesGridContent() {
    final filteredServices = otherServicesList
        .where((element) => element['title'] != "Ask Universe")
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 1.5),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4, // Rectangular landscape cards
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
                context, filteredServices[index]['route'].toString());
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: whiteColor.withOpacity(0.08), // Glass effect
              border: Border.all(color: whiteColor.withOpacity(0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Stack(
                children: [
                   // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          whiteColor.withOpacity(0.1),
                          whiteColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(fixPadding * 1.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(0),
                          height: 55, // Increased to match zodiac size
                          width: 55,  // Increased to match zodiac size
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage(filteredServices[index]['image'].toString()),
                                fit: BoxFit.contain
                            )
                          ),
                        ),
                        Text(
                          filteredServices[index]['title'].toString(),
                          style: medium16White,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  otherServicesTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        getTranslation(context, 'home.other_services'),
        style: medium18White.copyWith(color: whiteColor.withOpacity(0.9)),
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
                Navigator.pushNamed(
                  context,
                  '/horoscopeDetail',
                  arguments: {'signIndex': index},
                );
              },
              child: Container(
                height: 85,
                width: 75,
                margin: const EdgeInsets.symmetric(horizontal: fixPadding / 2),
                child: Column(
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: whiteColor.withOpacity(0.08),
                        border: Border.all(color: whiteColor.withOpacity(0.2)),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        horoscope[index]['image'].toString(),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      horoscope[index]['name'].toString(),
                      style: medium13WhiteF4.copyWith(fontSize: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: medium18White.copyWith(color: whiteColor.withOpacity(0.9)),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              getTranslation(context, 'home.see_all'),
              style: medium14White.copyWith(color: whiteColor.withOpacity(0.5)),
            ),
          )
        ],
      ),
    );
  }

  Widget askUniverseHero(Size size) {
    return GestureDetector(
      onTap: () {
         Navigator.pushNamed(context, '/universeMessage');
      },
      child: Container(
        height: 220, // Increased height to prevent overflow
        margin: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: Stack(
            children: [
              // Background Image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/home/universe_card_bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Gradient overlay for better text contrast
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              // Glass overlay
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0), // Removed blur to show details
                child: Container(
                   color: whiteColor.withOpacity(0.0),
                ),
              ),
              // Animated Content 
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome, 
                      color: Color(0xFFFFCE31), // Star color
                      size: 30,
                    ),
                    height5Space,
                    const Text(
                      "Ask the Universe",
                      style: TextStyle(
                        fontFamily: 'Cinzel', // Ensure font availability or use default serif
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: whiteColor,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ]
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Receive guidance from the stars",
                      style: medium14White.copyWith(color: whiteColor.withOpacity(0.8)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // Gold to Orange
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Send Message",
                            style: TextStyle(
                              color: Colors.black, // Dark text on gold
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto', 
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.send_rounded, color: Colors.black, size: 16),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
