import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  Set<String> selectedInterests = {};

  final List<Map<String, dynamic>> interests = [
    {'icon': Icons.attach_money, 'label': 'Money'},
    {'icon': Icons.business_center, 'label': 'Business'},
    {'icon': Icons.handshake, 'label': 'Friends'},
    {'icon': Icons.favorite, 'label': 'Love'},
    {'icon': Icons.people, 'label': 'Family'},
    {'icon': Icons.work, 'label': 'Career'},
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
          'Interests',
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
              value: 0.7,
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
                      'What interests you the most\nin life?',
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
                    heightSpace,
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: fixPadding * 2,
                          crossAxisSpacing: fixPadding * 2,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: interests.length,
                        itemBuilder: (context, index) {
                          return interestItem(
                            interests[index]['icon'],
                            interests[index]['label'],
                          );
                        },
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

  Widget interestItem(IconData icon, String label) {
    final isSelected = selectedInterests.contains(label);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedInterests.remove(label);
          } else {
            selectedInterests.add(label);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? primaryColor.withValues(alpha: 0.3)
              : const Color(0xFF1F1A3D),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFF2F2955),
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
                    : primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? primaryColor : whiteColor.withValues(alpha: 0.5),
              ),
            ),
            heightSpace,
            Text(
              label,
              style: TextStyle(
                color: isSelected ? whiteColor : whiteColor.withValues(alpha: 0.5),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget nextButton() {
    final bool hasSelection = selectedInterests.isNotEmpty;
    
    return InkWell(
      onTap: hasSelection
          ? () {
              Navigator.pushNamed(context, '/onboardingCompatibilityQuestion');
            }
          : null,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
        ),
        decoration: BoxDecoration(
          color: hasSelection 
              ? primaryColor 
              : const Color(0xFF3D3761),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: hasSelection
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
            color: hasSelection ? whiteColor : greyColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

