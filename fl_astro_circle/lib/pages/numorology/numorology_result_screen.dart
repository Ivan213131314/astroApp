import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../theme/theme.dart';
import 'numorology_service.dart';

class NumerologyResultScreen extends StatefulWidget {
  final NumerologyResult result;
  final String? docId;

  const NumerologyResultScreen({
    super.key,
    required this.result,
    this.docId,
  });

  @override
  State<NumerologyResultScreen> createState() => _NumerologyResultScreenState();
}

class _NumerologyResultScreenState extends State<NumerologyResultScreen> {
  late List<Map<String, dynamic>> percentageList;

  final List<Color> _traitColors = [
    redColor,
    greenColor,
    const Color(0xFF77CCF0),
    const Color(0xFFDFCF3E),
    const Color(0xFFE46BEE),
    const Color(0xFFFF965A),
  ];

  final List<IconData> _traitIcons = [
    Icons.sentiment_very_satisfied,
    Icons.volunteer_activism,
    Icons.verified,
    Icons.assignment_turned_in,
    Icons.fitness_center,
    Icons.psychology,
  ];

  final List<String> _traitKeys = [
    'funny',
    'obedient',
    'honest',
    'responsible',
    'hard_working',
    'smart',
  ];

  final _bottomNavItems = [
    LineAwesomeIcons.home_solid,
    Icons.rocket_launch_rounded,
    CupertinoIcons.heart_fill,
    LineAwesomeIcons.bell,
    LineAwesomeIcons.user,
  ];

  @override
  void initState() {
    super.initState();
    _buildPercentageList();
  }

  void _buildPercentageList() {
    percentageList = [];
    for (int i = 0; i < _traitKeys.length; i++) {
      final key = _traitKeys[i];
      final value = widget.result.traits[key] ?? 0.75;
      percentageList.add({
        'titleKey': 'numorology_detail.$key',
        'value': value,
        'color': _traitColors[i],
        'icon': _traitIcons[i],
      });
    }
  }

  void _navigateToDeepDetail(NumerologyCategory category, String teaser) {
    Navigator.pushNamed(
      context,
      '/numerologyDeepDetail',
      arguments: {
        'docId': widget.docId,
        'luckyNumber': widget.result.luckyNumber,
        'birthDate': widget.result.birthDate,
        'category': category.name,
        'teaser': teaser,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blueShade1,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: 270,
            backgroundColor: scaffoldBgColor,
            elevation: 0,
            titleSpacing: 20.0,
            centerTitle: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _backButton(context),
                widthSpace,
                width5Space,
                Expanded(
                  child: Text(
                    getTranslation(context, 'numorology_detail.numorology'),
                    style: bold18White,
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _numerologyInfo(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _percentageListContent(),
                _details(),
                heightSpace,
                heightSpace,
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: fixPadding,
        horizontal: fixPadding * 2.0,
      ),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: scaffoldBgColor,
        boxShadow: [
          BoxShadow(
            color: recBgColor.withValues(alpha: 0.45),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_bottomNavItems.length, (index) {
          final isSelected = index == 3; // Notifications
          return InkWell(
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/bottombar',
                (route) => false,
                arguments: {'selectedIndex': index},
              );
            },
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                _bottomNavItems[index],
                color: whiteF4Color,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _details() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About Character Section
          _buildCategorySection(
            title: getTranslation(context, 'numorology_detail.about_character'),
            color: const Color(0xFF77CCF0),
            teaser: widget.result.aboutCharacter,
            category: NumerologyCategory.character,
            icon: Icons.psychology,
          ),
          heightSpace,
          heightSpace,

          // About Behavior Section
          _buildCategorySection(
            title: getTranslation(context, 'numorology_detail.about_behavior'),
            color: const Color(0xFFE46BEE),
            teaser: widget.result.aboutBehavior,
            category: NumerologyCategory.behavior,
            icon: Icons.emoji_people,
          ),
          heightSpace,
          heightSpace,

          // Responsibility Section
          _buildCategorySection(
            title: getTranslation(context, 'numorology_detail.responsible'),
            color: const Color(0xFFDFCF3E),
            teaser: widget.result.aboutResponsibility,
            category: NumerologyCategory.responsibility,
            icon: Icons.auto_awesome,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required Color color,
    required String teaser,
    required NumerologyCategory category,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleWidget(title, color),
        heightSpace,
        Text(
          teaser,
          style: regualr14Grey,
        ),
        heightSpace,
        _buildGoDeeper(color, category, teaser, icon),
      ],
    );
  }

  Widget _buildGoDeeper(
      Color color, NumerologyCategory category, String teaser, IconData icon) {
    return GestureDetector(
      onTap: () => _navigateToDeepDetail(category, teaser),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 1.5,
          vertical: fixPadding,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.8), color],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: whiteColor, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Go Deeper',
              style: TextStyle(
                color: whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, color: whiteColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _titleWidget(String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: medium18White,
        ),
        height5Space,
        Container(
          height: 5,
          width: 45,
          color: color,
        )
      ],
    );
  }

  Widget _percentageListContent() {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(fixPadding * 2.0),
      itemCount: percentageList.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: fixPadding * 2.0,
        crossAxisSpacing: fixPadding * 2.0,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final color = percentageList[index]['color'] as Color;
        final icon = percentageList[index]['icon'] as IconData;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  percent: percentageList[index]['value'] as double,
                  progressColor: color,
                  backgroundColor: const Color(0xFF484363),
                  radius: 32,
                  lineWidth: 5,
                  center: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "${((percentageList[index]['value'] as double) * 100).toInt()}%",
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              getTranslation(
                  context, percentageList[index]['titleKey'].toString()),
              style: regualr14Grey,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            )
          ],
        );
      },
    );
  }

  Widget _numerologyInfo() {
    return Padding(
      padding: const EdgeInsets.only(
        top: fixPadding * 2.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          Container(
            height: 100,
            width: 100,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: primaryColor,
              ),
              alignment: Alignment.center,
              child: FittedBox(
                child: Text(
                  "${widget.result.luckyNumber}",
                  style: bold70White,
                ),
              ),
            ),
          ),
          heightSpace,
          Text(
            getTranslation(context, 'numorology_detail.lucky_number'),
            style: medium16Grey,
          ),
          height5Space,
          Text(
            widget.result.birthDate,
            style: bold18Grey,
          )
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/bottombar',
          (route) => false,
          arguments: {'selectedIndex': 0},
        );
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

