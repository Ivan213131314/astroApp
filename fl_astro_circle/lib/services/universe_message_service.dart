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

  List<UniverseMessageData> get responses => _responses;
  int get unreadCount => _unreadCount;

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
