import 'package:fl_astro_circle/pages/screens.dart';
import 'package:fl_astro_circle/pages/universeSign/universe_sign_player_screen.dart';
import 'package:fl_astro_circle/services/universe_sign_service.dart';
import 'package:fl_astro_circle/services/superwall_service.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

/// Model for sign categories
class SignCategory {
  final String id;
  final String emoji;
  final String name;
  final List<String> questions;
  final List<Color> gradientColors;
  final Color glowColor;

  const SignCategory({
    required this.id,
    required this.emoji,
    required this.name,
    required this.questions,
    required this.gradientColors,
    required this.glowColor,
  });
}

class UniverseSignScreen extends StatefulWidget {
  const UniverseSignScreen({super.key});

  @override
  State<UniverseSignScreen> createState() => _UniverseSignScreenState();
}

class _UniverseSignScreenState extends State<UniverseSignScreen>
    with SingleTickerProviderStateMixin {
  final UniverseSignService signService = UniverseSignService();
  
  late AnimationController _animationController;
  SignStatus currentStatus = SignStatus.idle;
  bool showReceivedDialog = false;
  String? currentQuestionForDialog;
  String? currentCategoryForDialog;
  String? selectedQuestion;
  String? selectedCategoryId;
  String? _dialogDismissedMessageId; // ID сообщения, для которого диалог был закрыт

  /// Category definitions with questions
  final List<SignCategory> categories = const [
    SignCategory(
      id: 'love',
      emoji: '❤️',
      name: 'LOVE',
      questions: [
        "Give me a sign about love today",
        "Help me understand my feelings today",
        "Show me if I should take a step today",
        "Let me notice something important about relationships today",
        "Help me see love more clearly today",
        "Show me what I shouldn't ignore in my love life today",
        "Help me understand what my heart needs today",
        "Give me a sign about emotional connection today",
        "Let me notice how others treat me today",
        "Show me what matters most in love today",
      ],
      gradientColors: [Color(0xFFFF6B6B), Color(0xFFFF4757)],
      glowColor: Color(0xFFFF6B6B),
    ),
    SignCategory(
      id: 'money',
      emoji: '💰',
      name: 'MONEY',
      questions: [
        "Give me a sign about money today",
        "Show me where my opportunity is today",
        "Help me understand my financial direction today",
        "Let me notice something important about work today",
        "Help me avoid a wrong financial step today",
        "Show me what deserves attention in my work life today",
        "Give me clarity about money matters today",
        "Help me see my priorities more clearly today",
        "Let me notice useful ideas or chances today",
        "Show me what I should focus on financially today",
      ],
      gradientColors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      glowColor: Color(0xFFFFD700),
    ),
    SignCategory(
      id: 'path',
      emoji: '🌿',
      name: 'LIFE PATH',
      questions: [
        "Give me a sign about my path today",
        "Help me understand what I should focus on today",
        "Show me what truly matters today",
        "Let me notice what feels right today",
        "Help me see my direction more clearly today",
        "Show me what I shouldn't ignore today",
        "Give me clarity about my next step today",
        "Help me understand my inner state today",
        "Let me notice meaningful moments today",
        "Show me what deserves my attention today",
      ],
      gradientColors: [Color(0xFF4ECB71), Color(0xFF2ECC71)],
      glowColor: Color(0xFF4ECB71),
    ),
    SignCategory(
      id: 'decision',
      emoji: '🔮',
      name: 'DECISION',
      questions: [
        "Give me a sign about a decision I'm thinking about",
        "Help me understand if I'm moving the right way today",
        "Show me what I should consider before deciding",
        "Let me notice what feels easy or heavy today",
        "Help me gain clarity about my choice today",
        "Show me what my intuition is pointing to today",
        "Give me a sign about my current situation",
        "Help me see what I'm overlooking today",
        "Let me notice what aligns with me today",
        "Show me what deserves a second thought today",
      ],
      gradientColors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
      glowColor: Color(0xFF9B59B6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    signService.loadResponses();
    
    _animationController = AnimationController(
      vsync: this,
      duration: UniverseSignService.animationDuration,
    );
    
    // Check for ongoing sending from service
    if (signService.isSending) {
      final progress = signService.animationProgress;
      if (progress < 1.0) {
        currentStatus = SignStatus.sending;
        selectedQuestion = signService.pendingQuestion;
        _animationController.forward(from: progress);
        _setupAnimationListener();
      }
    }
    
    // Check for unread messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUnreadMessages();
    });
    
    signService.addListener(() {
      if (mounted) {
        _checkForUnreadMessages();
      }
    });
  }
  
  void _checkForUnreadMessages() {
    if (!showReceivedDialog && 
        signService.responses.isNotEmpty && 
        currentStatus == SignStatus.idle) {
      final latestMessage = signService.responses.first;
      // Не показываем диалог, если он уже был закрыт для этого сообщения
      if (!latestMessage.isRead && latestMessage.id != _dialogDismissedMessageId) {
        setState(() {
          showReceivedDialog = true;
          currentQuestionForDialog = latestMessage.question;
          currentCategoryForDialog = latestMessage.category;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Generate general question for category with today's date
  String _generateCategoryQuestion(SignCategory category) {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM d, yyyy');
    final formattedDate = dateFormat.format(now);
    
    switch (category.id) {
      case 'love':
        return "Today is $formattedDate. What sign is the Universe sending me about love today?";
      case 'money':
        return "Today is $formattedDate. What sign is the Universe sending me about money and finances today?";
      case 'path':
        return "Today is $formattedDate. What sign is the Universe sending me about my life path today?";
      case 'decision':
        return "Today is $formattedDate. What sign is the Universe sending me about making decisions today?";
      default:
        return "Today is $formattedDate. What sign is the Universe sending me today?";
    }
  }

  /// Handle category tap - send general question directly
  void _onCategoryTap(SignCategory category) {
    final question = _generateCategoryQuestion(category);
    _sendQuestion(question, category.id);
  }

  /// Send selected question
  void _sendQuestion(String question, String categoryId) {
    signService.startSending(question, category: categoryId);
    
    setState(() {
      selectedQuestion = question;
      selectedCategoryId = categoryId;
      currentStatus = SignStatus.sending;
    });

    _animationController.reset();
    _animationController.forward();
    _setupAnimationListener();
  }
  
  void _setupAnimationListener() {
    _animationController.removeStatusListener(_onAnimationStatusChanged);
    _animationController.addStatusListener(_onAnimationStatusChanged);
  }
  
  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _onAnimationComplete();
    }
  }
  
  void _onAnimationComplete() async {
    final question = signService.pendingQuestion ?? selectedQuestion ?? '';
    final category = selectedCategoryId;
    await signService.completeSending();
    
    if (mounted) {
      currentQuestionForDialog = question;
      currentCategoryForDialog = category;
      setState(() {
        showReceivedDialog = true;
        currentStatus = SignStatus.idle;
      });
      selectedQuestion = null;
      selectedCategoryId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
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
            ),
            const SizedBox(width: 16),
            const Text(
              'Universe Sign',
              style: bold20White,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(fixPadding * 2),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: currentStatus == SignStatus.sending
                    ? _buildSendingAnimation()
                    : _buildCategorySelection(),
              ),
            ),
          ),
          if (showReceivedDialog) _buildReceivedDialog(),
        ],
      ),
    );
  }

  /// Build sending animation (same as universe_message.dart)
  Widget _buildSendingAnimation() {
    return AnimatedBuilder(
      key: const ValueKey('sending'),
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, -50 * value),
              child: Opacity(
                opacity: 1.0 - (value > 0.8 ? (value - 0.8) * 5 : 0.0),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ...List.generate(3, (index) {
                        final rippleValue = ((value * 3) + (index * 0.3)) % 1.0;
                        return Container(
                          height: 60 + (40 * rippleValue),
                          width: 60 + (40 * rippleValue),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.5 * (1 - rippleValue)),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                      const Icon(
                        Icons.rocket_launch_rounded,
                        size: 50,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            heightSpace,
            heightSpace,
            const Text(
              'Sending via satellites...',
              style: TextStyle(
                color: whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connecting to NASA network',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            heightSpace,
            heightSpace,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: fixPadding * 4),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: whiteColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        primaryColor.withValues(alpha: 0.8),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(value * 100).toInt()}%',
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build category selection UI
  Widget _buildCategorySelection() {
    return Column(
      key: const ValueKey('idle'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon with stars
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 5,
                left: 10,
                child: Icon(
                  Icons.star,
                  size: 16,
                  color: primaryColor.withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                top: 0,
                right: 15,
                child: Icon(
                  Icons.star,
                  size: 14,
                  color: primaryColor.withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 5,
                child: Icon(
                  Icons.star,
                  size: 12,
                  color: primaryColor.withValues(alpha: 0.4),
                ),
              ),
              const Icon(
                Icons.auto_awesome,
                size: 48,
                color: primaryColor,
              ),
            ],
          ),
        ),
        heightSpace,
        const Text(
          'Choose Your Sign',
          style: TextStyle(
            color: whiteColor,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'What would you like the Universe to guide you with today?',
          style: TextStyle(
            color: whiteColor.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        heightSpace,
        heightSpace,
        heightSpace,
        // Category bubbles grid
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: categories.map((category) => _buildCategoryBubble(category)).toList(),
        ),
      ],
    );
  }

  /// Build individual category bubble
  Widget _buildCategoryBubble(SignCategory category) {
    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category.gradientColors[0].withValues(alpha: 0.3),
              category.gradientColors[1].withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: category.gradientColors[0].withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: category.glowColor.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                color: whiteColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build received message dialog
  Widget _buildReceivedDialog() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
            padding: const EdgeInsets.all(fixPadding * 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F2E),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: whiteColor.withValues(alpha: 0.1),
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.mark_email_read_rounded,
                        size: 60,
                        color: greenColor,
                      ),
                      heightSpace,
                      heightSpace,
                      const Text(
                        'The Universe has responded',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      heightSpace,
                                            heightSpace,
                      const Text(
                        '🔒 The message is encrypted\nThe Universe speaks in symbols, not words\nOnly those ready can decode it',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      heightSpace,
                      heightSpace,
                      GestureDetector(
                        onTap: () async {
                          // Показать paywall перед переходом к расшифровке
                          await SuperwallService().showPaywall(
                            placement: "subscribe_button",
                            onPurchased: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  child: UniverseSignPlayerScreen(
                                    question: currentQuestionForDialog ?? '',
                                    category: currentCategoryForDialog,
                                  ),
                                  type: PageTransitionType.rightToLeft,
                                  duration: const Duration(milliseconds: 300),
                                ),
                              );
                            },
                            onDeclined: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Subscribe to unlock universe signs'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: fixPadding * 2,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [primaryColor, Color(0xFF7B5CFA)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              'Decode the Sign',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      if (signService.responses.isNotEmpty) {
                        final latestMessage = signService.responses.first;
                        _dialogDismissedMessageId = latestMessage.id; // Запоминаем ID закрытого сообщения
                        await signService.markAsRead(latestMessage.id);
                      }
                      if (mounted) {
                        setState(() {
                          showReceivedDialog = false;
                          currentStatus = SignStatus.idle;
                          currentQuestionForDialog = 'closed';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: whiteColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: whiteColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SignStatus {
  idle,
  sending,
  waiting,
  received,
}
