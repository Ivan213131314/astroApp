import 'package:flutter/foundation.dart';
import 'package:fl_astro_circle/services/notification_storage_service.dart';
import 'dart:async';
import 'dart:math';

class UniverseMessageService extends ChangeNotifier {
  static final UniverseMessageService _instance = UniverseMessageService._internal();
  factory UniverseMessageService() => _instance;
  UniverseMessageService._internal();

  final NotificationStorageService _storageService = NotificationStorageService();
  
  List<UniverseMessageData> _responses = [];
  int _unreadCount = 0;
  StreamSubscription? _subscription;

  // Animation duration constant
  static const Duration animationDuration = Duration(seconds: 10);

  // Sending state - persists across navigation
  DateTime? _sendStartTime;
  String? _pendingQuestion;
  Timer? _autoCompleteTimer;

  List<UniverseMessageData> get responses => _responses;
  int get unreadCount => _unreadCount;

  // Sending state getters
  bool get isSending => _sendStartTime != null;
  String? get pendingQuestion => _pendingQuestion;

  /// Returns animation progress from 0.0 to 1.0
  double get animationProgress {
    if (_sendStartTime == null) return 0.0;
    final elapsed = DateTime.now().difference(_sendStartTime!);
    final progress = elapsed.inMilliseconds / animationDuration.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }

  /// Returns remaining time for animation
  Duration get remainingTime {
    if (_sendStartTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_sendStartTime!);
    final remaining = animationDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Start sending - call this when user taps send
  /// Automatically saves message after animationDuration regardless of UI state
  void startSending(String question) {
    // Cancel any existing timer
    _autoCompleteTimer?.cancel();
    
    _pendingQuestion = question;
    _sendStartTime = DateTime.now();
    
    // Set up auto-complete timer - this will save the message even if user navigates away
    _autoCompleteTimer = Timer(animationDuration, () {
      _autoCompleteSending();
    });
    
    notifyListeners();
  }

  /// Called automatically by timer when animation duration passes
  Future<void> _autoCompleteSending() async {
    if (_pendingQuestion != null) {
      final question = _pendingQuestion!;
      _pendingQuestion = null;
      _sendStartTime = null;
      _autoCompleteTimer = null;
      
      await addUniverseResponse(question);
      notifyListeners();
    }
  }

  /// Complete sending - call when animation finishes (from UI)
  /// If timer already auto-completed, this does nothing
  Future<void> completeSending() async {
    // Cancel timer since we're completing manually
    _autoCompleteTimer?.cancel();
    _autoCompleteTimer = null;
    
    if (_pendingQuestion != null) {
      await addUniverseResponse(_pendingQuestion!);
    }
    _pendingQuestion = null;
    _sendStartTime = null;
    notifyListeners();
  }

  /// Cancel sending (if user cancels)
  void cancelSending() {
    _autoCompleteTimer?.cancel();
    _autoCompleteTimer = null;
    _pendingQuestion = null;
    _sendStartTime = null;
    notifyListeners();
  }

  void loadResponses() {
    _subscription?.cancel();
    _subscription = _storageService.getUniverseMessagesStream().listen((messages) {
      _responses = messages;
      _unreadCount = messages.where((r) => !r.isRead).length;
      notifyListeners();
    });
  }

  Future<void> addUniverseResponse(String question) async {
    final audioDuration = Random().nextInt(13) + 8; // 8-20 секунд
    await _storageService.saveUniverseMessage(
      question: question,
      audioFilePath: null,
      audioDuration: audioDuration,
    );
  }

  Future<void> updateAudioFilePath(String id, String filePath) async {
    await _storageService.updateUniverseMessageAudioPath(id, filePath);
  }

  Future<void> markAsRead(String id) async {
    await _storageService.markUniverseMessageAsRead(id);
  }

  Future<void> markAllAsRead() async {
    for (var response in _responses) {
      if (!response.isRead) {
        await _storageService.markUniverseMessageAsRead(response.id);
      }
    }
  }

  Future<void> deleteResponse(String id) async {
    await _storageService.deleteUniverseMessage(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Keep this for backwards compatibility, but use UniverseMessageData from storage service
typedef UniverseResponse = UniverseMessageData;
