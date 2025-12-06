import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_astro_circle/services/horoscope_service.dart';
import 'package:fl_astro_circle/models/horoscope_data.dart';
import 'horoscope_deep_detail_screen.dart';

class HoroscopeDetailScreen extends StatefulWidget {
  const HoroscopeDetailScreen({super.key});

  @override
  State<HoroscopeDetailScreen> createState() => _HoroscopeDetailScreenState();
}

class _HoroscopeDetailScreenState extends State<HoroscopeDetailScreen> {
  final HoroscopeService _horoscopeService = HoroscopeService();
  
  // Zodiac signs configuration (order matches home.dart and horoscope.dart)
  static const List<Map<String, String>> zodiacSigns = [
    {'id': 'aries', 'image': 'assets/home/image-1.png', 'key': 'horoscope_list.aries'},
    {'id': 'taurus', 'image': 'assets/home/image-2.png', 'key': 'horoscope_list.taurus'},
    {'id': 'gemini', 'image': 'assets/home/image-3.png', 'key': 'horoscope_list.gemini'},
    {'id': 'cancer', 'image': 'assets/home/image-4.png', 'key': 'horoscope_list.cancer'},
    {'id': 'leo', 'image': 'assets/home/image-5.png', 'key': 'horoscope_list.leo'},
    {'id': 'virgo', 'image': 'assets/home/image-6.png', 'key': 'horoscope_list.virgo'},
    {'id': 'libra', 'image': 'assets/home/image-7.png', 'key': 'horoscope_list.libra'},
    {'id': 'scorpio', 'image': 'assets/home/image-8.png', 'key': 'horoscope_list.scorpio'},
    {'id': 'sagittarius', 'image': 'assets/home/image-12.png', 'key': 'horoscope_list.sagittarius'},
    {'id': 'capricorn', 'image': 'assets/home/image-9.png', 'key': 'horoscope_list.capricorn'},
    {'id': 'aquarius', 'image': 'assets/home/image-10.png', 'key': 'horoscope_list.aquarius'},
    {'id': 'pisces', 'image': 'assets/home/image-11.png', 'key': 'horoscope_list.pisces'},
  ];
  
  final list = [
    translation('horoscope_detail.today'),
    translation('horoscope_detail.tomorrow'),
    translation('horoscope_detail.this_week'),
  ];

  int selectedindex = 0;
  
  // Horoscope data from Firestore
  Map<HoroscopePeriod, HoroscopeData?> _horoscopeData = {};
  bool _isLoading = true;
  String? _error;
  
