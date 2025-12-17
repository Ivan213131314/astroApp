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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String userName = 'user';
  String? _userPhotoPath;
  bool _isExploreExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExplore() {
    setState(() {
      _isExploreExpanded = !_isExploreExpanded;
      if (_isExploreExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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
      "image": "assets/home/natal_chart_premium.png",
      "title": "Netal chart",
      "detail": "Calculate your Netal chart and check your planet position",
      'route': '/natalchart'
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
      "image": "assets/home/service6.png",
      "title": "Ask Universe",
      "detail": "Send your question to the universe via NASA satellites",
      "route": '/universeMessage',
      "locked": true
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
        child: Column(
          children: [
            // Main scrollable content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: _isExploreExpanded ? 20 : 80),
                children: [
                  askUniverseHero(size),
                  heightSpace,
                  heightSpace,
                  titleWidget(getTranslation(context, 'home.horoscope'), () {
                    Navigator.pushNamed(context, '/horoscope');
                  }),
                  heightSpace,
                  horoscopeListContent(),
                  heightSpace,
                  // Expandable content with animation
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    axisAlignment: -1.0,
                    child: Column(
                      children: [
                        heightSpace,
                        otherServicesTitle(),
                        servicesGridContent(),
                        heightSpace,
                        heightSpace,
                        // talkToAstrologerBlock(), // Temporarily hidden
                        heightSpace,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Fixed bottom "Explore More" button
            Container(
              padding: const EdgeInsets.only(bottom: 115, top: 10),
              child: _buildExploreMoreButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreMoreButton() {
    return GestureDetector(
      onTap: _toggleExplore,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isExploreExpanded
                ? [
                    const Color(0xFF4A2F7F).withOpacity(0.4),
                    const Color(0xFF2A1B4D).withOpacity(0.5),
                  ]
                : [
                    const Color(0xFF6B3FA0).withOpacity(0.4),
                    const Color(0xFF8C6AE3).withOpacity(0.3),
                  ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFB388FF).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B3FA0).withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isExploreExpanded ? "Show Less" : "Explore More",
              style: TextStyle(
                color: whiteColor.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _isExploreExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: whiteColor.withOpacity(0.9),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget servicesGridContent() {
    final filteredServices = otherServicesList;

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
                  // Lock icon in top right corner
                  if (filteredServices[index]['locked'] == true)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: whiteColor,
                          size: 14,
                        ),
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

  Widget talkToAstrologerBlock() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/astrologerChat');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        padding: const EdgeInsets.all(fixPadding * 2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6B3FA0).withOpacity(0.8), // Purple
              const Color(0xFF4A2F7F).withOpacity(0.9), // Dark purple
              const Color(0xFF2A1B4D), // Very dark purple
            ],
          ),
          border: Border.all(
            color: const Color(0xFFB388FF).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B3FA0).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: -3,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container with glow effect
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFB388FF), // Light purple
                    Color(0xFF8C6AE3), // Medium purple
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB388FF).withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: whiteColor,
                size: 30,
              ),
            ),
            const SizedBox(width: fixPadding * 1.5),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Talk to Astrologer",
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Get personalized cosmic guidance",
                    style: TextStyle(
                      color: whiteColor.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor.withOpacity(0.1),
                border: Border.all(
                  color: whiteColor.withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: whiteColor,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget askUniverseHero(Size size) {
    return GestureDetector(
      onTap: () {
         Navigator.pushNamed(context, '/universeSign');
      },
      child: Container(
        height: 180, // Reduced height
        margin: const EdgeInsets.only(
            left: fixPadding * 2.0, right: fixPadding * 2.0, top: 20, bottom: fixPadding),
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
              Opacity(
                opacity: 0.5,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/home/universe_card_bg.png"),
                      fit: BoxFit.cover,
                    ),
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

                    const Text(
                      "Universe Sign for Today",
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
                      "Your daily sign from the Universe",
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
                            "Send Intention",
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
