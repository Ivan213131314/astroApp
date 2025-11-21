import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final Map<String, bool> goals = {
    '😊 Understand myself and others better': false,
    '💕 Improve relationship with my partner': false,
    '💡 Receive daily insights and tips': false,
    '🔮 Be prepared for the future': false,
    '❤️ Find my perfect match': false,
    '🔍 Check compatibility with others': false,
    '✨ Get guidance and advice': false,
  };

  double _progress = 0.0;

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
              value: _progress,
              backgroundColor: const Color(0xFF3D3761),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 3,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                children: [
                  heightSpace,
                  heightSpace,
                  const Text(
                    'What are your goals?',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  heightSpace,
                  const Text(
                    'Choose as many as you like for more precise\ncontent personalization',
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
                  ...goals.keys.map((goal) => goalItem(goal)),
                ],
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

  Widget goalItem(String text) {
    final isSelected = goals[text]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: fixPadding * 1.5),
      child: InkWell(
        onTap: () {
          setState(() {
            goals[text] = !goals[text]!;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0,
            vertical: fixPadding * 1.8,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? primaryColor.withValues(alpha: 0.2)
                : const Color(0xFF1F1A3D),
            border: Border.all(
              color: isSelected ? primaryColor : const Color(0xFF2F2955),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? whiteColor : whiteColor.withValues(alpha: 0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? primaryColor : const Color(0xFF3D3761),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: whiteColor,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget nextButton() {
    final bool hasSelection = goals.values.any((selected) => selected);
    
    return InkWell(
      onTap: hasSelection ? () {
        Navigator.pushNamed(context, '/onboardingGoalsInfo');
      } : null,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
        ),
        decoration: BoxDecoration(
          color: hasSelection ? primaryColor : const Color(0xFF3D3761),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: hasSelection ? [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          'NEXT',
          style: TextStyle(
            color: hasSelection ? whiteColor : whiteColor.withValues(alpha: 0.4),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