  // Zodiac sign data (initialized from navigation arguments)
  String _zodiacSign = 'virgo';
  String _zodiacImage = 'assets/home/image-6.png';
  String _zodiacKey = 'horoscope_list.virgo';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Data will be loaded after receiving navigation arguments in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    
    // Read zodiac sign index from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['signIndex'] != null) {
      final idx = args['signIndex'] as int;
      if (idx >= 0 && idx < zodiacSigns.length) {
        setState(() {
          _zodiacSign = zodiacSigns[idx]['id']!;
          _zodiacImage = zodiacSigns[idx]['image']!;
          _zodiacKey = zodiacSigns[idx]['key']!;
        });
      }
    }
    
    _initialized = true;
    _loadHoroscopes();
  }

  Future<void> _loadHoroscopes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _horoscopeService.getAllPeriodsForToday(
        zodiacSign: _zodiacSign,
      );
      
      setState(() {
        _horoscopeData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки гороскопа: $e';
        _isLoading = false;
      });
    }
  }

  HoroscopeData? get _currentHoroscope {
    final period = _indexToPeriod(selectedindex);
    return _horoscopeData[period];
  }

  HoroscopePeriod _indexToPeriod(int index) {
    switch (index) {
      case 0:
        return HoroscopePeriod.today;
      case 1:
        return HoroscopePeriod.tomorrow;
      case 2:
        return HoroscopePeriod.thisWeek;
      default:
        return HoroscopePeriod.today;
    }
  }

  void _navigateToDeepDetail(HoroscopeCategory category, String teaser) {
    final timePeriod = selectedindex == 0
        ? getTranslation(context, 'horoscope_detail.today')
        : (selectedindex == 1
            ? getTranslation(context, 'horoscope_detail.tomorrow')
            : getTranslation(context, 'horoscope_detail.this_week'));

    Navigator.pushNamed(
      context,
      '/horoscopeDeepDetail',
      arguments: {
        'zodiacSign': getTranslation(context, _zodiacKey),
        'timePeriod': timePeriod,
        'category': category.name,
        'teaser': teaser,
        'horoscopeData': _currentHoroscope,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: blueShade1,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: 310,
            backgroundColor: scaffoldBgColor,
            elevation: 0,
            titleSpacing: 20.0,
            centerTitle: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                backButton(context),
                widthSpace,
                width5Space,
                Expanded(
                  child: Text(
                    getTranslation(context, 'horoscope_detail.horoscope'),
                    style: bold18White,
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: hotoscopeInfo(size),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                contentList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  contentList() {
    // Show loading indicator
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(fixPadding * 4.0),
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    // Show error message
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: redColor, size: 48),
              heightSpace,
              Text(
                _error!,
                style: regualr14Grey,
                textAlign: TextAlign.center,
              ),
              heightSpace,
              ElevatedButton(
                onPressed: _loadHoroscopes,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state if no data
    if (_currentHoroscope == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          child: Column(
            children: [
              const Icon(Icons.hourglass_empty, color: greyColor, size: 48),
              heightSpace,
              const Text(
                'Гороскоп пока не сгенерирован.\nПопробуйте позже.',
                style: regualr14Grey,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final horoscope = _currentHoroscope!;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding * 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category scores (Love, Business, Health)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryIndicator(
                title: getTranslation(context, 'horoscope_detail.love'),
                color: redColor,
                value: horoscope.getCategoryScore(HoroscopeCategory.love),
              ),
              _buildCategoryIndicator(
                title: getTranslation(context, 'horoscope_detail.business'),
                color: greenColor,
                value: horoscope.getCategoryScore(HoroscopeCategory.business),
              ),
              _buildCategoryIndicator(
                title: getTranslation(context, 'horoscope_detail.health'),
                color: primaryColor,
                value: horoscope.getCategoryScore(HoroscopeCategory.health),
              ),
            ],
          ),
          heightSpace,
          // Overall Horoscope
          titleWidget(
              getTranslation(context, 'horoscope_detail.overall_horoscope'),
              primaryColor),
          heightSpace,
          Text(
            horoscope.overall.text,
            style: regualr14Grey,
          ),
          heightSpace,
          _buildGoDeeper(
            primaryColor,
            HoroscopeCategory.overall,
            horoscope.overall.text,
            Icons.auto_awesome,
          ),
          heightSpace,
          heightSpace,
          // Love & Passion
          titleWidget(getTranslation(context, 'horoscope_detail.love_passion'),
              redColor),
          heightSpace,
          Text(
            horoscope.love.text,
            style: regualr14Grey,
          ),
          heightSpace,
          _buildGoDeeper(
            redColor,
            HoroscopeCategory.love,
            horoscope.love.text,
            Icons.favorite,
          ),
          heightSpace,
          heightSpace,
          // Business & Career
          titleWidget(
              getTranslation(context, 'horoscope_detail.business_career'),
              greenColor),
          heightSpace,
          Text(
            horoscope.business.text,
            style: regualr14Grey,
          ),
          heightSpace,
          _buildGoDeeper(
            greenColor,
            HoroscopeCategory.business,
            horoscope.business.text,
            Icons.business_center,
          ),
          heightSpace,
          heightSpace,
        ],
      ),
    );
  }

  Widget _buildCategoryIndicator({
    required String title,
    required Color color,
    required double value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding),
      child: Column(
        children: [
          CircularPercentIndicator(
            percent: value,
            progressColor: color,
            backgroundColor: const Color(0xFF484363),
            radius: 32,
            center: Text(
              "${(value * 100).toInt()}%",
              style: medium18Grey,
            ),
          ),
          heightSpace,
          Text(
            title,
            style: regualr16Grey,
          )
        ],
      ),
    );
  }

  Widget _buildGoDeeper(
      Color color, HoroscopeCategory category, String teaser, IconData icon) {
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

  titleWidget(String title, Color color) {
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



  hotoscopeInfo(Size size) {
    return Container(
      padding: const EdgeInsets.only(
          left: fixPadding, right: fixPadding, top: fixPadding * 8.0),
      width: double.maxFinite,
      color: scaffoldBgColor,
      child: Column(
        children: [
          Image.asset(
            _zodiacImage,
            height: 135,
          ),
          height5Space,
          Text(
            getTranslation(context, _zodiacKey),
            style: medium25WhiteF4,
          ),
          heightSpace,
          heightSpace,
          listContent(),
        ],
      ),
    );
  }

  listContent() {
    return Row(
      children: List.generate(
        list.length,
        (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedindex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: fixPadding),
                padding: const EdgeInsets.symmetric(
                    vertical: fixPadding / 1.5, horizontal: fixPadding / 5),
                decoration: BoxDecoration(
                  color: selectedindex == index ? primaryColor : blueShade1,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  list[index],
                  style: selectedindex == index ? bold16WhiteF4 : bold16Grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  backButton(BuildContext context) {
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
