import 'dart:convert';
import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/pages/compatibility/compatibilityBirthDate/compatibility_loading_screen.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:fl_astro_circle/services/ai_chat_service.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompatibilityBirthDateScreen extends StatefulWidget {
  const CompatibilityBirthDateScreen({super.key});

  @override
  State<CompatibilityBirthDateScreen> createState() =>
      _CompatibilityBirthDateScreenState();
}

class _CompatibilityBirthDateScreenState
    extends State<CompatibilityBirthDateScreen> {
  final NotificationStorageService _storageService = NotificationStorageService();
  final AiChatService _aiService = AiChatService();

  Map<String, dynamic>? _args;
  
  // Сгенерированный AI контент
  Map<String, String>? _generatedContent;

  // Person 1 name and date
  final TextEditingController _person1NameController = TextEditingController();
  DateTime _person1Date = DateTime(1990, 1, 1);
  late FixedExtentScrollController _person1DayController;
  late FixedExtentScrollController _person1MonthController;
  late FixedExtentScrollController _person1YearController;

  // Person 2 name and date
  final TextEditingController _person2NameController = TextEditingController();
  DateTime _person2Date = DateTime(1990, 1, 1);
  late FixedExtentScrollController _person2DayController;
  late FixedExtentScrollController _person2MonthController;
  late FixedExtentScrollController _person2YearController;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  void initState() {
    super.initState();
    _person1DayController = FixedExtentScrollController(initialItem: 0);
    _person1MonthController = FixedExtentScrollController(initialItem: 0);
    _person1YearController = FixedExtentScrollController(initialItem: 40);

    _person2DayController = FixedExtentScrollController(initialItem: 0);
    _person2MonthController = FixedExtentScrollController(initialItem: 0);
    _person2YearController = FixedExtentScrollController(initialItem: 40);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _args = args;
    }
  }

  @override
  void dispose() {
    _person1NameController.dispose();
    _person1DayController.dispose();
    _person1MonthController.dispose();
    _person1YearController.dispose();
    _person2NameController.dispose();
    _person2DayController.dispose();
    _person2MonthController.dispose();
    _person2YearController.dispose();
    super.dispose();
  }

  String get sign1 => _args?['sign1'] ?? '';
  String get sign1Image => _args?['sign1Image'] ?? 'assets/home/image-1.png';
  String get sign2 => _args?['sign2'] ?? '';
  String get sign2Image => _args?['sign2Image'] ?? 'assets/home/image-1.png';

  // ===== Локальный кэш через SharedPreferences =====
  
  String _getCacheKey(String name1, String name2, String birthDate1, String birthDate2) {
    final key = '${name1.toLowerCase().trim()}_${name2.toLowerCase().trim()}_'
        '${birthDate1}_${birthDate2}_${sign1}_${sign2}';
    return 'compatibility_${key.hashCode}';
  }

  Future<void> _saveToCache(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
      debugPrint('Compatibility saved to cache: $key');
    } catch (e) {
      debugPrint('Error saving compatibility to cache: $e');
    }
  }

  Future<Map<String, dynamic>?> _loadFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        debugPrint('Compatibility loaded from cache: $key');
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading compatibility from cache: $e');
    }
    return null;
  }

  // ===== Конец кэша =====

  void _showLoadingAndNavigate() async {
    // Валидация имён
    final name1 = _person1NameController.text.trim();
    final name2 = _person2NameController.text.trim();
    
    if (name1.isEmpty || name2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            name1.isEmpty && name2.isEmpty 
                ? 'Please enter names for both persons'
                : name1.isEmpty 
                    ? 'Please enter name for Person 1'
                    : 'Please enter name for Person 2',
          ),
          backgroundColor: redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    final birthDate1Iso = _person1Date.toIso8601String();
    final birthDate2Iso = _person2Date.toIso8601String();
    final cacheKey = _getCacheKey(name1, name2, birthDate1Iso, birthDate2Iso);
    
    // 1. Сначала проверяем локальный кэш
    final cached = await _loadFromCache(cacheKey);
    if (cached != null && mounted) {
      Navigator.pushNamed(
        context,
        '/compatibilityDetail',
        arguments: cached,
      );
      return;
    }
    
    // 2. Проверяем существующую запись в Firebase
    final existing = await _storageService.findExistingCompatibility(
      name1: name1,
      name2: name2,
      birthDate1: birthDate1Iso,
      birthDate2: birthDate2Iso,
    );
    
    if (existing != null && existing.hasAllTeasers && mounted) {
      // Найдена существующая запись - сохраняем в кэш и переходим
      final resultData = {
        'docId': existing.id,
        'sign1': existing.sign1,
        'sign1Image': existing.sign1Image,
        'sign2': existing.sign2,
        'sign2Image': existing.sign2Image,
        'person1Name': existing.name1,
        'person2Name': existing.name2,
        'person1BirthDate': existing.birthDate1,
        'person2BirthDate': existing.birthDate2,
        'lovePercent': existing.lovePercent,
        'businessPercent': existing.businessPercent,
        'healthPercent': existing.healthPercent,
        'loveTeaser': existing.loveTeaser,
        'businessTeaser': existing.businessTeaser,
        'healthTeaser': existing.healthTeaser,
      };
      
      // Сохраняем в локальный кэш
      await _saveToCache(cacheKey, resultData);
      
      Navigator.pushNamed(
        context,
        '/compatibilityDetail',
        arguments: resultData,
      );
      return;
    }
    
    // 3. Генерируем новую совместимость
    final contentFuture = _generateTeasers();
    
    if (!mounted) return;
    
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return CompatibilityLoadingScreen(
            sign1Image: sign1Image,
            sign2Image: sign2Image,
            sign1Name: sign1,
            sign2Name: sign2,
            contentFuture: contentFuture,
            onComplete: () => _navigateToResult(cacheKey),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  String _getLanguage() {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'ru':
        return 'Russian';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      default:
        return 'English';
    }
  }

  String _formatBirthDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<Map<String, String>> _generateTeasers() async {
    final language = _getLanguage();
    final name1 = _person1NameController.text.trim();
    final name2 = _person2NameController.text.trim();
    final birthDate1 = _formatBirthDate(_person1Date);
    final birthDate2 = _formatBirthDate(_person2Date);
    
    try {
      // Генерируем только 3 коротких тизера параллельно
      final results = await Future.wait([
        _aiService.generateCompatibilityTeaser(
          sign1: sign1, sign2: sign2, 
          category: CompatibilityCategory.love, 
          language: language,
          name1: name1, name2: name2,
          birthDate1: birthDate1, birthDate2: birthDate2,
        ),
        _aiService.generateCompatibilityTeaser(
          sign1: sign1, sign2: sign2, 
          category: CompatibilityCategory.business, 
          language: language,
          name1: name1, name2: name2,
          birthDate1: birthDate1, birthDate2: birthDate2,
        ),
        _aiService.generateCompatibilityTeaser(
          sign1: sign1, sign2: sign2, 
          category: CompatibilityCategory.health, 
          language: language,
          name1: name1, name2: name2,
          birthDate1: birthDate1, birthDate2: birthDate2,
        ),
      ]);
      
      _generatedContent = {
        'loveTeaser': results[0],
        'businessTeaser': results[1],
        'healthTeaser': results[2],
      };
      
      return _generatedContent!;
    } catch (e) {
      debugPrint('Error generating teasers: $e');
      _generatedContent = {
        'loveTeaser': 'The cosmic dance between $name1 and $name2 holds secrets of passion and connection...',
        'businessTeaser': 'When $name1 and $name2 join forces in the professional realm...',
        'healthTeaser': 'The wellness journey of $name1 and $name2 together is written in the celestial patterns...',
      };
      return _generatedContent!;
    }
  }

  Future<void> _navigateToResult(String cacheKey) async {
    try {
      final random = Random();
      final lovePercent = 0.5 + random.nextDouble() * 0.5;
      final businessPercent = 0.5 + random.nextDouble() * 0.5;
      final healthPercent = 0.5 + random.nextDouble() * 0.5;
      
      final name1 = _person1NameController.text.trim();
      final name2 = _person2NameController.text.trim();
      final birthDate1Iso = _person1Date.toIso8601String();
      final birthDate2Iso = _person2Date.toIso8601String();

      // Сохраняем в Firebase
      final docId = await _storageService.saveCompatibility(
        sign1: sign1,
        sign1Image: sign1Image,
        sign2: sign2,
        sign2Image: sign2Image,
        lovePercent: lovePercent,
        businessPercent: businessPercent,
        healthPercent: healthPercent,
        name1: name1,
        name2: name2,
        birthDate1: birthDate1Iso,
        birthDate2: birthDate2Iso,
      );
      
      // Сохраняем тизеры в Firebase
      if (_generatedContent != null) {
        await _storageService.updateCompatibilityContent(
          docId,
          loveTeaser: _generatedContent!['loveTeaser'],
          businessTeaser: _generatedContent!['businessTeaser'],
          healthTeaser: _generatedContent!['healthTeaser'],
        );
      }

      // Подготавливаем данные результата
      final resultData = {
        'docId': docId,
        'sign1': sign1,
        'sign1Image': sign1Image,
        'sign2': sign2,
        'sign2Image': sign2Image,
        'person1Name': name1,
        'person2Name': name2,
        'person1BirthDate': birthDate1Iso,
        'person2BirthDate': birthDate2Iso,
        'lovePercent': lovePercent,
        'businessPercent': businessPercent,
        'healthPercent': healthPercent,
        'loveTeaser': _generatedContent?['loveTeaser'],
        'businessTeaser': _generatedContent?['businessTeaser'],
        'healthTeaser': _generatedContent?['healthTeaser'],
      };
      
      // Сохраняем в локальный кэш
      await _saveToCache(cacheKey, resultData);

      if (!mounted) return;

      // Replace loading screen with result
      Navigator.pushReplacementNamed(
        context,
        '/compatibilityDetail',
        arguments: resultData,
      );
    } catch (e) {
      Navigator.pop(context); // Close loading screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to calculate compatibility: $e'),
          backgroundColor: redColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: Row(
          children: [
            _backButton(context),
            widthSpace,
            width5Space,
            Expanded(
              child: Text(
                getTranslation(context, 'compatibility_birth_date.title'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _bgImage(size),
            Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(fixPadding * 2.0),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _signsRow(size),
                      heightSpace,
                      heightSpace,
                      _subtitleText(),
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      _personDateSection(
                        title: getTranslation(
                            context, 'compatibility_birth_date.person1_date'),
                        signImage: sign1Image,
                        signName: sign1,
                        date: _person1Date,
                        nameController: _person1NameController,
                        dayController: _person1DayController,
                        monthController: _person1MonthController,
                        yearController: _person1YearController,
                        onDateChanged: (date) {
                          setState(() => _person1Date = date);
                        },
                      ),
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      _personDateSection(
                        title: getTranslation(
                            context, 'compatibility_birth_date.person2_date'),
                        signImage: sign2Image,
                        signName: sign2,
                        date: _person2Date,
                        nameController: _person2NameController,
                        dayController: _person2DayController,
                        monthController: _person2MonthController,
                        yearController: _person2YearController,
                        onDateChanged: (date) {
                          setState(() => _person2Date = date);
                        },
                      ),
                    ],
                  ),
                ),
                _calculateButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _signsRow(Size size) {
    return Row(
      children: [
        _signWidget(size, sign1Image, sign1),
        Expanded(
          child: Row(
            children: [
              _dottedBorder(),
              _heartIcon(),
              _dottedBorder(),
            ],
          ),
        ),
        _signWidget(size, sign2Image, sign2),
      ],
    );
  }

  Widget _heartIcon() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor,
        border: Border.all(color: whiteColor, width: 3),
      ),
      child: const Icon(
        Icons.favorite,
        color: whiteColor,
        size: 18,
      ),
    );
  }

  Widget _signWidget(Size size, String image, String name) {
    return Container(
      width: size.width * 0.25,
      padding: const EdgeInsets.symmetric(vertical: fixPadding),
      decoration: BoxDecoration(
        color: blueShade1,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
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
            height: 45,
          ),
          height5Space,
          Text(
            name,
            style: regualr16White,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _dottedBorder() {
    return Expanded(
      child: DottedBorder(
        padding: EdgeInsets.zero,
        dashPattern: const [2.5],
        color: greyColor,
        child: Container(),
      ),
    );
  }

  Widget _subtitleText() {
    return Text(
      getTranslation(context, 'compatibility_birth_date.subtitle'),
      style: medium16Grey,
      textAlign: TextAlign.center,
    );
  }

  Widget _personDateSection({
    required String title,
    required String signImage,
    required String signName,
    required DateTime date,
    required TextEditingController nameController,
    required FixedExtentScrollController dayController,
    required FixedExtentScrollController monthController,
    required FixedExtentScrollController yearController,
    required Function(DateTime) onDateChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: blueShade1,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: recBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  signImage,
                  fit: BoxFit.contain,
                ),
              ),
              widthSpace,
              Expanded(
                child: Text(
                  title,
                  style: medium16White,
                ),
              ),
              Text(
                '${date.day} ${_months[date.month - 1]} ${date.year}',
                style: medium14Primary,
              ),
            ],
          ),
          heightSpace,
          // Name input field
          TextField(
            controller: nameController,
            style: const TextStyle(color: whiteColor, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter name',
              hintStyle: TextStyle(color: greyColor.withValues(alpha: 0.7)),
              filled: true,
              fillColor: recBgColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 1.5,
                vertical: fixPadding,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
              ),
            ),
          ),
          heightSpace,
          _datePicker(
            date: date,
            dayController: dayController,
            monthController: monthController,
            yearController: yearController,
            onDateChanged: onDateChanged,
          ),
        ],
      ),
    );
  }

  Widget _datePicker({
    required DateTime date,
    required FixedExtentScrollController dayController,
    required FixedExtentScrollController monthController,
    required FixedExtentScrollController yearController,
    required Function(DateTime) onDateChanged,
  }) {
    final daysInMonth = _getDaysInMonth(date.year, date.month);

    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              scrollController: dayController,
              itemExtent: 36,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: primaryColor.withValues(alpha: 0.3), width: 1),
                    bottom: BorderSide(
                        color: primaryColor.withValues(alpha: 0.3), width: 1),
                  ),
                ),
              ),
              onSelectedItemChanged: (index) {
                final newDay = index + 1;
                onDateChanged(DateTime(date.year, date.month, newDay));
              },
              children: List.generate(daysInMonth, (index) {
                return Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            flex: 2,
            child: CupertinoPicker(
              scrollController: monthController,
              itemExtent: 36,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: primaryColor.withValues(alpha: 0.3), width: 1),
                    bottom: BorderSide(
                        color: primaryColor.withValues(alpha: 0.3), width: 1),
                  ),
                ),
              ),
              onSelectedItemChanged: (index) {
                final newMonth = index + 1;
                final newDaysInMonth = _getDaysInMonth(date.year, newMonth);
                final newDay = date.day > newDaysInMonth ? newDaysInMonth : date.day;
                onDateChanged(DateTime(date.year, newMonth, newDay));
              },
              children: _months.map((month) {
                return Center(
                  child: Text(
                    month,
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              scrollController: yearController,
              itemExtent: 36,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: primaryColor.withValues(alpha: 0.3), width: 1),
                    bottom: BorderSide(
                        color: primaryColor.withValues(alpha: 0.3), width: 1),
                  ),
                ),
              ),
              onSelectedItemChanged: (index) {
                final newYear = 1950 + index;
                final newDaysInMonth = _getDaysInMonth(newYear, date.month);
                final newDay = date.day > newDaysInMonth ? newDaysInMonth : date.day;
                onDateChanged(DateTime(newYear, date.month, newDay));
              },
              children: List.generate(76, (index) {
                return Center(
                  child: Text(
                    '${1950 + index}',
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calculateButton() {
    return Padding(
      padding: const EdgeInsets.all(fixPadding * 2.0),
      child: InkWell(
        onTap: _showLoadingAndNavigate,
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: fixPadding * 1.5),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            getTranslation(context, 'compatibility_birth_date.calculate'),
            style: const TextStyle(
              color: whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bgImage(Size size) {
    return Container(
      height: size.height,
      width: size.width,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.maxFinite,
        height: size.height * 0.22,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/compatibility/bgImage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scaffoldBgColor,
                scaffoldBgColor.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
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
