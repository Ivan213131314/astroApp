import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class UniverseDecipherScreen extends StatelessWidget {
  final String question;

  const UniverseDecipherScreen({
    super.key,
    required this.question,
  });

  // Mock данные для расшифровки
  static const List<Map<String, String>> mockDeciphers = [
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

  String _getMockDecipher() {
    final index = question.hashCode.abs() % mockDeciphers.length;
    return mockDeciphers[index]['message']!;
  }

  String _getTitle() {
    final index = question.hashCode.abs() % mockDeciphers.length;
    return mockDeciphers[index]['title']!;
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
      body: SingleChildScrollView(
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
                    const Row(
                      children: [
                        Icon(
                          Icons.question_answer_outlined,
                          color: primaryColor,
                          size: 18,
                        ),
                        widthSpace,
                        Text(
                          'Your Question',
                          style: medium14Grey,
                        ),
                      ],
                    ),
                    heightSpace,
                    Text(
                      question,
                      style: medium16WhiteF4,
                    ),
                  ],
                ),
              ),

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
                      _getMockDecipher(),
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
      ),
    );
  }
}









