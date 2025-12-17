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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
                  color: recBgColor.withValues(alpha: 0.8),
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
      body: Container(
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
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(fixPadding * 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Category emoji and title
                        Text(
                          _getCategoryEmoji(),
                          style: const TextStyle(fontSize: 50),
                        ),
                        heightSpace,
                        const Text(
                          'A sign has arrived',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        heightSpace,
                        heightSpace,
                        heightSpace,
                        
                        // Audio Player
                        _buildAudioPlayer(),
                        
                        heightSpace,
                        heightSpace,
                        heightSpace,
                        
                        // Tooltip-styled message
                        _buildTooltipMessage(),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom button
              Padding(
                padding: const EdgeInsets.all(fixPadding * 2),
                child: _buildDecodeButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 2),
      decoration: BoxDecoration(
        color: blueShade1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Play button
          GestureDetector(
            onTap: isLoading ? null : _togglePlayPause,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.8),
                    const Color(0xFF7B5CFA).withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: whiteColor,
                      strokeWidth: 2,
                    )
                  : Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: whiteColor,
                      size: 45,
                    ),
            ),
          ),
          
          heightSpace,
          heightSpace,
          
          // Progress bar
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
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: whiteColor.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 6,
                    ),
                  ),
                  heightBox(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: regualr14Grey,
                      ),
                      Text(
                        _formatDuration(totalDuration),
                        style: regualr14Grey,
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

  Widget _buildTooltipMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: fixPadding * 3,
        vertical: fixPadding * 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF08080C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2A2A35),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🔒 The message is encrypted',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          heightBox(10),
          Text(
            'Only decoding reveals its meaning',
            style: TextStyle(
              color: whiteColor.withValues(alpha: 0.6),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDecodeButton() {
    return GestureDetector(
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C6BAB), Color(0xFF6B5A91)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B5CFA).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Decode the Sign',
            style: TextStyle(
              color: whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
