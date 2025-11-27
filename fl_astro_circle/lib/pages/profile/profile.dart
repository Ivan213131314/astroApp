import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: scaffoldBgColor,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: Text(
          getTranslation(context, 'profile.profile'),
          style: bold20White,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: fixPadding * 2.0),
        children: [
          userDetail(size),
          heightSpace,
          // Пункт меню "Astrologers" убран
          // iconListTile(CupertinoIcons.person_3,
          //     getTranslation(context, 'profile.astrologers'), () {
          //   Navigator.pushNamed(context, '/astrologers');
          // }),
          imageListTile("assets/profile/compare.png",
              getTranslation(context, 'profile.compatibility'), () {
            Navigator.pushNamed(context, '/compatibility');
          }),
          imageListTile("assets/profile/number.png",
              getTranslation(context, 'profile.numorology'), () {
            Navigator.pushNamed(context, '/numorology');
          }),
          iconListTile(LineAwesomeIcons.hand_paper,
              getTranslation(context, 'profile.plam_reader'), () {
            Navigator.pushNamed(context, '/plamReader');
          }),
          imageListTile("assets/profile/planet.png",
              getTranslation(context, 'profile.netal_chart'), () {
            Navigator.pushNamed(context, '/natalchart');
          }),
          iconListTile(
              CupertinoIcons.chat_bubble_2,
              "Chat with Astrologer",
              () {
            Navigator.pushNamed(context, '/astrologerChat');
          }),
          iconListTile(
              CupertinoIcons.globe, getTranslation(context, 'profile.language'),
              () {
            Navigator.pushNamed(context, '/language');
          }),
          iconListTile(CupertinoIcons.square_list,
              getTranslation(context, 'profile.about_us'), () {
            Navigator.pushNamed(context, '/aboutUs');
          }),
          iconListTile(LineAwesomeIcons.gem,
              getTranslation(context, 'profile.subscribe'), () {
            Navigator.pushNamed(context, '/subscribe');
          }),
          iconListTile(
            LineAwesomeIcons.sign_out_alt_solid,
            getTranslation(context, 'profile.logout'),
            () {
              logoutDialog(context);
            },
            color: const Color(0xFFEF5353),
          ),
        ],
      ),
    );
  }

  logoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(fixPadding * 2.0),
          contentPadding: EdgeInsets.zero,
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: fixPadding * 2.0,
                    right: fixPadding * 2.0,
                    top: fixPadding * 2.0,
                    bottom: fixPadding),
                child: Text(
                  getTranslation(context, 'profile.logout_text'),
                  style: medium16Blue,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: fixPadding, right: fixPadding, bottom: fixPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        getTranslation(context, 'profile.no'),
                        style: medium16Grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _authService.signOut();
                        
                        // Сбрасываем флаг onboarding при выходе
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('onboarding_completed', false);
                        
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context, 
                            '/onboarding', 
                            (route) => false
                          );
                        }
                      },
                      child: Text(
                        getTranslation(context, 'profile.yes'),
                        style: medium16Blue,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  iconListTile(IconData icon, String title, Function() onTap,
      {Color color = whiteF4Color}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      leading: Icon(
        icon,
        color: color,
        size: 22,
      ),
      minLeadingWidth: 0,
      title: Text(
        title,
        style: medium16WhiteF4.copyWith(color: color),
      ),
    );
  }

  imageListTile(icon, String title, Function() onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      leading: Image.asset(
        icon,
        color: whiteF4Color,
        height: 22,
        width: 22,
      ),
      minLeadingWidth: 0,
      title: Text(
        title,
        style: medium16WhiteF4,
      ),
    );
  }

  userDetail(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Row(
        children: [
          Container(
            height: size.height * 0.1,
            width: size.height * 0.1,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage("assets/profile/profileImage.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          widthSpace,
          widthSpace,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leslie Alexander",
                  style: medium16WhiteF4,
                ),
                heightSpace,
                Text(
                  "+91 (1234567890)",
                  style: medium14Grey,
                )
              ],
            ),
          ),
          widthSpace,
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/editProfile');
            },
            child: const Icon(
              LineAwesomeIcons.edit,
            ),
          )
        ],
      ),
    );
  }
}
