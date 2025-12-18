import 'package:fl_astro_circle/pages/universeMessage/universe_decipher_screen.dart';
import 'package:fl_astro_circle/services/cosmic_audio_generator.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'package:fl_astro_circle/services/superwall_service.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

/// Intermediate screen with audio player before decryption
class UniverseSignPlayerScreen extends StatefulWidget {
  final String question;
  final String? category;
  final String? messageId;

  const UniverseSignPlayerScreen({
    super.key,
    required this.question,
    this.category,
    this.messageId,
  });

  @override
  State<UniverseSignPlayerScreen> createState() => _UniverseSignPlayerScreenState();
}

class _UniverseSignPlayerScreenState extends State<UniverseSignPlayerScreen> {
  final CosmicAudioGenerator audioGenerator = CosmicAudioGenerator();
  final NotificationStorageService storageService = NotificationStorageService();
  
  bool isPlaying = false;
  bool isLoading = false;
  int audioDuration = 15; // Default duration
  
  late final VoidCallback _audioStateListener;

  @override
  void initState() {
    super.initState();
    _audioStateListener = () {
      if (mounted) {
        setState(() {
          isPlaying = audioGenerator.isPlaying;
        });
      }
    };
    audioGenerator.setOnStateChanged(_audioStateListener);
    
    // Load message data if messageId provided
    _loadMessageData();
  }

  Future<void> _loadMessageData() async {
    if (widget.messageId != null) {
      // Try to get audio duration from stored message
      final messages = await storageService.getUniverseMessagesStream().first;
      final message = messages.where((m) => m.id == widget.messageId).firstOrNull;
      if (message != null && mounted) {
        setState(() {
          audioDuration = message.audioDuration;
        });
      }
    }
  }

  @override
  void dispose() {
    audioGenerator.stop();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await audioGenerator.pause();
    } else if (audioGenerator.position > Duration.zero) {
      await audioGenerator.resume();
    } else {
      setState(() => isLoading = true);
      
      await audioGenerator.playCosmicMessage(
        messageId: widget.messageId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
        durationSeconds: audioDuration,
        audioFilePath: null,
        onComplete: () {
          if (mounted) {
            setState(() => isPlaying = false);
          }
        },
      );
      
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Minimalist Modern Theme Colors - Purple Edition
    // Using deep purple background to match app theme
    final bgColor = const Color(0xFF130B29); // Deep space purple
    final cardColor = const Color(0xFF221642); // Lighter purple for cards
    final accentColor = _getCategoryColor(); // Vivid category color
    final primaryAccent = const Color(0xFF7B5CFA); // App's primary purple

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Universe Sign',
          style: bold20White.copyWith(letterSpacing: 0.5),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: whiteColor,
              size: 20,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          // Subtle gradient to add depth without clutter
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1F1147),
              const Color(0xFF130B29),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category & Title Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          _getCategoryEmoji(),
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      heightSpace,
                      const Text(
                        'A sign has arrived',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Audio Player - Minimalist Round
                      _buildMinimalAudioPlayer(cardColor, accentColor),
                      
                      const SizedBox(height: 40),

                      // Encrypted Message - Clean Box
                      _buildMinimalMessage(cardColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalAudioPlayer(Color cardColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: isLoading ? null : _togglePlayPause,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: isPlaying ? accentColor : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isPlaying ? accentColor : Colors.white).withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: isPlaying ? whiteColor : accentColor,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: isPlaying ? whiteColor : accentColor,
                          size: 40,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          StreamBuilder<Duration>(
            stream: audioGenerator.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final totalDuration = Duration(seconds: audioDuration);
              final progress = totalDuration.inMilliseconds > 0
                  ? position.inMilliseconds / totalDuration.inMilliseconds
                  : 0.0;

              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(totalDuration),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalMessage(Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFFFFD700),
              size: 24,
            ),
          ),
          heightBox(15),
          const Text(
            'The message is encrypted',
            style: TextStyle(
              color: whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          heightBox(8),
          const Text(
            'Only decoding reveals its meaning',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 25),
          
          // Decode Button inside the card
          GestureDetector(
            onTap: () async {
              await SuperwallService().showPaywall(
                placement: "subscribe_button",
                onPurchased: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: UniverseDecipherScreen(
                        question: widget.question,
                        category: widget.category,
                        messageId: widget.messageId,
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              decoration: BoxDecoration(
                // Purple Gradient Button
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7B5CFA),
                    Color(0xFF5D40D9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B5CFA).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Decode the Sign',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
