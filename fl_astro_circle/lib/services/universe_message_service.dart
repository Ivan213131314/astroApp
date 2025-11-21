import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class UniverseMessageService extends ChangeNotifier {
  static final UniverseMessageService _instance = UniverseMessageService._internal();
  factory UniverseMessageService() => _instance;
  UniverseMessageService._internal();

  List<UniverseResponse> _responses = [];
  int _unreadCount = 0;

  List<UniverseResponse> get responses => _responses;
  int get unreadCount => _unreadCount;

  Future<void> loadResponses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? responsesJson = prefs.getString('universe_responses');
    
    if (responsesJson != null) {
      final List<dynamic> decoded = json.decode(responsesJson);
      _responses = decoded.map((e) => UniverseResponse.fromJson(e)).toList();
      _unreadCount = _responses.where((r) => !r.isRead).length;
      notifyListeners();
    }
  }

  Future<void> addUniverseResponse(String question) async {
    final response = UniverseResponse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question,
      audioUrl: 'mock_audio_${Random().nextInt(1000)}.mp3',
      audioDuration: Random().nextInt(13) + 8, // 8-20 секунд
      timestamp: DateTime.now(),
      isRead: false,
    );

    _responses.insert(0, response);
    _unreadCount++;
    await _saveResponses();
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _responses.indexWhere((r) => r.id == id);
    if (index != -1 && !_responses[index].isRead) {
      _responses[index].isRead = true;
      _unreadCount--;
      await _saveResponses();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (var response in _responses) {
      response.isRead = true;
    }
    _unreadCount = 0;
    await _saveResponses();
    notifyListeners();
  }

  Future<void> deleteResponse(String id) async {
    final index = _responses.indexWhere((r) => r.id == id);
    if (index != -1) {
      if (!_responses[index].isRead) {
        _unreadCount--;
      }
      _responses.removeAt(index);
      await _saveResponses();
      notifyListeners();
    }
  }

  Future<void> _saveResponses() async {
    final prefs = await SharedPreferences.getInstance();
    final responsesJson = json.encode(_responses.map((e) => e.toJson()).toList());
    await prefs.setString('universe_responses', responsesJson);
  }
}

class UniverseResponse {
  final String id;
  final String question;
  final String audioUrl;
  final int audioDuration;
  final DateTime timestamp;
  bool isRead;

  UniverseResponse({
    required this.id,
    required this.question,
    required this.audioUrl,
    required this.audioDuration,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'audioUrl': audioUrl,
      'audioDuration': audioDuration,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory UniverseResponse.fromJson(Map<String, dynamic> json) {
    return UniverseResponse(
      id: json['id'],
      question: json['question'],
      audioUrl: json['audioUrl'],
      audioDuration: json['audioDuration'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

