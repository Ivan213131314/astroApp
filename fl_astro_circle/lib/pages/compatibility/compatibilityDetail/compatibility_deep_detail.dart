import 'dart:math';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/services/ai_chat_service.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class CompatibilityDeepDetailScreen extends StatefulWidget {
  const CompatibilityDeepDetailScreen({super.key});

  @override
  State<CompatibilityDeepDetailScreen> createState() =>
      _CompatibilityDeepDetailScreenState();
}

class _CompatibilityDeepDetailScreenState
    extends State<CompatibilityDeepDetailScreen> with TickerProviderStateMixin {
  final AiChatService _aiService = AiChatService();
  final NotificationStorageService _storageService = NotificationStorageService();
  
  // Анимации для загрузки
  AnimationController? _orbitController;
  AnimationController? _pulseController;

  String? _docId;
  String? _sign1;
  String? _sign1Image;
  String? _sign2;
  String? _sign2Image;
  CompatibilityCategory? _category;
  String? _teaser;
  
  // Данные для персонализации
  String? _name1;
  String? _name2;
  String? _birthDate1;
  String? _birthDate2;

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
      _sign1 = args['sign1'];
      _sign1Image = args['sign1Image'];
      _sign2 = args['sign2'];
      _sign2Image = args['sign2Image'];
      _teaser = args['teaser'];
      
      // Данные для персонализации
      _name1 = args['person1Name'];
      _name2 = args['person2Name'];
      _birthDate1 = args['person1BirthDate'];
      _birthDate2 = args['person2BirthDate'];

      final categoryName = args['category'] as String?;
      if (categoryName != null) {
        _category = CompatibilityCategory.values.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => CompatibilityCategory.love,
        );
      }

      // Загружаем или генерируем детальный контент
      _loadOrGenerateDetail();
    }
    _initialized = true;
  }

  Future<void> _loadOrGenerateDetail() async {
    if (_docId != null && _category != null) {
      final saved = await _storageService.getCompatibilityById(_docId!);
      if (saved != null) {
        String? detail;
        switch (_category!) {
          case CompatibilityCategory.love:
            detail = saved.loveDetail;
            break;
          case CompatibilityCategory.business:
            detail = saved.businessDetail;
            break;
          case CompatibilityCategory.health:
            detail = saved.healthDetail;
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

  String? _formatBirthDateFromIso(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return null;
    try {
      final date = DateTime.parse(isoDate);
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return null;
    }
  }

  Future<void> _generateDetail() async {
    if (_sign1 == null || _sign2 == null || _category == null) {
      setState(() {
        _isLoading = false;
        _detailContent = 'Unable to generate content. Missing data.';
      });
      return;
    }

    try {
      final language = _getLanguage();
      final detail = await _aiService.generateCompatibilityDetail(
        sign1: _sign1!,
        sign2: _sign2!,
        category: _category!,
        language: language,
        name1: _name1,
        name2: _name2,
        birthDate1: _formatBirthDateFromIso(_birthDate1),
        birthDate2: _formatBirthDateFromIso(_birthDate2),
      );

      if (!mounted) return;

      setState(() {
        _detailContent = detail;
        _isLoading = false;
      });

      if (_docId != null) {
        switch (_category!) {
          case CompatibilityCategory.love:
            await _storageService.updateCompatibilityContent(_docId!, loveDetail: detail);
            break;
          case CompatibilityCategory.business:
            await _storageService.updateCompatibilityContent(_docId!, businessDetail: detail);
            break;
          case CompatibilityCategory.health:
            await _storageService.updateCompatibilityContent(_docId!, healthDetail: detail);
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
    final sign1 = _sign1 ?? 'Unknown';
    final sign2 = _sign2 ?? 'Unknown';
    
    switch (_category) {
      case CompatibilityCategory.love:
        return '''The romantic connection between $sign1 and $sign2 is a fascinating cosmic dance that deserves deep exploration.

When these two signs come together in love, they create a unique energy that can be both challenging and incredibly rewarding. The planetary alignments suggest a relationship filled with growth opportunities and passionate moments.

Venus, the planet of love, plays a crucial role in how these signs express affection. $sign1 approaches love with their characteristic traits, while $sign2 brings their own unique perspective to the relationship.

The emotional depth of this pairing cannot be understated. Both signs have the capacity for deep feelings, though they may express them differently. Understanding these differences is key to building a lasting bond.

Communication in love matters greatly for this pair. The way they share their hearts, discuss their dreams, and navigate conflicts will determine the strength of their union.

Physical chemistry between $sign1 and $sign2 often surprises both partners. The attraction can be magnetic, drawing them together in ways that transcend the ordinary.

Long-term potential exists when both partners commit to understanding and growing together. The stars suggest that with patience and love, this can be a transformative relationship.''';

      case CompatibilityCategory.business:
        return '''The professional partnership between $sign1 and $sign2 holds remarkable potential when properly understood and nurtured.

In the business realm, these two signs bring complementary skills that can create a powerhouse team. $sign1 contributes their natural strengths while $sign2 adds their unique capabilities to the mix.

Mercury, the planet of communication and commerce, influences how these signs collaborate. Their ability to exchange ideas, negotiate deals, and solve problems together is written in the stars.

Financial attitudes between $sign1 and $sign2 may differ, but this can be a strength rather than a weakness. One may be more conservative while the other takes calculated risks, creating balance.

Leadership dynamics in this pairing require attention. Understanding who leads in what situations, and how to share power effectively, will determine business success.

The work ethic of both signs complements each other when properly aligned. Their combined dedication can move mountains when they share a common vision.

Long-term business success is achievable when both parties respect each other's contributions and maintain clear communication channels.''';

      case CompatibilityCategory.health:
        return '''The wellness journey shared by $sign1 and $sign2 is influenced by celestial energies that affect both physical and emotional health.

When these signs come together, they can either support or challenge each other's wellbeing. Understanding these dynamics is essential for maintaining health and vitality.

The Moon, governing emotions and intuition, plays a significant role in how these signs affect each other's mental health. Emotional support flows between them in unique patterns.

Lifestyle compatibility between $sign1 and $sign2 touches every aspect of daily living. From sleep patterns to exercise preferences, the stars influence their rhythms.

Stress management is an area where these signs can truly help each other. One may offer calming energy while the other provides motivation to overcome challenges.

Physical activity preferences may differ, but finding common ground in wellness practices strengthens both the body and the bond between them.

The healing potential of this pairing is profound. When $sign1 and $sign2 commit to supporting each other's health, they create a nurturing environment for growth and vitality.''';

      default:
        return 'Detailed analysis is currently unavailable. Please try again later.';
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

  Color get _categoryColor {
    switch (_category) {
      case CompatibilityCategory.love:
        return redColor;
      case CompatibilityCategory.business:
        return greenColor;
      case CompatibilityCategory.health:
        return primaryColor;
      default:
        return primaryColor;
    }
  }

  IconData get _categoryIcon {
    switch (_category) {
      case CompatibilityCategory.love:
        return Icons.favorite;
      case CompatibilityCategory.business:
        return Icons.business_center;
      case CompatibilityCategory.health:
        return Icons.spa;
      default:
        return Icons.auto_awesome;
    }
  }

  String get _categoryTitle {
    switch (_category) {
      case CompatibilityCategory.love:
        return getTranslation(context, 'compatibility_detail.love_passion');
      case CompatibilityCategory.business:
        return getTranslation(context, 'compatibility_detail.business_career');
      case CompatibilityCategory.health:
        return getTranslation(context, 'compatibility_detail.health');
      default:
        return 'Compatibility';
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
                    _buildSignAvatar(_sign1Image ?? '', _sign1 ?? ''),
                    const SizedBox(width: 20),
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
                    const SizedBox(width: 20),
                    _buildSignAvatar(_sign2Image ?? '', _sign2 ?? ''),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _categoryTitle,
                  style: bold18White,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_sign1 ?? ''} & ${_sign2 ?? ''}',
                  style: medium14Grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignAvatar(String imagePath, String name) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _categoryColor, width: 2),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: blueShade1,
            child: imagePath.isNotEmpty
                ? Image.asset(imagePath, height: 40, width: 40)
                : Icon(_categoryIcon, color: _categoryColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: regualr14Grey),
      ],
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
          if (_isLoading)
            _buildLoadingState()
          else
            _buildDetailContent(),
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
        const Text(
          'Receiving information from the Universe',
          style: TextStyle(
            color: whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'via cosmic satellites...',
          style: TextStyle(
            color: greyColor,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        for (int i = 0; i < 4; i++)
          Padding(
            key: ValueKey('shimmer_$i'),
            padding: const EdgeInsets.only(bottom: 12),
            child: _shimmerLine(
              width: i == 3 ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.8,
            ),
          ),
      ],
    );
  }

  Widget _buildSatelliteAnimation() {
    return SizedBox(
      height: 180,
      width: 180,
      child: AnimatedBuilder(
        animation: Listenable.merge([_orbitController!, _pulseController!]),
        builder: (context, child) {
          final orbitValue = _orbitController!.value * 2 * pi;
          final pulseValue = 0.8 + (_pulseController!.value * 0.4);
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Внешняя орбита
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _categoryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              // Внутренняя орбита
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _categoryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              // Центральное свечение (Земля)
              Container(
                width: 50 * pulseValue,
                height: 50 * pulseValue,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _categoryColor.withValues(alpha: 0.6),
                      _categoryColor.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Центральная иконка
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: blueShade1,
                  border: Border.all(color: _categoryColor, width: 2),
                ),
                child: Icon(
                  Icons.public,
                  color: _categoryColor,
                  size: 22,
                ),
              ),
              // Спутник 1
              Transform.translate(
                offset: Offset(
                  70 * cos(orbitValue),
                  70 * sin(orbitValue),
                ),
                child: _buildSatellite(),
              ),
              // Спутник 2 (противоположный)
              Transform.translate(
                offset: Offset(
                  70 * cos(orbitValue + pi),
                  70 * sin(orbitValue + pi),
                ),
                child: _buildSatellite(),
              ),
              // Спутник 3 (на внутренней орбите)
              Transform.translate(
                offset: Offset(
                  45 * cos(-orbitValue * 1.5),
                  45 * sin(-orbitValue * 1.5),
                ),
                child: _buildSatellite(small: true),
              ),
              // Сигнальные волны
              for (int index = 0; index < 3; index++)
                Builder(
                  key: ValueKey('wave_$index'),
                  builder: (context) {
                    final delay = index * 0.3;
                    final waveProgress = ((_orbitController!.value + delay) % 1.0);
                    return Container(
                      width: 50 + (waveProgress * 60),
                      height: 50 + (waveProgress * 60),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _categoryColor.withValues(alpha: (1 - waveProgress) * 0.4),
                          width: 1,
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSatellite({bool small = false}) {
    final size = small ? 16.0 : 22.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _categoryColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: _categoryColor.withValues(alpha: 0.6),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.satellite_alt,
        color: whiteColor,
        size: size * 0.7,
      ),
    );
  }

  Widget _shimmerLine({required double width}) {
    return Container(
      height: 14,
      width: width,
      decoration: BoxDecoration(
        color: greyColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildDetailContent() {
    if (_detailContent == null) {
      return const Center(
        child: Text(
          'Content unavailable',
          style: medium16Grey,
        ),
      );
    }

    final paragraphs = _detailContent!
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

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
