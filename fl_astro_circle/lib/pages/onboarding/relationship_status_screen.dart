import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class RelationshipStatusScreen extends StatefulWidget {
  const RelationshipStatusScreen({super.key});

  @override
  State<RelationshipStatusScreen> createState() => _RelationshipStatusScreenState();
}

class _RelationshipStatusScreenState extends State<RelationshipStatusScreen> {
  String? selectedStatus;

  final List<Map<String, dynamic>> statuses = [
    {'icon': Icons.favorite_border, 'label': 'Single'},
    {'icon': Icons.favorite, 'label': 'In relationship'},
    {'icon': Icons.home, 'label': 'Cohabitants'},
    {'icon': Icons.diamond_outlined, 'label': 'Engaged'},
    {'icon': Icons.diamond, 'label': 'Married'},
    {'icon': Icons.compare_arrows, 'label': 'Separated'},
    {'icon': Icons.heart_broken, 'label': 'Divorced'},
    {'icon': Icons.favorite_outline, 'label': 'Widowed'},
    {'icon': Icons.help_outline, 'label': 'Complicated'},
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
          'Relationship status',
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
              value: 0.65,
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
                    const Text(
                      'Which word best describes your\nrelationship status?',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: fixPadding * 1.5,
                          crossAxisSpacing: fixPadding * 1.5,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: statuses.length,
                        itemBuilder: (context, index) {
                          return statusItem(
                            statuses[index]['icon'],
                            statuses[index]['label'],
                          );
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

  Widget statusItem(IconData icon, String label) {
    final isSelected = selectedStatus == label;
    return InkWell(
      onTap: () {
        setState(() {
          selectedStatus = label;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.pushNamed(context, '/onboardingInterests');
        });
      },
      child: Container(
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
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: isSelected 
                    ? primaryColor.withValues(alpha: 0.5)
                    : primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? primaryColor : whiteColor.withValues(alpha: 0.7),
              ),
            ),
            heightSpace,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? whiteColor : greyColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

