import 'package:dotted_border/dotted_border.dart';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/services/ai_chat_service.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CompatibilityDetailScreen extends StatefulWidget {
  const CompatibilityDetailScreen({super.key});

  @override
  State<CompatibilityDetailScreen> createState() =>
      _CompatibilityDetailScreenState();
}

class _CompatibilityDetailScreenState extends State<CompatibilityDetailScreen> {
  Map<String, dynamic>? compatibilityData;
  final NotificationStorageService _storageService = NotificationStorageService();
  
  // AI-контент (только тизеры)
  String? _loveTeaser;
  String? _businessTeaser;
  String? _healthTeaser;
  
  // ID документа
  String? _docId;
  
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      compatibilityData = args;
      _docId = args['docId'];
      
      // Читаем тизеры из arguments
      _loveTeaser = args['loveTeaser'];
      _businessTeaser = args['businessTeaser'];
      _healthTeaser = args['healthTeaser'];
      
      // Если тизеры не переданы через args, но есть docId - загружаем из хранилища
      if (_loveTeaser == null && _docId != null) {
        _loadTeasersFromStorage();
      }
    }
    _initialized = true;
  }

  Future<void> _loadTeasersFromStorage() async {
    final saved = await _storageService.getCompatibilityById(_docId!);
    if (saved != null && mounted) {
      setState(() {
        _loveTeaser = saved.loveTeaser;
        _businessTeaser = saved.businessTeaser;
        _healthTeaser = saved.healthTeaser;
      });
    }
  }

  void _navigateToDeepDetail(CompatibilityCategory category, String teaser) {
    Navigator.pushNamed(
      context,
      '/compatibilityDeepDetail',
      arguments: {
        'docId': _docId,
        'sign1': sign1,
        'sign1Image': sign1Image,
        'sign2': sign2,
        'sign2Image': sign2Image,
        'category': category.name,
        'teaser': teaser,
        'person1Name': person1Name,
        'person2Name': person2Name,
        'person1BirthDate': person1BirthDate,
        'person2BirthDate': person2BirthDate,
      },
    );
  }

  List<Map<String, dynamic>> get percentageList {
    if (compatibilityData != null) {
      return [
        {
          "title": translation('compatibility_detail.love'),
          "color": redColor,
          "value": compatibilityData!['lovePercent'] ?? 0.88,
        },
        {
          "title": translation('compatibility_detail.business'),
          "color": greenColor,
          "value": compatibilityData!['businessPercent'] ?? 0.95,
        },
        {
          "title": translation('compatibility_detail.health'),
          "color": primaryColor,
          "value": compatibilityData!['healthPercent'] ?? 0.60,
        }
      ];
    }
    return [
      {
        "title": translation('compatibility_detail.love'),
        "color": redColor,
        "value": 0.88,
      },
      {
        "title": translation('compatibility_detail.business'),
        "color": greenColor,
        "value": 0.95,
      },
      {
        "title": translation('compatibility_detail.health'),
        "color": primaryColor,
        "value": 0.60,
      }
    ];
  }

  String get sign1 => compatibilityData?['sign1'] ?? getTranslation(context, 'compatibility_detail.libra');
  String get sign1Image => compatibilityData?['sign1Image'] ?? "assets/home/image-7.png";
  String get sign2 => compatibilityData?['sign2'] ?? getTranslation(context, 'compatibility_detail.aries');
  String get sign2Image => compatibilityData?['sign2Image'] ?? "assets/home/image-1.png";
  
  String get person1Name => compatibilityData?['person1Name'] ?? 'Person 1';
  String get person2Name => compatibilityData?['person2Name'] ?? 'Person 2';
  String get person1BirthDate => compatibilityData?['person1BirthDate'] ?? '';
  String get person2BirthDate => compatibilityData?['person2BirthDate'] ?? '';

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(isoDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            backButton(context),
            widthSpace,
            width5Space,
            Expanded(
              child: Text(
                getTranslation(context, 'compatibility_detail.compatibility'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          horoscopeDetail(size),
          contentList(),
        ],
      ),
    );
  }

  Widget contentList() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(fixPadding * 2.0),
      decoration: const BoxDecoration(
        color: blueShade1,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: persentListContent(),
          ),
          heightSpace,
          heightSpace,
          titleWidget(
              getTranslation(context, 'compatibility_detail.overall_horoscope'),
              primaryColor),
          heightSpace,
          // User info block
          _buildUserInfoBlock(),
          heightSpace,
          heightSpace,
          
          // Love & Passion Section
          _buildCategorySection(
            title: getTranslation(context, 'compatibility_detail.love_passion'),
            color: redColor,
            teaser: _loveTeaser,
            category: CompatibilityCategory.love,
            icon: Icons.favorite,
          ),
          heightSpace,
          heightSpace,
          
          // Business & Career Section
          _buildCategorySection(
            title: getTranslation(context, 'compatibility_detail.business_career'),
            color: greenColor,
            teaser: _businessTeaser,
            category: CompatibilityCategory.business,
            icon: Icons.business_center,
          ),
          heightSpace,
          heightSpace,
          
          // Health Section
          _buildCategorySection(
            title: getTranslation(context, 'compatibility_detail.health'),
            color: primaryColor,
            teaser: _healthTeaser,
            category: CompatibilityCategory.health,
            icon: Icons.spa,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required Color color,
    required String? teaser,
    required CompatibilityCategory category,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleWidget(title, color),
        heightSpace,
        Text(
          teaser ?? '',
          style: regualr14Grey,
        ),
        heightSpace,
        if (teaser != null)
          _buildGoDeeper(color, category, teaser, icon),
      ],
    );
  }

  Widget _buildGoDeeper(Color color, CompatibilityCategory category, String teaser, IconData icon) {
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

  List<Widget> persentListContent() {
    return List.generate(
      percentageList.length,
      (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding),
          child: Column(
            children: [
              CircularPercentIndicator(
                percent: percentageList[index]['value'] as double,
                progressColor: percentageList[index]['color'] as Color,
                backgroundColor: const Color(0xFF484363),
                radius: 32,
                center: Text(
                  "${((percentageList[index]['value'] as double) * 100).toInt()}%",
                  style: medium18Grey,
                ),
              ),
              heightSpace,
              Text(
                percentageList[index]['title'].toString(),
                style: regualr16Grey,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfoBlock() {
    final name1 = person1Name.isNotEmpty ? person1Name : 'Person 1';
    final name2 = person2Name.isNotEmpty ? person2Name : 'Person 2';
    
    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: recBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(sign1Image, height: 24, width: 24),
              width5Space,
              Expanded(
                child: Text(
                  '$name1 - $sign1 - ${_formatDate(person1BirthDate)}',
                  style: regualr14Grey,
                ),
              ),
            ],
          ),
          height5Space,
          Row(
            children: [
              Image.asset(sign2Image, height: 24, width: 24),
              width5Space,
              Expanded(
                child: Text(
                  '$name2 - $sign2 - ${_formatDate(person2BirthDate)}',
                  style: regualr14Grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget titleWidget(String title, Color color) {
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

  Widget horoscopeDetail(Size size) {
    return Padding(
      padding: const EdgeInsets.only(
          left: fixPadding * 2.0,
          right: fixPadding * 2.0,
          bottom: fixPadding * 3.0,
          top: fixPadding),
      child: Row(
        children: [
          horoscopeWidget(size, sign1Image, sign1),
          Expanded(
            child: Row(
              children: [
                dottedBorder(),
                compareButton(),
                dottedBorder(),
              ],
            ),
          ),
          horoscopeWidget(size, sign2Image, sign2),
        ],
      ),
    );
  }

  Widget compareButton() {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor,
        border: Border.all(
          color: whiteColor,
          width: 5,
        ),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        "assets/compatibility/compare-icon.png",
        height: 20,
        width: 20,
      ),
    );
  }

  Widget dottedBorder() {
    return Expanded(
      child: DottedBorder(
        padding: EdgeInsets.zero,
        dashPattern: const [2.5],
        color: greyColor,
        child: Container(),
      ),
    );
  }

  Widget horoscopeWidget(Size size, image, text) {
    return Container(
      width: size.width * 0.25,
      padding: const EdgeInsets.symmetric(vertical: fixPadding),
      decoration: BoxDecoration(
        color: blueShade1,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: blueShade1.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            image,
            fit: BoxFit.cover,
            height: 50,
          ),
          heightSpace,
          Text(
            text,
            style: regualr16White,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget backButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
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
