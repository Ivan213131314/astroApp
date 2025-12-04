import 'dart:convert';

import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/theme.dart';
import 'natal_chart_loading_screen.dart';
import 'natal_chart_ai_service.dart';

class NatalChartScreen extends StatefulWidget {
  const NatalChartScreen({super.key});

  @override
  State<NatalChartScreen> createState() => _NatalChartScreenState();
}

class _NatalChartScreenState extends State<NatalChartScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController timeofBirthController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  
  // Google Places
  static const String googleApiKey = "AIzaSyA2SREUYbUCxDavUiFaZ1UyKf6XPI7eZ1k";
  final FocusNode locationFocusNode = FocusNode();
  double? latitude;
  double? longitude;
  
  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    timeofBirthController.dispose();
    locationController.dispose();
    locationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _calculateAndSave() async {
    if (nameController.text.isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (dobController.text.isEmpty) {
      _showError('Please select date of birth');
      return;
    }

    // Переходим на экран загрузки с анимацией
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _NatalChartLoadingWrapper(
          name: nameController.text,
          dateOfBirth: selectedDate,
          timeOfBirth: timeofBirthController.text.isNotEmpty 
              ? timeofBirthController.text 
              : null,
          location: locationController.text.isNotEmpty 
              ? locationController.text 
              : null,
          latitude: latitude,
          longitude: longitude,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: redColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                getTranslation(context, 'natal_chart.natal_chart'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: fixPadding * 2.0,
          right: fixPadding * 2.0,
          bottom: fixPadding * 2.0,
          top: fixPadding,
        ),
        children: [
          natalTitle(),
          heightSpace,
          contentText(),
          heightSpace,
          heightSpace,
          heightSpace,
          nameField(),
          heightSpace,
          heightSpace,
          dateOfBirthField(size),
          heightSpace,
          heightSpace,
          timeOfBirthField(size),
          heightSpace,
          heightSpace,
          locationField(),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          calculateButton(),
        ],
      ),
    );
  }

  contentText() {
    return const Text(
      "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
      style: regualr14Grey,
      textAlign: TextAlign.center,
    );
  }

  natalTitle() {
    return Text(
      getTranslation(context, 'natal_chart.title'),
      style: medium18White,
      textAlign: TextAlign.center,
    );
  }

  calculateButton() {
    return InkWell(
      onTap: _calculateAndSave,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.2, horizontal: fixPadding * 2.0),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.25),
              blurRadius: 5,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'natal_chart.calculate'),
          style: bold20White,
        ),
      ),
    );
  }

  locationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText('${getTranslation(context, 'natal_chart.birth_location')} *'),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: recBgColor,
            boxShadow: [
              BoxShadow(
                color: recBgColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: locationController,
            googleAPIKey: googleApiKey,
            focusNode: locationFocusNode,
            inputDecoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0,
                vertical: fixPadding * 1.4,
              ),
              border: InputBorder.none,
              hintText: getTranslation(context, 'natal_chart.enter_birth_location'),
              hintStyle: regualr15Grey,
            ),
            textStyle: medium15WhiteF4,
            debounceTime: 600,
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (Prediction prediction) {
              setState(() {
                latitude = double.tryParse(prediction.lat ?? '');
                longitude = double.tryParse(prediction.lng ?? '');
              });
            },
            itemClick: (Prediction prediction) {
              locationController.text = prediction.description ?? '';
              locationController.selection = TextSelection.fromPosition(
                TextPosition(offset: locationController.text.length),
              );
              FocusScope.of(context).unfocus();
            },
            seperatedBuilder: Divider(
              color: greyColor.withValues(alpha: 0.3),
              height: 1,
            ),
            containerHorizontalPadding: 0,
            containerVerticalPadding: 0,
            itemBuilder: (context, index, Prediction prediction) {
              return Container(
                color: recBgColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2.0,
                  vertical: fixPadding * 1.2,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: fixPadding),
                    Expanded(
                      child: Text(
                        prediction.description ?? '',
                        style: medium15WhiteF4,
                      ),
                    ),
                  ],
                ),
              );
            },
            isCrossBtnShown: true,
          ),
        )
      ],
    );
  }

  timeOfBirthField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText('${getTranslation(context, 'natal_chart.time_of_birth')} *'),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: recBgColor,
            boxShadow: [
              BoxShadow(
                color: recBgColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            onTap: () {
              timePickerDialog(size);
            },
            readOnly: true,
            style: medium15WhiteF4,
            controller: timeofBirthController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0,
                vertical: fixPadding * 1.4,
              ),
              border: InputBorder.none,
              hintText: getTranslation(context, 'natal_chart.select_time'),
              hintStyle: regualr15Grey,
            ),
          ),
        )
      ],
    );
  }

  timePickerDialog(Size size) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, state) {
              return Dialog(
                backgroundColor: whiteColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                insetPadding: const EdgeInsets.all(fixPadding * 2.0),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: fixPadding * 2.0),
                      child: Text(
                        getTranslation(context, 'natal_chart.time'),
                        style: bold20BlueShade1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: 1,
                      width: double.maxFinite,
                      color: greyD4Color,
                    ),
                    heightSpace,
                    SizedBox(
                      height: size.height * 0.22,
                      child: CupertinoTheme(
                        data: const CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: bold20Primary),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: selectedTime,
                          onDateTimeChanged: (date) {
                            setState(
                              () {
                                selectedTime = date;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    heightSpace,
                    heightSpace,
                    proceedButton(
                      () {
                        setState(() {
                          String formattedTime = DateFormat.jm(
                                  Localizations.localeOf(context).toString())
                              .format(selectedTime);
                          timeofBirthController.text = formattedTime;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    height5Space,
                    iDontKnowButton(),
                    height5Space,
                    cancelButton(context),
                    height5Space,
                  ],
                ),
              );
            },
          );
        });
  }

  dateOfBirthField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText(getTranslation(context, 'natal_chart.date_birth')),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: recBgColor,
            boxShadow: [
              BoxShadow(
                color: recBgColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: medium15WhiteF4,
            controller: dobController,
            onTap: () {
              datePickerDialog(size);
            },
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
              border: InputBorder.none,
              hintText: getTranslation(context, 'natal_chart.select_date'),
              hintStyle: regualr15Grey,
            ),
          ),
        )
      ],
    );
  }

  datePickerDialog(Size size) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Dialog(
              backgroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              insetPadding: const EdgeInsets.all(fixPadding * 2.0),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: fixPadding * 2.0),
                    child: Text(
                      getTranslation(context, 'natal_chart.date'),
                      style: bold20BlueShade1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 1,
                    width: double.maxFinite,
                    color: greyD4Color,
                  ),
                  heightSpace,
                  SizedBox(
                    height: size.height * 0.22,
                    child: ScrollDatePicker(
                      selectedDate: selectedDate,
                      scrollViewOptions: const DatePickerScrollViewOptions(
                        day: ScrollViewDetailOptions(
                          selectedTextStyle: bold20Primary,
                          textStyle: bold18BlueShade1,
                        ),
                        month: ScrollViewDetailOptions(
                          selectedTextStyle: bold20Primary,
                          textStyle: bold18BlueShade1,
                        ),
                        year: ScrollViewDetailOptions(
                            selectedTextStyle: bold20Primary,
                            textStyle: bold18BlueShade1,
                            margin: EdgeInsets.symmetric(
                                horizontal: fixPadding * 2.0)),
                      ),
                      onDateTimeChanged: (date) {
                        state(() {
                          setState(
                            () {
                              selectedDate = date;
                            },
                          );
                        });
                      },
                    ),
                  ),
                  heightSpace,
                  heightSpace,
                  proceedButton(
                    () {
                      setState(() {
                        String formattedDate =
                            DateFormat('dd MMMM yyyy').format(selectedDate);

                        dobController.text = formattedDate;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  height5Space,
                  cancelButton(context),
                  height5Space,
                ],
              ),
            );
          },
        );
      },
    );
  }

  cancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        getTranslation(context, 'natal_chart.cancel'),
        style: bold16Grey,
      ),
    );
  }

  iDontKnowButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          timeofBirthController.text = "I don't know";
        });
        Navigator.pop(context);
      },
      child: const Text(
        "I don't know",
        style: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  proceedButton(Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: primaryColor,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.25),
              blurRadius: 6,
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'natal_chart.proceed'),
          style: bold20White,
        ),
      ),
    );
  }

  nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText(getTranslation(context, 'natal_chart.name')),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: recBgColor,
            boxShadow: [
              BoxShadow(
                color: recBgColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: medium15WhiteF4,
            cursorColor: primaryColor,
            controller: nameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
              border: InputBorder.none,
              hintText: getTranslation(context, 'natal_chart.enter_name'),
              hintStyle: regualr15Grey,
            ),
          ),
        )
      ],
    );
  }

  titleText(String text) {
    return Text(
      text,
      style: bold16WhiteF4,
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
/// Wrapper для экрана загрузки натальной карты
class _NatalChartLoadingWrapper extends StatefulWidget {
  final String name;
  final DateTime dateOfBirth;
  final String? timeOfBirth;
  final String? location;
  final double? latitude;
  final double? longitude;

  const _NatalChartLoadingWrapper({
    required this.name,
    required this.dateOfBirth,
    this.timeOfBirth,
    this.location,
    this.latitude,
    this.longitude,
  });

  @override
  State<_NatalChartLoadingWrapper> createState() => _NatalChartLoadingWrapperState();
}

class _NatalChartLoadingWrapperState extends State<_NatalChartLoadingWrapper> {
  Future<Map<String, dynamic>>? _calculationFuture;
  Map<String, dynamic>? _result;
  final NotificationStorageService _storageService = NotificationStorageService();
  final NatalChartAiService _aiService = NatalChartAiService();
  String _language = 'English';
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _language = _getLanguage();
    
    // Запускаем расчёт только один раз после получения языка
    if (!_started) {
      _started = true;
      _calculationFuture = _calculateNatalChart();
    }
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

  // Генерация уникального ключа кэша на основе входных данных
  String _getCacheKey() {
    final key = '${widget.name.toLowerCase().trim()}_'
        '${widget.dateOfBirth.year}-${widget.dateOfBirth.month}-${widget.dateOfBirth.day}_'
        '${widget.timeOfBirth ?? ''}_'
        '${widget.location ?? ''}';
    return 'natal_chart_${key.hashCode}';
  }

  // Сохранение в локальный кэш
  Future<void> _saveToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = Map<String, dynamic>.from(data);
      if (cacheData['dateOfBirth'] is DateTime) {
        cacheData['dateOfBirth'] = (cacheData['dateOfBirth'] as DateTime).toIso8601String();
      }
      await prefs.setString(_getCacheKey(), jsonEncode(cacheData));
      debugPrint('Natal chart saved to cache: ${_getCacheKey()}');
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  // Загрузка из локального кэша
  Future<Map<String, dynamic>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_getCacheKey());
      if (jsonStr != null) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (data['dateOfBirth'] is String) {
          data['dateOfBirth'] = DateTime.parse(data['dateOfBirth'] as String);
        }
        debugPrint('Natal chart loaded from cache: ${_getCacheKey()}');
        return data;
      }
    } catch (e) {
      debugPrint('Error loading from cache: $e');
    }
    return null;
  }

  /// Вычисление знака зодиака по дате рождения
  String _calculateSunSign(DateTime date) {
    final month = date.month;
    final day = date.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces';
  }

  /// Упрощенный расчет Moon Sign (без точных эфемерид использует приближение)
  String _calculateMoonSign(DateTime date) {
    // Упрощенный расчет: Луна проходит все 12 знаков за ~27.3 дня
    // Начальная точка: 1 января 2000 - Луна в Скорпионе
    final referenceDate = DateTime(2000, 1, 1);
    final daysDiff = date.difference(referenceDate).inDays;
    final moonCycle = 27.3;
    final signsFromReference = (daysDiff / (moonCycle / 12)).floor() % 12;
    
    final signs = ['Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces', 
                   'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra'];
    return signs[signsFromReference];
  }

  /// Упрощенный расчет Rising Sign (зависит от времени рождения)
  String _calculateRisingSign(DateTime date, String? timeOfBirth) {
    // Rising sign меняется каждые ~2 часа
    // Если время неизвестно - используем Sun Sign
    if (timeOfBirth == null || timeOfBirth.isEmpty || timeOfBirth == "I don't know") {
      return _calculateSunSign(date);
    }
    
    // Пытаемся распарсить время
    int hour = 12; // default
    try {
      // Форматы: "10:30 AM", "22:30", etc.
      final timeLower = timeOfBirth.toLowerCase();
      if (timeLower.contains('am') || timeLower.contains('pm')) {
        final parts = timeLower.replaceAll(RegExp(r'[ap]m'), '').trim().split(':');
        hour = int.parse(parts[0]);
        if (timeLower.contains('pm') && hour != 12) hour += 12;
        if (timeLower.contains('am') && hour == 12) hour = 0;
      } else {
        final parts = timeOfBirth.split(':');
        hour = int.parse(parts[0]);
      }
    } catch (e) {
      hour = 12;
    }
    
    // Rising sign основан на времени + Sun sign
    final sunSignIndex = _getSignIndex(_calculateSunSign(date));
    final risingOffset = (hour / 2).floor();
    final risingIndex = (sunSignIndex + risingOffset) % 12;
    
    final signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 
                   'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    return signs[risingIndex];
  }

  int _getSignIndex(String sign) {
    final signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 
                   'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    return signs.indexOf(sign);
  }

  String _formatBirthDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Сохранение в Firebase
  Future<String?> _saveToFirebase({
    required String sunSign,
    required String moonSign,
    required String risingSign,
    String? sunTeaser,
    String? moonTeaser,
    String? risingTeaser,
  }) async {
    try {
      final docId = await _storageService.saveNatalChart(
        name: widget.name,
        dateOfBirth: widget.dateOfBirth,
        timeOfBirth: widget.timeOfBirth ?? '',
        location: widget.location ?? '',
        planetsData: [], // Пустой список, т.к. используем AI
        sunSign: sunSign,
        moonSign: moonSign,
        risingSign: risingSign,
        sunTeaser: sunTeaser,
        moonTeaser: moonTeaser,
        risingTeaser: risingTeaser,
      );
      debugPrint('Natal chart saved to Firebase with ID: $docId');
      return docId;
    } catch (e) {
      debugPrint('Error saving natal chart to Firebase: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _calculateNatalChart() async {
    try {
      debugPrint('=== _calculateNatalChart: Starting ===');
      
      // 1. Сначала проверяем локальный кэш
      final cached = await _loadFromCache();
      if (cached != null && cached['sunTeaser'] != null) {
        debugPrint('=== _calculateNatalChart: Found in cache ===');
        _result = cached;
        await Future.delayed(const Duration(milliseconds: 800));
        return cached;
      }

      // 2. Вычисляем знаки зодиака
      final sunSign = _calculateSunSign(widget.dateOfBirth);
      final moonSign = _calculateMoonSign(widget.dateOfBirth);
      final risingSign = _calculateRisingSign(widget.dateOfBirth, widget.timeOfBirth);
      
      debugPrint('=== Signs calculated: Sun=$sunSign, Moon=$moonSign, Rising=$risingSign ===');

      // 3. Генерируем AI тизеры параллельно
      final language = _language ?? 'English';
      final birthDateFormatted = _formatBirthDate(widget.dateOfBirth);
      
      NatalChartTeasers? teasers;
      try {
        debugPrint('=== Generating AI teasers... ===');
        teasers = await _aiService.generateAllTeasers(
          sunSign: sunSign,
          moonSign: moonSign,
          risingSign: risingSign,
          language: language,
          name: widget.name,
          birthDate: birthDateFormatted,
          birthTime: widget.timeOfBirth,
          location: widget.location,
        );
        debugPrint('=== AI teasers generated successfully ===');
      } catch (e) {
        debugPrint('Error generating AI teasers: $e');
        // Fallback teasers if AI fails
        teasers = NatalChartTeasers(
          sunTeaser: 'Your Sun in $sunSign reveals the core of who you are - your vital essence and life purpose. There are hidden depths to your solar identity waiting to be discovered...',
          moonTeaser: 'With Moon in $moonSign, your emotional landscape holds mysteries even you may not fully understand. Your inner world pulses with lunar wisdom...',
          risingTeaser: 'Your Rising Sign in $risingSign shapes how the world first sees you, yet there is so much more beneath this celestial mask...',
        );
      }

      // 4. Формируем результат
      _result = {
        'name': widget.name,
        'dateOfBirth': widget.dateOfBirth,
        'timeOfBirth': widget.timeOfBirth ?? '',
        'location': widget.location ?? '',
        'sunSign': sunSign,
        'moonSign': moonSign,
        'risingSign': risingSign,
        'sunTeaser': teasers.sunTeaser,
        'moonTeaser': teasers.moonTeaser,
        'risingTeaser': teasers.risingTeaser,
      };
      
      debugPrint('=== _calculateNatalChart: Result created ===');
      debugPrint('Name: ${widget.name}');
      debugPrint('Sun: $sunSign, Moon: $moonSign, Rising: $risingSign');
      debugPrint('SunTeaser length: ${teasers.sunTeaser.length}');

      // 5. Сохраняем в локальный кэш (не блокирующий)
      try {
        await _saveToCache(_result!);
      } catch (e) {
        debugPrint('Error saving to cache: $e');
      }

      // 6. Сохраняем в Firebase и получаем docId (не блокирующий)
      try {
        final docId = await _saveToFirebase(
          sunSign: sunSign,
          moonSign: moonSign,
          risingSign: risingSign,
          sunTeaser: teasers.sunTeaser,
          moonTeaser: teasers.moonTeaser,
          risingTeaser: teasers.risingTeaser,
        );
        
        if (docId != null) {
          _result!['docId'] = docId;
        }
      } catch (e) {
        debugPrint('Error saving to Firebase: $e');
      }

      debugPrint('=== _calculateNatalChart: Completed successfully ===');
      return _result!;
    } catch (e, stackTrace) {
      debugPrint('=== _calculateNatalChart: CRITICAL ERROR ===');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      
      // Создаём минимальный fallback результат, чтобы экран детализации все равно открылся
      final sunSign = _calculateSunSign(widget.dateOfBirth);
      final moonSign = _calculateMoonSign(widget.dateOfBirth);
      final risingSign = _calculateRisingSign(widget.dateOfBirth, widget.timeOfBirth);
      
      _result = {
        'name': widget.name,
        'dateOfBirth': widget.dateOfBirth,
        'timeOfBirth': widget.timeOfBirth ?? '',
        'location': widget.location ?? '',
        'sunSign': sunSign,
        'moonSign': moonSign,
        'risingSign': risingSign,
        'sunTeaser': 'Your Sun in $sunSign reveals the core of who you are.',
        'moonTeaser': 'Your Moon in $moonSign shapes your emotional world.',
        'risingTeaser': 'Your Rising Sign in $risingSign is how the world sees you.',
      };
      
      debugPrint('=== Fallback result created ===');
      return _result!;
    }
  }

  void _onLoadingComplete() {
    debugPrint('=== _onLoadingComplete called ===');
    debugPrint('_result is null: ${_result == null}');
    if (_result != null) {
      debugPrint('_result keys: ${_result!.keys.toList()}');
      debugPrint('sunSign: ${_result!['sunSign']}');
      final sunTeaser = _result!['sunTeaser']?.toString() ?? '';
      debugPrint('sunTeaser: ${sunTeaser.length > 50 ? sunTeaser.substring(0, 50) : sunTeaser}...');
    }
    
    if (_result != null && mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/natalchartDetail',
        arguments: _result,
      );
    } else {
      debugPrint('ERROR: _result is null or not mounted!');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Показываем загрузку пока Future не создан
    if (_calculationFuture == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1a0a3e),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return NatalChartLoadingScreen(
      name: widget.name,
      dateOfBirth: widget.dateOfBirth,
      timeOfBirth: widget.timeOfBirth,
      location: widget.location,
      calculationFuture: _calculationFuture!,
      onComplete: _onLoadingComplete,
    );
  }
}

