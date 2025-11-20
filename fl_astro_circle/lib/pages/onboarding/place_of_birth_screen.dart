import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class PlaceOfBirthScreen extends StatefulWidget {
  const PlaceOfBirthScreen({super.key});

  @override
  State<PlaceOfBirthScreen> createState() => _PlaceOfBirthScreenState();
}

class _PlaceOfBirthScreenState extends State<PlaceOfBirthScreen> {
  final TextEditingController placeController = TextEditingController();
  final FocusNode placeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      placeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    placeController.dispose();
    placeFocusNode.dispose();
    super.dispose();
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
          'Place of birth',
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
              value: 0.4,
              backgroundColor: const Color(0xFF3D3761),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 3,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    placeInputField(),
                    heightSpace,
                    heightSpace,
                    const Text(
                      'We will analyze the position of stars and planets in your place of birth at the moment you were born',
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
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

  Widget placeInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: fixPadding * 2.0,
        vertical: fixPadding * 0.8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2955),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: placeFocusNode.hasFocus ? primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: placeController,
        focusNode: placeFocusNode,
        style: const TextStyle(
          color: whiteColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: const InputDecoration(
          hintText: 'Type in your place of birth',
          hintStyle: TextStyle(
            color: greyColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: fixPadding * 1.2),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget nextButton() {
    return InkWell(
      onTap: placeController.text.isNotEmpty
          ? () {
              Navigator.pushNamed(context, '/onboardingHoroscopesQuestion');
            }
          : null,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
        ),
        decoration: BoxDecoration(
          color: placeController.text.isNotEmpty 
              ? primaryColor 
              : const Color(0xFF3D3761),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: placeController.text.isNotEmpty
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          'NEXT',
          style: TextStyle(
            color: placeController.text.isNotEmpty ? whiteColor : greyColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

