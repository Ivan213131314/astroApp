import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;

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
          'Your gender',
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
              value: 0.5,
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
                    heightSpace,
                    const Text(
                      'Gender is important for personalizing your relationship guide and well-being readings',
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        genderOption('Male', Icons.male),
                        widthSpace,
                        widthSpace,
                        widthSpace,
                        genderOption('Female', Icons.female),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget genderOption(String gender, IconData icon) {
    final isSelected = selectedGender == gender;
    return InkWell(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.pushNamed(context, '/onboardingName');
        });
      },
      child: Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          color: isSelected 
              ? primaryColor.withValues(alpha: 0.3)
              : const Color(0xFF2F2955),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: isSelected 
                    ? primaryColor.withValues(alpha: 0.5)
                    : primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: isSelected ? primaryColor : whiteColor.withValues(alpha: 0.7),
              ),
            ),
            heightSpace,
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? whiteColor : greyColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

