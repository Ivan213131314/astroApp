import 'package:fl_astro_circle/services/ai_chat_service.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:fl_astro_circle/services/universe_cache_service.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UniverseDecipherScreen extends StatefulWidget {
  final String question;
  final String? category;
  final String? messageId;

  const UniverseDecipherScreen({
    super.key,
    required this.question,
    this.category,
    this.messageId,
  });

  @override
  State<UniverseDecipherScreen> createState() => _UniverseDecipherScreenState();
}

class _UniverseDecipherScreenState extends State<UniverseDecipherScreen>
    with TickerProviderStateMixin {
  final AiChatService _aiService = AiChatService();
  final UniverseCacheService _cacheService = UniverseCacheService();
  final NotificationStorageService _storageService = NotificationStorageService();
  
  late AnimationController _pulseController;
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;
  
  bool _isLoading = true;
  bool _signCarried = false;
  bool _showFlash = false;
  String? _aiResponse;
  String? _error;

  // Fallback mock данные
  static const List<Map<String, String>> _fallbackMessages = [
    {
      'title': 'The Cosmic Answer',
      'message': '''The universe has listened to your question and sends this message:

Your path is illuminated by the stars of destiny. What you seek is already on its way to you. The alignment of celestial bodies suggests a turning point approaching within the next lunar cycle.

Trust in the cosmic flow. The energy you have been sending into the universe is returning to you threefold. Pay attention to signs that appear during twilight hours — they carry important guidance.

Remember: the universe speaks in whispers to those who listen. Your question has created ripples in the cosmic fabric, and the answer is manifesting in your reality as we speak.

🌟 Cosmic Alignment: 87%
🔮 Energy Resonance: High
⭐ Fortune Index: Ascending'''
    },
    {
      'title': 'Message from the Stars',
      'message': '''The celestial frequencies have decoded your inquiry:

A significant transformation awaits you. The planetary alignment indicates that the answer to your question lies not in the destination, but in the journey itself.

The cosmos reveals that patience will be your greatest ally. What appears as delay is actually cosmic preparation for something greater than you imagined.

Three signs will confirm this message:
1. A recurring number sequence
2. An unexpected encounter
3. A dream that feels like memory

Trust the timing of the universe. Everything is unfolding exactly as it should.

🌙 Lunar Influence: Strong
✨ Destiny Probability: 94%
🌌 Cosmic Blessing: Active'''
    },
    {
      'title': 'Universal Wisdom Revealed',
      'message': '''The vast expanse of space carries your answer:

Your soul's vibration has reached the cosmic consciousness. The response echoes through dimensions: YES, but not in the way you expect.

The universe is rearranging circumstances in your favor. A door that seemed closed is about to reveal a hidden path. Someone connected to your question will cross your path within 11 days.

The stars advise:
• Release attachment to specific outcomes
• Embrace the unexpected with open arms
• Your intuition is stronger than you realize

The cosmic energy surrounding your question is exceptionally positive. The universe celebrates your courage to ask.

🪐 Planetary Support: Maximum
💫 Manifestation Power: 91%
🌠 Cosmic Confirmation: Received'''
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _flashAnimation = CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    );
    _flashController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _saveSignCarriedState();
        setState(() {
          _showFlash = false;
          _signCarried = true;
        });
      }
    });
    
    _loadSignCarriedState();
    _loadAiResponse();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  /// Генерирует ключ для сегодняшнего дня (сбрасывается завтра)
  String _getSignCarriedKey() {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final messageKey = widget.messageId ?? widget.question.hashCode.toString();
    return 'sign_carried_${dateKey}_$messageKey';
  }

  /// Загрузка состояния из SharedPreferences
  Future<void> _loadSignCarriedState() async {
    final prefs = await SharedPreferences.getInstance();
    final carried = prefs.getBool(_getSignCarriedKey()) ?? false;
    if (mounted && carried) {
      setState(() {
        _signCarried = true;
      });
    }
  }

  /// Сохранение состояния в SharedPreferences
  Future<void> _saveSignCarriedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getSignCarriedKey(), true);
  }

  Future<void> _loadAiResponse() async {
    // Try to load cached result first
    if (widget.messageId != null) {
      // 1. Check SharedPreferences cache (fastest)
      final cachedResult = await _cacheService.getCachedResult(widget.messageId!);
      if (cachedResult != null) {
        if (mounted) {
          setState(() {
            _aiResponse = cachedResult;
            _isLoading = false;
          });
        }
        return;
      }
      
      // 2. Check Firebase for saved result
      final messageData = await _storageService.getUniverseMessageById(widget.messageId!);
      if (messageData?.decipherResult != null) {
        // Cache it locally for next time
        await _cacheService.cacheResult(widget.messageId!, messageData!.decipherResult!);
        if (mounted) {
          setState(() {
            _aiResponse = messageData.decipherResult;
            _isLoading = false;
          });
        }
        return;
      }
    }
    
    // 3. Generate new AI response
    try {
      final response = await _aiService.generateUniverseSign(
        question: widget.question,
        category: widget.category ?? 'path',
      );
      
      // Save to cache and Firebase if we have messageId
      if (widget.messageId != null && response != null) {
        await _cacheService.cacheResult(widget.messageId!, response);
        await _storageService.updateUniverseMessageDecipherResult(widget.messageId!, response);
      }
      
      if (mounted) {
        setState(() {
          _aiResponse = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to mock data on error
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getFallbackMessage() {
    final index = widget.question.hashCode.abs() % _fallbackMessages.length;
    return _fallbackMessages[index]['message']!;
  }

  String _getCategoryName() {
    switch (widget.category) {
      case 'love':
        return 'Love';
      case 'money':
        return 'Money';
      case 'path':
        return 'Life Path';
      case 'decision':
        return 'Decision';
      default:
        return 'You';
    }
  }

  String _getTitle() {
    return 'Your insight about ${_getCategoryName()} was decoded';
  }

  String _getCategoryEmoji() {
    switch (widget.category) {
      case 'love':
        return '❤️';
      case 'money':
        return '💰';
      case 'path':
        return '🌿';
      case 'decision':
        return '🔮';
      default:
        return '✨';
    }
  }

  Color _getCategoryColor() {
    switch (widget.category) {
      case 'love':
        return const Color(0xFFFF6B6B);
      case 'money':
        return const Color(0xFFFFD700);
      case 'path':
        return const Color(0xFF4ECB71);
      case 'decision':
        return const Color(0xFF9B59B6);
      default:
        return primaryColor;
    }
  }

  Color _getCategorySecondaryColor() {
    switch (widget.category) {
      case 'love':
        return const Color(0xFFFF4757);
      case 'money':
        return const Color(0xFFFFA500);
      case 'path':
        return const Color(0xFF2ECC71);
      case 'decision':
        return const Color(0xFF8E44AD);
      default:
        return const Color(0xFF7B5CFA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: whiteF4Color),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Universe Decipher',
          style: bold20White,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  categoryColor.withValues(alpha: 0.4),
                  categoryColor.withValues(alpha: 0.15),
                  scaffoldBgColor,
                  scaffoldBgColor,
                ],
                stops: const [0.0, 0.2, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: _isLoading ? _buildLoadingState() : _buildContent(),
            ),
          ),
          // Flash overlay animation
          if (_showFlash)
            AnimatedBuilder(
              animation: _flashAnimation,
              builder: (context, child) {
                return Container(
                  color: Colors.white.withValues(alpha: (1.0 - _flashAnimation.value) * 0.9),
                  child: Center(
                    child: Transform.scale(
                      scale: 1.0 + (_flashAnimation.value * 2.0),
                      child: Opacity(
                        opacity: 1.0 - _flashAnimation.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                categoryColor.withValues(alpha: 0.8),
                                categoryColor.withValues(alpha: 0.0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: categoryColor.withValues(alpha: 0.6),
                                blurRadius: 60,
                                spreadRadius: 30,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getCategoryEmoji(),
                              style: const TextStyle(fontSize: 60),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final categoryColor = _getCategoryColor();
    final secondaryColor = _getCategorySecondaryColor();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated cosmic icon with category color - wrapped in fixed size to prevent text jumping
          SizedBox(
            height: 120,
            width: 120,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulseValue = 0.8 + (_pulseController.value * 0.4);
                  return Container(
                    height: 100 * pulseValue,
                    width: 100 * pulseValue,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          categoryColor.withValues(alpha: 0.5),
                          secondaryColor.withValues(alpha: 0.5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withValues(alpha: 0.3 + (_pulseController.value * 0.3)),
                          blurRadius: 20 + (_pulseController.value * 10),
                          spreadRadius: 5 + (_pulseController.value * 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getCategoryEmoji(),
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Decoding cosmic message...',
            style: TextStyle(
              color: whiteColor.withValues(alpha: 0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'The Universe is responding ${_getCategoryEmoji()}',
            style: TextStyle(
              color: whiteColor.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: whiteColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final message = _aiResponse ?? _getFallbackMessage();
    final categoryColor = _getCategoryColor();
    final secondaryColor = _getCategorySecondaryColor();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(fixPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error notification (if any)
            if (_error != null) ...[
              heightSpace,
              Container(
                padding: const EdgeInsets.all(fixPadding),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                    widthSpace,
                    Expanded(
                      child: Text(
                        'Showing cosmic wisdom from our archives',
                        style: TextStyle(
                          color: Colors.orange.shade200,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            heightSpace,
            heightSpace,
            heightSpace,

            // Заголовок расшифровки с цветом категории
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2,
                  vertical: fixPadding,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withValues(alpha: 0.3),
                      secondaryColor.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  _getTitle(),
                  style: bold16WhiteF4,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            heightSpace,
            heightSpace,

            // Основное сообщение с цветом категории
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(fixPadding * 2),
              decoration: BoxDecoration(
                color: blueShade1,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Пульсирующая иконка с эмодзи категории
                  SizedBox(
                    height: 96,
                    width: 96,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final pulseValue = 0.9 + (_pulseController.value * 0.15);
                          return Transform.scale(
                            scale: pulseValue,
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    categoryColor.withValues(alpha: 0.5),
                                    secondaryColor.withValues(alpha: 0.5),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: categoryColor.withValues(alpha: 0.3 + (_pulseController.value * 0.2)),
                                    blurRadius: 15 + (_pulseController.value * 5),
                                    spreadRadius: 2 + (_pulseController.value * 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _getCategoryEmoji(),
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  heightSpace,
                  heightSpace,

                  // Текст расшифровки
                  Text(
                    message,
                    style: regualr16WhiteF4,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),

            heightSpace,
            heightSpace,
            heightSpace,

            // Кнопка "Carry this sign today" / "This sign is now with you"
            if (_signCarried)
              // Текст после нажатия
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: fixPadding * 2,
                  horizontal: fixPadding * 2,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '✨',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This sign is now with you.',
                      style: TextStyle(
                        color: whiteColor.withValues(alpha: 0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Return tomorrow',
                      style: TextStyle(
                        color: categoryColor.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              // Кнопка Carry this sign today
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showFlash = true;
                  });
                  _flashController.forward(from: 0.0);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: fixPadding * 1.5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [categoryColor, secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: whiteColor),
                      widthSpace,
                      const Text(
                        'Carry this sign today',
                        style: bold16WhiteF4,
                      ),
                    ],
                  ),
                ),
              ),

            heightSpace,
            heightSpace,
          ],
        ),
      ),
    );
  }
}

