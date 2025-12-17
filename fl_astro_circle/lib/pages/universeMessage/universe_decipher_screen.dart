import 'package:fl_astro_circle/services/ai_chat_service.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class UniverseDecipherScreen extends StatefulWidget {
  final String question;
  final String? category;

  const UniverseDecipherScreen({
    super.key,
    required this.question,
    this.category,
  });

  @override
  State<UniverseDecipherScreen> createState() => _UniverseDecipherScreenState();
}

class _UniverseDecipherScreenState extends State<UniverseDecipherScreen> {
  final AiChatService _aiService = AiChatService();
  
  bool _isLoading = true;
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
    _loadAiResponse();
  }

  Future<void> _loadAiResponse() async {
    try {
      final response = await _aiService.generateUniverseSign(
        question: widget.question,
        category: widget.category ?? 'path',
      );
      
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

  String _getTitle() {
    if (_aiResponse != null) {
      return 'Message from the Stars';
    }
    final index = widget.question.hashCode.abs() % _fallbackMessages.length;
    return _fallbackMessages[index]['title']!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
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
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated cosmic icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.5),
                        const Color(0xFF7B5CFA).withValues(alpha: 0.5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: whiteColor,
                    size: 50,
                  ),
                ),
              );
            },
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
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final message = _aiResponse ?? _getFallbackMessage();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(fixPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Вопрос пользователя
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(fixPadding * 1.5),
              decoration: BoxDecoration(
                color: blueShade1.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.question_answer_outlined,
                        color: primaryColor,
                        size: 18,
                      ),
                      widthSpace,
                      const Text(
                        'Your Question',
                        style: medium14Grey,
                      ),
                      const Spacer(),
                      Text(
                        _getCategoryEmoji(),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  heightSpace,
                  Text(
                    widget.question,
                    style: medium16WhiteF4,
                  ),
                ],
              ),
            ),

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

            // Заголовок расшифровки
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2,
                  vertical: fixPadding,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.3),
                      const Color(0xFF7B5CFA).withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFFD700),
                      size: 20,
                    ),
                    widthSpace,
                    Text(
                      _getTitle(),
                      style: bold16WhiteF4,
                    ),
                    widthSpace,
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFFD700),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            heightSpace,
            heightSpace,

            // Основное сообщение
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(fixPadding * 2),
              decoration: BoxDecoration(
                color: blueShade1,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Декоративная иконка сверху
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.5),
                          const Color(0xFF7B5CFA).withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: whiteColor,
                      size: 40,
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

            // Кнопка "Share"
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share feature coming soon!'),
                    backgroundColor: primaryColor,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: fixPadding * 1.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, Color(0xFF7B5CFA)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, color: whiteColor),
                    widthSpace,
                    Text(
                      'Share Your Cosmic Message',
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
