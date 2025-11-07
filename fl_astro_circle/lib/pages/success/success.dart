import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onWillPop(context),
      child: Scaffold(
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: size.height,
              width: size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/auth/bgImage.png"),
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scaffoldBgColor,
                      const Color(0xFF301B87).withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    Column(
                      children: [
                        doneIcon(),
                        heightSpace,
                        heightSpace,
                        congratulationText(context)
                      ],
                    ),
                    const Spacer(),
                    backButton(context)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  doneIcon() {
    return Container(
      height: 75,
      width: 75,
      decoration: const BoxDecoration(
        color: recBgColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: whiteF4Color,
        size: 50,
      ),
    );
  }

  congratulationText(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        getTranslation(context, 'success.congratulation_text'),
        style: medium15Grey,
        textAlign: TextAlign.center,
      ),
    );
  }

  backButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/bottombar',
          (route) => false,
        );
      },
      child: Text(
        getTranslation(context, 'success.back_to_home'),
        style: medium16White,
      ),
    );
  }

  onWillPop(context) {
    Navigator.pushNamedAndRemoveUntil(context, '/bottombar', (route) => false);
  }
}
