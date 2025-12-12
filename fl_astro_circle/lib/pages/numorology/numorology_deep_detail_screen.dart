import 'dart:math';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:flutter/material.dart';
import 'numorology_service.dart';

class NumerologyDeepDetailScreen extends StatefulWidget {
  const NumerologyDeepDetailScreen({super.key});

  @override
  State<NumerologyDeepDetailScreen> createState() =>
      _NumerologyDeepDetailScreenState();
}

class _NumerologyDeepDetailScreenState extends State<NumerologyDeepDetailScreen>
    with TickerProviderStateMixin {
  final NumerologyService _service = NumerologyService();
  final NotificationStorageService _storageService = NotificationStorageService();

  AnimationController? _orbitController;
  AnimationController? _pulseController;

  String? _docId;
  int? _luckyNumber;
  String? _birthDate;
  NumerologyCategory? _category;
  String? _teaser;

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
      _docId = args['docId'] as String?;
      _luckyNumber = args['luckyNumber'] as int?;
      _birthDate = args['birthDate'] as String?;
      _teaser = args['teaser'] as String?;

      final categoryName = args['category'] as String?;
      if (categoryName != null) {
        _category = NumerologyCategory.values.firstWhere(
          (c) => c.name == categoryName,
          orElse: () => NumerologyCategory.character,
        );
      }

      _loadOrGenerateDetail();
    }
    _initialized = true;
  }

  Future<void> _loadOrGenerateDetail() async {
    // Сначала пробуем загрузить из Firebase
    if (_docId != null && _category != null) {
      final saved = await _storageService.getNumerologyById(_docId!);
      if (saved != null) {
        String? detail;
        switch (_category!) {
          case NumerologyCategory.character:
            detail = saved.characterDetail;
            break;
          case NumerologyCategory.behavior:
            detail = saved.behaviorDetail;
            break;
          case NumerologyCategory.responsibility:
            detail = saved.responsibilityDetail;
            break;
        }
        if (detail != null && detail.isNotEmpty) {
          setState(() {
            _detailContent = detail;
            _isLoading = false;
          });
          return;
        }
      }
    }
    
    // Если нет сохраненного - генерируем
    _generateDetail();
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

  Future<void> _generateDetail() async {
    if (_luckyNumber == null || _birthDate == null || _category == null) {
      setState(() {
        _isLoading = false;
        _detailContent = 'Unable to generate content. Missing data.';
      });
      return;
    }

    try {
      final language = _getLanguage();
      final detail = await _service.generateNumerologyDetail(
        luckyNumber: _luckyNumber!,
        birthDate: _birthDate!,
        category: _category!,
        language: language,
      );

      if (!mounted) return;

      setState(() {
        _detailContent = detail;
        _isLoading = false;
      });

      // Сохраняем в Firebase
      if (_docId != null) {
        try {
          switch (_category!) {
            case NumerologyCategory.character:
              await _storageService.updateNumerologyContent(_docId!, characterDetail: detail);
              break;
            case NumerologyCategory.behavior:
              await _storageService.updateNumerologyContent(_docId!, behaviorDetail: detail);
              break;
            case NumerologyCategory.responsibility:
              await _storageService.updateNumerologyContent(_docId!, responsibilityDetail: detail);
              break;
          }
        } catch (e) {
          debugPrint('Error saving detail to Firebase: $e');
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
    final number = _luckyNumber ?? 1;

    switch (_category) {
      case NumerologyCategory.character:
        return '''People with Life Path Number $number possess a unique set of character traits that define their journey through life.

Their core personality is marked by distinctive qualities that set them apart. These individuals carry an energy that resonates with the vibration of number $number, influencing how they perceive and interact with the world around them.

Inner strength comes naturally to those born under this number. They have an innate ability to tap into their personal power and use it to overcome obstacles. This strength is not always visible on the surface but reveals itself during challenging times.

Emotionally, Life Path $number individuals experience life with a particular intensity. Their feelings run deep, and they have a unique way of processing and expressing their emotions that can both inspire and surprise others.

The shadow aspects of this number include tendencies that require awareness and growth. Recognizing these patterns allows for personal development and the transformation of weaknesses into strengths.

Natural talents flow abundantly for those walking this path. Creative abilities, intellectual gifts, or spiritual insights may come effortlessly, waiting to be developed and shared with the world.

Others perceive Life Path $number individuals in distinctive ways. Their presence carries a certain magnetism that draws people in, creating opportunities for meaningful connections and influence.''';

      case NumerologyCategory.behavior:
        return '''The behavioral patterns of Life Path $number reveal much about how these individuals navigate their daily lives.

Daily routines and habits are shaped by the energy of this number. There is a natural rhythm to how they approach their days, with certain activities and patterns feeling more aligned than others.

Communication style for number $number is distinct and recognizable. The way they express ideas, share feelings, and engage in dialogue reflects the deeper vibration of their life path.

Decision-making follows specific patterns influenced by this numerological energy. Some choices come easily while others require more deliberation, all guided by the inherent wisdom of their number.

When faced with stress and challenges, Life Path $number individuals have characteristic responses. Understanding these patterns helps in developing healthier coping mechanisms and building resilience.

Relationships are navigated with particular tendencies. The attachment style and way of connecting with others carries the imprint of this powerful number, affecting all forms of partnership.

Professional behavior and work habits align with the qualities of number $number. Career success often comes through embracing these natural tendencies rather than fighting against them.

Change and uncertainty are met with responses typical of this life path. Learning to work with these natural inclinations leads to greater adaptability and growth.''';

      case NumerologyCategory.responsibility:
        return '''The sacred mission of Life Path $number carries profound significance for both the individual and the world.

This number brings with it specific karmic lessons that must be learned and integrated. These lessons are not burdens but opportunities for soul growth and evolution.

Fulfilling your highest potential as a $number requires conscious awareness and dedicated effort. The universe has placed particular opportunities along your path to help you achieve this destiny.

Responsibilities to yourself come first. Self-care, personal growth, and honoring your own needs create the foundation from which you can serve others effectively.

Responsibilities to others flow naturally from your number. There are specific ways in which you are called to contribute to the lives of those around you and to society as a whole.

The legacy you are meant to leave carries the imprint of number $number. Your contributions to the world, whether large or small, align with this higher purpose.

Spiritual growth opportunities abound for those walking this path. The universe continuously presents chances for deeper understanding and expanded consciousness.

Aligning your actions with your life purpose brings fulfillment and meaning. When you live in harmony with the energy of your number, life flows more smoothly and purposefully.

The greater good you serve through your life path benefits not only yourself but ripples outward to touch countless others in ways both seen and unseen.''';

      default:
        return 'Detailed analysis is currently unavailable. Please try again later.';
    }
  }

  Color get _categoryColor {
    switch (_category) {
      case NumerologyCategory.character:
        return const Color(0xFF77CCF0);
      case NumerologyCategory.behavior:
        return const Color(0xFFE46BEE);
      case NumerologyCategory.responsibility:
        return const Color(0xFFDFCF3E);
      default:
        return primaryColor;
    }
  }

  IconData get _categoryIcon {
    switch (_category) {
      case NumerologyCategory.character:
        return Icons.psychology;
      case NumerologyCategory.behavior:
        return Icons.emoji_people;
      case NumerologyCategory.responsibility:
        return Icons.auto_awesome;
      default:
        return Icons.star;
    }
  }

  String get _categoryTitle {
    switch (_category) {
      case NumerologyCategory.character:
        return getTranslation(context, 'numorology_detail.about_character');
      case NumerologyCategory.behavior:
        return getTranslation(context, 'numorology_detail.about_behavior');
      case NumerologyCategory.responsibility:
        return getTranslation(context, 'numorology_detail.responsible');
      default:
        return 'Numerology';
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
                    _buildNumberWidget(),
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
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _categoryTitle,
                  style: bold18White,
                ),
                const SizedBox(height: 4),
                Text(
                  'Life Path Number ${_luckyNumber ?? ''}',
                  style: medium14Grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberWidget() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: _categoryColor.withValues(alpha: 0.5),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: primaryColor,
        ),
        alignment: Alignment.center,
        child: Text(
          '${_luckyNumber ?? ''}',
          style: const TextStyle(
            color: whiteColor,
            fontSize: 36,
            fontWeight: FontWeight.bold,
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
        const Text(
          'Receiving cosmic insights...',
          style: TextStyle(
            color: whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'via numerological channels...',
          style: TextStyle(
            color: greyColor,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _shimmerLine(
              width: i == 3
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.8,
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
              // Outer orbit
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
              // Inner orbit
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
              // Center glow
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
              // Center number
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: _categoryColor.withValues(alpha: 0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: primaryColor,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${_luckyNumber ?? ''}',
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Satellite 1
              Transform.translate(
                offset: Offset(
                  70 * cos(orbitValue),
                  70 * sin(orbitValue),
                ),
                child: _buildSatellite(),
              ),
              // Satellite 2
              Transform.translate(
                offset: Offset(
                  70 * cos(orbitValue + pi),
                  70 * sin(orbitValue + pi),
                ),
                child: _buildSatellite(),
              ),
              // Signal waves
              for (int index = 0; index < 3; index++)
                Builder(
                  builder: (context) {
                    final delay = index * 0.3;
                    final waveProgress =
                        ((_orbitController!.value + delay) % 1.0);
                    return Container(
                      width: 50 + (waveProgress * 60),
                      height: 50 + (waveProgress * 60),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _categoryColor
                              .withValues(alpha: (1 - waveProgress) * 0.4),
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

  Widget _buildSatellite() {
    return Container(
      width: 22,
      height: 22,
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
      child: const Icon(
        Icons.satellite_alt,
        color: whiteColor,
        size: 14,
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
    if (_detailContent == null || _detailContent!.trim().isEmpty) {
      return const Center(
        child: Text(
          'Content unavailable',
          style: medium16Grey,
        ),
      );
    }

    // Try splitting by double newlines first, then single newlines
    var paragraphs = _detailContent!
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();
    
    // If no paragraphs found with double newlines, try single newlines
    if (paragraphs.isEmpty) {
      paragraphs = _detailContent!
          .split('\n')
          .where((p) => p.trim().isNotEmpty)
          .toList();
    }
    
    // If still empty, treat entire content as one paragraph
    if (paragraphs.isEmpty && _detailContent!.trim().isNotEmpty) {
      paragraphs = [_detailContent!.trim()];
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
                          text:
                              paragraph.length > 1 ? paragraph.substring(1) : '',
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
                'May the numbers guide your path',
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







