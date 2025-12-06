import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_astro_circle/models/horoscope_data.dart';

class HoroscopeDeepDetailScreen extends StatefulWidget {
  const HoroscopeDeepDetailScreen({super.key});

  @override
  State<HoroscopeDeepDetailScreen> createState() =>
      _HoroscopeDeepDetailScreenState();
}

class _HoroscopeDeepDetailScreenState extends State<HoroscopeDeepDetailScreen> {
  String? _zodiacSign;
  String? _timePeriod;
  HoroscopeCategory? _category;
  String? _teaser;
  HoroscopeData? _horoscopeData;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _zodiacSign = args['zodiacSign'] as String?;
      _timePeriod = args['timePeriod'] as String?;
      _teaser = args['teaser'] as String?;
      _horoscopeData = args['horoscopeData'] as HoroscopeData?;

      final categoryName = args['category'] as String?;
      if (categoryName != null) {
        _category = HoroscopeCategory.values.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => HoroscopeCategory.overall,
        );
      }
    }
    _initialized = true;
  }

  String _getDeepDetail() {
    // Check if we have the necessary data
    if (_horoscopeData == null || _category == null) {
      return 'Детальный анализ временно недоступен. Попробуйте позже.';
    }

    try {
      // Get the category-specific data from HoroscopeData
      final categoryData = _horoscopeData!.getCategoryData(_category!);
      
      // Return deepText if available, otherwise fall back to regular text
      if (categoryData.deepText.isNotEmpty) {
        return categoryData.deepText;
      } else if (categoryData.text.isNotEmpty) {
        return categoryData.text;
      } else {
        return 'Детальный анализ временно недоступен. Попробуйте позже.';
      }
    } catch (e) {
      return 'Произошла ошибка при загрузке детального анализа.';
    }
  }

  Color get _categoryColor {
    switch (_category) {
      case HoroscopeCategory.overall:
        return primaryColor;
      case HoroscopeCategory.love:
        return redColor;
      case HoroscopeCategory.business:
        return greenColor;
      default:
        return primaryColor;
    }
  }

  IconData get _categoryIcon {
    switch (_category) {
      case HoroscopeCategory.overall:
        return Icons.auto_awesome;
      case HoroscopeCategory.love:
        return Icons.favorite;
      case HoroscopeCategory.business:
        return Icons.business_center;
      default:
        return Icons.star;
    }
  }

  String get _categoryTitle {
    switch (_category) {
      case HoroscopeCategory.overall:
        return getTranslation(context, 'horoscope_detail.overall_horoscope');
      case HoroscopeCategory.love:
        return getTranslation(context, 'horoscope_detail.love_passion');
      case HoroscopeCategory.business:
        return getTranslation(context, 'horoscope_detail.business_career');
      default:
        return 'Horoscope';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
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
              colors: [
                _categoryColor.withValues(alpha: 0.3),
                scaffoldBgColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _categoryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _categoryColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(_categoryIcon, color: whiteColor, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _categoryTitle,
                  style: bold18White,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_zodiacSign ?? ''} - ${_timePeriod ?? ''}',
                  style: medium14Grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final detailContent = _getDeepDetail();
    
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
                border: Border.all(
                  color: _categoryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    color: _categoryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _teaser!,
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          _buildDetailContent(detailContent),
        ],
      ),
    );
  }

  Widget _buildDetailContent(String content) {
    var paragraphs = content
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) {
      paragraphs = content
          .split('\n')
          .where((p) => p.trim().isNotEmpty)
          .toList();
    }

    if (paragraphs.isEmpty && content.trim().isNotEmpty) {
      paragraphs = [content.trim()];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: _categoryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Deep Analysis',
              style: bold18White,
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...paragraphs.asMap().entries.map((entry) {
          final index = entry.key;
          final paragraph = entry.value;
          final isFirst = index == 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirst)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: paragraph.isNotEmpty ? paragraph[0] : '',
                          style: TextStyle(
                            color: _categoryColor,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: paragraph.length > 1 ? paragraph.substring(1) : '',
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 15,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    paragraph,
                    style: const TextStyle(
                      color: greyColor,
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.auto_awesome,
                color: _categoryColor.withValues(alpha: 0.5),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'May the stars guide your path',
                style: TextStyle(
                  color: greyColor.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
