import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        centerTitle: false,
        elevation: 0,
        backgroundColor: scaffoldBgColor,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            backButton(context),
            widthSpace,
            width5Space,
            Expanded(
              child: Text(
                getTranslation(context, 'about.about_us'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
            left: fixPadding * 2.0,
            right: fixPadding * 2.0,
            bottom: fixPadding * 2.0,
            top: fixPadding),
        children: const [
          // Main introduction
          Text(
            "Astro Circle is a space for daily reflection, intuition, and personal focus.",
            style: bold18White,
          ),
          heightSpace,
          heightSpace,
          
          // Philosophy
          Text(
            "We don't predict the future and we don't control destiny.\n\nInstead, we help you slow down, notice patterns, and reflect on what matters in your life.",
            style: regualr14Grey,
          ),
          heightSpace,
          heightSpace,
          
          // What we offer
          Text(
            "Through daily signs, intentions, and symbolic guidance, Astro Circle creates a simple ritual that helps you:",
            style: regualr14Grey,
          ),
          heightSpace,
          Text(
            "• focus on your thoughts and emotions\n• reflect on important areas of life\n• feel more clarity and inner balance",
            style: regualr14Grey,
          ),
          heightSpace,
          heightSpace,
          
          // Our approach
          Text(
            "Our experience combines elements of astrology, symbolism, and modern technology to offer gentle guidance — not answers, not rules, and not absolute truths.",
            style: regualr14Grey,
          ),
          heightSpace,
          heightSpace,
          
          // Target audience
          Text(
            "Astro Circle is designed for people who:",
            style: regualr14Grey,
          ),
          heightSpace,
          Text(
            "• enjoy reflection and intuition\n• seek meaning in everyday moments\n• appreciate calm, mindful rituals",
            style: regualr14Grey,
          ),
          heightSpace,
          heightSpace,
          
          // Disclaimer
          Text(
            "Every message in the app is meant to inspire awareness, not decision-making. Your choices are always your own.",
            style: regualr14Grey,
          ),
          heightSpace,
          heightSpace,
          
          // Legal note
          Text(
            "Astro Circle is not a substitute for professional advice and should be used for personal reflection and entertainment purposes.",
            style: regualr14Grey,
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
