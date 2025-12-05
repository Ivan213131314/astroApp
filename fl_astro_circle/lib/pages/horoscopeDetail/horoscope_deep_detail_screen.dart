import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

enum HoroscopeCategory {
  overall,
  love,
  business,
}

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

  String _getMockDetail() {
    final sign = _zodiacSign ?? 'Your Sign';
    final period = _timePeriod ?? 'today';

    switch (_category) {
      case HoroscopeCategory.overall:
        return '''The cosmic energies surrounding $sign $period are particularly powerful and transformative.

The planetary alignments create a unique opportunity for personal growth and self-discovery. You may find yourself drawn to new perspectives and ways of thinking that challenge your usual patterns.

This is an excellent time to trust your intuition and follow your inner guidance. The universe is conspiring in your favor, even if circumstances don't immediately appear that way.

Pay attention to synchronicities and meaningful coincidences that occur throughout your day. These are messages from the cosmos, guiding you toward your highest path.

Your natural strengths are amplified during this period, making it easier to accomplish tasks that usually require more effort. Use this energy wisely to make progress on important goals.

Challenges that arise are opportunities for growth rather than obstacles. Approach difficulties with curiosity and an open mind, knowing that each experience is teaching you something valuable.

The overall theme for $sign $period is transformation through awareness. Stay present, remain flexible, and trust in the journey.''';

      case HoroscopeCategory.love:
        return '''Matters of the heart take center stage for $sign $period, bringing both excitement and depth to your romantic life.

If you're in a relationship, this is a powerful time for deepening your connection and understanding your partner on a more profound level. Honest communication opens doors to greater intimacy.

Single individuals may find unexpected romantic opportunities presenting themselves. Be open to connections that don't fit your usual type—the universe may surprise you with someone special.

Venus and Mars create a harmonious dance in your chart, enhancing your natural charm and magnetism. You're radiating an attractive energy that others can't help but notice.

Past relationship patterns may come up for review and healing. This is your opportunity to release what no longer serves you and create space for healthier dynamics.

Self-love is equally important during this time. The relationship you have with yourself sets the tone for all other relationships in your life. Treat yourself with the kindness and respect you deserve.

For those exploring new relationships, take your time. True connection develops through shared experiences and genuine vulnerability, not rushed decisions.

The cosmic message for $sign $period in matters of love is to lead with your heart while keeping your wisdom engaged.''';

      case HoroscopeCategory.business:
        return '''Professional opportunities and career advancement are highlighted for $sign $period, bringing potential for significant progress.

Your creative problem-solving abilities are particularly sharp now. Innovative ideas flow easily, and you have the clarity to see solutions that others might miss.

This is an excellent time for networking and building professional relationships. Connections made during this period could prove valuable for years to come.

Financial matters require attention and careful planning. While opportunities for increase are present, they require strategic action rather than impulsive decisions.

Leadership qualities emerge naturally in your work environment. Others look to you for guidance and direction, even if you don't hold an official leadership position.

Projects that have been stalled or challenging may suddenly begin to move forward. Persistence pays off, and your consistent effort is about to show tangible results.

Be open to unexpected opportunities that don't fit your original plan. Sometimes the universe has better ideas than we do about our career path.

The key to success for $sign $period lies in balancing ambition with patience, and confidence with humility. Trust in your abilities while remaining open to learning.''';

      default:
        return 'Detailed cosmic insights are currently unavailable.';
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
    final detailContent = _getMockDetail();
    
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
