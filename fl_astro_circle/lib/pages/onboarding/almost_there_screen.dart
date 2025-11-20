import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlmostThereScreen extends StatefulWidget {
  const AlmostThereScreen({super.key});

  @override
  State<AlmostThereScreen> createState() => _AlmostThereScreenState();
}

class _AlmostThereScreenState extends State<AlmostThereScreen> {
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (!mounted) return;
    Navigator.pushNamed(context, '/register');
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Almost there',
          style: TextStyle(
            color: whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scaffoldBgColor,
              Color(0xFF301B87),
            ],
          ),
        ),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: 0.95,
              backgroundColor: const Color(0xFF3D3761),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 3,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                child: Column(
                  children: [
                    heightSpace,
                    heightSpace,
                    const Text(
                      'Lde, achieve all your goals\nwith AstroCircle',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: comparisonColumn(
                              'Without AstroCircle',
                              [
                                'Seeking advice and support',
                                'Unsure how astrology influences',
                                "Unfamiliar with others' traits",
                                'Having doubts',
                              ],
                              false,
                            ),
                          ),
                          widthSpace,
                          widthSpace,
                          Expanded(
                            child: comparisonColumn(
                              'With AstroCircle',
                              [
                                'Receiving answers to your questions',
                                'Using insights to improve your life',
                                'Understanding other people better',
                                'Receiving personal advice',
                              ],
                              true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              child: nextButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget comparisonColumn(String title, List<String> items, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: isPositive 
            ? primaryColor.withValues(alpha: 0.25)
            : const Color(0xFF2F2955).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: isPositive 
            ? Border.all(color: primaryColor, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isPositive ? whiteColor : greyColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          heightSpace,
          heightSpace,
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: fixPadding * 1.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    isPositive ? Icons.check_circle : Icons.remove_circle_outline,
                    size: 18,
                    color: isPositive ? primaryColor : greyColor,
                  ),
                ),
                width5Space,
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isPositive ? whiteF4Color : greyColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget nextButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/register');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
        ),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'NEXT',
          style: TextStyle(
            color: whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

