import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationStorageService {
  static final NotificationStorageService _instance = NotificationStorageService._internal();
  factory NotificationStorageService() => _instance;
  NotificationStorageService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference _getUserCollection(String collectionName) {
    if (_userId == null) throw Exception('User not logged in');
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc('data')
        .collection(collectionName);
  }

  // ==================== Universe Messages ====================

  Future<String> saveUniverseMessage({
    required String question,
    String? audioFilePath,
    required int audioDuration,
  }) async {
    final docRef = await _getUserCollection('universe_messages').add({
      'question': question,
      'audioFilePath': audioFilePath,
      'audioDuration': audioDuration,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Stream<List<UniverseMessageData>> getUniverseMessagesStream() {
    if (_userId == null) return Stream.value([]);
    
    return _getUserCollection('universe_messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UniverseMessageData.fromFirestore(doc))
            .toList());
  }

  Future<void> updateUniverseMessageAudioPath(String docId, String audioFilePath) async {
    await _getUserCollection('universe_messages').doc(docId).update({
      'audioFilePath': audioFilePath,
    });
  }

  Future<void> markUniverseMessageAsRead(String docId) async {
    await _getUserCollection('universe_messages').doc(docId).update({
      'isRead': true,
    });
  }

  Future<void> deleteUniverseMessage(String docId) async {
    await _getUserCollection('universe_messages').doc(docId).delete();
  }

  // ==================== Natal Charts ====================

  Future<String> saveNatalChart({
    required String name,
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required String location,
    required List<Map<String, dynamic>> planetsData,
  }) async {
    final docRef = await _getUserCollection('natal_charts').add({
      'name': name,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'timeOfBirth': timeOfBirth,
      'location': location,
      'planetsData': planetsData,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Stream<List<NatalChartData>> getNatalChartsStream() {
    if (_userId == null) return Stream.value([]);
    
    return _getUserCollection('natal_charts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NatalChartData.fromFirestore(doc))
            .toList());
  }

  Future<void> markNatalChartAsRead(String docId) async {
    await _getUserCollection('natal_charts').doc(docId).update({
      'isRead': true,
    });
  }

  Future<void> deleteNatalChart(String docId) async {
    await _getUserCollection('natal_charts').doc(docId).delete();
  }

  // ==================== Compatibility ====================

  Future<String> saveCompatibility({
    required String sign1,
    required String sign1Image,
    required String sign2,
    required String sign2Image,
    required double lovePercent,
    required double businessPercent,
    required double healthPercent,
  }) async {
    final docRef = await _getUserCollection('compatibility').add({
      'sign1': sign1,
      'sign1Image': sign1Image,
      'sign2': sign2,
      'sign2Image': sign2Image,
      'lovePercent': lovePercent,
      'businessPercent': businessPercent,
      'healthPercent': healthPercent,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Stream<List<CompatibilityData>> getCompatibilityStream() {
    if (_userId == null) return Stream.value([]);
    
    return _getUserCollection('compatibility')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CompatibilityData.fromFirestore(doc))
            .toList());
  }

  Future<void> markCompatibilityAsRead(String docId) async {
    await _getUserCollection('compatibility').doc(docId).update({
      'isRead': true,
    });
  }

  Future<void> deleteCompatibility(String docId) async {
    await _getUserCollection('compatibility').doc(docId).delete();
  }

  // ==================== Get unread counts ====================

  Future<int> getUnreadCount() async {
    if (_userId == null) return 0;
    
    int count = 0;
    
    final universeSnap = await _getUserCollection('universe_messages')
        .where('isRead', isEqualTo: false)
        .get();
    count += universeSnap.docs.length;
    
    final natalSnap = await _getUserCollection('natal_charts')
        .where('isRead', isEqualTo: false)
        .get();
    count += natalSnap.docs.length;
    
    final compatSnap = await _getUserCollection('compatibility')
        .where('isRead', isEqualTo: false)
        .get();
    count += compatSnap.docs.length;
    
    return count;
  }
}

// ==================== Data Models ====================

class UniverseMessageData {
  final String id;
  final String question;
  final String? audioFilePath;
  final int audioDuration;
  final bool isRead;
  final DateTime createdAt;

  UniverseMessageData({
    required this.id,
    required this.question,
    this.audioFilePath,
    required this.audioDuration,
    required this.isRead,
    required this.createdAt,
  });

  factory UniverseMessageData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UniverseMessageData(
      id: doc.id,
      question: data['question'] ?? '',
      audioFilePath: data['audioFilePath'],
      audioDuration: data['audioDuration'] ?? 10,
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

class NatalChartData {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String timeOfBirth;
  final String location;
  final List<Map<String, dynamic>> planetsData;
  final bool isRead;
  final DateTime createdAt;

  NatalChartData({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.location,
    required this.planetsData,
    required this.isRead,
    required this.createdAt,
  });

  factory NatalChartData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NatalChartData(
      id: doc.id,
      name: data['name'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeOfBirth: data['timeOfBirth'] ?? '',
      location: data['location'] ?? '',
      planetsData: List<Map<String, dynamic>>.from(data['planetsData'] ?? []),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

class CompatibilityData {
  final String id;
  final String sign1;
  final String sign1Image;
  final String sign2;
  final String sign2Image;
  final double lovePercent;
  final double businessPercent;
  final double healthPercent;
  final bool isRead;
  final DateTime createdAt;

  CompatibilityData({
    required this.id,
    required this.sign1,
    required this.sign1Image,
    required this.sign2,
    required this.sign2Image,
    required this.lovePercent,
    required this.businessPercent,
    required this.healthPercent,
    required this.isRead,
    required this.createdAt,
  });

  factory CompatibilityData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CompatibilityData(
      id: doc.id,
      sign1: data['sign1'] ?? '',
      sign1Image: data['sign1Image'] ?? '',
      sign2: data['sign2'] ?? '',
      sign2Image: data['sign2Image'] ?? '',
      lovePercent: (data['lovePercent'] ?? 0.0).toDouble(),
      businessPercent: (data['businessPercent'] ?? 0.0).toDouble(),
      healthPercent: (data['healthPercent'] ?? 0.0).toDouble(),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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


