import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:fl_astro_circle/pages/natalChart/natal_chart_ai_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class NatalChartDetailScreen extends StatefulWidget {
  const NatalChartDetailScreen({super.key});

  @override
  State<NatalChartDetailScreen> createState() => _NatalChartDetailScreenState();
}

class _NatalChartDetailScreenState extends State<NatalChartDetailScreen> {
  Map<String, dynamic>? chartData;
  final NotificationStorageService _storageService = NotificationStorageService();
  
  // AI-контент (тизеры)
  String? _sunTeaser;
  String? _moonTeaser;
  String? _risingTeaser;
  
  // Знаки зодиака
  String? _sunSign;
  String? _moonSign;
  String? _risingSign;
  
  // ID документа
  String? _docId;
  
  // Флаг перехода с экрана уведомлений
  bool _fromNotifications = false;
  
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    
    final args = ModalRoute.of(context)?.settings.arguments;
    debugPrint('=== NatalChartDetailScreen didChangeDependencies ===');
    debugPrint('args is null: ${args == null}');
    debugPrint('args type: ${args.runtimeType}');
    
    if (args != null && args is Map<String, dynamic>) {
      debugPrint('args keys: ${args.keys.toList()}');
      debugPrint('sunSign from args: ${args['sunSign']}');
      
      chartData = args;
      _docId = args['docId'];
      _fromNotifications = args['fromNotifications'] == true;
      
      // Читаем данные из arguments
      _sunSign = args['sunSign'];
      _moonSign = args['moonSign'];
      _risingSign = args['risingSign'];
      _sunTeaser = args['sunTeaser'];
      _moonTeaser = args['moonTeaser'];
      _risingTeaser = args['risingTeaser'];
      
      debugPrint('After assignment - _sunSign: $_sunSign');
      debugPrint('After assignment - _sunTeaser: ${_sunTeaser?.substring(0, 50)}...');
      
      // Если тизеры не переданы через args, но есть docId - загружаем из хранилища
      if (_sunTeaser == null && _docId != null) {
        _loadTeasersFromStorage();
      }
    } else {
      debugPrint('ERROR: args is null or not Map!');
    }
    _initialized = true;
  }

  Future<void> _loadTeasersFromStorage() async {
    final saved = await _storageService.getNatalChartById(_docId!);
    if (saved != null && mounted) {
      setState(() {
        _sunSign = saved.sunSign;
        _moonSign = saved.moonSign;
        _risingSign = saved.risingSign;
        _sunTeaser = saved.sunTeaser;
        _moonTeaser = saved.moonTeaser;
        _risingTeaser = saved.risingTeaser;
      });
    }
  }

  void _navigateToDeepDetail(NatalChartCategory category, String teaser, String sign) {
    Navigator.pushNamed(
      context,
      '/natalChartDeepDetail',
      arguments: {
        'docId': _docId,
        'category': category.name,
        'teaser': teaser,
        'sign': sign,
        'name': name,
        'dateOfBirth': dateOfBirth,
        'timeOfBirth': timeOfBirth,
        'location': location,
      },
    );
  }

  String get name => chartData?['name'] ?? '';
  DateTime? get dateOfBirth => chartData?['dateOfBirth'] is DateTime 
      ? chartData!['dateOfBirth'] 
      : (chartData?['dateOfBirth'] is String 
          ? DateTime.tryParse(chartData!['dateOfBirth']) 
          : null);
  String get timeOfBirth => chartData?['timeOfBirth'] ?? '';
  String get location => chartData?['location'] ?? '';

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  final _bottomNavItems = [
    LineAwesomeIcons.home_solid,
    Icons.rocket_launch_rounded,
    CupertinoIcons.heart_fill,
    LineAwesomeIcons.bell,
    LineAwesomeIcons.user,
  ];

  @override
  Widget build(BuildContext context) {
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
                getTranslation(context, 'natal_chart_detail.natal_chart'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(),
          _buildContent(),
        ],
      ),
      bottomNavigationBar: _fromNotifications ? null : _buildBottomNavigationBar(),
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
                color: Colors.transparent,
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: Column(
        children: [
          // Zodiac wheel image
          Image.asset(
            "assets/natalDetail/natalchartImage.png",
            height: 180,
            fit: BoxFit.contain,
          ),
          heightSpace,
          heightSpace,
          // User info
          Text(
            name,
            style: bold20White,
            textAlign: TextAlign.center,
          ),
          height5Space,
          Text(
            '${_formatDate(dateOfBirth)} • ${timeOfBirth.isNotEmpty ? timeOfBirth : "Time unknown"}',
            style: regualr14Grey,
            textAlign: TextAlign.center,
          ),
          if (location.isNotEmpty) ...[
            height5Space,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: greyColor, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    location,
                    style: regualr14Grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
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
          // Signs summary
          _buildSignsSummary(),
          heightSpace,
          heightSpace,
          
          // Sun Sign Section
          _buildCategorySection(
            title: getTranslation(context, 'natal_chart_detail.title1'),
            subtitle: _sunSign ?? 'Unknown',
            color: Colors.orange,
            teaser: _sunTeaser,
            category: NatalChartCategory.sunSign,
            icon: Icons.wb_sunny,
          ),
          heightSpace,
          heightSpace,
          
          // Moon Sign Section
          _buildCategorySection(
            title: getTranslation(context, 'natal_chart_detail.title2'),
            subtitle: _moonSign ?? 'Unknown',
            color: Colors.blueGrey,
            teaser: _moonTeaser,
            category: NatalChartCategory.moonSign,
            icon: Icons.nightlight_round,
          ),
          heightSpace,
          heightSpace,
          
          // Rising Sign Section
          _buildCategorySection(
            title: getTranslation(context, 'natal_chart_detail.title3'),
            subtitle: _risingSign ?? 'Unknown',
            color: primaryColor,
            teaser: _risingTeaser,
            category: NatalChartCategory.risingSign,
            icon: Icons.arrow_upward,
          ),
          heightSpace,
          heightSpace,
        ],
      ),
    );
  }

  Widget _buildSignsSummary() {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: recBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSignBadge('☉', _sunSign ?? '?', Colors.orange),
          _buildSignBadge('☽', _moonSign ?? '?', Colors.blueGrey),
          _buildSignBadge('↑', _risingSign ?? '?', primaryColor),
        ],
      ),
    );
  }

  Widget _buildSignBadge(String symbol, String sign, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        height5Space,
        Text(
          sign,
          style: regualr14Grey,
        ),
      ],
    );
  }

  Widget _buildCategorySection({
    required String title,
    required String subtitle,
    required Color color,
    required String? teaser,
    required NatalChartCategory category,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            widthSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: medium18White,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        height5Space,
        Container(
          height: 3,
          width: 45,
          margin: const EdgeInsets.only(left: 48),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        heightSpace,
        Text(
          teaser ?? 'Loading cosmic insights...',
          style: regualr14Grey,
        ),
        heightSpace,
        if (teaser != null)
          _buildGoDeeper(color, category, teaser, subtitle, icon),
      ],
    );
  }

  Widget _buildGoDeeper(Color color, NatalChartCategory category, String teaser, String sign, IconData icon) {
    return GestureDetector(
      onTap: () => _navigateToDeepDetail(category, teaser, sign),
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
