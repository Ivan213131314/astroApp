import 'dart:math';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/pages/natalChart/natal_chart_ai_service.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:flutter/material.dart';

class NatalChartDeepDetailScreen extends StatefulWidget {
  const NatalChartDeepDetailScreen({super.key});

  @override
  State<NatalChartDeepDetailScreen> createState() => _NatalChartDeepDetailScreenState();
}

class _NatalChartDeepDetailScreenState extends State<NatalChartDeepDetailScreen>
    with TickerProviderStateMixin {
  final NatalChartAiService _aiService = NatalChartAiService();
  final NotificationStorageService _storageService = NotificationStorageService();

  AnimationController? _orbitController;
  AnimationController? _pulseController;

  String? _docId;
  String? _sign;
  NatalChartCategory? _category;
  String? _teaser;
  String? _name;
  DateTime? _dateOfBirth;
  String? _timeOfBirth;
  String? _location;

  bool _isLoading = true;
  String? _detailContent;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbitController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _docId = args['docId'];
      _sign = args['sign'];
      _teaser = args['teaser'];
      _name = args['name'];
      _timeOfBirth = args['timeOfBirth'];
      _location = args['location'];

      final dob = args['dateOfBirth'];
      if (dob is DateTime) {
        _dateOfBirth = dob;
      } else if (dob is String) {
        _dateOfBirth = DateTime.tryParse(dob);
      }

      final categoryName = args['category'] as String?;
      if (categoryName != null) {
        _category = NatalChartCategory.values.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => NatalChartCategory.sunSign,
        );
      }

      _loadOrGenerateDetail();
    }
    _initialized = true;
  }

  Future<void> _loadOrGenerateDetail() async {
    if (_docId != null && _category != null) {
      final saved = await _storageService.getNatalChartById(_docId!);
      if (saved != null) {
        String? detail;
        switch (_category!) {
          case NatalChartCategory.sunSign:
            detail = saved.sunDetail;
            break;
          case NatalChartCategory.moonSign:
            detail = saved.moonDetail;
            break;
          case NatalChartCategory.risingSign:
            detail = saved.risingDetail;
            break;
        }
        if (detail != null) {
          setState(() {
            _detailContent = detail;
            _isLoading = false;
          });
          return;
        }
      }
    }
    _generateDetail();
  }

  String _formatBirthDate(DateTime? date) {
    if (date == null) return '';
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _generateDetail() async {
    if (_sign == null || _category == null) {
      setState(() {
        _isLoading = false;
        _detailContent = 'Unable to generate content. Missing data.';
      });
      return;
    }

    try {
      final language = _getLanguage();
      final detail = await _aiService.generateDetail(
        category: _category!,
        sign: _sign!,
        language: language,
        name: _name,
        birthDate: _formatBirthDate(_dateOfBirth),
        birthTime: _timeOfBirth,
        location: _location,
      );

      if (!mounted) return;

      setState(() {
        _detailContent = detail;
        _isLoading = false;
      });

      if (_docId != null) {
        switch (_category!) {
          case NatalChartCategory.sunSign:
            await _storageService.updateNatalChartContent(_docId!, sunDetail: detail);
            break;
          case NatalChartCategory.moonSign:
            await _storageService.updateNatalChartContent(_docId!, moonDetail: detail);
            break;
          case NatalChartCategory.risingSign:
            await _storageService.updateNatalChartContent(_docId!, risingDetail: detail);
            break;
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _detailContent = _getFallbackDetail();
      });
      debugPrint('Error generating detail: $e');
    }
  }

  String _getFallbackDetail() {
    final sign = _sign ?? 'Unknown';
    final nameStr = _name ?? 'you';

    switch (_category) {
      case NatalChartCategory.sunSign:
        return '''The Sun in $sign illuminates the very core of who $nameStr is.

This solar placement speaks to your fundamental identity, your ego, and your vital life force. The Sun represents your conscious mind.

With the Sun in $sign, there is a particular way of shining your light into the world. This placement influences your sense of purpose and willpower.

The creative expression associated with this solar position is unique and powerful.

As you continue your journey of self-discovery, embracing your $sign Sun will lead to greater authenticity.''';

      case NatalChartCategory.moonSign:
        return '''The Moon in $sign reveals the hidden emotional landscape within $nameStr's soul.

This lunar placement governs your instinctive reactions and emotional needs. The Moon represents your subconscious patterns.

With the Moon in $sign, your emotional responses have a distinct quality. This placement shapes how you seek comfort and security.

The nurturing style associated with this lunar position influences how you care for loved ones.

Understanding your lunar nature allows you to honor your emotional rhythms.''';

      case NatalChartCategory.risingSign:
        return '''The Rising Sign in $sign forms the first impression $nameStr makes upon the world.

This Ascendant placement represents the mask you wear in public and your physical appearance.

With $sign rising, there is a particular quality to your presence that people immediately notice.

The Rising Sign also governs your approach to beginnings - how you start projects and enter new situations.

Understanding your Ascendant helps you navigate social situations with greater awareness.''';

      default:
        return 'Detailed analysis is currently unavailable.';
    }
  }

  String _getLanguage() {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'ru': return 'Russian';
      case 'es': return 'Spanish';
      case 'fr': return 'French';
      case 'de': return 'German';
      default: return 'English';
    }
  }

  Color get _categoryColor {
    switch (_category) {
      case NatalChartCategory.sunSign: return Colors.orange;
      case NatalChartCategory.moonSign: return Colors.blueGrey;
      case NatalChartCategory.risingSign: return primaryColor;
      default: return primaryColor;
    }
  }

  IconData get _categoryIcon {
    switch (_category) {
      case NatalChartCategory.sunSign: return Icons.wb_sunny;
      case NatalChartCategory.moonSign: return Icons.nightlight_round;
      case NatalChartCategory.risingSign: return Icons.arrow_upward;
      default: return Icons.auto_awesome;
    }
  }

  String get _categoryTitle {
    switch (_category) {
      case NatalChartCategory.sunSign: return getTranslation(context, 'natal_chart_detail.title1');
      case NatalChartCategory.moonSign: return getTranslation(context, 'natal_chart_detail.title2');
      case NatalChartCategory.risingSign: return getTranslation(context, 'natal_chart_detail.title3');
      default: return 'Natal Chart';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: scaffoldBgColor,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: recBgColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, color: whiteColor),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_categoryColor.withValues(alpha: 0.3), scaffoldBgColor],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _categoryColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: _categoryColor.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2)],
                  ),
                  child: Icon(_categoryIcon, color: whiteColor, size: 32),
                ),
                const SizedBox(height: 16),
                Text(_categoryTitle, style: bold18White),
                const SizedBox(height: 4),
                Text(_sign ?? 'Unknown', style: TextStyle(color: _categoryColor, fontSize: 16, fontWeight: FontWeight.w600)),
                if (_name != null && _name!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(_name!, style: medium14Grey),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 2),
      decoration: const BoxDecoration(
        color: blueShade1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_teaser != null) ...[
            Container(
              padding: const EdgeInsets.all(fixPadding * 1.5),
              decoration: BoxDecoration(
                color: _categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _categoryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote, color: _categoryColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_teaser!, style: const TextStyle(color: greyColor, fontSize: 14, fontStyle: FontStyle.italic, height: 1.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_isLoading) _buildLoadingState() else _buildDetailContent(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildSatelliteAnimation(),
        const SizedBox(height: 24),
        const Text('Receiving cosmic wisdom', style: TextStyle(color: whiteColor, fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('via celestial satellites...', style: TextStyle(color: greyColor, fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 30),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 14,
              width: i == 3 ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(color: greyColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
            ),
          ),
      ],
    );
  }

  Widget _buildSatelliteAnimation() {
    return SizedBox(
      height: 180, width: 180,
      child: AnimatedBuilder(
        animation: Listenable.merge([_orbitController!, _pulseController!]),
        builder: (context, child) {
          final orbitValue = _orbitController!.value * 2 * pi;
          final pulseValue = 0.8 + (_pulseController!.value * 0.4);

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _categoryColor.withValues(alpha: 0.2), width: 1))),
              Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _categoryColor.withValues(alpha: 0.3), width: 1))),
              Container(width: 50 * pulseValue, height: 50 * pulseValue, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [_categoryColor.withValues(alpha: 0.6), _categoryColor.withValues(alpha: 0.1), Colors.transparent]))),
              Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: blueShade1, border: Border.all(color: _categoryColor, width: 2)), child: Icon(_categoryIcon, color: _categoryColor, size: 22)),
              Transform.translate(offset: Offset(70 * cos(orbitValue), 70 * sin(orbitValue)), child: _buildSatellite()),
              Transform.translate(offset: Offset(70 * cos(orbitValue + pi), 70 * sin(orbitValue + pi)), child: _buildSatellite()),
              Transform.translate(offset: Offset(45 * cos(-orbitValue * 1.5), 45 * sin(-orbitValue * 1.5)), child: _buildSatellite(small: true)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSatellite({bool small = false}) {
    final size = small ? 16.0 : 22.0;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: _categoryColor, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: _categoryColor.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1)]),
      child: Icon(Icons.satellite_alt, color: whiteColor, size: size * 0.7),
    );
  }

  Widget _buildDetailContent() {
    if (_detailContent == null) {
      return const Center(child: Text('Content unavailable', style: medium16Grey));
    }

    final paragraphs = _detailContent!.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(height: 4, width: 40, decoration: BoxDecoration(color: _categoryColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          const Text('Deep Analysis', style: bold18White),
        ]),
        const SizedBox(height: 20),
        ...paragraphs.asMap().entries.map((entry) {
          final index = entry.key;
          final paragraph = entry.value;
          final isFirst = index == 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: isFirst
                ? RichText(
                    text: TextSpan(children: [
                      TextSpan(text: paragraph.isNotEmpty ? paragraph[0] : '', style: TextStyle(color: _categoryColor, fontSize: 48, fontWeight: FontWeight.bold, height: 1)),
                      TextSpan(text: paragraph.length > 1 ? paragraph.substring(1) : '', style: const TextStyle(color: greyColor, fontSize: 15, height: 1.7)),
                    ]),
                  )
                : Text(paragraph, style: const TextStyle(color: greyColor, fontSize: 15, height: 1.7)),
          );
        }),
        const SizedBox(height: 20),
        Center(
          child: Column(children: [
            Icon(Icons.auto_awesome, color: _categoryColor.withValues(alpha: 0.5), size: 32),
            const SizedBox(height: 8),
            Text('May the stars illuminate your path', style: TextStyle(color: greyColor.withValues(alpha: 0.7), fontSize: 12, fontStyle: FontStyle.italic)),
          ]),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}



