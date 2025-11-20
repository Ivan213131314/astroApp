import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class MainReasonScreen extends StatefulWidget {
  const MainReasonScreen({super.key});

  @override
  State<MainReasonScreen> createState() => _MainReasonScreenState();
}

class _MainReasonScreenState extends State<MainReasonScreen> {
  String? selectedReason;

  final List<String> reasons = [
    'Make decisions with confidence',
    'Receive answers to my questions',
    'Get an outside perspective',
    'Feel hope and motivation',
  ];

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
          'Your goals',
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
              value: 0.15,
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
                      'What is your main reason for\nwanting to get guidance and\nadvice?',
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
                      child: ListView.builder(
                        itemCount: reasons.length,
                        itemBuilder: (context, index) {
                          return reasonItem(reasons[index]);
                        },
                      ),
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

  Widget reasonItem(String text) {
    final isSelected = selectedReason == text;
    return Padding(
      padding: const EdgeInsets.only(bottom: fixPadding * 1.5),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedReason = text;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pushNamed(context, '/onboardingGoalTogether');
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0,
            vertical: fixPadding * 2.5,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? primaryColor.withValues(alpha: 0.2)
                : const Color(0xFF2F2955),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

