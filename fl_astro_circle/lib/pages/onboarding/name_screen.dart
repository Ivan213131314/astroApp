import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController nameController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
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
          'Your name',
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
            const LinearProgressIndicator(
              value: 0.55,
              backgroundColor: Color(0xFF3D3761),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
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
                    userAvatar(),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    nameInputField(),
                    heightSpace,
                    const Text(
                      'Enter your name*',
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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

  Widget userAvatar() {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: primaryColor,
      ),
    );
  }

  Widget nameInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: fixPadding * 2.0,
        vertical: fixPadding * 0.8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2955),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: nameFocusNode.hasFocus ? primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: nameController,
        focusNode: nameFocusNode,
        style: const TextStyle(
          color: whiteColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: fixPadding * 1.2),
        ),
        textAlign: TextAlign.center,
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget nextButton() {
    return InkWell(
      onTap: nameController.text.isNotEmpty
          ? () {
              Navigator.pushNamed(context, '/onboardingBirthChartQuestion');
            }
          : null,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
        ),
        decoration: BoxDecoration(
          color: nameController.text.isNotEmpty 
              ? primaryColor 
              : const Color(0xFF3D3761),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: nameController.text.isNotEmpty
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
            color: nameController.text.isNotEmpty ? whiteColor : greyColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

