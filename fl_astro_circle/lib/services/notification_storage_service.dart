import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

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
    String? sunSign,
    String? moonSign,
    String? risingSign,
    String? sunTeaser,
    String? moonTeaser,
    String? risingTeaser,
  }) async {
    final docRef = await _getUserCollection('natal_charts').add({
      'name': name,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'timeOfBirth': timeOfBirth,
      'location': location,
      'planetsData': planetsData,
      'sunSign': sunSign,
      'moonSign': moonSign,
      'risingSign': risingSign,
      'sunTeaser': sunTeaser,
      'moonTeaser': moonTeaser,
      'risingTeaser': risingTeaser,
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

  /// Обновить AI-контент для натальной карты
  Future<void> updateNatalChartContent(
    String docId, {
    String? sunTeaser,
    String? sunDetail,
    String? moonTeaser,
    String? moonDetail,
    String? risingTeaser,
    String? risingDetail,
  }) async {
    final updates = <String, dynamic>{};
    if (sunTeaser != null) updates['sunTeaser'] = sunTeaser;
    if (sunDetail != null) updates['sunDetail'] = sunDetail;
    if (moonTeaser != null) updates['moonTeaser'] = moonTeaser;
    if (moonDetail != null) updates['moonDetail'] = moonDetail;
    if (risingTeaser != null) updates['risingTeaser'] = risingTeaser;
    if (risingDetail != null) updates['risingDetail'] = risingDetail;
    
    if (updates.isNotEmpty) {
      await _getUserCollection('natal_charts').doc(docId).update(updates);
    }
  }

  /// Получить данные натальной карты по ID
  Future<NatalChartData?> getNatalChartById(String docId) async {
    if (_userId == null) return null;
    
    final doc = await _getUserCollection('natal_charts').doc(docId).get();
    if (doc.exists) {
      return NatalChartData.fromFirestore(doc);
    }
    return null;
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
    String? name1,
    String? name2,
    String? birthDate1,
    String? birthDate2,
  }) async {
    final docRef = await _getUserCollection('compatibility').add({
      'sign1': sign1,
      'sign1Image': sign1Image,
      'sign2': sign2,
      'sign2Image': sign2Image,
      'lovePercent': lovePercent,
      'businessPercent': businessPercent,
      'healthPercent': healthPercent,
      'name1': name1,
      'name2': name2,
      'birthDate1': birthDate1,
      'birthDate2': birthDate2,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Поиск существующей совместимости по именам и датам рождения
  Future<CompatibilityData?> findExistingCompatibility({
    required String name1,
    required String name2,
    required String birthDate1,
    required String birthDate2,
  }) async {
    if (_userId == null) return null;
    
    // Ищем точное совпадение по именам и датам (в обоих порядках)
    final query1 = await _getUserCollection('compatibility')
        .where('name1', isEqualTo: name1)
        .where('name2', isEqualTo: name2)
        .where('birthDate1', isEqualTo: birthDate1)
        .where('birthDate2', isEqualTo: birthDate2)
        .limit(1)
        .get();
    
    if (query1.docs.isNotEmpty) {
      return CompatibilityData.fromFirestore(query1.docs.first);
    }
    
    // Проверяем обратный порядок (person1 <-> person2)
    final query2 = await _getUserCollection('compatibility')
        .where('name1', isEqualTo: name2)
        .where('name2', isEqualTo: name1)
        .where('birthDate1', isEqualTo: birthDate2)
        .where('birthDate2', isEqualTo: birthDate1)
        .limit(1)
        .get();
    
    if (query2.docs.isNotEmpty) {
      return CompatibilityData.fromFirestore(query2.docs.first);
    }
    
    return null;
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

  /// Обновить AI-контент для совместимости
  Future<void> updateCompatibilityContent(
    String docId, {
    String? loveTeaser,
    String? loveDetail,
    String? businessTeaser,
    String? businessDetail,
    String? healthTeaser,
    String? healthDetail,
  }) async {
    final updates = <String, dynamic>{};
    if (loveTeaser != null) updates['loveTeaser'] = loveTeaser;
    if (loveDetail != null) updates['loveDetail'] = loveDetail;
    if (businessTeaser != null) updates['businessTeaser'] = businessTeaser;
    if (businessDetail != null) updates['businessDetail'] = businessDetail;
    if (healthTeaser != null) updates['healthTeaser'] = healthTeaser;
    if (healthDetail != null) updates['healthDetail'] = healthDetail;
    
    if (updates.isNotEmpty) {
      await _getUserCollection('compatibility').doc(docId).update(updates);
    }
  }

  /// Получить данные совместимости по ID
  Future<CompatibilityData?> getCompatibilityById(String docId) async {
    if (_userId == null) return null;
    
    final doc = await _getUserCollection('compatibility').doc(docId).get();
    if (doc.exists) {
      return CompatibilityData.fromFirestore(doc);
    }
    return null;
  }

  // ==================== Numerology ====================

  Future<String> saveNumerology({
    required int luckyNumber,
    required String birthDate,
    required Map<String, double> traits,
    required String aboutCharacter,
    required String aboutBehavior,
    required String aboutResponsibility,
  }) async {
    final docRef = await _getUserCollection('numerology').add({
      'luckyNumber': luckyNumber,
      'birthDate': birthDate,
      'traits': traits,
      'aboutCharacter': aboutCharacter,
      'aboutBehavior': aboutBehavior,
      'aboutResponsibility': aboutResponsibility,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Поиск существующей нумерологии по дате рождения
  Future<NumerologyData?> findExistingNumerology({
    required String birthDate,
  }) async {
    if (_userId == null) return null;
    
    final query = await _getUserCollection('numerology')
        .where('birthDate', isEqualTo: birthDate)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      return NumerologyData.fromFirestore(query.docs.first);
    }
    
    return null;
  }

  Stream<List<NumerologyData>> getNumerologyStream() {
    if (_userId == null) return Stream.value([]);
    
    return _getUserCollection('numerology')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NumerologyData.fromFirestore(doc))
            .toList());
  }

  Future<void> markNumerologyAsRead(String docId) async {
    await _getUserCollection('numerology').doc(docId).update({
      'isRead': true,
    });
  }

  Future<void> deleteNumerology(String docId) async {
    await _getUserCollection('numerology').doc(docId).delete();
  }

  /// Обновить AI-контент для нумерологии (детальный анализ)
  Future<void> updateNumerologyContent(
    String docId, {
    String? characterDetail,
    String? behaviorDetail,
    String? responsibilityDetail,
  }) async {
    final updates = <String, dynamic>{};
    if (characterDetail != null) updates['characterDetail'] = characterDetail;
    if (behaviorDetail != null) updates['behaviorDetail'] = behaviorDetail;
    if (responsibilityDetail != null) updates['responsibilityDetail'] = responsibilityDetail;
    
    if (updates.isNotEmpty) {
      await _getUserCollection('numerology').doc(docId).update(updates);
    }
  }

  /// Получить данные нумерологии по ID
  Future<NumerologyData?> getNumerologyById(String docId) async {
    if (_userId == null) return null;
    
    final doc = await _getUserCollection('numerology').doc(docId).get();
    if (doc.exists) {
      return NumerologyData.fromFirestore(doc);
    }
    return null;
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
    
    final numerologySnap = await _getUserCollection('numerology')
        .where('isRead', isEqualTo: false)
        .get();
    count += numerologySnap.docs.length;
    
    return count;
  }

  /// Stream для получения количества непрочитанных уведомлений в реальном времени
  Stream<int> getUnreadCountStream() {
    if (_userId == null) return Stream.value(0);

    // Слушаем все 4 коллекции
    final universeStream = _getUserCollection('universe_messages')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);

    final natalStream = _getUserCollection('natal_charts')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);

    final compatStream = _getUserCollection('compatibility')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);

    final numerologyStream = _getUserCollection('numerology')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);

    // Комбинируем все 4 стрима - при изменении любого пересчитывается сумма
    return Rx.combineLatest4(
      universeStream,
      natalStream,
      compatStream,
      numerologyStream,
      (int universe, int natal, int compat, int numerology) {
        return universe + natal + compat + numerology;
      },
    );
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
  
  // Знаки зодиака
  final String? sunSign;
  final String? moonSign;
  final String? risingSign;
  
  // AI-сгенерированный контент
  final String? sunTeaser;
  final String? sunDetail;
  final String? moonTeaser;
  final String? moonDetail;
  final String? risingTeaser;
  final String? risingDetail;

  NatalChartData({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.location,
    required this.planetsData,
    required this.isRead,
    required this.createdAt,
    this.sunSign,
    this.moonSign,
    this.risingSign,
    this.sunTeaser,
    this.sunDetail,
    this.moonTeaser,
    this.moonDetail,
    this.risingTeaser,
    this.risingDetail,
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
      sunSign: data['sunSign'],
      moonSign: data['moonSign'],
      risingSign: data['risingSign'],
      sunTeaser: data['sunTeaser'],
      sunDetail: data['sunDetail'],
      moonTeaser: data['moonTeaser'],
      moonDetail: data['moonDetail'],
      risingTeaser: data['risingTeaser'],
      risingDetail: data['risingDetail'],
    );
  }

  /// Проверить, есть ли все тизеры
  bool get hasAllTeasers => 
      sunTeaser != null && moonTeaser != null && risingTeaser != null;

  /// Проверить, есть ли детальный контент для категории
  bool hasDetail(String category) {
    switch (category) {
      case 'sun':
        return sunDetail != null;
      case 'moon':
        return moonDetail != null;
      case 'rising':
        return risingDetail != null;
      default:
        return false;
    }
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
  
  // Персональные данные
  final String? name1;
  final String? name2;
  final String? birthDate1;
  final String? birthDate2;
  
  // AI-сгенерированный контент
  final String? loveTeaser;
  final String? loveDetail;
  final String? businessTeaser;
  final String? businessDetail;
  final String? healthTeaser;
  final String? healthDetail;

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
    this.name1,
    this.name2,
    this.birthDate1,
    this.birthDate2,
    this.loveTeaser,
    this.loveDetail,
    this.businessTeaser,
    this.businessDetail,
    this.healthTeaser,
    this.healthDetail,
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
      name1: data['name1'],
      name2: data['name2'],
      birthDate1: data['birthDate1'],
      birthDate2: data['birthDate2'],
      loveTeaser: data['loveTeaser'],
      loveDetail: data['loveDetail'],
      businessTeaser: data['businessTeaser'],
      businessDetail: data['businessDetail'],
      healthTeaser: data['healthTeaser'],
      healthDetail: data['healthDetail'],
    );
  }
  
  /// Получить отображаемое название (имена или знаки)
  String get displayTitle {
    if (name1 != null && name1!.isNotEmpty && name2 != null && name2!.isNotEmpty) {
      return '$name1 & $name2';
    }
    return '$sign1 & $sign2';
  }
  
  /// Получить подзаголовок (знаки если есть имена)
  String get displaySubtitle {
    if (name1 != null && name1!.isNotEmpty) {
      return '$sign1 & $sign2';
    }
    return '';
  }

  /// Проверить, есть ли все тизеры
  bool get hasAllTeasers => 
      loveTeaser != null && businessTeaser != null && healthTeaser != null;

  /// Проверить, есть ли детальный контент для категории
  bool hasDetail(String category) {
    switch (category) {
      case 'love':
        return loveDetail != null;
      case 'business':
        return businessDetail != null;
      case 'health':
        return healthDetail != null;
      default:
        return false;
    }
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

class NumerologyData {
  final String id;
  final int luckyNumber;
  final String birthDate;
  final Map<String, double> traits;
  final String aboutCharacter;
  final String aboutBehavior;
  final String aboutResponsibility;
  final bool isRead;
  final DateTime createdAt;
  
  // AI-сгенерированный детальный контент
  final String? characterDetail;
  final String? behaviorDetail;
  final String? responsibilityDetail;

  NumerologyData({
    required this.id,
    required this.luckyNumber,
    required this.birthDate,
    required this.traits,
    required this.aboutCharacter,
    required this.aboutBehavior,
    required this.aboutResponsibility,
    required this.isRead,
    required this.createdAt,
    this.characterDetail,
    this.behaviorDetail,
    this.responsibilityDetail,
  });

  factory NumerologyData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Парсим traits
    final traitsMap = <String, double>{};
    if (data['traits'] != null) {
      final rawTraits = data['traits'] as Map<String, dynamic>;
      rawTraits.forEach((key, value) {
        traitsMap[key] = (value as num).toDouble();
      });
    }
    
    return NumerologyData(
      id: doc.id,
      luckyNumber: data['luckyNumber'] ?? 1,
      birthDate: data['birthDate'] ?? '',
      traits: traitsMap,
      aboutCharacter: data['aboutCharacter'] ?? '',
      aboutBehavior: data['aboutBehavior'] ?? '',
      aboutResponsibility: data['aboutResponsibility'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      characterDetail: data['characterDetail'],
      behaviorDetail: data['behaviorDetail'],
      responsibilityDetail: data['responsibilityDetail'],
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
  
  /// Проверить, есть ли детальный контент для категории
  bool hasDetail(String category) {
    switch (category) {
      case 'character':
        return characterDetail != null;
      case 'behavior':
        return behaviorDetail != null;
      case 'responsibility':
        return responsibilityDetail != null;
      default:
        return false;
    }
  }
}

